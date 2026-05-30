"use strict";
// LUCAS RODRIGUES XAVIER - 25000508
// Este arquivo é o repositório de usuários na nuvem (Firestore).
// Ele é responsável por salvar e buscar as informações cadastrais dos usuários.
Object.defineProperty(exports, "__esModule", { value: true });
exports.saveUser = saveUser;
exports.getUserPhoneNumber = getUserPhoneNumber;
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("../shared/firebase");
// Salva ou atualiza os dados cadastrais do usuário no Firestore usando seu UID único
async function saveUser(uid, input) {
    var _a;
    const pessoa = {
        uid,
        nome: input.nome || null,
        cpf: input.cpf || null,
        email: input.email || null,
        telefone: input.telefone || null,
        saldo: Math.floor(Number((_a = input.saldo) !== null && _a !== void 0 ? _a : 0)), // Garante que o saldo seja um número inteiro
        createdAt: firestore_1.FieldValue.serverTimestamp(), // Salva a data/hora exata do cadastro no servidor
    };
    // Grava as informações no documento do usuário dentro da coleção
    await firebase_1.usersCollection.doc(uid).set(pessoa);
}
// Busca o número de telefone do usuário no banco usando o UID dele
async function getUserPhoneNumber(uid) {
    var _a;
    const docSnap = await firebase_1.usersCollection.doc(uid).get();
    const telefone = (_a = docSnap.data()) === null || _a === void 0 ? void 0 : _a.telefone;
    // Valida se o telefone existe e não está vazio
    if (typeof telefone !== "string" || telefone.trim().length === 0) {
        return null;
    }
    return telefone.trim();
}
//# sourceMappingURL=userRepository.js.map