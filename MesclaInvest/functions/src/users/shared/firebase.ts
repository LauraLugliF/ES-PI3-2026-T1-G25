// Max Thomazini Barbosa RA:25003934
import {getApp, getApps, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

const app = getApps().length === 0 ? initializeApp() : getApp();

export const db = getFirestore(app, "projeto3");
export const usersCollection = db.collection("users");
