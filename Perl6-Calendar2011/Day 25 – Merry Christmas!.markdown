Day 25 – Merry Christmas! December 25, 2011


The kind elves who spend the rest of the year working in Santa’s shop to bring you more of Perl 6 each year would like to wish you a very warm and fuzzy Christmas vacation. December is always a special time for us, because we get to interact with you all through the interface of the advent calendar. We think that’s wonderful.

Be sure to check out this year’s  Perl 6 coding contest , where you can win €100 worth of books!

Merry Christmas!


Posted in  2011  |  1 Comment »
Day 24 — Subs are Always Better in multi-ples December 24, 2011


Hey look, it’s Christmas Eve! (Also, the palindrome of 42!) And today, we’re going to learn about  multi  subs, which are essentially synonyms (like any natural language would have). Let’s get started! An Informative Introduction

multi  subs are simply subroutines (or anything related to it, such as methods, macros, etc.) that start with the  multi  keyword and are then allowed to have the same name as another sub before, provided that sub starts with a  multi  (or  proto  — that’s later) keyword. What has to be different between these subs is their signature, or list of formal parameters.

Sound complicated? It isn’t, just take a look at the example below:

 1
 2
 3
 4
 5
 6
 7
 multi sub steve(Str $name) {
      return "Hello, $name";
 }
  
 multi sub steve(Int $number) {
      return "You are person number $number to use this sub!";
 }


Every sub was started with the  multi  keyword, and has the same name of “steve”, but its parameters are different. That’s how Perl 6 knows which steve to use. If I were to later type  steve("John") , then the first steve gets called. If, however, I were to type steve(35) , then I’d get the second steve sub. Equal Footing with built-ins

When you write a  multi sub , and it happens to have the same name as some other built-in, your sub is on equal footing with the compiler’s. There’s no preferring Perl 6′s  multi sub  over yours, so if you write a multi sub  with the same name as a built-in and with the same signature, say

 1
 2
 3
 multi sub slurp($filename) {
      say "Yum! $filename was tasty. Got another one?";
 }


And then try calling it with something like  slurp("/etc/passwd") , I get this:

 1
 2
 3
 Ambiguous dispatch to multi 'slurp'. Ambiguous candidates had signatures:
 :(Any $filename)
 :(Any $filename)


Why? Because Perl 6 found two equally valid choices for slurp("/etc/passwd") , my sub and its own, and was unable to decide. That’s the easiest way I know to demonstrate equal footing. A Fun Conclusion

Now, since it’s Christmas, let’s try writing another  open  sub, but unlike the built-in  open  sub, which opens files, this one open presents! Here’s our Present class for this example:

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
 13
 14
 15
 16
 17
 class Present {
      has $.item;
      has $.iswrapped = True;
  
      method look() {
          if $.iswrapped {
              say "It's wrapped.";
          }
          else {
              say $.item;
          }
      }
  
      method unwrap() {
          $!iswrapped = False;
      }
 }


Now, our open  multi sub  looks like this:

 1
 2
 3
 4
 multi sub open(Present $present) {
      $present.unwrap;
      say "You unwrap the present and find...!";
 }


The signature is vastly different from Perl 6′s own open sub, which is a good thing. And here’s the rest of the code, which makes a Present and uses our new  multi sub :

 1
 2
 3
 4
 my $gift = Present.new(:item("sock"));
 $gift.look;
 open($gift);
 $gift.look;
But wait!

Running this gets us an error in the latest pull of Rakudo:

 1
 2
 3
 4
 $ ./perl6 present.p6
 It's wrapped.
 This type cannot unbox to a native string
 ⋮


This means that Perl 6′s original open sub is being used, so perhaps it’s being interpreted as an  only  sub ( only  subs are the default — only sub unique() {...}  and  sub unique() {...}  mean the same thing). No matter, let’s try adding a  proto sub  line before our multi sub:

 1
 proto sub open(|$) {*}


A  proto sub  allows you to specify the commonalities between multi subs of the same name. In this case,  |$  means “every possible argument”, and  {*}  means “any kind of code”. It also turns any sub with that name into a  multi  sub (unless explicitly defined as something other than  multi ). This is useful if you’re, say, importing a &color  sub from a module that isn’t defined as  multi  (or explicitly as only ) and you want to have your own  &color  sub as well.

After adding this before our  multi sub open , we get this result:

 1
 2
 3
 4
 $ ./perl6 present.p6
 It's wrapped.
 You unwrap the present and find...!
 sock


It works! Well, that’s it for  multi  subs. For all the nitty-gritty details, see the most current  S06 . Enjoy your multi subs and your Christmas Eve!


Tags: multi subs ,  perl6
Posted in  2011  |  1 Comment »



Tags: idiom idiomatic
Posted in  2011  |  2 Comments »
Day 22 – Operator overloading, revisited December 22, 2011


Today’s post is a follow-up. Exactly two years ago, Matthew Walton wrote on this blog about  overloading operators :

