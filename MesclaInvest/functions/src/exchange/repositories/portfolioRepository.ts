// Max Thomazini Barbosa RA:25003934
// Repositório para gerenciar o portfólio (tokens) do usuário

import {db} from "../../startups/shared/firebase";
import {Portfolio} from "../types/Portfolio";

// Obter portfólio específico do usuário para uma startup
export async function obterPortfolio(
  userId: string,
  startupId: string,
): Promise<Portfolio | null> {
  if (!userId || !startupId) {
    throw new Error("userId e startupId são obrigatórios");
  }

  try {
    const snap = await db
      .collection("portfolios")
      .where("userId", "==", userId)
      .where("startupId", "==", startupId)
      .limit(1)
      .get();

    if (snap.empty) {
      return null;
    }

    const doc = snap.docs[0];
    return {
      id: doc.id,
      ...doc.data(),
    } as Portfolio;
  } catch (erro) {
    throw new Error(`Erro ao obter portfólio: ${erro}`);
  }
}

// Obter todos os portfólios de um usuário
export async function obterPortfoliosDoUsuario(userId: string): Promise<Portfolio[]> {
  if (!userId) {
    throw new Error("userId é obrigatório");
  }

  try {
    const snap = await db
      .collection("portfolios")
      .where("userId", "==", userId)
      .get();

    return snap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    } as Portfolio));
  } catch (erro) {
    throw new Error(`Erro ao obter portfólios: ${erro}`);
  }
}

// Adicionar/atualizar portfólio após compra
export async function adicionarTokensAoPortfolio(
  userId: string,
  startupId: string,
  quantidade: number,
  precoUnitario: number,
): Promise<Portfolio> {
  if (!userId || !startupId) {
    throw new Error("userId e startupId são obrigatórios");
  }

  if (quantidade <= 0 || precoUnitario < 0) {
    throw new Error("quantidade deve ser positiva e precoUnitario não-negativo");
  }

  try {
    const portfolioExistente = await obterPortfolio(userId, startupId);
    const agora = new Date();

    if (portfolioExistente) {
      // Atualizar portfólio existente - recalcular preço médio
      const quantidadeTotal = portfolioExistente.quantidade + quantidade;
      const valorTotal =
        portfolioExistente.quantidade * portfolioExistente.precoMedioCompra +
        quantidade * precoUnitario;
      const novoPrecoMedio = valorTotal / quantidadeTotal;

      if (portfolioExistente.id) {
        const docRef = db.collection("portfolios").doc(portfolioExistente.id);
        await docRef.update({
          quantidade: quantidadeTotal,
          precoMedioCompra: novoPrecoMedio,
          atualizadoEm: agora,
        });
      }

      return {
        ...portfolioExistente,
        quantidade: quantidadeTotal,
        precoMedioCompra: novoPrecoMedio,
        atualizadoEm: agora,
      };
    } else {
      // Criar novo portfólio
      const docRef = db.collection("portfolios").doc();
      const novoPortfolio: Portfolio = {
        id: docRef.id,
        userId,
        startupId,
        quantidade,
        precoMedioCompra: precoUnitario,
        dataCompra: agora,
        atualizadoEm: agora,
      };

      await docRef.set(novoPortfolio);
      return novoPortfolio;
    }
  } catch (erro) {
    throw new Error(`Erro ao adicionar tokens: ${erro}`);
  }
}

// Remover tokens do portfólio (venda)
export async function removerTokensDoPortfolio(
  userId: string,
  startupId: string,
  quantidade: number,
): Promise<Portfolio | null> {
  if (!userId || !startupId) {
    throw new Error("userId e startupId são obrigatórios");
  }

  if (quantidade <= 0) {
    throw new Error("quantidade deve ser positiva");
  }

  try {
    const portfolioExistente = await obterPortfolio(userId, startupId);

    if (!portfolioExistente) {
      throw new Error("Portfólio não encontrado");
    }

    if (portfolioExistente.quantidade < quantidade) {
      throw new Error("Quantidade insuficiente de tokens para venda");
    }

    const novaQuantidade = portfolioExistente.quantidade - quantidade;
    const agora = new Date();

    if (novaQuantidade === 0) {
      // Deletar portfólio se quantidade chegar a 0
      if (portfolioExistente.id) {
        await db.collection("portfolios").doc(portfolioExistente.id).delete();
      }
      return null;
    }

    // Atualizar portfólio com nova quantidade
    if (portfolioExistente.id) {
      const docRef = db.collection("portfolios").doc(portfolioExistente.id);
      await docRef.update({
        quantidade: novaQuantidade,
        atualizadoEm: agora,
      });
    }

    return {
      ...portfolioExistente,
      quantidade: novaQuantidade,
      atualizadoEm: agora,
    };
  } catch (erro) {
    throw new Error(`Erro ao remover tokens: ${erro}`);
  }
}
