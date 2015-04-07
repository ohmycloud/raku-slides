Merry Christmas! December 25, 2009


On behalf of all the people that brought you this year’s Perl 6 Advent Calendar, I’d like to wish everyone out there a very  Merry Christmas!


Posted in  2009  |  5 Comments »
Day 24: The Perl 6 standard grammar December 24, 2009





We’ve now reached the end of this year’s advent series, what will be the gift in our last box? The door opens to reveal…the  Perl 6 grammar .

At first it might seem odd to cite a grammar as a significant component of a language. Obviously the syntax matters a lot to people writing programs in that language, but once a syntax has been designed, we simply use grammars to describe the syntax and build parsers, right?

Not in Perl 6, where language syntax is a dynamic thing — modifiable to accommodate new keywords and syntax not anticipated in the original design. Or, perhaps more accurately, Perl 6 explicitly anticipates and supports modules and applications changing the language’s syntax for their specific needs.  Defining custom operators  is just one example of a place where we change the language syntax itself, but Perl 6 also allows the dynamic addition of macros, new statement types, new sigils, and the like.

Thus a Perl 6 grammar and parser needs to not only parse the standard Perl 6 syntax, it must handle program-defined custom syntax as well. Language modifications must also be scoped, so that defining a new operator in one module doesn’t inadvertently change the interpretation of another module in unintended ways.

This is what the Perl 6 standard grammar achieves, and much of the effort that has gone into the Perl 6 specification for regexes and grammars ( Synopsis 5 ) has been just to make this sort of thing possible. I personally believe this is one of the key features that will enable Perl 6 to remain a viable language far into the future. (On the other hand, when I first read the designs for Perl 6 in detail, I had serious doubts as to whether this could in fact be achieved. It’s nice to see that it wasn’t an impossible dream.)

The expectation is that parsers for Perl 6 will themselves be written in Perl 6, and there are several examples already available. The “standard” or “reference” grammar and parser is  STD.pm ; Larry has been using this to refine the Perl 6 language specification and explore the impacts of various language constructs on the writing of Perl 6 programs.

Some parts of STD.pm are still evolving in response to implementation concerns; thus Rakudo Perl maintains  its own version of the language grammar  that works for its environment. Many of the ideas first explored by Rakudo often find their way back into the standard grammar. This is by design — our expectation is that the various grammar implementations will continue to converge over the course of the next year.

The key feature that jumps out from looking at the Perl 6 grammar is the use of  protoregexes . A protoregex allows multiple regexes to be combined into a single “category”. In a more traditional grammar, we might write:
    rule statement {
        | <if_statement>
        | <while_statement>
        | <for_statement>
        | <expr>
    }
    rule if_statement    { 'if' <expr> <statement> }
    rule while_statement { 'while' <expr> <statement> }
    rule for_statement   { 'for' '(' <expr> ';' <expr> ';' <expr> ')' <stmt> }

With a protoregex, we’d write it as follows:
    proto token statement { <...> }
    rule statement:sym<if>    { 'if' <expr> <statement> }
    rule statement:sym<while> { 'while' <expr> <statement> }
    rule statement:sym<for>
        { 'for' '(' <expr> ';' <expr> ';' <expr> ')' <stmt> }
    rule statement:sym<expr>  { <expr> }

We’re still saying that a <statement> matches any of the listed statement constructs, but the protoregex version is much easier to extend. In the non-protoregex version above, adding a new statement construct (such as “repeat..until”) would require rewriting the “rule statement” declaration in its entirety to include the new statement construct. But with a protoregex, we can simply declare an additional rule:
    rule statement:sym<repeat> { 'repeat' <stmt> 'until' <expr> }

This newly declared rule is automatically added as one of the candidates to the <statement> protoregex. All of this works for derived languages as well:
    grammar MyNewGrammar is BaseGrammar {
        rule statement:sym<repeat> { 'repeat' <stmt> 'until' <expr> }
    }

Thus MyGrammar parses everything the same as BaseGrammar, with the additional definition of the  repeat..until  statement construct.

The ability to dynamically replace the existing grammar with a new one that has different parse semantics is at the heart of Perl 6′s operator overloading, macro handling, and other syntax modifying features. Unlike source filters, this provides a much more nuanced approach to declaring new language constructs.

Another significant component of the standard grammar is its devotion to providing useful error diagnostics when an error is encountered. Instead of simply saying “an error occurred here”, it offers suggestions about what might have been intended instead, and places where it thinks the programmer may have been confused. It also does significant work to catch constructs that have changed between Perl 5 and Perl 6, to assist people with migration. For example, if someone writes an “unless” statement with an “else” block, the parser responds with
    unless does not take "else" in Perl 6; please rewrite using "if"

Or, if a program appears to contain the question-mark-colon (?:) ternary operator, the parser says
    Unsupported use of "?:"; in Perl 6 please use "??!!"

 

In late October of this year, Rakudo started a significant refactor in a new branch (called “ng”) that makes use of protoregexes and the many other features of the STD.pm grammar. We still have a short way to continue before this new branch can become the official released version of Rakudo, but we expect that to happen in the January 2010 release. Already this conversion has enabled us to finally add long-awaited features in Rakudo, including dynamic generation of metaoperators , lazy list handling, lexical context handling, and the like.

With Rakudo’s conversion to following STD.pm for its grammar, we’re very much on track for the Rakudo Star release in April 2010. While we expect that Rakudo Star won’t be a complete implementation of Perl 6, it will be sufficiently advanced and usable for a wide variety of applications. We’ve been quickly resolving the critical items listed in the Rakudo Star  ROADMAP , and over the next couple of months will be focusing on improved error reporting (like STD.pm) and distribution / packaging issues.

…and this concludes the Perl 6 Advent series for December 2009. We hope that you’ve enjoyed reading the articles at least as much as we’ve enjoyed writing them, and we appreciate the many comments that people have made about the posts. We also hope to have conveyed our sense that many useful parts of Perl 6 are available now for experimentation, and that we’re well on the way to making them available in 2010 for a wider variety of applications. Indeed, we have high hopes and expectations for the entire Perl family in 2010 — it promises to be an exciting time for us all.

Happy holidays, and best wishes for the new year.




Posted in  2009  |  2 Comments »
Day 23: Lazy fruits from the gather of Eden December 23, 2009


Today’s gift is a construct not often seen in other languages. It’s an iterator builder! And it’s called  gather .

