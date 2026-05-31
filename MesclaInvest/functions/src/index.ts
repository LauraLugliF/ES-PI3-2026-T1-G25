import {addUser} from "./users/index";
import {setGlobalOptions} from "firebase-functions";

// Configuração global do runtime das Functions para manter o consumo de recursos controlado.
setGlobalOptions({maxInstances: 10});

// Expõe as funções do módulo de usuários diretamente no ponto de entrada principal.
export {addUser};
export {getUserPhoneNumber} from "./users/index";

// Reexporta o módulo de startups como parte do bundle principal das Functions.
export * from "./startups";

// Reexporta o módulo de exchange, que inclui o fluxo de depósito, compra e venda.
export * from "./exchange";

