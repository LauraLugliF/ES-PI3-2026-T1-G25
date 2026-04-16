import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {initializeApp} from "firebase-admin/app";
// Adicionado o FieldValue na importação abaixo
import {getFirestore, FieldValue} from "firebase-admin/firestore";

const app = initializeApp();
const db = getFirestore(app, "projeto3");
// Renomeado para fazer sentido com o objetivo
const colPessoas = db.collection("users");

export const addUser = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    // Coletando os dados da pessoa
    const uid = request.body?.uid;
    const nome = request.body?.nome;
    const cpf = request.body?.cpf;
    const email = request.body?.email;
    const telefone = request.body?.telefone;
    
    // Gerando o timestamp do servidor
    const createdAt = FieldValue.serverTimestamp();

    // Validação obrigatória do UID
    if (typeof uid !== "string" || uid.trim().length === 0) {
      response.status(400).send("Campo 'uid' é obrigatório.");
      return;
    }

    // Montando o objeto da Pessoa com todos os campos recebidos
    const pessoa = {
      uid: uid,
      nome: nome || null,
      cpf: cpf || null,
      email: email || null,
      telefone: telefone || null,
      createdAt: createdAt,
    };

    try {
      // Inserindo a pessoa no banco usando o UID como document ID
      await colPessoas.doc(uid).set(pessoa);
      response.status(201).send("Pessoa cadastrada com sucesso. UID: " + uid);
    } catch (error) {
      logger.error("Erro ao cadastrar pessoa.", error);
      response.status(500).send("Erro interno ao cadastrar a pessoa.");
    }
  }
);