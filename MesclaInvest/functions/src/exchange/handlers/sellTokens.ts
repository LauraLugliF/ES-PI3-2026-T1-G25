// Max Thomazini Barbosa RA:25003934
// Handler para venda de tokens

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {adicionarDeposito} from "../repositories/userRepository";
import {obterStartup} from "../repositories/startupRepository";
import {removerTokensDoPortfolio, obterPortfolio} from "../repositories/portfolioRepository";
import {criarTransacao} from "../repositories/transactionRepository";
import {atualizarStartupAposVenda} from "../../startups/repositories/startupRepository";

export const sellTokensHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      const userId = (request.body?.userId as string) || "";
      const startupId = (request.body?.startupId as string) || "";
      const quantidade = (request.body?.quantidade as number) || 0;
      const precoUnitario = (request.body?.precoUnitario as number) || 0;

      // Validações básicas
      if (!userId || !startupId || quantidade === undefined || precoUnitario === undefined) {
        response.status(400).send("userId, startupId, quantidade e precoUnitario são obrigatórios");
        return;
      }

      if (typeof quantidade !== "number" || typeof precoUnitario !== "number") {
        response.status(400).send("quantidade e precoUnitario devem ser números");
        return;
      }

      if (quantidade <= 0 || precoUnitario < 0) {
        response.status(400).send("quantidade deve ser positiva e precoUnitario não-negativo");
        return;
      }

      // Verificar se a startup existe
      const startup = await obterStartup(startupId);
      if (!startup) {
        response.status(404).send("Startup não encontrada");
        return;
      }

      // Verificar se o usuário possui portfólio nessa startup
      const portfolio = await obterPortfolio(userId, startupId);
      if (!portfolio) {
        response.status(404).send("Você não possui tokens dessa startup");
        return;
      }

      // Verificar se o usuário possui quantidade suficiente de tokens
      if (portfolio.quantidade < quantidade) {
        response.status(400).send(
          `Você possui apenas ${portfolio.quantidade} tokens, mas está tentando vender ${quantidade}`,
        );
        return;
      }

      // Calcular o valor total em centavos para saldo e capital da startup.
      const precoTotalCents = Math.floor(quantidade * precoUnitario * 100);

      // Remover tokens do portfólio
      const novoPortfolio = await removerTokensDoPortfolio(
        userId,
        startupId,
        quantidade,
      );

      const startupAtualizada = await atualizarStartupAposVenda(
        startupId,
        quantidade,
        precoTotalCents,
      );

      // Adicionar saldo ao usuário
      await adicionarDeposito(userId, precoTotalCents);

      // Registrar a transação
      const transacao = await criarTransacao(
        "venda",
        userId,
        startupId,
        quantidade,
        precoUnitario,
      );

      response.status(200).send({
        sucesso: true,
        mensagem: "Venda realizada com sucesso",
        portfolio: novoPortfolio,
        startup: startupAtualizada,
        transacao,
      });
    } catch (error) {
      logger.error("Erro ao realizar venda de tokens.", error);
      response.status(500).send("Erro interno ao realizar venda.");
    }
  },
);
