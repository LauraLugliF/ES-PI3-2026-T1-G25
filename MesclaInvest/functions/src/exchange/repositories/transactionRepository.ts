// Max Thomazini Barbosa RA:25003934
// Repositório para gerenciar transações de compra/venda

import {db} from "../../startups/shared/firebase";
import {Transaction} from "../types/Transaction";

// Criar uma nova transação de compra/venda
export async function criarTransacao(
  tipo: "compra" | "venda",
  userId: string,
  startupId: string,
  quantidade: number,
  precoUnitario: number,
): Promise<Transaction> {
  if (!["compra", "venda"].includes(tipo)) {
    throw new Error("Tipo deve ser 'compra' ou 'venda'");
  }

  if (!userId || !startupId) {
    throw new Error("userId e startupId são obrigatórios");
  }

  if (quantidade <= 0 || precoUnitario < 0) {
    throw new Error("quantidade deve ser positiva e precoUnitario não-negativo");
  }

  try {
    const precoTotal = quantidade * precoUnitario;
    const agora = new Date();

    const novaTransacao: Transaction = {
      tipo,
      userId,
      startupId,
      quantidade,
      precoUnitario,
      precoTotal,
      dataTrasacao: agora,
    };

    const docRef = db.collection("transactions").doc();
    await docRef.set(novaTransacao);

    return {
      id: docRef.id,
      ...novaTransacao,
    };
  } catch (erro) {
    throw new Error(`Erro ao criar transação: ${erro}`);
  }
}

// Obter todas as transações de um usuário
export async function obterTransacoesDoUsuario(userId: string): Promise<Transaction[]> {
  if (!userId) {
    throw new Error("userId é obrigatório");
  }

  try {
    const snap = await db
      .collection("transactions")
      .where("userId", "==", userId)
      .orderBy("dataTrasacao", "desc")
      .get();

    return snap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    } as Transaction));
  } catch (erro) {
    throw new Error(`Erro ao obter transações: ${erro}`);
  }
}

// Obter transações de um usuário para uma startup específica
export async function obterTransacoesDoUsuarioPorStartup(
  userId: string,
  startupId: string,
): Promise<Transaction[]> {
  if (!userId || !startupId) {
    throw new Error("userId e startupId são obrigatórios");
  }

  try {
    const snap = await db
      .collection("transactions")
      .where("userId", "==", userId)
      .where("startupId", "==", startupId)
      .orderBy("dataTrasacao", "desc")
      .get();

    return snap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    } as Transaction));
  } catch (erro) {
    throw new Error(`Erro ao obter transações: ${erro}`);
  }
}

// Obter histórico de compras/vendas
export async function obterTransacoesPorTipo(
  userId: string,
  tipo: "compra" | "venda",
): Promise<Transaction[]> {
  if (!userId) {
    throw new Error("userId é obrigatório");
  }

  if (!["compra", "venda"].includes(tipo)) {
    throw new Error("Tipo deve ser 'compra' ou 'venda'");
  }

  try {
    const snap = await db
      .collection("transactions")
      .where("userId", "==", userId)
      .where("tipo", "==", tipo)
      .orderBy("dataTrasacao", "desc")
      .get();

    return snap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    } as Transaction));
  } catch (erro) {
    throw new Error(`Erro ao obter transações: ${erro}`);
  }
}
