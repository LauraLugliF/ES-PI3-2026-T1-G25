// LUCAS RODRIGUES XAVIER - 25000508
import 'package:flutter/material.dart';

import '../../widgets/app_bottom_navigation.dart';
import '../../services/explore_startups_service.dart';

part 'explore_startups_screen_state.dart';
part '../../widgets/explore_startups_widgets.dart';

class ExploreStartupsScreen extends StatefulWidget {
  final List<String> filters;
  final String selectedFilter;

  const ExploreStartupsScreen({
    super.key,
    this.filters = const ["Todas", "Nova", "Em operação", "Em expansão"],
    this.selectedFilter = "Todas",
  });

  @override
  State<ExploreStartupsScreen> createState() => _ExploreStartupsScreenState();
}
