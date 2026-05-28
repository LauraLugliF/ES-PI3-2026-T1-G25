//Max Thomazini Barbosa RA:25003934
part of 'login_mfa_challenge.dart';

class _LoginMfaChallengePageState extends State<LoginMfaChallengePage> {
  final _smsCodeController = TextEditingController();
  final LoginMfaService _service = LoginMfaService();

  late final List<PhoneMultiFactorInfo> _phoneHints;

  int _selectedHintIndex = 0;
  bool _isSendingCode = false;
  bool _isConfirming = false;
  String? _verificationId;
  String? _message;

  PhoneMultiFactorInfo? get _selectedHint {
    if (_phoneHints.isEmpty) {
      return null;
    }
    return _phoneHints[_selectedHintIndex];
  }

  String? get _selectedPhoneNumber {
    final hint = _selectedHint;
    final phoneNumber = hint?.phoneNumber.trim();
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null;
    }
    return phoneNumber;
  }

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

  @override
  void dispose() {
    _smsCodeController.dispose();
    super.dispose();
  }

  Future<void> _sendSmsCode() async {
    final hint = _selectedHint;
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

  @override
  Widget build(BuildContext context) {
    final isBusy = _isSendingCode || _isConfirming;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoginMfaHeader(email: widget.email),
              const SizedBox(height: 24),
              const LoginMfaIntroCard(),
              if (_selectedPhoneNumber != null) ...[
                const SizedBox(height: 16),
                LoginMfaDestinationCard(phoneNumber: _selectedPhoneNumber!),
              ],
              const SizedBox(height: 20),
              LoginMfaHintList(
                hints: _phoneHints,
                selectedIndex: _selectedHintIndex,
                onHintSelected: (index) {
                  setState(() {
                    _selectedHintIndex = index;
                  });
                  _sendSmsCode();
                },
              ),
              if (_verificationId != null) ...[
                const SizedBox(height: 24),
                LoginMfaInputField(
                  icon: Icons.message_outlined,
                  hintText: 'Código SMS',
                  controller: _smsCodeController,
                  enabled: !isBusy,
                  inputBorder: const Color(0xFFE0E0E0),
                  textGrey: const Color(0xFF8B9297),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                LoginMfaPrimaryButton(
                  label: 'Confirmar código e entrar',
                  onPressed: isBusy ? null : _confirmSmsCode,
                  isLoading: _isConfirming,
                ),
              ],
              if (_isSendingCode && _verificationId == null) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_message != null) ...[
                const SizedBox(height: 16),
                LoginMfaMessage(message: _message!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
