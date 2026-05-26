// Max Thomazini Barbosa RA:25003934
// Handler para compra de tokens

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {getUserBalance, deduzirSaldoUsuario} from "../repositories/userRepository";

import {obterStartup} from "../repositories/startupRepository";
import {adicionarTokensAoPortfolio} from "../repositories/portfolioRepository";
import {criarTransacao} from "../repositories/transactionRepository";

export const buyTokensHandler = onRequest(
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

      // Calcular o valor total
      const precoTotal = Math.floor(quantidade * precoUnitario);

      // Verificar se o usuário tem saldo suficiente
      const saldoDisponivel = await getUserBalance(userId);
      if (saldoDisponivel === null || saldoDisponivel < precoTotal) {
        response.status(400).send("Saldo insuficiente para essa compra");
        return;
      }

      // Deduzir o saldo da conta do usuário
      await deduzirSaldoUsuario(userId, precoTotal);

      // Adicionar tokens ao portfólio
      const portfolio = await adicionarTokensAoPortfolio(
        userId,
        startupId,
        quantidade,
        precoUnitario,
      );

      // Registrar a transação
      const transacao = await criarTransacao(
        "compra",
        userId,
        startupId,
        quantidade,
        precoUnitario,
      );

      response.status(200).send({
        sucesso: true,
        mensagem: "Compra realizada com sucesso",
        portfolio,
        transacao,
      });
    } catch (error) {
      logger.error("Erro ao realizar compra de tokens.", error);
      response.status(500).send("Erro interno ao realizar compra.");
    }
  },
);
