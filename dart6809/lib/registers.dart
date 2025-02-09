import 'package:dart6809/condition_code_register.dart';

abstract class Register {
  int registerValue;
  int get value {return registerValue;}
  set value(int n){registerValue = n&mask();}
  int mask();
  int size();
  shiftLeft() => registerValue *= 2;
  shiftRight() => registerValue = registerValue ~/ 2;
  Register({this.registerValue = 0});
  /// Returns the value after an increment. If `v=5` then `inc()` will return `6`.
  int inc() {return ++registerValue;}
  /// Returns the current value, and increments. If `registerValue=5` then `vinc()`
  /// will return `5` and `registerValue` will be `6` after the call.
  int vinc() {int n=registerValue++; return n;}
}
class Register8bit extends Register {
  @override
  int mask() => 0xff;
  @override
  int size() => 8;
}

class Register16bit extends Register {
  @override
  int mask() => 0xffff;
  @override
  int size() => 16;
}

class RegisterCombined extends Register {
  Register high;  // high order byte 0xFF00
  Register low;   // low order by te 0x00FF
  @override
  int mask() => 0xffff;
  @override
  int size() => 16;
  @override
  int get value {return high.value*0x100+low.value;}
  set regD(newValue) {high.value = (newValue&0xff00)/0x100; low.value = newValue&low.mask();}
  RegisterCombined(this.high,this.low);
}

class Registers {
  Register pc = Register16bit();
  Register u = Register16bit();
  Register s = Register16bit();
  Register y = Register16bit();
  Register x = Register16bit();
  Register dp = Register8bit();
  Register a = Register8bit();
  Register b = Register8bit();
  late Register d;
  ConditionCodeRegister regCC = ConditionCodeRegister.zero();
  Registers() {d = RegisterCombined(a,b);}
}