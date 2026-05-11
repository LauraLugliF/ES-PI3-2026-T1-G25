import {db} from "../../startups/shared/firebase";

// Retorna o saldo (em centavos) do usuário identificado por `uid`.
// Se o usuário não existir retorna `null`.
export async function getUserBalance(uid: string): Promise<number | null> {
  if (typeof uid !== "string" || uid.trim().length === 0) {
    throw new Error("Campo 'uid' é obrigatório.");
  }

  const docRef = db.collection("users").doc(uid);
  const snap = await docRef.get();

  if (!snap.exists) return null;

  const data = snap.data();
  const saldo = data?.saldo;

  if (typeof saldo === "number") return saldo;

  return null;
}
