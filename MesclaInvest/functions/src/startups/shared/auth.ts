// Laura Lugli Fonseca Pereira RA: 25000739
// Verificação de autenticação compartilhada entre os handlers de startups
import {CallableRequest, HttpsError} from "firebase-functions/https";
import {AuthenticatedUser} from "../types";

// Verifica se o usuário está autenticado e retorna seus dados básicos
// Lança erro se não houver usuário autenticado na requisição
export function requireAuthenticatedUser(
  request: CallableRequest,
): AuthenticatedUser {
  // Verifica se existe um usuário autenticado na requisição
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Usuario precisa estar autenticado para acessar esta funcao.",
    );
  }

  // Retorna apenas os dados necessários para as regras de negócio
  return {
    uid: request.auth.uid,
    email: request.auth.token.email as string | undefined,
  };
}
