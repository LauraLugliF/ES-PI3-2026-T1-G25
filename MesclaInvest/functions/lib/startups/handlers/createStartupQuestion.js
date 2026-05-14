"use strict";
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
exports.createStartupQuestion = void 0;
// Laura Lugli Fonseca Pereira RA: 25000739
// Handler que cria uma pergunta pública ou privada para uma startup
const firestore_1 = require("firebase-admin/firestore");
const https_1 = require("firebase-functions/https");
const logger = __importStar(require("firebase-functions/logger"));
const constants_1 = require("../shared/constants");
const auth_1 = require("../shared/auth");
const validation_1 = require("../shared/validation");
const startupDetailsRepository_1 = require("../repositories/startupDetailsRepository");
// Cria uma pergunta para uma startup
// O app deve enviar em `data`:
// - `startupId`: identificador da startup
// - `text`: texto da pergunta
// - `visibility`: visibilidade da pergunta (publica ou privada)
// Perguntas privadas exigem que o usuário seja investidor da startup
exports.createStartupQuestion = (0, https_1.onCall)(async (request) => {
    var _a, _b, _c, _d;
    // Verifica se o usuário está autenticado e obtém seus dados
    const user = (0, auth_1.requireAuthenticatedUser)(request);
    // Normaliza o ID da startup recebido
    const startupId = (0, validation_1.normalizeString)((_a = request.data) === null || _a === void 0 ? void 0 : _a.startupId);
    // Normaliza o texto da pergunta recebido
    const text = (0, validation_1.normalizeString)((_b = request.data) === null || _b === void 0 ? void 0 : _b.text);
    // Define visibilidade padrão como pública se não informada
    const visibility = (_d = (0, validation_1.normalizeString)((_c = request.data) === null || _c === void 0 ? void 0 : _c.visibility)) !== null && _d !== void 0 ? _d : "publica";
    // Valida se o ID da startup e o texto foram enviados
    if (!startupId || !text) {
        throw new https_1.HttpsError("invalid-argument", "Informe startupId e text.");
    }
    // Valida se a visibilidade informada é um valor permitido
    if (!constants_1.allowedVisibilities.includes(visibility)) {
        throw new https_1.HttpsError("invalid-argument", "Visibility invalida. Use publica ou privada.");
    }
    // Verifica se a startup existe no banco
    const startup = await (0, startupDetailsRepository_1.getStartupById)(startupId);
    // Retorna erro 404 se a startup não existir
    if (!startup) {
        throw new https_1.HttpsError("not-found", "Startup nao encontrada.");
    }
    // Perguntas privadas só podem ser enviadas por investidores
    if (visibility === "privada") {
        // Verifica se o usuário é investidor desta startup
        const isInvestor = await (0, startupDetailsRepository_1.userIsInvestor)(startupId, user.uid);
        // Bloqueia o envio se o usuário não for investidor
        if (!isInvestor) {
            throw new https_1.HttpsError("permission-denied", "Somente investidores desta startup podem enviar perguntas privadas.");
        }
    }
    // Monta o documento da pergunta para salvar no Firestore
    const question = {
        authorUid: user.uid,
        authorEmail: user.email,
        text,
        visibility: visibility,
        createdAt: firestore_1.FieldValue.serverTimestamp(),
    };
    // Salva a pergunta na subcoleção de perguntas da startup
    const questionId = await (0, startupDetailsRepository_1.createQuestion)(startupId, question);
    // Registra log da criação da pergunta
    logger.info("Pergunta criada para startup.", {
        startupId,
        questionId,
        visibility,
    });
    // Retorna os dados da pergunta criada
    return {
        data: {
            id: questionId,
            startupId,
            visibility,
        },
    };
});
//# sourceMappingURL=createStartupQuestion.js.map