require_relative "../spec_helper"

context BrainBend::Interpreter do
  it "gets created" do
    expect { BrainBend::Interpreter.new }.to_not raise_error
  end

  context "initializing" do
    subject { BrainBend::Interpreter.new }

    context "memory" do

      it "has an array with one byte" do
        subject.memory.should eq([0])
      end

      it "has a memory pointer of position 0" do
        subject.memory_pointer.should eq(0)
      end
    end

    it "returns the current byte" do
      subject.current_byte.should eq(0)
    end

  end

  context ">" do
    subject { BrainBend::Interpreter.new(memory: [0, 0], memory_pointer: 0) }

    it "moves the memory pointer one position to the right" do
      subject.>
      subject.memory_pointer.should eq(1)
    end

    it "initializes a new location with a 0" do
      subject.>; subject.>
      subject.memory.should eq([0, 0, 0])
    end
  end

  context "<" do
    subject { BrainBend::Interpreter.new(memory: [0, 0], memory_pointer: 1) }
    it "moves the memory pointer one position to the left" do
      subject.<
      subject.memory_pointer.should eq(0)
    end

  end

  context "+" do
    subject { BrainBend::Interpreter.new(memory: [0, 255], memory_pointer: 0) }
    it "adds 1 to the existing value" do
      subject.+
      subject.memory.should eq([1, 255])
      subject.+
      subject.memory.should eq([2, 255])
    end

    it "wraps from 255 to 0" do
      subject.>
      subject.+
      subject.memory.should eq([0, 0])
    end
  end

  context "-" do
    subject { BrainBend::Interpreter.new(memory: [0, 255], memory_pointer: 1) }
    it "subtracts 1 from the existing value" do
      subject.-
      subject.memory.should eq([0, 254])
      subject.-
      subject.memory.should eq([0, 253])
    end

    it "wraps from 0 to 255" do
      subject.<
      subject.-
      subject.memory.should eq([255, 255])
    end
  end

  context "i" do
    subject { BrainBend::Interpreter.new(memory: [0], memory_pointer: 0, input_string: "Hi", input_pointer: 0) }
    it "sets a byte based on the current input string" do
      subject.i
      subject.memory.should eq(["H".ord])
      subject.input_pointer.should eq(1)
    end

    it "overwrites existing data" do
      subject.i
      subject.i
      subject.memory.should eq(["i".ord])
      subject.input_pointer.should eq(2)
    end

    it "ignores input beyond end of string" do
      subject.i
      subject.i
      subject.i
      subject.memory.should eq(["i".ord])
      subject.input_pointer.should eq(3)
    end
  end

  context "o" do
    subject { BrainBend::Interpreter.new(memory: [72, 105], memory_pointer: 0, output_string: "") }
    it "appends a byte to the output string" do
      subject.o
      subject.output_string.should eq("H")
    end

    it "appends the current byte to the output string" do
      subject.o
      subject.o
      subject.output_string.should eq("HH")
    end

    it "ignores input beyond end of string" do
      subject.o
      subject.>
      subject.o
      subject.output_string.should eq("Hi")
    end
  end

  context "gosub" do
    
    it "goes to the next matching symbol" do
      subject = BrainBend::Interpreter.new(code_string: "[<[.],[>]+]-", code_pointer: 2)
      subject.gosub
      subject.code_pointer.should == 4
    end

    it "skips intermediary non-matching symbols" do
      subject = BrainBend::Interpreter.new(code_string: "[<[.],[>]+]-", code_pointer: 0 )
      subject.gosub
      subject.code_pointer.should == 10
    end

    it "does not change the code pointer when the current byte is nonzero" do
      subject = BrainBend::Interpreter.new(code_string: "[<[.],[>]+]-", code_pointer: 0, memory: [1] )
      subject.gosub
      subject.code_pointer.should == 0
    end
  end

  context "ret" do
    
    it "goes to the previous matching symbol" do
      subject = BrainBend::Interpreter.new(code_string: "[<[.],[>]+]-", code_pointer: 4, memory: [1])
      subject.ret
      subject.code_pointer.should == 2
    end

    it "skips intermediary non-matching symbols" do
      subject = BrainBend::Interpreter.new(code_string: "[<[.],[>]+]-", code_pointer: 10, memory: [1] )
      subject.ret
      subject.code_pointer.should == 0
    end

    it "does not change the code pointer when the current byte is 0" do
      subject = BrainBend::Interpreter.new(code_string: "[<[.],[>]+]-", code_pointer: 10, memory: [0] )
      subject.ret
      subject.code_pointer.should == 10
    end

  end

  context "interpret!" do
    subject { BrainBend::Interpreter.new(input_string: "Ii.", code_string: ",-.>,.>,-------------.") }
    it "interprets the code" do
      subject.interpret!
      subject.output_string.should eq("Hi!")
    end
  end

end