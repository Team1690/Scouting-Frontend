T Function() always<T>(final T result) => () => result;
T Function(I) always2<T, I>(final T result) => (final I _ignored) => result;
T identity<T>(final T result) => result;

extension MapNullable<A> on A? {
  B fold<B>(final B Function() onEmpty, final B Function(A) onSome) =>
      this == null ? onEmpty() : onSome(this as A);

  B? mapNullable<B>(final B Function(A) f) => fold(always(null), f);

  B? onNullDo<B>(final B Function() f) => fold(f, always2(null));

  B? onNull<B>(final B value) => onNullDo(always(value));

  A orElseDo(final A Function() f) => fold(f, identity);

  A orElse(final A value) => orElseDo(always(value));
}
