require "spec"
require "../src/tokenizer"

describe Tokenizer do
  describe Tokenizer::Delimiter do
    it "should extract a message" do
      msg1 = "123GO"
      buffer = Tokenizer.new("GO")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["123GO"])
    end

    it "should ignore incomplete messages" do
      msg1 = "123GO45"
      buffer = Tokenizer.new("GO")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["123GO"])
      result = buffer.extract("6GO789GO00")
      result.map { |bytes| String.new(bytes) }.should eq(["456GO", "789GO"])
      buffer.buffer.size.should eq(2)
    end

    it "should extract multiple messages" do
      msg1 = "123GO45GO"
      buffer = Tokenizer.new("GO")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["123GO", "45GO"])
    end

    it "should work with multiple delimiters" do
      msg1 = "123GO45GO11111END3GO"
      buffer = Tokenizer.new("GO", "END")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["123GO", "45GO", "11111END", "3GO"])
    end

    it "should ignore incomplete messages with multiple delimiters" do
      buffer = Tokenizer.new("GO", "END")
      result = buffer.extract("123EN")
      result.map { |bytes| String.new(bytes) }.should eq([] of String)
      result = buffer.extract("D6GO789GO00")
      result.map { |bytes| String.new(bytes) }.should eq(["123END", "6GO", "789GO"])
      buffer.buffer.size.should eq(2)
    end
  end
end
