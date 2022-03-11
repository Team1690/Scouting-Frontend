extension Cast<E extends num> on Iterable<E> {
  Iterable<V> castToGeneric<V extends num>() {
    return map((final E e) {
      if (V == int) {
        return e.toInt() as V;
      } else if (V == double) {
        return e.toDouble() as V;
      }
      throw Exception("Shoudn't happen");
    });
  }
}
