Day 15 – Something Exceptional December 15, 2011


The Perl 6 exception system is currently in development; here is a small example demonstrating a part of the current state:
use v6;
 
sub might_die(Real $x) {
     die "negative" if $x < 0;
     $x.sqrt;
}
 
for 5, 0, -3, 1+2i -> $n {
     say "The square root of $n is ", might_die($n);
 
     CATCH {
         # CATCH sets $_ to the error object,
         # and then checks the various cases:
         when 'negative' {
             # note that $n is still in scope,
             # since the CATCH block is *inside* the
             # to-be-handled block
             say "Cannot take square root of $n: negative"
         }
         default {
             say "Other error: $_";
         }
     }
}

This produces the following output under rakudo:
The square root of 5 is 2.23606797749979
The square root of 0 is 0
Cannot take square root of -3: negative
Other error: Nominal type check failed for parameter '$x'; expected Real but got Complex instead

A few interesting points: the presence of a  CATCH  block automatically makes the surrounding block catch exceptions. Inside the  CATCH  block, all lexical variables from the outside are normally accessible, so all the interesting information is available for error processing.

Inside the  CATCH  block, the error object is available in the  $_  variable, on the outside it is available in  $! . If an exception is thrown inside a CATCH  block, it is not caught — unless there is a second, inner  CATCH that handles it.

The insides of a  CATCH  block typically consists of  when  clauses, and sometimes a  default  clause. If any of those matches the error object, the error is considered to be handled. If no clause matches (and no default  block is present), the exception is rethrown.

Comparing the output from rakudo to the one that niecza produces for the same code, one can see that the last line differs:
Other error: Nominal type check failed in binding Real $x in might_die; got Complex, needed Real

This higlights a problem in the current state: The wording of error messages is not yet specified, and thus differs among implementations.

I am working on rectifying that situation, and also throwing interesting types of error objects. In the past week, I have managed to start throwing specific error objects from within the Rakudo compiler. Here is an example:
$ ./perl6 -e 'try eval q[ class A { $!x } ]; say "error: $!"; say $!.perl'
error: Attribute $!x not declared in class A
X::Attribute::Undeclared.new(
         name => "\$!x",
         package-type => "class",
         package-name => "A", filename => "",
         line => 1,
         column => Any,
         message => "Attribute \$!x not declared in class A"
)
# output reformatted for clarity

The string that is passed to  eval  is not a valid Perl 6 program, because it accesses an attribute that wasn’t declared in class  A . The exception thrown is of type  X::Attribute::Undeclared , and it contains several details: the name of the attribute, the type of package it was missing in (could be class, module, grammar and maybe others), the name of the package, the actual error message and information about the source of the error (line, cfile name (empty because  eval()  operates on a string, not on a file), and column, though column isn’t set to a useful value yet).

X::Attribute::Undeclared  inherits from type  X::Comp , which is the common superclass for all compile time errors. Once all compile time errors in Rakudo are switched to  X::Comp  objects, one will be able to check if errors were produced at run time or at compile with code like
eval $some-string;
CATCH {
     when X::Comp { say 'compile time' }
     default      { say 'run time'     }
}

The  when  block smart-matches the error object against the  X::Comp type object, which succeeds whenever the error object conforms to that type (so, is of that type or a subclas of  X::Comp ).

Writing and using new error classes is quite easy:
class X::PermissionDenied is X::Base {
     has $.reason;
     method message() { "Permission denied: $.reason" };
}
# and using it somewhere:
die X::PermissionDenied.new( reason => "I don't like your nose");

So Perl 6 has a rather flexible error handling mechanism, and libraries and applications can choose to throw error objects with rich information. The plan is to have the Perl 6 compilers throw such easily introspectable error objects too, and at the same time unify their error messages.

Many thanks go to Ian Hague and The Perl Foundation for funding my work on exceptions.


Posted in  2011  |  4 Comments »
Meta-programming: what, why and how December 14, 2011


Sometimes, it’s good to take ones understanding of a topic, throw it away and try to build a new mental model of it from scratch. I did that in the last couple of years with object orientation. Some things feel ever so slightly strange to let go of and re-evaluate. For many people, an object really is “an instance of a class” and inheritance really is a core building block of OOP. I suspect many people who read this post will at this point be thinking, “huh, of course they really are” – and if so, that’s totally fair enough. Most people’s view of OOP will, naturally, be based around the languages they’ve applied object orientation in, and most of the mainstream languages really do have objects that are instances of classes and really do have inheritance as a core principle.

Step back and look around, however, and things get a bit more blurry. JavaScript doesn’t have any notion of classes. CLOS (the Common Lisp Object System) does have classes, but they don’t have methods. And even if we do just stick with the languages that have classes with methods, there’s a dizzying array of “extras” playing their part in the language’s OO world view; amongst them are interfaces, mixins and roles.

Roles – more often known as traits in the literature – are a relatively recent arrival on the OO scene, and they serve as an important reminder than object orientation is not finished yet. It’s a living, breathing paradigm, undergoing its own evolution just as our programming languages in general are.

And that brings me nicely on to Perl 6 – a language that from the start has set out to be able to evolve. At a syntax level, that’s done by opening up the grammar to mutation – in a very carefully controlled way, such that you always know what language any given lexical scope is in. Meta-programming plays that same role, but in the object orientation and type system space.

So what is a meta-object? A meta-object is simply an object that describes how a piece of our language works. What sorts of things in Perl 6 have meta-objects? Here’s a partial list.
Classes
Roles
Subsets
Enumerations
Attributes
Subroutines
Methods
Signatures
Parameters


