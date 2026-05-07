import {addUser} from "./cadastro/index";
import {setGlobalOptions} from "firebase-functions";

// Limita o número de instâncias para evitar excesso de concorrência nas functions.
setGlobalOptions({maxInstances: 10});

// Expõe a function de cadastro no ponto de entrada principal.
export {addUser};

// Reexporta todas as functions relacionadas ao módulo de startups.
export * from "./startups";
