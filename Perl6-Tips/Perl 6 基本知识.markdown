


 V


 Perl 6
 Perl 6 Basics Tablet

 Contents
 Defaults
 Statements
 Spaces and Indentation
 Comments
 Single Line
 Multi Line
 POD

 Quoting
 Delimiter
 Interpolation
 Single Quotes
 Double Quotes
 Quote Words
 Heredocs
 Paths
 Regex
 Code

 Number Literals
 Radix Prefixes
 General Radix Form
 Scientific Notation
 Rational Number
 Complex Number
 Version Number

 Formatting
 perl
 pretty
 fmt
 sprintf
 pack
 Formats
 Date and Time






1st law of language redesign: Everyone wants the colon for their particular syntax.
2nd law of language redesign: Larry gets the colon for whatever he wants.

Basics doesn't mean here not always easy but fundamental. Defaults

Please start your Perl 6 program with one of the following lines. #!/usr/bin/perl6
use v6.0;
v6;


or just start with a keyword like module or class . That marks your code as Perl 6 (in case the interpreter defaults to Perl 5) and makes it possible to mix Perl 5 and 6 in one source file.

To even that little obstacle, you can leave out the usual use strict; and use warnings; in front of every script, because thats now default. Also use utf; is obsolete since any Perl 6 source code is always treated as unicode and any UTF character can be used anywhere in the code. Even the features of the pragmas constant and vars are now part of the core language.

Also the functionality of many useful and famous modules like Moose (object system), Parse::RecDescent++, exception handling, List::[More]Utils , Export, English an advanced pretty printer and much more is already built in. So you get a lot extra for a little v6; . Statements

Unless you use blocks , a Perl program executes one statement after another in linear progression (from left to right, from up to down). They have to be separated by a semicolon ( ; ), except before and after a closing curly brace, where it is optional. $coderef = sub { fetch_data(); compute() }
空格和缩进

Perl doesn't care about indentation. And spaces are still in many places without meaning. However these have become fewer. 注释 单行注释

Like in Perl 5 and many other languages of its league, a "#" tells the compiler to ignore the rest of the line. my $var = 'good'; # that code is boring
多行注释

If many lines has to be commented, use #` followed by any pair of braces that surround the comment. $things = #`( i wonder how many of these
I will need, hm maybe 3, or 4, better 5 ) 5; # same as $things = 5;
POD

Even POD is there to embedd documentation, it can be used just for inserting comments. =begin comment
...
=end comment
$=


all POD variables 引号

Quoting is like regular expression a sublanguage inside the main language with its own syntactical rules. It is parsed by a special grammar as to be found in the special variable $~Quote . The operator with the same name (the generic quoting operator Q) does almost nothing, just provides a mechanism to mark the beginning and end of text sequence. 分隔符

The examples in this chapter use almost every time slashes for that purpose, but any not alphanumerical character or pair of matching (bracing) character can be used as well. Q /.../ or Q |...| or Q *...* or Q "..." or Q[...] ...


An extended delimiter mechanism is delivered by heredocs . 插值

Inside of these delimiters, every character will be taken literally. Any additional meaning has to be added by quoting adverbs that have to follow the Q. Most of them have a short and a long name and some of the most useful have an additional syntax that replaces them altogether with the Q operator (like single or double quotes). :b aka :backslash # control character (implies at least :q )
:s aka :scalar # scalar variable : $name
:a aka :array # array variable : @name[...]
:h aka :hash # hash variable : %name{...}
:c aka :closure # anonymous blocks : {...}
:f aka :function # callable routines : &name(...)
Q :b /\t\n/; # tab and new line character
Q :s /$poem/; # content of $poem
Q :a /@primes[]/; # all number separated by single spaces
Q :a /@primes[0]/; # returns '2', the first prime
Q :a /me@primes.de/; # returns literally the mail adress, you need the square braces to interpolate arrays
Q :h /%dev{}/; # all developer names (values, not keys) separated by single spaces, angle brackets work too
Q :h /%dev[rakudo] %dev<niecza>/; # just 2 values
Q :h /%dev/; # literally '%dev', you need braces here too
Q :c /There are {2**6} hexagrams in I Ging./; # returns: 'There are 64 hexagrams in I Ging.', inserts the result of the closure
Q :c /Perl 6 Compiler: {%dev.keys}./; # use it too for method calls
Q :h /Perl 6 Compiler: %dev.keys./; # no interpolation
Q :f :a /Here it Tom with the weather: &fetch_report($day)./; # inserts report of that day, even inside Strings the correctness of arguments will be checked!
Q :f :a /fetch_report($day)/; # interpolates just $day
Q :f :a /&fetch_report/; # literal string '&fetch_report', even if the subroutine takes no arguments
单引号

