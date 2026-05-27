//Max Thomazini Barbosa RA:25003934

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../repositories/exchange_repository.dart';
import '../../repositories/startup_repository.dart';
import '../../widgets/app_bottom_navigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'dashboard_screen_state.dart';
part '../../widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
