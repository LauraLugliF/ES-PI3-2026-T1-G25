"use strict";
// Max Thomazini Barbosa RA:25003934
// Handler para venda de tokens
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
exports.sellTokensHandler = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const userRepository_1 = require("../repositories/userRepository");
const startupRepository_1 = require("../repositories/startupRepository");
const portfolioRepository_1 = require("../repositories/portfolioRepository");
const transactionRepository_1 = require("../repositories/transactionRepository");
const startupRepository_2 = require("../../startups/repositories/startupRepository");
exports.sellTokensHandler = (0, https_1.onRequest)({ region: "southamerica-east1", invoker: "public" }, async (request, response) => {
    var _a, _b, _c, _d;
    try {
        const userId = ((_a = request.body) === null || _a === void 0 ? void 0 : _a.userId) || "";
        const startupId = ((_b = request.body) === null || _b === void 0 ? void 0 : _b.startupId) || "";
        const quantidade = ((_c = request.body) === null || _c === void 0 ? void 0 : _c.quantidade) || 0;
        const precoUnitario = ((_d = request.body) === null || _d === void 0 ? void 0 : _d.precoUnitario) || 0;
        // Validações básicas
        if (!userId || !startupId || quantidade === undefined || precoUnitario === undefined) {
            response.status(400).send("userId, startupId, quantidade e precoUnitario são obrigatórios");
            return;
        }
        if (typeof quantidade !== "number" || typeof precoUnitario !== "number") {
            response.status(400).send("quantidade e precoUnitario devem ser números");
            return;
        }
        if (quantidade <= 0 || precoUnitario < 0) {
            response.status(400).send("quantidade deve ser positiva e precoUnitario não-negativo");
            return;
        }
        // Verificar se a startup existe
        const startup = await (0, startupRepository_1.obterStartup)(startupId);
        if (!startup) {
            response.status(404).send("Startup não encontrada");
            return;
        }
        // Verificar se o usuário possui portfólio nessa startup
        const portfolio = await (0, portfolioRepository_1.obterPortfolio)(userId, startupId);
        if (!portfolio) {
            response.status(404).send("Você não possui tokens dessa startup");
            return;
        }
        // Verificar se o usuário possui quantidade suficiente de tokens
        if (portfolio.quantidade < quantidade) {
            response.status(400).send(`Você possui apenas ${portfolio.quantidade} tokens, mas está tentando vender ${quantidade}`);
            return;
        }
        // Calcular o valor total em centavos para saldo e capital da startup.
        const precoTotalCents = Math.floor(quantidade * precoUnitario * 100);
        // Remover tokens do portfólio
        const novoPortfolio = await (0, portfolioRepository_1.removerTokensDoPortfolio)(userId, startupId, quantidade);
        const startupAtualizada = await (0, startupRepository_2.atualizarStartupAposVenda)(startupId, quantidade, precoTotalCents);
        // Adicionar saldo ao usuário
        await (0, userRepository_1.adicionarDeposito)(userId, precoTotalCents);
        // Registrar a transação
        const transacao = await (0, transactionRepository_1.criarTransacao)("venda", userId, startupId, quantidade, precoUnitario);
        response.status(200).send({
            sucesso: true,
            mensagem: "Venda realizada com sucesso",
            portfolio: novoPortfolio,
            startup: startupAtualizada,
            transacao,
        });
    }
    catch (error) {
        logger.error("Erro ao realizar venda de tokens.", error);
        response.status(500).send("Erro interno ao realizar venda.");
    }
});
//# sourceMappingURL=sellTokens.js.map