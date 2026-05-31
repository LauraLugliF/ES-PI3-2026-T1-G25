import 'package:flutter/material.dart';

import '../../repositories/exchange_repository.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/app_bottom_navigation.dart';

part 'dashboard_screen_state.dart';
part '../../widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
