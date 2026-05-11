import {HttpsError, onCall} from "firebase-functions/https";
import {seedDemoStartups} from "../repositories/startupRepository";
import {normalizeString} from "../shared/validation";

// Callable responsável por popular o catálogo de startups de demonstração.
export const seedStartupCatalog = onCall(async (request) => {
  // Normaliza a chave recebida para evitar falhas com espaços extras ou valores vazios.
  const seedKey = normalizeString(request.data?.seedKey);

  // Fora do emulator, exige uma chave válida para impedir uso indevido do seed.
  if (!process.env.FUNCTIONS_EMULATOR) {
    if (!process.env.SEED_STARTUP_CATALOG_KEY || seedKey !== process.env.SEED_STARTUP_CATALOG_KEY) {
      throw new HttpsError(
        "permission-denied",
        "Seed bloqueado fora do emulator sem seedKey valido.",
      );
    }
  }

  // Executa o seed e retorna quantos registros foram processados e quais IDs foram usados.
  const startupIds = await seedDemoStartups();

  return {
    data: {
      count: startupIds.length,
      ids: startupIds,
    },
  };
});
