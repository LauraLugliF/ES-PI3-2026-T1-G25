import { Timestamp } from "firebase-admin/firestore";

export type StartupStage = "nova" | "em_operacao" | "em_expansao";

export type Founder = {
  name: string;
  role: string;
  equityPercent: number;
  bio?: string;
};

export type ExternalMember = {
  name: string;
  role: string;
  organization?: string;
};

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