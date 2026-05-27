// Laura Lugli Fonseca Pereira RA: 25000739
// Repositório responsável pelas consultas da tela de detalhes da startup
import {
  StartupDocument,
  StartupListItem,
  StartupQuestionDocument,
} from "../types";
import {db} from "../shared/firebase";

// Reutiliza a collection de startups do Firestore
const startupsCollection = db.collection("startups");

// Converte documento completo em versão resumida para listagem
function toListItem(id: string, startup: StartupDocument): StartupListItem {
  // Retorna apenas os campos necessários para a tela de catálogo
  return {
    id,
    name: startup.name,
    stage: startup.stage,
    shortDescription: startup.shortDescription,
    capitalRaisedCents: startup.capitalRaisedCents,
    totalTokensIssued: startup.totalTokensIssued,
    currentTokenPriceCents: startup.currentTokenPriceCents,
    coverImageUrl: startup.coverImageUrl,
    tags: startup.tags,
  };
}

// Retorna lista resumida de todas as startups para a tela de catálogo
export async function listStartupItems(): Promise<StartupListItem[]> {
  // Busca até 100 startups no Firestore
  const snapshot = await startupsCollection.limit(100).get();
  // Converte cada documento para o formato resumido
  return snapshot.docs.map((doc) =>
    toListItem(doc.id, doc.data() as StartupDocument),
  );
}

// Busca o documento completo de uma startup pelo ID
export async function getStartupById(
  startupId: string,
): Promise<StartupDocument | undefined> {
  // Busca o documento da startup pelo ID informado
  const snapshot = await startupsCollection.doc(startupId).get();
  // Retorna undefined se a startup não existir
  if (!snapshot.exists) {
    return undefined;
  }
  // Retorna os dados da startup encontrada
  return snapshot.data() as StartupDocument;
}

// Verifica se o usuário autenticado é investidor da startup informada
export async function userIsInvestor(
  startupId: string,
  uid: string,
): Promise<boolean> {
  // Busca o documento do investidor na subcoleção investors
  const investorSnapshot = await startupsCollection
    .doc(startupId)
    .collection("investors")
    .doc(uid)
    .get();
  // Retorna true se o documento existir, false caso contrário
  return investorSnapshot.exists;
}

// Retorna as perguntas públicas da startup ordenadas pela mais recente
export async function listPublicQuestions(startupId: string) {
  // Busca até 50 perguntas públicas na subcoleção questions
  const questionsSnapshot = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .where("visibility", "==", "publica")
    .limit(50)
    .get();

  // Mapeia os documentos para o formato esperado pelo app
  return questionsSnapshot.docs
    .map((doc) => ({
      id: doc.id,
      text: doc.get("text"),
      answer: doc.get("answer") ?? null,
      answeredAt: doc.get("answeredAt")?.toDate?.()?.toISOString?.() ?? null,
      createdAt: doc.get("createdAt")?.toDate?.()?.toISOString?.() ?? null,
    }))
    // Ordena pela mais recente primeiro
    .sort((left, right) =>
      String(right.createdAt ?? "").localeCompare(String(left.createdAt ?? "")),
    );
}

// Retorna as perguntas privadas do investidor logado ordenadas pela mais recente
// Somente o próprio investidor pode ver suas perguntas privadas
export async function listPrivateQuestions(startupId: string, uid: string) {
  // Busca até 50 perguntas privadas do investidor logado
  const questionsSnapshot = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .where("visibility", "==", "privada")
    .where("authorUid", "==", uid)
    .limit(50)
    .get();

  // Mapeia os documentos para o formato esperado pelo app
  return questionsSnapshot.docs
    .map((doc) => ({
      id: doc.id,
      text: doc.get("text"),
      answer: doc.get("answer") ?? null,
      answeredAt: doc.get("answeredAt")?.toDate?.()?.toISOString?.() ?? null,
      createdAt: doc.get("createdAt")?.toDate?.()?.toISOString?.() ?? null,
    }))
    // Ordena pela mais recente primeiro
    .sort((left, right) =>
      String(right.createdAt ?? "").localeCompare(String(left.createdAt ?? "")),
    );
}

// Salva uma nova pergunta na subcoleção de perguntas da startup
export async function createQuestion(
  startupId: string,
  question: StartupQuestionDocument,
): Promise<string> {
  // Adiciona a pergunta na subcoleção questions da startup
  const questionRef = await startupsCollection
    .doc(startupId)
    .collection("questions")
    .add(question);
  // Retorna o ID gerado para a pergunta
  return questionRef.id;
}
