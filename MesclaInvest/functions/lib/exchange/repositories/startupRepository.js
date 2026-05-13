"use strict";
// Max Thomazini Barbosa RA:25003934
// Repositório para acessar dados de startups (leitura)
Object.defineProperty(exports, "__esModule", { value: true });
exports.obterStartup = obterStartup;
exports.obterTodasAsStartups = obterTodasAsStartups;
exports.startupExiste = startupExiste;
exports.obterPrecoTokenStartup = obterPrecoTokenStartup;
const firebase_1 = require("../../startups/shared/firebase");
// Obter dados de uma startup específica
async function obterStartup(startupId) {
    if (!startupId) {
        throw new Error("startupId é obrigatório");
    }
    try {
        const docRef = firebase_1.db.collection("startups").doc(startupId);
        const snap = await docRef.get();
        if (!snap.exists) {
            return null;
        }
        return snap.data();
    }
    catch (erro) {
        throw new Error(`Erro ao obter startup: ${erro}`);
    }
}
// Obter todas as startups
async function obterTodasAsStartups() {
    try {
        const snap = await firebase_1.db.collection("startups").get();
        return snap.docs.map((doc) => doc.data());
    }
    catch (erro) {
        throw new Error(`Erro ao obter startups: ${erro}`);
    }
}
// Verificar se uma startup existe
async function startupExiste(startupId) {
    try {
        const startup = await obterStartup(startupId);
        return startup !== null;
    }
    catch (_a) {
        return false;
    }
}
// Obter preço atual de um token de uma startup
async function obterPrecoTokenStartup(startupId) {
    try {
        const startup = await obterStartup(startupId);
        if (!startup) {
            return null;
        }
        return startup.currentTokenPriceCents || null;
    }
    catch (_a) {
        return null;
    }
}
//# sourceMappingURL=startupRepository.js.map