You can exercise further control over the operator’s parsing by adding traits to the definition, such as  tighter ,  equiv  and  looser , which let you specify the operator’s precedence in relationship to operators which have already been defined. Unfortunately, at the time of writing this is not supported in Rakudo so we will not consider it further today.

Rakudo is still lagging in precedence support (though at this point there are no blockers that I know about to simply going ahead and implementing it). But there’s a new implementation on the block, one that didn’t exist two years ago: Niecza.

Let’s try out operator precedence in Niecza.
$ niecza -e 'sub infix:<mean>($a, $b) { ($a + $b) / 2 }; say 10 mean 4 * 5'
15

Per default, an operator gets the same precedence as  infix<+> . This is per spec. (How do we know it got the same precedence as infix<+>  above? Well, we know it’s not tighter than multiplication, otherwise we’d have gotten the result 35.)

That’s all well and good, but what if we want to make our mean little operator evaluate tighter than multiplication? Nothing could be simpler:
$ niecza -e 'sub infix:<mean>($a, $b) is tighter(&infix:<*>) { ($a + $b) / 2 }; say 10 mean 4 * 5'
35

See what we did there?  is tighter  is a  trait  that we apply to the operator definition. The trait accepts an argument, in this case the language-provided multiplication operator. It all reads quite well, too: “infix mean is tighter [than] infix multiplication”.

Note the explicit use of intuitive naming for the precedence levels. Rather than the inherently confusing terms “higher/lower”, Perl 6 talks about “tighter/looser”, as in “multiplication binds tighter than addition”. Easier to think about precedence that way.

Internally, the precedence levels are stored not as numbers but as strings. Each original precedence level gets a letter of the alphabet and an equals sign ( = ). Subsequent added precendence levels append either a less-than sign ( < ) or a greater-than sign ( > ) to an existing precedence level representation. Using this system, we never “run out” of levels between existing ones (as we could if we were using integers, for example), and tighter levels always come lexigographically before looser ones. Language designers, take heed.

A few last passing notes about operators in Perl 6, while we’re on the subject:
In Perl 6,  operators are subroutines . They just happen to have funny names, like prefix:<-> or postfix:<++> or infix:<?? !!>. This actually takes a lot of the hand-wavey magic out of defining them. The traits that we’ve seen applied to operators are really subroutine traits… these just happen to be relevant to operator definitions.
As a consequence, just like subroutines,  operators are lexically scoped  by default. Lexical scoping is something we like in Perl 6; it keeps popping up in unexpected places as a solid, sound design principle in the language. In practice, this means that if you declare an operator within a given scope, the operator will be visible and usable within that scope. You’re modifying the parser, but you’re doing it locally, within some block or other. (Or within the whole file, of course.)
Likewise, if you want to  export your operators , you just use the same exporting mechanism used with subroutines. See how this unification between operators and subroutines keeps making sense? (In Perl 6-land, we say “operators are just funny-looking subroutines”.)
Multiple dispatch in operators  works just as with ordinary subroutines. Great if you want to dispatch your operators on different types. As with all other routines in the core library in Perl 6, all operators are declared multi to be able to co-exist peacefully with module extensions to the language.
Operators can be macros , too. This is not an exceptions to the rule that operators are subroutines, because in Perl 6, macros are subroutines. In other words, if you want some syntactic sugar to execute at parse time (which is what a macro does), you can dress it up either as a normal-looking sub, or as an operator.


That’s it for today. Now, go forth and multiply, or even define your own operator that’s either tighter or looser than multiplication.


Posted in  2011  |  Leave a Comment »
Native libraries, native objects December 21, 2011


Last year flussence++ wrote a nice post about writing XMMS bindings for Perl 6 using the Native Call Interface. It has improved a bit since then, (at least NCI, I don’t know about XMMS), so let’s show it off a bit.

To run the examples below you need a  NativeCall  module installed. Then add  use NativeCall;  at the top of the file.

Previously, we were carefully writing all the C subs we needed to use and then usually writing some Perl 6 class which wrapped it in a nice, familiar interface. That doesn’t change much, except that now a class is not really an interface for some C-level data structure. Thanks to the new metamodel we can now make our class to actually  be  a C-level data structure, at least under the hood. Consider a class representing a connection to Music Player Daemon:
    class Connection is repr('CPointer') {
        sub mpd_connection_new(Str $host, Int $port)
            returns Connection
            is native('libmpdclient.so') {}
        sub mpd_connection_free()
            is native('libmpdclient.so') {}
        method new(Str $host, Int $port) {
            self.bless(mpd_connection_new($host, $port))
        }
        method DESTROY {
            mpd_connection_free(self)
        }
    }

The first line does not necesarilly look familiar. The  is repr  trait tells the compiler that the internal representation of the class  Connection is a C pointer. It still is a fully functional Perl 6 type, which we can use in method signatures or wherever (as seen in the lines below).

We then declare some native fuctions we’re going to use. It’s quite convenient to put them inside the class body, so they don’t pollute the namespace and don’t confuse the user. What we are really exposing here is the  new  method, which uses  bless  to set the object’s internal representation to what  mpd_connection_new  has returned. From now on our object is a Perl 6 level object, while under the hood being a mere C pointer. In method  DESTROY  we just pass  self  to another native function,  mpd_connection_free , without the need to unbox it or whatever. The  NativeCall  module will just extract its internal representation and pass it around. Ain’t that neat?

