require "spec"
require "../src/tokenizer"

describe Tokenizer do
  describe Tokenizer::Abstract do
    it "should extract a message" do
      msg1 = "3abc"
      buffer = Tokenizer.new do |io|
        # Use #peek to get a slice of this memory
        str = io.gets_to_end
        str[0].to_i + 1
      end
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["3abc"])

      buffer.buffer.size.should eq(0)
    end

    it "should handle cases where the message is larger than the buffer" do
      msg1 = "7abcde"
      buffer = Tokenizer.new do |io|
        str = io.gets_to_end
        str[0].to_i + 1
      end
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq([] of String)

      result = buffer.extract("fg2e")
      result.map { |bytes| String.new(bytes) }.should eq(["7abcdefg"])

      buffer.buffer.size.should eq(2)

      result = buffer.extract("h")
      result.map { |bytes| String.new(bytes) }.should eq(["2eh"])

      buffer.buffer.size.should eq(0)
    end

    it "should extract multiple messages" do
      # NOTE:: seems weird that 'a' + 1 doesn't raise an error...
      msg1 = "3abc4aaaa5t"
      buffer = Tokenizer.new do |io|
        # Use #peek to get a slice of this memory
        str = io.gets_to_end
        str[0].to_i + 1
      end
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["3abc", "4aaaa"])

      buffer.buffer.size.should eq(2)
    end
  end
end
