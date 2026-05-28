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
exports.getUserPhoneNumber = exports.addUser = void 0;
const https_1 = require("firebase-functions/v2/https");
const https_2 = require("firebase-functions/https");
const logger = __importStar(require("firebase-functions/logger"));
const app_1 = require("firebase-admin/app");
// Adicionado o FieldValue na importação abaixo
const firestore_1 = require("firebase-admin/firestore");
const auth_1 = require("../startups/shared/auth");
const app = (0, app_1.initializeApp)();
const db = (0, firestore_1.getFirestore)(app, "projeto3");
// Renomeado para fazer sentido com o objetivo
const colPessoas = db.collection("users");
exports.addUser = (0, https_1.onRequest)({ region: "southamerica-east1", invoker: "public" }, async (request, response) => {
    var _a, _b, _c, _d, _e, _f, _g;
    // Coletando os dados da pessoa
    const uid = (_a = request.body) === null || _a === void 0 ? void 0 : _a.uid;
    const nome = (_b = request.body) === null || _b === void 0 ? void 0 : _b.nome;
    const cpf = (_c = request.body) === null || _c === void 0 ? void 0 : _c.cpf;
    const email = (_d = request.body) === null || _d === void 0 ? void 0 : _d.email;
    const telefone = (_e = request.body) === null || _e === void 0 ? void 0 : _e.telefone;
    const saldo = (_g = (_f = request.body) === null || _f === void 0 ? void 0 : _f.saldo) !== null && _g !== void 0 ? _g : 0;
    // Gerando o timestamp do servidor
    const createdAt = firestore_1.FieldValue.serverTimestamp();
    // Validação obrigatória do UID
    if (typeof uid !== "string" || uid.trim().length === 0) {
        response.status(400).send("Campo 'uid' é obrigatório.");
        return;
    }
    // Montando o objeto da Pessoa com todos os campos recebidos
    const pessoa = {
        uid: uid,
        nome: nome || null,
        cpf: cpf || null,
        email: email || null,
        telefone: telefone || null,
        saldo: Math.floor(Number(saldo)), // Garante que é um inteiro em centavos
        createdAt: createdAt,
    };
    try {
        // Inserindo a pessoa no banco usando o UID como document ID
        await colPessoas.doc(uid).set(pessoa);
        response.status(201).send("Pessoa cadastrada com sucesso. UID: " + uid);
    }
    catch (error) {
        logger.error("Erro ao cadastrar pessoa.", error);
        response.status(500).send("Erro interno ao cadastrar a pessoa.");
    }
});
exports.getUserPhoneNumber = (0, https_2.onCall)(async (request) => {
    var _a, _b;
    const user = (0, auth_1.requireAuthenticatedUser)(request);
    let telefone = null;
    const docSnap = await colPessoas.doc(user.uid).get();
    if (docSnap.exists) {
        telefone = (_a = docSnap.data()) === null || _a === void 0 ? void 0 : _a.telefone;
    }
    if ((typeof telefone !== "string" || telefone.trim().length === 0) && user.email) {
        const emailSnap = await colPessoas
            .where("email", "==", user.email)
            .limit(1)
            .get();
        if (!emailSnap.empty) {
            telefone = (_b = emailSnap.docs[0].data()) === null || _b === void 0 ? void 0 : _b.telefone;
        }
    }
    if (typeof telefone !== "string" || telefone.trim().length === 0) {
        throw new https_2.HttpsError("not-found", "Telefone nao encontrado para o usuario.");
    }
    return {
        phoneNumber: telefone.trim(),
    };
});
//# sourceMappingURL=index.js.map