Let’s see some bigger example. We’ll use  taglib  library to extract the metadata about some music files lying around. Let’s see the  Tag  class first:
    class Tag is repr('CPointer') {
        sub taglib_tag_title(Tag)  returns Str is native('libtag_c.so') {}
        sub taglib_tag_artist(Tag) returns Str is native('libtag_c.so') {}
        sub taglib_tag_album(Tag)  returns Str is native('libtag_c.so') {}
        sub taglib_tag_genre(Tag)  returns Str is native('libtag_c.so') {}
        sub taglib_tag_year(Tag)   returns Int is native('libtag_c.so') {}
        sub taglib_tag_track(Tag)  returns Int is native('libtag_c.so') {}
        sub taglib_tag_free_strings(Tag)       is native('libtag_c.so') {}
 
        method title  { taglib_tag_title(self)  }
        method artist { taglib_tag_artist(self) }
        method album  { taglib_tag_album(self)  }
        method genre  { taglib_tag_genre(self)  }
        method year   { taglib_tag_year(self)   }
        method track  { taglib_tag_track(self)  }
 
        method free   { taglib_tag_free_strings(self) }
    }

That one is pretty boring: plenty of native functions, and plenty of methods being exactly the same things. You may have noticed the lack of  new : how are we going to get an object and read our precious tags? In  taglib , the actual  Tag  object is obtained from a Tag_File  object first. Why didn’t we implement it first? Well, it’s going to have a method returning the  Tag  object shown above, so it was convenient to declare it first.
    class TagFile is repr('CPointer') {
        sub taglib_file_new(Str) returns TagFile is native('libtag_c.so') {}
        sub taglib_file_free(TagFile)            is native('libtag_c.so') {}
        sub taglib_file_tag(TagFile) returns Tag is native('libtag_c.so') {}
        sub taglib_file_is_valid(TagFile) returns Int
            is native('libtag_c.so') {}
 
        method new(Str $filename) {
            unless $filename.IO.e {
                die "File '$filename' not found"
            }
            my $self = self.bless(taglib_file_new($filename));
            unless taglib_file_is_valid($self) {
                taglib_file_free(self);
                die "'$filename' is invalid"
            }
            return $self;
        }
 
        method tag  { taglib_file_tag(self)  }
 
        method free { taglib_file_free(self) }
    }

Note how we use native functions in  new  to check for exceptional situations and react in an appropriately Perl 6 way. Now we only have to write a simple MAIN before we can test it on our favourite music files.
    sub MAIN($filename) {
        my $file = TagFile.new($filename);
        my $tag  = $file.tag;
        say 'Artist: ', $tag.artist;
        say 'Title:  ', $tag.title;
        say 'Album:  ', $tag.album;
        say 'Year:   ', $tag.year;
 
        $tag.free;
        $file.free;
    }

Live demo! Everyone loves live demos.
    $ perl6 taginfo.pl some-track.mp3
    Artist: Diablo Swing Orchestra
    Title:  Balrog Boogie
    Album:  The Butcher's Ballroom
    Year:   2009

Works like a charm. I promise I’ll wrap it up in some nice Audio::Tag  module and release it on Github shortly.

Of course there’s more to do with NativeCall than just passing raw pointers around. You could, for example, declare it as a  repr('CStruct')  and access the  struct  field directly, as you would in good, old C. This is only partly implemented as for now though, but that shouldn’t stop you from experimenting and seeing what you can do before Christmas. Happy hacking!


Posted in  2011  |  4 Comments »



Posted in  2011  |  3 Comments »
Day 19 – Abstraction and why it’s good December 19, 2011


Some people are a bit afraid of the word “abstract”, because they’ve heard math teachers say it, and also, abstract art freaks them out. But abstraction is a fine and useful thing, and not so complicated. As programmers, we use it every day in different forms. The term is from Latin and means “to withdraw from” or “to pull away from”, and what we’re pulling away from is the specifics so we can focus on the big picture. That’s often mighty useful.

Here are a few examples: Variables

If your computer only knew how to handle one specific number at a time, it’d be an abacus. Pretty early on, the programmer guild figured out it made a lot of sense to talk about the memory address of a value, and let that address contain whatever it pleased. They abstracted away from the value, and thus made the program more general.

As time passed, addresses were replaced by names, mostly as a convenience. Some people found it a good idea to give their variables descriptive names, as opposed to things like  $grbldf . Subroutines

Code re-use. We hear so much about it in the OO circles, but it holds equally well for subroutines. You write your code once, and then call it from all over the place. Convenient.

But, as I point out in  an announcement pretending to be a computer science professor from an alternate timeline , there’s also the secondary benefit of giving your chunk of code a good mnemonic name, because that act in a sense improves the programming language itself. You’re giving yourself new verbs to program with.

