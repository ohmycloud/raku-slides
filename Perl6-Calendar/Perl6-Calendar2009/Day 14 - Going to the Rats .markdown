



Posted in  2009  |  15 Comments »
Day 14: Going to the Rats December 14, 2009


As I hinted at back in the in the  Day 1 post , Perl 6 has rational numbers. They are created in the most straightforward fashion, by dividing an integer with another integer. But it can be a bit hard to see that there is anything unusual about the result:

 > say (3/7).WHAT
 Rat()
 > say 3/7
 0.428571428571429


When you convert a Rat to a Str (for example, to “say” it), it converts to a decimal representation. This is based on the principle of least surprise: people generally expect 1/4 to equal 0.25. But the precision of the Rat is exact, rather than the approximation you’d get from a floating point number like a Num:

 > say (3/7).Num + (2/7).Num + (2/7).Num - 1;
 -1.11022302462516e-16
 > say 3/7 + 2/7 + 2/7 - 1
 0


The most straightforward way to see what is going on inside the Rat is to use the  .perl  method.  .perl  is a standard Perl 6 method which returns a human-readable string which, when eval’d, recreates the original object as closely as is possible:

 > say (3/7).perl
 3/7


You can also pick at the components of the Rat:

 > say (3/7).numerator
 3
 > say (3/7).denominator
 7
 > say (3/7).nude.perl
 [3, 7]


All the standard numeric operators and operations work on Rats. The basic arithmetic operators will generate a result which is also a Rat if that is possible; the rest will generate Nums:

 > my $a = 1/60000 + 1/60000; say $a.WHAT; say $a; say $a.perl
 Rat()
 3.33333333333333e-05
 1/30000
 > my $a = 1/60000 + 1/60001; say $a.WHAT; say $a; say $a.perl
 Num()
 3.33330555601851e-05
 3.33330555601851e-05
 > my $a = cos(1/60000); say $a.WHAT; say $a; say $a.perl
 Num()
 0.999999999861111
 0.999999999861111


(Note that the  1/60000 + 1/60000  didn’t work in the last official release of Rakudo, but is fixed in the Rakudo github repository.)

There also is a nifty method on Num which creates a Rat within a given tolerance of the Num (default is 1e-6):

 > say 3.14.Rat.perl
 157/50
 > say pi.Rat.perl
 355/113
 > say pi.Rat(1e-10).perl
 312689/99532


One interesting development which has not made it into the main Rakudo build yet is decimal numbers in the source are now spec’d to be Rats. Luckily this is implemented in the ng branch, so it is possible to demo how it will work once it is in mainstream Rakudo:

 > say 1.75.WHAT
 Rat()
 > say 1.75.perl
 7/4
 > say 1.752.perl
 219/125


One last thing: in Rakudo, the Rat class is entirely implemented in Perl 6. The  source code  is thus a pretty good example of how to implement a numeric class in Perl 6.


Posted in  2009  |  8 Comments »
Day 13: Junctions December 13, 2009


Among the many exciting things in Perl 6, junctions are one of my favourites. While I know I don’t really comprehend everything you can do with them, there are a few useful tricks which I think most people will appreciate, and it is those which I’m going to cover as today’s gift.

Junctions are values which have (potentially) more than one value at once. That sounds odd, so let’s get thinking about some code which uses them. First, let’s take an example. Suppose you want to check a variable for a match against a set of numbers:
if $var == 3 || $var == 5 || $var == 7 { ... }

I’ve never liked that kind of testing, seeing as how it requires much repetition. With an  any  junction we can rewrite this test:
if $var == any(3, 5, 7) { ... }

How does this work? Right near the core of Perl 6 is a concept called junctive autothreading. What this means is that, most of the time, you can pass a junction to anything expecting a single value. The code will run for each member of the junction, and the result will be all those results combined in the same kind of junction which was originally passed.

In the sample above, the  infix:<==>  operator is run for each element of the junction to compare them with  $var . The results of each test are combined into a new  any  junction, which is then evaluated in Boolean context by the  if  statement. An  any  junction in Boolean context is true if any of its values are true, so if  $var  matches any value in the junction, the test will pass.