But first, let’s try a bit of historical perspective. Many Perl people know their  map ,  grep  and  sort , convenient functions to carry out simple list transformations, filterings and rankings without having to resort to  for loops.
my @squares = map { $_ * $_ }, @numbers;
my @primes  = grep { is-prime($_) }, @numbers;

The  map  and  grep  constructs are especially powerful once we get comfortable with chaining them:
my @children-of-single-moms =
    map  {  .children },
    grep { !.is-married },
    grep {  .gender == FEMALE },
         @citizens;

(Note that  .children  may return one child, a list of several children or an empty list.  map  has a flattening influence on the lists thus produced, so the final result is a flat list of children.)

The chaining of  map  and  sort  gave rise to the famous  Schwartzian transform , a Perl 5 caching idiom for when the thing being sorted on is computationally expensive:
my @files-by-modification-date =
    map  { .[0] },                # deconstruct
    sort { $^a[1] <=> $^b[1] },
    map  { [$_, $_ ~~ :M] },      # compute and construct
         @files;

It’s unfortunate that the functional paradigm puts the steps in reverse order of processing. The proposed pipe syntax, notably the  ==> , would solve that. But it’s not implemented in Rakudo yet, only described in S03.

Anyway, if you’ve read the post from  day 20 , you know that the Schwartzian transform is built into  sort  nowadays:
my @files-by-modification-date =
    sort { $_ ~~ :M },
    @files;

So that’s, you know,  coming along .

Now, what about this  gather  construct? Well, it’s a kind of generalization of  map  and  grep .
sub mymap(&transform, @list) {
    gather for @list {
        take transform($_);
    }
};
 
sub mygrep(&condition, @list) {
    gather for @list {
        take $_ if condition($_);
    }
};

(The real  map  can swallow several argument at a time, making it more powerful than the  &mymap  above.)

Just to be clear about what happens:  gather  signals that within the subsequent block, we’ll be building a list. Each  take  adds an element to the list. You could think of it as  push ing to an anonymous array if you want:
my @result = gather { take $_ for 5..7 }; # this...
 
my @result;
push @result, $_ for 5..7; # ...is the same as this

Which brings us to the first property of  gather : it’s the construct you can use for building lists when  map ,  grep  and  sort  aren’t sufficient. Of course, there’s no need to reinvent those constructions… but the fact that you can do that, or roll your own special variants, is kinda nice.
sub incremental-concat(@list) {
  my $string-accumulator = "";
  gather for @list {
    # RAKUDO: The ~() is a workaround for [perl #62178]
    take ~($string-accumulator ~= $_);
  }
};
 
say incremental-concat(<a b c>).perl; # ["a", "ab", "abc"]

The above is nicer than using  map , since we need to manage the $string-accumulator  between iterations.

(Implementing  &incremental-concat  by hand is silly in an implementation which implements the  [\~]  operator. Just a short announcement to people who want to keep track of the extent to which Perl 6 is channeling APL. Rakudo doesn’t yet, though.)

The second property of  gather  is that while the  take  calls (of course) have to occur within the scope of a  gather  block, they do not necessarily have to occur in the  lexical  scope, only the  dynamic  scope. For those unfamiliar with the distinction, I think an example explains it best:
sub traverse-tree-inorder(Tree $t) {
  traverse-tree-inorder($t.left) if $t.left;
  take transform($t);
  traverse-tree-inorder($t.right) if $t.right;
}
 
my $tree = ...;
my @all-nodes = gather traverse-tree-inorder($tree);

See what’s happening here? We wrap the call to  &traverse-tree-inorder  in a  gather  statement. The statement itself doesn’t  lexically contain any  take  calls, but the called subroutine does, and the  take  in there remembers that it’s in a gather context. That’s what makes the gather  context dynamic rather than lexical.

Just to hammer in the point,  traverse-tree-inorder  does lexical recursion on a tree structure, and no matter how far down the call stack we find ourselves, the values passed to  take  find their way back into the same anonymous array, rooted in the  gather  around the original call. It’s as if the anonymous array were implicitly passed around for us automatically as invisible arguments. Another way to view it is that the  gather  mode works orthogonally to the call stack, essentially not caring about how many calls down it is.

Should we be unfortunate enough to do a  take  outside of any  gather block, we’ll get a warning at runtime.

I’ve saved the best till last: the third property of  gather : it’s  lazy .

What does “lazy” mean here? Well, to take the above tree-traversing code as an example: when the assignment to  @all-nodes  has executed, the tree hasn’t yet been traversed. Only when you access the first element of the array,  @all-nodes[0] , does the traversal start. And it stops right after it finds the leftmost leaf node. Access @all-nodes[1] , and the traversal will resume from where it left off, run just enough to find the second node in the traversal, and then stop.

In short, the code within the gather block starts and stops in such a way that it never does more work than you’ve asked it to do. That’s lazy.

It’s essentially a model of  delayed execution . Perl 6 promises to run the code inside your gather block, but only if it turns out that you actually need the information. Operationally, you can think of it as a separate thread that starts and stops, always doing the smallest possible amount of work to keep the main thread satisfied. But under the hood in a given implementation, it’s likely implemented by continuations — or, failing that, by painful, complicated cheating.

Now here’s the thing: most any array in Perl 6 has the lazy behavior by default, and things like reading all lines from a file are lazy by default, and not only  can   map  and  grep  be implemented using  gather ; it turns out that they actually  are , too. So  map  and  grep  are  also  lazy.

Now, it’s nice to know that values aren’t unnecessarily generated when you’re doing calculations with arrays… but the  really  nice thing is that lazy arrays open up the door for  stream-based programming  and, by extension, infinite arrays.

Unfortunately, laziness hasn’t landed in Rakudo yet. We’re nearly there though, so I don’t feel too bad dangling these examples in front of you, even though they will currently cause Rakudo to spin the fans of your computer and nothing more:
my @natural-numbers = 0 .. Inf;
 
my @even-numbers  = 0, 2 ... *;    # arithmetic seq
my @odd-numbers   = 1, 3 ... *;
my @powers-of-two = 1, 2, 4 ... *; # geometric seq
 
my @squares-of-odd-numbers = map { $_ * $_ }, @odd-numbers;
 
sub enumerate-positive-rationals() { # with duplicates, but still
  take 1;
  for 1..Inf -> $total {
    for 1..^$total Z reverse(1..^$total) -> $numerator, $denominator {
      take $numerator / $denominator;
    }
  }
}
 
sub enumerate-all-rationals() {
  map { $_, -$_ }, enumerate-positive-rationals();
}
 
