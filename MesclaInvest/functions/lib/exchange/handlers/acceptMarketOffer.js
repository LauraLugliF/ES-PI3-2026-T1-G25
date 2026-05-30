"use strict";
// LUCAS RODRIGUES XAVIER - 25000508
// Handler para aceitar uma oferta do mercado P2P (comprador)
// Executa em transação atômica: debita comprador, credita vendedor, transfere tokens, atualiza preço.
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
exports.acceptMarketOfferHandler = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("../../startups/shared/firebase");
const userRepository_1 = require("../repositories/userRepository");
const portfolioRepository_1 = require("../repositories/portfolioRepository");
const startupRepository_1 = require("../../startups/repositories/startupRepository");
exports.acceptMarketOfferHandler = (0, https_1.onRequest)({ region: "southamerica-east1", invoker: "public" }, async (request, response) => {
    var _a, _b;
    try {
        const buyerId = ((_a = request.body) === null || _a === void 0 ? void 0 : _a.buyerId) || "";
        const offerId = ((_b = request.body) === null || _b === void 0 ? void 0 : _b.offerId) || "";
        // Valida campos obrigatórios
        if (!buyerId || !offerId) {
            response.status(400).send("buyerId e offerId são obrigatórios.");
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
        // Verifica se a oferta ainda está aberta
        if (oferta.status !== "open") {
            response.status(400).send("Esta oferta já foi encerrada ou cancelada.");
            return;
        }
        // Comprador não pode comprar a própria oferta
        if (oferta.sellerId === buyerId) {
            response.status(400).send("Você não pode comprar sua própria oferta.");
            return;
        }
        const precoTotalCents = oferta.precoPorTokenCents * oferta.quantidade;
        // Verifica saldo do comprador
        const saldoComprador = await (0, userRepository_1.getUserBalance)(buyerId);
        if (saldoComprador === null || saldoComprador < precoTotalCents) {
            response.status(400).send("Saldo insuficiente para comprar esta oferta.");
            return;
        }
        // Executa a transação atômica no Firestore
        await firebase_1.db.runTransaction(async (tx) => {
            // Marca oferta como preenchida
            tx.update(ofertaRef, {
                status: "filled",
                atualizadaEm: firestore_1.FieldValue.serverTimestamp(),
            });
        });
        // Debita saldo do comprador
        await (0, userRepository_1.deduzirSaldoUsuario)(buyerId, precoTotalCents);
        // Credita saldo do vendedor
        await (0, userRepository_1.adicionarDeposito)(oferta.sellerId, precoTotalCents);
        // Adiciona tokens ao portfólio do comprador
        const precoPorTokenReais = oferta.precoPorTokenCents / 100;
        await (0, portfolioRepository_1.adicionarTokensAoPortfolio)(buyerId, oferta.startupId, oferta.quantidade, precoPorTokenReais);
        // Impacta o preço do token (pressão de compra — preço sobe)
        await (0, startupRepository_1.atualizarStartupAposCompra)(oferta.startupId, oferta.quantidade, precoTotalCents);
        response.status(200).send({
            sucesso: true,
            mensagem: `Compra realizada! Você adquiriu ${oferta.quantidade} token(s) de ${oferta.startupId}.`,
            ofertaId: offerId,
            quantidade: oferta.quantidade,
            totalPagoCents: precoTotalCents,
        });
    }
    catch (error) {
        logger.error("Erro ao aceitar oferta de mercado.", error);
        response.status(500).send("Erro interno ao aceitar oferta.");
    }
});
//# sourceMappingURL=acceptMarketOffer.js.map