So that’s meta-objects, but what about the protocol? You can read protocol as “API” or “interface”. It’s an agreed set of methods that a meta-object will provide if it wants to expose certain features. Let’s consider the API for anything that can have methods, such as classes and roles. At a minimum, it will provide:
add_method – adds a method to the object
methods – enables introspection of the methods that the object has
method_table – provides a hash of the methods in this type, excluding any that may be inherited


What about something that you can call a method on? It just has to provide one thing:
find_method – takes an object and a name, and returns the method if one exists


By now you may be thinking, “wait a moment, is there something that you can call a method on, but that does not have methods”? And the answer is – yes. For example, an enum has values that you can call a method on – the methods that the underlying type of the enumeration provides. You can’t actually add a method to an enum itself, however.

What’s striking about this is that we are now doing object oriented programming…to implement our object oriented language features. And this in turn means that we can tweak and extend our language – perhaps by subclassing an existing meta-object, or even by writing a new one from scratch. To demonstrate this, we’ll do a simple example, then a trickier one.

Suppose we wanted to forbid multiple inheritance. Here’s the code that we need to write.
my class SingleInheritanceClassHOW
    is Mu is Metamodel::ClassHOW
{
    method add_parent(Mu $obj, Mu $parent) {
        if +self.parents($obj, :local) > 0 {
            die "Multiple inheritance is forbidden!";
        }
        callsame;
    }
}
my module EXPORTHOW { }
EXPORTHOW.WHO.<class> = SingleInheritanceClassHOW;

What are we doing here? First, we inherit from the standard Perl 6 implementation of classes, which is defined by the class Metamodel::ClassHOW. (For now, we also inherit from Mu, since meta-objects currently consider themselves outside of the standard type hierarchy. This may change.) We then override the add_parent method, which is called whenever we want to add a parent to a class. We check the current number of (local) parents that a class has; if it already has one, then we die. Otherwise, we use callsame in order to just call the normal add_parent method, which actually adds the parent.

You may wonder what the $obj parameter that we’re taking is, and why it is needed. It is there because if we were implementing a prototype model of OOP, then adding a method to an object would operate on the individual object, rather than stashing the method away in the meta-object.

Finally, we need to export our new meta-object to anything that uses our module, so that it will be used in place of the “class” package declarator. Do do this, we stick it in the EXPORTHOW module, under the name “class”. The importer pays special attention to this module, if it exists. So, here it is in action, assuming we put our code in a module si.pm. This program works as usual:
use si;
class A { }
class B is A { }

While this one:
class A { }
class B { }
class C is A is B { }

Will die with:
===SORRY!===
Multiple inheritance is forbidden!

At compile time.

Now for the trickier one. Let’s do a really, really simple implementation of aspect oriented programming. We’ll write an aspects module. First, we declare a class that we’ll use to mark aspects.
my class MethodBoundaryAspect is export {
}

Next, when a class is declared with “is SomeAspect”, where SomeAspect inherits from MethodBoundaryAspect, we don’t want to treat it as inheritance. Instead, we’d like to add it to a list of aspects. Here’s an extra trait modifier to do that.
multi trait_mod:(Mu:U $type, MethodBoundaryAspect:U $aspect) is export {
    $aspect === MethodBoundaryAspect ??
        $type.HOW.add_parent($type, $aspect) !!
        $type.HOW.add_aspect($type, $aspect);
}

We take care to make sure that the declaration of aspects themselves – which will directly derive from this class – still works out by continuing to call add_parent for those. Otherwise, we call a method add_aspect, which we’ll define in a moment.

Supposing that our aspects work by optionally implementing entry and exit methods, which get passed the details of the call, here’s our custom meta-class, and the code to export it, just as before.
my class ClassWithAspectsHOW
    is Mu is Metamodel::ClassHOW
{
    has @!aspects;
    method add_aspect(Mu $obj, MethodBoundaryAspect:U $aspect) {
        @!aspects.push($aspect);
    }
    method compose(Mu $obj) {
        for @!aspects -> $a {
        for self.methods($obj, :local) -> $m {
            $m.wrap(-> $obj, |$args {
                $a.?entry($m.name, $obj, $args);
                my $result := callsame;
                $a.?exit($m.name, $obj, $args, $result);
                $result
            });
        }
        }
        callsame;
    }
}
my module EXPORTHOW { }
EXPORTHOW.WHO.<class> = ClassWithAspectsHOW;

Here, we see how add_aspect is implemented – it just pushes the aspect onto a list. The magic all happens at class composition time. The compose method is called after we’ve parsed the closing curly of a class declaration, and is the point at which we finalize things relating to the class declaration. Ahead of that, we loop over any aspects we have, and the wrap each method declared in the class body up so that it will make the call to the entry and exit methods.

Here’s an example of the module in use.
use aspects;
class LoggingAspect is MethodBoundaryAspect {
    method entry($method, $obj, $args) {
        say "Called $method with $args";
    }
    method exit($method, $obj, $args, $result) {
        say "$method returned with $result.perl()";
    }
}
class Example is LoggingAspect {
    method double($x) { $x * 2 }
    method square($x) { $x ** 2 }
}
say Example.double(3);
say Example.square(3);

And the output is:
Called double with 3
double returned with 6
6
Called square with 3
square returned with 9
9

So, a module providing basic aspect orientation support in 30 or so lines. Not so bad.

As you can imagine, we can go a long way with meta-programming, whether we want to create policies, development tools (like Grammar::Debugger) or try to add entirely new concepts to our language. Happy meta-hacking.


Posted in  2011  |  2 Comments »
Bailador — A small Dancer clone December 13, 2011


Today we’ll write a simple Dancer clone in Perl 6. Simple also means Very Minimal — it will only recognize basic GET requests. Let’s look at how the simplest Dancer app possible looks like:
    get '/' => sub {
        "Hello World!"
    };
    dance;

