// Max Thomazini Barbosa RA:25003934
// Repositório para gerenciar transações de compra/venda.

// Acesso ao Firestore compartilhado com o restante das funções.
import {db} from "../../startups/shared/firebase";
// Tipo que representa uma transação persistida.
import {Transaction} from "../types/Transaction";

// Cria e persiste uma transação de compra ou venda.
export async function criarTransacao(
  tipo: "compra" | "venda",
  userId: string,
  startupId: string,
  quantidade: number,
  precoUnitario: number,
): Promise<Transaction> {
  // Impede valores fora do domínio aceito para o tipo da transação.
  if (!["compra", "venda"].includes(tipo)) {
    throw new Error("Tipo deve ser 'compra' ou 'venda'");
  }

  // Garante que a transação esteja vinculada a usuário e startup válidos.
  if (!userId || !startupId) {
    throw new Error("userId e startupId são obrigatórios");
  }

  // Evita quantidades inválidas e preços unitários negativos.
  if (quantidade <= 0 || precoUnitario < 0) {
    throw new Error("quantidade deve ser positiva e precoUnitario não-negativo");
  }

  try {
    // Calcula o total em reais/cents conforme o valor recebido pela chamada.
    const precoTotal = quantidade * precoUnitario;
    const agora = new Date();

    // Monta o documento que será gravado no histórico de transações.
    const novaTransacao: Transaction = {
      tipo,
      userId,
      startupId,
      quantidade,
      precoUnitario,
      precoTotal,
      dataTrasacao: agora,
    };

    // Persiste a transação em uma nova chave gerada pelo Firestore.
    const docRef = db.collection("transactions").doc();
    await docRef.set(novaTransacao);

    // Retorna a transação já com o identificador do documento.
    return {
      id: docRef.id,
      ...novaTransacao,
    };
  } catch (erro) {
    throw new Error(`Erro ao criar transação: ${erro}`);
  }
}

// Recupera todo o histórico de transações de um usuário.
export async function obterTransacoesDoUsuario(userId: string): Promise<Transaction[]> {
  // Identificador obrigatório para filtrar as transações corretas.
  if (!userId) {
    throw new Error("userId é obrigatório");
  }

  try {
    // Busca as transações do usuário em ordem decrescente de data.
    const snap = await db
      .collection("transactions")
      .where("userId", "==", userId)
      .orderBy("dataTrasacao", "desc")
      .get();

    // Converte os documentos em objetos tipados para a camada de consumo.
    return snap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    } as Transaction));
  } catch (erro) {
    throw new Error(`Erro ao obter transações: ${erro}`);
  }
}

// Recupera as transações de um usuário em uma startup específica.
export async function obterTransacoesDoUsuarioPorStartup(
  userId: string,
  startupId: string,
): Promise<Transaction[]> {
  // Exige os dois identificadores para montar a consulta segmentada.
  if (!userId || !startupId) {
    throw new Error("userId e startupId são obrigatórios");
  }

  try {
    // Filtra por usuário e startup e mantém a ordenação temporal.
    const snap = await db
      .collection("transactions")
      .where("userId", "==", userId)
      .where("startupId", "==", startupId)
      .orderBy("dataTrasacao", "desc")
      .get();

    // Normaliza o resultado para a forma usada pela aplicação.
    return snap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    } as Transaction));
  } catch (erro) {
    throw new Error(`Erro ao obter transações: ${erro}`);
  }
}

// Filtra o histórico por tipo de operação: compra ou venda.
export async function obterTransacoesPorTipo(
  userId: string,
  tipo: "compra" | "venda",
): Promise<Transaction[]> {
  // Garante que o usuário foi informado antes de fazer a busca.
  if (!userId) {
    throw new Error("userId é obrigatório");
  }

  // Limita o filtro aos tipos aceitos pelo domínio.
  if (!["compra", "venda"].includes(tipo)) {
    throw new Error("Tipo deve ser 'compra' ou 'venda'");
  }

  try {
    // Busca apenas as transações do tipo solicitado e ordena da mais recente para a mais antiga.
    const snap = await db
      .collection("transactions")
      .where("userId", "==", userId)
      .where("tipo", "==", tipo)
      .orderBy("dataTrasacao", "desc")
      .get();

    // Converte o resultado do Firestore para a estrutura esperada pelo restante do sistema.
    return snap.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    } as Transaction));
  } catch (erro) {
    throw new Error(`Erro ao obter transações: ${erro}`);
  }
}
