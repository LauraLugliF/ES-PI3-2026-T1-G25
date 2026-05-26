"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.usersCollection = exports.db = void 0;
// Max Thomazini Barbosa RA:25003934
const app_1 = require("firebase-admin/app");
const firestore_1 = require("firebase-admin/firestore");
const app = (0, app_1.getApps)().length === 0 ? (0, app_1.initializeApp)() : (0, app_1.getApp)();
exports.db = (0, firestore_1.getFirestore)(app, "projeto3");
exports.usersCollection = exports.db.collection("users");
//# sourceMappingURL=firebase.js.map