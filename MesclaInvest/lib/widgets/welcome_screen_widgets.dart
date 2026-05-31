//Max Thomazini Barbosa RA:25003934
// Reune a composicao visual da tela inicial de boas-vindas.
import 'package:flutter/material.dart';

import 'app_logo.dart';

// Monta a tela inicial com logo, textos e acoes de cadastro e login.
class WelcomeScreenContent extends StatelessWidget {
  // Nao recebe estado externo porque esta tela e totalmente declarativa.
  const WelcomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _WelcomeLogo(),
              SizedBox(height: 30),
              _WelcomeTitle(),
              SizedBox(height: 10),
              _WelcomeSubtitle(),
              SizedBox(height: 40),
              _WelcomeCreateAccountButton(),
              SizedBox(height: 15),
              _WelcomeLoginButton(),
              SizedBox(height: 30),
              _WelcomeFooterText(),
            ],
          ),
        ),
      ),
    );
  }
}

// Exibe o logo do aplicativo no topo da tela.
class _WelcomeLogo extends StatelessWidget {
  // Separado para deixar a composicao principal mais legivel.
  const _WelcomeLogo();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: AppLogo(),
    );
  }
}

// Mostra o titulo principal da tela.
class _WelcomeTitle extends StatelessWidget {
  const _WelcomeTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Seja bem vindo(a)!',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// Mostra o texto de apoio com a proposta do app.
class _WelcomeSubtitle extends StatelessWidget {
  const _WelcomeSubtitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Sua jornada de investimentos começa aqui.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey,
      ),
    );
  }
}

// Botao primario que leva ao cadastro.
class _WelcomeCreateAccountButton extends StatelessWidget {
  const _WelcomeCreateAccountButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2DBE9D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Criar Conta',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

// Botao secundario que leva ao fluxo de login.
class _WelcomeLoginButton extends StatelessWidget {
  const _WelcomeLoginButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF2DBE9D)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Entrar',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF2DBE9D),
          ),
        ),
      ),
    );
  }
}

// Exibe a observacao final para usuarios que ja possuem conta.
class _WelcomeFooterText extends StatelessWidget {
  const _WelcomeFooterText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Já tem conta? Use o botão “Entrar”.',
      style: TextStyle(
        color: Colors.grey,
      ),
    );
  }
}