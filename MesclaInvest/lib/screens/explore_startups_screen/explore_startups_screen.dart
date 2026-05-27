// LUCAS RODRIGUES XAVIER - 25000508
// Esta é a tela principal de exploração de startups.
// Ela funciona como um "mural" onde os investidores podem ver todas as startups disponíveis
// e filtrá-las de acordo com a fase em que se encontram (novas, em operação, ou em expansão).

import 'package:flutter/material.dart';

import '../../widgets/app_bottom_navigation.dart';
import '../../services/explore_startups_service.dart';

part 'explore_startups_screen_state.dart';
part '../../widgets/explore_startups_widgets.dart';

class ExploreStartupsScreen extends StatefulWidget {
  // Lista com os filtros de categorias disponíveis para o usuário clicar
  final List<String> filters;
  // Qual filtro está ativo logo ao abrir a tela (o padrão é mostrar "Todas")
  final String selectedFilter;

  const ExploreStartupsScreen({
    super.key,
    this.filters = const ["Todas", "Nova", "Em operação", "Em expansão"],
    this.selectedFilter = "Todas",
  });

  @override
  State<ExploreStartupsScreen> createState() => _ExploreStartupsScreenState();
}
