// Max Thomazini Barbosa RA:25003934

// Dependências do Firebase Functions e do logger para expor a consulta HTTP e registrar falhas.
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
// Repositório responsável por buscar o saldo persistido do usuário.
import {getUserBalance} from "../repositories/userRepository";

// Function HTTP que consulta o saldo de um usuário a partir do `uid` informado.
export const getUserBalanceHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      // Aceita o identificador tanto pela query string quanto pelo corpo da requisição.
      const uid = (request.query?.uid as string) || request.body?.uid;

      // Garante que o usuário tenha sido informado antes de consultar o banco.
      if (typeof uid !== "string" || uid.trim().length === 0) {
        response.status(400).send("Campo 'uid' é obrigatório.");
        return;
      }

      // Busca o saldo em centavos no repositório.
      const saldo = await getUserBalance(uid);

      // Se o usuário não existir, retorna 404 para sinalizar ausência de cadastro.
      if (saldo === null) {
        response.status(404).send("Usuário não encontrado.");
        return;
      }

      // Retorna o saldo bruto para a camada que consome esta function.
      response.status(200).send({uid, saldo});
    } catch (error) {
      // Registra a falha e responde com erro genérico para evitar vazamento de detalhes internos.
      logger.error("Erro ao obter saldo do usuário.", error);
      response.status(500).send("Erro interno ao obter saldo.");
    }
  },
);
