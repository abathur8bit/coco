import 'package:flutter6809/cpu.dart';
import 'package:flutter6809/registers.dart';
import 'package:flutter6809/addressing_mode.dart';
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
    // select instruction from db
    // select concat('add(0x',opcode,",",lower(mnemonic),mode,");") source from mnemonic where mnemonic=? order by opcode;
    add(0x39,rtsInherent);
    add(0x86,ldaImmediate);
    add(0x96,ldaDirect);
    add(0xa6,ldaIndexed);
    add(0xb6,ldaExtended);
    add(0xC6,ldbImmediate);
    add(0xD6,ldbDirect);
    add(0xE6,ldbIndexed);
    add(0xF6,ldbExtended);
    add(0xCC,lddImmediate);
    add(0xDC,lddDirect);
    add(0xEC,lddIndexed);
    add(0xFC,lddExtended);
    add(0x8E,ldxImmediate);
    add(0x9E,ldxDirect);
    add(0xAE,ldxIndexed);
    add(0xBE,ldxExtended);
    add(0x108e,ldyImmediate);
    add(0x109E,ldyDirect);
    add(0x10BE,ldyExtended);
    add(0x97,staDirect);
  }
  @override
  void exec(int now) {
    if(mnemonics.isEmpty) initOpcodes();

    while(regs.pc.value<memory.length) {
      if(single()==0) break;
    }
  }

  int single() {
    if(mnemonics.length==0) initOpcodes();
    // print(sprintf("pc=%04x",[regs.pc.value]));
    int opcode = memory[regs.pc.vinc()];
    if (opcode == 0x39) return 0; // time to stop

    // if an opcode is 0x10 or 0x11, it is a 2-byte opcode
    if (opcode == 0x10 || opcode == 0x11) {
      // we need to read the second byte to get the full opcode
      // print("getting second byte for opcode");
      opcode = opcode * 0x100 + memory[regs.pc.vinc()];
    }

    int Function()? m = mnemonics[opcode];
    // print(sprintf("found mnemonic opcode=%04x (%d)",[opcode,opcode]));
    assert(m != null);
    if (m != null) {
      return m();
    }
    return 0;
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
    int address = addressExtended(regs.pc.vinc(),regs.pc.vinc());
    return memory[address];
  }
  int load16Immediate() {
    return memory[addressImmediate(regs.pc.vinc())]*0x100+memory[addressImmediate(regs.pc.vinc())];
  }
  int load16Direct() {
    int address = addressDirect(regs.pc.vinc());
    return memory[address]*0x100+memory[address+1];
  }
  int load16Extended() {
    int address = addressExtended(regs.pc.vinc(),regs.pc.vinc());
    return memory[address]*0x100+memory[address+1];
  }
  int load8Indexed() {
    int postByte = memory[regs.pc.vinc()];
    if(postByte&0x80 == 0) {
      return memory[addressIndexed5bitOffset(postByte)];   // n,R 0RRnnnnn
    } else if(postByte&0x84==0x84) {
      return memory[addressIndexedNoOffset(postByte)];     // ,R 1RR0 0100
    }
    return 0;
  }
  int addressImmediate(int pc) {
    return pc;
  }
  int addressDirect(int pc) {
    return regs.dp.value*0x100+memory[pc];
  }
  int addressExtended(int pcHigh,int pcLow) {
    return memory[pcHigh]*0x100+memory[pcLow];
  }
  /// Return the address pointed to by postByte with 5-bit signed offset.
  /// Form n,R Opcode 0RRnnnnn 
  int addressIndexed5bitOffset(int postByte) {
    int registerBits = (postByte&0x60) >> 5;  //grab bits 65 and shift down (0110 0000)
    int offset = postByte&0x0f;   //grab bits 3210
    if(postByte&0x10 == 0x10) {
      offset = -(1+0xf-offset); // convert from twos complement
    }
    int address=0;
    switch(registerBits) {
      case 0: address=regs.x.value;
      case 1: address=regs.y.value;
      case 2: address=regs.u.value;
      case 3: address=regs.s.value;
    }
    return address+offset;
  }
  /// Return the address pointed to by postByte with no offset
  /// Form ,R Opcode 1RR00100
  int addressIndexedNoOffset(int postByte) {
    int registerBits = (postByte&0x60) >> 5;  //grab bits 65 and shift down (0110 0000)
    int address=0;
    switch(registerBits) {
      case 0: address=regs.x.value;
      case 1: address=regs.y.value;
      case 2: address=regs.u.value;
      case 3: address=regs.s.value;
    }
    return address;
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
    regs.a.value = load8Indexed();
    return 1;
  }
  int ldaExtended() {
    regs.a.value = load8Extended();
    return 1;
  }

  int ldbImmediate() {
    regs.b.value = memory[addressImmediate(regs.pc.vinc())];
    return 1;
  }
  int ldbDirect() {
    regs.b.value = memory[addressDirect(regs.pc.vinc())];
    return 1;
  }
  int ldbIndexed() {
    regs.b.value = load8Indexed();
    return 1;
  }
  int ldbExtended() {
    regs.b.value = load8Extended();
    return 1;
  }

  int lddImmediate() {
    regs.d.value = load16Immediate();
    return 1;
  }
  int lddDirect() {
    regs.d.value = load16Direct();
    return 1;
  }
  int lddIndexed() {
    regs.d.value = load16Indexed();
    return 1;
  }
  int lddExtended() {
    regs.d.value = load16Extended();
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
  int ldxImmediate() {
    regs.x.value = load16Immediate();
    return 1;
  }
  int ldxDirect() {
    regs.x.value = load16Direct();
    return 1;
  }
  int ldxIndexed() {
    regs.x.value = load16Indexed();
    return 1;
  }
  int ldxExtended() {
    regs.x.value = load16Extended();
    return 1;
  }

  int staDirect() {
    int address = addressDirect(regs.pc.vinc());
    memory[address] = regs.a.value;
    return 1;
  }
}

