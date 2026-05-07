"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizeString = normalizeString;
//Max Thomazini Barbosa RA:25003934
function normalizeString(value) {
    // Rejeita qualquer valor que não seja texto.
    if (typeof value !== "string") {
        return undefined;
    }
    // Remove espaços extras nas extremidades.
    const trimmed = value.trim();
    // Retorna apenas strings com conteúdo real; caso contrário, trata como vazio.
    return trimmed.length > 0 ? trimmed : undefined;
}
//# sourceMappingURL=validation.js.map