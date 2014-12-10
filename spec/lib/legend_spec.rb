require 'legend'

describe Legend do
  describe "simple mapping checks" do
    let(:simple) { Legend.new('b', 't') }

    it "should allow for proper incorporation" do
      expect(simple.incorporate_mapping('bivteclnbklzn', 'thunderstorms')).to eq(true)
    end
  end

  describe "simple conversions" do
    let(:simple) { Legend.new('b', 't') }

    it "should return nil for unmapped chars" do
      expect(simple.plain_char_for_cypher('z')).to be_nil
    end

    it "should map correctly" do
      expect(simple.plain_char_for_cypher('b')).to eq('t')
      expect(simple.plain_char_for_cypher('t')).to be_nil
    end

    it "should preserve case in mapping" do
      expect(simple.plain_char_for_cypher('B')).to eq('T')
      expect(simple.plain_char_for_cypher('T')).to be_nil
    end

    it "should reverse map correctly" do
      expect(simple.cypher_char_for_plain('t')).to eq('b')
    end

    it "should preserve case in reverse map" do
      expect(simple.cypher_char_for_plain('T')).to eq('B')
    end
  end

  describe "complete decoding" do
    let(:simple) { Legend.new('b', 't').tap { |l|
                    l.incorporate_mapping('bivteclnbklzn', 'thunderstorms') } }

    it "should return the complete decoded word" do
      expect(simple.decode('nkzc zklc bivteclnbklzn')).to eq('some more thunderstorms')
    end

    it "should preserve the case of the cyphertext" do
      expect(simple.decode('Nkzc zklc Bivteclnbklzn')).to eq('Some more Thunderstorms')
    end
  end
end