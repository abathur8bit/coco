import 'package:flutter_test/flutter_test.dart';
import 'package:flutter6809/condition_code_register.dart';

void main() {
  test('zero',() {
    ConditionCodeRegister ccreg = ConditionCodeRegister.zero();
    expect(false,ccreg.entire);
    expect(false,ccreg.firq);
    expect(false,ccreg.halfCarry);
    expect(false,ccreg.irq);
    expect(false,ccreg.negative);
    expect(false,ccreg.zero);
    expect(false,ccreg.overflow);
    expect(false,ccreg.carry);
  });

  test('construct',() {
    ConditionCodeRegister ccreg = ConditionCodeRegister(false,true,true,true,true,true,true,false);
    expect(false,ccreg.entire);
    expect(true,ccreg.firq);
    expect(true,ccreg.halfCarry);
    expect(true,ccreg.irq);
    expect(true,ccreg.negative);
    expect(true,ccreg.zero);
    expect(true,ccreg.overflow);
    expect(false,ccreg.carry);

    ccreg.zero = false;
    expect(false,ccreg.zero);
  });


}