 Perl 6 Documentation
class List
Items, Flattening and Sigils
Methods
elems
end
keys
values
kv
pairs
join
map
grep
first
classify
Bool
Str
Int
pick
roll
eager
reverse
rotate
sort
reduce
splice
pop
push
shift
unshift
combinations
permutations
Methods supplied by role Positional
of
Methods supplied by class Any
ACCEPTS
any
all
one
none
Methods supplied by class Mu
defined
Bool
Str
gist
perl
clone
new
bless
CREATE
print
say
ACCEPTS
WHICH
my class List is Iterable does Positional { .. }

List stores items sequentially and potentially lazily.

Indexes into lists and arrays start at 0 by default.

You can assign to list elements if they are containers. Use Arrays to have every value of the list stored in a container. Items, Flattening and Sigils

In Perl 6, assigning a List to a scalar variable does not lose information. The difference is that iteration generally treats a list (or any other list-like object, like a Parcel or an Array ) inside a scalar as a single element.
my @a = 1, 2, 3;
for @a { }      # three iterations
my $s = @a;
for $s { }      # one iteration
for @a.item { } # one iteration
for $s.list { } # three iterations

Lists generally interpolate (flatten) unless they are accessed via an item (scalar) container.
my @a = 1, 2, 3;
my @flat   = @a, @a;           # six elements
my @nested = @a.item, @a.item; # two elements

.item can often be written as $( ... ) , and on an array variable even as $@a . Methods elems
multi sub    elems($list)  returns Int:D
multi method elems(List:D:) returns Int:D

Returns the number of elements in the list. end
multi sub    end($list)  returns Int:D
multi method end(List:D:) returns Int:D

Returns the index of the last element. keys
multi sub    keys($list)  returns List:D
multi method keys(List:D:) returns List:D

Returns a list of indexes into the list (e.g., 0..(@list.elems-1)). values
multi sub    values($list)  returns List:D
multi method values(List:D:) returns List:D

Returns a copy of the list. kv
multi sub    kv($list)  returns List:D
multi method kv(List:D:) returns List:D

Returns an interleaved list of indexes and values. For example
<a b c>.kv

Returns
0, 'a', 1, 'b', 2, 'c' pairs
multi sub    pairs($list)   returns List:D
multi method pairs(List:D:) returns List:D

Returns a list of pairs, with the indexes as keys and the list values as values.
<a b c>.pairs   # 0 => 'a', 1 => 'b', 2 => 'c' join
multi sub    join($separator, *@list) returns Str:D
multi method join(List:D: $separator) returns Str:D

Treats the elements of the list as strings, interleaves them with $separator and concatenates everything into a single string.

Example:
join ', ', <a b c>;     # 'a, b, c' map
multi sub    map(&code, *@elems) returns List:D
multi method map(List:D: &code) returns List:D

Invokes &code for each element and gathers the return values in another list and returns it. This happens lazily, i.e. &code is only invoked when the return values are accessed.

Examples:
> ('hello', 1, 22/7, 42, 'world').map: { .WHAT.perl }
Str Int Rat Int Str
> map *.Str.chars, 'hello', 1, 22/7, 42, 'world'
5 1 8 2 5 grep
multi sub    grep(Mu $matcher, *@elems) returns List:D
multi method grep(List:D:  Mu $matcher) returns List:D

Returns a lazy list of elements against which $matcher smart-matches. The elements are returned in the order in which they appear in the original list.

Examples:
> ('hello', 1, 22/7, 42, 'world').grep: Int
1 42
> grep { .Str.chars > 3 }, 'hello', 1, 22/7, 42, 'world'
hello 3.142857 world first
multi sub    first(Mu $matcher, *@elems)
multi method first(List:D:  Mu $matcher)

Returns the first item of the list which smart-matches against $matcher , fails when no values match.

Examples:
say (1, 22/7, 42).first: * > 5;     # 42
say $f = ('hello', 1, 22/7, 42, 'world').first: Complex;
>  ('hello', 1, 22/7, 42, 'world',1+2i).first: Complex;
1+2i
say $f.perl; #  Failure.new(exception => X::AdHoc.new(payload => "No values matched")) classify
multi sub    classify(&mapper, *@values) returns Hash:D
multi method classify(List:D: &mapper)   returns Hash:D

Transforms a list of values into a hash representing the classification of those values according to a mapper; each hash key represents the classification for one or more of the incoming list values, and the corresponding hash value contains an array of those list values classified by the mapper into the category of the associated key.

Example:
say classify { $_ %% 2 ?? 'even' !! 'odd' }, (1, 7, 6, 3, 2);
            # ("odd" => [1, 7, 3], "even" => [6, 2]).hash;;
say ('hello', 1, 22/7, 42, 'world').classify: { .Str.chars }
            # ("5" => ["hello", "world"], "1" => [1], "8" => [22/7], "2" => [42]).hash Bool
multi method Bool(List:D:) returns Bool:D

Returns True if the list has at least one element, and False for the empty list. Str
multi method Str(List:D:) returns Str:D

