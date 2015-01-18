=encoding utf8

=head1 TITLE

Synopsis 7: Lists and Iteration  列表和迭代

=head1 AUTHORS

    Patrick R. Michaud <pmichaud@pobox.com

=head1 VERSION

    Created: 12 July 2012

    Last Modified: 29 May 2013
    Version: 2

=head1 Overview

Lists and arrays have always been one of Perl's fundamental data types,
and Perl 6 is no different.  However, lists in Perl 6 have been greatly
extended to accommodate lazy lists, infinite lists, lists of mutable
and immutable elements, typed lists, flattening behaviors, and so on.  
So where lists and arrays in Perl 5 tended to be finite sequences of 
scalar values, in Perl 6 we have additional dimensions of behavior
that must be addressed.
Perl 6 中的列表扩展为惰性列表、无限列表、元素可变列表、元素不可变列表、类型列表、展开行为等等。

=head2 The C<List> type

The C<List> class is the base class for dealing with other types of
lists, including C<Array>.  To the programmer, a C<List> is a potentially
lazy and infinite sequence of elements.  A C<List> is mutable, in that
one can manipulate the sequence via operations such as C<push>, C<pop>,
C<shift>, C<unshift>, C<splice>, etc.  A C<List>'s elements may be
either mutable or immutable.

对于程序员来说，列表潜在是懒惰并含有无限元素的序列。列表是可变的，你可以通过诸如 push、pop、shift、unshift、splice等操作符来操作序列。列表中的元素可以是可变的或者不可变的。
C<List> objects are C<Positional>, meaning they can be bound to
array variables and support the postfix C<.[]> operator.
列表对象是基于位置的，意味着它们能被绑定到数组变量上，并且支持 .[] 后缀操作符。

Lists are also lazy, in that the elements of a C<List> may 
come from generator functions (called C<Iterator>s) that produce
elements on demand.
列表也是懒惰的，因为列表中的元素可以来自于能按需产生元素的生成函数（叫做迭代）。

=head2 The C<Array> type

An C<Array> is simply a C<List> in which all of the elements are held
in scalar containers.  This allows assignment to the elements of the
array.
数组就是一个所有元素都存储在标量容器的列表。

=head2 The C<Parcel> type

The comma operator (C<< infix:<,> >>) creates C<Parcel> objects.  
These should not be confused with lists; a C<Parcel> represents
a raw syntactic sequence of elements.  A C<Parcel> is immutable,
although the elements of a C<Parcel> may be either mutable or
immutable.
逗号操作符 infix:<,> 创建 Parcel 对象。这些不应该改和列表混淆； Parcel 是一种未经加工的元素序列。Parcel 是不可变的，尽管 Parcel中的元素可以是不可变的，也可是不可变的。





The name "Parcel" is derived from the phrase "parenthesis cell", 
since many C<Parcel> objects appear inside of parentheses.  
However, except for the empty parcel, it's the comma operator 
that creates C<Parcel> objects.  
Parcel 来自于短语  "parenthesis cell".因为很多 Parcel 对象出现在圆括号里面。然而，除了空的 parcel，是逗号操作符创建了 Parcel 对象。




    ()       # empty Parcel
    (1)      # 一个整数
    (1,2)    # a Parcel with two Ints
    (1
,
)     # a Parcel with one Int
> (1).WHAT()
(Int)
> (1,).WHAT()
(Parcel)


A C<Parcel> is also C<Positional>, and uses flattening context for
list operations such as C<.[]> and C<.elems>.  See "Flattening contexts"
below.  For raw access to the arguments without flattening, you may use
C<.arg($n)> instead of C<.[$n]>, and C<.args> instead of C<.elems>.
Parcel 也是位置的，并且对于诸如  .[] 和 .elems 列表操作会使用 展开上下文。查看下面的  "Flattening contexts"。访问没有展开的原始参数，你可以使用 .arg($n) 代替 .[$n], 和 .args 代替 .elems




