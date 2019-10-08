class Tokenizer::Delimiter < Tokenizer
  @delimiters : Array(NamedTuple(delimiter: Bytes, read_buffer: Bytes))
  @smallest_size : Int32 = 0
  @largest_size : Int32 = 0

  def initialize(*delimiters)
    @delimiters = [] of NamedTuple(delimiter: Bytes, read_buffer: Bytes)
    delimiters.each do |delimiter|
      @delimiters << {
        delimiter:   delimiter.to_slice,
        read_buffer: Bytes.new(delimiter.size),
      }
    end

    @checked = 0
    smallest_size
  end

  private def smallest_size
    small_size = Int32::MAX
    large_size = 0

    @delimiters.each do |delimiter|
      del_size = delimiter[:delimiter].size
      small_size = del_size if del_size < small_size
      large_size = del_size if del_size > large_size
    end
    @smallest_size = small_size
    @largest_size = large_size
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

    while remaining >= @smallest_size
      read_pos = @buffer.pos
      found = false

      @delimiters.each do |details|
        delimiter = details[:delimiter]
        read_buffer = details[:read_buffer]

        if remaining >= delimiter.size
          @buffer.pos = read_pos
          @buffer.read read_buffer

          # Check to see if we've found the delimiter
          if read_buffer == delimiter
            found = true

            slice = Bytes.new(@buffer.pos - last_found)
            @buffer.pos = last_found
            @buffer.read slice
            messages << slice
            last_found = @buffer.pos

            break
          end
        end
      end

      # move the buffer forward by 1 byte (unless we extracted a message)
      @buffer.pos = read_pos + 1 unless found
      remaining = @buffer.size - @buffer.pos
    end

    # Update buffer
    if messages.size > 0
      @checked = @buffer.pos - last_found
      @buffer.pos = last_found
      truncate_buffer
    else
      @checked = @buffer.size - (@largest_size + 1)
      @checked = 0 if @checked < 0
    end

    messages
  end
end
