import 'package:dart6809/emulator_device.dart';

class Cpu extends EmulatorDevice {
  static const String deviceType = "cpu";
  int cycleCounter;
  List<int> memory;
  Cpu(String name,List<int> ram) :
        cycleCounter=0,
        memory = ram,
        super(name:name,type:deviceType);

  void exec(int now) {}
  void addCycleCounter(int amount) {
    cycleCounter += amount;
  }
  void poke(int address,int value) {
    memory[address] = value;
  }
  int peek(int address) {
    return memory[address];
  }
  void setMemory(List<int> source) {
    memory = source;
  }
  void setRange(int offset,List<int> source) {
    for(int i=0; i<source.length; i++) {
      memory[offset+i] = source[i];
    }
  }
}