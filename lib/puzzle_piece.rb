require 'cypher_word'

class PuzzlePiece
  attr_reader :cypherword, :possibles

  def initialize(cyphertext)
    @cypherword = CypherWord.new(cyphertext)
    @possibles = []
  end

  # Return the length of the cypherword that's a part of this piece.
  def length
    @cypherword.length if @cypherword
  end

  # This method returns the number of possible plaintext matches we are
  # currently holding that match in pattern, and length, the cyphertext we
  # have. It's a simple way to see how many possible decodings we know about
  # for this one cypherword. If there's no array to hold the possibles, this
  # method will return nil indicating an error.
  def matches
    @possibles.count if @possibles
  end

  # This method uses the provided legend to partially, if not fully, decode the
  # cypherword into plaintext and then check that against all the possible plain
  # text words we know about and returns how many matches there are. This is a
  # good way to see how many, if any, matches there are to the decoding provided
  # by the legend. If there's no array to hold the possibles, this method will
  # return nil indicating an error.
  def count_possibles_for_legend(legend)
    return nil unless @cypherword && @possibles && legend
    @possibles.map { |p| @cypherword.can_match?(p, legend) ? 1 : 0 }.inject(:+)
  end

  # This method looks at the supplied plaintext word, and if it's pattern matches
  # the CypherWord we have, then we'll add it to the array of possibles. It's a
  # simple way to populate the list of possible plaintext words for all the
  # pieces in the puzzle.
  def possible?(plaintext)
    return false unless @cypherword && @possibles && plaintext
    add = (@cypherword.matches_pattern?(plaintext) && @possibles.index(plaintext).nil?)
    @possibles << plaintext if add
    add
  end

  def drop_possible(plaintext)
    @possibles.delete(plaintext) if @possibles
  end

  def clear_possibles
    @possibles = []
  end

  def ==(other)
    other.instance_of?(PuzzlePIece) &&
    (@cypherword == other.cypherword)
    (@possibles == other.possibles)
  end
end