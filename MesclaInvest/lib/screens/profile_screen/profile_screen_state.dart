//Max Thomazini Barbosa RA:25003934
// Concentra a orquestracao da tela de perfil e das acoes de seguranca.
part of 'profile_screen.dart';

class _ProfileScreenState extends State<ProfileScreen> {
  // Controla o carregamento do fluxo de ativacao de MFA.
  bool _isMfaLoading = false;
  // Reflete se o usuario ja possui MFA por SMS ativado.
  bool _isMfaEnabled = false;
  // Controla a consulta do status de MFA ao backend.
  bool _isMfaStatusLoading = true;
  // Bloqueia a UI enquanto o logout esta em andamento.
  bool _isSigningOut = false;
  // Mensagem exibida no card de seguranca quando necessario.
  String? _mfaMessage;
  // Evita recarregamentos redundantes ao voltar para a rota.
  bool _wasCurrentRoute = false;
  // Carrega os dados do perfil uma unica vez por instancia da tela.
  late final Future<ProfileData> _profileFuture;
  // Consulta os dados consolidados do perfil.
  final ProfileService _profileService = ProfileService();
  // Consulta o estado atual do MFA.
  final ProfileMfaService _mfaService = ProfileMfaService();
  // Realiza a saida da conta do usuario.
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

  // Bloqueia a navegacao quando o fluxo de MFA esta em andamento.
  void _onNavTap(int index) {
    // Evita navegar durante o fluxo de MFA para não desmontar a tela no meio
    // de callbacks/dialgos assincronos.
    if (_isMfaLoading) return;
    // Delegar navegacao ao helper ja existente.
    // TODO: ajustar comportamento se necessario ao restaurar logica.
    handleBottomNavTap(context, currentIndex: 3, tappedIndex: index);
  }

  // Abre a tela de ativacao de MFA e atualiza o estado apos o retorno.
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

  // Realiza o logout e limpa a pilha de navegacao ao concluir com sucesso.
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

  // Consulta o backend para refletir o estado atual do MFA na interface.
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

  // Libera o ciclo do state quando a tela for descartada.
  @override
  void dispose() {
    super.dispose();
  }

  // Monta a tela e atualiza o status de MFA ao entrar na rota.
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

  // Recarrega o status de MFA quando a rota volta a ser visivel.
  void _refreshMfaOnRouteEnter(BuildContext context) {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;

    if (isCurrentRoute && !_wasCurrentRoute) {
      _loadMfaStatus();
    }

    _wasCurrentRoute = isCurrentRoute;
  }
}