So we need something to add routes to our app, and something to run it. Let’s take care of adding routes first. We’ll create an array to store all those, and thus  get()  will just add them to it.
    my @routes;
    sub get(Pair $x) is export {
        @routes.push: $x;
    }

In case you’re not familiar with the  Pair  thing, in Perl 6 a fat comma ( => ) creates an actual data structure containing a key and a value. In this case, the key is just a string ‘/’, and the value is a subroutine.

Having  @routes  being a simple array of keys and values we can now write a simple dispatcher:
    sub dispatch($env) {
        for @routes -> $r {
            if $env<REQUEST_URI> ~~ $r.key {
                return $r.value.();
            }
        }
        return "404";
    }

dispatch()  takes a hash representing our environment, which contains the  REQUEST_URI  string, basing on which we’ll try to find an appropriate candidate to dispatch to.

The above example is also cheating a bit: it just returns a ’404′ string instead of creating a proper HTTP response. Making it respond properly is left as an exercise for the reader (not the last one in this short article, I assure you :)).

Since we got that far already, writing our own  dance()  is a piece of cake. We’re going to call it  baile()  though. Why do we write all this in Spanish? If you can guess on which classes I was bored and wrote this thing on a piece of paper, then on the next YAPC I’ll show you the fastest possible way to tie a shoe. No kidding! But let’s finish this thing first.

Luckily we don’t need to write our own web server now. We have HTTP::Server::Simple::PSGI  in Perl 6, which will do most of the hard work for us. The only thing we have to do is to create a PSGI app. In case you’ve never heard of it, a PSGI app is a mere subroutine, taking the environment as an argument, and returning an array of three things: an HTTP response code, an array of HTTP headers and a response body. Once we have our PSGI app ready, we just feed HTTP::Server::Simple::PSGI  with it, and we’re good to go.
    sub baile is export {
        my $app = sub($env) {
            my $res = dispatch($env);
            return ['200', [ 'Content-Type' => 'text/plain' ], $res];
        }
 
        given HTTP::Server::Simple.PSGI.new {
            .host = 'localhost';
            .app($app);
            .run;
        }
    }

Yep, we’re cheating again and returning  200  no matter what. Remember the part about “an exercise for the reader?” You can think about it while celebrating a working Dancer clone. But wait, there’s more!

Let’s look at our  dispatch()  once again:
    sub dispatch($env) {
        for @routes -> $r {
            if $env<REQUEST_URI> ~~ $r.key {
                return $r.value.();
            }
        }
        return "404";
    }

You probably noticed that we’ve used  ~~  — a smartmatching operator. Thanks to that, we can match  REQUEST_URI  against strings, but not only.  Junctions  will work fine too:
    get any('/h', '/help', '/halp') => sub {
        "A helpful help message"
    }

And regexes:
    get /greet\/(.+)/ => sub ($x) {
        "Welcome $x"
    }

The last one will need a bit of tweaking in  dispatch() . Yes,  ~~  does the regex matching for us, but we have to take care of passing the match results to the callback function. Let’s modify the  if  body then:
    sub dispatch($env) {
        for @routes -> $r {
            if $env<REQUEST_URI> ~~ $r.key {
                if $/ {
                    return $r.value.(|$/.list);
                } else {
                    return $r.value.();
                }
            }
        }
        return "404";
    }

The  if $/  part checks whether the match resulted in setting the Match  object in the  $/  variable. If it did, we flatten the  Match  to a list, and pass it to the callback function. We need a  |  prefix, so it becomes expanded to a parameter list instead of being passed as a mere array. From now on, the above example with  greet  will Just Work. Yay!

The Bailador code presented here is available  in the Github repository . If you feel challenged by the “exercises for the reader”, or just want to make it a bit more proper Dancer port, you’re welcome to hack on it a bit and contribute. I hope I showed you how simple it is to write a simple, yet useful thing, and going with those simple steps we can hopefully get to something close to a full-blown Dancer port. Happy hacking, and have an appropriate amount of fun!


Posted in  2011  |  Leave a Comment »
Exploratory parsing with Perl 6 December 12, 2011


There have already been some delectable little grammar goodies this Advent Calendar. We hope to add to that today, with a discussion of the concept of “Exploratory Parsing” and Perl 6.

There’s no question that many modern programming languages having embraced regular expressions as a central part of the language or via a standard library. Some languages have introduced full-blown-parsing facilities as core features of their design. For example, many functional languages give us powerful parser combinators. Perl 6, as the astute advent reader knows, gives us “Regexes and Rules”. It turns out that Perl 6 Regexes are an implementation of  parsing expression grammars , or PEGs for short, originally formulated by Bryan Ford.

I was inspired by a recent  Ward Cunnigham   post  where he uses PEGs to explore seemingly unstructured text. Ward used an implementation of a PEG parser generator written in C by  Ian Piumarta .

We however have a powerful PEG-like parser built right into the core of the Perl 6 language, so what better way to play with exploratory parsing than getting cozy with your favourite Perl 6 compiler, pouring yourself another glass of eggnog, and divining meaning from random text out on the interwebs!

Our first example is taken directly from Ward’s “Exploratory Parsing” post. If you haven’t at least perused it yet, may I encourage you to do so.

The first thing we do is retrieve some data to explore:
wget http://introcs.cs.princeton.edu/java/data/world192.txt

We then translate Ward’s first example into Perl 6:
use v6;
 
# Inspired by
# http://dev.aboutus.org/2011/07/03/getting-started-exploratory-parsing.html
# but using Perl 6 regexes and tokens
 
grammar ExploratoryParsing {
    token TOP {
        <fact>+
    }
 
    token fact { <key> <value> | <other_char> }
 
    token key { <whitespace> <word>+ ':' }
 
    token value { [<!key> .]+ }
 
    token word { <alpha>+ ' '* }
 
    token whitespace { '\n' ' '* }
 
    token other_char { . }
 
}

