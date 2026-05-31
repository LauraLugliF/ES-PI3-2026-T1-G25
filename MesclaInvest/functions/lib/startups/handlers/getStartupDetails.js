"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getStartupDetails = void 0;
// Laura Lugli Fonseca Pereira RA: 25000739
// Handler que retorna os dados completos da tela de detalhes de uma startup
const https_1 = require("firebase-functions/https");
const auth_1 = require("../shared/auth");
const validation_1 = require("../shared/validation");
const startupDetailsRepository_1 = require("../repositories/startupDetailsRepository");
// Busca os dados completos de uma startup específica
// Chamada pelo app com `id` da startup
// Retorna sumário, sócios, conselho, vídeos, perguntas públicas,
// perguntas privadas do investidor e flags de acesso
exports.getStartupDetails = (0, https_1.onCall)(async (request) => {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j;
    // Verifica se o usuário está autenticado
    const user = (0, auth_1.requireAuthenticatedUser)(request);
    // Normaliza o ID recebido removendo espaços extras
    const startupId = (0, validation_1.normalizeString)((_a = request.data) === null || _a === void 0 ? void 0 : _a.id);
    // Valida se o ID foi enviado corretamente
    if (!startupId) {
        throw new https_1.HttpsError("invalid-argument", "Informe o parametro id da startup.");
    }
    // Busca o documento principal da startup no Firestore
    const startup = await (0, startupDetailsRepository_1.getStartupById)(startupId);
    // Retorna erro 404 se a startup não existir
    if (!startup) {
        throw new https_1.HttpsError("not-found", "Startup nao encontrada.");
    }
    // Verifica se o usuário autenticado é investidor desta startup
    const isInvestor = await (0, startupDetailsRepository_1.userIsInvestor)(startupId, user.uid);
    // Busca as perguntas públicas da subcoleção de perguntas
    const publicQuestions = await (0, startupDetailsRepository_1.listPublicQuestions)(startupId);
    // Busca o histórico de preço para o gráfico da tela de detalhes
    const priceHistory = await (0, startupDetailsRepository_1.listPriceHistory)(startupId);
    // Busca as perguntas privadas apenas se o usuário for investidor
    // Somente o próprio investidor vê suas perguntas privadas
    const privateQuestions = isInvestor ?
        await (0, startupDetailsRepository_1.listPrivateQuestions)(startupId, user.uid) :
        [];
    // Retorna todos os dados da tela de detalhe para o app Flutter
    return {
        data: {
            // Identificador da startup
            id: startupId,
            // Dados gerais exibidos na listagem e no detalhe
            name: startup.name,
            stage: startup.stage,
            shortDescription: startup.shortDescription,
            description: startup.description,
            coverImageUrl: (_b = startup.coverImageUrl) !== null && _b !== void 0 ? _b : null,
            tags: startup.tags,
            // Sumário executivo da startup
            executiveSummary: startup.executiveSummary,
            // Métricas financeiras e de tokens
            capitalRaisedCents: startup.capitalRaisedCents,
            totalTokensIssued: startup.totalTokensIssued,
            currentTokenPriceCents: startup.currentTokenPriceCents,
            // Estrutura societária — sócios e fundadores
            founders: startup.founders,
            // Conselho e mentores — só retorna se houver dados
            externalMembers: startup.externalMembers.length > 0 ?
                startup.externalMembers :
                [],
            // Vídeos demonstrativos — só retorna se houver dados
            demoVideos: startup.demoVideos.length > 0 ?
                startup.demoVideos :
                [],
            // URL do plano de negócios em PDF
            pitchDeckUrl: (_c = startup.pitchDeckUrl) !== null && _c !== void 0 ? _c : null,
            // Perguntas e respostas públicas
            publicQuestions,
            // Histórico de preço para o gráfico de desempenho
            priceHistory: priceHistory.length > 0 ? priceHistory : [
                {
                    id: "seed-fallback",
                    priceCents: startup.currentTokenPriceCents,
                    changeType: "seed",
                    quantity: 0,
                    createdAt: (_e = (_d = startup.createdAt) === null || _d === void 0 ? void 0 : _d.toDate().toISOString()) !== null && _e !== void 0 ? _e : null,
                },
            ],
            // Perguntas privadas do investidor logado — vazio para não investidores
            privateQuestions,
            // Timestamps convertidos para ISO string
            createdAt: (_g = (_f = startup.createdAt) === null || _f === void 0 ? void 0 : _f.toDate().toISOString()) !== null && _g !== void 0 ? _g : null,
            updatedAt: (_j = (_h = startup.updatedAt) === null || _h === void 0 ? void 0 : _h.toDate().toISOString()) !== null && _j !== void 0 ? _j : null,
            // Flags de acesso exclusivas para investidores
            access: {
                isInvestor,
                canTradeTokens: isInvestor,
                canSendPrivateQuestions: isInvestor,
            },
        },
    };
});
//# sourceMappingURL=getStartupDetails.js.map