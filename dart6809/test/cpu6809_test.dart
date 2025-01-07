import 'package:dart6809/registers.dart';
import 'package:test/test.dart';
import 'package:dart6809/cpu6809.dart';

void main() {
  const String cpuName = "6809";
  const int normalRamSize = 128*1024;
  const int expandedRamSize = 512*1024;
  test('cpu normal', () {
    Cpu6809 cpu = Cpu6809.normal();
    expect(cpuName, cpu.name);
    expect("cpu", cpu.type);
    expect(normalRamSize, cpu.memory.length);
  });
  test('cpu expanded',() {
    Cpu6809 cpu = Cpu6809.expanded();
    expect(cpuName, cpu.name);
    expect("cpu", cpu.type);
    expect(expandedRamSize, cpu.memory.length);
  });
  test('pass in memory',() {
    List<int> ram = [1,2,3,4,5,6,7,8,9];
    Registers regs = Registers();
    Cpu6809 cpu = Cpu6809.withMemoryRegs(ram,regs);
    for(int i=0; i<ram.length; i++) {
      expect(ram[i],cpu.peek(i));
    }
  });
}