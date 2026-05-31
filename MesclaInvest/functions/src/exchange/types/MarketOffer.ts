// LUCAS RODRIGUES XAVIER - 25000508
// Representa uma oferta de venda de tokens no mercado secundário P2P

export type MarketOfferStatus = "open" | "filled" | "cancelled";
export type MarketOfferType = "buy" | "sell";

export type MarketOffer = {
  id?: string; // ID do documento no Firestore
  sellerId: string; // UID do usuário criador (vendedor ou comprador)
  sellerEmail: string; // E-mail do criador (exibido no balcão)
  startupId: string; // ID da startup cujos tokens estão em negociação
  quantidade: number; // Quantidade de tokens ofertados
  precoPorTokenCents: number; // Preço unitário em centavos
  status: MarketOfferStatus;
  type?: MarketOfferType; // Tipo da oferta: "buy" (compra) ou "sell" (venda)
  criadaEm: Date | unknown;
  atualizadaEm: Date | unknown;
};
