// LUCAS RODRIGUES XAVIER - 25000508
part of '../screens/explore_startups_screen/explore_startups_screen.dart';

// Este é o cartão visual (card) de cada startup que aparece na nossa lista de exploração.
// Ele mostra de forma resumida as principais informações da startup.
class StartupListItem extends StatelessWidget {
  // A startup contendo todos os dados a serem exibidos no card
  final StartupData startup;
  // Ação disparada quando o usuário toca no card
  final VoidCallback onTap;

  // Construtor padrão do item de lista do Explore Startups
  const StartupListItem({super.key, required this.startup, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Acessa o tema global do aplicativo para obter cores e estilos consistentes
    final theme = Theme.of(context);
    
    // Retorna um InkWell para dar efeito visual de clique (ripple effect)
    return InkWell(
      onTap: onTap, // Executa a função de navegação repassada ao widget
      borderRadius: BorderRadius.circular(16), // Bordas arredondadas no clique
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), // Margem externa inferior entre os itens
        padding: const EdgeInsets.all(12), // Espaçamento interno do card
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest, // Cor de fundo do card adaptada ao tema
          borderRadius: BorderRadius.circular(16), // Bordas arredondadas do card
        ),
        child: Column(
          children: [
            // Primeira linha: A logomarca abreviada e o estágio da startup (ex: "Nova")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logomarca: um quadradinho colorido contendo a inicial ou abreviação do nome
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      startup.logoLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                // Badge/Crachá do estágio da startup (ex: "Em expansão", "Nova")
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    startup.stage,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Informações principais: Nome, Setor de atuação, e quantidade total de tokens
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome comercial da startup
                Text(
                  startup.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Exemplo: "Tecnologia - Tokens: 1.5M"
                Text(
                  "${startup.sector} - Tokens: ${startup.tokens}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                // Laura Lugli Fonseca Pereira RA: 25000739
                // Exibe a descrição curta da startup se estiver disponível
                if (startup.shortDescription.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    startup.shortDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                // Preço e seta indicativa de clique
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Preço formatado (ex: R$ 10,00)
                    Text(
                      startup.price,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}