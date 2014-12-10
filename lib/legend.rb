
class Legend
  attr_reader :legend_map

  LC_A = 'a'.ord

  def initialize(cypher_char, plain_char)
    @legend_map = []
    map_cypher_to_plain(cypher_char, plain_char)
  end

  def initialize_clone(other)
    super
    @legend_map = other.legend_map.clone
  end

  # This method sets the mapping in this legend for the provided pair of
  # characters: the cypher character and the plain character. This will
  # go into the legend and will be used in all subsequent decodings of
  # cypherwords by this legend.
  def map_cypher_to_plain(cypher_char, plain_char)
    @legend_map[cypher_char.downcase.ord - LC_A] = plain_char.downcase
  end

  # When a mapping in a legend has been seen to be an error, you need a method
  # to 'undo' that mapping so a different modification to the legend cam be
  # tried. This method removes the mapping for the cyphertext character in the
  # legend so it will not be mapped in subsequent applications of this legend
  # to a cypherword.
  def unmap_cypher(cypher_char)
    @legend_map[cypher_char.downcase.ord - LC_A] = nil
  end

  # This method returns the plaintext character for the cyphertext character
  # supplied - IF a mapping exists for this cyphertext character. If not, the
  # return value will be '\0', so you need to check on this before you go
  # blindly using it.
  def plain_char_for_cypher(cypher_char)
    pc = @legend_map[cypher_char.downcase.ord - LC_A]
    (cypher_char.ord < LC_A) ? (pc.upcase if pc) : pc
  end

  # This method returns the cyphertext character for the plaintext character
  # supplied - IF a mapping exists for this pairing. If not, the
  # return value will be '\0', so you need to check on this before you go
  # blindly using it.
  def cypher_char_for_plain(plain_char)
    if (idx = @legend_map.index(plain_char.downcase))
      cc = (idx + LC_A).chr
      (plain_char.ord < LC_A) ? (cc.upcase if cc) : cc
    end
  end

  # There will be times when we want to know if it's possible to take a
  # cypherword and it's possible plaintext and augment our own mapping with
  # the characters in these words without creating an illegal Legend. Examples
  # would be changing the existing mapped characters or create two different
  # plaintext characters for the same cypher character. If it's possible,
  # we'll incorporate the mappings and return YES, if not, nothing it changed
  # and NO is returned.
  def incorporate_mapping(cyphertext, plaintext)
    return false unless cyphertext.instance_of?(String) &&
                        plaintext.instance_of?(String) &&
                        cyphertext.length == plaintext.length
    pairs = cyphertext.chars.zip(plaintext.chars).uniq
    # make sure that none of the parties in the maps is already spoken for
    ok = (pairs.map do |cc, pc|
      cco = cc.downcase.ord - LC_A
      (@legend_map[cco] != pc) && (@legend_map[cco] || @legend_map.index(pc)) ? 1 : 0
    end.inject(:+) == 0)
    # if it's OK to add, then do each pair
    pairs.each do |cc, pc|
      map_cypher_to_plain(cc, pc)
    end if ok
    ok
  end

  # This method takes a cyphertext and attempts to completely decode it into a
  # plaintext using the mapping currently available. If it creates a completely
  # decoded word/phrase, it returns that word. If not, it returns nil. All
  # whitespace and punctuation is simply passed through unchanged.
  def decode(cyphertext)
    return nil unless cyphertext.instance_of?(String)
    plaintext = cyphertext.chars.map do |c|
      (c =~ /[a-zA-Z]/) ? plain_char_for_cypher(c) : c
    end.join
    plaintext if (plaintext.length == cyphertext.length)
  end

  def ==(other)
    other.instance_of?(Legend) && (@legend_map == other.legend_map)
  end
end