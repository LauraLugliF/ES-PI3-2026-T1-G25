// Reexporta helpers e handlers do módulo de exchange para simplificar o ponto de entrada principal.
export {getUserBalance} from "./repositories/userRepository";
export {getUserBalanceHandler} from "./handlers/getUserBalance";
export {getUserTokensHandler} from "./handlers/getUserTokens";
export {addDepositHandler} from "./handlers/addDeposit";
export {buyTokensHandler} from "./handlers/buyTokens";
export {sellTokensHandler} from "./handlers/sellTokens";

// Funções do mercado P2P, responsáveis pelo fluxo de ofertas entre usuários.
export {createMarketOfferHandler} from "./handlers/createMarketOffer";
export {listMarketOffersHandler} from "./handlers/listMarketOffers";
export {acceptMarketOfferHandler} from "./handlers/acceptMarketOffer";
export {cancelMarketOfferHandler} from "./handlers/cancelMarketOffer";
