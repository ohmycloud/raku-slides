# Day 9 – Data munging in Perl 6 vs Perl 5

by smls
One thing that Perl has traditionally been used for a lot, is small scripts which read some data (usually from a file), put it into a data structure, transform said data structure, and print some output based on it.

I believe that Perl 6, too, has the potential to appeal to people with such data wrangling needs (who may not necessarily be professional programmers, e.g. powerusers/sysadmins or students/scientists). Perl 6 does not share Perl 5’s selling-point of coming pre-installed on most *nix systems, but it entices with convenience features that allow script writers to focus more on what they’re trying to accomplish, and less on low-level technical details.

Let me showcase and compare an idiomatic Perl 5 solution and an idiomatic Perl 6 solution for the same simple data munging use-case (which might be a little contrived, but practical enough to be transferable to more complex problems), so you can form your own opinion:


Case Study: Generating a Grades Report

example.txt		
Peter	B
Celine	A-
Zsófia	B+
João	F
Maryam	B+
秀英	B-
Finn	D+
Aarav	A
Emma	F
Omar	B

STDOUT :	

Zsófia's grade: B+
List of students with a failing grade:
  João, Emma
Distribution of grades by letter:
  A: 2 students
  B: 5 students
  D: 1 student
  F: 2 students
  
Consider a text file in which each line lists a unique student name and, separated by whitespace, that student’s grade (like shown above, except that there could be arbitrarily many lines). We want our script to be able to parse such a file and print a report consisting of three things:

the grade of the student named “Zsófia”,
the names of all students with a failing grade (i.e. worse than D-),
a frequency distribution of grades grouped by their letter (without the +/-).
Let’s go through the complete solution step-by-step, for both languages at the same time:

Part 1: Boilerplate

Perl 5	
#!/usr/bin/env perl

use warnings;
use strict;
use feature 'say';
use utf8;
binmode STDOUT, ':utf8';

Perl 6	
#!/usr/bin/env perl6
In the Perl 5 version, we need to start with a little “exposition” so that we can…

be reasonably confident that in case of a typo in the code, we won’t get incorrect results without noticing it;
print lines without having to add \n at the end all the time;
write Unicode characters (like ó) directly in the source code;
print text which contains Unicode characters to standard output.
In Perl 6, all of those features are already enabled out of the box, so we save some typing.

If you plan to save the script as a file with the .pl suffix, consider adding the line use v6; at the top though, so a useful error message is printed when the file is accidentally executed with the Perl 5 interpreter.
On to the actual code:

Part 2: Reading and parsing input

Perl 5	
open my $fh, '<:utf8', "grades.txt"
    or die "Failed to open file: $!";

my %grade;
while (<$fh>) {
    m/^(\w+) \s+ ([A-F][+-]?)$/x
        or die "Can't parse line '$_'";
    $grade{$1} = $2;
};
Perl 6	
my %grade = "grades.txt".IO.lines.map: {
    m:s/^(\w+) (<[A..F]><[+-]>?)$/
        or die "Can't parse line '$_'";
    ~$0 => ~$1
};
A hash variable (signified by the % sigil) lends itself to storing the kind of data we’re dealing with here: For each line of the file, we’ll create an entry in our hash with the student name as the key, and the grade as the value.

In Perl 5, the customary idiom for processing a file line-by-line is to use an open statement to store a filehandle in a variable, and then iterate over it with the magic angle-brackets operator and a while loop.

In Perl 6, we can use a more high-level approach: Calling the .IO method on the filename string returns an object which represents that filesystem path, on which we can in turn call the .lines method to get a lazy list of the lines of that file. ‘Lazy’ means that it will only read new lines from disk as needed, while we loop over the list elements – which we do here using the .map method, since this allows us to elegantly initialize the hash using a single assignment.

Other things of note in the Perl 6 version:

We don’t need to make the filehandle Unicode-aware or make sure we exit with an error in case the file can’t be read – both happen by default.
The .method: ... syntax is an alternative way to write .method(...), which in this case allows our map to look more like a block statement and reduces parentheses clutter.
The :s (“sigspace”) regex modifier makes parsing whitespace between tokens more elegant. On the other hand, character classes have become slightly more verbose compared to Perl 5…
The regex capture result variables ($0, $1, …) return full Match objects – which adds lots of flexibility for more complex use-cases, but here we only want to keep around the strings they matched, so we “stringify” them using the ~ prefix operator.
Part 3: Looking up an item of data

Perl 5	
say "Zsófia's grade: $grade{Zsófia}";
Perl 6	
say "Zsófia's grade: %grade<Zsófia>";
Not much to see here; both languages make it easy to access a value from a hash, and interpolate it into a string.

Do note though how Perl 6 variables always keep their normal sigil, and the { } hash indexing operator no longer guesses whether you meant the thing inside as an expression or a literal string – it always parses its content as an expression, and is joined by the new < > variant for literal strings.
Part 4: Filtering data

