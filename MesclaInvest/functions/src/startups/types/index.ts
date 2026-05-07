// Max Thomazini Barbosa RA:25003934
import {Timestamp} from "firebase-admin/firestore";

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