I don’t know about you, but I love how declarative this is. I encourage you to compare the two implementations. The translation is almost trivial, no?

We introduce a MAIN method which slurps up a data file, uses our grammar definition to parse the text, and tells us how many “facts” we’ve found.
sub MAIN() {
    my $text = slurp('world192.txt');
    say "Read world factbook. Parsing...";
 
    my $match = ExploratoryParsing.parse($text);
    say "Found ", +$match, " facts.";
}

Running this with the Rakudo Perl 6 compiler we get:
$ perl6 exp-parsing.pl
Read world factbook. Parsing...
Found 16814 facts.

If we use the awesomely awesome Grammar::Tracer or Grammar::Debugger already  unwrapped for us earlier  this month, we can even step further into this and explore matches.

The remaining embellishments from Ward’s original post are left as an exercise for the reader.

You can see how powerful this idea is. We start with some semi-structured text and use the power of Perl 6 Regexes and Rules to start pulling things apart, stirring the precipitate meaning and exploring pattern and trends we see in the data. This kind of work is trivial in a language like Perl 6 with powerful parsing support. You can even imagine jumping into a Perl 6 REPL and doing this interactively.

Hopefully this has whet your appetite for playing with Perl 6 regexes. Happy parsing.


Posted in  2011  |  Leave a Comment »
Privacy and OOP December 11, 2011


There are a number of ways in which Perl 6 encourages you to restrict the scope of elements of your program. By doing so, you can better understand how they are used and will be able to refactor them more easily later, potentially aiding agility. Lexical scoping is one such mechanism, and subroutines are by default lexically scoped.

Let’s take a look at a class that demonstrates some of the object oriented related privacy mechanisms.
    class Order {
        my class Item {
            has $.name;
            has $.price;
        }
 
        has Item @!items;
 
        method add_item($name, $price) {
            @!items.push(Item.new(:$name, :$price))
        }
 
        method discount() {
            self!compute_discount()
        }
 
        method total() {
            self!compute_subtotal() - self!compute_discount();
        }
 
        method !compute_subtotal() {
            [+] @!items>>.price
        }
 
        method !compute_discount() {
            my $sum = self!compute_subtotal();
            if $sum >= 1000 {
                $sum * 0.15
            }
            elsif $sum >= 100 {
                $sum * 0.1
            }
            else {
                0
            }
        }
    }

Taking a look at this, the first thing we notice is that Item is a lexical class. A class declared with “my” scope can never be referenced outside of the scope it is declared within. In our case, we never leak instances of it outside of our Order class either. This makes our class an example of the aggregate pattern: it prevents outside code from holding direct references to the things inside of it. Should we ever decide to change the way that our class represents its items on the inside, we have complete freedom to do so.

The other example of a privacy mechanism at work in this class is the use of private methods. A private method is declared just like an ordinary method, but with an exclamation mark appearing before its name. This gives it the same visibility as an attribute (which, you’ll note, are also declared with an exclamation mark – a nice bit of consistency). It also means you need to call it differently, using the exclamation mark instead of the dot.

Private methods are non-virtual. This may seem a little odd at first, but is consistent: attributes are also not visible to subclasses. By being non-virtual, we also get some other benefits. The latest Rakudo, with its optimizer cranked up to its highest level, optimizes calls to private methods and complains about missing ones at compile time. Thus a typo:
    self!compite_subtotal() - self!compute_discount();

Will get us a compile time error:
    ===SORRY!===
    CHECK FAILED:
    Undefined private method 'compite_subtotal' called (line 18)

You may worry a little over the fact that we now can’t subclass the discount computation, but that’s likely not a good design anyway; for one, we’d need to also expose the list of items, breaking our aggregate boundary. If we do want pluggable discount mechanisms we’d probably be better implementing the strategy pattern.

Private methods can, of course, not be called from outside of the class, which is also a compile time error. First, if you try:
    say $order!compute_discount;

You’ll be informed:
    ===SORRY!===
    Private method call to 'compute_discount' must be fully qualified
    with the package containing the method

Which isn’t so surprising, given they are non-virtual. But even if we do:
    say $o!Order::compute_discount;

Our encapsulation-busting efforts just get us:
    ===SORRY!===
    Cannot call private method 'compute_discount' on package Order
    because it does not trust GLOBAL

This does, however, hint at the get-out clause for private methods: a class may choose to trust another one (or, indeed, any other package) to be able to call its private methods. Critically, this is the decision of the class itself; if the class declaration didn’t decide to trust you, you’re out of luck. Generally, you won’t need “trusts”, but occasionally you may be in a situation where you have two very closely coupled classes. That’s usually undesirable in itself, though. Don’t trust too readily. :-)

So, lexical classes, private methods and some nice compiler support to help catch mistakes. Have an agile advent. :-)


Posted in  2011  |  Leave a Comment »
Documenting Perl 6 December 10, 2011


A wise man once said that programs must be written for people to read, and only incidentally for machines to execute. But aside from being read, your code is also going to be used by people, who don’t really want to dive into it to understand what it does. That’s where the documentation comes in.

In Perl 5 we had POD, which stands for Plain Old Documentation. In Perl 6 we have Pod, which is not really an abbreviation of anything. As its specification says, “Perl 6′s Pod is much more uniform, somewhat more compact, and considerably more expressive”. It has changed slightly compared to Perl 5 Pod, but most of the stuff remains the same, or at least very similar.

There are three main types of Pod blocks in Perl 6.  Delimited blocks are probably the most obvious and simple ones:
    =begin pod
    <whatever Pod content we want>
    =end pod

