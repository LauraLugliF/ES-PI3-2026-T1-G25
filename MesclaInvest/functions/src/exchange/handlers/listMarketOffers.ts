// LUCAS RODRIGUES XAVIER - 25000508
// Handler para listar as ofertas abertas no mercado P2P
// Retorna todas as ofertas com status "open", opcionalmente filtradas por startup.

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {db} from "../../startups/shared/firebase";
import {MarketOffer} from "../types/MarketOffer";

export const listMarketOffersHandler = onRequest(
  {region: "southamerica-east1", invoker: "public"},
  async (request, response) => {
    try {
      const startupId = (request.body?.startupId as string) || "";

      // Monta a query base: apenas ofertas abertas
      // Alterado: Removido orderBy para evitar exigência de índice composto em construção
      let query = db
        .collection("marketOffers")
        .where("status", "==", "open") as FirebaseFirestore.Query;

      // Filtra por startup se informada
      if (startupId) {
        // Alterado: Removido orderBy para evitar exigência de índice composto em construção
        query = db
          .collection("marketOffers")
          .where("status", "==", "open")
          .where("startupId", "==", startupId);
      }

      const snapshot = await query.get();

      const ofertas: MarketOffer[] = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...(doc.data() as Omit<MarketOffer, "id">),
      }));

      // Alterado: Adicionada ordenação em memória para ordenar por preço sem depender do índice composto
      ofertas.sort((a, b) => a.precoPorTokenCents - b.precoPorTokenCents);

      response.status(200).send({
        sucesso: true,
        ofertas,
      });
    } catch (error) {
      logger.error("Erro ao listar ofertas de mercado.", error);
      response.status(500).send("Erro interno ao listar ofertas.");
    }
  },
);
