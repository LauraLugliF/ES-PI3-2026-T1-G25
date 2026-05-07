"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.db = exports.auth = void 0;
//Max Thomazini Barbosa RA:25003934
const auth_1 = require("firebase-admin/auth");
const app_1 = require("firebase-admin/app");
const firestore_1 = require("firebase-admin/firestore");
// Garante que o Firebase Admin seja inicializado apenas uma vez no ambiente das functions.
if ((0, app_1.getApps)().length === 0) {
    (0, app_1.initializeApp)();
}
// Instâncias compartilhadas para autenticação e acesso ao Firestore.
exports.auth = (0, auth_1.getAuth)();
exports.db = (0, firestore_1.getFirestore)();
//# sourceMappingURL=firebase.js.map