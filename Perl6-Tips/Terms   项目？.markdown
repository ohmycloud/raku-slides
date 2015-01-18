 Perl 6 Documentation
Search 

Terms
Literals
Int
Rat
Num
Str
Regex
Pair
Parcel
Quoting constructs
Identifier terms
self
now
rand
pi
e
i
Variables

Most syntactic constructs in Perl 6 can be categorized in terms and operators .

Here you can find an overview of different kinds of terms. Literals Int
42
12_300_00
:16<DEAD_BEEF>    #十六进制

Int literals consist of digits, and can contain underscores between any two digits.

To specify a base other than ten, use the colonpair form :radix<number> . Rat    有理数
12.34
1_200.345_678

Rat (rational numbers) literals contain two integer parts joined by a dot.

Note that trailing dots are not allowed, so you have to write 1.0 instead of 1. (this rule is important because there are infix operators starting with a dot, for example the .. Range operator). Num   浮点数
12.3e-32
3e8

Num (floating point numbers) literals consist of Rat or Int literals followed by an e and a (possibly negative) exponent. 3e8 constructs a Num with value 3 * 10**8 . Str

see the section on quoting constructs below. Regex

see the section on quoting constructs below. Pair
a => 1
'a' => 'b'
:identifier
:!identifier
:identifier<value>
:identifier<value1 value2>
:identifier($value)
:identifier['val1', 'val2']
:identifier{key1 => 'val1', key2 => 'value2'}
:$item
:@array
:%hash
:&callable

Pair objects can be created either with infix:«=>» (which auto-quotes the left-hand side if it is an identifier), or with the various colonpair forms. Those always start with a colon, and then are followed either by an identifier or the name of an already existing variable (whose name sans the sigil is used as the key, and value of the variable is used as the value of the pair).

In the identifier form a colonpair, the optional value can be any circumfix. If it is left blank, the value is Bool::True . The value of the :!identifier form is Bool::False .

If used in an argument list, all of these forms count as named arguments, with the exception of 'quoted string' => $value . Parcel
()
1, 2, 3
<a b c>
«a b c»
qw/a b c/

Parcel literals are: the empty pair of parens () , a comma-separated list, or several quoting constructs Quoting constructs

TODO Identifier terms

There are built-in identifier terms in Perl 6, which are listed below. In addition one can add new identifier terms with the syntax
sub term:<fourty-two> { 42 };
say fourty-two

or as constants
constant forty-two = 42;
say fourty-two self

Inside a method, self refers to the invocant (i.e. the object the method was called on). If used in a context where it doesn't make sense, a compile-time exception of type X::Syntax::NoSelf is thrown. now

Returns an Instant object representing the current time. rand

Returns a pseudo-random Num in the range 0..^1 .        #不包含1 pi

Returns the number pi , i.e. the ratio between circumference and diameter of a circle. e

Returns Euler's number i    返回虚部

Returns the imaginary unit (for Complex numbers). Variables

Variables are discussed in variable language docs .


Generated on 2014-03-22T13:18:49-0400 from the sources at perl6/doc on github . This is a work in progress to document Perl 6, and known to be incomplete. Your contribution is appreciated.

The Camelia image is copyright 2009 by Larry Wall.
