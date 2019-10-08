require "spec"
require "../src/tokenizer"

describe Tokenizer do
  describe Tokenizer::Length do
    it "should not return anything when a complete message is not available" do
      msg1 = "GO123"
      buffer = Tokenizer.new(6, "GO")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq([] of String)
    end

    it "should not return anything when the messages is empty" do
      msg1 = ""
      buffer = Tokenizer.new(6, "GO")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq([] of String)
    end

    it "should tokenize messages where the data is a complete message" do
      msg1 = "GO1234"
      buffer = Tokenizer.new(6, "GO")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["GO1234"])
    end

    it "should tokenize length only messages where the data is a complete message" do
      msg1 = "GO1234123456"
      buffer = Tokenizer.new(6)
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["GO1234", "123456"])
    end

    it "should discard data that is not relevant" do
      msg1 = "1234-GO1234"
      buffer = Tokenizer.new(6, "GO")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["GO1234"])
    end

    it "should return multiple complete messages" do
      msg1 = "GO1234GOhome"
      buffer = Tokenizer.new(6, "GO")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["GO1234", "GOhome"])
    end

    it "should discard data between multiple complete messages" do
      msg1 = "1234-GO123412345-GOhome"
      buffer = Tokenizer.new(6, "GO")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["GO1234", "GOhome"])
    end

    it "should tokenize messages where the indicator is split" do
      msg1 = "GOtestG"
      msg2 = "Owhoa"
      buffer = Tokenizer.new(6, "GO")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["GOtest"])
      result = buffer.extract(msg2)
      result.map { |bytes| String.new(bytes) }.should eq(["GOwhoa"])
    end

    it "should tokenize messages where the indicator is split and there is discard data" do
      msg1 = "GOtest\n\r1234G"
      msg2 = "Owhoa\n"
      buffer = Tokenizer.new(6, "GO")
      result = buffer.extract(msg1)
      result.map { |bytes| String.new(bytes) }.should eq(["GOtest"])
      result = buffer.extract(msg2)
      result.map { |bytes| String.new(bytes) }.should eq(["GOwhoa"])
    end
  end
end