This can save a lot of duplicated code, and looks quite elegant. There’s another way to write it, as  any  junctions can also be constructed using the  infix:<|>  operator:
if $var == 3|5|7 { ... }

What if you want to invert this kind of test? There’s another kind of junction that’s very helpful, and it’s called  none :
if $var == none(3, 5, 7) { ... }

As you may have guessed, a  none  junction in Boolean context is true only if none of its elements are true.

Junctive autothreading also applies in other circumstances, such as:
my $j = any(1, 2, 3);
my $k = $j + 2;

What will this do? By analogy to the first example, you can probably guess that  $k  will end up being  any(3, 4, 5) .

There is an important point to note in these examples. We’re talking about junctive  autothreading , which should give you a hint. By the Perl 6 spec, the compiler is free to run these multiple operations on junctions in different threads so that they can execute in parallel. Much as with hyperoperators, you need to be aware that this could happen and avoid anything which would make a mess if run simultaneously.

The last thing I want to talk about is how junctions work with smartmatching. This is really just another instance of autothreading, but there are some other junction types which become particularly useful with smartmatching.

Say you have a text string, and you want to see if it matches all of a set of regexes:
$string ~~ /<first>/ & /<second>/ & /<third>/

Assuming, of course, you have defined regexes called  first ,  second and  third . Rather like  | ,  &  is an infix operator which creates junctions, this time  all  junctions which are only true if all their members are true.

The great thing about junctions is that they have this behaviour without the routine you’re passing them to having to know about it, so you can pass junctions to almost any library or core function and expect this kind of behaviour (it is possible for a routine to deliberately notice junctions and treat them how it prefers rather than using the normal autothreading mechanism). So if you have a routine which takes a value to smartmatch something against, you can pass it a junction and get that flexibility in the smartmatch for free. We use this in the Perl 6 test suite, with functions like  Test::Util::is_run , which runs some code in another interpreter and smartmatches against its output.

To finish off, here are some other useful things you can do with junctions. First, checking if  $value  is present in  @list :
any(@list) == $value

Junction constructors can work quite happily with the elements of arrays, so this opens up many possibilities. Others include:
all(@list) > 0; # All members greater than zero?
all(@a) == any(@b); # All elements of @a present in @b?

Go experiment, and have fun!


Posted in  2009  |  9 Comments »
Day 12: Modules and Exporting December 12, 2009


Today I’d like to talk about a fairly fundamental subject: libraries.

To write a library in Perl 6, we use the “module” keyword:
module Fancy::Utilities {
    sub lolgreet($who) {
        say "O HAI " ~ uc $who;
    }
}

Put that in Fancy/Utilities.pm somewhere in $PERL6LIB and we can use it like the following:
use Fancy::Utilities;
Fancy::Utilities::lolgreet('Tene');

That’s hardly ideal.  Just like in Perl 5, we can indicate that some symbols from the module should be made available in the lexical scope of the code loading the module.  We’ve got a rather different syntax for it, though:
# Utilities.pm
module Fancy::Utilities {
  sub lolgreet($who) is export {
    say "O HAI " ~ uc $who;
  }
}
 
# foo.pl
use Fancy::Utilities;
lolgreet('Jnthn');

If you don’t specify further, symbols marked “is export” are exported by default.  We can also choose to label symbols as being exported as part of a different named group:
module Fancy::Utilities {
sub lolgreet($who) is export(:lolcat, :greet) {
  say "O HAI " ~ uc $who;
}
sub nicegreet($who) is export(:greet, :DEFAULT) {
  say "Good morning, $who!"; # Always morning?
}
sub shortgreet is export(:greet) {
  say "Hi!";
}
sub lolrequest($item) is export(:lolcat) {
  say "I CAN HAZ A {uc $item}?";
}
}

Those tags can be referenced in the code loading this module to choose which symbols to import:
use Fancy::Utilities; # Just get the DEFAULTs
use Fancy::Utilities :greet, :lolcat;
use Fancy::Utilities :ALL; # Everything marked is export

