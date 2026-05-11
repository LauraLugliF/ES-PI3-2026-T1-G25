import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {getUserBalance} from "../repositories/userRepository";

export const getUserBalanceHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      const uid = (request.query?.uid as string) || request.body?.uid;

      if (typeof uid !== "string" || uid.trim().length === 0) {
        response.status(400).send("Campo 'uid' é obrigatório.");
        return;
      }

      const saldo = await getUserBalance(uid);

      if (saldo === null) {
        response.status(404).send("Usuário não encontrado.");
        return;
      }

      response.status(200).send({uid, saldo});
    } catch (error) {
      logger.error("Erro ao obter saldo do usuário.", error);
      response.status(500).send("Erro interno ao obter saldo.");
    }
  },
);
