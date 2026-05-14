// Max Thomazini Barbosa RA:25003934
// Tipos relacionados ao módulo `exchange`.
export type User = {
  uid: string;
  nome?: string | null;
  cpf?: string | null;
  email?: string | null;
  telefone?: string | null;
  // saldo em centavos (inteiro)
  saldo?: number | null;
  createdAt?: unknown;
};

export type BalanceResult = number | null; // saldo em centavos ou null se não existir
