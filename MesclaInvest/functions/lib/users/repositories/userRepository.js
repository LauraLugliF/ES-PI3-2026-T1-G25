"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.saveUser = saveUser;
exports.getUserPhoneNumber = getUserPhoneNumber;
// LUCAS RODRIGUES XAVIER - 25000508
const firestore_1 = require("firebase-admin/firestore");
const firebase_1 = require("../shared/firebase");
async function saveUser(uid, input) {
    var _a;
    const pessoa = {
        uid,
        nome: input.nome || null,
        cpf: input.cpf || null,
        email: input.email || null,
        telefone: input.telefone || null,
        saldo: Math.floor(Number((_a = input.saldo) !== null && _a !== void 0 ? _a : 0)),
        createdAt: firestore_1.FieldValue.serverTimestamp(),
    };
    await firebase_1.usersCollection.doc(uid).set(pessoa);
}
async function getUserPhoneNumber(uid) {
    var _a;
    const docSnap = await firebase_1.usersCollection.doc(uid).get();
    const telefone = (_a = docSnap.data()) === null || _a === void 0 ? void 0 : _a.telefone;
    if (typeof telefone !== "string" || telefone.trim().length === 0) {
        return null;
    }
    return telefone.trim();
}
//# sourceMappingURL=userRepository.js.map