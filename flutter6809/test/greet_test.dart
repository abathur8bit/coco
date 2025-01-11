import 'package:flutter_test/flutter_test.dart';
import 'package:flutter6809/greet.dart';

void main() {
  group("greet",() {
    test("hello",() {
      Greet g=Greet();
      expect("Hello lee",g.greet("lee"));
    });
    test("bye",() {
      Greet g=Greet();
      expect("bye-bye",g.bye());
    });
  });
}