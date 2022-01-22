import * as functions from "firebase-functions";

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

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