This is especially true in Perl 6, because subroutines are lexically scoped (as opposed to Perl 5) and thus you can easily put a subroutine inside another routine. I use it when writing  a Connect 4 game , for example. Packages and modules

In Perl, packages don’t do much. They pull things together and keep them there. In a sense, what they abstract away is a set of subroutines from the rest of the world.

Perl 5 delivers its whole OO functionality through packages and a bit of dispatch magic on the side. It’s quite a feat, actually, but sometimes a bit  too  minimal. Moose fixes many of those early issues by providing a full-featured object system. Perl 6 lets packages go back to just being collections of subroutines, but provides a few dedicated abstractions for OO, a kind of built-in Moose. Which brings us to… Classes

Object-orientation means a lot of different things to different people. To some, it’s the notion of an  object , a piece of memory with a given set of operations and a given set of states. In a sense, we’re again in the business of extending the language like with did with subroutines. But this time we’re building new  nouns  rather than new verbs. One moment the language doesn’t know about a  Customer  object type; the next, it does.

To others, object-orientation means keeping the operations public and the states private. They refer to this division as  encapsulation , because the object is like a little capsule, protecting your data from the big bad world. This is also a kind of abstraction, built on the idea that the rest of the world shouldn’t  need  to care about the internals of your objects, because some day you may want to refactor them. Don’t talk to the brain, talk to the hand; do your thing through the published operations of the object. Roles

But class-based OO with inheritance will take you only so far. In the past 10 years or so, people have become increasingly aware of the limitations of inheritance-based class hierarchies. Often there are concerns which cut completely across a conventional inheritance hierarchy.

This is where  roles  come in; they allow you to apply behaviors in little cute packages here and there, without being tied up by a tree-like structure. In  a post about roles  I explore how this helps write better programs. But really the best example nowadays is probably the Rakudo compiler and its extensive use of roles; jnthn has been writing about that in an earlier advent post.

If classes abstract away complete sets of behaviors, roles abstract away partial sets of behaviors, or  responsibilities .

You can even do so at runtime, using  mixins , which are roles that you add to an object as the program executes. Objects changing type during runtime sounds magic almost to the point of recklessness; but it’s all done in a very straightforward manner using anonymous subclasses. Metaobjects

Sometimes you want extra control over how the object system itself works. The object system in Perl 6, through one of those neat bite-your-own-tail tricks, is written using itself, and is completely modifiable in terms of itself. Basically, a bunch of the complexity has been removed by not having a separate hidden, unreachable system to handle the intricacies of the object system. Instead, there’s a visible API for interacting with the object system.

And, when we feel like it, we can invent new and exotic varieties of object systems. Or just tweak the existing one to our fancy. Macros

On the way up the abstraction ladder, we’ve abstracted away bigger and bigger chunks of code: values, code, routines, behaviors, responsibilities and object systems. Now we reach the top, and there we find  macros . Ah, macros, these magical, inscrutable beasts. What do macros abstract away?

Code.

Well, that’s rather disappointing, isn’t it? Didn’t we already abstract away code with subroutines? Yes, we did. But it turns out there’s so much code in a program that sometimes, it needs to be abstracted away on several levels!

Subroutines abstract away code that can then run in several different ways. You call the routine with other values, and it behaves differently. Macros abstract away code that can then be compiled in several different ways. You write a macro with other values, and it gets compiled into different code, which can then in turn run differently.

Essentially, macros give you a hook into the compiler to help you shape and guide what code it emits during the compilation itself. In a sense, you’re abstracting certain parts of the compilation process, the parsing and the syntax manipulation and the code generation. Again, you’re shaping the language — but this time not inventing new nouns or verbs, but whole ways of expressing yourself.

Macros come in two broad types:  textual  (a la C) and  syntax tree  (a la Lisp). The textual ones have a number of known issues stemming from the fact that they’re essentially a big imprecise search-and-replace on your code. The syntax tree ones are hailed as the best thing about Lisp, because it allows Lisp programs to grow and adapt to the needs of the programmer, by inventing new ways of expressing yourself.

Perl 6, being Perl 6, specifies both textual macros and syntax tree macros. I’m currently working on a grant to bring syntax macros to Rakudo Perl 6. There’s  a branch  where I’m hammering out the syntax and semantics of macros. It’s fun work, and made much more feasible by the past year’s improvements to Rakudo itself. In conclusion

As an application grows and becomes more complex, it needs more rungs of the abstraction ladder to rest on. It needs more levels of abstraction with which to draw away the specifics and focus on the generalities.

Perl 6 is a new Perl, distinct from Perl 5. Its most distinguishing trait is perhaps that it has more rungs on the abstraction ladder to help you write code that’s more to the point. I like that.


Posted in  2011  |  Leave a Comment »
The view from the inside: using meta-programming to implement Rakudo December 18, 2011


