Day 19 ¨C Snow white and the seven conditionals

Day 19 ¨C Snow white and the seven conditionals

by carl
Perl 6 is a big language. It¡¯s rather unapologetic about it. The vast, frightening, beautiful (and slightly dated) periodic table of operators hammers this point home. The argument for having a plethora of operators is to cover a lot of semantic ground, to let you freely express yourself with More Than One Way To Do It. The argument against is fear: ¡°aaargh, so many!¡±

But ¡¯tis the season, and love conquers fear. Today I went searching for conditionals in the language; ways to say ¡°if p then q¡± in Perl 6. All this in order to take you on a guided tour of conditionals.

Here¡¯s what we are looking for: a language construct with an antecedent (¡°the ¡®if¡¯ part¡±) and a consequent (¡°the ¡®then¡¯ part¡±). (They may also have an optional ¡®else¡¯ part, but under my arbitrary search criteria, I don¡¯t care.)

I went looking, and I found seven of them. Now for the promised tour.

if

An oldie but a goodie.


if prompt("Should I exult? ") eq "yes" {
    say "yay!";
}
Unlike in Perl 5, you don't have to put parentheses around the antecedent expression. (Cue Python programmers rolling their eyes, unimpressed.) There are elsif and else clauses that you can add if you need it.

I won't count unless separately, as all it does is reverse the logical value of the antecedent.

when

The when statement also qualifies. It's a conditional statement, but with a preference to matching against the topic variable, $_.


given prompt("What is your age? ") {
    when * < 15 { do-not-let-into-bar() }
    when * < 25 { ask-for-ID() }
    when * > 80 { suggest-bingo-around-the-corner() }
}
The semantic "bonus" with this statement is that the end of a when block implicitly triggers a succeed (known as break to traditionalists), which will leave the surrounding contextualizer ($_-binding) block, if any. Or, in plain language, you don't have to put in explicit breaks in your Perl 6 switch statements.

The when statement doesn't have an opposite version. I have sometimes campaigned for whenn't, but with surprisingly (or rather, predictably) little uptake. Ah well; there will be modules.

&&

"Now hold your horses!", I hear you say. "That ain't no conditional!" And you would be right. But, according to the criteria of the search, it is, you see. It has an antecedent and a consequent. The consequent only gets evaluated if the antecedent is truthy.


if @stuff && @stuff[0] eq "interesting" {
    # ...
}
This behavior is called "short-circuiting", and Perl 6 is only one of a long list of languages that work this way.

I won't count ||, because it's the dual of &&. It also short-circuits, but it bails early on truthy values instead of falsy ones.

and

If we count &&, surely we should count its low-precedence cousin, and.


open("file.txt")
    and say "Yup, it opened";
Some people use && and and interchangeable, or prefer only one of them. I'm a little bit more restrictive, and tend to use && inside of expressions, and and only between statements.

I won't count or, again because it's the dual of and.

not ?&

A non-entrant in our tour which nontheless deserves an honorable mention is the ?& operator. It's a "boolifying &&".

But besides always returning a boolean value (rather than the rightmost truthy value, as && and and do), it also doesn't short-circuit. Which makes it useless as a conditional.


sub f1 { say "first"; False }
sub f2 { say "second" }

f1() && f2();   # says "first"
f1() ?& f2();   # says "first", "second"
Therefore, there are two reasons I'm not counting ?|.

not & either

We have another honorable mention. In Perl 5, the & operator deals in bitmasks (just as in a lot of C-derived languages), but in Perl 6 this operator has been stolen for a higher purpose: junctions.


f1() & f2();    # says "first", "second" in some order
The old bitmask operator (now spelled +&, by the way) doesn't short-circuit, and never did in any language I'm aware of. This new junctional operator also doesn't short-circuit. In fact, the semantics it conveys is one of quantum computer "simultaneous evaluation". Actual threading semantics is not guaranteed, currently does not happen in Rakudo ¡ª and may not be worth the overhead for most small calculations anyway ¡ª but the message is clear: hie the hence, short-circuiting.

//

The most questionable conditional on my list, this one nevertheless made the cut. It's a version of ||, but instead of testing for truthiness, it tests for undefinedness. Other than that, it's very conditional.


my $name = %names{$id} // "<no name given>";
This operator is notable for sharing a first place (with say) as "most liked feature side-ported to Perl 5". (Just don't mention smartmatch to a Perl 5 person.)

The dual of //, for evaluating a consequent only if the antecedent is a defined value, is spelled ??, and of course, it does not exist and never did. *bright neuralizer flash*

?? !!

Loved and known by many names ¡ª ternary operator, trinary operator, conditional operator ¡ª this operator defies grammatical categories but is clearly a conditional, too. It even has an else part.


my $opponent = $player == White ?? Black !! White;
Almost every language out there spells this operator as ? : and it takes a while to get used to the new spelling in Perl 6. (The reason was that both ? and : were far too short and valuable to waste on this operator, so it got "demoted" to a longer spelling.)

If you ask me, ?? !! is an improvement once you see past the historical baggage: all of the other pure boolean operators already identify themselves by doubling a symbolic character like that. It blends in better.

You didn't hear it from me, but if anyone ever feels like creating an unless/else version of this operator, you could do a lot worse than choosing ?? ?? for the job. Ah, Unicode.

andthen

Finally, a late entry, andthen also works as a conditional. Just when you thought Perl 6 had you semantically covered with && and and for ordinary boolean values, and // for undefined values...

...it opens up a third door. The andthen operator only evaluates its right-hand statement if the left-hand statement succeeded.


shut-down-reactor()
    andthen don-hazmat-suit()
    andthen enter-chamber()
;
Succeeding means returning something defined and not failing along the way. Structually, the andthen operator has been compared to Haskell's monadic bind: success of earlier statements guards execution of later ones. Though it's not implemented yet in Rakudo, you're even supposed to be able to pass the successful value from the left-hand statement to the right-hand one. (It ends up in $_.)

I won't count orelse, even though it also short-circuits. Though it's worth noting that the right-hand side of orelse ends up with the $! value from the left-hand side.

Signoff

Thank you for taking the tour. As you can see, there really is More Than One Way to write a condition in Perl 6. Some of them will turn up more often in everyday code, and some less often. I use and only rarely, and I've yet to use an andthen in real code. The others all crop up fairly regularly, and all in their own favorite contexts.

Some languages give you a sparse diet of the bare necessities, claiming that it's good for you to have fewer choices. Perl is not one of those languages. Instead, you get lots of choice, lots of freedom, and it's up to you to do great things with it. Of course, we also try to make sure that the constructs are there make sense, are in good taste, and feel consistent with the rest of the language. The end result is a pleasant language with plenty of rope to shoot yourself in the foot with.

Merry conditional Christmas!