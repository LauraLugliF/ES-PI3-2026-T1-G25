"use strict";
// LUCAS RODRIGUES XAVIER - 25000508
// Handler para listar as ofertas abertas no mercado P2P
// Retorna todas as ofertas com status "open", opcionalmente filtradas por startup.
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.listMarketOffersHandler = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const firebase_1 = require("../../startups/shared/firebase");
exports.listMarketOffersHandler = (0, https_1.onRequest)({ region: "southamerica-east1", invoker: "public" }, async (request, response) => {
    var _a;
    try {
        const startupId = ((_a = request.body) === null || _a === void 0 ? void 0 : _a.startupId) || "";
        // Monta a query base: apenas ofertas abertas
        // Alterado: Removido orderBy para evitar exigência de índice composto em construção
        let query = firebase_1.db
            .collection("marketOffers")
            .where("status", "==", "open");
        // Filtra por startup se informada
        if (startupId) {
            // Alterado: Removido orderBy para evitar exigência de índice composto em construção
            query = firebase_1.db
                .collection("marketOffers")
                .where("status", "==", "open")
                .where("startupId", "==", startupId);
        }
        const snapshot = await query.get();
        const ofertas = snapshot.docs.map((doc) => (Object.assign({ id: doc.id }, doc.data())));
        // Alterado: Adicionada ordenação em memória para ordenar por preço sem depender do índice composto
        ofertas.sort((a, b) => a.precoPorTokenCents - b.precoPorTokenCents);
        response.status(200).send({
            sucesso: true,
            ofertas,
        });
    }
    catch (error) {
        logger.error("Erro ao listar ofertas de mercado.", error);
        response.status(500).send("Erro interno ao listar ofertas.");
    }
});
//# sourceMappingURL=listMarketOffers.js.map