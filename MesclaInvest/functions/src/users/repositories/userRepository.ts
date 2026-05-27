// LUCAS RODRIGUES XAVIER - 25000508
// Este arquivo é o repositório de usuários na nuvem (Firestore).
// Ele é responsável por salvar e buscar as informações cadastrais dos usuários.

import {FieldValue} from "firebase-admin/firestore";
import {usersCollection} from "../shared/firebase";

// Molde/Formato com as informações básicas que podemos receber ao cadastrar um usuário
type UserInput = {
  nome?: unknown;
  cpf?: unknown;
  email?: unknown;
  telefone?: unknown;
  saldo?: unknown;
};

// Salva ou atualiza os dados cadastrais do usuário no Firestore usando seu UID único
export async function saveUser(uid: string, input: UserInput): Promise<void> {
  const pessoa = {
    uid,
    nome: input.nome || null,
    cpf: input.cpf || null,
    email: input.email || null,
    telefone: input.telefone || null,
    saldo: Math.floor(Number(input.saldo ?? 0)), // Garante que o saldo seja um número inteiro
    createdAt: FieldValue.serverTimestamp(), // Salva a data/hora exata do cadastro no servidor
  };

  // Grava as informações no documento do usuário dentro da coleção
  await usersCollection.doc(uid).set(pessoa);
}

// Busca o número de telefone do usuário no banco usando o UID dele
export async function getUserPhoneNumber(uid: string): Promise<string | null> {
  const docSnap = await usersCollection.doc(uid).get();
  const telefone = docSnap.data()?.telefone;

  // Valida se o telefone existe e não está vazio
  if (typeof telefone !== "string" || telefone.trim().length === 0) {
    return null;
  }

  return telefone.trim();
}
