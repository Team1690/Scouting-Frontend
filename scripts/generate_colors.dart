import "package:faker/faker.dart";

void main(final List<String> args) {
  for (int i = 0; i < 100; i++) {
    // ignore: avoid_print
    print(
      "Color.fromARGB(255,${random.integer(255)},${random.integer(255)},${random.integer(255)}),",
    );
  }
}
