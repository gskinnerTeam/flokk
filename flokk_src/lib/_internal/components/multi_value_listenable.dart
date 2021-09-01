import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  ValueListenableBuilder2(
      {Key? key,
      required this.value1,
      required this.value2,
      required this.builder,
      this.child})
      : super(key: key);

  final ValueListenable<A> value1;
  final ValueListenable<B> value2;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: value1,
      builder: (_, a, __) => ValueListenableBuilder<B>(
        valueListenable: value2,
        builder: (context, b, __) => builder(context, a, b, child),
      ),
    );
  }
}

class ValueListenableBuilder3<A, B, C> extends StatelessWidget {
  ValueListenableBuilder3(
      {Key? key,
      required this.value1,
      required this.value2,
      required this.value3,
      required this.builder,
      this.child})
      : super(key: key);

  final ValueListenable<A> value1;
  final ValueListenable<B> value2;
  final ValueListenable<C> value3;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, C c, Widget? child)
      builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: value1,
      builder: (_, a, __) => ValueListenableBuilder2<B, C>(
        value1: value2,
        value2: value3,
        builder: (context, b, c, __) => builder(context, a, b, c, child),
      ),
    );
  }
}

class ValueListenableBuilder4<A, B, C, D> extends StatelessWidget {
  ValueListenableBuilder4(this.value1, this.value2, this.value3, this.value4,
      {Key? key, required this.builder, this.child})
      : super(key: key);

  final ValueListenable<A> value1;
  final ValueListenable<B> value2;
  final ValueListenable<C> value3;
  final ValueListenable<D> value4;

  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, C c, D d, Widget? child)
      builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<A, B>(
      value1: value1,
      value2: value2,
      builder: (_, a, b, __) => ValueListenableBuilder2<C, D>(
        value1: value3,
        value2: value4,
        builder: (context, c, d, __) => builder(context, a, b, c, d, child),
      ),
    );
  }
}
