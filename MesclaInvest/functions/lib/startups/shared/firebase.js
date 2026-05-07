"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.db = exports.auth = void 0;
// Max Thomazini Barbosa RA:25003934
const auth_1 = require("firebase-admin/auth");
const app_1 = require("firebase-admin/app");
const firestore_1 = require("firebase-admin/firestore");
// Garante que o Firebase Admin seja inicializado apenas uma vez no ambiente das functions.
// Mantemos a referência da app: se já existir usamos getApp(), caso contrário inicializamos.
const app = (0, app_1.getApps)().length === 0 ? (0, app_1.initializeApp)() : (0, app_1.getApp)();
// Instâncias compartilhadas para autenticação e acesso ao Firestore.
// Passamos `app` explicitamente e usamos o databaseId nomeado 'projeto3'.
exports.auth = (0, auth_1.getAuth)(app);
exports.db = (0, firestore_1.getFirestore)(app, "projeto3");
//# sourceMappingURL=firebase.js.map