import 'package:flutter_test/flutter_test.dart';
import 'package:flutter6809/registers.dart';
import 'package:flutter6809/cpu6809.dart';
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

  test("exec",() {
    List<int> source = [0x86,0xFF,0x96,0x02,0xB6,0x00,0x07,0x39];
    Registers regs = Registers();
    Cpu6809 c = Cpu6809.withMemoryRegs(source,regs);
    c.exec(0);
    expect(0x39,c.a);
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



  test("ldb immediate",() {
    List<int> source = [0xC6,0xAB,0x39];
    List<int> data = [0x00,0x11,0x22,0x33];
    Cpu6809 c = Cpu6809.normal();
    c.regs.dp.value = 0x0b;
    c.regs.pc.value = 0x3f00;
    c.setRange(0xb00,data);
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.b,0xab);
  });

  test("ldb direct",() {
    // ldb     <$3           ; B direct
    // rts
    List<int> source = [0xD6,0x03,0x39];
    List<int> data = [0x00,0x11,0x22,0x33];
    Cpu6809 c = Cpu6809.normal();
    c.regs.dp.value = 0x0b;
    c.regs.pc.value = 0x3f00;
    c.setRange(0xb00,data);
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.b,0x33);
  });

  test("ldb extended",() {
    // ldb     $b01           ; B extended
    // rts
    List<int> source = [0xF6,0x0B,0x01,0x39];
    List<int> data = [0x00,0x11,0x22,0x33];
    Cpu6809 c = Cpu6809.normal();
    c.regs.dp.value = 0x0b;
    c.regs.pc.value = 0x3f00;
    c.setRange(0xb00,data);
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.b,0x11);
  });

  test("ldd immediate",() {
    // ldd     #$1223        ; D immediate
    // rts
    List<int> source = [0xCC,0x12,0x23,0x39];
    Cpu6809 c = Cpu6809.normal();
    c.regs.pc.value = 0x3f00;
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.d,0x1223);
    expect(c.pc,0x3f04);
  });
  test("ldd direct",() {
    // ldd     <$2          ; D direct
    // rts
    List<int> data = [0x00,0x11,0x22,0x33];
    List<int> source = [0xDC,0x02,0x39];
    Cpu6809 c = Cpu6809.normal();
    c.regs.dp.value = 0x0b;
    c.regs.pc.value = 0x3f00;
    c.setRange(0xb00,data);
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.d,0x2233);
  });
  test("ldd extended",() {
    // ldd     $b01          # D extended
    // rts
    List<int> data = [0x00,0x11,0x22,0x33];
    List<int> source = [0xFC,0x0B,0x01,0x39];
    Cpu6809 c = Cpu6809.normal();
    c.regs.pc.value = 0x3f00;
    c.setRange(0xb00,data);
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.d,0x1122);
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
    c.regs.dp.value = 0x0b;
    c.regs.pc.value = 0x3f00;
    c.setRange(0xb00,data);
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.y,0x1122);
  });
  test("ldy extended",() {
    List<int> data = [0x00,0x11,0x22,0x33];
    List<int> source = [0x10,0xBE,0x0B,0x02,0x39];
    Cpu6809 c = Cpu6809.normal();
    c.regs.pc.value = 0x3f00;
    c.setRange(0xb00,data);
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.y,0x2233);
    expect(c.pc,0x3f05);
  });
  test("ldx immediate",() {
    // ldx     #$123f           ; X immediate
    // rts
    List<int> source = [0x8E,0x12,0x3F,0x39];
    Cpu6809 c = Cpu6809.normal();
    c.regs.pc.value = 0x3f00;
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.x,0x123f);
    expect(c.pc,0x3f04);
  });
  test("ldx direct",() {
    // ldx     <2           ; X direct
    // rts
    List<int> data = [0x00,0x11,0x22,0x33];
    List<int> source = [0x9E,0x02,0x39];
    Cpu6809 c = Cpu6809.normal();
    c.regs.dp.value = 0x0b;
    c.regs.pc.value = 0x3f00;
    c.setRange(0xb00,data);
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.x,0x2233);
  });
  test("ldx extended",() {
    // ldx     $0b01           ; X extended
    // rts
    List<int> data = [0x00,0x11,0x22,0x33];
    List<int> source = [0xBE,0x0B,0x01,0x39];
    Cpu6809 c = Cpu6809.normal();
    c.regs.dp.value = 0x0b;
    c.regs.pc.value = 0x3f00;
    c.setRange(0xb00,data);
    c.setRange(0x3f00,source);
    c.exec(0);
    expect(c.x,0x1122);
  });

  test("lda 1,u",() {
    Cpu6809 c = Cpu6809.normal();
    int dataAddress = 0x0b00;
    int sourceAddress = 0x3f00;
    c.regs.u.value = dataAddress;
    setupTest([0xA6,0x41,0x39],[0x00,0x11,0x22,0x33],c,sourceAddress,dataAddress);
    expect(c.a,0x11);
  });
  test("lda 5-bit signed offset",() {
    List<int> data = [0x10,0x11,0x22,0x33];
    Cpu6809 c = Cpu6809.normal();
    int dataAddress = 0x0b00;
    int sourceAddress = 0x3f00;

    // lda -1,x
    c = Cpu6809.normal();
    c.regs.x.value = dataAddress+1;
    setupTest([0xA6,0x1f,0x39],data,c,sourceAddress,dataAddress);
    expect(c.a,0x10);

    // lda 1,x
    c = Cpu6809.normal();
    c.regs.x.value = dataAddress;
    setupTest([0xA6,0x01,0x39],data,c,sourceAddress,dataAddress);
    expect(c.a,0x11);

    // lda 1,y
    c = Cpu6809.normal();
    c.regs.y.value = dataAddress;
    setupTest([0xA6,0x21,0x39],data,c,sourceAddress,dataAddress);
    expect(c.a,0x11);

    // lda 1,u
    c = Cpu6809.normal();
    c.regs.u.value = dataAddress;
    setupTest([0xA6,0x41,0x39],data,c,sourceAddress,dataAddress);
    expect(c.a,0x11);

    // lda 1,s
    c = Cpu6809.normal();
    c.regs.s.value = dataAddress;
    setupTest([0xA6,0x61,0x39],data,c,sourceAddress,dataAddress);
    expect(c.a,0x11);
  });

  test("LD no offset",() {
    List<int> data = [0x10,0x11,0x22,0x33];
    Cpu6809 c = Cpu6809.normal();
    int dataAddress = 0x0b00;
    int sourceAddress = 0x3f00;

    // lda ,x
    c = Cpu6809.normal();
    c.regs.x.value = dataAddress; //point to element 0
    setupTest([0xA6,0x84,0x39],data,c,sourceAddress,dataAddress);
    expect(c.a,0x10);

    // ldb ,y
    c = Cpu6809.normal();
    c.regs.y.value = dataAddress+2; //point to element 2
    setupTest([0xE6,0xA4,0x39],data,c,sourceAddress,dataAddress);
    expect(c.b,0x22);

    // lda ,u
    c = Cpu6809.normal();
    c.regs.u.value = dataAddress+1; //point to element 1
    setupTest([0xA6,0xC4,0x39],data,c,sourceAddress,dataAddress);
    expect(c.a,0x11);

    // ldb ,s
    c = Cpu6809.normal();
    c.regs.s.value = dataAddress+3; //point to element 3
    setupTest([0xE6,0xE4,0x39],data,c,sourceAddress,dataAddress);
    expect(c.b,0x33);
  });
}

void setupTest(List<int> source,List<int> data,Cpu6809 c,int sourceAddress,int dataAddress) {
  c.regs.pc.value = sourceAddress;
  c.setRange(dataAddress,data);
  c.setRange(sourceAddress,source);
  c.exec(0);
}