In  my previous article  for the Perl 6 advent calendar, I looked at how we can use the meta-programming facilities of Rakudo Perl 6 in order to build a range of tools, tweak the object system to our liking or even add major new features “from the outside”. While it’s nice that you can do these things, the Perl 6 object system that you get by default is already very rich and powerful, supporting a wide range of features. Amongst them are:
Classes
Parametric roles
Attributes
Methods (including private ones)
Delegation
Introspection
Subset (aka. refinement) types
Enums


That’s a lot of stuff to implement, but it’s all done by implementing meta-objects, and therefore we can take advantage of OOP – with both classes and roles – to factor it. The only real difference between the meta-programming we saw in my last article and the meta-programming we do while implementing the core Perl 6 object system in Rakudo is that the meta-objects are mostly written in NQP. NQP is a vastly smaller, much more easily optimizable and portable subset of Perl 6. Being able to use it also helps us to avoid many painful bootstrapping issues. Since it is mostly a small subset of Perl 6, it’s relatively easy to get in to.

In this article, I want to take you inside of Rakudo and, through implementing a missing feature, give you a taste of what it’s like to hack on the core language. So, what are we going to implement? Well, one feature of roles is that they can also serve as interfaces. That is, if you write:
role Describable {
    method describe() { ... }
}
class Page does Describable {
}

Then we are meant to get a compile time error, since the class Page does not implement the method “describe”. At the moment, however, there is no error at compile time; we don’t get any kind of failure until we call the describe method at runtime. So, let’s make this work!

One key thing we’re going to need to know is whether a method is just a stub, with a body containing just “…”, “???” or “!!!”. This is available to us by checking its .yada method. So, we have that bit. Question is, where to check it?

Unlike classes, which have the meta-object ClassHOW by default, there  isn’t a single RoleHOW. In fact, roles show up in no less than four different forms. The two most worth knowing about are ParametricRoleHOW and ConcreteRoleHOW. Every role is born parametric. Whether you explicitly give it extra parameters or not, it is always parametric on at least the type of the invocant. Before we can ever use a role, it has to be composed into a class. Along the way, we have to specialize it, taking all the parametric things and replacing them with concrete ones. The outcome of this is a role type with a meta-object of type ConcreteRoleHOW, which is now ready for composition into the class.

So that’s roles themselves, but what about composing them? Well, the actual composition is performed by two classes, RoleToClassApplier and RoleToRoleApplier. RoleToClassApplier is actually only capable of applying a single role to a class. This may seem a little odd: classes can do multiple roles, after all. However, it turns out that a neat way to factor this is to always “sum” multiple roles to a single one, and then apply that to the class. Anyway, it would seem that we need to be doing some kind of check in RoleToClassApplier. Looking through, we see this:
my @methods := $to_compose_meta.methods($to_compose, :local(1));
for @methods {
    my $name;
    try { $name := $_.name }
    unless $name { $name := ~$_ }
    unless has_method($target, $name, 1) {
        $target.HOW.add_method($target, $name, $_);
    }
}

OK, so, it’s having a bit of “fun” with, of all things, looking up the name of the method. Actually it’s trying to cope with NQP and Rakudo methods having slightly different ideas about how the name of a method is looked up. But that aside, it’s really just a loop going over the methods in a role and adding them to the class. Seems like a relatively opportune time to spot the yada case, which indicates we require a method rather than want to compose one into the class. So, we change it do this:
my @methods := $to_compose_meta.methods($to_compose, :local(1));
for @methods {
    my $name;
    my $yada := 0;
    try { $name := $_.name }
    unless $name { $name := ~$_ }
    try { $yada := $_.yada }
    if $yada {
        unless has_method($target, $name, 0) {
            pir::die("Method '$name' must be implemented by " ~
            $target.HOW.name($target) ~
            " because it is required by a role");
        }
    }
    elsif !has_method($target, $name, 1) {
        $target.HOW.add_method($target, $name, $_);
    }
}

A couple of notes. The first is that we’re doing binding, because NQP does not have assignment. Binding is easier to analyze and generate code for. Also, the has_method call is passing an argument of 0 or 1, which indicates whether we want to consider methods in just the target class or any of its parents (note that there’s no True/False in NQP). If the class inherits a method then we’ll consider that as good enough: it has it.

So, now we run our program and we get:
===SORRY!===
Method 'describe' must be implemented by Page because it is required by a role

Which is what we were after. Note that the “SORRY!” indicates it is a compile time error. Success!

So, are we done? Not so fast! First, let’s check the inherited method case works out. Here’s an example.
role Describable {
    method describe() { ... }
}
class SiteItem {
    method describe() { say "It's a thingy" }
}
class Page is SiteItem does Describable {
}

And…oh dear. It gives an error. Fail. So, back to RoleToClassApplier. And…aha.
sub has_method($target, $name, $local) {
    my %mt := $target.HOW.method_table($target);
    return nqp::existskey(%mt, $name)
}

Yup. It’s ignoring the $local argument. Seems it was written with the later need to do a required methods check in mind, but never implemented to handle it. OK, that’s an easy fix – we just need to go walking the MRO (that is, the transitive list of parents in dispatch order).
sub has_method($target, $name, $local) {
    if $local {
        my %mt := $target.HOW.method_table($target);
        return nqp::existskey(%mt, $name);
    }
    else {
        for $target.HOW.mro($target) {
            my %mt := $_.HOW.method_table($_);
            if nqp::existskey(%mt, $name) {
                return 1;
            }
        }
        return 0;
    }
}

