import 'package:flutter_test/flutter_test.dart';
import 'package:flutter6809/registers.dart';
void main() {
  test('inc',() {
    Register reg = Register8bit();
    reg.value=1;
    reg.inc();              //inc to 2
    expect(2,reg.value);    //new value
    expect(3,reg.inc());    //returns new value after increment
    expect(3,reg.vinc());   //returns current value, then increments
    expect(4,reg.value);    //new value
  });
  test('reg 8 bit', () {
    Register reg = Register8bit();
    expect(8, reg.size());
    expect(0xff, reg.mask());
    expect(0, reg.value);
    reg.value = 0xabcd;
    expect(0xcd,reg.value);
    reg.value = 4;
    reg.shiftLeft();
    expect(8,reg.value);
    reg.shiftRight();
    expect(4,reg.value);
  });

  test('reg 16 bit', () {
    Register reg = Register16bit();
    expect(16, reg.size());
    expect(0xffff, reg.mask());
    expect(0,reg.value);
    reg.value = 0xabcd;
    expect(0xabcd,reg.value);
    reg.value = 0xabcd1234;
    expect(0x1234,reg.value);
    reg.value = 0x1234;
    reg.shiftLeft();
    expect(0x2468,reg.value);
    reg.shiftRight();
    expect(0x1234,reg.value);
  });

  test('correct size',() {
    Registers regs = Registers();
    expect(16,regs.pc.size());
    expect(16,regs.u.size());
    expect(16,regs.s.size());
    expect(16,regs.y.size());
    expect(16,regs.x.size());
    expect( 8,regs.dp.size());
    expect( 8,regs.a.size());
    expect( 8,regs.b.size());
    expect(16,regs.d.size());
  });

  test('reg D',() {
    Registers regs = Registers();
    expect( 8,regs.a.size());
    expect( 8,regs.b.size());
    expect(16,regs.d.size());
    regs.a.value = 0x12;
    regs.b.value = 0x34;
    expect(regs.d.value,0x1234);

    regs.d.value = 0xabcd;
    expect(regs.d.value,0xabcd);
    expect(regs.a.value,0xab);
    expect(regs.b.value,0xcd);
  });
}