Paragraph blocks  are a bit more magical. They begin with  =for , and end on the nearest blank line (as the name, Paragraph, suggest):
    my $piece = 'of perl 6 code'
    =for comment
    Here we put whatever we want.
    The compiler will not notice anyway.
    our $perl6 = 'code continues';

Abbreviated blocks  are similar to  Paragraph blocks . The leading  =  is followed immediately by a Pod block identifier and the content. Sounds familiar?
    =head1 Shoulders, Knees and Toes

That’s right,  =head  is nothing magical in Perl 6 Pod. That means you can write it also as a paragraph block
    =for head1
    Longer header
    than we usually write.

Or a full-blown delimited block
    =begin head1
    This header is longer than it should be
    =end head1

Any block can be written as a delimited block, paragraph block, or abbreviated block. No magic. Not all blocks are created equal, of course.  =head  will be treated differently than plain  =pod . By whom? By the Pod renderer, of course, but also by the Perl 6 compiler itself. In Perl 6, Pod is not a second-class citizen, ignored during the program compilation. Pod in Perl 6 is a part of the code; along with parsing and constructing AST of the code to be executed, the compiler also parses and builds AST of all Pod blocks. They are then kept in the special $=POD  variable, and can be inspected by the runtime:
    =begin pod
    Some pod content
    =end pod
    say $=POD[0].content[0].content;

The  say  line may look a little complicated. Content, of a content, of a what? What really happens, is that ‘Some pod content’ is parsed as an ordinary paragraph, and kept in the  Pod::Block::Para  object. The delimited block started with  =begin pod  becomes a Pod::Block::Named , and it can contain any number of child blocks. It’s also a first block in our example code, so it ends up in  $=POD[0] .

You now probably think “geez, how ugly is that. Who’s going to use it in this form”. Don’t worry. Frankly, I don’t expect anyone to use the AST directly. That’s what Pod renderers are useful for. Take for example  Pod::To::Text :
    =begin pod
    =head1 A Heading!
    A paragraph! With many lines!
        An implicit code block!
        my $a = 5;
    =item A list!
    =item Of various things!
    =end pod
    DOC INIT {
        use Pod::To::Text;
        pod2text($=POD);
    }

Ran as it is, the code doesn’t produce any output. Why is it so? The DOC INIT  block looks a little special. It gets run with every other  INIT block, but also only when the  --doc  flag is passed to the compiler. Let’s take a look:
    $ perl6 --doc foo.pl
    A Heading!
 
    A paragraph! With many lines!
 
        An implicit code block!
        my $a = 5;
 
     * A list!
 
     * Of various things!

Actually, when no  DOC INIT  block exists in the code, the compiler generates a default  DOC INIT , identical to the one in the example above. So you could really omit it, leaving only the Pod in the file, and perl6 --doc  will produce exactly the same result.

But wait, there’s more!

I wrote about 3 types of Pod blocks, but there’s another one I didn’t talk about before. They are  Declarator blocks , and they single purpose is to document the actual Perl 6 objects. Take a look.
    #= it's a sheep! really!
    class Sheep {
 
        #= produces a funny sound
        method bark {
            say "Actually, I don't think sheeps bark"
        }
    }

Every declarator block gets attached to the object which comes after it. It’s available in the  .WHY  attribute, so we can use it like this:
    say Sheep.WHY.content;                      # it's a sheep! really!
    say Sheep.^find_method('bark').WHY.content; # produces a funny sound

In this case we also don’t need to care about doing a  ^find_method and all this for every piece of documentation we want to read. The mighty  Pod::To::Text  takes care about it too. If we run the Sheep code with  --doc  flag, we get the following:
    class Sheep: it's a sheep! really!
    method bark: produces a funny sound

The specification says it’s possible to document all the class attributes and all the arguments that methods or subroutines take. Unfortunately no Perl 6 implementation (that I know of) implements those yet.