They provide the most basic mechanism in a convenient syntax. All the following are synonyms: Q :single /.../;
Q :q /.../;
q /.../;
'...'


The backslash (\) liberates here just itself and the single quote from its special meaning. Or to put it simple \\ translates (or interpolates) to \ and \' to ' . For anything more you need additional adverbs. 'Welcome in Larry\'s madhouse'
'\'\\'; # string contains: '\
q |\||; # string contains: |
双引号

Double quoting combines all the previous mentioned adverbs for interpolation (also :q - implied by :b ), thatswhy all the following are synonymous. Q :s, :a, :h, :f, :c, :b /.../;
Q :double /.../;
Q :qq /.../;
qq /.../;
"..."


But further adverbs can also be added using q/.../ or qq/.../. Quote Words

While other quote operators return a single string item, this one can return arrays because he splits the string on any whitespace (\s aka <ws>). Q :words /.../;
Q :w /.../; # :q implied
qw/.../; # like Perl 5's qw/.../
<...>
Q :quotewords /.../; # qw/.../ with quote protextion
Q :ww /.../; # :qq implied
<<>> # have also a unicode alias (chevron)


The second group of aliases mark a modified version, where single and double quoted strings (inside the quote) are treated as one word. Thats called quote protection . my @steps = <one "two three">; # 3 steps to success: ["one", "\"two", "three\""]
my @steps = <<one "two three">>; # now only 2 steps: ["one", "two three"]


Please note also that :quotewords (double pointy braces) implies :double (double quotes), which means all interpolation rules apply here also. <$pi> eq '$pi'
<<$pi>> eq "$pi" # == '3.14159...'


The same pointy braces (quote operators) are also in used, when writing hash slices . Heredocs

Are now normal quoted strings, only with a special delimiter, defined by the adverbs to and heredoc. Heredocs can be nested. Q :to 'EOT';
...
...
EOT


To make templates in which variables and closures are evaluated, take the normal double quote and just add the adverb for the heredoc delimiter or define with other adverbs what exactly you want to have evaluated. qq:heredoc 'EOT';
EOT
路径

Pathstrings have their own quote operator. This way you get the warnings early if there is something incompatible with convention. Q :path /.../;
Q :p /.../;
qp /.../;
正则

Even being a completely different language then quoting on its own (as to be defined in $~Regex and $~P5Regex ), regular expressions can be built using the general quoting operator with the right adverb. Q :regex /.../ aka rx/.../
Q :subst /.../.../ aka s/.../.../
Q :trans /.../.../ aka tr/.../.../ aka .trans("..." => "...")
代码

The following 3 aliases quote code that will be run immediately (on runtime) and replaced with the result. Q :exec /.../;
Q :x /.../;
qx /.../;


In Perl 5 qx/.../ aka ... did a system call and not just run eval. To get that behaviour use: qqx/$cmd @args[]/ # do system call and insert result, alias to that is gone


However there is yet another adverb for quasi quoting, meaning: the quoted code will be parsed and compiled into a abstract syntax tree (AST - internal representation of the compiler) during compile time. Result is the compiled AST. Parsing will be done by using the grammar stored in $~Quasi . This gets important when writing macros . Q :code /.../;
数字直接量

Unlike strings, numbers don't need quoting . But if there is a non number character in it, there will be an error. Chars of a number definition are: (0-9,.,+,-,e,E,i,_) including the radix prefixes : (0b,0o,0d,0x) and the prefix for version numbering (v). The + and can act also as operator that convert into the numerical context, which still means: take from left to right all digits and stop with the first none number character.

A single underscore is allowed only between any two digits, delimiter helping readability. 3_456_789; # same as 3456789
$int = 2;
$real = 2.2;
基数前缀 0b binary - base 2, digits 0..1
0o ocatal - base 8, digits 0..7
0d decimal - base 10, digits 0..9
0x hexadecimal - base 16, digits 0..9,a..f (case insensitive)
通用基数形式 :10<42> # same as 0d42 or 42      :16<11>  # 等于10进制的17
科学记数法 $float = 60.2e23 # becomes automatically 6.02e24
$float = 6.02E-23 # capital E works too
有理数

To distinguish them from a division operation, you have to groupe them with braces. (3/7)
(3/7).numerator
(3/7).denominator
(3/7).nude.perl


