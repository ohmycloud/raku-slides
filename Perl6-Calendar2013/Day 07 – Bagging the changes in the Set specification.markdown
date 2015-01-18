Day 07 – Bagging the changes in the Set specification By   Liztormato


In 2012, colomon++ implemented most of the then Set / Bag specification in  Niecza   and   Rakudo , and  blogged about  it last year.

Then in May this year, it became clear that there was a flaw in the implementation that prohibited creating Sets of Sets easily. In June, colomon++ re-implemented Sets and Bags in Niecza using the new views on the spec. And I took it upon myself to port these changes to Rakudo. And I was in for a treat (in the  Bertie Bott’s Every Flavour Beans  kind of way).Bags和Sets的一些变化。 Texan versus (non-ASCII) Unicode

Although the Set/Bag modules were written in Perl 6, there were some barriers to conquer: it was not as simple as a copy-paste operation. First of all, all Set operators were implemented in their Unicode form in Niecza foremost, with the non-Unicode (ASCII) versions (aka Texan versions) implemented as a dispatcher to the Unicode version. At the time, I was mostly developing in rakudo on Parrot. And Parrot has this performance issues with parsing code that contains non-ASCII characters (at  any  place in the code, even in comments). Therefore, the old implementation of Sets and Bags in Rakudo, only had the Texan versions of the operators. So I had to carefully figure out which Unicode operator in the Niecza code (e.g.  ⊆ ) matched which Texan operator (namely  (<=) ) in the Rakudo code, and make the necessary changes.

Then I decided: well, why don’t we have Unicode operators for Sets and Bags in Rakudo either? I mentioned this on the #perl6 channel, and I think it was jnthn++ who pointed out that there should be a way to define Unicode operators  without  actually having to use Unicode characters. After trying this, and having jnthn++ fix some issues in that area, it was indeed possible.

So how does that look?
  # U+2286 SUBSET OF OR EQUAL TO
  only sub infix:<<"\x2286">>($a, $b --> Bool) {
      $a (<=) $b;
  }

One can only say: Yuck! But it gets the job done. So now one can write:
  $ perl6 -e 'say set( <a b c> ) ⊆ set( <a b c d> )'
  True

Note that Parcels (such as  <a b c> ) are automatically upgraded to Sets by the set operators. So one can shorten this similar statement to:
  $ perl6 -e 'say <a b c> ⊆ <a b d>'  # note missing c
  False

Of course, using the Unicode operator in Rakudo comes at the expense of an additional subroutine call. But that’s for some future optimizer to take care of. Rakudo中使用Unicode操作符会调用额外的子例程，额外的花销。未开会优化。 Still no bliss

But alas, the job was still not done. The implementation using Hash in Rakudo, would not allow Sets within Sets yet still. It would  look like it worked, but that was only because the stringification of a Set was used as a key in another set. So, when you asked for the elements of such a Set of Sets, you would get strings back, rather than Sets.

Rakudo allows objects to be used as keys (and still remain objects), by mixing in the TypedHash role into a Hash, so that .keys  returns objects, rather than strings. Unfortunately, using the TypedHash role is only completely functional for user programs,  not when building the Perl 6 internals using Perl 6, as is done in the core settings. Bummer.

However, the way TypedHash is implemented, could also be used for implementing Sets and Bags. For Sets, there is simply an underlying Hash, in which the key is the  .WHICH  value of the thing in the set, and the value is the thing. For Bags, that became a little more involved, but not a lot: again, the key is the .WHICH of the thing, and the value is a Pair with the thing as the key, and the count as the value. So, after refactoring the code to take this into account as well, it seemed I could finally consider this job finished (at least for now). It’s all about values

Then, the  nitty gritty of the Set spec  struck again.
  "they are subject to === equality rather than eqv equality"

What does that mean?
  $ perl6 -e 'say <a b c> === <a b c>'
  False
  $ perl6 -e 'say <a b c> eqv <a b c>'
  True

In other words, because any Set consisting of <a b c> is identical to any other Set consisting of <a b c>, you would expect:
  $ perl6 -e 'say set(<a b c>) === set(<a b c>)'
  False

to return  True  (rather than False).

Fortunately, there is  some specification  that comes in aid. It’s just a matter of creating a  .WHICH  method for Sets and Bags, and we’re set. So now:
  $ perl6 -e 'say set(<a b c>) === set(<a b c>)’
  True

just works, because:
  $ perl6 -e 'say set(<a b c>).WHICH; say set(<a b c>).WHICH'
  Set|Str|a Str|b Str|c
  Set|Str|a Str|b Str|c

shows that both sets, although defined separately, are really the same. Oh, and some other spec changes

In October, Larry  invoked rule #2  again, but those changes were mostly just names. There’s a new immutable  Mix  and mutable MixHash , but you could consider those just as Bags with floating point weights, rather than unsigned integer weights. Creating Mix was mostly a  Cat license job . Conclusion

Sets, Bags, Mixes, and their mutable counterparts SetHash, BagHash and MixHash, are now first class citizens in Perl 6 Rakudo. So, have fun with them!

来源： < http://perl6advent.wordpress.com/2013/12/07/day-07-bagging-the-changes-in-the-set-specification/ >  