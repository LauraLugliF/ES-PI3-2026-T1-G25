// LUCAS RODRIGUES XAVIER - 25000508
import {FieldValue} from "firebase-admin/firestore";
import {usersCollection} from "../shared/firebase";

type UserInput = {
  nome?: unknown;
  cpf?: unknown;
  email?: unknown;
  telefone?: unknown;
  saldo?: unknown;
};

export async function saveUser(uid: string, input: UserInput): Promise<void> {
  const pessoa = {
    uid,
    nome: input.nome || null,
    cpf: input.cpf || null,
    email: input.email || null,
    telefone: input.telefone || null,
    saldo: Math.floor(Number(input.saldo ?? 0)),
    createdAt: FieldValue.serverTimestamp(),
  };

  await usersCollection.doc(uid).set(pessoa);
}

export async function getUserPhoneNumber(uid: string): Promise<string | null> {
  const docSnap = await usersCollection.doc(uid).get();
  const telefone = docSnap.data()?.telefone;

  if (typeof telefone !== "string" || telefone.trim().length === 0) {
    return null;
  }

  return telefone.trim();
}