With that fixed, we’re in better shape. However, you may be able to imagine another case that we didn’t yet handle. What if another role provides the method? Well, first let’s see what the current failure mode is. Here’s the code.
role Describable {
    method describe() { ... }
}
role DefaultStuff {
    method describe() { say "It's a thingy" }
}
class Page does Describable does DefaultStuff {
}

And here’s the failure.
===SORRY!===
Method 'describe' must be resolved by class Page because it exists
in multiple roles (DefaultStuff, Describable)

So, it’s actually considering this as a collision. So where do collisions actually get added? Happily, that just happens in one place: in RoleToRoleApplier. Here’s the code in question.
if +@add_meths == 1 {
    $target.HOW.add_method($target, $name, @add_meths[0]);
}
else {
    # More than one - add to collisions list.
    $target.HOW.add_collision($target, $name, %meth_providers{$name});
}

We needn’t worry if we just have one method and it’s a requirement rather than an actual implementation – it’ll just do the right thing. So it’s just the second branch that needs consideration. Here’s how we change things.
if +@add_meths == 1 {
    $target.HOW.add_method($target, $name, @add_meths[0]);
}
else {
    # Find if any of the methods are actually requirements, not
    # implementations.
    my @impl_meths;
    for @add_meths {
        my $yada := 0;
        try { $yada := $_.yada; }
        unless $yada {
            @impl_meths.push($_);
        }
    }
 
    # If there's still more than one possible - add to collisions list.
    # If we got down to just one, add it. If they were all requirements,
    # just choose one.
    if +@impl_meths == 1 {
        $target.HOW.add_method($target, $name, @impl_meths[0]);
    }
    elsif +@impl_meths == 0 {
        $target.HOW.add_method($target, $name, @add_meths[0]);
    }
    else {
        $target.HOW.add_collision($target, $name, %meth_providers{$name});
    }
}

Essentially, we filter out those that are implementations of the method rather than just requirements. If we are left with just a single method, then it’s the only implementation, and it satisfies the requirements, so we add it and we don’t need to do anything further. If we discover they are all requirements, then we don’t want to flag up a collision, but instead we just pick any of the required methods and pass it along. They’ll all give the same error. Otherwise, if we have multiple implementations, then it’s a real collision so we add it just as before. And…it works!

So, we run the test suite, things look good…and commit.
3 files changed, 48 insertions(+), 6 deletions(-)

And there we go – Rakudo now supports a part of the spec that it never has before, and it wasn’t terribly much effort to put in. And that just leaves me to go to the fridge and grab a Christmas ale to relax after a little meta-hacking. Cheers!


Posted in  2011  |  1 Comment »
Day 17: Gtk Mandelbrot December 17, 2011


Two years ago today, the Advent post was on  making Mandelbrot sets in Perl 6. At the time, they were in black and white, slow to produce, Rakudo was prone to crashing, and the only user interface thing you could control was how big the resulting PPM file was.

As they say, that was then.  This is now.



The new  gtk-mandelbrot.pl  script is 423 lines of Perl 6 code — targeted at Niecza, threaded, and using the GtkSharp library. It allows you to move and resize the windows, zoom in (left mouse button, drag across image to define zoom boundaries), create Julia set images (right click on a Mandelbrot set image), increase the number of iterations (press ‘m’), and output a PPM file for a window (press ‘s’).

The threading doesn’t actually improve performance on my MacBook Pro (still looking into why) but it does make the script much more responsive.

It would be far too long to go through all the code, but lets hit on the highlights. The core is almost unchanged:

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
 sub julia(Complex $c, Complex $z0) {
      my $z = $z0;
      my $i;
      loop ($i = 0; $i < $max_iterations; $i++) {
          if $z.abs > 2 {
              return $i + 1;
          }
          $z = $z * $z + $c;
      }
      return 0;
 }


It’s named  julia  instead of  mandel  now, because it is more general. If you call it with  $z0  set to  0 , it calculates the same thing the old mandel  did. Allowing  $z0  to vary allows you to calculate Julia sets as well.

The code around it is very different, though! Stefan O’Rear wrote the threading code, using Niecza’s Threads library, which is a thin wrapper on C#’s threading libraries, and probably not very close to what Perl 6′s built-in threading will look like when it is ready to go. He establishes a  WorkQueue  with a list of the work that needs to be done, and then starts N running threads, where N comes from the environment variable THREADS if it is present, and the reported processor count otherwise:

 1
 2
 3
 for ^(%*ENV<THREADS> // CLR::System::Environment.ProcessorCount) {
      Thread.new({ WorkQueue.run });
 }


WorkQueue.run  is pretty simple:

 1
 2
 3
 4
 5
 6
 7
 8
 method run() {
      loop {
          my $item = self.shift;
          next if $item.cancelled;
          $item.run.();
          $item.mark-done;
      }
 }