sub fibonacci() {
  gather {
    take 0;
    my ($last, $this) = 0, 1;
    loop { # infinitely!
      take $this;
      ($last, $this) = $this, $last + $this;
    }
  }
}
say fibonacci[10]; # 55
 
# Merge two sorted (potentially infinite) arrays
sub merge(@a, @b) {
  !@a && !@b ?? () !!
  !@a        ?? @b !!
         !@b ?? @a !!
  (@a[0] < @b[0] ?? @a.shift !! @b.shift, merge(@a, @b))
}
 
sub hamming-sequence() # 2**a * 3**b * 5**c, where { all(a,b,c) >= 0 }
  gather {
    take 1;
    take $_ for
        merge( (map { 2 * $_ } hamming-sequence()),
               merge( (map { 3 * $_ }, hamming-sequence()),
                      (map { 5 * $_ }, hamming-sequence()) ));
  }
}

(That last subroutine is a Perl 6 solution to the Hamming problem, described in  section 6.4  of mjd++’s Higher Order Perl. A seriously cool book, by the way. It builds iterators from scratch; we just use  gather for the same result.)

Today’s obfu award goes to  David Brunton , who has written a Perl 6 tweet which draws a  rule #30 cellular automaton , which also happens to look like a Christmas tree.
$ perl6 -e 'my %r=[^8]>>.fmt("%03b") Z (0,1,1,1,1,0,0,0);\
say <. X>[my@i=0 xx 9,1,0 xx 9];\
for ^9 {say <. X>[@i=map {%r{@i[($_-1)%19,$_,($_+1)%19].join}},^19]};'
.........X.........
........XXX........
.......XX..X.......
......XX.XXXX......
.....XX..X...X.....
....XX.XXXX.XXX....
...XX..X....X..X...
..XX.XXXX..XXXXXX..
.XX..X...XXX.....X.
XX.XXXX.XX..X...XXX


Posted in  2009  |  9 Comments »
Day 22: Operator Overloading December 22, 2009


Today’s gift is something I complain about a lot. Not because it’s a problem in Perl 6, but because Java doesn’t have it: operator overloading, and the definition of new operators.

Perl 6 makes it easy to overload existing operators, and to define new ones. Operators are simply specially-named multi subs, and the standard multi-dispatch rules are used to determine what the most appropriate implementation to call is.

A common example, which many of you may have seen before, is the definition of a factorial operator which mimics mathematical notation:
multi sub postfix:<!>(Int $n) {
  [*] 1..$n;
}
 
say 3!;

The naming convention for operators is quite straightforward. The first part of the name is the syntactic category, which is  prefix ,  postfix , infix ,  circumfix  or  postcircumfix . After the colon is an angle bracket quote structure (the same kind of thing often seen constructing lists or accessing hash keys in Perl 6) which provides the actual operator. In the case of the circumfix operator categories, this should be a pair of bracketing characters, but all other operators take a single symbol which can have multiple characters in it. In the example above, we define a postfix operator  !  which functions on an integer argument.

You can exercise further control over the operator’s parsing by adding traits to the definition, such as  tighter ,  equiv  and  looser , which let you specify the operator’s precedence in relationship to operators which have already been defined. Unfortunately, at the time of writing this is not supported in Rakudo so we will not consider it further today.

If you define an operator which already exists, the new definition simply gets added to the set of multi subs already defined for that operator. For example, we can define a custom class, and then specify that they can be added together using a custom  infix:<+> :
class PieceOfString {
  has Int $.length;
}
 
multi sub infix:<+>(PieceOfString $lhs, PieceOfString $rhs) {
  PieceOfString.new(:length($lhs.length + $rhs.length));
}

Obviously, real-world examples tend to be rather more complex than this, involving multiple member variables. We could also check our pieces of string for equality:
multi sub infix:<==>(PieceOfString $lhs, PieceOfString $rhs --> Bool) {
  $lhs.length == $rhs.length;
}

In which case we’re really just redispatching to one of the built-in variants of  infix:<==> . At the time of writing this override of  == doesn’t work properly in Rakudo.

One thing you might want to do which you probably shouldn’t do with operator overloading is operating things like  prefix:<~> , the stringification operator. Why not? Well, if you do that, you won’t catch every conversion to  Str . Instead, you should give your class a custom Str  method, which is what would usually do the work:
use MONKEY_TYPING;
 
augment class PieceOfString {
  method Str {
    '-' x $.length;
  }
}

This will be called by the default definition of  prefix:<~> . Methods which have the names of types are used as type conversions throughout Perl 6, and you may commonly wish to provide  Str  and Num  for your custom types where it makes sense to do so.

Thus overriding  prefix:<~>  makes little sense, unless you actually want to change its meaning for your type. This is not to be recommended, as programmers in C++ and other languages with operator overloading will be aware. Changing the conventional semantics of an operator for a custom type is not usually something which ends well, leads to confusion in the users of your library and may result in some unpleasant bugs. After all, who knows what operator behaviour the standard container types are expecting? Trample on that, and you could be in a great deal of trouble.

New semantics are best left for new operators, and fortunately, as we have seen, Perl 6 allows you to do just that. Because Perl 6 source code is in Unicode, there are a great variety of characters available for use as operators. Most of them are impossible to type, so it is expected that multicharacter ASCII operators will be the most common new operators. For an example of a Unicode snowman operator, refer back to the end of  Day 17 .


Posted in  2009  |  11 Comments »
Day 21, Grammars and Actions December 21, 2009


In today’s post, we’re going to cover several topics, but primarily grammars. I’d like to use an example inspired by some Perl 5 code I wrote for work recently.

So we have a bunch of text that we want to process and deal with. Perl’s supposed to be great at that, right? To be precise, let’s talk about the following text, describing some questions and their answers:
pickmany: Which items are food?
    ac: Rice
    ac: Orange
    ac: Mushroom
    ai: Shoes
pickone: Which item is a color?
    ac: Orange
    ai: Shoes
    ai: Mushroom
    ai: Rice

To parse this in Perl 6, I’ll start by defining a Grammar. A Grammar is a special type of namespace for holding regular expressions. We’ll also define several named expressions to split up our parsing a bit.
grammar Question::Grammar {
    token TOP {
        \n*
        <question>+
    }
    token question {
        <header>
        <answer>+
    }
    token header {
        ^^ $<type>=['pickone'|'pickmany'] ':' \s+ $<text>=[\N*] \n
    }
    token answer {
        ^^ \s+ $<correct>=['ac'|'ai'] ':' \s+ $<text>=[\N*] \n
    }
}

