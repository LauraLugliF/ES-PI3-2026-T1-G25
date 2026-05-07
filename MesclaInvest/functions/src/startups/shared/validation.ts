//Max Thomazini Barbosa RA:25003934
export function normalizeString(value: unknown): string | undefined {
  // Rejeita qualquer valor que não seja texto.
  if (typeof value !== "string") {
    return undefined;
  }

  // Remove espaços extras nas extremidades.
  const trimmed = value.trim();

  // Retorna apenas strings com conteúdo real; caso contrário, trata como vazio.
  return trimmed.length > 0 ? trimmed : undefined;
}