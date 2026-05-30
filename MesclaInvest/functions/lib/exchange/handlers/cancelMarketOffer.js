"use strict";
// LUCAS RODRIGUES XAVIER - 25000508
// Handler para cancelar uma oferta própria no mercado P2P
// Devolve os tokens ao portfólio do vendedor e marca a oferta como cancelada.
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
exports.cancelMarketOfferHandler = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("../../startups/shared/firebase");
const portfolioRepository_1 = require("../repositories/portfolioRepository");
exports.cancelMarketOfferHandler = (0, https_1.onRequest)({ region: "southamerica-east1", invoker: "public" }, async (request, response) => {
    var _a, _b;
    try {
        const userId = ((_a = request.body) === null || _a === void 0 ? void 0 : _a.userId) || "";
        const offerId = ((_b = request.body) === null || _b === void 0 ? void 0 : _b.offerId) || "";
        // Valida campos obrigatórios
        if (!userId || !offerId) {
            response.status(400).send("userId e offerId são obrigatórios.");
            return;
        }
        // Carrega a oferta
        const ofertaRef = firebase_1.db.collection("marketOffers").doc(offerId);
        const ofertaSnap = await ofertaRef.get();
        if (!ofertaSnap.exists) {
            response.status(404).send("Oferta não encontrada.");
            return;
        }
        const oferta = ofertaSnap.data();
        // Verifica se a oferta pertence ao usuário solicitante
        if (oferta.sellerId !== userId) {
            response.status(403).send("Você não tem permissão para cancelar esta oferta.");
            return;
        }
        // Verifica se a oferta ainda está aberta
        if (oferta.status !== "open") {
            response.status(400).send("Esta oferta não pode ser cancelada pois já foi encerrada.");
            return;
        }
        // Marca a oferta como cancelada
        await ofertaRef.update({
            status: "cancelled",
            atualizadaEm: firestore_1.FieldValue.serverTimestamp(),
        });
        // Devolve os tokens ao portfólio do vendedor
        const precoPorTokenReais = oferta.precoPorTokenCents / 100;
        await (0, portfolioRepository_1.adicionarTokensAoPortfolio)(userId, oferta.startupId, oferta.quantidade, precoPorTokenReais);
        response.status(200).send({
            sucesso: true,
            mensagem: `Oferta cancelada. ${oferta.quantidade} token(s) devolvidos à sua carteira.`,
            ofertaId: offerId,
        });
    }
    catch (error) {
        logger.error("Erro ao cancelar oferta de mercado.", error);
        response.status(500).send("Erro interno ao cancelar oferta.");
    }
});
//# sourceMappingURL=cancelMarketOffer.js.map