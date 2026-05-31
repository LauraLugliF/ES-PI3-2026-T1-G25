// LUCAS RODRIGUES XAVIER - 25000508
// Handler para cancelar uma oferta própria no mercado P2P
// Devolve os tokens ao portfólio do vendedor e marca a oferta como cancelada.

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {FieldValue} from "firebase-admin/firestore";
import {db} from "../../startups/shared/firebase";
import {adicionarTokensAoPortfolio} from "../repositories/portfolioRepository";
import {MarketOffer} from "../types/MarketOffer";
import {adicionarDeposito} from "../repositories/userRepository";

export const cancelMarketOfferHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      const userId = (request.body?.userId as string) || "";
      const offerId = (request.body?.offerId as string) || "";

      // Valida campos obrigatórios
      if (!userId || !offerId) {
        response.status(400).send("userId e offerId são obrigatórios.");
        return;
      }

      // Carrega a oferta
      const ofertaRef = db.collection("marketOffers").doc(offerId);
      const ofertaSnap = await ofertaRef.get();

      if (!ofertaSnap.exists) {
        response.status(404).send("Oferta não encontrada.");
        return;
      }

      const oferta = ofertaSnap.data() as MarketOffer;

      // Verifica se a oferta pertence ao usuário solicitante
      if (oferta.sellerId !== userId) {
        response.status(403).send("Você não tem permissão para cancelar esta oferta.");
        return;
      }

      // Verifica se a oferta ainda está aberta
      if (oferta.status !== "open") {
        response.status(400).send("Esta oferta não pode ser cancelada pois já foi encerrada.");
        return;
      }

      // Marca a oferta como cancelada
      await ofertaRef.update({
        status: "cancelled",
        atualizadaEm: FieldValue.serverTimestamp(),
      });

      // Devolve o recurso reservado dependendo do tipo da oferta (Reais para compras, Tokens para vendas)
      if (oferta.type === "buy") {
        // Devolve os Reais que estavam bloqueados ao saldo do criador da oferta de compra
        const precoTotalCents = oferta.precoPorTokenCents * oferta.quantidade;
        await adicionarDeposito(userId, precoTotalCents);

        response.status(200).send({
          sucesso: true,
          mensagem: `Oferta de compra cancelada. R$ ${(precoTotalCents / 100).toFixed(2)} devolvidos à sua carteira.`,
          ofertaId: offerId,
        });
      } else {
        // Devolve os tokens que estavam reservados de volta ao portfólio do vendedor
        const precoPorTokenReais = oferta.precoPorTokenCents / 100;
        await adicionarTokensAoPortfolio(
          userId,
          oferta.startupId,
          oferta.quantidade,
          precoPorTokenReais,
        );

        response.status(200).send({
          sucesso: true,
          mensagem: `Oferta cancelada. ${oferta.quantidade} token(s) devolvidos à sua carteira.`,
          ofertaId: offerId,
        });
      }
    } catch (error) {
      logger.error("Erro ao cancelar oferta de mercado.", error);
      response.status(500).send("Erro interno ao cancelar oferta.");
    }
  },
);
