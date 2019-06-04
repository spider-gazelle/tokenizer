class Tokenizer::Length < Tokenizer
  @indicator : Bytes?
  @compare_i : Bytes?

  def initialize(@token_size : Int32)
  end

  getter indicator
  property token_size

  def indicator=(indicator)
    indicator = indicator.to_slice
    @indicator = indicator
    @compare_i = Bytes.new(indicator.size)
    self
  end

  def extract(data)
    # Write to the end of the buffer
    @buffer.pos = @buffer.size
    @buffer.write data.to_slice

    if indicator = @indicator
      indicator_extract(indicator)
    else
      length_extract
    end
  end

  private def indicator_extract(indicator)
    compare = @compare_i.not_nil!
    messages = [] of Bytes

    # If we have enough data we want to tokenise
    while @buffer.size >= @token_size
      # Find the start of the message
      while @buffer.size > compare.size
        @buffer.pos = 0
        @buffer.read compare
        break if indicator == compare

        # remove the first byte of the buffer as it doesn't match
        @buffer.pos = 1
        truncate_buffer
      end

      # Extract a token
      if @buffer.size >= @token_size
        slice = Bytes.new(@token_size)
        @buffer.pos = 0
        @buffer.read slice
        messages << slice
        truncate_buffer
      end
    end

    messages
  end

  private def length_extract
    messages = [] of Bytes

    # If we have enough data we want to tokenise
    if @buffer.size >= @token_size
      @buffer.pos = 0

      # Extract tokens
      loop do
        slice = Bytes.new(@token_size)
        @buffer.read slice
        messages << slice
        remaining = @buffer.size - @buffer.pos
        break if remaining < @token_size
      end

      truncate_buffer
    end

    messages
  end
end
