import "package:firebase_functions_interop/firebase_functions_interop.dart";

void main() {
    functions["moin"] = functions
            .region("europe-central2")
            .https.onRequest(greet);
}

void greet(ExpressHttpRequest request) {
    request.response
            ..writeln("Moin, moin!")
            ..close();
}
