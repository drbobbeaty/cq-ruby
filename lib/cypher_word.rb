require 'legend'

class CypherWord
  attr_reader :cyphertext

  def initialize(cyphertext)
    @cyphertext = cyphertext
    @cyphertext_chars = cyphertext.chars
    @cyphertext_uniq_count = cyphertext.chars.to_a.uniq.count
  end

  def length
    @cyphertext.length if @cyphertext
  end

  # One of the initial tests of a plaintext word is to see if the pattern of
  # characters matches the cyphertext. If the pattern doesn't match, then the
  # decoded text can't possibly match, either. This method will look at the
  # pattern of characters in the cyphertext and compare it to the pattern in
  # the argument and if they match, will return true.
  def matches_pattern?(plaintext)
    return false unless @cyphertext && plaintext &&
                        @cyphertext.length == plaintext.length
    pc = @cyphertext_chars.zip(plaintext.chars).uniq.count
    ptc = plaintext.chars.to_a.uniq.count
    (pc == @cyphertext_uniq_count) && (@cyphertext_uniq_count == ptc)
  end

  # This method will use the provided Legend and map the cyphertext into a
  # plaintext string and then see if the resulting word COULD BE the plaintext.
  # This is not to say that the word is completely decoded - only that those
  # characters that are decoded match the characters in the plaintext.
  def can_match?(plaintext, legend)
    return false unless @cyphertext && plaintext && legend.instance_of?(Legend) &&
                        @cyphertext.length == plaintext.length
    plaintext =~ /@cyphertext.chars { |c| legend.plain_char_for_cypher(c) || '.' }/
  end

  # This method returns true if, and only if, the Legend applied to this
  # cyphertext results in the plaintext <b>exactly</b>. This means that there
  # are NO characters that aren't properly decoded in the cyphertext. If this
  # method returns true, then can_match? will be true, but the reverse is not
  # necessarily true.
  def decodes_to?(plaintext, legend)
    return false unless @cyphertext && plaintext && legend.instance_of?(Legend) &&
                        @cyphertext.length == plaintext.length
    plaintext == @cyphertext.chars { |c| legend.plain_char_for_cypher(c) }
  end

  # This method takes the Legend and applies it to the cyphertext and IF it
  # creates a completely decoded word, it returns that word. If not, it
  # returns nil. This is very similar to decodes_to? but it returns the word
  # it decodes to.
  def create_plaintext(legend)
    legend.decode(@cyphertext) if legend.respond_to?(:decode) && @cyphertext
  end

  def ==(other)
    other.instance_of?(CypherWord) && (@cyphertext == other.cyphertext)
  end
end