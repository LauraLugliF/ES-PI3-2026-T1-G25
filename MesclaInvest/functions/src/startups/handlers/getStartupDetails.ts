// Laura Lugli Fonseca Pereira RA: 25000739
// Handler que retorna os dados completos da tela de detalhes de uma startup
import {HttpsError, onCall} from "firebase-functions/https";
import {requireAuthenticatedUser} from "../shared/auth";
import {normalizeString} from "../shared/validation";
import {
  getStartupById,
  listPublicQuestions,
  userIsInvestor,
} from "../repositories/startupDetailsRepository";

// Busca os dados completos de uma startup específica
// Chamada pelo app com `id` da startup
// Retorna sumário, sócios, conselho, vídeos, perguntas públicas e flags de acesso
export const getStartupDetails = onCall(async (request) => {
  // Verifica se o usuário está autenticado
  const user = requireAuthenticatedUser(request);

  // Normaliza o ID recebido removendo espaços extras
  const startupId = normalizeString(request.data?.id);

  // Valida se o ID foi enviado corretamente
  if (!startupId) {
    throw new HttpsError(
      "invalid-argument",
      "Informe o parametro id da startup."
    );
  }

  // Busca o documento principal da startup no Firestore
  const startup = await getStartupById(startupId);

  // Retorna erro 404 se a startup não existir
  if (!startup) {
    throw new HttpsError("not-found", "Startup nao encontrada.");
  }

  // Verifica se o usuário autenticado é investidor desta startup
  const isInvestor = await userIsInvestor(startupId, user.uid);

  // Busca as perguntas públicas da subcoleção de perguntas
  const questions = await listPublicQuestions(startupId);

  // Retorna todos os dados da tela de detalhe para o app Flutter
  return {
    data: {
      // Identificador da startup
      id: startupId,
      // Dados gerais exibidos na listagem e no detalhe
      name: startup.name,
      stage: startup.stage,
      shortDescription: startup.shortDescription,
      description: startup.description,
      coverImageUrl: startup.coverImageUrl ?? null,
      tags: startup.tags,
      // Sumário executivo da startup
      executiveSummary: startup.executiveSummary,
      // Métricas financeiras e de tokens
      capitalRaisedCents: startup.capitalRaisedCents,
      totalTokensIssued: startup.totalTokensIssued,
      currentTokenPriceCents: startup.currentTokenPriceCents,
      // Estrutura societária — sócios e fundadores
      founders: startup.founders,
      // Conselho e mentores — só retorna se houver dados
      externalMembers: startup.externalMembers.length > 0
        ? startup.externalMembers
        : [],
      // Vídeos demonstrativos — só retorna se houver dados
      demoVideos: startup.demoVideos.length > 0
        ? startup.demoVideos
        : [],
      // URL do plano de negócios em PDF
      pitchDeckUrl: startup.pitchDeckUrl ?? null,
      // Perguntas e respostas públicas
      publicQuestions: questions,
      // Timestamps convertidos para ISO string
      createdAt: startup.createdAt?.toDate().toISOString() ?? null,
      updatedAt: startup.updatedAt?.toDate().toISOString() ?? null,
      // Flags de acesso exclusivas para investidores
      access: {
        isInvestor,
        canTradeTokens: isInvestor,
        canSendPrivateQuestions: isInvestor,
      },
    },
  };
});