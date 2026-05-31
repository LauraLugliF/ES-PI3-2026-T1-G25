import {db} from "../../startups/shared/firebase";

// Lida com a leitura e atualização do saldo do usuário na coleção `users`.

// Retorna o saldo do usuário em centavos.
// Se o documento não existir ou o campo estiver ausente, retorna `null`.
export async function getUserBalance(uid: string): Promise<number | null> {
  // Validação defensiva para impedir consultas com identificador vazio.
  if (typeof uid !== "string" || uid.trim().length === 0) {
    throw new Error("Campo 'uid' é obrigatório.");
  }

  // Busca o documento do usuário no Firestore.
  const docRef = db.collection("users").doc(uid);
  const snap = await docRef.get();

  // Sem documento não há saldo para retornar.
  if (!snap.exists) return null;

  // Lê o saldo gravado e garante que ele realmente seja numérico.
  const data = snap.data();
  const saldo = data?.saldo;

  if (typeof saldo === "number") return saldo;

  return null;
}

// Soma um depósito ao saldo atual do usuário e persiste o novo valor.
// A função trabalha em centavos para manter a consistência financeira.
export async function adicionarDeposito(uid: string, depositoEmCentavos: number): Promise<number> {
  // Garante que o identificador do usuário seja válido.
  if (typeof uid !== "string" || uid.trim().length === 0) {
    throw new Error("Campo 'uid' é obrigatório.");
  }

  // Depósito precisa ser positivo para evitar créditos inválidos.
  if (typeof depositoEmCentavos !== "number" || depositoEmCentavos <= 0) {
    throw new Error("Valor do depósito deve ser um número positivo.");
  }

  // Localiza o documento do usuário que terá o saldo atualizado.
  const docRef = db.collection("users").doc(uid);
  const snap = await docRef.get();

  // Sem usuário cadastrado, a operação não pode prosseguir.
  if (!snap.exists) {
    throw new Error("Usuário não encontrado.");
  }

  // Usa zero como saldo padrão quando o campo não existe ou está inconsistente.
  const data = snap.data();
  const saldoAtual = (typeof data?.saldo === "number") ? data.saldo : 0;

  // Calcula o novo saldo somando o depósito ao valor já armazenado.
  const novoSaldo = saldoAtual + depositoEmCentavos;

  // Persiste o saldo recalculado no documento do usuário.
  await docRef.update({saldo: novoSaldo});

  return novoSaldo;
}

// Deduz um valor do saldo do usuário e devolve o saldo atualizado.
export async function deduzirSaldoUsuario(uid: string, valorEmCentavos: number): Promise<number> {
  // Validação básica do usuário antes de tentar qualquer leitura no banco.
  if (typeof uid !== "string" || uid.trim().length === 0) {
    throw new Error("Campo 'uid' é obrigatório.");
  }

  // A dedução também deve ser positiva para manter a regra financeira do domínio.
  if (typeof valorEmCentavos !== "number" || valorEmCentavos <= 0) {
    throw new Error("Valor da dedução deve ser um número positivo.");
  }

  // Carrega o documento para verificar se o usuário existe e qual é o saldo atual.
  const docRef = db.collection("users").doc(uid);
  const snap = await docRef.get();

  // Não é possível debitar saldo de um usuário inexistente.
  if (!snap.exists) {
    throw new Error("Usuário não encontrado.");
  }

  // Usa zero como padrão quando o saldo não está preenchido.
  const data = snap.data();
  const saldoAtual = (typeof data?.saldo === "number") ? data.saldo : 0;

  // Impede o saldo de ficar negativo.
  if (saldoAtual < valorEmCentavos) {
    throw new Error("Saldo insuficiente.");
  }

  // Calcula e grava o novo saldo após o débito.
  const novoSaldo = saldoAtual - valorEmCentavos;

  await docRef.update({saldo: novoSaldo});

  return novoSaldo;
}
