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
exports.getUserBalanceHandler = void 0;
const https_1 = require("firebase-functions/v2/https");
const logger = __importStar(require("firebase-functions/logger"));
const userRepository_1 = require("../repositories/userRepository");
exports.getUserBalanceHandler = (0, https_1.onRequest)({ region: "southamerica-east1", invoker: "public" }, async (request, response) => {
    var _a, _b;
    try {
        const uid = ((_a = request.query) === null || _a === void 0 ? void 0 : _a.uid) || ((_b = request.body) === null || _b === void 0 ? void 0 : _b.uid);
        if (typeof uid !== "string" || uid.trim().length === 0) {
            response.status(400).send("Campo 'uid' é obrigatório.");
            return;
        }
        const saldo = await (0, userRepository_1.getUserBalance)(uid);
        if (saldo === null) {
            response.status(404).send("Usuário não encontrado.");
            return;
        }
        response.status(200).send({ uid, saldo });
    }
    catch (error) {
        logger.error("Erro ao obter saldo do usuário.", error);
        response.status(500).send("Erro interno ao obter saldo.");
    }
});
//# sourceMappingURL=getUserBalance.js.map