First, a brief overview of what’s going on here, from a standpoint that assumes you’re familiar with regular expressions at least a little. By default in Perl 6 grammars, whitespace is ignored and matches occur over the entire string. It’s like the /x and /s Perl 5 modifiers are turned on. TOP is the regex that’s called if we try to match against the entire grammar as a whole.

‘token’ is one of three identifiers used to declare a regex, including ‘regex’, ‘token’, and ‘rule’. ‘regex’ is the plain, unmodified version, and the second two just enable some additional options. ‘token’ disables backtracking, and ‘rule’ both disables backtracking and causes whitespace in the regex to match literal whitespace in the matched text. We won’t use ‘rule’s here.

The <foo> syntax is what’s used to call another named regex. ‘^^’ is used to match the beginning of a line, as opposed to lone ‘^’, which matches the beginning of the entire matched text. The square brackets, [], are non-capturing grouping, like (?: ) in Perl 5 regular expressions.

The = syntax is used to assign the RHS into the name specified on the LHS. You’ll see what I mean later when we use the result of this regex.

Let’s see what we get if we try matching against that grammar and printing the result we get back:
my $text = Q {
pickmany: Which items are food?
    ac: Rice
    ac: Orange
    ac: Mushroom
    ai: Shoes
pickone: Which item is a color?
    ac: Orange
    ai: Shoes
    ai: Mushroom
    ai: Rice
};
my $match = Question::Grammar.parse($text);
say $match.perl;

Try running that yourself if you like. It produces 232 lines of output, which is a bit too much to include here. Let’s pull out just one part, the questions.
# Print the question
for $match<question>.flat -> $q {
    say $q<header><text>;
}
We need to use .flat, because $match<question> is an array held in a scalar container.

As a reminder, postfix <> is the auto-quoting named lookup syntax. That’s equivalent to the following, but a little easier to type, and also easier to read:
# Print the question
for $match{'question'}.flat -> $q {
    say $q{'header'}{'text'};
}

So we can see that a match object contains named items as hash values, and repetitions are stored as an array. If we had any positional captures, made with parens just like Perl 5: (), they would have been accessed through the positional interface, with postfix [], like an array.

The next step is to make some classes and then populate them from the match object. First some class definitions:
class Question::Answer {
    has $.text is rw;
    has Bool $.correct is rw;
}
class Question {
    has $.text is rw;
    has $.type is rw;
    has Question::Answer @.answers is rw;
}

Building Question objects out of the match object isn’t that bad, but it’s still not pretty:
my @questions = $match<question>.map: {
    Question.new(
        text    => ~$_<header><text>,
        type    => ~$_<header><type>,
        answers => $_<answer>.map: {
            Question::Answer.new(
                text => ~$_<text>,
                correct => ~$_<correct> eq 'ac',
            )
        },
    );
};

Remembering that any repetition in the regex is reflected as an array in the match object, we map over the <question> attribute, building a Question object for each. Each <question> match has an array of <answer> matches, so we map over those too, building a list of Question::Answer objects for each one. We are stringifying the values to have strings in our array, rather than a bunch of Match objects.

As you can guess, this approach doesn’t scale up very well. A much nicer way to do it is to build the objects as we go. The method used to do this is to pass an object as the :action argument to the .parse() method on the Grammar. The parsing engine will then call methods on that object with the same name as the regexes being parsed, with the evaluated match object for the rule passed as an argument. If the method calls ‘make()’ during execution, the argument to ‘make()’ is set as the ‘.ast’ (for “Abstract Syntax Tree”) attribute of the match object.

Okay, that’s a fairly abstract description. Let’s see some real code. We need to make a class with methods named the same as those three regexes:
class Question::Actions {
    method TOP($/) {
        make $<question>».ast;
    }
    method question($/) {
        make Question.new(
            text => ~$<header><text>,
            type => ~$<header><type>,
            answers => $<answer>».ast,
        );
    }
    method answer($/) {
        make Question::Answer.new(
            correct => ~$<correct> eq 'ac',
            text => ~$<text>,
        );
    }
}

$/ is the traditional name for match objects, and it’s as special as $_, in that there’s special syntax that accesses its attributes. Named and Positional access without a variable ($<foo> and $[1]) are translated into access to $/ ($/<foo> and $/[1]). It’s only a one-character difference, but it saves some visual noise, and helps it fill a semantic space similar to $1, $2, $3, etc. in Perl 5.

In the ‘TOP’ method, we just use a hyperoperator method call to make a list of the .ast attributes of each item in $<question>. Again, whenever we call ‘make’ in an action method, we’re setting something as the ‘.ast’ attribute of the match object that gets returned, so this is just fetching whatever we ‘make’ in the ‘question’ method.

In the ‘question’ method, we construct a new Question object, populating its attributes from the match object, and specifically set its ‘answers’ attribute as the list of objects we produce in each call to the ‘answer’ regex from the current parse of ‘question’.

In the ‘answer’ method, we do the same thing, setting the ‘correct’ attribute to the result of a comparison, so that it satisfies the ‘Bool’ type constraint on the attribute.

So, again, to use this in a parse, we instantiate this new class and pass the object as the :action parameter to the ‘.parse’ method of the grammar, and then we fetch the constructed object from the ‘.ast’ attribute of the match object it returns:
my $actions = Question::Actions.new();
my @questions = Question::Grammar.parse($text, :actions($actions)).ast.flat;
We need .flat for the same reason as before.

Now we can inspect the created objects to see that everything went according to plan:
for @questions -> $q {
    say $q.text;
    for $q.answers.kv -> $i, $a {
        say "    $i) {$a.text}";
    }
}

To finish this post off, let’s add a method to Question to ask the question, fetch an answer, and grade the question.

Let’s start by printing out a representation of the question, its answers, and a prompt:
    method ask {
        my %hints = (
            pickmany => "Choose all that are true",
            pickone => "Choose the one item that is correct",
        );
        say "\n{%hints{$.type}}\n";
        say $.text;
        for @.answers.kv -> $i, $a {
            say "$i) {$a.text}";
        }
        print "> ";

Next, let’s fetch a line from STDIN and pull out the digits.
        my $line = $*IN.get();
        my @answers = $line.comb(/<digit>+/)>>.Int.sort;

‘comb’ is kind of the opposite of ‘split’, in that we specify what we want to keep instead of what we want to discard. The advantage here is that we don’t have to choose a delimiter. The user can enter “1 2 3″, “1,2,3″, or even “1, 2, and 3″. We then use a hyperoperator method call to generate an array of Integers from the array of Matches, and then sort it.

Next, let’s generate a corresponding array of all of the correct answer indexes, and then compare them to determine correctness of the response. This isn’t the only way to do it, merely the first that occurred to me. :)
        my @correct = @.answers.kv.map({ $^value.correct ?? $^key !! () });
        if @correct ~~ @answers {
            say "Yay, you got it right!";
            return 1;
        }
        else {
            say "Oops... you got it wrong. :(";
            return 0;
        }
    }