=head2 Flattening contexts, the C<Iterable> type

C<List> and C<Parcel> objects can have other container objects
as elements.  In some contexts we want to interpolate the values
of container objects into the surrounding C<List> or C<Parcel>,
while in other contexts we want any subcontainers to be preserved.
Such interpolation is known as "flattening".
列表和Parcel 对象都把其它容器对象作为元素。在一些上下文中，我们想把容器对象的值插入到列表或 parcel的周围，而在其它上下文中，我们想
保留所有的子容器
。这样的插值叫做 展开。

The C<Iterable> type is performed by container and generator objects
that will interpolate their values in flattening contexts.  Both
C<List> and C<Parcel> are C<Iterable>.  C<Iterable> implies support
for C<.iterator>, which returns an object capable of producing the
elements of the C<Iterable>.
列表和Parcel都是可迭代的，可迭代表明它支持 .iterator 方法

Objects held in scalar containers are never interpolated in
flattening context, even if the object is C<Iterable>.
标量容器中存储的对象不会在 flattening 上下文中插值，即使那个对象是可迭代的。




    my @a = 3,4,5;
    for 1,2,
@a
 { .say }        # 5次迭代
1
2
3
4
5

    my $s = @a;
    for 1,2,
$s
 { ... }        # 3次迭代
1
2
3 4 5

Here, both C<$s> and C<@a> refer to the same underlying C<Array> object,
but the presence of the scalar container prevents C<$s> from being
flattened into the C<for> loop.  The C<.list> or C<.flat> method
may be used to restore the flattening behavior:
这里，$s 和 @a 指向同一个数组对象，但是标量容器的出现阻止 $s 被展开到 for 循环中。 
.list
 和 
.flat
 方法能被用于还原展开行为：

    for 1,2,$s.list { .say }    # 5次遍历
    for 1,2,@($s) { .say  }     # 5次遍历，@()会强制为列表上下文
1
2
3
4
5

Conversely, the C<.item> or C<$()> contextualizer can be used to
prevent an C<Iterable> from being interpolated:
相反，
.item
 方法和 
$()
 能用于防止插值：
    my @b = 1,2,@a;           # @b 有5个元素
    my @c = 1,2,@a.item;      # @c 有3个元素
    my @c = 1,2,$(@a);        # 同上
> say 
+@c


3
=head2 Iterators 迭代器

An C<Iterator> is an object that is able to generate or produce
elements of a list (called "reification").  Because a single
C<Iterator> may be directly or indirectly referenced by
multiple container objects simultaneously, C<Iterator>s provide 
an immutable view of the sequence of elements produced, leaving
it up to containers to provide any mutability.

=head3 The C<.reify> method

The C<.reify($n)> method requests an C<Iterator> to return a C<Parcel>
consisting of at least C<$n> reified elements, followed by any additional
iterators needed for the remaining elements in the sequence.  For example:

.reify($n)
 方法要求迭代器返回一个含有至少$n个具体元素的 Parcel，后面跟着序列中剩余元素的附加的迭代器，例如：
    my $r = 10..50;
    say $r.iterator.reify(5).perl;  # (10, 11, 12, 13, 14, 
15..50
)

Iterators are allowed to return more or fewer elements than requested
by C<$n>; it's up to the caller to properly handle any shortage or 
excess.  (In general an iterator is expected to always reify at
least one element, however.)  If C<$n> is C<*>, then the iterator
is asked to generate elements according to whatever is most natural 
for the thing being iterated.  For a C<Range> this might be a substantial
number (or even all) of the elements of the range; for a filehandle
it might read a single record; for a C<List> it may return only the
non-lazy portion of the list.
> say $r.iterator.reify(
*
).perl
(10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 37, 48, 49, 50)
Once C<.reify> is called on an iterator, the iterator is expected
to return the same results for all subsequent calls to C<.reify>.
This is true even if the C<$n> argument is different from one call
to the next.  The general pattern is often something like:

    class SomeIter is Iterator {
        has $!reified;

        method reify($n = 1) {
            unless $!reified.defined {
                # generate return Parcel and bind to $!reified
            }
            $!reified;
        }
    }

