import 'package:dart6809/registers.dart';
import 'package:test/test.dart';
import 'package:dart6809/cpu6809.dart';
import 'package:sprintf/sprintf.dart';

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

    regs.pc.value = 0x400;
    expect(0x400,cpu.pc);
  });
  test("lda",() {
    List<int> source = [0x86,0xFF,0x96,0x02,0xB6,0x00,0x07,0x39];
    Registers regs = Registers();
    Cpu6809 c = Cpu6809.withMemoryRegs(source,regs);
    c.single();
    expect(0xff,c.a);

    c.single();
    expect(0x96,c.a);

    c.single();
    expect(0x39,c.a);
  });

  test("exec",() {
    List<int> source = [0x86,0xFF,0x96,0x02,0xB6,0x00,0x07,0x39];
    Registers regs = Registers();
    Cpu6809 c = Cpu6809.withMemoryRegs(source,regs);
    c.exec(0);
    expect(0x39,c.a);
  });

  test("ldy immediate",() {
    List<int> source = [0x10,0x8E,0x12,0x34,0x39];
    Registers regs = Registers();
    Cpu6809 c = Cpu6809.withMemoryRegs(source,regs);
    c.exec(0);
    expect(c.y,0x1234);
  });
  test("ldy direct",() {
    List<int> data = [0x00,0x11,0x22,0x33];
    List<int> source = [0x10,0x9E,0x01,0x39];
    Cpu6809 c = Cpu6809.normal();
    c.regs.dp.value = 0x0b00;
    c.regs.pc.value = 0x3f00;
    c.setRange(0xb00,data);
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.y,0x1122);
  });
}