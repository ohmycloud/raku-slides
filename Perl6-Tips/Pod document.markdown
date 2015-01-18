 Perl 6 Documentation
Search 


Perl 6 Containers: a low-level approach
What is a variable?
Scalar containers
Binding
Scalar Containers and Listy Things
Assigning and Binding to Array Variables
Binding to Array Elements
Flattening, Items and Containers
Non-flattening contexts
What flattens, what doesn't? Perl 6 Containers: a low-level approach

This article started as a conversion on IRC explaining the difference between the Array and the List type in Perl 6. It explains the levels of indirection involved in dealing with variables and container elements. What is a variable?

Some people like to say "everything is an object", but in fact a variable is not a user-exposed object in Perl 6.

When the compiler encounters a variable declaration like my $x , it registers it in some internal symbol table. This internal symbol table is used to detect undeclared variables, and to tie the code generation for the variable to the correct scope.

At run time, a variable appears as an entry in a lexical pad , or lexpad for short. This is a per-scope data structure that stores a pointer for each variable.

In the case of my $x , the lexpad entry for the variable $x is a pointer to an object of type Scalar , usually just called the container . Scalar containers

Although objects of type Scalar are everywhere in Perl 6, you usually never see them directly as objects, because most operations decontainerize , which means they act on the Scalar container's contents instead of the container itself.

In a code like
my $x = 42;
say $x;

the assignment $x = 42 stores a pointer to the Int object 42 in the scalar container to which the lexpad entry for $x points.

The assignment operator asks the container on the left to store the value on its right. What exactly that means is up to the container type. For Scalar it means "replace the previously stored value with the new one".

Note that subroutine signatures allow passing around of containers:
sub f($a is rw) {
    $a = 23;
}
my $x = 42;
f($x);
say $x;         # 23

Inside the subroutine, the lexpad entry for $a points to the same container that $x points to outside the subroutine. Which is why assignment to $a also modifies the contents of $x .

Likewise a routine can return a container if it is marked as is rw :
my $x = 23;
sub f() is rw { $x };
f() = 42;
say $x;         # 42

For explicit returns, return-rw instead of return must be used.

Returning a container is how is rw attribute accessors work. So
class A {
    has $.attr is rw;
}

is equivalent to
class A {
    has $!attr;
    method attr() is rw { $!attr }
} Binding

Next to assignment, Perl 6 also supports binding with the := operator. When binding a value or a container to a variable, the lexpad entry of the variable is modified (and not just the container it points to). If you write
my $x := 42;

then the lexpad entry for $x directly points to the Int 42. Which means that you cannot assign to it anymore:
$ perl6 -e 'my $x := 42; $x = 23'
Cannot modify an immutable value
   in block  at -e:1

You can also bind variables to other variables:
my $a = 0;
my $b = 0;
$a := $b;
$b = 42;
say $a;         # 42

Here after the initial binding, the lexpad entries for $a and $b both point to the same scalar container, so assigning to one variable also changes the contents of the other.

You've seen this situation before: it is exactly what happened with the signature parameter marked as is rw . Scalar Containers and Listy Things

There are a number of positional container types with slightly different semantics in Perl 6. The most basic one is Parcel , short for Parenthesis cell . It is created by the comma operator, and often delimited by round parenthesis -- hence the name.
say (1, 2, 3).WHAT;     # (Parcel)

A parcel is immutable, which means you cannot change the number of elements in a parcel. But if one of the elements happens to be a scalar container, you can still assign to it:
my $x = 42;
($x, 1, 2)[0] = 23;
say $x;                 # 23
($x, 1, 2)[1] = 23;     # Error: Cannot modify an immutable value

So the parcel doesn't care about whether its elements are values or containers, they just store and retrieve whatever was given to them.

A List has the same attitude of indifference towards containers. But it allows modifying the length (for example with push , pop , shift and unshift ), and it is also lazy.

An Array is just like a list, except that it forces all its elements to be containers. Thus you can say
my @a = 1, 2, 3;
@a[0] = 42;
say @a;         # 42 2 3

and @a actually stores three scalar containers. @a[0] returns one of them, and the assignment operator replaces the integer value stored in that container with the new one, 42 . Assigning and Binding to Array Variables

Assigning to a scalar variable and to an array variable both do basically the same thing: discard the old value(s), and enter some new value(s).

Still it's easy to observe how different they are:
my $x = 42; say $x.WHAT;    # (Int)
my @a = 42; say @a.WHAT;    # (Array)

This is because the Scalar container type hides itself well, but Array makes no such effort.

To place a non- Array into an array variable, binding works:
my @a := (1, 2, 3);
say @a.WHAT;                # (Parcel) Binding to Array Elements

As a curious side note, Perl 6 supports binding to array elements:
my @a = (1, 2, 3);
@a[0] := my $x;
$x = 42;
say @a;                     # 42 2 3

If you've read and understood the previous explanations, it is now time to wonder how this can possibly work. After all, binding to a variable requires a lexpad entry for that variable, and while there is one for an array, there aren't lexpad entries for each array element (you cannot expand the lexpad at run time).

The answer is that binding to array elements is recognized at the syntax level, and instead of emitting code for a normal binding operation, a special method on the array is called that knows how to do the binding itself. Flattening, Items and Containers

The % and @ sigils in Perl 6 generally indicate flattening. That means that flattening list context iterates over them as if there was no container boundary:
my @a = 1, 2, 3;
my @b = @a, 4, 5;
say @b.elems;               # 5
say @b.join: '|';           # 1|2|3|4|5

Here @a is flattened out in the second line.

Item containers prevent flattening, thus allowing the programmer to write nested data structures.

The following examples all do the same, and do not flatten:
my @a = 1, 2, 3;
my @b = @a.item, 4, 5;
   @b = $(@a), 4, 5;
   @b = $@a, 4, 5;
   @b = [1, 2, 3], 4, 5;
my $item = @a;
   @b = $item, 4, 5;
say @b.perl;            # Array.new([1, 2, 3], 4, 5);

[...] creates an itemized array, and Array.new(...) a non-itemized array.

There is a slight exception though: if you call a method on an itemized container, it will generally behave as if it weren't itemized. So [1, 2, 3].join(',') produces "1,2,3" as a result, as one might hope.

This also means that calling the .list method flattens out an itemized container:
my $item = [1, 2, 3]; 
my @b = $item.list, 4, 5;    # 5 elems
   @b = @($item), 4, 5;      # a shortcut
   @b = @$item, 4, 5;        # another shortcut

Other methods on lists also return flat lists/parcels, so for example
my $item = [1, 2, 3]; 
my @b = $item.sort, 4, 5;    # 5 elems

sorts the elements of $item and then returns a list that is flattened out in the array assignment.

Note that .list de-itemizes only the invocant; it does not recursively flatten the whole data structure. For example in
my @a = [1, [2, 3, 4]].list;
say @a.elems;               # 2

the .list only de-itemizes the outer bracktes, the inner ones create an array that is stored in the second element of the Array, and is not touched by .list .