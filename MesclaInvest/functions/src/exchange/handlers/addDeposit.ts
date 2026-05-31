// Max Thomazini Barbosa RA:25003934

// Dependências do Firebase Functions e do logger para expor a API HTTP e registrar falhas.
import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
// Repositório responsável por atualizar o saldo do usuário no Firestore.
import {adicionarDeposito} from "../repositories/userRepository";

// Function HTTP que recebe um depósito em reais e o converte para centavos antes de persistir.
export const addDepositHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      // Aceita os dados tanto pela query string quanto pelo corpo da requisição.
      const uid = (request.query?.uid as string) || request.body?.uid;
      const valorEmReais = (request.query?.valor as unknown) || request.body?.valor;

      // Garante que o identificador do usuário foi enviado e não está vazio.
      if (typeof uid !== "string" || uid.trim().length === 0) {
        response.status(400).send("Campo 'uid' é obrigatório.");
        return;
      }

      // Valida se o valor informado é um número positivo em reais.
      if (typeof valorEmReais !== "number" || valorEmReais <= 0) {
        response.status(400).send("Campo 'valor' deve ser um número positivo (em reais).");
        return;
      }

      // Converte reais para centavos para evitar problemas de precisão com ponto flutuante.
      const depositoEmCentavos = Math.floor(valorEmReais * 100);

      // Atualiza o saldo do usuário e recupera o novo valor já consolidado.
      const novoSaldo = await adicionarDeposito(uid, depositoEmCentavos);

      // Responde com os valores em reais para facilitar o consumo pela interface.
      response.status(200).send({
        uid,
        depositoEmReais: valorEmReais,
        novoSaldoEmReais: novoSaldo / 100,
      });
    } catch (error) {
      // Registra o erro no logger do Firebase e retorna falha genérica ao cliente.
      logger.error("Erro ao adicionar depósito.", error);
      response.status(500).send("Erro interno ao adicionar depósito.");
    }
  },
);
