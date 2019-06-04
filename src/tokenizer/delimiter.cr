class Tokenizer::Delimiter < Tokenizer
  @delimiter : Bytes

  def initialize(delimiter)
    @delimiter = delimiter.to_slice
    @compare_d = Bytes.new(@delimiter.size)
    @checked = 0
  end

  getter delimiter

  def delimiter=(delimiter)
    @delimiter = delimiter.to_slice
  end

  def extract(data)
    # Write to the end of the buffer
    @buffer.pos = @buffer.size
    @buffer.write data.to_slice

    # Moved to the last position that was checked
    @buffer.pos = @checked
    last_found = 0
    messages = [] of Bytes
    remaining = @buffer.size - @buffer.pos

    while remaining >= @delimiter.size
      @buffer.read @compare_d

      # Check to see if we've found the delimiter
      if @compare_d == @delimiter
        slice = Bytes.new(@buffer.pos - last_found)
        @buffer.pos = last_found
        @buffer.read slice
        messages << slice
        last_found = @buffer.pos
      else
        # move the buffer forward by 1 byte
        @buffer.pos = @buffer.pos - @delimiter.size + 1
      end
      remaining = @buffer.size - @buffer.pos
    end

    # Update buffer
    if messages.size > 0
      @checked = @buffer.pos - last_found
      @buffer.pos = last_found
      truncate_buffer
    else
      @checked = @buffer.pos
    end

    messages
  end
end
