One place infinite lazy lists do not work are the hyper meta operators
The idea is that conceptually they work on the entire list at once
Indeed, they are allowed to work on its elements in any order, and in parallel
(In practice, none of the Perl 6 compilers handle parallel processing yet)
Our first example of a meta operator: an operator built from a simpler operator
@a »+« @b produces an array which is the sum of the other two arrays
@a »%%» 2 produces an array of Bools telling which elements of @a are divisible by 2
~«@a is effectively the same as @a».Str -- it returns an array of strings


If you do need to sum the elements of two infinite lazy lists, you can use the zip meta operator
Instead of @a »+« @b, you can do @a Z+ @b
Z+ evaluates the lists lazily and returns its values lazily
It's effectively doing (@a Z @b).map(* + *)
<a b c> Z~ <1 2 3> returns a1 b2 c3
Likewise, the cross operator X has a meta operator equivalent
<a b c> X~ <1 2 3> returns a1 a2 a3 b1 b2 b3 c1 c2 c3

Another meta operator which works on arrays/lists is reduce:
[+] @a sums all of the elements of @a and returns the sum
It's functionally equivalent to @a[0] + @a[1] + ... + @a[*-1]
Any infix operator can be used in place of + there
Obviously this will not work for infinite lazy lists
But there is another form of the reduce meta operator which returns a lazy list
[\*] 1...* returns the lazy list 1, 1*2, 1*2*3, 1*2*3*4 ...
That is to say, it returns each internal step of the evaluation of [*]

Other meta operators:
Assignment: The traditional op= (eg +=)
Negation: Infix relational operators can be used as !op
That is, $a !eq $b is equivalent to !($a eq $b)
Reversing: Rop reverses the arguments to op
So $a R- $b is the same as $b - $a

"Naturally," meta operators can be nested
<a b c> X~ <1 2 3> is a1 a2 a3 b1 b2 b3 c1 c2 c3
<a b c> RX~ <1 2 3> is 1a 1b 1c 2a 2b 2c 3a 3b 3c
<a b c> RXR~ <1 2 3> is a1 b1 c1 a2 b2 c2 a3 b3 c3
That's one of the few useful applications of this I know of :)

New operators can be defined just like any other sub
multi sub infix:<+>(MyInt $a, MyInt $b) overloads addition for MyInt
sub postfix:<!>(Int $a) { [*] 1..$a; } creates a factorial operator:
5! yields 120, just as you would expect
sub prefix:<$$$>($a) { "$a billion dollars" }
$$$10 yields the string 10 billion dollars
In theory, these new operators can be used with meta operators too

You may have the impression that Perl 6 is operator crazy
If so, you are right
Part of the Perl 6 philosophy is to have a very rich set of operators
It's up to programmers not to abuse this
eg As an infix, + (by itself) should always refer to mathematical addition
But that's a convention, not a hard technical rule of the language

prefix:<+> is just sugar for calling an object's Numeric conversion method
Operators which start with + are numeric operators
For instance, +& converts both its arguments to Int and does bitwise AND on them
prefix:<?> is sugar for .Bool, and ?| converts its arguments to Bool and ORs them
prefix:<~> is sugar for .Str, conversion to a string


