// Max Thomazini Barbosa RA:25003934

// Dependências do Firebase Functions e do logger para expor a consulta HTTP e registrar falhas.
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
// Repositório responsável por recuperar os tokens do usuário no Firestore.
import {obterPortfoliosDoUsuario} from "../repositories/portfolioRepository";

// Function HTTP que retorna todos os tokens/portfólios associados a um usuário.
export const getUserTokensHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      // Aceita o identificador tanto por `userId` quanto por `uid`, na query ou no body.
      const userId =
        (request.query?.userId as string) ||
        (request.query?.uid as string) ||
        request.body?.userId ||
        request.body?.uid;

      // Garante que a chamada tenha um identificador válido antes de consultar o banco.
      if (typeof userId !== "string" || userId.trim().length === 0) {
        response.status(400).send("Campo 'userId' (ou 'uid') é obrigatório.");
        return;
      }

      // Busca todos os portfolios vinculados ao usuário informado.
      const portfolios = await obterPortfoliosDoUsuario(userId);

      // Retorna a lista em uma estrutura simples para consumo pela interface.
      response.status(200).send({
        userId,
        tokens: portfolios,
      });
    } catch (error) {
      // Registra o erro no logger do Firebase e devolve falha genérica ao cliente.
      logger.error("Erro ao obter tokens do usuário.", error);
      response.status(500).send("Erro interno ao obter tokens do usuário.");
    }
  },
);
