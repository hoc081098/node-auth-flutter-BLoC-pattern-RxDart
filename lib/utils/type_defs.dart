typedef Function0<T> = T Function();

typedef Function1<P0, R> = R Function(P0);

typedef Function2<P0, P1, R> = R Function(P0, P1);

typedef Function3<P0, P1, P2, R> = R Function(P0, P1, P2);

extension PipeFunction1Extension<T, R> on Function1<T, R> {
  Function1<T, S> pipe<S>(Function1<R, S> other) => (t) => other(this(t));
}

String trim(String s) => s.trim();
