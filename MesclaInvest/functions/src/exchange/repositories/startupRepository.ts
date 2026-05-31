// Max Thomazini Barbosa RA:25003934
// Repositório para acessar dados de startups (leitura).

// Acesso compartilhado ao Firestore usado pelas functions da exchange.
import {db} from "../../startups/shared/firebase";
// Tipo da startup persistida no banco.
import {StartupDocument} from "../../startups/types";

// Busca os dados de uma startup específica pelo identificador.
export async function obterStartup(startupId: string): Promise<StartupDocument | null> {
  // Valida se o identificador foi informado antes de consultar o banco.
  if (!startupId) {
    throw new Error("startupId é obrigatório");
  }

  try {
    // Recupera o documento diretamente pela chave da startup.
    const docRef = db.collection("startups").doc(startupId);
    const snap = await docRef.get();

    // Sem documento encontrado, a startup não existe.
    if (!snap.exists) {
      return null;
    }

    // Retorna os dados persistidos com o tipo esperado pela camada de domínio.
    return snap.data() as StartupDocument;
  } catch (erro) {
    throw new Error(`Erro ao obter startup: ${erro}`);
  }
}

// Recupera todas as startups cadastradas.
export async function obterTodasAsStartups(): Promise<StartupDocument[]> {
  try {
    // Lê toda a coleção de startups e normaliza o retorno para objetos tipados.
    const snap = await db.collection("startups").get();

    return snap.docs.map((doc) => doc.data() as StartupDocument);
  } catch (erro) {
    throw new Error(`Erro ao obter startups: ${erro}`);
  }
}

// Verifica rapidamente se uma startup existe no banco.
export async function startupExiste(startupId: string): Promise<boolean> {
  try {
    const startup = await obterStartup(startupId);
    return startup !== null;
  } catch {
    return false;
  }
}

// Retorna o preço atual de um token da startup em centavos.
export async function obterPrecoTokenStartup(startupId: string): Promise<number | null> {
  try {
    const startup = await obterStartup(startupId);
    if (!startup) {
      return null;
    }
    // Usa o preço armazenado na startup, se ele existir.
    return startup.currentTokenPriceCents || null;
  } catch {
    return null;
  }
}
