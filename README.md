# CryptoQuip Solver in Ruby

The standard CryptoQuip, as it appears in the comics, is a simple substitution
cypher where one character of the solution is provided, and it's up to the player
to figure out the rest from the provided cyphertext and the clue. It's a fun little
puzzle to play, but that doesn't stop a more _analytical_ approach.

This project is about a few different attacks on solving the general CryptoQuip
puzzle in as short a time as possible. There are other versions of this same
attack, and there are several different attack schemes. This just happens to
be the fastest we've found.

I wanted to brush up on my ruby skills and posrting the Obj-C codebase to
ruby seemed like a nice way to migrate the code to Swift, but brush up on
ruby at the same time.

## The Origin Story

It all starts at Purdue University in the Fall of 1985, in the EE007 office of a
few friends, and _The Exponent_, the daily campus paper, was publishing the
CryptoQuip puzzle. Jim wanted to solve them himself, and I was simply not
that interested, but I could see that there was a way to _automate_ the
finding of a solution if we simply had a set of _reference_ words.

The first attempt at a solution was really a solution for a _single word_ - which
was a simply `grep` command on the school's BSD unix machines hitting
`/usr/dict/words` and the pattern of the unknown word. That worked for
a while, and then I realized that all I needed was the file of words, and I could
write something on my PC with _Turbo Pascal_ and I could do _all_ the words
in the puzzle.

One thing lead to another... Jim wrote a shell script... I finished my Pascal
version... and at this point, another officemate joined in: Bret. We each
wanted to be able to solve the puzzle as quickly as possible - just by
entering the puzzle and the given hint.

## The Basic Solution

The current algorithm is based on the idea that each cyphertext word is really
a simple pattern of characters. This pattern can then be used to filter out those
words from the master list that simply don't match the pattern. At this point,
each of the cyphertext words will have a series of _possible_ words which then
have to be compared to all the other _possible_ words for all the other
cyphertext words to see what words "match" and create a complete solution.

This is the purpose of the _Legend_. This is simply the potential key to
decoding the puzzle. New _Legends_ will be tried and see if they decode the
plaintext words properly, and if so, we keep checking, if not, we discard that
_Legend_, and try another.

There are a few other things - like what order to check the words, and how to
prune the search tree, but those are all in the code as comments.

## Usage

You can pull up the code in `irb` and then simply load the `quip.rb` file and
run the `exercise` function. It will run the solver on the test input and
return the result.

```ruby
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
```

We didn't put in the effort to make this a RESTful endpoint with Sinatra, or
anything like that... we just wanted to have a reference implementation that
we could verify worked, and then get some metrics for the size of the codebase
and the speed of execution.
