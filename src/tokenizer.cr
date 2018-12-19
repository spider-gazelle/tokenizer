abstract class Tokenizer
  # simple tokenizer
  def self.new(delimiter)
    Tokenizer::Delimiter.new(delimiter)
  end

  def self.new(token_size : Int32, indicator = nil)
    t = Tokenizer::Length.new(token_size)
    t.indicator = indicator if indicator
    t
  end

  # abstract tokenizer
  def self.new(&callback : IO::Memory -> Int32)
    Tokenizer::Abstract.new(&callback)
  end

  getter buffer

  def clear
    @buffer.clear
    self
  end

  # removes all bytes before the current buffer position
  protected def truncate_buffer
    slice = Bytes.new(@buffer.size - @buffer.pos)
    @buffer.read slice
    @buffer.clear
    @buffer.write slice
    @buffer.rewind
  end
end

require "./tokenizer/*"