Stringifies the elements of the list and joins them with spaces (same as .join(' ') ). Int
multi method Int(List:D:) return Int:D

Returns the number of elements in the list (same as .elems ). pick
multi sub    pick($count, *@list) returns List:D
multi method pick(List:D: $count = 1)

Returns $count elements chosen at random and without repetition from the invocant. If * is passed as $count , or $count is greater than or equal to the size of the list, then all elements from the invocant list are returned in a random sequence.

Examples:
say <a b c d e>.pick;           # b
b
say <a b c d e>.pick: 3;        # c a e
say  <a b c d e>.pick: *;       # e d a b c roll
multi sub    roll($count, *@list) returns List:D
multi method roll(List:D: $count = 1)

Returns a lazy list of $count elements, each randomly selected from the list. Each random choice is made independently, like a separate die roll where each die face is a list element.

If * is passed to $count , returns a lazy , infinite list of randomly chosen elements from the original list.

Examples:
say <a b c d e>.roll;       # b
b
say <a b c d e>.roll: 3;    # c c e
say roll 8, <a b c d e>;    # b a e d a e b c
my $random_digits := (^10).roll(*);1;
say $random_digits[^15];    # 3 8 7 6 0 1 3 2 0 8 8 5 8 0 5 eager
multi method eager(List:D:) returns List:D

贪婪地计算列表中的所有元素。Evaluates all elements in the list eagerly, and returns the invocant. If a List signals that it is "known infinite", eager evaluation may stop at the point where the infinity is detected. reverse
multi sub    reverse(*@list ) returns List:D
multi method reverse(List:D:) returns List:D

Returns a list with the same elements in reverse order.

Note that reverse always refers to reversing elements of a list; to reverse the characters in a string, use flip .

Examples:
say <hello world!>.reverse      #  world! hello
say reverse ^10                 # 9 8 7 6 5 4 3 2 1 0 rotate
multi sub    rotate(@list,  Int:D $n = 1) returns List:D
multi method rotate(List:D: Int:D $n = 1) returns List:D

Returns the list rotated by $n elements.

Examples:
<a b c d e>.rotate(2);   # <c d e a b>
<a b c d e>.rotate(-1);  # <e a b c d> sort
multi sub    sort(*@elems)      returns List:D
multi sub    sort(&by, *@elems) returns List:D
multi method sort(List:D:)      returns List:D
multi method sort(List:D:, &by) returns List:D

Sorts the list, smallest element first. By default infix:< cmp > is used for comparing list elements.

If &by is provided, and it accepts two arguments, it is invoked for pairs of list elements, and should return Order::Increase , Order::Same or Order::Decrease .

If &by accepts only one argument, the list elements are sorted according to by($a) cmp by($b) . The return values of &by are cached, so that &by is only called once per list element.

Examples:
say (3, -4, 7, -1, 2, 0).sort;                  # -4 -1 0 2 3 7
say (3, -4, 7, -1, 2, 0).sort
:
 
*.abs
;           # 0 -1 2 3 -4 7
say (3, -4, 7, -1, 2, 0).sort
:
 { $^b leg $^a }; # 7 3 2 0 -4 -1 reduce
multi sub    reduce(&with, *@elems)
multi method reduce(List:D: &with)

Applies &with to the first and the second value of the list, then to the result of that calculation and the third value and so on. Returns a single item generated that way.

Note that reduce is an implicit loop, and thus responds to next , last and redo statements.

Example:
say (1, 2, 3).reduce: 
* - *
;    # -4 splice
multi sub    splice(@list,  $start, $elems?, *@replacement) returns List:D
multi method splice(List:D: $start, $elems?, *@replacement) returns List:D

Deletes $elems elements starting from index $start from the list, returns them and replaces them by @replacement . If $elems is omitted, all the elements starting from index $start are deleted.

Example:
my @foo = <a b c d e f g>;
say @foo.splice(2, 3, <M N O P>);       # c d e
say @foo;                               # a b M N O P f g pop
multi sub    pop(List:D )
multi method pop(List:D:)

Removes and returns the last item from the list, fails for an empty list.

Example:
> my @foo = <a b>;
a b
> @foo.pop;
b
> pop @foo
a
> pop @foo
Element popped from empty list push
multi sub    push(List:D, *@values) returns List:D
multi method push(List:D: *@values) returns List:D

Adds the @values to the end of the list, and returns the modified list. Fails for infinite lists.

Example:
my @foo = <a b c>;
@foo.push: 1, 3 ... 11;
say @foo;                   # a b c 1 3 5 7 9 11 shift
multi sub    shift(List:D )
multi method shift(List:D:)

Removes and returns the first item from the list. Fails for an empty list.

Example:
my @foo = <a b>;
say @foo.shift;     # a
say @foo.shift;     # b
say @foo.shift;     # Element shifted from empty list unshift
multi sub    unshift(List:D, *@values) returns List:D
multi method unshift(List:D: *@values) returns List:D

