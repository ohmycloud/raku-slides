Perl 6 专家指南  开始
分类: Perl6
原文： http://perl6maven.com/tutorial/toc    The Perl Maven's Perl 6 Tutorial


 

 

  开始

Perl6是一个规范和一组测试。任何通过测试的编译器都被认为是一个合法的Perl 6 编译器。Perl 6 有几种编译器。 就今天而言，他们都是不完整的实现现了语言的一个子集。

Rakudo 运行在Parrot虚拟机上，并且它是目前最有希望的实现。
Niecza是一个定位于公共语言运行库的编译器（.NET和Mono）。
Perlito可以被绑定在网上，因为它可以将一些Perl 6的代码编译为Javascript，并在浏览器中运行。
Pugs是用Haskell编写的是第一个可用的实现，但但是它是目前只有最低限度的维护。

我们将使用 Rakudo

 

 

 

 

 

 

 

 

 

 
Introduction to Perl 6
Getting started
Other resources
Installing Rakudo
Development Environment
Running Rakudo
Hello World
Comments
POD - Plain Old Documentation
First steps in Perl 6
Hello World - scalar variables
Hello World - interpolation
Reading from the keyboard
Numerical operations
Automatically convert string to number
String operators
String concatenation
String repetition
if statement - comparing values
Other forms of the if statement
Ternary Operator
Comparison Operators
Boolean expressions (logical operators)
Chained comparisons
Comparing values - Calculator
Calculator - given
String functions: index
String functions: substr
Super-or (junctions)
Files in Perl 6
exit
warn
die
Twigils and special variables
Read line from file
Read all the lines with get
Process a file line by line
Write to a file
Open file modes
slurp
Read lines into array
Exercise: Print sum of numbers
Solution
Perl 6 Lists and Arrays
List Literals, list ranges
List Assignment
Swap two values
Loop over elements of list with for
Create array, go over elements
Array elements (create menu)
Array assignment
Command line options
Process CSV file
join
The uniq functions
Looping over a list of values one at a time, two at a time and more
Looping over any number of elements
Missing values
Iterating over more than one array in parallel
Z as in zip
xx - string multiplicator
sort values
Meta Operators
Assignment Operators
Method invocation in assignment
Calling a function during assignment
Negated Relation Operators
Reversed operators
Hyper Operators
Reduction operators
Reduction Triangle operators
Cross operators
Perl 6 Hashes
Hashes (Associative Arrays)
Fetching data from a hash
Multidimensional hashes
Count words
Overview
slurp
kv
Looping over keys of a hash
Subroutines in Perl 6
Simple definition with required parameters
Subroutine with arbitrary number of parameters
Passing arrays and hashes
Multiple signatures
Optional parameters
Named only parameters
No parameter definition - perl 5 style
Fibonacci
Creating Operators
Create your own operator
Perl 6 Regexes
Regexes in Perl 6
Match digit
Match Any character
Escape characters
Spaces in regex
End of string anchors
Ranges
Arithmetic
Quantifier
Quantifier 2
Match several words
Alternates
Match object
Capture
Named Regex
Capture with quantifier
Reuse capture
Word boundary
Named Regex
Rules
Tokens
Replace
Grammar
Grammar with error handling
Grammar that is easier to extend
Grammar subclass
Junctions in Perl 6
Junctions
More examples with Junctions
Modules in Perl 6
Exporting subs from modules
Object Oriented Perl 6
Simple Point class
Read/write attributes and accessors
Class Methods
Private Attributes
Method with parameters
Inheritence of classes
Classes in Perl 6
Perl 5 to Perl 6
Intro
Hello World
Scalars
Arrays
Hashes
Control Structures
Functions
Files
Modules, Classes
Perl 5 to Perl 6
Shell to Perl 6
Intro
Unix commands in Perl 6
awk
cat
cd in Perl 6
chmod
chown
cmp
compress
cut
date
diff
df
dos2unix
du
file
find
grep
gzip
head
kill
ln
ls
mkdir
mv
ps
popd
pushd
pwd
rmdir
rm
sed
sort
tail
tar
touch
uniq
unix2dos
wc
who
zip
Other UNIX command
Appendix
grok and App::Grok
Using 3rd party Perl 6 modules
Thanks