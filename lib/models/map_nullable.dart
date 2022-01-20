extension MapNullable<A> on A? {
  //call f if this isn't null and return null if it is
  B? mapNullable<B>(final B Function(A) f) =>
      this == null ? null : f(this as A);

  //call function if this is null and return null if it isn't
  B? onNullDo<B>(final B Function() f) => this == null ? f() : null;

  //return value if this is null and return this if this isn't
  B? onNull<B>(final B value) => onNullDo(() => value);

  //call function if this is null and return this if it isn't
  A orElseDo(final A Function() f) => onNullDo(f) ?? this as A;

  //return value if this is null and return this if it isn't
  A orElse(final A value) => orElseDo(() => value);
}
