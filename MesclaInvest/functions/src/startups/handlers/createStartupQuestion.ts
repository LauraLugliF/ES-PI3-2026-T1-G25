// Laura Lugli Fonseca Pereira RA: 25000739
// Handler que cria uma pergunta pública ou privada para uma startup
import {FieldValue} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import {allowedVisibilities} from "../shared/constants";
import {requireAuthenticatedUser} from "../shared/auth";
import {normalizeString} from "../shared/validation";
import {
  createQuestion,
  getStartupById,
  userIsInvestor,
} from "../repositories/startupDetailsRepository";
import {QuestionVisibility, StartupQuestionDocument} from "../types";

// Cria uma pergunta para uma startup
// O app deve enviar em `data`:
// - `startupId`: identificador da startup
// - `text`: texto da pergunta
// - `visibility`: visibilidade da pergunta (publica ou privada)
// Perguntas privadas exigem que o usuário seja investidor da startup
export const createStartupQuestion = onCall(async (request) => {
  // Verifica se o usuário está autenticado e obtém seus dados
  const user = requireAuthenticatedUser(request);

  // Normaliza o ID da startup recebido
  const startupId = normalizeString(request.data?.startupId);

  // Normaliza o texto da pergunta recebido
  const text = normalizeString(request.data?.text);

  // Define visibilidade padrão como pública se não informada
  const visibility = normalizeString(request.data?.visibility) ?? "publica";

  // Valida se o ID da startup e o texto foram enviados
  if (!startupId || !text) {
    throw new HttpsError("invalid-argument", "Informe startupId e text.");
  }

  // Valida se a visibilidade informada é um valor permitido
  if (!allowedVisibilities.includes(visibility as QuestionVisibility)) {
    throw new HttpsError(
      "invalid-argument",
      "Visibility invalida. Use publica ou privada.",
    );
  }

  // Verifica se a startup existe no banco
  const startup = await getStartupById(startupId);

  // Retorna erro 404 se a startup não existir
  if (!startup) {
    throw new HttpsError("not-found", "Startup nao encontrada.");
  }

  // Perguntas privadas só podem ser enviadas por investidores
  if (visibility === "privada") {
    // Verifica se o usuário é investidor desta startup
    const isInvestor = await userIsInvestor(startupId, user.uid);

    // Bloqueia o envio se o usuário não for investidor
    if (!isInvestor) {
      throw new HttpsError(
        "permission-denied",
        "Somente investidores desta startup podem enviar perguntas privadas.",
      );
    }
  }

  // Monta o documento da pergunta para salvar no Firestore
  const question: StartupQuestionDocument = {
    authorUid: user.uid,
    authorEmail: user.email,
    text,
    visibility: visibility as QuestionVisibility,
    createdAt: FieldValue.serverTimestamp(),
  };

  // Salva a pergunta na subcoleção de perguntas da startup
  const questionId = await createQuestion(startupId, question);

  // Registra log da criação da pergunta
  logger.info("Pergunta criada para startup.", {
    startupId,
    questionId,
    visibility,
  });

  // Retorna os dados da pergunta criada
  return {
    data: {
      id: questionId,
      startupId,
      visibility,
    },
  };
});
