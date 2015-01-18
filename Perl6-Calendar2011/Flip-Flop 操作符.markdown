The Flip-Flop operator December 5, 2011


Perl5有一个二元操作符叫做flip-flop,它为假直到它的第一个参数被计算为真，然后它保持真(反转)，直到第二个参数计算为真，然后在那里它又变成假(flop)。 这真是太有用了，以至于Perl6也有flip-flop,只是它拼写为ff,并有一些变异 ：
    ff
    ff^
    ^ff
    ^ff^

音调符号^意味着在那个结尾跳过结尾。

…或许一些例子更能说明问题…
    for 1..20 { .say if $_ == 9  ff  $_ == 13; }     # 9 10 11 12 13
    for 1..20 { .say if $_ == 9  ff^ $_ == 13; }     # 9 10 11 12
    for 1..20 { .say if $_ == 9 ^ff  $_ == 13; }     #   10 11 12 13
    for 1..20 { .say if $_ == 9 ^ff^ $_ == 13; }     #   10 11 12

每个例子中，我们遍历从1到20的数字范围，并且在flip-flop返回真时输出那些数字。每次循环中，flip-flop 操作符的左边( $_ == 9 ) 和 flip-flop操作符的右边 ( $_ == 13 )都会被计算。 (这里我已经在 flip-flop操作符的两侧使用了简单的数字比较，但是，一般任何布尔表达式都能使用。

Each instance of the flip-flop operator maintains it’s own little bit of internal state to decide when to return  True  or  False . All flip-flop operators are born with their internal state set to return  False waiting for the moment they can be flipped and start returning  True .每个 flip-flop 操作符的实例维护它们的内部状态以决定什么时候返回TRUE或False.所有的flip-flop操作符在它们的内部状态被设置为返回False时出现，直到它们被反转然后开始返回 TRUE.

In the first and second examples when  $_ == 9 , the flip-flop operators flips their internal state to  True  and immediately return True .  In the third and fourth examples when  $_ == 9  the flip-flop operators set their internal state to  True  but they return  False  on that iteration because of the leading circumflex.在第一个和第二个例子中，当$_ == 9 时，flip-flop 操作符反转它们的内部状态为 TRUE ，然后立即返回 TRUE.在第三个和第四个例子中，当$_== 9时，flip-flop操作符将它们的内部状态设置为 TRUE,但是它们在那次遍历中返回 False ，因为前置的 ^符号。

类似地，在上面的第一个和第三个例子中，一旦RHS求值为真时， flip-flop操作符在下一次循环中将它们的内部状态反转回FALSE,然后返回True.在第三个和第四个例子中，flip-flop操作符在RHS返回真时立即反转为FALSE.Similarly, in the first and third examples above, once the RHS evaluates to  True , the flip-flop operators flop their internal state back to  False on next evaluation and return  True . In the third and fourth examples, the flip-flops operators flop sooner by returning  False  immediately upon evaluating the RHS  True .

To make the flip-flop operator flip, but never flop, use a  *  on the RHS:让flip-flop操作符反转但从不flop,在RHS上使用*：
    for 1..20 { .say if $_ == 15 ff * ; }     # 15 16 17 18 19 20

Perl 6 has another set of flip-flop operators that function similar to the ones mentioned above, except the RHS isn’t evaluted when the LHS becomes true. This is particularly important when both the RHS and the LHS of the flip-flop could evaluate to  True  at the same time.perl6有另外一套 flip-flop操作符，功能与上面提到的差不多，除了，在LHS变成真的时候，RHS不被求值。这很有用，当flip-flop操作符的RHS 和LHS 都同时求值为真的时候，These operators are spelled 这些操作符被拼写为   fff ,  fff^ ,  ^fff , and  ^fff^ .


Posted in  2011  |  7 Comments »
Traits — Meta Data With Character December 4, 2011


Traits are a nice, extensible way to attach meta data to all sorts of objects in Perl 6.

An example is the  is cached  trait that automatically caches the functions return value, based on the argument(s) passed to it.

Here is a simple implementation of that trait:
# this gets called when 'is cached' is added
# to a routine
multi sub trait_mod:<is>(Routine $r, :$cached!) {
     my %cache;
     #wrap the routine in a block that..
     $r.wrap(-> $arg {
         # looks up the argument in the cache
         %cache.exists($arg)
             ?? %cache{$arg}
             # ... and calls the original, if it
             # is not found in the cache
             !! (%cache{$arg} = callwith($arg))
         }
     );
}
 
# example aplication:
sub fib($x) is cached {
     say("fib($x)");
     $x <= 1 ?? 1 !! fib($x - 1) + fib($x - 2);
}
# only one call for each value from 0 to 10
say fib(10);

A trait is applied with a verb, here  is . That verb appears in the routine name that handles the trait, here  trait_mod:<is> . The arguments to that handler are the object on which the trait is applied, and the name of the trait (here  cached ) as a named argument.

Note that a production grade  is cached  would need to handle multiple arguments, and maybe things like limiting the cache size.

In this example, the  .wrap  method is called on the routine, but of course you can do whatever you want. Common applications are mixing roles into the routine or adding them to a dispatch table.

Traits can not only be applied to routines, but also to parameters, attributes and variables. For example writable accessors are realized with the  is rw  trait:
class Book {
     has @.pages is rw;
     ...
}

Traits are also used to attach documentation to classes and attributes (stay tuned for an addvent calendar post on Pod6), marking routine parameters as writable and declaring class inheritance and role application.

This flexibility makes them ideal for writing libraries that make the user code look like a domain-specific language, and supplying meta data in a safe way.


Posted in  2011  |  6 Comments »
Buffers and Binary IO December 3, 2011


Perl 5 is known to have very good Unicode support (starting from version 5.8, the later the better), but people still complain that it is hard to use. The most important reason for that is that the programmer needs to keep track of which strings have been decoded, and which are meant to be treated as binary strings. And there is no way to reliably introspect variables to find out if they are binary or text strings.

In Perl 6, this problem has been addressed by introducing separate types.  Str  holds text strings. String literals in Perl 6 are of type  Str . Binary data is stored in  Buf  objects. There is no way to confuse the two. Converting back and forth is done with the  encode  and  decode methods.
    my $buf = Buf.new(0x6d, 0xc3, 0xb8, 0xc3, 0xbe, 0x0a);
    $*OUT.write($buf);
 
    my $str = $buf.decode('UTF-8');
    print $str;

Both of those output operations have the same effect, and print  møþ  to the standard output stream, followed by a newline.  Buf.new(...) takes a list of integers between 0 and 255, which are the byte values from which the new byte buffer is constructed.  $*OUT.write($buf) writes the  $buf  buffer to standard output.

$buf.decode('UTF-8')  decodes the buffer, and returns a  Str  object (or dies if the buffer doesn’t consistute valid UTF-8). The reverse operation is  $Buf.encode($encoding) . A  Str  can simply be printed with  print .

Of course  print  also needs to convert the string to a binary representation somewhere in the process. There is a default encoding for this and other operations, and it is  UTF-8 . The Perl 6 specification allows the user to change the default, but no compiler implements that yet.

For reading, you can use the  .read($no-of-bytes)  methods to read a  Buf , and  .get  for reading a line as a  Str .

The  read  and  write  methods are also present on sockets, not just on the ordinary file and stream handles.

One of the particularly nasty things you can accidentally do in Perl 5 is
concatenating text and binary strings, or combine them in another way (like with  join  or string interpolation). The result of such an operation is a string that happens to be broken, but only if the binary string contains any bytes above 127 — which can be a nightmare to debug.

In Perl 6, you get  Cannot use a Buf as a string  when you try that, avoiding that trap.

The existing Perl 6 compilers do not yet provide the same level of Unicode support as Perl 5 does, but the bits that are there are much harder to misuse.


Posted in  2011  |  2 Comments »
Grammar::Tracer and Grammar::Debugger December 2, 2011


Grammars are, for many people, one of the most exciting features of Perl 6. They unify parsing with object orientation, with each production rule in your grammar being represented by a method. These methods are a little special: they are declared using the keywords “regex”, “rule” or “token”, each of which gives you different defaults on backtracking and whitespace handling. In common is that they lead to the body of the method being parsed using the Perl 6 rule syntax. Under the hood, however, they really are just methods, and production rules that refer to others are really just method calls.

Perl 6 grammars also give you a seamless way to combine declarative and imperative parsing. This means efficient mechanisms, such as NFAs and DFAs, may be used to handle the declarative parts – the things that your tokens tend to be made up of – while a more imperative mechanism drives the parsing of larger structures. This in turn means that you don’t need to write a tokenizer; it can be derived from the rules that you write in the grammar.

So what is the result of parsing some text with a grammar? Well, provided it’s able to match your input, you get back a parse tree. This data structure – made up of Match objects – captures the structure of the input. You can treat each Match node a little bit like a hash, indexing in to it to look at the values that its production rules matched. While you can build up your own tree or other data structure while parsing, sometimes the Match tree you get back by default will be convenient enough to extract the information you need.

That’s wonderful, but there was a key clause in all of this: “provided it’s able to match”. In the case that the grammar fails to match your input, then it tells you so – by giving back an empty Match object that, in boolean context, is false. It’s at this point that many people stop feeling the wonder of grammars and start feeling the pain of trying to figure out why on earth their seemingly fine grammar did not accept the input they gave it. Often, it’s something silly – but in a grammar of dozens of production rules – or sometimes even just ten – the place where things go wrong can be elusive.

Thankfully, help is now at hand, in the form of two modules: Grammar::Tracer, which gives you a tree-like trace output of your grammar, and Grammar::Debugger, which gives the same trace output but also enables you to set breakpoints and single step through the grammar.

A picture is worth a thousand words, so here’s how Grammar::Tracer looks in action!



What we’re seeing here is a tree representation of the production rules that were called, starting at “TOP”, next trying to parse a production rule called “country”, which in turn wants to parse a name, two “num”s and an “integer”. The green indicates a successful match, and next to it we see the snippet of text that was captured.

So what happens when things go wrong? In that case, we see something like this:



Here, we see that something happened during the parse that caused a cascade of failures all the way back up to the “TOP” production rule, which meant that the parse failed overall. Happily, though, we now have a really good clue where to look. Here is the text my grammar was trying to match at the time:
Russia
    Ulan Ude : 51.833333,107.600000 : 1
    Moscow : 55.75000,37.616667 : 4

Looking at this, we see that the “name” rule appears to have picked up “Ulan”, but actually the place in question is “Ulan Ude”. This leads us directly to the name production in our grammar:

token name { \w+ }

Just a smattering of regex fu is enough to spot the problem here: we don’t parse names that happen to have spaces in them. Happily, that’s an easy fix.

token name { \w+ [\h+ \w+]* }

So how do we turn on the tracing? Actually, that’s easy: just take the file containing the grammar you wish to trace, and add at the top:

use Grammar::Tracer;

And that’s it; now whenever you use the grammar, it will be traced. Note that this statement has lexical effect, so if you’re using modules that also happen to have grammars – which you likely don’t care about – they will not end up getting the tracing behavior.

You can also do this:

use Grammar::Debugger;

The debugger is the tracer’s big sister, and knows a few more tricks. Here’s an example of it in action.



Instead of getting the full trace, now as soon as we hit the TOP production rule the program execution breaks and we get a prompt. Pressing enter allows you to step rule by rule through the parse. For some people, this may be preferable; others prefer to get the full trace output and analyze it. However, there are a few more tricks. In the example above, I added a breakpoint on the “name” rule. Using “r” informs the debugger to keep running through the production rules until it hits one called “name”, at which point it breaks. It is also possible to add breakpoints in code, for more extended debugging sessions with many runs. There’s one additional feature in code, which is to set a conditional breakpoint.

Sound interesting? You can get modules  from GitHub , and if you want to see a live demo of a grammar being debugged using it, then there is a  video of my Debugging Perl 6 Grammars talk  from YAPC::Europe 2011;  slides  are also available to make the sample code more clear than it is on the video. Note that the modules need one of the compiler releases from the Rakudo “nom” development branch; we’ll be making a distribution release later this month based on that, though, and these modules will come with it.

You may also be thinking: I bet these are complex modules doing lots of guts stuff! In fact, they are 44 lines (Grammar::Tracer) and 171 lines (Grammar::Debugger), and written in Perl 6. They are built using the meta-programming support we’ve been working on in the Rakudo Perl 6 compiler during the course of the last year – and if you want to know more about that, be sure to check out my meta-programming post coming up later on in this year’s advent calendar.


Posted in  2011  |  3 Comments »
Day 1: Catching Up With Perl 6 December 1, 2011


When we started the Perl 6 Advent Calendar back in 2009, Rakudo was really the only game in town if you wanted to play with Perl 6. But Perl 6 was intended from the start to be a language with multiple implementations, and at the moment there are four different Perl 6 implementations of interest. Because there are so many implementations, I’m not going to give instructions for getting each; instead I’m linking to those instructions.

The most stable and complete implementation is  Rakudo Star . This is currently based on the  last  major revision of Rakudo. It’s been frozen since July, and so lags a bit behind the current Perl 6 spec. It’s slow. But it’s also pretty reliable.

The current Rakudo development version is called  “Nom” . It’s full of great improvements over the last Rakudo Star release, notably native types, improved performance, and a much better metamodel. (For example, check out the  Grammar::Tracer  module, which takes advantage of the new metamodel to add regex tracing in just 44 lines of code.) It’s not quite ready for prime time yet, as it still misses some features that work in Rakudo Star, but progress has been incredible, and it’s quite possible a new Rakudo Star based on Nom will be released during this month.

Stefan O’Rear’s  Niecza  was just a fledging compiler during last year’s Advent calendar, but it’s a serious contender these days. Built to run on the CLR (.NET and Mono), it is relatively zippy, implements a significant portion of Perl 6, and works easily with existing CLR libraries.

Lastly, ingy and Mäsak have plans afoot to revive  Pugs , the original Perl 6 implementation in Haskell. So far they’ve just got it building again on current Haskell compilers, but the long-term goal is to get it running on the spec tests again and bring it closer to the current spec.

Which implementation should you use? If you’re looking for a stable, fairly complete Perl 6, Rakudo Star is it. If you just want to explore the language, try Rakudo Nom — you will probably run into bugs, but it’s significantly more advanced than Rakudo Star, and exposing the bugs is a big help to Rakudo’s development. If you have an idea which would benefit from being able to use CLR libraries, Niecza is fantastic. There’s a handy  comparison chart  of the different features available.

Personally, I have all three of these installed on my machine, and have different projects underway on each of them.

Finally, please don’t hesitate to ask for help, either in the comments here or on the  #perl6  IRC channel on Freenode. The Perl 6 community is very friendly.

来源： < http://perl6advent.wordpress.com/2011/12/page/3/ >  