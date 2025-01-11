import 'package:flutter6809/cpu6809.dart';
import 'package:flutter6809/registers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter6809/cpu.dart';

void main() {
  const String cpuName = "6809";
  const int ramSize = 64*1024;
  List<int> ram = List<int>.filled(ramSize, 0);
  test('cpu',() {
    Cpu c = Cpu(cpuName,ram);
    expect("cpu",c.type);
    expect(cpuName,c.name);
    expect(ramSize,c.memory.length);
    expect(0,c.memory[0]);
  });

  test('cpu cycles',() {
    Cpu c = Cpu(cpuName,ram);
    c.addCycleCounter(5);
    expect(5,c.cycleCounter);
  });

  test('peek poke memory',() {
    Cpu c = Cpu(cpuName,ram);
    c.poke(0x400,255);
    expect(255,c.memory[0x400]);
    expect(255,c.peek(0x400));

    //set range
    List<int> source = [1,2,3,4,5,6,7,8,9];
    int offset=0x400;
    c.setRange(offset,source);
    for(int i=0; i<source.length; i++) {
      expect(source[i],c.peek(offset+i));
    }

    //replacing memory
    c.setMemory(source);
    expect(source.length,c.memory.length);
    for(int i=0; i<source.length; i++) {
      expect(source[i],c.peek(i));
    }
  });


}