require 'puzzle_piece'

def get_words
  words = []
  File.open('fixtures/words', 'r') do |infile|
    while (line = infile.gets)
      words << line.chomp
    end
  end
  words
end

def exercise
  w = get_words
  ct = 'Fict O ncc bivteclnbklzn O lcpji ukl pt vzglcddp'
  cc = 'b'
  pc = 't'
  dude = Quip.new(ct, cc, pc)
  st = Time.now
  puts 'starting attack...'
  dude.attempt_word_block_attack(w)
  et = Time.now - st
  puts "solutions: #{dude.solutions} in #{et*1000} msec"
end

class Quip
  attr_reader :cyphertext, :legend, :pieces, :solutions

  def initialize(cyphertext, cypher_char, plain_char)
    # start out everything with decent defaults...
    @cyphertext = cyphertext
    @legend = Legend.new(cypher_char, plain_char)
    @pieces = []
    @solutions = []
    # ...and then make all the puzzle pieces...
    cyphertext.downcase.gsub(/[^a-z0-9\'\s]/, '').split(" ").each do |ct|
      @pieces << PuzzlePiece.new(ct)
    end
  end

  # This is the entry point for attempting the "Word Block" attack on the
  # cyphertext. The idea is that we start with the initial legend, and then
  # for each plaintext word in the first cypherword that matches the legend,
  # we add those keys not in the legend, but supplied by the plaintext to
  # the legend, and then try the next cypherword in the same manner.
  #
  # There will be quite a few 'passes' in this attack plan, but hopefully not
  # nearly as many as a character-based scheme.
  #
  # If this attack results in a successful decoding of the cyphertext, this
  # method will return true, otherwise, it will return false.
  def attempt_word_block_attack(words)
    # first, set up the possibles for each piece based on the words provided
    words.each { |w| @pieces.each { |p| p.possible?(w) } }
    # sort the pieces by the number of possibles
    @pieces.sort! do |a, b|
      a.matches <=> b.matches
    end
    # now run through the attack from the beginning
    do_word_block_attack(0, @legend)
  end

  private

  # This is the recursive entry point for attempting the "Word Block" attack
  # on the cyphertext starting at the 'index'th word in the quip. The idea is
  # that we start with the provided legend, and then for each plaintext word
  # in the 'index'ed cypherword that matches the legend, we add those keys not
  # in the legend, but supplied by the plaintext to the legend, and then try
  # the next cypherword in the same manner.
  #
  # If this attack results in a successful decoding of the cyphertext, this
  # method will return true, otherwise, it will return false.
  def do_word_block_attack(idx, key)
    p = @pieces[idx]
    cw = p.cypherword
    p.possibles.each do |pt|
      have_solution = false;
      if cw.can_match?(pt, key)
        # good! Now let's see if we are all done with all the words
        if (idx == @pieces.count - 1)
          # make sure we can really decode the last word
          if key.incorporate_mapping(cw.cyphertext, pt)
            # if it's good, add the solution to the list
            if (dec = key.decode(@cyphertext))
              @solutions << dec
              have_solution = true
            end
          end
        else
          # OK, we had a match but we have more cypherwords
          # to check. So, copy the legend, add in the assumed
          # values from the plaintext, and move to the next
          next_key = key.clone
          if next_key.incorporate_mapping(cw.cyphertext, pt)
            have_solution = do_word_block_attack(idx + 1, next_key)
          end
        end
      end
      # if we have any solutions - stop
      break if have_solution
    end
    @solutions.count > 0
  end
end

exercise