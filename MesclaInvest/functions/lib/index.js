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
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.addUser = void 0;
const index_1 = require("./cadastro/index");
Object.defineProperty(exports, "addUser", { enumerable: true, get: function () { return index_1.addUser; } });
const firebase_functions_1 = require("firebase-functions");
// Limita o número de instâncias para evitar excesso de concorrência nas functions.
(0, firebase_functions_1.setGlobalOptions)({ maxInstances: 10 });
// Reexporta todas as functions relacionadas ao módulo de startups.
__exportStar(require("./startups"), exports);
//# sourceMappingURL=index.js.map