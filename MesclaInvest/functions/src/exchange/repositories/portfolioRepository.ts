// Max Thomazini Barbosa RA:25003934
// Repositório para gerenciar o portfólio (tokens) do usuário.

// Acesso centralizado ao Firestore usado pelas operações de exchange.
import {db} from "../../startups/shared/firebase";
import {Portfolio} from "../types/Portfolio";

// Recupera o portfólio de um usuário para uma startup específica.
export async function obterPortfolio(
  userId: string,
  startupId: string,
): Promise<Portfolio | null> {
  // Validação mínima dos identificadores necessários para a consulta.
  if (!userId || !startupId) {
    throw new Error("userId e startupId são obrigatórios");
  }

  try {
    // Filtra a coleção pelo usuário e pela startup, limitando o retorno a um documento.
    const snap = await db
      .collection("portfolios")
      .where("userId", "==", userId)
      .where("startupId", "==", startupId)
      .limit(1)
      .get();

    // Sem documento correspondente, não existe portfólio para devolver.
    if (snap.empty) {
      return null;
    }

    // Converte o documento encontrado em um objeto tipado para uso pelo restante do código.
    const doc = snap.docs[0];
    return {
      id: doc.id,
      ...doc.data(),
    } as Portfolio;
  } catch (erro) {
    throw new Error(`Erro ao obter portfólio: ${erro}`);
  }
}

// Recupera todos os portfólios associados a um usuário.
export async function obterPortfoliosDoUsuario(userId: string): Promise<Portfolio[]> {
  // Evita consultas inválidas quando o identificador não foi informado.
  if (!userId) {
    throw new Error("userId é obrigatório");
  }

  try {
    // Busca todos os documentos da coleção que pertencem ao usuário informado.
    const snap = await db
      .collection("portfolios")
      .where("userId", "==", userId)
      .get();

    // Normaliza o retorno para o formato esperado pela camada de apresentação.
    return snap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    } as Portfolio));
  } catch (erro) {
    throw new Error(`Erro ao obter portfólios: ${erro}`);
  }
}

// Adiciona um novo portfólio ou atualiza um existente após a compra de tokens.
export async function adicionarTokensAoPortfolio(
  userId: string,
  startupId: string,
  quantidade: number,
  precoUnitario: number,
): Promise<Portfolio> {
  // Garante que o vínculo com usuário e startup esteja definido.
  if (!userId || !startupId) {
    throw new Error("userId e startupId são obrigatórios");
  }

  // Rejeita quantidades inválidas ou preço unitário negativo.
  if (quantidade <= 0 || precoUnitario < 0) {
    throw new Error("quantidade deve ser positiva e precoUnitario não-negativo");
  }

  try {
    // Verifica se já existe um portfólio para calcular o preço médio corretamente.
    const portfolioExistente = await obterPortfolio(userId, startupId);
    const agora = new Date();

    if (portfolioExistente) {
      // Atualiza o portfólio existente recalculando a quantidade total e o preço médio.
      const quantidadeTotal = portfolioExistente.quantidade + quantidade;
      const valorTotal =
        portfolioExistente.quantidade * portfolioExistente.precoMedioCompra +
        quantidade * precoUnitario;
      const novoPrecoMedio = valorTotal / quantidadeTotal;

      // Persiste a atualização no documento já existente.
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
      // Cria um novo portfólio quando o usuário ainda não possui posição nessa startup.
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

// Remove tokens do portfólio quando ocorre uma venda.
export async function removerTokensDoPortfolio(
  userId: string,
  startupId: string,
  quantidade: number,
): Promise<Portfolio | null> {
  // Exige os identificadores mínimos para localizar a posição do usuário.
  if (!userId || !startupId) {
    throw new Error("userId e startupId são obrigatórios");
  }

  // A remoção precisa ser de uma quantidade positiva.
  if (quantidade <= 0) {
    throw new Error("quantidade deve ser positiva");
  }

  try {
    // Localiza a posição atual para verificar se a venda é possível.
    const portfolioExistente = await obterPortfolio(userId, startupId);

    if (!portfolioExistente) {
      throw new Error("Portfólio não encontrado");
    }

    // Impede a venda de uma quantidade maior do que a posição disponível.
    if (portfolioExistente.quantidade < quantidade) {
      throw new Error("Quantidade insuficiente de tokens para venda");
    }

    // Calcula a quantidade restante após a venda.
    const novaQuantidade = portfolioExistente.quantidade - quantidade;
    const agora = new Date();

    if (novaQuantidade === 0) {
      // Remove o documento quando a posição é totalmente zerada.
      if (portfolioExistente.id) {
        await db.collection("portfolios").doc(portfolioExistente.id).delete();
      }
      return null;
    }

    // Atualiza apenas a quantidade e a data de modificação quando ainda existe saldo em tokens.
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
