//Max Thomazini Barbosa RA:25003934
// Concentra a orquestracao do fluxo de ativacao do MFA por SMS.
part of 'mfa_enroll_page.dart';

class _MfaEnrollPageState extends State<MfaEnrollPage> {
  // Controla os valores digitados pelo usuario para telefone, senha e codigo.
  final _phoneController = TextEditingController();
  // Armazena a senha atual usada na reautenticacao.
  final _passwordController = TextEditingController();
  // Recebe o codigo SMS informado para concluir a ativacao.
  final _smsCodeController = TextEditingController();
  // Encapsula as regras de negocio do cadastro de MFA.
  final MfaEnrollService _service = MfaEnrollService();

  // Evita disparar mais de um envio de SMS ao mesmo tempo.
  bool _isSendingCode = false;
  // Evita confirmar o codigo enquanto outro passo ainda esta ativo.
  bool _isEnrolling = false;
  // Id de verificacao retornado pelo Firebase para validar o SMS.
  String? _verificationId;
  // Mensagem exibida na interface para sucesso ou erro.
  String? _message;

  // Libera os controladores quando a tela sai da arvore.
  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  // Reautentica o usuario e solicita o envio do SMS de ativacao.
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
        onEnrollmentComplete: () {
          if (!mounted) return;
          setState(() {
            _message = 'Autenticacao por SMS ativada com sucesso.';
          });
          Navigator.of(context).pop(true);
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

  // Finaliza a ativacao do MFA usando o codigo recebido por SMS.
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

  // Monta a tela com o formulario, os passos e os estados de carregamento.
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
