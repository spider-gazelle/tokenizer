class Tokenizer::Abstract < Tokenizer
  def initialize(&@callback : IO::Memory -> Int32)
    @buffer = IO::Memory.new
  end

  property callback

  def extract(data)
    # Write to the end of the buffer
    @buffer.pos = @buffer.size
    @buffer.write data.to_slice
    @buffer.pos = 0

    messages = [] of Bytes
    msg_size = 0

    while @buffer.pos < @buffer.size
      msg_size = @callback.call(@buffer)

      # Check if more buffering is required
      break if msg_size > @buffer.size
      break if msg_size <= 0

      # Extract the message
      slice = Bytes.new(msg_size)
      @buffer.pos = 0
      @buffer.read slice
      messages << slice
      truncate_buffer
    end

    messages
  end
end
