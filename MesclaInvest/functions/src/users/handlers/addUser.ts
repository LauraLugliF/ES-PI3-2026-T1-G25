// LUCAS RODRIGUES XAVIER - 25000508
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {saveUser} from "../repositories/userRepository";

export const addUser = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    const uid = request.body?.uid;

    if (typeof uid !== "string" || uid.trim().length === 0) {
      response.status(400).send("Campo 'uid' é obrigatório.");
      return;
    }

    try {
      await saveUser(uid, {
        nome: request.body?.nome,
        cpf: request.body?.cpf,
        email: request.body?.email,
        telefone: request.body?.telefone,
        saldo: request.body?.saldo,
      });

      response.status(201).send("Pessoa cadastrada com sucesso. UID: " + uid);
    } catch (error) {
      logger.error("Erro ao cadastrar pessoa.", error);
      response.status(500).send("Erro interno ao cadastrar a pessoa.");
    }
  },
);
