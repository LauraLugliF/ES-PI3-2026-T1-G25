// Max Thomazini Barbosa RA:25003934
import {HttpsError, onCall} from "firebase-functions/https";
import {getUserPhoneNumber as getPhoneNumber} from "../repositories/userRepository";

export const getUserPhoneNumber = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "Usuario precisa estar autenticado para acessar esta funcao.",
    );
  }

  const phoneNumber = await getPhoneNumber(request.auth.uid);

  if (!phoneNumber) {
    throw new HttpsError(
      "not-found",
      "Telefone nao encontrado para o usuario.",
    );
  }

  return {
    phoneNumber,
  };
});
