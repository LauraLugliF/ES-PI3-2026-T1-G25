// Laura Lugli Fonseca Pereira RA: 25000739
// Handler que lista e filtra as startups do catálogo MesclaInvest
import {HttpsError, onCall} from "firebase-functions/https";
import {allowedStages} from "../shared/constants";
import {requireAuthenticatedUser} from "../shared/auth";
import {normalizeString} from "../shared/validation";
import {listStartupItems} from "../repositories/startupDetailsRepository";
import {StartupStage} from "../types";

// Lista as startups cadastradas no catálogo do MesclaInvest
// O app pode enviar em `data`:
// - `stage`: filtro opcional por estágio
// - `search`: texto opcional para busca no catálogo
// Exige usuário autenticado e retorna count, filtros aplicados e lista de startups
export const listStartups = onCall(async (request) => {
  // Verifica se o usuário está autenticado
  requireAuthenticatedUser(request);

  // Normaliza o filtro de estágio recebido
  const stage = normalizeString(request.data?.stage);

  // Normaliza o texto de busca em minúsculas para comparação
  const search = normalizeString(request.data?.search)
    ?.toLocaleLowerCase("pt-BR");

  // Valida se o estágio informado é um valor permitido
  if (stage && !allowedStages.includes(stage as StartupStage)) {
    throw new HttpsError(
      "invalid-argument",
      "Filtro stage invalido. Use nova, em_operacao ou em_expansao."
    );
  }

  // Busca todas as startups e aplica os filtros recebidos
  const startups = (await listStartupItems())
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
      availableStages: allowedStages,
      stage: stage ?? null,
      search: search ?? null,
    },
    data: startups,
  };
});