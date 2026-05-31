// Max Thomazini Barbosa RA:25003934
// Handler para compra de tokens.

// Dependências do Firebase Functions e do logger para expor a rota HTTP e registrar falhas.
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
// Repositório responsável por ler e debitar o saldo do usuário.
import {getUserBalance, deduzirSaldoUsuario} from "../repositories/userRepository";

// Repositório de startups usado para validar a existência da startup antes da compra.
import {obterStartup} from "../repositories/startupRepository";
// Repositório que atualiza a posição de tokens do usuário.
import {adicionarTokensAoPortfolio} from "../repositories/portfolioRepository";
// Repositório que persiste o histórico financeiro da operação.
import {criarTransacao} from "../repositories/transactionRepository";
// Atualiza os dados agregados da startup após a compra.
import {atualizarStartupAposCompra} from "../../startups/repositories/startupRepository";

// Function HTTP que executa o fluxo completo de compra de tokens.
export const buyTokensHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      // Lê os parâmetros obrigatórios enviados no corpo da requisição.
      const userId = (request.body?.userId as string) || "";
      const startupId = (request.body?.startupId as string) || "";
      const quantidade = (request.body?.quantidade as number) || 0;
      const precoUnitario = (request.body?.precoUnitario as number) || 0;

      // Valida se todos os campos obrigatórios foram enviados.
      if (!userId || !startupId || quantidade === undefined || precoUnitario === undefined) {
        response.status(400).send("userId, startupId, quantidade e precoUnitario são obrigatórios");
        return;
      }

      // Garante que os campos numéricos vieram com o tipo esperado.
      if (typeof quantidade !== "number" || typeof precoUnitario !== "number") {
        response.status(400).send("quantidade e precoUnitario devem ser números");
        return;
      }

      // Rejeita quantidades inválidas e preços unitários negativos.
      if (quantidade <= 0 || precoUnitario < 0) {
        response.status(400).send("quantidade deve ser positiva e precoUnitario não-negativo");
        return;
      }

      // Confirma que a startup informada existe antes de movimentar saldo ou portfólio.
      const startup = await obterStartup(startupId);
      if (!startup) {
        response.status(404).send("Startup não encontrada");
        return;
      }

      // Calcula o valor total em centavos para evitar erros de precisão decimal.
      const precoTotalCents = Math.floor(quantidade * precoUnitario * 100);

      // Verifica se o usuário possui saldo suficiente para concluir a compra.
      const saldoDisponivel = await getUserBalance(userId);
      if (saldoDisponivel === null || saldoDisponivel < precoTotalCents) {
        response.status(400).send("Saldo insuficiente para essa compra");
        return;
      }

      // Debita o valor da conta antes de registrar os tokens comprados.
      await deduzirSaldoUsuario(userId, precoTotalCents);

      // Atualiza o portfólio do usuário com a nova posição comprada.
      const portfolio = await adicionarTokensAoPortfolio(
        userId,
        startupId,
        quantidade,
        precoUnitario,
      );

      // Atualiza os dados consolidados da startup após a movimentação.
      const startupAtualizada = await atualizarStartupAposCompra(
        startupId,
        quantidade,
        precoTotalCents,
      );

      // Registra a operação no histórico para rastreabilidade e auditoria.
      const transacao = await criarTransacao(
        "compra",
        userId,
        startupId,
        quantidade,
        precoUnitario,
      );

      // Retorna um resumo da operação concluída com sucesso.
      response.status(200).send({
        sucesso: true,
        mensagem: "Compra realizada com sucesso",
        portfolio,
        startup: startupAtualizada,
        transacao,
      });
    } catch (error) {
      // Registra qualquer falha inesperada e devolve erro genérico ao cliente.
      logger.error("Erro ao realizar compra de tokens.", error);
      response.status(500).send("Erro interno ao realizar compra.");
    }
  },
);

