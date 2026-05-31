// LUCAS RODRIGUES XAVIER - 25000508
// Handler para aceitar uma oferta do mercado P2P (comprador)
// Executa em transação atômica: debita comprador, credita vendedor, transfere tokens, atualiza preço.

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {FieldValue} from "firebase-admin/firestore";
import {db} from "../../startups/shared/firebase";
import {getUserBalance, deduzirSaldoUsuario, adicionarDeposito} from "../repositories/userRepository";
import {adicionarTokensAoPortfolio, obterPortfolio, removerTokensDoPortfolio} from "../repositories/portfolioRepository";
import {atualizarStartupAposCompra, atualizarStartupAposVenda} from "../../startups/repositories/startupRepository";
import {MarketOffer} from "../types/MarketOffer";

export const acceptMarketOfferHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      const buyerId = (request.body?.buyerId as string) || "";
      const offerId = (request.body?.offerId as string) || "";

      // Valida campos obrigatórios
      if (!buyerId || !offerId) {
        response.status(400).send("buyerId e offerId são obrigatórios.");
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

      // Verifica se a oferta ainda está aberta
      if (oferta.status !== "open") {
        response.status(400).send("Esta oferta já foi encerrada ou cancelada.");
        return;
      }

      // Comprador não pode comprar a própria oferta
      if (oferta.sellerId === buyerId) {
        response.status(400).send("Você não pode aceitar sua própria oferta.");
        return;
      }

      const precoTotalCents = oferta.precoPorTokenCents * oferta.quantidade;

      if (oferta.type === "buy") {
        // Caso em que a oferta é de COMPRA:
        // Quem está aceitando (buyerId) é o VENDEDOR dos tokens, e quem criou a oferta (oferta.sellerId) é o COMPRADOR.

        // Verifica se quem aceita possui tokens suficientes no portfólio
        const portfolio = await obterPortfolio(buyerId, oferta.startupId);
        if (!portfolio || portfolio.quantidade < oferta.quantidade) {
          response.status(400).send(`Você não possui tokens suficientes desta startup para vender. Necessário: ${oferta.quantidade}.`);
          return;
        }

        // Executa a transação atômica no Firestore para preencher a oferta
        await db.runTransaction(async (tx) => {
          tx.update(ofertaRef, {
            status: "filled",
            atualizadaEm: FieldValue.serverTimestamp(),
          });
        });

        // Deduz tokens do portfólio de quem aceitou a oferta
        await removerTokensDoPortfolio(buyerId, oferta.startupId, oferta.quantidade);

        // Adiciona tokens ao portfólio do criador da oferta (comprador original)
        const precoPorTokenReais = oferta.precoPorTokenCents / 100;
        await adicionarTokensAoPortfolio(
          oferta.sellerId,
          oferta.startupId,
          oferta.quantidade,
          precoPorTokenReais,
        );

        // Credita dinheiro ao saldo de quem aceitou a oferta (vendedor atual)
        await adicionarDeposito(buyerId, precoTotalCents);

        // Impacta o preço do token (pressão de venda — preço cai)
        await atualizarStartupAposVenda(oferta.startupId, oferta.quantidade, precoTotalCents);

        response.status(200).send({
          sucesso: true,
          mensagem: `Venda realizada! Você vendeu ${oferta.quantidade} token(s) para ${oferta.sellerEmail || "outro usuário"}.`,
          ofertaId: offerId,
          quantidade: oferta.quantidade,
          totalPagoCents: precoTotalCents,
        });
      } else {
        // Caso em que a oferta é de VENDA (sell ou nulo):
        // Quem está aceitando (buyerId) é o COMPRADOR dos tokens, e quem criou a oferta (oferta.sellerId) é o VENDEDOR.

        // Verifica saldo do comprador
        const saldoComprador = await getUserBalance(buyerId);
        if (saldoComprador === null || saldoComprador < precoTotalCents) {
          response.status(400).send("Saldo insuficiente para comprar esta oferta.");
          return;
        }

        // Executa a transação atômica no Firestore
        await db.runTransaction(async (tx) => {
          tx.update(ofertaRef, {
            status: "filled",
            atualizadaEm: FieldValue.serverTimestamp(),
          });
        });

        // Debita saldo do comprador
        await deduzirSaldoUsuario(buyerId, precoTotalCents);

        // Credita saldo do vendedor
        await adicionarDeposito(oferta.sellerId, precoTotalCents);

        // Adiciona tokens ao portfólio do comprador
        const precoPorTokenReais = oferta.precoPorTokenCents / 100;
        await adicionarTokensAoPortfolio(
          buyerId,
          oferta.startupId,
          oferta.quantidade,
          precoPorTokenReais,
        );

        // Impacta o preço do token (pressão de compra — preço sobe)
        await atualizarStartupAposCompra(oferta.startupId, oferta.quantidade, precoTotalCents);

        response.status(200).send({
          sucesso: true,
          mensagem: `Compra realizada! Você adquiriu ${oferta.quantidade} token(s) de ${oferta.startupId}.`,
          ofertaId: offerId,
          quantidade: oferta.quantidade,
          totalPagoCents: precoTotalCents,
        });
      }
    } catch (error) {
      logger.error("Erro ao aceitar oferta de mercado.", error);
      response.status(500).send("Erro interno ao aceitar oferta.");
    }
  },
);
