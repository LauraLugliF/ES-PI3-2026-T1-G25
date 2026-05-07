//Max Thomazini Barbosa RA:25003934
import {getAuth} from "firebase-admin/auth";
import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

// Garante que o Firebase Admin seja inicializado apenas uma vez no ambiente das functions.
if (getApps().length === 0) {
  initializeApp();
}

// Instâncias compartilhadas para autenticação e acesso ao Firestore.
export const auth = getAuth();
export const db = getFirestore();