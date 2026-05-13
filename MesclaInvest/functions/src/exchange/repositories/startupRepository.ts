// Max Thomazini Barbosa RA:25003934
// Repositório para acessar dados de startups (leitura)

import {db} from "../../startups/shared/firebase";
import {StartupDocument} from "../../startups/types";

// Obter dados de uma startup específica
export async function obterStartup(startupId: string): Promise<StartupDocument | null> {
  if (!startupId) {
    throw new Error("startupId é obrigatório");
  }

  try {
    const docRef = db.collection("startups").doc(startupId);
    const snap = await docRef.get();

    if (!snap.exists) {
      return null;
    }

    return snap.data() as StartupDocument;
  } catch (erro) {
    throw new Error(`Erro ao obter startup: ${erro}`);
  }
}

// Obter todas as startups
export async function obterTodasAsStartups(): Promise<StartupDocument[]> {
  try {
    const snap = await db.collection("startups").get();

    return snap.docs.map((doc) => doc.data() as StartupDocument);
  } catch (erro) {
    throw new Error(`Erro ao obter startups: ${erro}`);
  }
}

// Verificar se uma startup existe
export async function startupExiste(startupId: string): Promise<boolean> {
  try {
    const startup = await obterStartup(startupId);
    return startup !== null;
  } catch {
    return false;
  }
}

// Obter preço atual de um token de uma startup
export async function obterPrecoTokenStartup(startupId: string): Promise<number | null> {
  try {
    const startup = await obterStartup(startupId);
    if (!startup) {
      return null;
    }
    return startup.currentTokenPriceCents || null;
  } catch {
    return null;
  }
}
