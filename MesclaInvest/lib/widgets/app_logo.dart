import 'package:flutter/material.dart';

// Renderiza o logotipo do aplicativo e oferece um fallback visual caso o asset falhe.
class AppLogo extends StatelessWidget {
  // Altura base usada no logo para ajustar a imagem e o fallback.
  final double height;
  // Como a imagem deve se comportar dentro do espaco disponivel.
  final BoxFit fit;
  // Caminho do asset exibido na maior parte dos cenarios.
  final String assetPath;

  // Permite customizar dimensoes e asset sem duplicar a logica de renderizacao.
  const AppLogo({
    super.key,
    this.height = 120,
    this.fit = BoxFit.contain,
    this.assetPath = 'lib/screens/assets/Logo1.png',
  });

  @override
  Widget build(BuildContext context) {
    // Ajusta a altura em cache para melhorar nitidez em telas com DPR alto.
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheHeight = (height * dpr).round();
    return Image.asset(
      assetPath,
      height: height,
      fit: fit,
      cacheHeight: cacheHeight,
      // Se o asset nao estiver disponivel, mostra um fallback neutro com o tema do app.
      errorBuilder: (c, e, st) => Container(
        width: height * 0.87,
        height: height * 0.87,
        decoration: BoxDecoration(
          color: const Color(0xFF2DBE9D).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.trending_up, size: 56, color: Color(0xFF2DBE9D)),
      ),
    );
  }
}