Perl 5	
say "List of students with a failing grade:";
say "  " . join ", ",
           grep { $grade{$_} ge "E" } keys %grade;
Perl 6	
say "List of students with a failing grade:";
say "  " ~ %grade.grep(*.value ge "E")».key.join(", ");
When it comes to filtering data, grep is our friend.

Leaving aside the fact that common Perl functions now also exist as methods in Perl 6 (allowing us to write chained operations in the order that they’ll be executed), there’s a more important difference here: Perl 6 lets us iterate over hash entries directly, each of them represented as a Pair object (which provides the .key and .value methods).

Other things of note in the Perl 6 version:

The * Whatever star is used to define a simple callback without having to write a curly-braced block.
The ». hyper operator is used to call the .key method on every element of the list of Pairs returned by .grep, and collect the results as a new list.
Part 5: Creating a frequency distribution from data

Perl 5	
say "Distribution of grades by letter:";
my %freq;
$freq{substr $grade{$_}, 0, 1}++ for keys %grade;
say "  $_: $freq{$_} student".($freq{$_} != 1 ? "s" : "")
    for sort keys %freq;
Perl 6	
say "Distribution of grades by letter:";
say "  {.key}: {+.value} student{"s" if .value != 1}"
    for %grade.classify(*.value.comb[0]).sort(*.key);
In Perl 5, the customary idiom for tallying up related items is to declare a new hash variable, and then iterate over the input data and increment a value in said hash on each iteration.

That would work in Perl 6, too… However since tallying or grouping items is such a common thing to do, a .classify method is provided which only requires us to specify what the items (here: Pair objects representing %grade entries) should be grouped by (here: the first letter of the value, which holds the grade). This gives us an anonymous hash of arrays like this:

%("B" => ["Peter" => "B", "Zsófia" => "B+", "Maryam" => "B+",
          "秀英" => "B-", "Omar" => "B"],
  "A" => ["Celine" => "A-", "Aarav" => "A"],
  "F" => ["João" => "F", "Emma" => "F"],
  "D" => ["Finn" => "D+"])
Since we’re only interested in the number of elements in each group, we “numify” each value of that hash using the + prefix operator before printing it, which does what we want since the numeric value of an array is its number of elements.

Other convenient Perl 6 features visible in this part of the solution:

A lone .method in term position is short for $_.method, i.e. calling the method on the current loop value.
The return value of arbitrary code can be interpolated into a string using curly braces.
Note: Rakudo currently has a known bug which prevents accessing $_ in such blocks inside strings; until it gets fixed, you can use $( ) instead of curly braces there, as a (less pretty) work-around.
if statements can be used as expressions – when the condition is false, the empty list is returned, which stringifies to the empty string.
Calling .comb without an argument on a string, returns a list of its characters.
That’s it; Here’s the whole code in one piece:

Perl 5 version
Perl 6 version
Perl 6 version with work-around for the aforementioned Rakudo bug
Conclusion

Although coding in Perl 5 and Perl 6 generally feels similar, Perl 6 oftentimes facilitates a more declarative or ”functional” approach to data munging.

Rather than having to use imperative flow control statements, temporary variables, and low-level IO operations, many simple data transformations can be written as an expression that only references the input once at the start, and “pipes” it through a number of methods calls and the like. This not only helps readability, but can for example also make it easier to parallelize code later on.

Of course, the trusty old imperative idioms are still supported too, so you can choose what’s best for each situation.

See Also / Further Reading

There are many data-munging related topics that I haven’t covered in this post; here are a few important ones, with links for further reading:

One-liners
For very simple data munging tasks, a Perl 6 one-liner may suffice. They work similarly to Perl 5 one-liners, except that they tend to rely less on special magic variables and built-ins to keep things short, and more on generally applicable features like the fact that leaving off the invocant of a method call automatically uses $_.
Grammars
For more complex use-cases you may find your data parsing needs outgrowing regexes; Luckily, Perl 6 provides an easy upgrade path to full-fledged grammar-based parsing, since Perl 6 regexes and grammars use the same notation.
Modules for parsing XML/CSV etc.
Of course if the data you’re parsing comes in a standard format like CSV or XML, you wouldn’t write your own parsing logic; you’d use one of the ready-made modules for it (which tend to be similar to the corresponding Perl 5 CPAN modules).
Concurrency/Parallelism
If the data-processing you’re doing is CPU intensive, you might want to run some of it in parallel to make use of multiple cores.
In Perl 5, this requires dealing with advanced low-level concepts such as threads and shared variables and tends to make your code significantly more complex, so people usually don’t bother.
Perl 6 aims to change that by providing high-level concurrency primitives, which in many cases can be used to parallelize computations without having to significantly refactor your code, and without having to deal with threads/locks/mutexes/etc.
About these ads