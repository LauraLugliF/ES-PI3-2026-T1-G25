"use strict";
// Max Thomazini Barbosa RA:25003934
// Repositório para gerenciar transações de compra/venda
Object.defineProperty(exports, "__esModule", { value: true });
exports.criarTransacao = criarTransacao;
exports.obterTransacoesDoUsuario = obterTransacoesDoUsuario;
exports.obterTransacoesDoUsuarioPorStartup = obterTransacoesDoUsuarioPorStartup;
exports.obterTransacoesPorTipo = obterTransacoesPorTipo;
const firebase_1 = require("../../startups/shared/firebase");
// Criar uma nova transação de compra/venda
async function criarTransacao(tipo, userId, startupId, quantidade, precoUnitario) {
    if (!["compra", "venda"].includes(tipo)) {
        throw new Error("Tipo deve ser 'compra' ou 'venda'");
    }
    if (!userId || !startupId) {
        throw new Error("userId e startupId são obrigatórios");
    }
    if (quantidade <= 0 || precoUnitario < 0) {
        throw new Error("quantidade deve ser positiva e precoUnitario não-negativo");
    }
    try {
        const precoTotal = quantidade * precoUnitario;
        const agora = new Date();
        const novaTransacao = {
            tipo,
            userId,
            startupId,
            quantidade,
            precoUnitario,
            precoTotal,
            dataTrasacao: agora,
        };
        const docRef = firebase_1.db.collection("transactions").doc();
        await docRef.set(novaTransacao);
        return Object.assign({ id: docRef.id }, novaTransacao);
    }
    catch (erro) {
        throw new Error(`Erro ao criar transação: ${erro}`);
    }
}
// Obter todas as transações de um usuário
async function obterTransacoesDoUsuario(userId) {
    if (!userId) {
        throw new Error("userId é obrigatório");
    }
    try {
        const snap = await firebase_1.db
            .collection("transactions")
            .where("userId", "==", userId)
            .orderBy("dataTrasacao", "desc")
            .get();
        return snap.docs.map((doc) => (Object.assign({ id: doc.id }, doc.data())));
    }
    catch (erro) {
        throw new Error(`Erro ao obter transações: ${erro}`);
    }
}
// Obter transações de um usuário para uma startup específica
async function obterTransacoesDoUsuarioPorStartup(userId, startupId) {
    if (!userId || !startupId) {
        throw new Error("userId e startupId são obrigatórios");
    }
    try {
        const snap = await firebase_1.db
            .collection("transactions")
            .where("userId", "==", userId)
            .where("startupId", "==", startupId)
            .orderBy("dataTrasacao", "desc")
            .get();
        return snap.docs.map((doc) => (Object.assign({ id: doc.id }, doc.data())));
    }
    catch (erro) {
        throw new Error(`Erro ao obter transações: ${erro}`);
    }
}
// Obter histórico de compras/vendas
async function obterTransacoesPorTipo(userId, tipo) {
    if (!userId) {
        throw new Error("userId é obrigatório");
    }
    if (!["compra", "venda"].includes(tipo)) {
        throw new Error("Tipo deve ser 'compra' ou 'venda'");
    }
    try {
        const snap = await firebase_1.db
            .collection("transactions")
            .where("userId", "==", userId)
            .where("tipo", "==", tipo)
            .orderBy("dataTrasacao", "desc")
            .get();
        return snap.docs.map((doc) => (Object.assign({ id: doc.id }, doc.data())));
    }
    catch (erro) {
        throw new Error(`Erro ao obter transações: ${erro}`);
    }
}
//# sourceMappingURL=transactionRepository.js.map