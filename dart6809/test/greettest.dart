import 'package:test/test.dart';
import 'package:dart6809/greet.dart';

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