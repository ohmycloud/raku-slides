Day 18 – A Grammar with duplicate checking By   Dwarring


Today’s example constructs a grammar for tracking playing cards in a single deal. We’ll say it’s poker with one or more players and that each player is being dealt a hand that contains exactly five cards.

There is, however, the need to detect duplicate cards. We’ll need some way of tracking cards both within each card-hand and between hands.

A simple Card Game Grammar

To start with, here’s the basic grammar (no duplicate checks yet):

grammar CardGame {
 
    rule TOP { ^ <deal> $ }
 
    rule deal {
        <hand>+ % ';'
    }
 
    rule hand { [ <card> ]**5 }
    token card {<face><suit>}
 
    proto token suit {*}
    token suit:sym<♥>  {<sym>}
    token suit:sym<♦>  {<sym>}
    token suit:sym<♣>  {<sym>}
    token suit:sym<♠>  {<sym>}
 
    token face {:i <[2..9]> | 10 | j | q | k | a }
}
 
say CardGame.parse("2♥ 5♥ 7♦ 8♣ 9♠");
say CardGame.parse("2♥ a♥ 7♦ 8♣ j♥");

The  top-level rule consists of a  deal . The  deal  consists of one or more  hand s separated by  ';' . Each  hand  consists of 5 playing card s.

Each card is represented by a  face , one of:  a  (ace),  j  (jack),  q (queen) or  k  (king), or  2  -  10 . This is followed by a suite: ♥ (hearts) ♦ (diamonds) ♣ (clubs) or ♠ (spades).

[We could have used the playing cards characters, newly introduced in Unicode 6.0, but these aren't widely supported yet].

As expected, the first cut of the grammar cheerily parses any hand:

say CardGame.parse("a♥ a♥ 7♦ 8♣ j♥");
# one hand, duplicate a♥
say CardGame.parse("a♥ 7♥ 7♦ 8♣ j♥; 10♥ j♥ q♥ k♥ a♥");
# two hands, duplicate j♥
 

Detecting Duplicates

We start by adding a Perl 6 variable declaration to the grammar. This will be used to track cards:

rule deal {
    :my %*PLAYED = ();
    <hand>+ % ';'
}

This declares  %*PLAYED   [1] . The  '%*'  twigil  indicates that it’s a hash  '%'  and that’s dynamically scoped  '*' .

Dynamic scoping is not only for subroutine and method calls  [1] . It also works seamlessly with grammar rules, tokens and actions.

Being dynamically scoped,  %*PLAYED  is available to callees of the deal  rule; the  hand  token, and its callee, the  card  token.

It’s also available to any actions, that then get called. So we can track and report on duplicates by creating an action class with a method for the  card  token:

class CardGame::Actions {
    method card($/) {
       my $card = $/.lc;
       say "Hey, there's an extra $card"
           if %*PLAYED{$card}++;
   }
}
 
my $a = CardGame::Actions.new;
say CardGame.parse("a♥ a♥ 7♦ 8♣ j♥", :actions($a));
# "Hey there's an extra a♥"
say CardGame.parse("a♥ 7♥ 7♦ 8♣ j♥; 10♥ j♥ q♥ k♥ a♦",
                   :actions($a));
# "Hey there's an extra j♥"

And that might be all that’s needed  for tracking and reporting on duplicates. There’s a pretty good separation between the declarative grammar and procedural actions, with just one dynamically scoped hash variable.

Disallowing Duplicates

But I had a situation where I wanted duplicate checking to be a parsing constraint. Parsing needed to fail when duplicates were encountered.

I achieved this by moving the duplicate check grammar side:

token card {<face><suit>
    <?{
        # only allow each card to appear once
        my $card = $/.lc;
        say "Hey, there's an extra $card"
            if %*PLAYED{$card};
 
        ! %*PLAYED{$card}++;
     }>
}

This has introduced a code assertion between the  <?{  and  }>    [2] . The rule succeeds when the code evaluates to a True value. The card  token thus fails when the same card is detected more than once in a single deal.

say CardGame.parse("2♥ 7♥ 2♦ 3♣ 3♦");
# legitimate, parses
 
say CardGame.parse("a♥ a♥ 7♦ 8♣ j♥");
# fails with message: Hey, there's an extra a♥
 
say CardGame.parse("a♥ 7♥ 7♦ 8♣ j♥; 10♥ j♥ q♥ k♥ a♦");
# fails with message: Hey, there's an extra j♥

[This last technique works fully on rakudo/parrot today and should be available on the jvm in the near future.]

Discussion/Conclusion

One thing to be careful of with this type of technique is back-tracking (trying of alternatives). If, for instance, the grammar was modified in such a way that the card token could be called more than once for single input card, then we might erroneously report a duplicate. It’s still possible to track, but becomes a bit more involved. The simplest answer is to keep the grammars as simple as possible and minimize back-tracking.

If in any doubt,  please consider using one or more of the Grammar::Debugger, Grammar::Tracer  [3]  or the debugger  [4] modules  [5]  to track what’s going on. You can also insert debugging code into tokens or rules as closures:  { say "here" } [6] .

That the exercise for today; a simple Perl 6 Grammar to parse playing-cards in a card-game, but with duplicate checks using either actions or code assertions.

来源： < http://perl6advent.wordpress.com/2013/12/18/day-18-a-grammar-with-duplicate-checking/ >  