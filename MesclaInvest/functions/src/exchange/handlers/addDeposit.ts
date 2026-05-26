import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {adicionarDeposito} from "../repositories/userRepository";

export const addDepositHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      const uid = (request.query?.uid as string) || request.body?.uid;
      const valorEmReais = (request.query?.valor as unknown) || request.body?.valor;

      if (typeof uid !== "string" || uid.trim().length === 0) {
        response.status(400).send("Campo 'uid' é obrigatório.");
        return;
      }

      if (typeof valorEmReais !== "number" || valorEmReais <= 0) {
        response.status(400).send("Campo 'valor' deve ser um número positivo (em reais).");
        return;
      }

      // Converte reais para centavos
      const depositoEmCentavos = Math.floor(valorEmReais * 100);

      const novoSaldo = await adicionarDeposito(uid, depositoEmCentavos);

      // Retorna novo saldo em reais
      response.status(200).send({
        uid,
        depositoEmReais: valorEmReais,
        novoSaldoEmReais: novoSaldo / 100,
      });
    } catch (error) {
      logger.error("Erro ao adicionar depósito.", error);
      response.status(500).send("Erro interno ao adicionar depósito.");
    }
  },
);
