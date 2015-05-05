=begin
> increment the data pointer (to point to the next cell to the right).
< decrement the data pointer (to point to the next cell to the left).
+ increment (increase by one, truncate overflow: 255 + 1 = 0) the byte at the data pointer.
- decrement (decrease by one, treat as unsigned byte: 0 - 1 = 255 ) the byte at the data pointer.
. output the byte at the data pointer.
, accept one byte of input, storing its value in the byte at the data pointer.
[ if the byte at the data pointer is zero, then instead of moving the instruction pointer forward to the next command, jump it forward to the command after the matching ] command.
] if the byte at the data pointer is nonzero, then instead of moving the instruction pointer forward to the next command, jump it back to the command after the matching [ command.
=end

module BrainBend
  class Interpreter

    attr_accessor :memory_pointer, :input_pointer, :output_pointer, :memory, 
                  :code_string, :code_pointer, :input_string, :output_string
    def initialize
      @memory = [0]
      @memory_pointer = 0
      self.code = ",>,<.>."
      self.input = "Hi"
      @output_pointer = 0
      @output_string = ""
    end

    def state
      { 
        memory: memory,
        memory_pointer: memory_pointer,
        current_byte: current_byte,
        code_string: code_string,
        code_pointer: code_pointer,
        current_instruction: current_instruction,
        input_string: input_string,
        input_pointer: input_pointer,
        output_string: output_string,
        output_pointer: output_pointer
      }
    end

    def current_instruction
      @code_string[code_pointer]
    end

    def current_byte
      @memory[memory_pointer]
    end

    def current_byte=(value)
      @memory[memory_pointer] = value
    end

    def normalize_current_byte
      @memory[memory_pointer] = case
      when current_byte.to_i <= 0
        0
      when current_byte.to_i >= 256
        255
      else
        current_byte.to_i
      end
    end

    def interpret!
      while @code_pointer <= (@code_string.length - 1)
        case current_instruction
        when "."
          self.send(:p)
        when ","
          self.send(:i)
        when "["
          self.send(:go_to)
        when "]"
          self.send(:return_to)
        else
          self.send(current_instruction.to_sym)
        end
        @code_pointer += 1
      end
      puts output_string
    end

    def go_to
      return unless current_byte == 0
      nest_count = 1
      until nest_count == 0
        @code_pointer += 1
        if current_instruction == "["
          nest_count += 1
        elsif current_instruction == "]"
          nest_count -= 1
        end
      end
      @code_pointer += 1
    end

    def return_to
      return if current_byte == 0
      nest_count = 1
      until nest_count == 0
        @code_pointer -= 1
        if current_instruction == "]"
          nest_count += 1
        elsif current_instruction == "["
          nest_count -= 1
        end
      end
      @code_pointer -= 1
    end

    def code=(value)
      @code_string = value
      @code_pointer = 0
    end

    def input=(value)
      @input_string = value
      @input_pointer = 0
    end

    def p
      @output_string[output_pointer] = current_byte.chr
      @output_pointer += 1
    end

    def i
      @current_byte = @input_string[input_pointer].ord % 256
      @input_pointer += 1
    end

    def >
      @memory_pointer += 1
      normalize_current_byte
    end

    def <
      @memory_pointer -= 1
      normalize_current_byte
    end

    def +
      current_byte += 1
      normalize_current_byte
    end

    def -
      current_byte -= 1
      normalize_current_byte
    end
  end
end