Day 22 – A catalogue of operator types By   Carl


Perl 6 has a very healthy relationship to operators. "An operator is just a funnily-named subroutine", goes the slogan in the community.

In practice, it means you can do this:
sub postfix:<!>($N) {
    [*] 2..$N;
}
say 6!;    # 720

Yeah, that’s the prototypical factorial example. I promise I won’t do it any more in this post. I swear the only reason we don’t  have factorial as a standard operator in the language, is so that we can impress people by defining it.

Anyway, so a postfix operator  !  is really just a "funnily-named" subroutine  postfix:<!> . Similarly, we have prefix and infix operators, like  prefix:<->  and  infix:<*> . They’re all just subroutines. I  wrote about that before , so I’m not going to hammer on that point.

Operators have different precedence (like  infix:<*>  binds tighter than  infix:<+> )…
$x + $y * $z   # compiler sees $x + ($y * $z)
$x * $y + $z   # compiler sees ($x * $y) + $z

…and different associativity (like  infix:</>  associates to the left but  infix:<=>  associates to the right).
$x / $y / $z   # compiler sees ($x / $y) / $z
$x = $y = $z   # compiler sees $x = ($y = $z)

But I  wrote about that before too , at quite some length, so I’m not going to revisit that topic.

No, today I just want to talk about the operator categories in general. I think Perl 6 does a nice job of describing the operator types themselves. I don’t see that in many other languages.

Here are all the different types:
 type            position           syntax
======          ==========         ========
 
prefix          before a term        !X
infix           between two terms    X ! Y
postfix         after a term         X!
 
circumfix       around               [X]
postcircumfix   after & around       X[Y]

A lot of other languages give you the ability to define your own operators. Many of them provide approaches which are hackish afterthoughts, and only allow you to override existing operators. Some other languages do approach the problem head-on, but end up simplifying the language to decrease the complexity of defining new operators.

Perl 6 approaches, and solves, the problem, head-on. You get all of the above operators, you can refine or override old ones, and you can talk  within the language  about things like precedence and associativity.

All that is rather nice. But, as usual, Perl 6 goes one step further and starts classifying  metaoperators , too.

What’s a metaoperator? That’s our name for when you can extend an operator in a certain way. For example, many languages allow some kind of not-equal operator like  infix:<!=> . Perl 6 has another one for string non-equality:  infix:<ne> . And then maybe you want to do smart non-matching:  infix:<!~~> . And so on — pretty soon you catch on to the pattern: you may, at one point or another, want to invert the result of  any  boolean matcher. So that’s what Perl 6 provides.

Here are a few examples:
normal op     negated op
=========     ==========
eq            !eq     ( synonym of ne )
~~            !~~
<             !<      ( synonym of >= )
before        !before

Because this particular metaoperator attaches itself before an infix operator, it gets the name  infix_prefix_meta_operator:<!> . I was going to say "and yes, you can add your own user-defined metaoperators too", but currently no implementation supports that. Maybe sometime in the future.

There are many other categories of metaoperators. For example the "multiplication reducer"  [*]  that we used in the factorial example at the top (which takes a list of numbers and multiplies them all together) is really an  infix:<*>  surrounded by the metaop  prefix_circumfix_meta_operator:sym<[ ]> . (It’s "prefix" because it goes before the list of numbers.)

Luckily, we don’t have meta-meta-ops. Already thinking about the metaops is quite a challenge sometimes. But what I like about Perl 6 and the approach it takes to grammar and operators is this: someone  did  think about it, long and hard. The resulting system has a pleasing simplicity to it.

Perl 6 is very well-suited for building parsers for languages. As one of its neatest tricks, it takes this expressive power and directs it towards the task of defining itself. As a Perl 6 user, you’re given not just an excellent toolbox, but a well-organized workshop to adapt and extend to fit your needs.

来源： < http://perl6advent.wordpress.com/2013/12/22/day-22-a-catalogue-of-operator-types/ >  