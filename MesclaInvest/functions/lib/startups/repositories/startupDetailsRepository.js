"use strict";
// Laura Lugli Fonseca Pereira RA: 25000739
// Repositório responsável pelas consultas da tela de detalhes da startup
Object.defineProperty(exports, "__esModule", { value: true });
exports.listStartupItems = listStartupItems;
exports.getStartupById = getStartupById;
exports.userIsInvestor = userIsInvestor;
exports.listPublicQuestions = listPublicQuestions;
exports.createQuestion = createQuestion;
const firebase_1 = require("../shared/firebase");
// Reutiliza a collection de startups do Firestore
const startupsCollection = firebase_1.db.collection("startups");
// Converte documento completo em versão resumida para listagem
function toListItem(id, startup) {
    var _a;
    // Retorna apenas os campos necessários para a tela de catálogo
    return {
        id,
        name: startup.name,
        stage: startup.stage,
        shortDescription: startup.shortDescription,
        capitalRaisedCents: startup.capitalRaisedCents,
        totalTokensIssued: startup.totalTokensIssued,
        currentTokenPriceCents: startup.currentTokenPriceCents,
        coverImageUrl: startup.coverImageUrl,
        tags: startup.tags,
        priceHistory: (_a = startup.priceHistory) !== null && _a !== void 0 ? _a : undefined,
    };
}
// Retorna lista resumida de todas as startups para a tela de catálogo
async function listStartupItems() {
    // Busca até 100 startups no Firestore
    const snapshot = await startupsCollection.limit(100).get();
    // Converte cada documento para o formato resumido
    return snapshot.docs.map((doc) => toListItem(doc.id, doc.data()));
}
// Busca o documento completo de uma startup pelo ID
async function getStartupById(startupId) {
    // Busca o documento da startup pelo ID informado
    const snapshot = await startupsCollection.doc(startupId).get();
    // Retorna undefined se a startup não existir
    if (!snapshot.exists) {
        return undefined;
    }
    // Retorna os dados da startup encontrada
    return snapshot.data();
}
// Verifica se o usuário autenticado é investidor da startup informada
async function userIsInvestor(startupId, uid) {
    // Busca o documento do investidor na subcoleção investors
    const investorSnapshot = await startupsCollection
        .doc(startupId)
        .collection("investors")
        .doc(uid)
        .get();
    // Retorna true se o documento existir, false caso contrário
    return investorSnapshot.exists;
}
// Retorna as perguntas públicas da startup ordenadas pela mais recente
async function listPublicQuestions(startupId) {
    // Busca até 50 perguntas públicas na subcoleção questions
    const questionsSnapshot = await startupsCollection
        .doc(startupId)
        .collection("questions")
        .where("visibility", "==", "publica")
        .limit(50)
        .get();
    // Mapeia os documentos para o formato esperado pelo app
    return questionsSnapshot.docs
        .map((doc) => {
        var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l;
        return ({
            id: doc.id,
            text: doc.get("text"),
            answer: (_a = doc.get("answer")) !== null && _a !== void 0 ? _a : null,
            answeredAt: (_f = (_e = (_d = (_c = (_b = doc.get("answeredAt")) === null || _b === void 0 ? void 0 : _b.toDate) === null || _c === void 0 ? void 0 : _c.call(_b)) === null || _d === void 0 ? void 0 : _d.toISOString) === null || _e === void 0 ? void 0 : _e.call(_d)) !== null && _f !== void 0 ? _f : null,
            createdAt: (_l = (_k = (_j = (_h = (_g = doc.get("createdAt")) === null || _g === void 0 ? void 0 : _g.toDate) === null || _h === void 0 ? void 0 : _h.call(_g)) === null || _j === void 0 ? void 0 : _j.toISOString) === null || _k === void 0 ? void 0 : _k.call(_j)) !== null && _l !== void 0 ? _l : null,
        });
    })
        // Ordena pela mais recente primeiro
        .sort((left, right) => { var _a, _b; return String((_a = right.createdAt) !== null && _a !== void 0 ? _a : "").localeCompare(String((_b = left.createdAt) !== null && _b !== void 0 ? _b : "")); });
}
// Salva uma nova pergunta na subcoleção de perguntas da startup
async function createQuestion(startupId, question) {
    // Adiciona a pergunta na subcoleção questions da startup
    const questionRef = await startupsCollection
        .doc(startupId)
        .collection("questions")
        .add(question);
    // Retorna o ID gerado para a pergunta
    return questionRef.id;
}
//# sourceMappingURL=startupDetailsRepository.js.map