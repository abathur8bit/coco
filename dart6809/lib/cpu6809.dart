import 'package:dart6809/cpu.dart';
import 'package:dart6809/registers.dart';

class Cpu6809 extends Cpu {
  static String cpuName="6809";
  static int normalRamSize = 128*1024;
  static int expandedRamSize = 512*1024;
  Registers regs;
  Cpu6809.normal() : regs = Registers(),super(cpuName,List<int>.filled(normalRamSize, 0));
  Cpu6809.expanded() : regs = Registers(),super(cpuName,List<int>.filled(expandedRamSize, 0));
  Cpu6809.withMemoryRegs(List<int> ram,Registers r) : regs = r,super(cpuName,ram);
  set setRegs(Registers newRegs) {regs = newRegs;}
  set pc(int value) {regs.pc.value = value;}
  int get pc => regs.pc.value;
}
