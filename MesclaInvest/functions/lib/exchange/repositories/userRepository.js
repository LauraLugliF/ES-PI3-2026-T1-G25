"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUserBalance = getUserBalance;
const firebase_1 = require("../../startups/shared/firebase");
// Retorna o saldo (em centavos) do usuário identificado por `uid`.
// Se o usuário não existir retorna `null`.
async function getUserBalance(uid) {
    if (typeof uid !== "string" || uid.trim().length === 0) {
        throw new Error("Campo 'uid' é obrigatório.");
    }
    const docRef = firebase_1.db.collection("users").doc(uid);
    const snap = await docRef.get();
    if (!snap.exists)
        return null;
    const data = snap.data();
    const saldo = data === null || data === void 0 ? void 0 : data.saldo;
    if (typeof saldo === "number")
        return saldo;
    return null;
}
//# sourceMappingURL=userRepository.js.map