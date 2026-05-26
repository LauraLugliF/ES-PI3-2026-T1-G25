import 'package:flutter/material.dart';

import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/profile_widgets.dart';
import '../../services/profile_service.dart';

// Nota: esta versão do arquivo mantém apenas a parte visual.
// TODO: reimplementar a lógica removida (Firebase auth, chamada de funções,
// verificação de telefone, linking de credenciais, tratamento de erros).

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const ProfileData _profileData = ProfileData(
    name: 'Nome do usuário',
    email: 'email@exemplo.com',
    phone: '(00) 00000-0000',
  );
  // TODO: quando reimplementar, remover 'const' e popular com dados reais.
  
  void _onNavTap(int index) {
    // Delegar navegação ao helper já existente.
    // TODO: ajustar comportamento se necessário ao restaurar lógica.
    handleBottomNavTap(context, currentIndex: 3, tappedIndex: index);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ProfileHeaderCard(profileData: _profileData),
            const SizedBox(height: 20),
            
            const Divider(height: 40),

            // --- SEÇÃO DE 2FA ---
            const Text('Segurança', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Segurança: seção visual. Implementar lógica de 2FA abaixo.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nenhum número cadastrado na conta.'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // Botão desabilitado (interface apenas).
                    // TODO: implementar `_start2FAFlow()` e alterar `onPressed` para
                    // `() => _start2FAFlow()` quando reativar a lógica.
                    onPressed: null,
                    icon: const Icon(Icons.security),
                    label: const Text('Ativar Autenticação por SMS'),
                  ),
                ),
              ],
            ),

            const Divider(height: 40),

            // --- BOTÃO DE LOGOUT ---
            SizedBox(
              width: double.infinity,
                child: OutlinedButton.icon(
                // Botão de logout desabilitado (interface apenas).
                // TODO: implementar `_logout()` e alterar `onPressed` para
                // `() => _logout()` quando reativar a lógica de autenticação.
                onPressed: null,
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: _onNavTap,
      ),
    );
  }
}
