/// Condition code register.
///                                        Condition Code Register
///                                   -------------------------------
///                                  | E | F | H | I | N | Z | V | C |
///                                   -------------------------------
///                     Entire flag____|   |   |   |   |   |   |   |____Carry flag
///                       FIRQ mask________|   |   |   |   |   |________Overflow
///                      Half carry____________|   |   |   |____________Zero
///                        IRQ mask________________|   |________________Negative
import 'package:dart6809/registers.dart';
class ConditionCodeRegister extends Register8bit {
  bool entire;
  bool firq;
  bool halfCarry;
  bool irq;
  bool negative;
  bool zero;
  bool overflow;
  bool carry;

  ConditionCodeRegister(
      this.entire,
      this.firq,
      this.halfCarry,
      this.irq,
      this.negative,
      this.zero,
      this.overflow,
      this.carry);

  ConditionCodeRegister.zero() :
    entire=false,
    firq=false,
    halfCarry=false,
    irq=false,
    negative=false,
    zero=false,
    overflow=false,
    carry=false;

  void clearAll() {
    entire=false;
    firq=false;
    halfCarry=false;
    irq=false;
    negative=false;
    zero=false;
    overflow=false;
    carry=false;
  }

  bool isEntire() {
    return entire;
  }

  ConditionCodeRegister setEntire(bool entire) {
    this.entire = entire;
    return this;
  }

  // bool isFirq() {
  //   return firq;
  // }
  //
  // ConditionCodeRegister setFirq(bool firq) {
  //   this.firq = firq;
  //   return this;
  // }
  //
  // bool isHalfCarry() {
  //   return halfCarry;
  // }
  //
  // ConditionCodeRegister setHalfCarry(bool halfCarry) {
  //   this.halfCarry = halfCarry;
  //   return this;
  // }
  //
  // bool isIrqMask() {
  //   return irq;
  // }
  //
  // ConditionCodeRegister setIrqMask(bool irqMask) {
  //   irq = irqMask;
  //   return this;
  // }
  //
  // bool isNegative() {
  //   return negative;
  // }
  //
  // ConditionCodeRegister setNegative(bool negative) {
  //   this.negative = negative;
  //   return this;
  // }
  //
  // bool isZero() {
  //   return zero;
  // }
  //
  // ConditionCodeRegister setZero(bool zero) {
  //   this.zero = zero;
  //   return this;
  // }
  //
  // bool isOverflow() {
  //   return overflow;
  // }
  //
  // ConditionCodeRegister setOverflow(bool overflow) {
  //   this.overflow = overflow;
  //   return this;
  // }
  //
  // bool isCarry() {
  //   return carry;
  // }
  //
  // ConditionCodeRegister setCarry(bool carry) {
  //   this.carry = carry;
  //   return this;
  // }
}