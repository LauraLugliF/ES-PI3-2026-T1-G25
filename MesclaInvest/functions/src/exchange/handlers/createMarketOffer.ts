// LUCAS RODRIGUES XAVIER - 25000508
// Handler para criar uma oferta de venda no mercado P2P
// Ao chamar, os tokens são reservados (saem da carteira) e a oferta fica visível para outros usuários.

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {FieldValue} from "firebase-admin/firestore";
import {db} from "../../startups/shared/firebase";
import {obterPortfolio, removerTokensDoPortfolio} from "../repositories/portfolioRepository";
import {atualizarStartupAposVenda} from "../../startups/repositories/startupRepository";

export const createMarketOfferHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      const sellerId = (request.body?.sellerId as string) || "";
      const sellerEmail = (request.body?.sellerEmail as string) || "";
      const startupId = (request.body?.startupId as string) || "";
      const quantidade = (request.body?.quantidade as number) || 0;
      const precoPorToken = (request.body?.precoPorToken as number) || 0;

      // Valida campos obrigatórios
      if (!sellerId || !startupId || quantidade <= 0 || precoPorToken <= 0) {
        response.status(400).send("sellerId, startupId, quantidade e precoPorToken são obrigatórios e devem ser positivos.");
        return;
      }

      // Verifica se o usuário possui tokens suficientes no portfólio
      const portfolio = await obterPortfolio(sellerId, startupId);
      if (!portfolio) {
        response.status(404).send("Você não possui tokens desta startup.");
        return;
      }
      if (portfolio.quantidade < quantidade) {
        response.status(400).send(`Você possui apenas ${portfolio.quantidade} token(s), mas tentou ofertar ${quantidade}.`);
        return;
      }

      const precoPorTokenCents = Math.round(precoPorToken * 100);
      const precoTotalCents = precoPorTokenCents * quantidade;

      // Remove os tokens do portfólio imediatamente (ficam reservados na oferta)
      await removerTokensDoPortfolio(sellerId, startupId, quantidade);

      // Cria a oferta no Firestore
      const ofertaRef = db.collection("marketOffers").doc();
      await ofertaRef.set({
        sellerId,
        sellerEmail,
        startupId,
        quantidade,
        precoPorTokenCents,
        status: "open",
        criadaEm: FieldValue.serverTimestamp(),
        atualizadaEm: FieldValue.serverTimestamp(),
      });

      // Impacta o preço do token (pressão de venda — preço cai)
      await atualizarStartupAposVenda(startupId, quantidade, precoTotalCents);

      response.status(200).send({
        sucesso: true,
        mensagem: "Oferta criada com sucesso. Seus tokens estão reservados e visíveis no mercado.",
        ofertaId: ofertaRef.id,
      });
    } catch (error) {
      logger.error("Erro ao criar oferta de mercado.", error);
      response.status(500).send("Erro interno ao criar oferta.");
    }
  },
);