As always, .perl gives you an almost source like code formatting which results here in 3/7 . Adding .nude you get (3/7) , the nude source code. There are 2 different immutable value types representing both rational number. FatRat has unlimited precision and Rat has just enough to be evaled into a Real type. When you explicitly type a variable to one o them, the braces become optional. my Rat $pi_approx = 22/7;
my FatRat $pi_approx = 2222222222/6981317007; # much more precision
复数

have also there own immutable value type . 1+2i
my $c = 5.2+1e42i;
say $c.WHAT; # returns 'Complex', which is the classname of the value object
版本号 v1.2.3 # okay
v1.2.* # okay, wildcard version
v1.2.3+ # okay, wildcard version
v1.2.3beta # illegal
Version('1.2.3beta') # okay
格式化
perl 方法


The .perl method returns a string that arranges any set of values in almost the same format, as the would be defined it source code. It's a built in Data::Dumper (pretty printer). @a.perl # evals to: [1, 2, 3, 4, 5]
%h.perl # evals to: {"akey" => "avalue", "bkey" => "bvalue"}


This works with data of any nesting depth. 漂亮的格式： .fmt 方法

它是sprinf 的小兄弟，作为变量的方法使用。如果那是一个键值对儿或列表，它当然使用跟 sprinf 同样的语法和方式将几个值格式化。 $result = '5.123456789';
say $result .fmt ('%.2f');  # "5.12\n"
@nr = 1..5;
say @nr.fmt("+%d."); # " +1. +2.+3.+4.+5.\n"
say @nr.fmt("%d.",','); # "1.,2.,3.,4.,5.\n"
say @nr.fmt("%d %d"); # ERROR

.fmt 还有第二个参数，用于指定分隔符： %p6c = sorear => 'niecza', fglock => 'perlito';
say %p6c.fmt("%s!"); # "sorear!\nfglock!\n"
say %p6c.fmt("%s", ',' ); # "sorear , fglock!\n"
say %p6c.fmt("%s:%s"); # "sorear:niecza\nfglock:perlito\n"
say %p6c.fmt("%s:%s",); # "sorear:niecza,fglock:perlito\n"
say %p6c.fmt("%s %s %s"); # ERROR









Upload Files

Click "Browse" to find the file you want to upload. When you click "Upload file" your file will be uploaded and added to the list of attachments for this page.

Maximum file size: 50MB


 
 
Add a link to the attachment at the top of the page? Images will appear in the page.
Expand zip archive and attach individual files to the page

 Done


 

 File Name Author Date Uploaded Size


 Close


 Delete Selected Files



Save Page As

Enter a meaningful and distinctive title for your page.

Page Title:

Tip: You'll be able to find this page later by using the title you choose.

 Cancel

 Save



Page Already Exists

There is already a page named XXX . Would you like to:

Save with a different name:

Save the page with the name " XXX "

Append your text to the bottom of the existing page named: " XXX "

 Cancel

 Ok



Upload Files

Click "Browse" to find the file you want to upload. When you click "Add file," this file will be added to the list of attachments for this page, and uploaded when you save the page.


 
 
Add a link to this attachment at the top of the page? Images will appear in the page.
Expand zip archive and attach individual files to the page?

 Done


 Add file

 
<span class="st-attachmentsqueue-listlabel">${ loc('Files To upload:') } </span> {var lastIndex = queue.length-1} {for file in queue} <span class="st-attachmentsqueue-filelist-name">${file}  <a href="#" onclick="javascript:window.EditQueue.remove_index(${file_index}); return false" title="${ loc('Remove [_1] from the queue', file) }" class="st-attachmentsqueue-filelist-delete">[x]</a> {if file_index != lastIndex}, {/if} {/for}

Add Tags

Enter a tag and click "Add tag". The tag will be saved when you save the page.


Tag: 
 
Suggestions:

 Done


 Add tag

 
Tags to apply: {var lastIndex = queue.length-1} {for tag in queue} <span class="st-tagqueue-taglist-name">${tag} <a href="#" onclick="javascript:window.TagQueue.remove_index(${tag_index}); return false" title="Remove ${tag} from the queue" class="st-tagqueue-taglist-delete">[x]</a>{if tag_index != lastIndex}, {/if} {/for} {var lastIndex = matches.length-1} {for t in matches} <a href="#" onclick="TagQueue.queue_tag('${t.name|escapespecial|quoter}'); return false" title="Add ${t.name} to page" class="st-tags-suggestion" >${t.name}</a>{if t_index != lastIndex}, {/if} {/for}