=head3 The C<.infinite> method

Because lists in Perl 6 can be lazy, they can also be infinite.
Each C<Iterator> must provide an C<.infinite> method, which returns
a value indicating the knowable finiteness of the iteration:

    .infinite     Meaning
    ----------------------------------------------
    True          iteration is known to be infinite
    False         iteration is known to be finite
    Mu            finiteness isn't currently known

As an example, C<Range> iterators can generally know finiteness simply
by looking at the endpoint of the C<Range>.  The iterator for the
C<< infix:<...> >> sequence operator treats any sequence ending in 
C<*> as being "known infinite", all other C<...> sequences have unknown
finiteness.  In the general case it's not possible for loop iterators
to definitively know if the sequence will be finite or infinite.
(Conjecture:  There will be a syntax or mechanism for the programmer
to indicate that such sequences are to be treated as known finite
or known infinite.)

=head2 Levels of laziness

Laziness is one of the primary virtues of a Perl programmer; it is
also one of the virtues of Perl 6.  However, it's also possible to
succumb to false laziness, so there are times when Perl 6 chooses 
to be eager instead of lazy.

Perl 6 defines four levels of laziness:

=over

=item Strictly Lazy

Does not evaluate anything unless explicitly required by the caller,
including not traversing non-lazy objects.  This behavior generally
occurs only by a pragma or by explicit lazy primitives.

=item Mostly Lazy

Try to obtain available elements without causing eager evaluation
of other lazy objects.  However, the implementation is allowed to
do batching for efficiency.  The programmer must not rely on
circular side effects when the implementation is working ahead
like this, or the results will be indeterminate.  (However, this
does not rule out pure I<definitional> circularity; earlier array
values may be used in the definition of subsequent values.)

=item Mostly Eager

Obtain all leading items that are not known to be infinite.
The remainder of the items are left for lazy evaluation.  
As with the "mostly lazy" case, the programmer must not depend 
on circular side effects in any situation where the implementation 
is allowed to work ahead.  Note that there are no language-defined 
limits on the amount of conjectural evaluation allowed, up to the 
size of available memory; however, an implementation may allow 
the arbitrary limitation of workahead by use of pragmas.

In any case there should be no profound semantic differences
between "mostly lazy" and "mostly eager".  These levels are
primarily just hints to the implementation as to whether you are
likely to want to use all the values in the list.  Nothing
transactional should be allowed to depend on the difference.

=item Strictly Eager

Obtain all items, failing immediately with an appropriate message
if asked to evaluate any data structures known to be infinite.
(Data structures that are effectively infinite but not provably
so will likely exhaust memory instead.)

=back

=head2 The laziness level of some common operations

=over

=item List assignment; my @a = @something;

In order to provide p5-like behavior in list assignment, it is performed
at the Mostly Eager level.  This means that if you do

    my @a = foo();

it will eagerly evaluate the return value from C<foo()> to place
elements into C<@a>, stopping only when encountering something
that is "known infinite" or upon reaching the end of the sequence.

=item C<for>, C<map>, C<grep>, etc.

The C<for> loop and looping routines such as C<map>, C<grep>, etc. are
Mostly Lazy by default, but will be eager when evaluated in sink context.
(Note, however, that we force C<for>, C<while>, C<until>, C<repeat> and
C<loop> loops to always be in sink context when used as a statement within
a statementlist.)

=item Slurpy parameters

Slurpy parameters are Mostly Lazy.

=item Feed operators
feed操作符是完全懒惰的，意味着在使用者要求任何元素之前不会执行任何操作。这就是

  my @a <== grep { ... } <== map { ... } <== grep { ... } <== 1, 2, 3

是完全懒惰的。

=back

=head2 Common list operations


