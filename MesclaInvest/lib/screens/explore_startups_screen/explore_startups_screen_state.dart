// LUCAS RODRIGUES XAVIER - 25000508
part of 'explore_startups_screen.dart';

// Aqui é onde controlamos o estado e o comportamento da tela de explorar startups.
// Cuidamos da pesquisa, dos botões de filtro e de buscar a lista de dados da internet.
class _ExploreStartupsScreenState extends State<ExploreStartupsScreen> {
  // O "mensageiro" (serviço) que sabe como ir buscar as startups no banco de dados
  final ExploreStartupsService _service = ExploreStartupsService();
  
  // Uma promessa (Future) que diz: "vou trazer uma lista de startups assim que a internet carregar"
  late Future<List<StartupData>> _startupsFuture;
  
  // Controlador do campo de texto da barra de busca (lupa)
  late TextEditingController _searchController;
  
  // Guarda o texto exato que o usuário digitou para pesquisar
  String _searchQuery = '';
  
  // Guarda qual filtro horizontal está ativo (começa mostrando "Todas")
  String _selectedFilter = 'Todas';

  // Executado quando a tela abre pela primeira vez no celular do usuário
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedFilter = widget.selectedFilter;
    _loadStartups(); // Dispara o carregamento das startups
  }

  // Executado quando o usuário sai desta tela (joga fora as coisas para não gastar memória)
  @override
  void dispose() {
    _searchController.dispose(); // Limpa o controlador de texto da pesquisa
    super.dispose();
  }

  // Função responsável por chamar o serviço e guardar a promessa de dados na nossa variável
  void _loadStartups() {
    setState(() {
      _startupsFuture = _service
          .obterStartups(
            selectedFilter: _selectedFilter,
            searchQuery: _searchQuery,
          )
          .catchError((e) {
            // Se algo der errado (ex: internet cair), mostra um aviso em vermelho na tela
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao carregar startups: $e')),
              );
            }
            return <StartupData>[]; // Retorna uma lista vazia para o app não travar
          });
    });
  }

  // Constrói o visual da página
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<List<StartupData>>(
          future: _startupsFuture, // Passamos a nossa promessa de carregar dados aqui
          builder: (context, snapshot) {
            // Enquanto a internet está buscando as startups, mostramos uma rodinha girando
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              );
            }

            final startups = snapshot.data ?? [];

            // GestureDetector serve para fechar o teclado se o usuário clicar em qualquer lugar vazio
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: CustomScrollView(
                slivers: [
                  _buildHeader(context),  // Cabeçalho e barra de pesquisa
                  _buildFilters(context), // Fileira de botões de filtros ("Nova", "Em operação"...)
                  if (startups.isNotEmpty)
                    _buildAllStartupsSection(context, startups), // Lista de startups se encontrar alguma
                  if (startups.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Nenhuma startup encontrada.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      // Adiciona o menu inferior padrão do aplicativo
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1, // Indica que a aba ativa é a número 1 (Explorar)
        onTap: (index) =>
            handleBottomNavTap(context, currentIndex: 1, tappedIndex: index),
      ),
    );
  }

  // Desenha a parte de cima com o título e a caixinha de pesquisa com a lupa
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text('Explorar startups', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (value) {
                        _searchQuery = value; // Salva o termo pesquisado
                        _loadStartups(); // Recarrega a lista
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar startups...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        icon: Icon(
                          Icons.search,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Botãozinho de configurações de filtro ao lado da busca
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.tune, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Desenha os botões de filtro na horizontal (Todas, Nova, Em operação...)
  Widget _buildFilters(BuildContext context) {
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: widget.filters.length,
          separatorBuilder: (ctx, i) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final filter = widget.filters[i];
            final isSelected = filter == _selectedFilter;
            return Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter; // Atualiza o filtro selecionado
                    _loadStartups(); // Busca novamente as startups do banco
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    filter,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Desenha a lista de startups no padrão infinito (SliverList)
  Widget _buildAllStartupsSection(
    BuildContext context,
    List<StartupData> listStartups,
  ) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          // O item no topo (index 0) é um título escrito "Startups" e a contagem de resultados
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Startups',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${listStartups.length} encontradas',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          // Os itens seguintes são os cards de cada startup da nossa lista
          final startupIndex = index - 1;
          if (startupIndex < listStartups.length) {
            final startup = listStartups[startupIndex];
            return StartupListItem(
              startup: startup,
              onTap: () => Navigator.pushNamed(
                context,
                '/startup-detail',
                arguments: startup.id, // Envia o ID da startup para a tela de detalhes
              ),
            );
          }
          return const SizedBox.shrink();
        }, childCount: listStartups.length + 1),
      ),
    );
  }
}
