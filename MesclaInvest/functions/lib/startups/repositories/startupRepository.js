"use strict";
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.seedDemoStartups = seedDemoStartups;
exports.atualizarStartupAposCompra = atualizarStartupAposCompra;
exports.atualizarStartupAposVenda = atualizarStartupAposVenda;
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("../shared/firebase");
// Reutiliza a collection de startups do Firestore em toda a rotina de seed.
const startupsCollection = firebase_1.db.collection("startups");
// Percentual de impacto por token negociado sobre o preço atual.
const tokenPriceImpactPercent = 0.0005;
// Dados de demonstração usados para popular o ambiente com registros iniciais.
const demoStartups = [
    {
        id: "biochip-campus",
        name: "BioChip Campus",
        stage: "nova",
        shortDescription: "Sensores portateis para analises laboratoriais didaticas.",
        description: "A BioChip Campus simula kits de diagnostico rapido para laboratorios universitarios, conectando sensores de baixo custo a um aplicativo de acompanhamento.",
        executiveSummary: "Startup em fase de ideacao com foco em prototipagem de sensores educacionais e validacao com cursos da area de saude.",
        capitalRaisedCents: 1850000,
        totalTokensIssued: 100000,
        currentTokenPriceCents: 125,
        founders: [
            {
                name: "Ana Ribeiro",
                role: "CEO",
                equityPercent: 48,
                bio: "Responsavel por estrategia e parcerias academicas.",
            },
            {
                name: "Lucas Moreira",
                role: "CTO",
                equityPercent: 37,
                bio: "Responsavel por hardware e integracao mobile.",
            },
            { name: "Mescla Labs", role: "Reserva estrategica", equityPercent: 15 },
        ],
        externalMembers: [
            {
                name: "Dra. Helena Costa",
                role: "Mentora",
                organization: "PUC-Campinas",
            },
        ],
        demoVideos: ["https://example.com/videos/biochip-campus-demo"],
        pitchDeckUrl: "https://example.com/decks/biochip-campus.pdf",
        coverImageUrl: "https://images.unsplash.com/photo-1581093458791-9015482442f6",
        tags: ["healthtech", "iot", "educacao"],
    },
    {
        id: "rota-verde",
        name: "Rota Verde",
        stage: "em_operacao",
        shortDescription: "Otimizacao de rotas sustentaveis para entregas urbanas.",
        description: "A Rota Verde usa dados de distancia, emissao estimada e ocupacao de entregadores para sugerir rotas urbanas com menor impacto ambiental.",
        executiveSummary: "Startup em operacao piloto com pequenos comercios locais e validacao de indicadores de economia de combustivel.",
        capitalRaisedCents: 7400000,
        totalTokensIssued: 250000,
        currentTokenPriceCents: 310,
        founders: [
            { name: "Beatriz Santos", role: "CEO", equityPercent: 42 },
            { name: "Rafael Almeida", role: "COO", equityPercent: 28 },
            { name: "Carla Nogueira", role: "CTO", equityPercent: 20 },
            { name: "Reserva de incentivos", role: "Pool", equityPercent: 10 },
        ],
        externalMembers: [
            { name: "Marcos Lima", role: "Conselheiro", organization: "Mescla" },
            {
                name: "Patricia Gomes",
                role: "Mentora",
                organization: "Rede de Logistica",
            },
        ],
        demoVideos: ["https://example.com/videos/rota-verde-demo"],
        pitchDeckUrl: "https://example.com/decks/rota-verde.pdf",
        coverImageUrl: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
        tags: ["logtech", "sustentabilidade", "mobilidade"],
    },
    {
        id: "mentorai",
        name: "MentorAI",
        stage: "em_expansao",
        shortDescription: "Triagem inteligente para programas de mentoria universitarios.",
        description: "A MentorAI organiza perfis de estudantes e mentores para recomendar encontros com base em objetivos, disponibilidade e historico de acompanhamento.",
        executiveSummary: "Startup em expansao com uso simulado em programas de pre-aceleracao e potencial de integracao a plataformas educacionais.",
        capitalRaisedCents: 12350000,
        totalTokensIssued: 500000,
        currentTokenPriceCents: 525,
        founders: [
            { name: "Diego Martins", role: "CEO", equityPercent: 36 },
            { name: "Juliana Vieira", role: "CPO", equityPercent: 24 },
            { name: "Felipe Andrade", role: "CTO", equityPercent: 25 },
            {
                name: "Investidores simulados",
                role: "Participacao externa",
                equityPercent: 15,
            },
        ],
        externalMembers: [
            {
                name: "Sofia Pereira",
                role: "Conselheira",
                organization: "Ecossistema Mescla",
            },
        ],
        demoVideos: ["https://example.com/videos/mentorai-demo"],
        pitchDeckUrl: "https://example.com/decks/mentorai.pdf",
        coverImageUrl: "https://images.unsplash.com/photo-1552664730-d307ca884978",
        tags: ["edtech", "ia", "mentoria"],
    },
];
// Insere ou atualiza as startups de exemplo em uma única operação em lote.
async function seedDemoStartups() {
    const batch = firebase_1.db.batch();
    for (const startup of demoStartups) {
        // Separa o ID do restante dos dados para manter o identificador fora do documento salvo.
        const { id } = startup, data = __rest(startup, ["id"]);
        const startupRef = startupsCollection.doc(id);
        // Escreve os campos e atualiza timestamps de criação e edição no mesmo commit.
        batch.set(startupRef, Object.assign(Object.assign({}, data), { createdAt: firestore_1.FieldValue.serverTimestamp(), updatedAt: firestore_1.FieldValue.serverTimestamp() }), { merge: true });
        const historyRef = startupRef.collection("priceHistory").doc();
        const initialHistoryPoint = {
            priceCents: data.currentTokenPriceCents,
            changeType: "seed",
            quantity: 0,
            createdAt: firestore_1.FieldValue.serverTimestamp(),
        };
        batch.set(historyRef, initialHistoryPoint);
    }
    await batch.commit();
    return demoStartups.map((startup) => startup.id);
}
// Atualiza os indicadores financeiros da startup após uma negociação.
async function atualizarStartupAposNegociacao(startupId, deltaTokens, deltaCapitalCents) {
    const startupRef = startupsCollection.doc(startupId);
    await firebase_1.db.runTransaction(async (transaction) => {
        var _a, _b, _c;
        const snapshot = await transaction.get(startupRef);
        if (!snapshot.exists) {
            throw new Error("Startup não encontrada");
        }
        const startup = snapshot.data();
        const capitalAtualizado = Math.max(0, ((_a = startup.capitalRaisedCents) !== null && _a !== void 0 ? _a : 0) + deltaCapitalCents);
        const totalTokensAtualizado = Math.max(0, ((_b = startup.totalTokensIssued) !== null && _b !== void 0 ? _b : 0) + deltaTokens);
        const precoAtualAtual = (_c = startup.currentTokenPriceCents) !== null && _c !== void 0 ? _c : 0;
        const priceDeltaCents = Math.max(1, Math.round(precoAtualAtual * tokenPriceImpactPercent * Math.abs(deltaTokens)));
        const precoAtualizado = Math.max(1, precoAtualAtual + (deltaTokens > 0 ? priceDeltaCents : -priceDeltaCents));
        transaction.update(startupRef, {
            capitalRaisedCents: capitalAtualizado,
            totalTokensIssued: totalTokensAtualizado,
            currentTokenPriceCents: precoAtualizado,
            updatedAt: firestore_1.FieldValue.serverTimestamp(),
        });
        const historyRef = startupRef.collection("priceHistory").doc();
        const changeType = deltaTokens > 0 ? "compra" : "venda";
        transaction.set(historyRef, {
            priceCents: precoAtualizado,
            changeType,
            quantity: Math.abs(deltaTokens),
            createdAt: firestore_1.FieldValue.serverTimestamp(),
        });
    });
    const snapshotAtualizado = await startupRef.get();
    if (!snapshotAtualizado.exists) {
        throw new Error("Startup não encontrada após atualização");
    }
    return snapshotAtualizado.data();
}
// Aplica os efeitos de uma compra na startup.
async function atualizarStartupAposCompra(startupId, quantidade, precoTotalCents) {
    if (quantidade <= 0) {
        throw new Error("quantidade deve ser positiva");
    }
    return atualizarStartupAposNegociacao(startupId, quantidade, precoTotalCents);
}
// Aplica os efeitos de uma venda na startup.
async function atualizarStartupAposVenda(startupId, quantidade, precoTotalCents) {
    if (quantidade <= 0) {
        throw new Error("quantidade deve ser positiva");
    }
    return atualizarStartupAposNegociacao(startupId, -quantidade, -precoTotalCents);
}
//# sourceMappingURL=startupRepository.js.map