Adds the @values to the start of the list, and returns the modified list. Fails if @values is infinite.

Example:
my @foo = <a b c>;
@foo.unshift: 1, 3 ... 11;
say @foo;                   # 1 3 5 7 9 11 a b c combinations
multi method combinations (List:D: Int:D $of)          returns List:D
multi method combinations (List:D: Range:D $of = 0..*) returns List:D
multi sub    combinations ($n, $k)                     returns List:D

The Int variant returns all $of -combinations of the invocant list. For example
say .join('|') for <a b c>.combinations(2);

prints
a|b
a|c
b|c

because all the 2-combinations of 'a', 'b', 'c' are ['a', 'b'], ['a', 'c'], ['b', 'c'] .

The Range variant combines all the individual combinations into a single list, so
say .join('|') for <a b c>.combinations(2..3);

prints
a|b
a|c
b|c
a|b|c

because that's the list of all 2- and 3-combinations.

The subroutine form combinations($n, $k) is equivalent to (^$n).combinations($k) , so
.say for combinations(4, 2)

prints
0 1
0 2
0 3
1 2
1 3
2 3 permutations
multi method permutations(List:D:) returns List:D
multi sub    permutations($n)      returns List:D

Returns all possible permutations of a list as a list of arrays. So
say .join('|') for <a b c>.permutations

prints
a|b|c
a|c|b
b|a|c
b|c|a
c|a|b
c|b|a

permutations treats all list elements as distinguishable, so (1, 1, 2).permutations still returns a list of 6 elements, even though there are only three distinct permutations.

The subroutine form permutations($n) is equivalent to (^$n).permutations , so
.say for permutations 3;

prints
1 2 3
1 3 2
2 1 3
2 3 1
3 1 2
3 2 1 Full-size type graph image as SVG Methods supplied by role Positional

List does role Positional , which provides the following methods: of
method of()

Returns the type constraint for elements of the positional container. Defaults to Mu . Methods supplied by class Any

List inherits from class Any , which provides the following methods: ACCEPTS
multi method ACCEPTS(Any:D: Mu $other)

Returns True if $other === self (i.e. it checks object identity). any

Interprets the invocant as a list and creates an any -Junction from it. all

Interprets the invocant as a list and creates an all -Junction from it. one

Interprets the invocant as a list and creates an one -Junction from it. none

Interprets the invocant as a list and creates an none -Junction from it. Methods supplied by class Mu

List inherits from class Mu , which provides the following methods: defined
multi sub    defined(Mu) returns Bool:D
multi method defined()   returns Bool:D

Returns False on the type object, and True otherwise. Bool
multi sub    Bool(Mu) returns Bool:D
multi method Bool()   returns Bool:D

Returns False on the type object, and True otherwise. Str
multi method Str()   returns Str

Returns a string representation of the invocant, intended to be machine readable. gist
multi sub    gist(Mu) returns Str
multi method gist()   returns Str

Returns a string representation of the invocant, optimized for fast recognition by humans.

The default gist method in Mu re-dispatches to the perl method, but many built-in classes override it to something more specific. perl
multi sub    perl(Mu) returns Str
multi method perl()   returns Str

Returns a Perlish representation of the object (i.e., can usually be re-parsed to regenerate the object). clone
method clone(*%twiddles)

Creates a shallow clone of the invocant. If named arguments are passed to it, their values are used in every place where an attribute name matches the name of a named argument. new
multi method new(*%attrinit)

Default method for constructing (create + initialize) new objects of a class. This method expects only named arguments which are then used to initialize attributes with accessors of the same name.

Classes may provide their own new method to override this default. bless
method bless(*%attrinit) returns Mu:D

Lower-level object construction method than new .

Creates a new object of the same type as the invocant, uses the named arguments to initialize attributes, and returns the created object.

You can use this method when writing custom constructors:
class Point {
    has $.x;
    has $.y;
    multi method new($x, $y) {
        self.bless(:$x, :$y);
    }
}
my $p = Point.new(-1, 1);

(Though each time you write a custom constructor, remember that it makes subclassing harder). CREATE
method CREATE() returns Mu:D

Allocates a new object of the same type as the invocant, without initializing any attributes. print
multi method print() returns Bool:D

Prints value to $*OUT after stringification using .Str method without newline at end. say
multi method say() returns Bool:D

Prints value to $*OUT after stringification using .gist method with newline at end. ACCEPTS
multi method ACCEPTS(Mu:U: $other)

Performs a type check. Returns True if $other conforms to the invocant (which is always a type object or failure).

This is the method that is triggered on smart-matching against type objects, for example in if $var ~~ Int { ... } . WHICH
multi method WHICH() returns ObjAt:D

Returns an object of type ObjAt which uniquely identifies the object. Value types override this method which makes sure that two equivalent objects return the same return value from WHICH .


Generated on 2014-03-22T13:18:49-0400 from the sources at perl6/doc on github . This is a work in progress to document Perl 6, and known to be incomplete. Your contribution is appreciated.

The Camelia image is copyright 2009 by Larry Wall.
