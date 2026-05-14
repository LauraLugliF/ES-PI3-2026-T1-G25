"use strict";
// Max Thomazini Barbosa RA:25003934
// Repositório para gerenciar o portfólio (tokens) do usuário
Object.defineProperty(exports, "__esModule", { value: true });
exports.obterPortfolio = obterPortfolio;
exports.obterPortfoliosDoUsuario = obterPortfoliosDoUsuario;
exports.adicionarTokensAoPortfolio = adicionarTokensAoPortfolio;
exports.removerTokensDoPortfolio = removerTokensDoPortfolio;
const firebase_1 = require("../../startups/shared/firebase");
// Obter portfólio específico do usuário para uma startup
async function obterPortfolio(userId, startupId) {
    if (!userId || !startupId) {
        throw new Error("userId e startupId são obrigatórios");
    }
    try {
        const snap = await firebase_1.db
            .collection("portfolios")
            .where("userId", "==", userId)
            .where("startupId", "==", startupId)
            .limit(1)
            .get();
        if (snap.empty) {
            return null;
        }
        const doc = snap.docs[0];
        return Object.assign({ id: doc.id }, doc.data());
    }
    catch (erro) {
        throw new Error(`Erro ao obter portfólio: ${erro}`);
    }
}
// Obter todos os portfólios de um usuário
async function obterPortfoliosDoUsuario(userId) {
    if (!userId) {
        throw new Error("userId é obrigatório");
    }
    try {
        const snap = await firebase_1.db
            .collection("portfolios")
            .where("userId", "==", userId)
            .get();
        return snap.docs.map((doc) => (Object.assign({ id: doc.id }, doc.data())));
    }
    catch (erro) {
        throw new Error(`Erro ao obter portfólios: ${erro}`);
    }
}
// Adicionar/atualizar portfólio após compra
async function adicionarTokensAoPortfolio(userId, startupId, quantidade, precoUnitario) {
    if (!userId || !startupId) {
        throw new Error("userId e startupId são obrigatórios");
    }
    if (quantidade <= 0 || precoUnitario < 0) {
        throw new Error("quantidade deve ser positiva e precoUnitario não-negativo");
    }
    try {
        const portfolioExistente = await obterPortfolio(userId, startupId);
        const agora = new Date();
        if (portfolioExistente) {
            // Atualizar portfólio existente - recalcular preço médio
            const quantidadeTotal = portfolioExistente.quantidade + quantidade;
            const valorTotal = portfolioExistente.quantidade * portfolioExistente.precoMedioCompra +
                quantidade * precoUnitario;
            const novoPrecoMedio = valorTotal / quantidadeTotal;
            if (portfolioExistente.id) {
                const docRef = firebase_1.db.collection("portfolios").doc(portfolioExistente.id);
                await docRef.update({
                    quantidade: quantidadeTotal,
                    precoMedioCompra: novoPrecoMedio,
                    atualizadoEm: agora,
                });
            }
            return Object.assign(Object.assign({}, portfolioExistente), { quantidade: quantidadeTotal, precoMedioCompra: novoPrecoMedio, atualizadoEm: agora });
        }
        else {
            // Criar novo portfólio
            const docRef = firebase_1.db.collection("portfolios").doc();
            const novoPortfolio = {
                id: docRef.id,
                userId,
                startupId,
                quantidade,
                precoMedioCompra: precoUnitario,
                dataCompra: agora,
                atualizadoEm: agora,
            };
            await docRef.set(novoPortfolio);
            return novoPortfolio;
        }
    }
    catch (erro) {
        throw new Error(`Erro ao adicionar tokens: ${erro}`);
    }
}
// Remover tokens do portfólio (venda)
async function removerTokensDoPortfolio(userId, startupId, quantidade) {
    if (!userId || !startupId) {
        throw new Error("userId e startupId são obrigatórios");
    }
    if (quantidade <= 0) {
        throw new Error("quantidade deve ser positiva");
    }
    try {
        const portfolioExistente = await obterPortfolio(userId, startupId);
        if (!portfolioExistente) {
            throw new Error("Portfólio não encontrado");
        }
        if (portfolioExistente.quantidade < quantidade) {
            throw new Error("Quantidade insuficiente de tokens para venda");
        }
        const novaQuantidade = portfolioExistente.quantidade - quantidade;
        const agora = new Date();
        if (novaQuantidade === 0) {
            // Deletar portfólio se quantidade chegar a 0
            if (portfolioExistente.id) {
                await firebase_1.db.collection("portfolios").doc(portfolioExistente.id).delete();
            }
            return null;
        }
        // Atualizar portfólio com nova quantidade
        if (portfolioExistente.id) {
            const docRef = firebase_1.db.collection("portfolios").doc(portfolioExistente.id);
            await docRef.update({
                quantidade: novaQuantidade,
                atualizadoEm: agora,
            });
        }
        return Object.assign(Object.assign({}, portfolioExistente), { quantidade: novaQuantidade, atualizadoEm: agora });
    }
    catch (erro) {
        throw new Error(`Erro ao remover tokens: ${erro}`);
    }
}
//# sourceMappingURL=portfolioRepository.js.map