Multi subs are export by default, so you only need to label them if you want to change that.
multi sub greet(Str $who) { say "Good morning, $who!" }
multi sub greet() { say "Hi!" }
multi sub greet(Lolcat $who) { say "O HAI " ~ $who.name }

Classes are just a specialization of modules, so you can export things from them as well.  In addition, you can export a method to make it available as a multi sub.  For example, the setting exports the “close” method from the IO class so you can call “close($fh);”
class IO {
    ...
    method close() is export {
        ...
    }
    ...
}

Perl 6 does support importing symbols by name from a library, but Rakudo does not yet implement it.


Posted in  2009  |  3 Comments »
Day 11: Classes, attributes, methods and more December 11, 2009


We excitedly tear the shiny wrapping paper off today’s gift, and inside we find something that nobody could object to! It’s the Perl 6 object model, in all its class-declaring, role-composing, meta-modelling glory. But before we get too carried away with the high-powered stuff, let’s see just how easy it is to write a class in Perl 6.

class Dog {
    has $.name;
    method bark($times) {
        say "w00f! " x $times;
    }
}

We start off by using the class keyword. If you’re coming from a Perl 5 background, you can think of class as being a bit like a variant of package that gives you a bunch of classy semantics out of the box.

Next, we use the has keyword to declare an attribute along with an accessor method. The . that you see in the name is a twigil. Twigils tell you something special about the scoping of a variable. The . twigil means “attribute + accessor”. Other options are:

has $!name;       # Private; only visible in the class
has $.name is rw; # Generates an l-value accessor

Next comes a method, introduced using the method keyword. method is like sub, but adds an entry to the methods table of the class. It also automatically takes the invocant for you, so you don’t have to write it in the parameter list. It is available through self.

All classes inherit a default constructor, named new, which maps named parameters to attributes. We can call this on Dog – the type object of the Dog class – to get a new instance.

my $fido = Dog.new(name => 'Fido');
say $fido.name;  # Fido
$fido.bark(3);   # w00f! w00f! w00f!

Notice that the method call operator in Perl 6 is . rather than Perl 5′s ->. It’s 50% shorter, and will be familiar to developers coming from a range of other languages.

Of course, there’s inheritance, so we can introduce a yappy puppy.

class Puppy is Dog {
    method bark($times) {
        say "yap! " x $times;
    }
}

There’s also support for delegation.

class DogWalker {
    has $.name;
    has Dog $.dog handles (dog_name => 'name');
}
my $bob = DogWalker.new(name => 'Bob', dog => $fido);
say $bob.name;      # Bob
say $bob.dog_name;  # Fido

Here, we declare that we’d like calls to the method dog_name on the class DogWalker to forward to the name method of the contained Dog. Renaming is just one option that is available; the delegation syntax offers many other alternatives.

The beauty is more than skin deep, however. Beneath all of the neat syntax is a meta-model. Classes, attributes and methods are all first class in Perl 6, and are represented by meta-objects. We can use these to introspect objects at runtime.

for Dog.^methods(:local) -> $meth {
    say "Dog has a method " ~ $meth.name;
}

The .^ operator is a variant on the . operator, but instead makes a call on the metaclass – the object that represents the class. Here, we ask it to give us a list of the methods defined within that class (we use :local to exclude those inherited from parent classes). This doesn’t just give us a list of names, but instead a list of Method objects. We could actually invoke the method using this object, but in this case we’ve just ask for its name.

Those of you into meta-programming and looking forward to extending the Perl 6 object model will be happy to know that there’s also a declarational aspect to all of this, so uses of the method keyword actually compile down to calls to add_method on the meta-class. Perl 6 not only offers you a powerful object model out of the box, but also provides opportunities for it to grow to meet other future needs that we didn’t think of yet.

These are just a handful of the great things that the Perl 6 object model has to offer; maybe we’ll discover more of them in some of the other gifts under the tree. :-)

来源： < http://perl6advent.wordpress.com/category/2009/page/2/ >  