//Max Thomazini Barbosa RA:25003934
part of 'profile_screen.dart';

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isMfaLoading = false;
  bool _isMfaEnabled = false;
  bool _isMfaStatusLoading = true;
  bool _isSigningOut = false;
  String? _mfaMessage;
  bool _wasCurrentRoute = false;
  late final Future<ProfileData> _profileFuture;
  final ProfileService _profileService = ProfileService();
  final ProfileMfaService _mfaService = ProfileMfaService();
  final LogoutService _logoutService = LogoutService();

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileData();
    _loadMfaStatus();
  }

  Future<ProfileData> _loadProfileData() {
    return _profileService.loadProfileData();
  }

  void _onNavTap(int index) {
    // Evita navegar durante o fluxo de MFA para não desmontar a tela no meio
    // de callbacks/dialgos assincronos.
    if (_isMfaLoading) return;
    // Delegar navegacao ao helper ja existente.
    // TODO: ajustar comportamento se necessario ao restaurar logica.
    handleBottomNavTap(context, currentIndex: 3, tappedIndex: index);
  }

  Future<void> _start2FAFlow() async {
    if (_isMfaLoading || _isMfaEnabled) return;

    setState(() {
      _isMfaLoading = true;
      _mfaMessage = null;
    });

    final enrolled = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const MfaEnrollPage()),
    );

    if (!mounted) return;

    setState(() {
      _isMfaLoading = false;
      if (enrolled == true) {
        _mfaMessage = 'Autenticacao por SMS ativada com sucesso.';
      }
    });

    // Sempre recarrega o status real no backend ao voltar da tela de MFA.
    await _loadMfaStatus();
  }

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    try {
      await _logoutService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mfaMessage = 'Nao foi possivel sair da conta.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  Future<void> _loadMfaStatus() async {
    if (mounted) {
      setState(() {
        _isMfaStatusLoading = true;
        // Evita mostrar estado "Ativado" antigo enquanto consulta o backend.
        _isMfaEnabled = false;
      });
    }

    var isPhoneMfaEnabled = false;
    try {
      final status = await _mfaService.loadStatus();
      isPhoneMfaEnabled = status.isPhoneMfaEnabled;
      debugPrint(
        'MFA status check: factors=${status.factorIds} '
        'phoneFactors=${status.phoneFactorsCount} '
        'providers=${status.providerIds}',
      );
    } catch (_) {
      isPhoneMfaEnabled = false;
    }

    if (!mounted) return;
    setState(() {
      _isMfaEnabled = isPhoneMfaEnabled;
      _isMfaStatusLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _refreshMfaOnRouteEnter(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F5),
      body: SafeArea(
        child: FutureBuilder<ProfileData>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Não foi possível carregar os dados do perfil.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            final profileData = snapshot.data ?? const ProfileData(
              name: 'Usuário',
              email: 'E-mail não cadastrado',
              phone: 'Telefone não cadastrado',
              cpf: 'CPF não cadastrado',
              createdAt: null,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfilePageHeader(),
                  const SizedBox(height: 24),
                  ProfileMainCard(profileData: profileData),
                  const SizedBox(height: 24),
                  const ProfileSectionTitle(title: 'DADOS DA CONTA'),
                  const SizedBox(height: 12),
                  ProfileAccountDataCard(profileData: profileData),
                  const SizedBox(height: 24),
                  const ProfileSectionTitle(title: 'SEGURANCA'),
                  const SizedBox(height: 12),
                  ProfileSecurityCard(
                    isMfaStatusLoading: _isMfaStatusLoading,
                    isMfaEnabled: _isMfaEnabled,
                    isMfaLoading: _isMfaLoading,
                    message: _mfaMessage,
                    onActivate: _start2FAFlow,
                  ),
                  const SizedBox(height: 16),
                  ProfileLogoutCard(
                    onTap: _signOut,
                    isLoading: _isSigningOut,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: _onNavTap,
      ),
    );
  }

  void _refreshMfaOnRouteEnter(BuildContext context) {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;

    if (isCurrentRoute && !_wasCurrentRoute) {
      _loadMfaStatus();
    }

    _wasCurrentRoute = isCurrentRoute;
  }
}