This is an infinite loop that starts by getting the next  WorkItem  off the queue, checks to see if it has been cancelled, and if it hasn’t, calls the .run  Callable  attribute and then the  mark-done  method.

The  WorkItem s on the queue look like this:

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
 13
 14
 15
 class WorkItem {
      has Bool $!done = False;
      has Bool $!cancelled = False;
  
      has Callable &.run;
      has Callable &.done-cb;
  
      method is-done() { WorkQueue.monitor.lock({ $!done }) }
      method mark-done() {
          &.done-cb.() unless WorkQueue.monitor.lock({ $!done++ })
      }
  
      method cancelled() { WorkQueue.monitor.lock({ $!cancelled }) }
      method cancel() { WorkQueue.monitor.lock({ $!cancelled = True }) }
 }


Each  WorkItem  has two flags,  $!done  and  $!cancelled , and two Callable  attributes,  &.run , already mentioned as what is called by WorkQueue.run , and  &.done-cb , which is the callback function to be called when the  &.run  method finishes.

The two methods (for now) we use in our WorkItem are relatively simple:

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
 13
 14
 15
 16
 17
 18
 19
 20
 21
 22
 23
 24
 sub row() {
      my $row = @rows[$y];
      my $counter = 0;
      my $counter_end = $counter + 3 * $width;
      my $c = $ur - $y * $delta * i;
  
      while $counter < $counter_end {
          my $value = $is-julia ?? julia($julia-z0, $c) !! julia($c, 0i);
          $row.Set($counter++, @red[$value % 72]);
          $row.Set($counter++, @green[$value % 72]);
          $row.Set($counter++, @blue[$value % 72]);
          $c += $delta;
      }
 }
  
 sub done() {
      Application.Invoke(-> $ , $ {
          $.draw-area.QueueDrawArea(0, $y, $width, 1);
      });
 }
  
 my $wi = WorkItem.new(run => &row, done-cb => &done);
 WorkQueue.push($wi);
 push @.line-work-items, $wi;


As you might expect,  row  calculates one line of the set we are working on. It may look like it is using global variables, but these subs are actually local to the  FractalSet.start-work  method and the variables are local to it from there. The  done  invokes a Gtk function noting that a portion of the window needs to be redrawn (namely the portion we just calculated).

The above block of code is called once for each row of the fractal window being generated, which has the effect of queuing up all of the fractal to be handled as there are available threads.

