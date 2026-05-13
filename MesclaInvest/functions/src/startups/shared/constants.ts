// Laura Lugli Fonseca Pereira RA: 25000739
// Constantes compartilhadas entre os handlers do módulo de startups
import {QuestionVisibility, StartupStage} from "../types";

// Lista de estágios válidos para filtro e validação
export const allowedStages: StartupStage[] = [
  "nova",
  "em_operacao",
  "em_expansao",
];

// Lista de visibilidades válidas para perguntas
export const allowedVisibilities: QuestionVisibility[] = [
  "publica",
  "privada",
];
