
NAME
DESCRIPTION
Bits and Pieces
Sigils
Hash elements no longer auto-quote
Global variables have a twigil
Command-line arguments
New ways of referring to array and hash elements
The double-underscore keywords are gone
Context

Operators
qw() changes; new interpolating form
Other important operator changes

Blocks and Statements
You don't need parens on control structure conditions
eval {} is now try {}
foreach becomes for
for becomes loop

Regexes and Rules
New regex syntax
Anonymous regexpes are now default

Subroutines
Formats
Packages
Modules
Objects
Method invocation changes from -> to .
Dynamic method calls distinguish symbolic refs from hard refs
Built-in functions are now methods

Overloading
Offering Hash and List semantics
Chaining file test operators has changed

Builtin Functions
References are gone (or: everything is a reference)
say()
wantarray() is gone

AUTHORS
NAME

Perl6::Perl5::Differences -- Differences between Perl 5 and Perl 6 DESCRIPTION

This document is intended to be used by Perl 5 programmers who are new to Perl 6 and just want a quick overview of the main differences. More detail on everything can be found in the language reference, which have been linked to throughout. In certain cases, you can also just use Perl 5 code in Perl 6 and compiler may say what's wrong. Note that it cannot recognize every difference, as sometimes old syntax actually means something else in Perl 6.

This list is currently known to be incomplete. Bits and Pieces Sigils

Where you used to say:
    my @fruits = ("apple", "pear", "banana");
    print $fruit[0], "\n";

You would now say:
    my @fruits = "apple", "pear", "banana";
    say @fruit[0];

Or even use the <> operator, which replaces qw() :
    my @fruits = <apple pear banana>;

Note that the sigil for fetching a single element has changed from $ to @ ; perhaps a better way to think of it is that the sigil of a variable is now a part of its name, so it never changes in subscripting. This also applies to hashes.

For details, see "Names and Variables" in S02 . Hash elements no longer auto-quote

Hash elements no longer auto-quote:
    过去：    $days{February}
    现在：   
 %days{'February'}

    Or:    
 %days<February>

    Or:     %days<<February>>

The curly-bracket forms still work, but curly-brackets are more distinctly block-related now, so in fact what you've got there is a block that returns the value "February". The <> and <<>> forms are in fact just quoting mechanisms being used as subscripts (see below). Global variables have a twigil

Yes, a twigil. It's the second character in the variable name. For globals, it's a *
    过去：    $ENV{FOO}
    现在：    %*ENV<FOO>

For details, see "Names and Variables" in S02 . Command-line arguments

The command-line arguments are now in @ * ARGS , not @ARGV . Note the * twigil because @*ARGS is a global. New ways of referring to array and hash elements

Number of elements in an array:
    过去：    $#array+1 or scalar(@array)
    现在：    @array
.elems

Index of last element in an array:
    过去：    $#array
    现在：    @array
.end

