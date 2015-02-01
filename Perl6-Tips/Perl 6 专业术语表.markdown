# Glossary of Perl 6 terminology
    Anonymous
    Autothreading
    Instance
    Invocant
    Literal
    lvalue
    Mainline
    Slurpy
    Type Object 
	

匿名子例程、方法或子方法，当它们不能通过名字调用时，被称作匿名的
# named subroutine
sub double($x) { 2 * $x };
# 
匿名子例程,存储在一个具名的标量里

my $double = sub ($x) { 2 * $x };

注意，匿名子例程仍然可以有名字
# anonymous, but knows its own name
my $s = 
anon
 sub triple($x) { 3 * $x }
say $s.name;        # triple Autothreading

Autothreading is what happens if you pass a junction to a sub that expects a parameter of type Any or a subtype thereof. The call is executed multiple times, each time with a different eigenstate of the junction. The result of these calls is assembled in a junction of the same type as the original junction.
sub f($x) { 2 * $x };
if f(1|2|3) == 4 {
    say 'success';
}

这里  f()  是一个含有一个参数的子例程，并且因为它没有显式的类型，它被隐式地作为 Any 类。  Junction  参数使  f(1|2|3)调用在内部作为   f(1)|f(2)|f(3)执行 ,而结果分支是  2|4|6 . This process of separating Junction arguments into multiple calls to a function is called autothreading . Instance

An instance of a class is also called an object in some other programming languages. It has a storage for attributes, and is often the return value of a call to a method called new , or a literal.

Instances of most types are defined to be True e.g., defined($instance) is True .
my Str $str = "hello";  ## this is with builtin types, e.g. Str
if defined($str) {
    say "Oh, yeah. I'm defined.";
} else {
    say "No. Something off? ";
}
## if you wanted objects...
class A {
    # nothing here for now.
}
my $an_instance = A.new;
say $an_instance.defined.perl;# defined($an_instance) works too.

Or to put it another way, a class has all the blueprint of methods and attributes, and an instance carries it forward into the real world. Invocant

The object on which a method is called is called the invocant in Perl 6. It is what self refers to in a method.
say 'str'.uc;   # 'str' is the invocant of method uc Literal

A literal is a piece of code that directly stands for a (often built-in) object, and also refers to the object itself.
my $x = 2;      # the 2 is a literal
say $x;         # $x is not a literal, but a variable lvalue

An lvalue or a left value is anything that can appear on the left hand side of the assignment operator = ; anything you can assign to.

Typical lvalues are variables, private and is rw attributes, lists of variables and lvalue subroutines.

Examples of lvalues:
Declaration             lvalue          Comments
my $x;                  $x
my ($a, $b);            ($a, $b)
has $!attribute;        $!attribute     Only inside classes
has $.attrib is rw;     $.attrib
sub a is rw { $x };     a()

Examples of things that are not lvalues
3                        # literals
constant x = 3;          # constants
has $.attrib;            # attributes; you can only assign to $!attrib
sub f { }; f();          # "normal" subs are not writable
sub f($x) { $x = 3 };    # error - parameters are read-only by default Mainline

The mainline is the program text that is not part of any kind of block.
use v6;     # mainline
sub f {
            # not in mainline, in sub f
}
f();        # in mainline again Slurpy

A parameter of a sub or method is said to be slurpy if it can consume an arbitrary number of arguments. It is indicated by an asterisk * in front of the parameter name.
sub sum (*@numbers) {
    return [+] @numbers;
} Type Object

A type object is an object representing a class, role, package, grammar or enum. It is generally accessible with the same name as the type.
class A { };
say A;              # A is the type object
my $x = A.new();    # same here
my $x = class {
    method greet() {
        say "hi";
    }
}
# $x now holds a type object returned from the
# anonymous class definition


Generated on 2014-03-22T13:18:49-0400 from the sources at perl6/doc on github . This is a work in progress to document Perl 6, and known to be incomplete. Your contribution is appreciated.

The Camelia image is copyright 2009 by Larry Wall.
