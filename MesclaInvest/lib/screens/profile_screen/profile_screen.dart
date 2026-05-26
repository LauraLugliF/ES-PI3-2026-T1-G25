import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/profile_widgets.dart';
import '../../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const ProfileData _profileData = ProfileData(
    name: 'Nome do usuário',
    email: 'email@exemplo.com',
    phone: '(00) 00000-0000',
  );
  // TODO: quando reimplementar dados reais do perfil, substituir estes dados fixos.

  bool _isMfaLoading = false;
  String? _mfaMessage;
  
  void _onNavTap(int index) {
    // Evita navegar durante o fluxo de MFA para não desmontar a tela no meio
    // de callbacks/dialgos assíncronos.
    if (_isMfaLoading) return;
    // Delegar navegação ao helper já existente.
    // TODO: ajustar comportamento se necessário ao restaurar lógica.
    handleBottomNavTap(context, currentIndex: 3, tappedIndex: index);
  }

  Future<String?> _askTextInput({
    required String title,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    if (!mounted) return null;

    final controller = TextEditingController();

    final value = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            autofocus: true,
            decoration: InputDecoration(labelText: label),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return value;
  }

  Future<void> _start2FAFlow() async {
    if (_isMfaLoading) return;

    setState(() {
      _isMfaLoading = true;
      _mfaMessage = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-logged-in',
          message: 'Faça login novamente para cadastrar o segundo fator.',
        );
      }

      final phoneNumber = await _askTextInput(
        title: 'Cadastrar telefone MFA',
        label: 'Telefone com DDI (ex.: +5511999999999)',
        keyboardType: TextInputType.phone,
      );

      if (!mounted || phoneNumber == null || phoneNumber.isEmpty) {
        return;
      }

      if (user.email == null || user.email!.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-email',
          message: 'Conta sem e-mail para reautenticação. Faça login novamente.',
        );
      }

      final password = await _askTextInput(
        title: 'Confirme sua senha',
        label: 'Senha atual da conta',
        obscureText: true,
      );

      if (!mounted || password == null || password.isEmpty) {
        return;
      }

      // Reautentica o usuário antes de operações sensíveis (enroll MFA).
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Cria a sessão MFA e inicia a verificação de número de telefone.
      final multiFactorSession = await user.multiFactor.getSession();
      final completer = Completer<void>();

      await auth.verifyPhoneNumber(
        multiFactorSession: multiFactorSession,
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneCredential) async {
          try {
            await user.multiFactor.enroll(
              PhoneMultiFactorGenerator.getAssertion(phoneCredential),
            );
            if (!completer.isCompleted) completer.complete();
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) completer.completeError(e);
        },
        codeSent: (String verificationId, int? resendToken) async {
          if (!mounted) {
            if (!completer.isCompleted) {
              completer.completeError(
                FirebaseAuthException(
                  code: 'profile-unmounted',
                  message: 'Tela de perfil foi fechada durante o fluxo de MFA.',
                ),
              );
            }
            return;
          }

          try {
            final smsCode = await _askTextInput(
              title: 'Código SMS',
              label: 'Digite o código recebido',
              keyboardType: TextInputType.number,
            );

            if (smsCode == null || smsCode.isEmpty) {
              if (!completer.isCompleted) {
                completer.completeError(
                  FirebaseAuthException(
                    code: 'sms-code-empty',
                    message: 'Código SMS não informado.',
                  ),
                );
              }
              return;
            }

            final smsCredential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            if (!mounted) {
              if (!completer.isCompleted) {
                completer.completeError(
                  FirebaseAuthException(
                    code: 'profile-unmounted',
                    message: 'Tela de perfil foi fechada durante o fluxo de MFA.',
                  ),
                );
              }
              return;
            }

            await user.multiFactor.enroll(
              PhoneMultiFactorGenerator.getAssertion(smsCredential),
            );

            if (!completer.isCompleted) completer.complete();
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          }
        },
        codeAutoRetrievalTimeout: (_) {
          if (!completer.isCompleted) {
            completer.completeError(
              FirebaseAuthException(
                code: 'sms-timeout',
                message: 'Tempo para inserir o código expirou. Tente novamente.',
              ),
            );
          }
        },
      );

      await completer.future;

      if (!mounted) return;
      setState(() {
        _mfaMessage = 'Autenticacao por SMS ativada com sucesso.';
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _mfaMessage = e.message ?? 'Nao foi possivel ativar o MFA.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mfaMessage = 'Ocorreu um erro inesperado ao ativar o MFA.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isMfaLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ProfileHeaderCard(profileData: _profileData),
            const SizedBox(height: 20),
            
            const Divider(height: 40),

            // --- SEÇÃO DE 2FA ---
            const Text('Segurança', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Segurança: permite cadastrar segundo fator por SMS no perfil.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nenhum número cadastrado na conta.'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isMfaLoading ? null : _start2FAFlow,
                    icon: const Icon(Icons.security),
                    label: _isMfaLoading
                        ? const Text('Processando...')
                        : const Text('Ativar Autenticacao por SMS'),
                  ),
                ),
                if (_mfaMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _mfaMessage!,
                    style: TextStyle(
                      color: _mfaMessage!.toLowerCase().contains('sucesso')
                          ? Colors.green
                          : Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),

            const Divider(height: 40),

            // --- BOTÃO DE LOGOUT ---
            SizedBox(
              width: double.infinity,
                child: OutlinedButton.icon(
                // Botão de logout desabilitado (interface apenas).
                // TODO: implementar `_logout()` e alterar `onPressed` para
                // `() => _logout()` quando reativar a lógica de autenticação.
                onPressed: null,
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: _onNavTap,
      ),
    );
  }
}
