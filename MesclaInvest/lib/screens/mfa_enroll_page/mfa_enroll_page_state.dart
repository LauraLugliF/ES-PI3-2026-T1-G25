//Max Thomazini Barbosa RA:25003934
part of 'mfa_enroll_page.dart';

class _MfaEnrollPageState extends State<MfaEnrollPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final MfaEnrollService _service = MfaEnrollService();

  bool _isSendingCode = false;
  bool _isEnrolling = false;
  String? _verificationId;
  String? _message;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  Future<void> _sendSmsCode() async {
    if (_isSendingCode || _isEnrolling) return;

    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      setState(() {
        _message = 'Preencha telefone e senha para continuar.';
      });
      return;
    }

    setState(() {
      _isSendingCode = true;
      _message = null;
    });

    try {
      await _service.sendSmsCode(
        phoneNumber: phone,
        password: password,
        onCodeSent: (verificationId) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _message = 'Codigo enviado por SMS. Digite abaixo para concluir.';
          });
        },
        onTimeout: (verificationId) {
          if (!mounted) return;
          if (_verificationId == null) {
            setState(() {
              _verificationId = verificationId;
            });
          }
        },
        onVerificationCompleted: (phoneCredential) async {
          try {
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              if (!mounted) return;
              setState(() {
                _message = 'Usuario nao autenticado. Faca login novamente.';
              });
              return;
            }

            await user.multiFactor.enroll(
              PhoneMultiFactorGenerator.getAssertion(phoneCredential),
            );
            if (!mounted) return;
            setState(() {
              _message = 'Autenticacao por SMS ativada com sucesso.';
            });
            Navigator.of(context).pop(true);
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;
            setState(() {
              _message = e.message ?? 'Falha ao ativar MFA automaticamente.';
            });
          }
        },
        onError: (message) {
          if (!mounted) return;
          setState(() {
            _message = message;
          });
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _message = e.message ?? 'Nao foi possivel iniciar o fluxo MFA.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Erro inesperado ao enviar codigo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  Future<void> _confirmSmsCode() async {
    if (_isEnrolling || _isSendingCode) return;

    final verificationId = _verificationId;
    final smsCode = _smsCodeController.text.trim();

    if (verificationId == null || verificationId.isEmpty) {
      setState(() {
        _message = 'Envie o codigo SMS primeiro.';
      });
      return;
    }

    if (smsCode.isEmpty) {
      setState(() {
        _message = 'Informe o codigo SMS recebido.';
      });
      return;
    }

    setState(() {
      _isEnrolling = true;
      _message = null;
    });

    try {
      await _service.confirmSmsCode(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      if (!mounted) return;
      setState(() {
        _message = 'Autenticacao por SMS ativada com sucesso.';
      });
      Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _message = e.message ?? 'Nao foi possivel confirmar o codigo SMS.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Erro inesperado ao confirmar codigo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isEnrolling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isSendingCode || _isEnrolling;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MfaEnrollHeader(),
              const SizedBox(height: 32),
              const MfaIntroCard(),
              const SizedBox(height: 20),
              const MfaStepsCard(),
              const SizedBox(height: 32),
              MfaInputField(
                icon: Icons.phone_outlined,
                hintText: 'Telefone com DDI (ex: +5511999999999)',
                controller: _phoneController,
                isPassword: false,
                enabled: !isBusy,
                inputBorder: const Color(0xFFE0E0E0),
                textGrey: const Color(0xFF8B9297),
              ),
              const SizedBox(height: 16),
              MfaInputField(
                icon: Icons.lock_open_outlined,
                hintText: 'Senha atual',
                controller: _passwordController,
                isPassword: true,
                enabled: !isBusy,
                inputBorder: const Color(0xFFE0E0E0),
                textGrey: const Color(0xFF8B9297),
              ),
              const SizedBox(height: 32),
              MfaPrimaryButton(
                label: 'Enviar código SMS',
                onPressed: isBusy ? null : _sendSmsCode,
                isLoading: _isSendingCode,
              ),
              if (_verificationId != null) ...[
                const SizedBox(height: 16),
                MfaInputField(
                  icon: Icons.message_outlined,
                  hintText: 'Código SMS',
                  controller: _smsCodeController,
                  isPassword: false,
                  enabled: !isBusy,
                  inputBorder: const Color(0xFFE0E0E0),
                  textGrey: const Color(0xFF8B9297),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                MfaPrimaryButton(
                  label: 'Confirmar código e ativar',
                  onPressed: isBusy ? null : _confirmSmsCode,
                  isLoading: _isEnrolling,
                ),
              ],
              if (_message != null) ...[
                const SizedBox(height: 16),
                MfaMessageText(message: _message!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
