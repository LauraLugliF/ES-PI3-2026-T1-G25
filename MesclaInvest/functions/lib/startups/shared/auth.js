"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuthenticatedUser = requireAuthenticatedUser;
// Laura Lugli Fonseca Pereira RA: 25000739
// Verificação de autenticação compartilhada entre os handlers de startups
const https_1 = require("firebase-functions/https");
// Verifica se o usuário está autenticado e retorna seus dados básicos
// Lança erro se não houver usuário autenticado na requisição
function requireAuthenticatedUser(request) {
    // Verifica se existe um usuário autenticado na requisição
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Usuario precisa estar autenticado para acessar esta funcao.");
    }
    // Retorna apenas os dados necessários para as regras de negócio
    return {
        uid: request.auth.uid,
        email: request.auth.token.email,
    };
}
//# sourceMappingURL=auth.js.map