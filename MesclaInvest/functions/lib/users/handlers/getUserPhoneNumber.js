"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUserPhoneNumber = void 0;
// Max Thomazini Barbosa RA:25003934
const https_1 = require("firebase-functions/https");
const userRepository_1 = require("../repositories/userRepository");
exports.getUserPhoneNumber = (0, https_1.onCall)(async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Usuario precisa estar autenticado para acessar esta funcao.");
    }
    const phoneNumber = await (0, userRepository_1.getUserPhoneNumber)(request.auth.uid);
    if (!phoneNumber) {
        throw new https_1.HttpsError("not-found", "Telefone nao encontrado para o usuario.");
    }
    return {
        phoneNumber,
    };
});
//# sourceMappingURL=getUserPhoneNumber.js.map