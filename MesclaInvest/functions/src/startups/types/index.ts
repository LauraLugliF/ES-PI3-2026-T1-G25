// Max Thomazini Barbosa RA:25003934
import {Timestamp, FieldValue} from "firebase-admin/firestore";

// Etapa atual da startup usada para classificar o estágio do negócio.
export type StartupStage = "nova" | "em_operacao" | "em_expansao";

// Representa os fundadores da startup e sua participação no negócio.
export type Founder = {
  name: string;
  role: string;
  equityPercent: number;
  bio?: string;
};

// Representa membros externos ligados à startup, como conselheiros ou parceiros.
export type ExternalMember = {
  name: string;
  role: string;
  organization?: string;
};

// Estrutura principal do documento de startup armazenado no Firestore.
export type StartupDocument = {
  name: string;
  stage: StartupStage;
  shortDescription: string;
  description: string;
  executiveSummary: string;
  capitalRaisedCents: number;
  totalTokensIssued: number;
  currentTokenPriceCents: number;
  founders: Founder[];
  externalMembers: ExternalMember[];
  demoVideos: string[];
  pitchDeckUrl?: string;
  coverImageUrl?: string;
  tags: string[];
  createdAt?: Timestamp;
  updatedAt?: Timestamp;
};

// Ponto do histórico de preço usado pelo gráfico de desempenho.
export type StartupPriceHistoryPoint = {
  priceCents: number;
  changeType: "seed" | "compra" | "venda";
  quantity: number;
  createdAt?: Timestamp | FieldValue;
};

// Define o nível de visibilidade de uma pergunta enviada à startup.
export type QuestionVisibility = "publica" | "privada";

// Dados mínimos do usuário autenticado necessários para regras de negócio.
export type AuthenticatedUser = {
  uid: string;
  email?: string;
};

// Documento de pergunta armazenado na subcoleção da startup.
export type StartupQuestionDocument = {
  authorUid: string;
  authorEmail?: string;
  text: string;
  visibility: QuestionVisibility;
  answer?: string;
  answeredAt?: Timestamp;
  createdAt: FieldValue;
};

// Versão resumida de startup usada na listagem do catálogo.
export type StartupListItem = {
  id: string;
  name: string;
  stage: StartupStage;
  shortDescription: string;
  capitalRaisedCents: number;
  totalTokensIssued: number;
  currentTokenPriceCents: number;
  coverImageUrl?: string;
  tags: string[];
};
