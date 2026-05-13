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

// Adiciona um depósito ao saldo do usuário (valor em centavos).
// Retorna o novo saldo em centavos.
export async function adicionarDeposito(uid: string, depositoEmCentavos: number): Promise<number> {
  if (typeof uid !== "string" || uid.trim().length === 0) {
    throw new Error("Campo 'uid' é obrigatório.");
  }

  if (typeof depositoEmCentavos !== "number" || depositoEmCentavos <= 0) {
    throw new Error("Valor do depósito deve ser um número positivo.");
  }

  const docRef = db.collection("users").doc(uid);
  const snap = await docRef.get();

  if (!snap.exists) {
    throw new Error("Usuário não encontrado.");
  }

  const data = snap.data();
  const saldoAtual = (typeof data?.saldo === "number") ? data.saldo : 0;

  // Calcula novo saldo
  const novoSaldo = saldoAtual + depositoEmCentavos;

  // Atualiza no Firestore
  await docRef.update({saldo: novoSaldo});

  return novoSaldo;
}

// Deduz um valor do saldo do usuário (valor em centavos).
// Retorna o novo saldo em centavos.
export async function deduzirSaldoUsuario(uid: string, valorEmCentavos: number): Promise<number> {
  if (typeof uid !== "string" || uid.trim().length === 0) {
    throw new Error("Campo 'uid' é obrigatório.");
  }

  if (typeof valorEmCentavos !== "number" || valorEmCentavos <= 0) {
    throw new Error("Valor da dedução deve ser um número positivo.");
  }

  const docRef = db.collection("users").doc(uid);
  const snap = await docRef.get();

  if (!snap.exists) {
    throw new Error("Usuário não encontrado.");
  }

  const data = snap.data();
  const saldoAtual = (typeof data?.saldo === "number") ? data.saldo : 0;

  if (saldoAtual < valorEmCentavos) {
    throw new Error("Saldo insuficiente.");
  }

  const novoSaldo = saldoAtual - valorEmCentavos;

  await docRef.update({saldo: novoSaldo});

  return novoSaldo;
}
