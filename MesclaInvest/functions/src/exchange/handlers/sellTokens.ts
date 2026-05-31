// Max Thomazini Barbosa RA:25003934
// Handler para venda de tokens.

// Dependências do Firebase Functions e do logger para expor a rota HTTP e registrar falhas.
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
// Repositório que credita o valor da venda no saldo do usuário.
import {adicionarDeposito} from "../repositories/userRepository";
// Repositório que valida a existência da startup negociada.
import {obterStartup} from "../repositories/startupRepository";
// Repositório que consulta e remove tokens do portfólio do usuário.
import {removerTokensDoPortfolio, obterPortfolio} from "../repositories/portfolioRepository";
// Repositório que registra a operação no histórico de transações.
import {criarTransacao} from "../repositories/transactionRepository";
// Atualiza os indicadores consolidados da startup após a venda.
import {atualizarStartupAposVenda} from "../../startups/repositories/startupRepository";

// Function HTTP que executa o fluxo completo de venda de tokens.
export const sellTokensHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      // Lê os parâmetros obrigatórios enviados no corpo da requisição.
      const userId = (request.body?.userId as string) || "";
      const startupId = (request.body?.startupId as string) || "";
      const quantidade = (request.body?.quantidade as number) || 0;
      const precoUnitario = (request.body?.precoUnitario as number) || 0;

      // Garante que todos os campos obrigatórios estejam presentes.
      if (!userId || !startupId || quantidade === undefined || precoUnitario === undefined) {
        response.status(400).send("userId, startupId, quantidade e precoUnitario são obrigatórios");
        return;
      }

      // Confere se os campos numéricos realmente chegaram como números.
      if (typeof quantidade !== "number" || typeof precoUnitario !== "number") {
        response.status(400).send("quantidade e precoUnitario devem ser números");
        return;
      }

      // Rejeita quantidades inválidas e preço unitário negativo.
      if (quantidade <= 0 || precoUnitario < 0) {
        response.status(400).send("quantidade deve ser positiva e precoUnitario não-negativo");
        return;
      }

      // Valida se a startup informada realmente existe.
      const startup = await obterStartup(startupId);
      if (!startup) {
        response.status(404).send("Startup não encontrada");
        return;
      }

      // Verifica se o usuário possui posição aberta nessa startup.
      const portfolio = await obterPortfolio(userId, startupId);
      if (!portfolio) {
        response.status(404).send("Você não possui tokens dessa startup");
        return;
      }

      // Evita que o usuário venda mais tokens do que possui.
      if (portfolio.quantidade < quantidade) {
        response.status(400).send(
          `Você possui apenas ${portfolio.quantidade} tokens, mas está tentando vender ${quantidade}`,
        );
        return;
      }

      // Calcula o valor total em centavos para manter consistência com o saldo em banco.
      const precoTotalCents = Math.floor(quantidade * precoUnitario * 100);

      // Remove os tokens vendidos do portfólio do usuário.
      const novoPortfolio = await removerTokensDoPortfolio(
        userId,
        startupId,
        quantidade,
      );

      // Atualiza os dados agregados da startup após a venda.
      const startupAtualizada = await atualizarStartupAposVenda(
        startupId,
        quantidade,
        precoTotalCents,
      );

      // Credita o valor da venda no saldo do usuário.
      await adicionarDeposito(userId, precoTotalCents);

      // Registra a operação no histórico para auditoria e rastreabilidade.
      const transacao = await criarTransacao(
        "venda",
        userId,
        startupId,
        quantidade,
        precoUnitario,
      );

      // Retorna um resumo da venda concluída com sucesso.
      response.status(200).send({
        sucesso: true,
        mensagem: "Venda realizada com sucesso",
        portfolio: novoPortfolio,
        startup: startupAtualizada,
        transacao,
      });
    } catch (error) {
      // Registra qualquer falha inesperada e devolve erro genérico ao cliente.
      logger.error("Erro ao realizar venda de tokens.", error);
      response.status(500).send("Erro interno ao realizar venda.");
    }
  },
);
