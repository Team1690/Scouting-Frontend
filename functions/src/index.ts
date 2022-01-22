import * as functions from "firebase-functions";

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

// See https://hasura.io/docs/latest/graphql/core/auth/authentication/webhook.html
// and https://github.com/hasura/graphql-engine/tree/master/community/boilerplates/auth-webhooks/nodejs-express
// and https://github.com/hasura/graphql-engine/blob/master/community/boilerplates/auth-webhooks/nodejs-firebase/firebase/firebaseHandler.js
export const hasuraExample = functions.https.onRequest((request, response) => {
  functions.logger.info("Hasura example logs:", {structuredData: true});
  functions.logger.info(request);
  response.send({
    "X-Hasura-User-Id": request.headers.userId,
    "X-Hasura-Role": "scouter",
    "X-Hasura-Is-Owner": "false",
    "X-Hasura-Custom": "not used",
    "Cache-Control": "max-age=600",
  });
});
