"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listStartups = void 0;
// Laura Lugli Fonseca Pereira RA: 25000739
// Handler que lista e filtra as startups do catálogo MesclaInvest
const https_1 = require("firebase-functions/https");
const constants_1 = require("../shared/constants");
const auth_1 = require("../shared/auth");
const validation_1 = require("../shared/validation");
const startupDetailsRepository_1 = require("../repositories/startupDetailsRepository");
// Lista as startups cadastradas no catálogo do MesclaInvest
// O app pode enviar em `data`:
// - `stage`: filtro opcional por estágio
// - `search`: texto opcional para busca no catálogo
// Exige usuário autenticado e retorna count, filtros aplicados e lista de startups
exports.listStartups = (0, https_1.onCall)(async (request) => {
    var _a, _b, _c;
    // Verifica se o usuário está autenticado
    (0, auth_1.requireAuthenticatedUser)(request);
    // Normaliza o filtro de estágio recebido
    const stage = (0, validation_1.normalizeString)((_a = request.data) === null || _a === void 0 ? void 0 : _a.stage);
    // Normaliza o texto de busca em minúsculas para comparação
    const search = (_c = (0, validation_1.normalizeString)((_b = request.data) === null || _b === void 0 ? void 0 : _b.search)) === null || _c === void 0 ? void 0 : _c.toLocaleLowerCase("pt-BR");
    // Valida se o estágio informado é um valor permitido
    if (stage && !constants_1.allowedStages.includes(stage)) {
        throw new https_1.HttpsError("invalid-argument", "Filtro stage invalido. Use nova, em_operacao ou em_expansao.");
    }
    // Busca todas as startups e aplica os filtros recebidos
    const startups = (await (0, startupDetailsRepository_1.listStartupItems)())
        // Filtra por estágio se informado
        .filter((startup) => !stage || startup.stage === stage)
        // Filtra por texto de busca nos campos principais
        .filter((startup) => {
        if (!search) {
            return true;
        }
        // Concatena os campos pesquisáveis para busca
        const searchable = [
            startup.name,
            startup.shortDescription,
            startup.stage,
            ...startup.tags,
        ].join(" ").toLocaleLowerCase("pt-BR");
        return searchable.includes(search);
    })
        // Ordena por nome em ordem alfabética
        .sort((left, right) => left.name.localeCompare(right.name, "pt-BR"));
    // Retorna a contagem, filtros aplicados e lista de startups
    return {
        count: startups.length,
        filters: {
            availableStages: constants_1.allowedStages,
            stage: stage !== null && stage !== void 0 ? stage : null,
            search: search !== null && search !== void 0 ? search : null,
        },
        data: startups,
    };
});
//# sourceMappingURL=listStartups.js.map