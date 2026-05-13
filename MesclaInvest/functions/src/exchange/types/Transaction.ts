// Max Thomazini Barbosa RA:25003934
// Representa uma transação de compra/venda que já foi realizada

export type Transaction = {
  id?: string;
  tipo: "compra" | "venda";
  userId: string;
  startupId: string;
  quantidade: number;
  precoUnitario: number;
  precoTotal: number;
  dataTrasacao: Date | unknown;
};
