// LUCAS RODRIGUES XAVIER - 25000508
// Handler para criar uma oferta de venda no mercado P2P
// Ao chamar, os tokens são reservados (saem da carteira) e a oferta fica visível para outros usuários.

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {FieldValue} from "firebase-admin/firestore";
import {db} from "../../startups/shared/firebase";
import {obterPortfolio, removerTokensDoPortfolio} from "../repositories/portfolioRepository";
import {getUserBalance, deduzirSaldoUsuario} from "../repositories/userRepository";

export const createMarketOfferHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      const sellerId = (request.body?.sellerId as string) || "";
      const sellerEmail = (request.body?.sellerEmail as string) || "";
      const startupId = (request.body?.startupId as string) || "";
      const quantidade = (request.body?.quantidade as number) || 0;
      const precoPorToken = (request.body?.precoPorToken as number) || 0;
      // Recupera o tipo de oferta (compra 'buy' ou venda 'sell'). Caso omitido, assume 'sell' por retrocompatibilidade.
      const type = (request.body?.type as "buy" | "sell") || "sell";

      // Valida campos obrigatórios
      if (!sellerId || !startupId || quantidade <= 0 || precoPorToken <= 0) {
        response.status(400).send("sellerId, startupId, quantidade e precoPorToken são obrigatórios e devem ser positivos.");
        return;
      }

      const precoPorTokenCents = Math.round(precoPorToken * 100);
      const precoTotalCents = precoPorTokenCents * quantidade;

      // Se for uma oferta de COMPRA P2P (buy)
      if (type === "buy") {
        // Valida se o comprador possui saldo em dinheiro suficiente na carteira
        const saldoDisponivel = await getUserBalance(sellerId);
        if (saldoDisponivel === null || saldoDisponivel < precoTotalCents) {
          response.status(400).send(`Você possui saldo insuficiente para criar esta oferta de compra. Necessário: R$ ${(precoTotalCents / 100).toFixed(2)}.`);
          return;
        }

        // Reserva o dinheiro deduzindo do saldo do comprador imediatamente no momento da criação
        await deduzirSaldoUsuario(sellerId, precoTotalCents);

        // Cria a oferta de compra com status "open" e tipo "buy" no Firestore
        const ofertaRef = db.collection("marketOffers").doc();
        await ofertaRef.set({
          sellerId,
          sellerEmail,
          startupId,
          quantidade,
          precoPorTokenCents,
          status: "open",
          type: "buy",
          criadaEm: FieldValue.serverTimestamp(),
          atualizadaEm: FieldValue.serverTimestamp(),
        });

        response.status(200).send({
          sucesso: true,
          mensagem: "Oferta de compra criada com sucesso. Seu saldo foi reservado e a oferta está visível no mercado.",
          ofertaId: ofertaRef.id,
        });
      } else {
        // Se for uma oferta de VENDA P2P (sell)
        // Verifica se o usuário possui de fato os tokens suficientes no portfólio para vender
        const portfolio = await obterPortfolio(sellerId, startupId);
        if (!portfolio) {
          response.status(404).send("Você não possui tokens desta startup.");
          return;
        }
        if (portfolio.quantidade < quantidade) {
          response.status(400).send(`Você possui apenas ${portfolio.quantidade} token(s), mas tentou ofertar ${quantidade}.`);
          return;
        }

        // Remove os tokens do portfólio imediatamente (ficam reservados na oferta do mercado)
        await removerTokensDoPortfolio(sellerId, startupId, quantidade);

        // Cria a oferta de venda com status "open" e tipo "sell" no Firestore
        const ofertaRef = db.collection("marketOffers").doc();
        await ofertaRef.set({
          sellerId,
          sellerEmail,
          startupId,
          quantidade,
          precoPorTokenCents,
          status: "open",
          type: "sell",
          criadaEm: FieldValue.serverTimestamp(),
          atualizadaEm: FieldValue.serverTimestamp(),
        });

        response.status(200).send({
          sucesso: true,
          mensagem: "Oferta criada com sucesso. Seus tokens estão reservados e visíveis no mercado.",
          ofertaId: ofertaRef.id,
        });
      }
    } catch (error) {
      logger.error("Erro ao criar oferta de mercado.", error);
      response.status(500).send("Erro interno ao criar oferta.");
    }
  },
);
