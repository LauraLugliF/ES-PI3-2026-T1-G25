// Max Thomazini Barbosa RA:25003934
// Representa os tokens que um usuário possui de uma startup

export type Portfolio = {
  id?: string; // ID do documento no Firestore
  userId: string; // UID do usuário proprietário
  startupId: string; // ID da startup
  quantidade: number; // Quantidade de tokens que o usuário possui
  precoMedioCompra: number; // Preço médio pago por token (em centavos)
  dataCompra: Date | unknown; // Data da primeira compra
  atualizadoEm?: Date | unknown; // Última atualização
};