Let’s call it on each question and collect the results by mapping over our new method:
my @results = @questions.map(*.ask);
say "\nFinal score: " ~ [+] @results;

You’ll get results like this:
[sweeks@kupo ~]$ perl6 /tmp/questions.pl
 
Choose all that are true, separated by spaces
 
Which items are food?
0) Rice
1) Orange
2) Mushroom
3) Shoes
> 0 1 2
Yay, you got it right!
 
Choose the one item that is correct
 
Which item is a color?
0) Orange
1) Shoes
2) Mushroom
3) Rice
> 1
Oops... you got it wrong. :(
 
Final score: 1

With everything put together, here’s the full program we’ve written:
﻿﻿﻿﻿﻿
class Question::Answer {
    has $.text is rw;
    has Bool $.correct is rw;
}
class Question {
    has $.text is rw;
    has $.type is rw;
    has Question::Answer @.answers is rw;
    method ask {
        my %hints = (
            pickmany => "Choose all that are true",
            pickone => "Choose the one item that is correct",
        );
        say "\n{%hints{$.type}}\n";
        say $.text;
        for @.answers.kv -> $i, $a {
            say "$i) {$a.text}";
        }
        print "> ";
        my $line = $*IN.get();
        my @answers = $line.comb(/<digit>+/)>>.Int.sort;
        my @correct = @.answers.kv.map({ $^value.correct ?? $^key !! () });
        if @correct ~~ @answers {
            say "Yay, you got it right!";
            return 1;
        } else {
            say "Oops... you got it wrong. :(";
            return 0;
        }
    }
}
 

grammar Question::Grammar {
    token TOP {
        \n*
        <question>+
    }
    token question {
        <header>
        <answer>+
    }
    token header {
        ^^ $<type>=['pickone'|'pickmany'] ':' \s+ $<text>=[\N*] \n
    }
    token answer {
        ^^ \s+ $<correct>=['ac'|'ai'] ':' \s+ $<text>=[\N*] \n
    }
}
 
class Question::Actions {
    method TOP($/) {
        make $<question>».ast;
    }
    method question($/) {
        make Question.new(
            text => ~$<header><text>,
            type => ~$<header><type>,
            answers => $<answer>».ast,
        );
    }
    method answer($/) {
        make Question::Answer.new(
            correct => ~$<correct> eq 'ac',
            text => ~$<text>,
        );
    }
}
 
my $text = Q {
pickmany: Which items are food?
    ac: Rice
    ac: Orange
    ac: Mushroom
    ai: Shoes
pickone: Which item is a color?
    ac: Orange
    ai: Shoes
    ai: Mushroom
    ai: Rice
};
 
my $actions = Question::Actions.new();
my @questions = Question::Grammar.parse($text, :action($actions)).ast.flat;
my @results = @questions.map(*.ask);
 
say "\nFinal score: " ~ [+] @results;




Posted in  2009  |  7 Comments »
Day 20: Little big things December 20, 2009


Today we look at some little big things…

There are many simple yet powerful ideas baked-in to Perl 6 that allow many wonderful things. One of these simple ideas is  introspection . Introspection is the act of observing yourself. For a programming language this means that there is some mechanism by which you, the programmer, can express questions about the language in the language itself. Perl 6 is a language that supports introspection in several ways. For instance, there are methods on object instances that tell to what class the object belongs, there are methods on classes to tell what methods are available to the class, etc.

There are even methods on subroutines to ask what the subroutine’s name is:
    sub foo (Int $i, @stuff, $blah = 5) { ... }
    say &foo.name;      # outputs "foo"

Now that may seem slightly pointless, but keep in mind that subroutines can be assigned to scalars or aliased to other names or may be generated on-the-fly, so it’s name may not be immediately obvious by glancing at the code.
    my $bar = &foo;
    # ... and then much later ...
    say $bar.name;      # What was this subroutine's name again?

Here are a few other items you can introspect on subroutines.
    say &foo.signature.perl;        # What does the subroutine signature look like?
    say &foo.count;                 # How many arguments does this subroutine take?
    say &foo.arity;                 # How many are required?

That last thing we introspected from the subroutine was its  arity ; the number of required arguments for a subroutine/method. Because Perl can now figure that information out for itself via introspection, interesting new things are available that weren’t easy or were even non-existent before. For instance, in Perl 5, map blocks take a list of items one at a time and transform each into one or more new items to create a new list, but because Perl 6 knows how many arguments are expected, it can take as many as needed.
    my @foo = map -> $x, $y { ... },  @bar;             # take @bar two at a time to generate @foo
    my @coords = map -> $x, $y, $z { ... }, @numbers;   # take @numbers three at a time

Another benefit of this ability to introspect the number of parameters a subroutine requires is a nicer mechanism for sorting arrays by some other criteria than the default string comparison. The  sort  method on arrays takes an optional subroutine to act as the comparator and ordinarily this subroutine takes 2 parameters–the items of the array to be compared. So, if you were modeling people and their karma, and wanted to sort an array of people by karma, you’d write something similar to this:
#!/usr/bin/perl6
 
use v6;
 
class Person {
    has $.name;
    has $.karma;
 
    method Str { return "$.name ($.karma)" }  # for pretty stringy output
}
 
my @names = <Jonathan Larry Scott Patrick Carl Moritz Will Stephen>;
 
my @people = map { Person.new(name => $_, karma => (rand * 20).Int) }, @names;
 
.say for @people.sort: { $^a.karma <=> $^b.karma };

But!  Since Perl 6 can introspect the comparator, we’ve got another option now. By passing a subroutine that only takes 1 parameter, Perl 6 can know to automatically do the equivalent of a  Schwartzian Transform . The above sort can now be written like so:
    .say for @people.sort: { $^a.karma };

But wait! There’s another small syntactic advantage now that there’s only one parameter to the subroutine: implicit aliasing to  $_ . So we can eliminate the auto-declared placeholder variable entirely:
    .say for @people.sort: { .karma };

What this does is call the  .karma  method on each element of the array one time (rather than twice for each comparison as would be done with the normal comparator) and then order the array based on the results.

Another little big thing is that Perl 6 has a built-in  type system . You may have noticed in the karma example above that I didn’t specify that numeric comparison should be used. That’s because perl is smart enough to figure out that we’re using numbers. If I had wanted to force the issue, I could have used a prefix  +  or  ~ :
    .say for @people.sort: { +.karma };     # sort numerically
    .say for @people.sort: { ~.karma };     # sort stringily

One place this is particularly handy is with the  .min  and  .max methods. These methods also take a subroutine to set user-defined criteria for the ordering of elements:
    say @people.min: { +.karma }         # all numbers, so numeric comparison
    say @people.max: { ~.name }         # all strings, so string comparison

If you read yesterday’s advent post, you’ll note that there is another way to write these last few examples using a  Whatever :
    .say for @people.sort: *.karma;
    say @values.min: +*.karma;
    say @values.max: ~*.name;

Which is another little big thing in Perl 6. Be sure to check out  the other advent entries  for even more little big things


Posted in  2009  |  Leave a Comment »
Day 19: Whatever December 19, 2009


Opening the door to today’s present, you find… Whatever. Yes, Whatever  is a type in Perl 6, and it stands for whatever it makes sense in the context it appears in.

Examples:
1..*                 # infinite range
my @x = <a b c d e>;
say @x[*-2]          # indexing from the back of the array
                     # returns 'd'
say @x.map: * ~ 'A'; # concatenate A to whatever the
                     # thing is we pass to it
say @x.pick(*)       # randomly pick elements of @x
                     # until all are used up

So how does this magic work?

Some of these uses are easy to see: A  *  in term position produces a Whatever  object, and some builtins (like  List.pick ) know what to do with it.

The  in term position  might need some more explanation: Perl 6 parses predictively; when the compiler reads a file, it always knows whether to expect a term or an operator:
say  2 + 4
|    | | |
|    | | + term (literal number)
|    | + operator (binary +)
|    +  term (literal number)
+ term (listop), which expects another term

So if you write
* * 2

it parses the first  *  as term, and the second one as an operator.

The line above generates a code block:  * * 2  is short for  -> $x { $x * 2 } . That’s a thing you can invoke like any other sub or block:
my $x = * * 2;
say $x(4);     # says 8

Likewise
say @x.map: * ~ 'A';

is a shortcut for
say @x.map: -> $x { $x ~ 'A' };

and
say @x.map: *.succ;

is a shortcut for
say @x.map: -> $x { $x.succ };

Whatever is also useful in sorting — for example, to sort a list numerically (a prefix ‘+’ means to obtain a numeric value of something):
@list.sort: +*

And to sort a list as strings (a prefix ‘~’ means to get the string value of something):
@list.sort: ~*

The Whatever-Star is very useful, but it also allows some  obfuscation ( explanation ).

The Whatever-Star was also an inspiration for the planned  Rakudo Star release . Because we know that release won’t be a complete implementation of Perl 6, we didn’t want to call it “1.0″. But other release numbers and tags also presented their own points of confusion. Finally it was decided to call it “Rakudo Whatever”, which then became “Rakudo Star”. (Our  detailed plans for Rakudo Star  are kept the Rakudo repository.)


Posted in  2009  |  6 Comments »
Day 18: Roles December 18, 2009


As the snow falls outside, we grab a glass of mulled wine – or maybe a cup of eggnog – to enjoy as we explore today’s exciting gift – roles!

Traditionally in object oriented programming, classes have taken on two tasks: instance management and re-use. Unfortunately, this can end up pulling classes in two directions: re-use wants them to be small and minimal, but if they’re representing a complex entity then they need to support all of the bits it needs. In Perl 6, classes retain the task of instance management. Re-use falls to roles.

So what does a role look like? Imagine that we are building up a bunch of classes that represent different types of product. Some of them will have various bits of data and functionality in common. For example, we may have a BatteryPower role.

 role BatteryPower {
      has $.battery-type;
      has $.batteries-included;
      method find-power-accessories() {
          return ProductSearch::find($.battery-type);
      }
 }


At first glance, this looks a lot like a class: it has attributes and methods. However, we can not use a role on its own. Instead, we must compose it into a class, using the  does  keyword.

 class ElectricCar does BatteryPower {
      has $.manufacturer;
      has $.model;
 }


Composition takes the attributes and methods – including generated accessors – from the role and copies them into the class. From that point on, it is as if the attributes and methods had been declared in the class itself. Unlike with inheritance, where the parents are looked at during method dispatch, with roles there is no runtime link beyond the class knowing to say “yes” if asked if it does a particular role.

Where things get really interesting is when we start to compose multiple roles into the class. Suppose that we have another role, SocketPower.

 role SocketPower {
      has $.adapter-type;
      has $.min-voltage;
      has $.max-voltage;
      method find-power-accessories() {
          return ProductSearch::find($.adapter-type);
      }
 }


Our laptop computer can be plugged in to the socket or battery powered, so we decide to compose in both roles.

 class Laptop does BatteryPower does SocketPower {
 }


We try to run this and…BOOM! Compile time fail! Unlike with inheritance and mix-ins, role composition puts all of the roles on a level playing field. If both provide a method of the same name – in this case, find-power-accessories  – then the conflict will be detected as the class is being formed and you will be asked to resolve it. This can be done by supplying a method in our class that says what should be done.

 class Laptop does BatteryPower does SocketPower {
      method find-power-accessories() {
          my $ss = $.adapter-type ~ ' OR ' ~ $.battery-type;
          return ProductSearch::find($ss);
      }
 }


This is perhaps the most typical use of roles, but not the only one. Roles can also be taken and mixed in to an object (on a per-object basis, not a per-class basis) using the  does  and  but  operators, and if filled only with stub methods will act like interfaces in Java and C#. I won’t talk any more about those in this post, though: instead, I want to show you how roles are also Perl 6′s way of achieving generic programming, or parametric polymorphism.

Roles can also take parameters, which may be types or just values. For example, we may have a role that we apply to products that need to having a delivery cost calculated. However, we want to be able to provide alternative shipping calculation models, so we take a class that can handle the delivery calculation as a parameter to the role.

 role DeliveryCalculation[::Calculator] {
      has $.mass;
      has $.dimensions;
      method calculate($destination) {
          my $calc = Calculator.new(
              :$!mass,
              :$!dimensions
          );
          return $calc.delivery-to($destination);
      }
 }


Here, the ::Calculator in the square brackets after the role name indicates that we want to capture a type object and associate it with the name Calculator within the body of the role. We can then use that type object to call .new on it. Supposing we had written classes that did shipping calculations, such as ByDimension and ByMass, we could then write:

 class Furniture does DeliveryCalculation[ByDimension] {
 }
 class HeavyWater does DeliveryCalculation[ByMass] {
 }


In fact, when you declare a role with parameters, what goes in the square brackets is just a signature, and when you use a role what goes in the square brackets is just an argument list. Therefore you have the full power of Perl 6 signatures at your disposal. On top of that, roles are “multi” by default, so you can declare multiple roles with the same short name, but taking different types or numbers of parameters.

As well as being able to parametrize roles using the square bracket syntax, it is also possible to use the  of  keyword if each role takes just one parameter. Therefore, with these declarations:

 role Cup[::Contents] { }
 role Glass[::Contents] { }
 class EggNog { }
 class MulledWine { }


We may now write the following:

 my Cup of EggNog $mug = get_eggnog();
 my Glass of MulledWine $glass = get_wine();


You can even stack these up.

 role Tray[::ItemType] { }
 my Tray of Glass of MulledWine $valuable;


The last of these is just a more readable way of saying Tray[Glass[MulledWine]]. Cheers!


Posted in  2009  |  13 Comments »
Day 17: Making Snowmen December 17, 2009


I started out planning this day to be about complex numbers in Perl 6. But after I thought about it a bit, I decided that the complex number implementation is so straightforward explaining it would make a pretty boring gift. Instead, let’s explore the  Mandelbrot set , which will let us do a bit of complex math, look at pretty pictures, and hint at some advanced features of Perl 6, too.

Without further ado, here’s the first version of the script:

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
 26
 27
 28
 29
 30
 use v6;
  
 my $height = @*ARGS[0] // 31;
 my $width = $height;
 my $max_iterations = 50;
  
 my $upper-right = -2 + (5/4)i;
 my $lower-left = 1/2 - (5/4)i;
  
 sub mandel(Complex $c) {
      my $z = 0i;
      for ^$max_iterations {
          $z = $z * $z + $c;
          return 1 if ($z.abs > 2);
      }
      return 0;
 }
  
 sub subdivide($low, $high, $count) {
      (^$count).map({ $low + ($_ / ($count - 1)) * ($high - $low) });
 }
  
 say "P1";
 say "$width $height";
  
 for subdivide($upper-right.re, $lower-left.re, $height) -> $re {
      my @line = subdivide($re + ($upper-right.im)i, $re + 0i, ($width + 1) / 2).map({ mandel($_) });
      my $middle = @line.pop;
      (@line, $middle, @line.reverse).join(' ').say;
 }


So, lines 3-5 set up the pixel size of the graphic we will create.  @*ARGS is the new name of the command line argument array. The  //  operator is the new “defined” operator; it returns its first argument if that argument is defined, its second otherwise. In other words, line 3 sets $height  to be the first argument on the command line, or 31 if no such argument was set.  $width  is set equal to  $height  — the code is set up to generate a square graphic right now, but the variables are set apart for ease of future hacking.  $max_iterations  sets how many times the core Mandelbrot loop will iterate before it concludes a point is in the set. (Because we’re relying on the symmetry of the Mandelbrot set,  $width  must be odd.)

Lines 7-8 set the boundaries of our image on the complex plane. Introducing the imaginary component of a number is as simple as giving a number (or numeric expression) followed by  i ; this creates a number of the Complex type. Complex math works pretty much the way you would expect it to, for example, (as we see here) adding a Complex to an Int or a Rat yields another Complex.

Lines 10-17, then, are the core Mandelbrot function. To quickly explain, a complex number c is in the Mandrelbrot set if the equation  z = z * z + c  (with initial z of 0) stays bounded as we iterate the equation. This function implements exactly that in Perl 6. We set up a loop to iterate  $max_iterations  times. It is known that once  |z|  grows bigger than 2 it will not stay bounded, so we use  $z.abs > 2  to check for that condition. If it is true, we leave the loop early, returning 1 from the function to indicate the corresponding pixel should be black. If the loop finishes the number of iterations without exceeding those bounds, we return 0 for the color white.

Lines 19-21 are a simple helper function to return a list of a simple arithmetic progression from  $low  to  $high  with  $count  elements. Note that  $low  and  $high  have no specified type, so any type (or even pair of types) that the basic arithmetic operators will work on will work here. (In this script, we use it first for Num, and then for Complex.)

Lines 23-24 print the header for the header for a  PBM file .

Lines 26-30 print the actual image data.  $upper-right.re  is the real part of the complex number  $upper-right , and  $upper-right.im  is the imaginary part. The loop iterates over the real part of the range. Inside the loop, we subdivide again along the imaginary part to generate a list of the complex values we are interested in examining for one half of this row of the image. We then run that list through the mandel function using map, generating a list of 0s and 1s for half of the row, including the midpoint.

We do it this way because the Mandelbrot set is symmetric about the imaginary axis. So we then pop that midpoint, and make a new list which is the old list (minus the midpoint), the midpoint, and the list (minus the midpoint) reversed. We then feed that to  join  to make a string for the entire line, and finally say to print it out.

Note that doing it this way rotates the Mandelbrot set 90 degrees from the way it is normally displayed, giving us a lovely snowman shape:


With the current Rakudo, this is quite slow, and prone to crash randomly depending on the size of the image you are generating. However, imagine for a minute that happy future day when Rakudo is not only snappy, but handles  automatic hyperoperator threading  as well. At that point, it will be easy to make a parallel version of this script by changing the map call to a hyperoperator.

There’s only one tricky bit: there’s no way to have a hyperoperator call a normal sub. They only call class methods and operators. So, as a first approximation which works in current Rakudo, we can “augment” the Complex class to have a  .mandel .

 use MONKEY_TYPING;
  
 augment class Complex {
      method mandel() {
          my $z = 0i;
          for ^$max_iterations {
              $z = $z * $z + self;
              return 1 if ($z.abs > 2);
          }
          return 0;
      }
 }
  
 for subdivide($upper-right.re, $lower-left.re, $height) -> $re {
      my @line = subdivide($re + ($upper-right.im)i, $re + 0i, ($width + 1) / 2)>>.mandel;
      my $middle = @line.pop;
      (@line, $middle, @line.reverse).join(' ').say;
 }


The only difference to  mandel  is it is now a method, and the role of the former  $c  argument is taken by  self . Then instead of map({mandel($_)})  we use the hyperoperator.

As I said, this version works now. But personally, I’m a little uncomfortable augmenting an existing class like that; it feels dirty to my old C++ instincts. We can avoid it by turning mandel into an operator:

 sub postfix:<☃>(Complex $c) {
      my $z = 0i;
      for ^$max_iterations {
          $z = $z * $z + $c;
          return 1 if ($z.abs > 2);
      }
      return 0;
 }
  
 for subdivide($upper-right.re, $lower-left.re, $height) -> $re {
      my @line = subdivide($re + ($upper-right.im)i, $re + 0i, ($width + 1) / 2)>>☃;
      my $middle = @line.pop;
      (@line, $middle, @line.reverse).join(' ').say;
 }


This takes advantage of Perl 6′s Unicode ability to have a little fun, defining the operator using the snowman symbol. This ☃ operator works fine in Rakudo today, but alas the  >>☃  hyperoperator does not work yet.

Thanks to Moritz and TimToady for suggests and help with this code. Two versions of the script (one full color) are up at  github , if you’d like to play around with them.

Update (4/18/2010): I’ve ported the color version of the script at github to the latest version of Rakudo. It’s quite slow, and uses phenomenal amounts of memory, but unlike the previous version it is rock-solid stable. Here’s a  1001×1001 full color Mandelbrot set  that took it 14 hours and 6.4 GB of memory to compute.


Posted in  2009  |  4 Comments »
Day 16: We call it ‘the old switcheroo’ December 16, 2009


Another glorious day in Advent; another gift awaits us. It’s switch statements!

Well, the term for them is still “switch statement” in Perl 6, but the keyword has changed for linguistic reasons. It’s now  given , as in “given today’s weather”:
given $weather {
  when 'sunny'  { say 'Aah! ☀'                    }
  when 'cloudy' { say 'Meh. ☁'                    }
  when 'rainy'  { say 'Where is my umbrella? ☂'   }
  when 'snowy'  { say 'Yippie! ☃'                 }
  default       { say 'Looks like any other day.' }
}

Here’s a minimal explanation of the semantics, just to get us started: in the above example, the contents of the variable  $weather  is tested against the strings  'sunny' ,  'cloudy' ,  'rainy' , and  'snowy' , one after the other. If either of them matches, the corresponding block runs. If none matches, the  default  block triggers instead.

Not so different from switch statements in other languages, in other words. (But wait!) We’ll note in passing that the  when  blocks don’t automatically fall through, so if you have several conditions which would match, only the first one will run:
given $probability {
  when     1.00 { say 'A certainty'   }
  when * > 0.75 { say 'Quite likely'  }
  when * > 0.50 { say 'Likely'        }
  when * > 0.25 { say 'Unlikely'      }
  when * > 0.00 { say 'Very unlikely' }
  when     0.00 { say 'Fat chance'  }
}

So if you have a  $probability  of  0.80 , the above code will print Quite likely , but not  Likely ,  Unlikely  etc. (In the cases when you want to “fall through” from a  when  block, you can end it with the keyword  continue .) ( Update:  after spec discussions that originated in the comments of this post,  break / continue   were renamed  to succeed / proceed .)

Note that in the above code, strings and decimal numbers and comparisons are used as the  when  expression. How does Perl 6 know how to match the  given  value against the  when  value, when both can be of wildly varying types?

The answer is that the two values enter a negotiation process called smartmatching , mentioned briefly in  Day 13 . To summarize, smartmatching (written as  $a ~~ $b ) is a kind of “regex matching on steroids”, where the  $b  doesn’t have to be a regex, but can be of any type. For ranges, the smartmatch will check if the value we want to match is within the range. If  $b  is a class or a role or a subtype, the smartmatch will perform a type check. And so on. For values like  Num and  Str  which represent themselves, some appropriate equivalence check is made.

The “whatever star” ( * ) has the peculiar property that it smartmatches on anything. Oh, and  default  is just sugar for  when * .

To summarize the summary, smartmatching is DWIM in operator form. And the  given / when  construct runs on top of it.

Now for something slightly head-spinning: the  given  and  when features are actually independant! While you complete the syllable “WHAT?”, let me explain how.

Given is actually a sort of once-only  for  loop.
given $punch-card {
  .bend;
  .fold;
  .mutilate;
}

See what happened there? All  given  does is set the topic, also known to Perl people as  $_ . The cute  .method  is actually short for $_.method .

Now it’s easier to see how  when  can be used without a  given , too. when  can be used inside any block which sets  $_ , implicitly or explicitly:
my $scanning;
for $*IN.lines {
  when /start/ { $scanning = True }
  when /stop/  { $scanning = False }
 
  if $scanning {
    # Do something which only happens between the
    # lines containing 'start' and 'stop'
  }
}

Note that those  when  blocks exhibit the same behaviour as the in a given  block: they skip the rest of the surrounding block after executing, which in the above code means they go directly to the next line in the input.

Here’s another example, this time with  $_  explicitly set:
sub fib(Int $_) {
  when * < 2 { 1 }
  default { fib($_ - 1) + fib($_ - 2) }
}

(This independence between  given  and  when  plays out in other ways too. For example, the way to handle exceptions is with a  CATCH  block, a variant of  given  which topicalizes on  $! , the variable holding the most recent exception.)

To top it all off, both  given  and  when  come in statement-ending varieties, just as  for ,  if  and the others:
  say .[0] + .[1] + .[2] given @list;
  say 'My God, it's full of vowels!' when /^ <[aeiou]>+ $/;

You can even nest a  when  inside a  given :
  say 'Boo!' when /phantom/ given $castle;

As  given  and  when  represent another striking blow against the Perl obfuscation track record, I hereby present you with the parting gift of an obfu DNA helix, knowing full well that it doesn’t quite make up for the damage caused. :)
$ perl6 -e 'for ^20 {my ($a,$b)=<AT CG>.pick.comb.pick(*);\
  my ($c,$d)=sort map {6+4*sin($_/2)},$_,$_+4;\
  printf "%{$c}s%{$d-$c}s\n",$a,$b}'
     G  C
      TA
     C G
   G    C
 C     G
 G     C
 T   A
  CG
CG
 C   G
 T     A
  T     A
   T    A
     C G
      TA
    T   A
  T     A
 A     T
 C    G
 G  C

来源： < http://perl6advent.wordpress.com/category/2009/ >  