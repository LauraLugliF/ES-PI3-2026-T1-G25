// LUCAS RODRIGUES XAVIER - 25000508
// Este arquivo define uma Cloud Function (função na nuvem) chamada "addUser".
// Ela funciona como uma "porta de entrada" pública na web que o aplicativo chama
// para salvar as informações de uma nova pessoa no banco de dados.

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {saveUser} from "../repositories/userRepository";

// Cria o endpoint HTTP na região da América do Sul (São Paulo)
export const addUser = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    const uid = request.body?.uid; // Pega o identificador único do usuário

    // Verifica se o identificador do usuário foi enviado corretamente
    if (typeof uid !== "string" || uid.trim().length === 0) {
      response.status(400).send("Campo 'uid' é obrigatório.");
      return;
    }

    try {
      // Chama o nosso repositório para salvar os dados da pessoa
      await saveUser(uid, {
        nome: request.body?.nome,
        cpf: request.body?.cpf,
        email: request.body?.email,
        telefone: request.body?.telefone,
        saldo: request.body?.saldo,
      });

      // Retorna uma resposta HTTP 201 indicando que o cadastro foi feito com sucesso
      response.status(201).send("Pessoa cadastrada com sucesso. UID: " + uid);
    } catch (error) {
      // Se houver algum erro, salva nos logs do console do Firebase e avisa o aplicativo
      logger.error("Erro ao cadastrar pessoa.", error);
      response.status(500).send("Erro interno ao cadastrar a pessoa.");
    }
  },
);
