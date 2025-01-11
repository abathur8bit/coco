import 'package:dart6809/cpu.dart';
import 'package:dart6809/registers.dart';
import 'package:dart6809/addressing_mode.dart';
import 'package:sprintf/sprintf.dart';

class Mnemonic {
  final AddressingMode mode;
  final int Function() function;
  Mnemonic(this.mode, this.function);
}

class Cpu6809 extends Cpu {
  static String cpuName="6809";
  static int normalRamSize = 128*1024;
  static int expandedRamSize = 512*1024;
  Registers regs;
  Cpu6809.normal() : regs = Registers(),super(cpuName,List<int>.filled(normalRamSize, 0));
  Cpu6809.expanded() : regs = Registers(),super(cpuName,List<int>.filled(expandedRamSize, 0));
  Cpu6809.withMemoryRegs(List<int> ram,Registers r) : regs = r,super(cpuName,ram);

  // Map<int,Mnemonic> mnemonics=<int,Mnemonic>{};
  Map<int,int Function()> mnemonics=<int,int Function()>{};


  set setRegs(Registers newRegs) {regs = newRegs;}
  int get pc => regs.pc.value;
  int get u => regs.u.value;
  int get s => regs.s.value;
  int get y => regs.y.value;
  int get x => regs.x.value;
  int get dp => regs.dp.value;
  int get a => regs.a.value;
  int get b => regs.b.value;
  int get d => regs.d.value;

  set pc(int value) {regs.pc.value = value;}
  set u(int value) {regs.u.value = value;}
  set s(int value) {regs.s.value = value;}
  set y(int value) {regs.y.value = value;}
  set x(int value) {regs.x.value = value;}
  set dp(int value) {regs.dp.value = value;}
  set a(int value) {regs.a.value = value;}
  set b(int value) {regs.b.value = value;}
  set d(int value) {regs.d.value = value;}

  void add(int opcode,int Function() m) {
    assert(!mnemonics.containsKey(opcode)); //ensure we don't already have the opcode
    mnemonics[opcode]=m;
  }

  void initOpcodes() {
    add(0x39,rtsInherent);
    add(0x86,ldaImmediate);
    add(0x96,ldaDirect);
    add(0xa6,ldaIndexed);
    add(0xb6,ldaExtended);
    add(0x108e,ldyImmediate);
    add(0x109E,ldyDirect);
    // add(0x39,Mnemonic(AddressingMode.inherent,rts_inherent));
    // add(0x86,Mnemonic(AddressingMode.immediate,lda_immediate));
    // add(0x96,Mnemonic(AddressingMode.direct,lda_direct));
    // add(0xa6,Mnemonic(AddressingMode.indexed,lda_indexed));
    // add(0xb6,Mnemonic(AddressingMode.extended,lda_extended));
  }
  @override
  void exec(int now) {
    if(mnemonics.isEmpty) initOpcodes();

    while(regs.pc.value<memory.length) {
      single();
    }
  }

  void single() {
    if(mnemonics.length==0) initOpcodes();
    print(sprintf("pc=%04x",[regs.pc.value]));
    int opcode = memory[regs.pc.vinc()];
    if (opcode == 0x39) return; // time to stop

    // if an opcode is 0x10 or 0x11, it is a 2-byte opcode
    if (opcode == 0x10 || opcode == 0x11) {
      // we need to read the second byte to get the full opcode
      // print("getting second byte for opcode");
      opcode = opcode * 0x100 + memory[regs.pc.vinc()];
    }

    int Function()? m = mnemonics[opcode];
    // print(sprintf("found mnemonic opcode=%04x (%d)",[opcode,opcode]));
    if (m != null) {
      m();
    }
  }

  int rtsInherent() {
    return 0;
  }

  int load8Immediate() {
    return memory[regs.pc.vinc()];
  }
  int load8Direct() {
    int address = regs.dp.value*0x100+memory[regs.pc.vinc()];
    return memory[address];
  }
  int load8Extended() {
    int address = memory[regs.pc.vinc()]*0x100+memory[regs.pc.vinc()];
    return memory[address];
  }
  int load8Indexed() {
    assert(false);  //not implemented
    return -1;
  }
  int load16Immediate() {
    return memory[regs.pc.vinc()]*0x100+memory[regs.pc.vinc()];
  }
  int load16Direct() {
    int address = regs.dp.value*0x100+memory[regs.pc.vinc()];
    print(sprintf("address=%04x a0=%02x a1=%02x dp=%02x",[address,memory[address],memory[address+1],regs.dp.value]));
    return memory[address]*0x100+memory[address+1];
  }
  int load16Extended() {
    int address = memory[regs.pc.vinc()]*0x100+memory[regs.pc.vinc()];
    return memory[address];
  }
  int load16Indexed() {
    assert(false);  //not implemented
    return -1;
  }
  int ldaImmediate() {
    regs.a.value = load8Immediate();
    return 1;
  }
  int ldaDirect() {
    regs.a.value = load8Direct();
    return 1;
  }
  int ldaIndexed() {
    return load8Indexed();
  }
  int ldaExtended() {
    regs.a.value = load8Extended();
    return 1;
  }

  int ldyImmediate() {
    regs.y.value = load16Immediate();
    return 1;
  }
  int ldyDirect() {
    regs.y.value = load16Direct();
    return 1;
  }
  int ldyIndexed() {
    regs.y.value = load16Indexed();
    return 1;
  }
  int ldyExtended() {
    regs.y.value = load16Extended();
    return 1;
  }
}

