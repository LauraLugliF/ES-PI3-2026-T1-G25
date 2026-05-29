//Max Thomazini Barbosa RA: 25003934
//Max Thomazini Barbosa RA:25003934
import 'package:flutter/material.dart';

import '../models/profile_data_model.dart';

class ProfilePageHeader extends StatelessWidget {
  const ProfilePageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meu',
          style: TextStyle(fontSize: 16, color: Color(0xFF8B9297)),
        ),
        Text(
          'Perfil',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1C),
          ),
        ),
      ],
    );
  }
}

class ProfileMainCard extends StatelessWidget {
  const ProfileMainCard({
    super.key,
    required this.profileData,
  });

  final ProfileData profileData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFEBF5F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF22996E),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profileData.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _buildInvestorSinceText(profileData.createdAt),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8B9297),
            ),
          ),
        ],
      ),
    );
  }

  String _buildInvestorSinceText(DateTime? createdAt) {
    if (createdAt == null) {
      return 'Investidor desde data não informada';
    }

    const months = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    final monthName = months[createdAt.month - 1];
    return 'Investidor desde ${createdAt.day} de $monthName de ${createdAt.year}';
  }
}

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF8B9297),
      ),
    );
  }
}

class ProfileAccountDataCard extends StatelessWidget {
  const ProfileAccountDataCard({
    super.key,
    required this.profileData,
  });

  final ProfileData profileData;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _ProfileInfoRow(icon: Icons.mail_outline, title: 'E-mail', value: profileData.email),
          const _ProfileDivider(),
          _ProfileInfoRow(icon: Icons.phone_outlined, title: 'Telefone', value: profileData.phone),
          const _ProfileDivider(),
          _ProfileInfoRow(icon: Icons.calendar_today_outlined, title: 'CPF', value: profileData.cpf),
        ],
      ),
    );
  }
}

class ProfileSecurityCard extends StatelessWidget {
  const ProfileSecurityCard({
    super.key,
    required this.isMfaStatusLoading,
    required this.isMfaEnabled,
    required this.isMfaLoading,
    required this.message,
    required this.onActivate,
  });

  final bool isMfaStatusLoading;
  final bool isMfaEnabled;
  final bool isMfaLoading;
  final String? message;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _ProfileIconContainer(icon: Icons.lock_outline),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Autenticacao 2FA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1C),
                      ),
                    ),
                  ],
                ),
              ),
              _buildAction(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isMfaStatusLoading
                ? 'Verificando...'
                : (isMfaEnabled ? 'Ativado' : 'Nao ativado'),
            style: const TextStyle(fontSize: 13, color: Color(0xFF8B9297)),
          ),
          if (message != null) ...[
            const SizedBox(height: 10),
            Text(
              message!,
              style: TextStyle(
                color: message!.toLowerCase().contains('sucesso') ? Colors.green : Colors.red,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAction() {
    if (isMfaStatusLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (!isMfaEnabled) {
      return ElevatedButton(
        onPressed: isMfaLoading ? null : onActivate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22996E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
        ),
        child: isMfaLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'Ativar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Ativado',
        style: TextStyle(
          color: Color(0xFF22996E),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ProfileLogoutCard extends StatelessWidget {
  const ProfileLogoutCard({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.exit_to_app,
                  color: Color(0xFFD94444),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Sair da conta',
                  style: TextStyle(
                    fontSize: 16,
                    color: isLoading ? const Color(0xFFD94444).withValues(alpha: 0.6) : const Color(0xFFD94444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _ProfileIconContainer(icon: icon),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Color(0xFF8B9297)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1C1C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileIconContainer extends StatelessWidget {
  const _ProfileIconContainer({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: const Color(0xFF22996E),
        size: 24,
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[100],
      indent: 68,
      endIndent: 16,
    );
  }
}
