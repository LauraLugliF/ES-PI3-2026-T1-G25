// LUCAS RODRIGUES XAVIER - 25000508
// Laura Lugli Fonseca Pereira RA: 25000739

// Importa os widgets visuais do Flutter
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importado para permitir abrir links externos de vídeos e PDFs

// Importa os widgets reutilizáveis da tela de detalhes
import '../../widgets/startups_detalhadas_widgets.dart';
import '../../widgets/app_bottom_navigation.dart';

// Importa o repository que chama as Cloud Functions.
import '../../repositories/startup_repository.dart';

// Liga este arquivo ao state separado
part 'startups_detalhadas_screen_state.dart';

// Define a tela de detalhes da startup como um widget com estado
class StartupDetailScreen extends StatefulWidget {
  // ID da startup que será exibida na tela
  final String startupId;

  // Cria a tela de detalhes recebendo o ID da startup
  const StartupDetailScreen({super.key, required this.startupId});

  // Informa qual classe controla o estado da tela
  @override
  State<StartupDetailScreen> createState() => _StartupDetailScreenState();
}