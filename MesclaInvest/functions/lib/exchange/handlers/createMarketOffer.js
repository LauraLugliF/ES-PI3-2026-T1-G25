"use strict";
// LUCAS RODRIGUES XAVIER - 25000508
// Handler para criar uma oferta de venda no mercado P2P
// Ao chamar, os tokens são reservados (saem da carteira) e a oferta fica visível para outros usuários.
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
exports.createMarketOfferHandler = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("../../startups/shared/firebase");
const portfolioRepository_1 = require("../repositories/portfolioRepository");
const userRepository_1 = require("../repositories/userRepository");
exports.createMarketOfferHandler = (0, https_1.onRequest)({ region: "southamerica-east1", invoker: "public" }, async (request, response) => {
    var _a, _b, _c, _d, _e, _f;
    try {
        const sellerId = ((_a = request.body) === null || _a === void 0 ? void 0 : _a.sellerId) || "";
        const sellerEmail = ((_b = request.body) === null || _b === void 0 ? void 0 : _b.sellerEmail) || "";
        const startupId = ((_c = request.body) === null || _c === void 0 ? void 0 : _c.startupId) || "";
        const quantidade = ((_d = request.body) === null || _d === void 0 ? void 0 : _d.quantidade) || 0;
        const precoPorToken = ((_e = request.body) === null || _e === void 0 ? void 0 : _e.precoPorToken) || 0;
        // Recupera o tipo de oferta (compra 'buy' ou venda 'sell'). Caso omitido, assume 'sell' por retrocompatibilidade.
        const type = ((_f = request.body) === null || _f === void 0 ? void 0 : _f.type) || "sell";
        // Valida campos obrigatórios
        if (!sellerId || !startupId || quantidade <= 0 || precoPorToken <= 0) {
            response.status(400).send("sellerId, startupId, quantidade e precoPorToken são obrigatórios e devem ser positivos.");
            return;
        }
        const precoPorTokenCents = Math.round(precoPorToken * 100);
        const precoTotalCents = precoPorTokenCents * quantidade;
        // Se for uma oferta de COMPRA P2P (buy)
        if (type === "buy") {
            // Valida se o comprador possui saldo em dinheiro suficiente na carteira
            const saldoDisponivel = await (0, userRepository_1.getUserBalance)(sellerId);
            if (saldoDisponivel === null || saldoDisponivel < precoTotalCents) {
                response.status(400).send(`Você possui saldo insuficiente para criar esta oferta de compra. Necessário: R$ ${(precoTotalCents / 100).toFixed(2)}.`);
                return;
            }
            // Reserva o dinheiro deduzindo do saldo do comprador imediatamente no momento da criação
            await (0, userRepository_1.deduzirSaldoUsuario)(sellerId, precoTotalCents);
            // Cria a oferta de compra com status "open" e tipo "buy" no Firestore
            const ofertaRef = firebase_1.db.collection("marketOffers").doc();
            await ofertaRef.set({
                sellerId,
                sellerEmail,
                startupId,
                quantidade,
                precoPorTokenCents,
                status: "open",
                type: "buy",
                criadaEm: firestore_1.FieldValue.serverTimestamp(),
                atualizadaEm: firestore_1.FieldValue.serverTimestamp(),
            });
            response.status(200).send({
                sucesso: true,
                mensagem: "Oferta de compra criada com sucesso. Seu saldo foi reservado e a oferta está visível no mercado.",
                ofertaId: ofertaRef.id,
            });
        }
        else {
            // Se for uma oferta de VENDA P2P (sell)
            // Verifica se o usuário possui de fato os tokens suficientes no portfólio para vender
            const portfolio = await (0, portfolioRepository_1.obterPortfolio)(sellerId, startupId);
            if (!portfolio) {
                response.status(404).send("Você não possui tokens desta startup.");
                return;
            }
            if (portfolio.quantidade < quantidade) {
                response.status(400).send(`Você possui apenas ${portfolio.quantidade} token(s), mas tentou ofertar ${quantidade}.`);
                return;
            }
            // Remove os tokens do portfólio imediatamente (ficam reservados na oferta do mercado)
            await (0, portfolioRepository_1.removerTokensDoPortfolio)(sellerId, startupId, quantidade);
            // Cria a oferta de venda com status "open" e tipo "sell" no Firestore
            const ofertaRef = firebase_1.db.collection("marketOffers").doc();
            await ofertaRef.set({
                sellerId,
                sellerEmail,
                startupId,
                quantidade,
                precoPorTokenCents,
                status: "open",
                type: "sell",
                criadaEm: firestore_1.FieldValue.serverTimestamp(),
                atualizadaEm: firestore_1.FieldValue.serverTimestamp(),
            });
            response.status(200).send({
                sucesso: true,
                mensagem: "Oferta criada com sucesso. Seus tokens estão reservados e visíveis no mercado.",
                ofertaId: ofertaRef.id,
            });
        }
    }
    catch (error) {
        logger.error("Erro ao criar oferta de mercado.", error);
        response.status(500).send("Erro interno ao criar oferta.");
    }
});
//# sourceMappingURL=createMarketOffer.js.map