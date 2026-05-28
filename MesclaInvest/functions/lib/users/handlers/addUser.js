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
exports.addUser = void 0;
// LUCAS RODRIGUES XAVIER - 25000508
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const userRepository_1 = require("../repositories/userRepository");
exports.addUser = (0, https_1.onRequest)({ region: "southamerica-east1", invoker: "public" }, async (request, response) => {
    var _a, _b, _c, _d, _e, _f;
    const uid = (_a = request.body) === null || _a === void 0 ? void 0 : _a.uid;
    if (typeof uid !== "string" || uid.trim().length === 0) {
        response.status(400).send("Campo 'uid' é obrigatório.");
        return;
    }
    try {
        await (0, userRepository_1.saveUser)(uid, {
            nome: (_b = request.body) === null || _b === void 0 ? void 0 : _b.nome,
            cpf: (_c = request.body) === null || _c === void 0 ? void 0 : _c.cpf,
            email: (_d = request.body) === null || _d === void 0 ? void 0 : _d.email,
            telefone: (_e = request.body) === null || _e === void 0 ? void 0 : _e.telefone,
            saldo: (_f = request.body) === null || _f === void 0 ? void 0 : _f.saldo,
        });
        response.status(201).send("Pessoa cadastrada com sucesso. UID: " + uid);
    }
    catch (error) {
        logger.error("Erro ao cadastrar pessoa.", error);
        response.status(500).send("Erro interno ao cadastrar a pessoa.");
    }
});
//# sourceMappingURL=addUser.js.map