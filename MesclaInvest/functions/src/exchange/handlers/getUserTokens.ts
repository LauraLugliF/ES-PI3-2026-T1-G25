import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {obterPortfoliosDoUsuario} from "../repositories/portfolioRepository";

export const getUserTokensHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      const userId =
        (request.query?.userId as string) ||
        (request.query?.uid as string) ||
        request.body?.userId ||
        request.body?.uid;

      if (typeof userId !== "string" || userId.trim().length === 0) {
        response.status(400).send("Campo 'userId' (ou 'uid') é obrigatório.");
        return;
      }

      const portfolios = await obterPortfoliosDoUsuario(userId);

      response.status(200).send({
        userId,
        tokens: portfolios,
      });
    } catch (error) {
      logger.error("Erro ao obter tokens do usuário.", error);
      response.status(500).send("Erro interno ao obter tokens do usuário.");
    }
  },
);