Moving upward in the code's organization, each fractal window we generate is managed by an instance of the  FractalSet  class.

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
 13
 class FractalSet {
      has Bool $.is-julia;
      has Complex $.upper-right;
      has Real $.delta;
      has Int $.width;
      has Int $.height;
      has Int $.max_iterations;
      has Complex $.c;
      has @.rows;
      has @.line-work-items;
      has $.new-upper-right;
  
      has $.draw-area;


$.is-julia  and  $.max_iterations  are self-explanatory.  $.upper-right  is the fixed complex number anchoring the image.  $.delta  is the amount of change in the previous number per-pixel; we assume the pixels are square.  $.width  and  $.height  are the size of the window in pixels.  $.c  only has meaning for Julia sets, where it is the value  $c  in the equation  $new-z = $z * $z + $c .  @.rows  the pixel information generated by the  row  sub above;  @.line-work-items saves a reference to all of the  WorkItem s generating those rows. $.new-upper-right  is temporary used during the zoom mouse operation.  $.draw-area  is the  Gtk.DrawingArea  for the related window.

Once all that is set up, the rest of the code is pretty straightforward. The Gtk windowing code is set up in  FractalSet.build-window :

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
 13
 14
 15
 16
 17
 18
 19
 20
 21
 22
 23
 24
 25
 method build-window()
 {
      my $index = +@windows;
      @windows.push(self);
      self.start-work;
  
      my $window = Window.new($.is-julia ?? "julia $index" !! "mandelbrot $index");
      $window.SetData("Id", SystemIntPtr.new($index));
      $window.Resize($.width, $.height);  # TODO: resize at runtime NYI
  
      my $event-box = GtkEventBox.new;
      $event-box.SetData("Id", SystemIntPtr.new($index));
      $event-box.add_ButtonPressEvent(&ButtonPressEvent);
      $event-box.add_ButtonReleaseEvent(&ButtonReleaseEvent);
  
      my $drawingarea = $.draw-area = GtkDrawingArea.new;
      $drawingarea.SetData("Id", SystemIntPtr.new($index));
      $drawingarea.add_ExposeEvent(&ExposeEvent);
      $window.add_DeleteEvent(&DeleteEvent);
      $event-box.Add($drawingarea);
  
      $window.Add($event-box);
      $window.add_KeyReleaseEvent(&KeyReleaseEvent);
      $window.ShowAll;
 }


We store a global array  @windows  tracking all the  FractalSet s in play. Each of the different objects here gets the  "Id"  data set to this set's index into the  @windows  array so we can easily look up the FractalSet  from callback functions. The rest of the method is just plugging the right callback into each component -- simple conceptually but it took this Gtk novice a lot of work figuring it all out.

As an example, consider the  KeyReleaseEvent  callback, which responds to presses on the keyboard.

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
 13
 sub KeyReleaseEvent($obj, $args) {
      my $index = $obj.GetData("Id").ToInt32();
      my $set = @windows[$index];
       
      given $args.Event.Key {
          when 'm' | 'M' {
              $set.increase-max-iterations;
          }
          when 's' | 'S' {
              $set.write-file;
          }
      }
 }


First we lookup the index into  @windows , then we get the  $set  we're looking at. Then we just call the appropriate  FractalSet  method, for instance

 1
 2
 3
 4
 5
 method increase-max-iterations() {
      self.stop-work;
      $.max_iterations += 32;
      self.start-work;
 }


.stop-work  cancels all the pending operations for this FractalSet, then we bump up the number of iterations, and then we  .start-work again to queue up a new set of rows with the new values.

The full  source code is here.  As of this writing it agrees with the code here, but this is an active project, and probably will change again in the not-too-distant future. Right now my biggest goals are figuring out how to get the threading to actually improve performance on my MacBook Pro and cleaning up the code. Both suggestions and questions are welcome.


Posted in  2011  |  1 Comment »
Where Have All The References Gone? December 16, 2011


Perl 5 programmers that start to learn Perl 6 often ask me how to take a reference to something, and my answers usually aren’t really helpful. In Perl 6, everything that can be held in a variable is an object, and objects are passed by reference everywhere (though you don’t always notice that, because objects like strings and numbers are immutable, so there’s no difference to passing by value). So, everything is already treated as a reference in some sense, and there’s no point in explicitly taking references.

But people aren’t happy with that answer, because it doesn’t explain how to get stuff done that involved references in Perl 5. So here are a few typical use cases of references, and how Perl 6 handles them.

Creating Objects

In Perl 5, an object is really just a reference to a blessed value (but people usually say "blessed reference", because you virtually never use the blessed value without going through a reference).

So, in Perl 5 you’d write
package My::Class;
# constructor
sub new { bless {}, shift };
# an accessor
sub foo {
     my $self = shift;
     # the ->{} dereferences $self as a hash
     $self->{foo} // 5;
}
# use the object:
say My::Class->new->foo;

In Perl 6, you just don’t think about references; classes are much more declarative, and there’s no need for dereferencing anything anywhere:
class My::Class {
     # attribute with accessor (indicated by the dot)
     # and default value
     has $.foo = 5;
}
# use it:
say My::Class.new.foo

If you don’t like the default constructor, you can still use  bless explicitly, but even then you don’t have to think about references:
method new() {
     # the * specifies the storage, and means "default storage"
     self.bless(*);
}

So, no explicit reference handling when dealing with OO. Great.

Nested Data Structures

In both Perl 5 and Perl 6, lists flatten automatically by default. So if you write
my @a = (1, 2);
my @b = (3, 4);
push @a, @b

then  @a  ends up with the four elements  1, 2, 3, 4 , not with three elements of which the third is an array.

In Perl 5, nesting the data structure happens by taking a reference to @b :
push @a, \@b;

In Perl 6, item context replaces this use of references. It is best illustrated by a rather clumsy method to achieve the same thing:
my $temp = @b;
 push @a, $temp;  # does not flatten the two items in $temp,
                 # because $temp is a scalar

Of course there are shortcuts; the following lines work too:
push @a, $(@b);
push @a, item @b;

(As a side note,  push @a, $@b  is currently not allowed, it tries to catch a p5ism; I will also try to persuade Larry and the other language designers to allow it, and have it mean the same thing as the other two).

On the flip side you need explicit dereferencing to get the values out of item context:
my @a = 1, 2;
my $scalar = @a;
for @a {
     # two iterations
}
for $scalar {
     # one iteration only
}
for @$scalar {
     # two iterations again
}

This explicit use of scalar and list context is the closest analogy to Perl 5 references, because it requires explicit context annotations in the same places where referencing and dereferencing is used in Perl 5.

But it’s not really the same, because there are cases where Perl 5 needs references, but Perl 6 can deduce the item context all on its own:
@a[3] = @b; # automatically puts @b in item context

Mutating Arguments

Another use references in Perl 5 is for passing data to routines that should be modified inside the routine:
sub set_five; {
     my $x = shift;
     # explicit dereferencing with another $:
     $$x = 5;
}
my $var;
# explicit taking of a reference
set_five \$var;

In Perl 6, there is a separate mechanism for this use case:
sub set_five($x is rw) {
     # no dereferencing
     $x = 5;
}
my $var;
# no explicit reference taking
set_five $var;

So again a use case of Perl 5 references is realized by another mechanism in Perl 6 (signature binding, or binding in general).

Summary

Nearly everything is a reference in Perl 6, but you still don’t see them, unless you take a very close look. The control of list flattening with item and list context is the one area where Perl 5′s referencing and dereferencing shines through the most.

来源： < http://perl6advent.wordpress.com/2011/12/ >  