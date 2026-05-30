// LUCAS RODRIGUES XAVIER - 25000508
// Representa uma oferta de venda de tokens no mercado secundário P2P

export type MarketOfferStatus = "open" | "filled" | "cancelled";

export type MarketOffer = {
  id?: string; // ID do documento no Firestore
  sellerId: string; // UID do usuário vendedor
  sellerEmail: string; // E-mail do vendedor (exibido no balcão)
  startupId: string; // ID da startup cujos tokens estão à venda
  quantidade: number; // Quantidade de tokens ofertados
  precoPorTokenCents: number; // Preço unitário em centavos
  status: MarketOfferStatus;
  criadaEm: Date | unknown;
  atualizadaEm: Date | unknown;
};