Therefore, last element in an array:
    过去：    $array[$#array]
    现在：    @array[@array.end]
            @array[*-1]              # beware of the "whatever"-star

For details, see "Built-In Data Types" in S02 The double-underscore keywords are gone
    Old                 New
    ---                 ---
    __LINE__            $
?
LINE
    __FILE__            $
?
FILE
    __PACKAGE__         $
?
PACKAGE
    __END__            
 =begin END

    __DATA__            
=begin DATA

See "double-underscore forms are going away" in S02 for details. The ? twigil refers to data that is known at compile time. Context

There are still three main contexts, void, item (formerly scalar) and list. Aditionally there are more specialized contexts, and operators that force that context.
    my @array = 1, 2, 3;

    # 生成项上下文
    my $a = @array; say $a.WHAT;    # prints Array

    # 字符串上下文
    say 
~
@array;                    # "1 2 3"

    # 数字上下文
    say +@array;                    # 3

    # 布尔上下文
    my $is-nonempty = 
?
@array;

Apostrophes ' and dashes - are allowed as part of identifiers, as long as they appear between two letters. Operators

A comprehensive list of operator changes is documented at "Changes to Perl 5 operators" in S03 and "New operators" in S03 .

Some highlights: qw() changes; new interpolating form
    过去：    qw(foo)
    现在：    <foo>

    过去：    split ' ', "foo $bar bat"
    现在：    <<foo $bar bat>>

Quoting operators now have modifiers that can be used with them (much like regexes and substitutions in Perl 5), and you can even define your own quoting operators. See S03 for details.

Note that () as a subscript is now a sub call, so instead of qw(a b) you would write qw<a b> or qw[a b] (if you don't like plain <a b> ), that is). Other important operator changes

String concatenation is now done with ~ .

Regex match is done with the smart match operator ~~ , the perl 5 match operator =~ is gone.
    if "abc" ~~ m/a/ { ... }

| and & as infix operators now construct junctions. The binary AND and binary OR operators are split into string and numeric operators, that is ~& is binary string AND, +& is binary numeric AND, ~| is binary string OR etc.
    过去： $foo & 1;
    现在： $foo +& 1;

The bitwise operators are now prefixed with a +, ~ or ? depending if the data type is a number, string or boolean.
    过去： $foo << 42;
    现在： $foo +< 42;

The assignment operators have been changed in a similar vein:
    过去： $foo <<= 42;
    现在： $foo +<= 42;

圆括号不创建列表，它们只是分组。列表是由逗号操作符创建的。逗号操作符比列表赋值操作符的优先级高，这允许你不使用括号而将列表写在右边。
    my @list = 1, 2, 3;     # @list really has three elements

解引用中的箭头操作符 -> 不见了。因为所有的东西都是对象，并且解引用的圆括号就是使用语法糖的方法调用，你可以直接使用合适的括号对儿进行索引或方法调用：
    my $aoa = [[1, 2, 3], [4, 5, 6], [7, 8, 9]];
    say $aoa[1][0];         # 4

    my $s = sub { say "hi" };
    $s();
    # or
    $s.();
    $lol.[1][0] Blocks and Statements

See S04 for the full specification of blocks and statements in Perl6. You don't need parens on control structure conditions
    过去：    if ($a < $b) { ... }
    现在：    if  
$a < $b
  { ... }

while 和 for 同样不需要括号。如果你坚持使用括号，确保在 if 后面有一个空格，否则它会是一个子例程调用。 eval {} is now try {}

Using eval on a block is now replaced with try .
    过去：  eval {
            # ...
          };
          if ($@) {
            warn "oops: $@";
          }
    现在：  
try
  {
             # ...
            
 CATCH
 { warn "oops: $!" }
          }

CATCH provides more flexiblity in handling errors. See "Exception_handlers" in S04 for details. foreach becomes for
    过去：    foreach (@whatever) { ... }
    现在：    for
 @whatever 
      { ... }

Also, the way of assigning to something other than $_ has changed:
    过去：    foreach my $x (@whatever) { ... }
    现在：    for @whatever -> $x       { ... }

This can be extended to take more than one element at a time:
    过去：    while (my($age, $sex, $location) = splice @whatever, 0, 3) { ... }
    现在：    for @whatever -> $age, $sex, $location { ... }

(Except the for version does not destroy the array.)

See "The for statement" in S04 and "each" in S29 for details. for becomes loop
    过去：    for  ($i=0; $i<10; $i++) { ... }
    现在：    
loop
 ($i=0; $i<10; $i++) { ... }

loop can also be used for infinite loops:
    过去：    while (1) { ... }
    现在：    loop { ... } Regexes and Rules New regex syntax

Here's a simple translation of a Perl5 regular expression to Perl6:
    过去：    $str =~ m/^\d{2,5}\s/i
    现在：    $str 
~~
 m
:P5:i
/^\d{2,5}\s/

The :P5 modifier is there because the standard Perl6 syntax is rather different, and 'P5' notes a Perl5 compatibility syntax. For a substitution:
    过去：    $str =~ s/(a)/$1/e;
    现在：    $str ~~ s
:P5
/(a)/{$0}/;

Notice that $1 starts at $0 now, and /e is gone in favor of the embedded closure notation. Anonymous regexpes are now default

Anonymous regexpes are now default, unless used in boolean context.
    过去：    my @regexpes = (
                qr/abc/,
                qr/def/,
            );
    现在：    my @regexpes = (
                /abc/,
                /def/,
            );

Also, if you still want to mark regexp as anonymous, the qr// operator is now called rx// (Mnemonic: r ege x ) or regex { } .

For the full specification, see S05 . See also:

The related Apocalypse, which justifies the changes:
  http://dev.perl.org/perl6/doc/design/apo/A05.html

And the related Exegesis, which explains it more detail:
  http://dev.perl.org/perl6/doc/design/exe/E05.html Subroutines Formats

Formats will be handled by external libraries. Packages Modules Objects

Perl 6 has a "real" object system, with key words for classes, methods and attributes. Public attributes have the . twigil, private ones the ! twigil.
    class YourClass {
        has $!private;
        has @.public;

        # and with write accessor
        has $.stuff is rw;

        method do_something {
            if self.can('bark') {
                say "Something doggy";
            }
        }
    } Method invocation changes from -> to .
方法调用从 -> 变成 .
    过去：    $object
->method

    现在：    $object
.method Dynamic method calls distinguish symbolic refs from hard refs
  过去： $self->$method()
  现在： $self.$method()      # hard ref
  现在： $self."$method"()    # symbolic ref Built-in functions are now methods  内置函数现在是方法了

大部分内置函数是内建的诸如 String、Array这种类的方法了：
    过去：    my $len = length($string);
    现在：    my $len = $string
.chars
;

    过去：    print sort(@array);
    现在：    print @array
.sort
;
            @array
.sort.print
;

You can still say sort(@array) if you prefer the non-OO idiom. Overloading  重载

Since both builtin functions and operators are multi subs and methods, changing their behaviour for particular types is a simple as adding the appropriate multi subs and methods. If you want these to be globally available, you have to put them into the GLOBAL namespace:
    multi sub GLOBAL::uc(TurkishStr $str) { ... }

    # "overload" the string concatenation:
    multi sub infix:<~>(TurkishStr $us, TurkishStr $them) { ... }

If you want to offer a type cast to a particular type, just provide a method with the same name as the type you want to cast to.
    sub needs_bar(Bar $x) { ... }
    class Foo {
        ...
        # coercion to type Bar:
        method Bar { ... }
    }

    needs_bar(Foo.new);         # coerces to Bar Offering Hash and List semantics

If you want to write a class whose objects can be assigned to a variable with the @ sigil, you have to implement the Positional roles. Likewise, for the % sigil you need to do the Associative role. The & sigil implies Callable .

The roles provides the operators postcircumfix:<[ ]> (Positional; for array indexing), postcircumfix:<{ }> (Associative) and postcircumfix:<()> (Callable). The are technically just methods with a fancy syntax. You should override these to provide meaningful semantics.
    class OrderedHash does Associative {
        multi method postcircumfix:<{ }>(Int $index) {
            # code for accessing single hash elements here
        }
        multi method postcircumfix:<{ }>(**@slice) {
            # code for accessing hash slices here
        }
        ...
    }

    my %orderedHash = OrderedHash.new();
    say %orderedHash{'a'};

See S13 for all the gory details. Chaining file test operators has changed   链式文件测试操作符已经变化了
    过去： if (-r $file && -x _) {...}
    现在： if $file 
~~
 
:r & :x
  {...}

For details, see "Changes to Perl 5 operators"/"The filetest operators now return a result that is both a boolean" in S03 Builtin Functions

A number of builtins have been removed. For details, see:

"Obsolete Functions" in S29 References are gone (or: everything is a reference)   引用消失了（或者：一切都是引用）

Capture objects fill the ecological niche of references in Perl 6. You can think of them as "fat" references, that is, references that can capture not only the current identity of a single object, but also the relative identities of several related objects. Conversely, you can think of Perl 5 references as a degenerate form of Capture when you want to refer only to a single item.



  过去： ref $foo eq 'HASH'
  现在： $foo ~~ Hash

  过去： @new = (ref $old eq 'ARRAY' ) ? @$old : ($old);
  现在： @new = @$old;

  过去： %h = ( k => \@a );
  现在： %h = ( k => @a );

To pass an argument to modify by reference:
  过去： sub foo {...};        foo(\$bar)
  现在： sub foo ($bar is 
rw
); foo(
$bar
)

The "obsolete" reference above has the details. Also, look for Capture under "Names_and_Variables" in S02 , or at the Capture FAQ, Perl6::FAQ::Capture . say()

This is a version of print that auto-appends a newline:
    过去：    print "Hello, world!\n";
    现在：    say   "Hello, world!";

Since you want to do that so often anyway, it seemed like a handy thing to make part of the language. This change was backported to Perl 5, so you can use say after you will use v5.10 or better. wantarray() is gone

wantarray is gone. In Perl 6, context flows outwards, which means that a routine does not know which context it is in.

Instead you should return objects that do the right thing in every context. AUTHORS

Kirrily "Skud" Robert, <skud@cpan.org> , Mark Stosberg, Moritz Lenz, Trey Harris, Andy Lester