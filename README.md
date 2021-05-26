# Crystal Lang Tokenizer

[![CI](https://github.com/spider-gazelle/tokenizer/actions/workflows/ci.yml/badge.svg)](https://github.com/spider-gazelle/tokenizer/actions/workflows/ci.yml)

A tool for buffering and tokenizing streaming inputs.


## Overview

Consider a binary protocol such as the one used by the [Harman BSS](https://aca.im/driver_docs/BSS/London-DI-Kit.pdf) DSP.

It uses `0x03` to indicate the end of a message.

```crystal
require "socket"
require "tokenizer"

# Connect to the device
connection = TCPSocket.new("10.10.10.10", 1023)
connection.tcp_nodelay = true

# Messages terminate with 0x03, so we are looking for this byte
token_buffer = Tokenizer.new(Bytes.new(1, 0x03))

while !connection.closed?
    raw_data = Bytes.new(512)
    bytes_read = connection.read(raw_data)
    break if bytes_read == 0 # Connection was closed

    token_buffer.extract(raw_data[0, bytes_read]).each do |message|
        # Process messages here, messages are of type Bytes

        # If the data was a string, it's simple to convert
        # (assuming we want to ignore the start and stop bytes)
        message = String.new(message[1, message.size - 2])

        # Do something with the message
        process message
    end
end

```

## Supported tokenization strategies

* Message Length - i.e. all messages are 12 bytes in size
* Delimiter - i.e. all messages end with [0x03, 0x00]
* Abstract - i.e. message header determines message length


### Message Length

Messages are a fixed length, optionally starting with some indicator bytes.

```crystal
# Message length 4 bytes, including the indicator bytes
buffer = Tokenizer.new(4, "GO")

# So a string like "GO12, GO56, G" has 2 complete messages
# "GO12" and "GO56"

messages = buffer.extract("GO12, GO56, G") # => [Bytes, Bytes]
messages = messages.map { |bytes| String.new(bytes) }
messages # => ["GO12", "GO56"]

```

The example above uses strings however you would typically use this binary data that can't be represented by strings


### Delimiter

Messages are variable length, however there is a byte or bytes that represent the end of the message.

```crystal
# Messages end with \n
buffer = Tokenizer.new("\n")

# So a string like "Hello.\nHow are you?\nWha" has 2 complete messages
# "Hello.\n" and "How are you?\n"

messages = buffer.extract("Hello.\nHow are you?\nWha")
messages = messages.map { |bytes| String.new(bytes) }
messages # => ["Hello.\n", "How are you?\n"]

```


### Abstract

Messages are split by some arbitrary logic. i.e.

* A header specifies the length of a message
* or a successful CRC check indicates the message end

A callback is used for the application to define when a complete message has been received.

```crystal
# A message header indicates the length of the message
buffer = Tokenizer.new do |io|
    bytes = io.peek # for demonstration purposes
    string = io.gets_to_end

    string[0].to_i + 1
end

# So a string like "7welcome2to5hu" has 2 complete messages
# "7welcome" and "2to"

messages = buffer.extract("7welcome2to5hu")
messages = messages.map { |bytes| String.new(bytes) }
messages # => ["7welcome", "2to"]

```

* The block is expected to return the number of bytes in the next message
* Returning anything <= 0 means the message is not complete
* You can return the message size even if the message has not completely buffered. (i.e. if the header is completely buffered)
