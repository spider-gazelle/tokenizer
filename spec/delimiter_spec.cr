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
  end
end
