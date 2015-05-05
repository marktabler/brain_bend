require_relative "brain_bend/version"

# Hello World:
# ++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.
# ROT13
#
# -,+[-[>>++++[>++++++++<-]<+<-[>+>+>-[>>>]<[[>+<-]>>+>]<<<<<-]]>>>[-]+>--[-[<->+++[-]]]<[++++++++++++<[>-[>+>>]>[+[<+>-]>+>>]<<<<<-]>>[<+>-]>[-[-<<[-]>>]<<[<<->>-]>>]<<[<<+>>-]]<[-]<.[-]<-,+]


module BrainBend
  class Interpreter

    def initialize(state = {})
      @memory = state[:memory] || [0]
      @memory_pointer = state[:memory_pointer] || 0
      @input_string = state[:input_string] || ""
      @input_pointer = state[:input_pointer] || 0
      @output_string = state[:output_string] || ""
      @code_string = state[:code_string] || ""
      @code_pointer = state[:code_pointer] || 0
    end

    def interpret!
      while current_instruction
        case current_instruction
        when "."
          self.o
        when ","
          self.i
        when "["
          self.gosub
        when "]"
          self.ret
        else
          self.send(current_instruction.to_sym)
        end
        @code_pointer += 1
      end
    end

    def current_instruction
      @code_string[@code_pointer]
    end      

    def code_pointer
      @code_pointer
    end

    def memory
      @memory
    end

    def memory_pointer
      @memory_pointer
    end

    def input_pointer
      @input_pointer
    end

    def output_string
      @output_string
    end

    def current_byte
      @memory[@memory_pointer]
    end

    def set_current_byte(value)
      @memory[@memory_pointer] = value
      normalize_current_byte
    end

    def +
      set_current_byte(current_byte + 1)
    end

    def -
      set_current_byte(current_byte - 1)
    end

    def >
      @memory_pointer += 1
      normalize_current_byte
    end

    def <
      @memory_pointer -= 1
      if @memory_pointer < 0
        raise "Out of bounds"
      end
      normalize_current_byte
    end

    def i
      if @input_string[@input_pointer]
        set_current_byte(@input_string[@input_pointer].ord)
      end
      @input_pointer += 1
    end

    def o
      @output_string << current_byte.chr
    end

    def gosub
      return unless current_byte == 0
      nest_depth = 1
      until nest_depth == 0
        @code_pointer += 1
        if @code_string[@code_pointer] == "["
          nest_depth += 1
        elsif @code_string[@code_pointer] == "]"
          nest_depth -= 1
        end
      end
    end

    def ret
      return if current_byte == 0
      nest_depth = 1
      until nest_depth == 0
        @code_pointer -= 1
        if @code_string[@code_pointer] == "]"
          nest_depth += 1
        elsif @code_string[@code_pointer] == "["
          nest_depth -= 1
        end
      end
    end

    def normalize_current_byte
      if current_byte == -1
        @memory[@memory_pointer] = 255
      elsif current_byte == 256
        @memory[@memory_pointer] = 0
      else        
        @memory[@memory_pointer] = current_byte.to_i
      end
    end
  end
end
