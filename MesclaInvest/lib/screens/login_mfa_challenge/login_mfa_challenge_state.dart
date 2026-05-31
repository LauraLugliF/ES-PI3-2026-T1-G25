//Max Thomazini Barbosa RA:25003934
// Concentra a orquestracao do fluxo de envio e confirmacao do SMS.
part of 'login_mfa_challenge.dart';

class _LoginMfaChallengePageState extends State<LoginMfaChallengePage> {
  // Controla a entrada do codigo SMS digitado pelo usuario.
  final _smsCodeController = TextEditingController();
  // Abstrai a comunicacao com o Firebase para o fluxo MFA.
  final LoginMfaService _service = LoginMfaService();

  // Guarda os fatores por telefone retornados pelo Firebase.
  late final List<PhoneMultiFactorInfo> _phoneHints;

  // Indica qual fator de SMS esta selecionado quando ha mais de um.
  int _selectedHintIndex = 0;
  // Evita envios duplicados do codigo enquanto a requisicao esta em andamento.
  bool _isSendingCode = false;
  // Evita confirmar o codigo enquanto outra operacao esta em andamento.
  bool _isConfirming = false;
  // Armazena o id necessario para validar o SMS informado.
  String? _verificationId;
  // Mensagem de retorno exibida na interface.
  String? _message;

  // Expõe um modelo derivado com os dados necessarios para renderizacao.
  LoginMfaChallengeModel get _model {
    return LoginMfaChallengeModel(
      phoneHints: _phoneHints,
      selectedHintIndex: _selectedHintIndex,
    );
  }

  // Carrega os fatores de MFA e dispara o envio automatico do SMS inicial.
  @override
  void initState() {
    super.initState();
    _phoneHints = widget.resolver.hints.whereType<PhoneMultiFactorInfo>().toList();

    if (_phoneHints.isEmpty) {
      _message = 'Nenhum fator por SMS encontrado para esta conta.';
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _sendSmsCode();
    });
  }

  // Libera o controlador do campo de SMS quando a tela sai da arvore.
  @override
  void dispose() {
    _smsCodeController.dispose();
    super.dispose();
  }

  // Solicita o envio de um novo SMS para o fator selecionado.
  Future<void> _sendSmsCode() async {
    final hint = _model.selectedHint;
    if (hint == null || _isSendingCode || _isConfirming) {
      return;
    }

    setState(() {
      _isSendingCode = true;
      _message = null;
      _verificationId = null;
    });

    try {
      final phoneNumber = hint.phoneNumber.trim();
      await _service.sendSmsCode(
        resolver: widget.resolver,
        hint: hint,
        onCodeSent: (verificationId) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _message = phoneNumber.isNotEmpty
                ? 'SMS enviado para $phoneNumber. Digite abaixo para concluir.'
                : 'SMS enviado para o número cadastrado. Digite abaixo para concluir.';
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
            await _service.resolveSignInWithCredential(
              resolver: widget.resolver,
              phoneCredential: phoneCredential,
            );
            if (!mounted) return;
            Navigator.of(context).pop(true);
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;
            setState(() {
              _message = e.message ?? 'Falha ao validar MFA automaticamente.';
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
        _message = e.message ?? 'Nao foi possivel enviar o codigo SMS.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Erro inesperado ao enviar o codigo SMS.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  // Confirma o codigo informado e conclui o desafio MFA.
  Future<void> _confirmSmsCode() async {
    if (_isConfirming || _isSendingCode) {
      return;
    }

    final verificationId = _verificationId;
    final smsCode = _smsCodeController.text.trim();

    if (verificationId == null || verificationId.isEmpty) {
      setState(() {
        _message = 'Envie o código SMS primeiro.';
      });
      return;
    }

    if (smsCode.isEmpty) {
      setState(() {
        _message = 'Informe o código SMS recebido.';
      });
      return;
    }

    setState(() {
      _isConfirming = true;
      _message = null;
    });

    try {
      await _service.resolveSignInWithCredential(
        resolver: widget.resolver,
        phoneCredential: PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _message = e.message ?? 'Nao foi possivel confirmar o código SMS.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'Erro inesperado ao confirmar o código.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  // Atualiza o fator selecionado e reinicia o fluxo de envio do SMS.
  void _handleHintSelected(int index) {
    setState(() {
      _selectedHintIndex = index;
    });
    _sendSmsCode();
  }

  // Monta a tela usando o widget de conteudo extraido para a interface.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: LoginMfaChallengeContent(
            email: widget.email,
            model: _model,
            isSendingCode: _isSendingCode,
            isConfirming: _isConfirming,
            verificationId: _verificationId,
            message: _message,
            smsCodeController: _smsCodeController,
            onHintSelected: _handleHintSelected,
            onConfirmPressed: _confirmSmsCode,
          ),
        ),
      ),
    );
  }
}
