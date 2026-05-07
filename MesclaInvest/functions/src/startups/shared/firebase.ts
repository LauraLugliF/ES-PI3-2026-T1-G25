// Max Thomazini Barbosa RA:25003934
import {getAuth} from "firebase-admin/auth";
import {getApps, getApp, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

// Garante que o Firebase Admin seja inicializado apenas uma vez no ambiente das functions.
// Mantemos a referência da app: se já existir usamos getApp(), caso contrário inicializamos.
const app = getApps().length === 0 ? initializeApp() : getApp();

// Instâncias compartilhadas para autenticação e acesso ao Firestore.
// Passamos `app` explicitamente e usamos o databaseId nomeado 'projeto3'.
export const auth = getAuth(app);
export const db = getFirestore(app, "projeto3");