There are dozens of Pod features that are not covered by this post, for example the formatting codes ( <,  > and so), or tables. If you’re interested take a look at Synopsis 26 ( http://perlcabal.org/syn/S26.html ). It’s actually written in Pod 6, and rendered by  Pod::To::HTML . Not all features it describes are implemented yet, but most of them are (see the test suite linked below), and some modules are actually documented with it ( Term::ANSIColor  for example).

Some useful links: Synopsis 26 Pod::To::Text source code Term::ANSIColor documentation
Pod test suite (shows what Pod in Rakudo is capable of)

Happy documenting!


Posted in  2011  |  Leave a Comment »
Day 9: Contributing to Perl 6 December 9, 2011


This time, instead of sharing some cool feature of Perl 6, I’d like to talk about how easy it is to contribute usefully to the project. So I’m going to walk you through the process of making a change to Niecza. It does require a bit of domain knowledge (which the fine folks on  #perl6  will be happy to help you with) but it’s definitely not rocket science. It’s not even particularly deep computer science, for the most part.

A few days ago, Radvendii asked on  #perl6  if there was a  round function in the core. The correct answer is “There should be one”, and it lead to a couple of bug fixes in Rakudo. But it got me to thinking — is Niecza supporting  round  (and its relatives  ceiling ,  floor , and truncate ) correctly?

Perl 6 has a  huge suite of tests  to see if an implementation is conforming to the spec, including a file for the  round  tests,  S32-num/rounders.t . My first step then was to check the spectests currently being run by Niecza. Just like in Rakudo, this is stored in a file named  t/spectest.data . So

 1
 2
 Wynne:niecza colomon$ grep round t/spectest.data
 Wynne:niecza colomon$


Okay, clearly we’re not running the  S32-num/rounders.t  test file. (Note, in case you’re getting confused — the links in this post are to the latest versions of the files, which include all the changes I made writing this post.) That’s a sign that something is not properly supported yet. So let’s go ahead and run it by hand to see what happens. Both Niecza and Rakudo use a fudging process, allowing you to mark the bits of a test file that don’t work yet in a particular compiler. So we need to use a special fudging tool to run the code:

 1
 2
 3
 4
 5
 6
 Wynne:niecza colomon$ t/fudgeandrun t/spec/S32-num/rounders.t
 1..108
 not ok 1 - floor(NaN) is NaN
 # /Users/colomon/tools/niecza/t/spec/S32-num/rounders.t line 16
 #    Failed test
 #           got: -269653970229347386159395778618353710042696546841345985910145121736599013708251444699062715983611304031680170819807090036488184653221624933739271145959211186566651840137298227914453329401869141179179624428127508653257226023513694322210869665811240855745025766026879447359920868907719574457253034494436336205824


That’s followed by about 15 similar errors, then

 1
 2
 3
 4
 5
 6
 Unhandled exception: Unable to resolve method truncate in class Num
    at /Users/colomon/tools/niecza/t/spec/S32-num/rounders.t line 34 (mainline @ 32)
    at /Users/colomon/tools/niecza/lib/CORE.setting line 2224 (ANON @ 2)
    at /Users/colomon/tools/niecza/lib/CORE.setting line 2225 (module-CORE @ 58)
    at /Users/colomon/tools/niecza/lib/CORE.setting line 2225 (mainline @ 1)
    at <unknown> line 0 (ExitRunloop @ 0)


Okay, so that’s at least two errors that need fixing.

We’ll go in order here, even though it means tackling what is most likely the most complicated error first. (If you do think this part of the problem is too hard to tackle, please skip ahead, because the last few improvements I made really were incredibly easy to do.) Opening src/CORE.setting , we find the following definition for  round :

 1
 sub round($x, $scale=1) { floor($x / $scale + 0.5) * $scale }


Okay, so the real problem is in  floor :

 1
 sub floor($x) { Q:CgOp { (floor {$x}) } }


What the heck does  Q:CgOp  mean? It means  floor  is actually implemented in C#. So we open up  lib/Builtins.cs  and search for floor , eventually finding  public static Variable floor(Variable a1) . I won’t print the full source code here, because it is on the long side, with a case for each of the different number types. We’re only interested in the floating point case here:

 1
 2
 3
 4
 5
 6
 7
 8
 9
 10
 11
 if (r1 == NR_FLOAT) {
      double v1 = PromoteToFloat(r1, n1);
      ulong bits = (ulong)BitConverter.DoubleToInt64Bits(v1);
      BigInteger big = (bits & ((1UL << 52) - 1)) + (1UL << 52);
      int power = ((int)((bits >> 52) & 0x7FF)) - 0x433;
      // note: >>= has flooring semantics for signed values
      if ((bits & (1UL << 63)) != 0) big = -big;
      if (power > 0) big <<= power;
      else big >>= -power;
      return MakeInt(big);
 }


We don’t actually need to understand how all that works to fix this problem. The important bit is the  PromoteToFloat  line, which sets  v1 to the floating point value which is the input to our floor. If we add a trap right after that, it should fix this bug. A quick C# websearch shows me that  Double  has member functions  IsNaN , IsNegativeInfinity , and  IsPositiveInfinity . Looking a bit around the Niecza source shows there is a  MakeFloat  function for returning floating point values. Let’s try:

 1
 2
 3
 if (Double.IsNaN(v1) || Double.IsNegativeInfinity(v1) || Double.IsPositiveInfinity(v1)) {
      return MakeFloat(v1);
 }


One quick call to  make  later, I can try the test file again:

 1
 2
 3
 4
 5
 6
 7
 8
 9
 Wynne:niecza colomon$ t/fudgeandrun t/spec/S32-num/rounders.t
 1..108
 ok 1 - floor(NaN) is NaN
 ok 2 - round(NaN) is NaN
 ok 3 - ceiling(NaN) is NaN
 not ok 4 - truncate(NaN) is NaN
 # /Users/colomon/tools/niecza/t/spec/S32-num/rounders.t line 19
 #    Failed test
 #           got: -269653970229347386159395778618353710042696546841345985910145121736599013708251444699062715983611304031680170819807090036488184653221624933739271145959211186566651840137298227914453329401869141179179624428127508653257226023513694322210869665811240855745025766026879447359920868907719574457253034494436336205824


Progress! Apparently truncate uses a separate method, so we’ll have to fix it separately.

 1
 2
 sub truncate($x) { $x.Int }
 method Int() { Q:CgOp { (coerce_to_int {self}) } }


 1
 2
 3
 4
 5
 public static Variable coerce_to_int(Variable a1) {
      int small; BigInteger big;
      return GetAsInteger(a1, out small, out big) ?
          MakeInt(big) : MakeInt(small);
 }


Oooo, this is perhaps a little bit trickier. Still a basic variant on the previous method, grabbing boilerplate code from a nearby function:

 1
 2
 3
 4
 5
 6
 7
 8
 9
 10
 int r1;
 P6any o1 = a1.Fetch();
 P6any n1 = GetNumber(a1, o1, out r1);
  
 if (r1 == NR_FLOAT) {
      double v1 = PromoteToFloat(r1, n1);
      if (Double.IsNaN(v1) || Double.IsNegativeInfinity(v1) || Double.IsPositiveInfinity(v1)) {
          return MakeFloat(v1);
      }
 }


I skipped the  HandleSpecial2  bit in the boilerplate, because I’m never quite sure how that works. Luckily, we have the spectests to check and see if I have broken something by doing this.

Now the first 15 tests in  rounders.t  pass, leaving us with the

 1
 Unhandled exception: Unable to resolve method truncate in class Num


error. That should be easy to handle! If we go back to lib/CORE.setting  and search for  ceiling , we see it appears two times: in the catch-all base class  Cool  and as a stand-alone sub. If we look at the neighboring subs, we see  floor ,  ceiling ,  round , and truncate  are all defined. If we look in  Cool , however, only  floor , ceiling , and  round  defined. That’s the source of our trouble!

The method definitions of the others in  Cool  are really simple; all they do is forward to the sub versions. It’s very easy to add a  truncate that does that:

 1
 method truncate() { truncate self }


And poof! This time when we run  rounders.t , we pass all 108 tests.

At this point we’ve got three things left to do. First, now that rounders.t  passes, we need to add it to  t/spectest.data . The list of tests there is ordered, so I just find the  S32-num  section and add S32-num/rounders.t  in alphabetical order.

Next I will commit all the changes to my copy of the git repo. (I won’t explain how to do that, there are lots of git tutorials on the web.) Then I run  make spectest  to make sure I haven’t broken anything with these changes. (Hmm… actually a few TODO passing, bugs elsewhere that this patch has fixed! Oh, and one test broken, but it’s one which we were only passing by accident before, so I won’t feel bad about fudging it.)

Once that is done, you need to send the patch on to the Niecza developers; I believe the easiest way to do this is via github.

I’ve got one more little change to make that popped into my head while I was working on this. One naive way of implementing, say floor  would be to convert the input into a floating point value (a Num in Perl 6) and then do  Num.floor . That doesn’t work for all numbers, however, as most of the other number types are capable of storing numbers larger than will fit in a standing floating point double. So we probably need tests in the test suite to check for these cases. Let’s add them.

The tests in  rounders.t  are weirdly organized for my taste. But hey, we can always add our tests at the bottom.

 1
 2
 3
 4
 5
 6
 7
 {
      my $big-int = 1234567890123456789012345678903;
      is $big-int.floor, $big-int, "floor passes bigints unchanged";
      is $big-int.ceiling, $big-int, "ceiling passes bigints unchanged";
      is $big-int.round, $big-int, "round passes bigints unchanged";
      is $big-int.truncate, $big-int, "truncate passes bigints unchanged";
 }


That passes okay in Niecza. (Probably out of courtesy we should check it on Rakudo as well and fudge it appropriately to make sure we’re not breaking their spectest!) We need to remember to add the count of new tests to the plan at the top of the test file. And then we can push that fix to github as well.

In conclusion, contributing to Perl 6 is easy. Anyone who tries writing Perl 6 code and reports problems they have to  #perl6  is helping in a very real way. If you can write even fairly simple Perl 6 code, then you can write useful spec tests. It’s only marginally harder to write new methods for the setting in Perl 6. And even when you have to get down and dirty and start dealing with the language the compiler is implemented in, it’s still quite possible to do useful work without any deep understanding of how the compiler works.


Posted in  2011  |  Leave a Comment »
Lexicality and Optimizability December 8, 2011


Traditional optimizations in compilers rely on compile-time knowledge about the program. Usually statically typed langauges like Java and C are rather good at that, and dynamic languages like Perl 5, ruby and python are not.

Perl 6 offers the flexibility of dynamic languages, but tries to provide much optimizability nonetheless by  gradual typing , that is offering optional static type annotations.

But even in the presence of type annotations, another piece is needed for compile time dispatch decision and inlining: the knowledge about the available routines (and in the case of multi subs, the available candidates).

To provide that knowledge, Perl 6 installs subroutine in lexical scopes (and not packages / symbol tables, as in Perl 5), and lexical scopes are immutable at run time. (Variables inside the lexical scopes are still mutable, you just cannot add or remove entries at run time).

To provide the necessary flexibility, Perl 6 allows code to run at compile time. A typical way to run code at compile time is with the  use directive:
{
    use Test;  # imports routines into the current
               # lexical scope, at compile time
    plan 1;
    ok 1, 'success';
}
# plan() and ok() are not available here,
# outside the scope into which the routines has been imported to.

The upside is that a sufficiently smart compiler can complain before runtime about missing routines and dispatches that are bound to fail. Current Rakudo does that, though there are a certainly cases that rakudo does not detect yet, but which are possible to detect.
sub f(Int $x) {
          say $x * 2;
           }
say "got here";
f('some string');

produces this output with current Rakudo:
===SORRY!===
CHECK FAILED:
Calling 'f' will never work with argument types (str) (line 5)
     Expected: :(Int $x)

Since built-in routines are provided in an outer scope to the user’s program, all built-in routines are automatically subjected to all the same rules and optimizations as user-provided routines.

Note that this has other implications:  require , which loads modules at run time, now needs a list of symbols to stub in at compile time, which are later wired up to the symbols loaded from the module.

The days are past where "a sufficiently smart compiler" was a legend; these days we have a compiler that can provide measurable speed-ups. There is still room for improvements, but we are now seeing the benefits from static knowledge and lexical scoping.


Posted in  2011  |  Leave a Comment »
Adventures in writing a simple grammar profiler December 7, 2011


Inspired by jnthn’s earlier post on  Grammar::Debugger , I wondered how hard it would be to implement a simple Perl 6 grammar profiler.  Turns out it wasn’t that hard at all.

As far as profiling goes, all I wanted was counts of how many times each rule was executed and the cumulative time each rule took to execute.    The interface I had in mind was something simple–a multi-level hash with names of grammars at the first level then, at the second level, names of the individual rules within the grammar, and finally the actual timing information.  The timing information would be accessed thusly:
say "MyGrammar::MyRule was called " ~ %timing<MyGrammar><MyRule><calls> ~ "times";
say "and took " ~ %timing<MyGrammar><MyRule><time> ~ " seconds to execute";

But first I had to figure out what jnthn’s code was doing.

From the outside looking in, the basic technique is to replace the normal grammar meta-object with a custom meta-object that inherits most of the behavior of the normal grammar meta-object but replaces the normal method lookup with a custom one that returns a routine that collects the timing information while calling the original method.

Looking at  jnthn’s code , I see that if the method name starts with  !  or is any one of “parse”, “CREATE”, “Bool”, “defined” or “MATCH”, we just return the original method without modification. This is so that we don’t trace private methods or accidentally trace methods that aren’t directly part of the grammar but are used by it. In my simple profiler, I need to get the name of the grammar, which I do by calling  my $grammar = $obj.WHAT.perl . So it looks like I need to add “perl” to that list of methods to pass through unscathed. Otherwise, I get an infinite recursion.

Anyway, for those method names that don’t match the aforementioned criteria, we return a custom built routine that accumulates the execution time and increments a counter for the number of calls. Seems straight-forward enough … below is the code (somewhat untested):
my %timing;
 
my class ProfiledGrammarHOW is Metamodel::GrammarHOW is Mu {
 
    method find_method($obj, $name) {
        my $meth := callsame;
        substr($name, 0, 1) eq '!' || $name eq any(<parse CREATE Bool defined MATCH perl>) ??
            $meth !!
            -> $c, |$args {
                my $grammar = $obj.WHAT.perl;
                %timing{$grammar} //= {};                   # Vivify grammar hash
                %timing{$grammar}{$meth.name} //= {};       # Vivify method hash
                my %t := %timing{$grammar}{$meth.name};
                my $start = now;                            # get start time
                my $result := $meth($obj, |$args);          # Call original method
                %t<time> += now - $start;             # accumulate execution time
                %t<calls>++;
                $result
            }
    }
 
    method publish_method_cache($obj) {
        # no caching, so we always hit find_method
    }
}
 
sub get-timing is export { %timing }
sub reset-timing is export { %timing = {} }
 
my module EXPORTHOW { }
EXPORTHOW.WHO.<grammar> = ProfiledGrammarHOW;

Assuming the above code was saved in file called “GrammarProfiler.pm”, you’d use it by adding the line  use GrammarProfiler;  to the top of any program that makes grammar declarations. Then after you parse your grammar, you can call  get-timing()  to obtain the hash that has the timing information for the individual rules that were executed during the parse or  reset-timing()  to clear the timing information.

Of course, a more full-fledged profiler would do much more work and provide many more profiling options, but this isn’t bad for a quick hack and it just might be useful too.


Posted in  2011  |  Leave a Comment »
Tetris on Niecza December 5, 2011


Niecza , the Other Perl 6 Implementation on Mono and .NET, recently gained the ability to call almost any Common Language Runtime library. In Niecza’s examples directory, a simple 30 line script called gtk1.pl shows how to use gtk-sharp, and thus Gtk and Gdk, the graphical basis of Gnome. Here is gtk1′s central working part:

 1
 2
 3
 4
 5
 6
 my $btn = Button.new("Hello World");
 $btn.add_Clicked: sub ($obj, $args) { #OK
      # runs when the button is clicked.
      say "Hello World";
      Application.Quit;
 };


The  add_Clicked  method defines a  callback routine , essential to process user input. Running gtk1.pl makes the following resizeable button in a window, and it closes when clicked:



From gtk1 to Tetris is not far, see the  source  also in niecza/examples. Two extra ingredients make it possible: a timer tick callback routine to animate the falling pieces, and non blocking keyboard input to give the user the illusion of control. Add some simple physics and Cairo graphics and you have a playable game (modulo scoring and similar low hanging fruit) in under 170 lines of Perl 6.

Animation by timer tick works by causing the whole window to be redrawn by an  ExposeEvent  at regular intervals. The redraw tries to move the falling piece downwards, and if the physics says no, it adds a new piece at the top instead. (Bug: that should eventually fail with a full pile of pieces.)  GLibTimeout  sets up the timer callback handler which invokes  .QueueDraw . The default interval is 300 milliseconds, and if the game engine wants to speed that up, it can adjust $newInterval which will replace the GLibTimeout on the next tick (sorry about the line wrap):

 1
 2
 3
 4
 5
 6
 7
 8
 9
 10
 11
 12
 my $oldInterval = 300;
 my $newInterval = 300;
 ...
 GLibTimeout.Add($newInterval, &TimeoutEvent);
 ...
 sub TimeoutEvent()
 {
      $drawingarea.QueueDraw;
      my $intervalSame = ($newInterval == $oldInterval);
      unless $intervalSame { GLibTimeout.Add($newInterval, &TimeoutEvent); }
      return $intervalSame; # True means continue calling this timeout handler
 }


Thanks to the excellent way Gtk handles typing, the keystroke event handler is fairly self documenting. The Piece subroutines do the physics ($colorindex 4 is the square block that does not rotate):

 1
 2
 3
 4
 5
 6
 7
 8
 9
 10
 11
 12
 $drawingarea.add_KeyPressEvent(&KeyPressEvent);
 ...
 sub KeyPressEvent($sender, $eventargs) #OK not used
 {
      given $eventargs.Event.Key {
          when 'Up' { if $colorindex != 4 { TryRotatePiece() } }
          when 'Down' { while CanMovePiece(0,1) {++$pieceY;} }
          when 'Left' { if CanMovePiece(-1,0) {--$pieceX;} }
          when 'Right' { if CanMovePiece( 1,0) {++$pieceX;} }
      }
      return True; # means this keypress is now handled
 }


With a bit more glue added, here is the result:



This post has glossed over other details such as the drawing of the graphics, because a later Perl 6 Advent post will cover that, even showing off some beautiful fractals, so keep following this blog! The above software was  presented  at the  London Perl Workshop 2011 .

来源： < http://perl6advent.wordpress.com/2011/12/page/2/ >  