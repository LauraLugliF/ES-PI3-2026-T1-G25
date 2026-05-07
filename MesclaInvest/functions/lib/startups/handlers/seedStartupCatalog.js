"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.seedStartupCatalog = void 0;
const https_1 = require("firebase-functions/https");
const startupRepository_1 = require("../repositories/startupRepository");
const validation_1 = require("../shared/validation");
// Callable responsável por popular o catálogo de startups de demonstração.
exports.seedStartupCatalog = (0, https_1.onCall)(async (request) => {
    var _a;
    // Normaliza a chave recebida para evitar falhas com espaços extras ou valores vazios.
    const seedKey = (0, validation_1.normalizeString)((_a = request.data) === null || _a === void 0 ? void 0 : _a.seedKey);
    // Fora do emulator, exige uma chave válida para impedir uso indevido do seed.
    if (!process.env.FUNCTIONS_EMULATOR) {
        if (!process.env.SEED_STARTUP_CATALOG_KEY || seedKey !== process.env.SEED_STARTUP_CATALOG_KEY) {
            throw new https_1.HttpsError("permission-denied", "Seed bloqueado fora do emulator sem seedKey valido.");
        }
    }
    // Executa o seed e retorna quantos registros foram processados e quais IDs foram usados.
    const startupIds = await (0, startupRepository_1.seedDemoStartups)();
    return {
        data: {
            count: startupIds.length,
            ids: startupIds,
        },
    };
});
//# sourceMappingURL=seedStartupCatalog.js.map