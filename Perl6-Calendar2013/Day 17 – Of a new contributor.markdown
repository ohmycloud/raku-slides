Day 17 – Of a new contributor By   Timotimo


If you’re anything like me, you’ve read last year’s advent calendar posts with delight, squeeing a little bit at the neat things you could express so easily with Perl 6. You might have wondered – like I have – if all those sundry features are just shiny bells and whistles that were added on top of an okay language. And you might be wondering how to find out more, dig deeper, and maybe even contribute.

As you can tell from the fact that I’m writing this article, I’ve decided to become a contributor to the Perl 6 effort. I’m going to tell you how I got interested and then involved (and inloved) with Perl 6.

Before my involvement with Perl 6 I mostly used Python. However beautiful and flexible Python is, I worked on a project where it was a poor fit and writing proper test code was exceptionally uncomfortable. Thus, I often made mistakes – misused my data structures, passed values of incorrect types to methods – that I felt the language should be able to detect early without sacrificing flexibility. The “gradual typing” approach of Perl 6 sounded like a very good fit to me.

Having a friend show me bits and pieces of Perl 6 quickly led to looking at the Advent Calendar last year. I also joined the IRC channel and asked a whole bunch of questions. Not having done any Perl 5 programming before made figuring out the nooks and crannies of Perl 6 syntax a bit harder than I would have liked, especially when using the Perl 6 book. Fortunately, the IRC channel was always active and eager to help.

After having learnt a bit more about Perl 6, I quickly started helping out here and there. In part because I’ve already enjoyed doing that for PyPy – which is implemented in a subset of Python, much like Rakudo is implemented in NQP – but also because I kept hitting little problems and bugs.

So, how do you actually get to contributing?

Well, starting small is always good. Come to the IRC channel and ask for “low hanging fruit”. Check out  bugs blocking on test coverage or easy tickets  from the Perl 6 bug tracker. Try porting or creating one of the  most wanted modules . Experiment with the language and look what bugs you hit. One thing that’s always good and often not very hard is fixing “LTA error messages”; those are error messages that are “less than awesome”.

At some point you’ll find something you’d like to fix. For me, the first thing was making spectests for bugs that were already fixed, but didn’t have a test yet. After that, giving a more helpful error message when a programmer tries to concatenate strings with . instead of ~. Then came fixing the output of nested Pair objects to have proper parenthesis. And then I dug deep into the Grammar, Actions and World classes to implement a suggestion mechanism for typos in variables, classes and subs.

The fact that most of your potential contributions will likely be done either in Perl 6 code or at least in NQP code makes it rather easy to get started, since even NQP is fairly high-level. And if you work through the  materials from the Rakudo and NQP Internals Workshop 2013 , you’ll get a decent head start in understanding how Rakudo and NQP work.

Whenever you get stuck, the people in #perl6 – including me, of course – will be happy to help you out and give advice along the way.

Let’s try to tackle a simple “testneeded” bug.  this bug about parsing :$<a> pair shorthand syntax  looks simple enough to write a test case for.

Here’s the executive summary:

The :$foo syntax has already been introduced a few days ago by the post on adverbly adverbs. The syntax here is a combination of the shorthand notation  $<foo>  to mean  $/<foo> , which refers to the named match group “foo” from the regex we just matched.

So  :$<foo>  is supposed to give the pair  "foo" => $<foo> . It didn’t in the past, but someone came along and fixed it. Now all we need to do is create a simple test case to make sure Rakudo doesn’t regress and other implementations don’t make the same mistake.

In the last comment of the discussion, jnthn already wrote a much shortened test case for this bug, hidden behind a “show quoted text” link:
'abc' ~~ /a $<a>=[\w+]/; say :$<a>.perl

Since sometimes it happens that such a test case causes a compilation error on one of the implementations, it’s useful to be able to “fudge” the whole thing in one go. That means writing something like  #?niecza skip  in front of a block. That’s why we wrap our whole little test in curly braces, like so:
# RT #76998
{
   my $res = do { 'abc' ~~ /a $<a>=[\w+]/; :$<a> };
   ok $res ~~ Pair, ':$<a> returns a pair';
   ok $res.key eq 'a', 'its key is "a"';
   ok $res.value ~~ Match:D, 'the pair's value is a defined match object';
}

So what have we done here? We executed the code in a do block, so that we can grab the value of the last piece of the block. The next three lines inspect the return value of our code block: Is it a Pair object? Is its key “a”, like expected? Is its value a defined Match object instance? (See  day 2′s post  about the :D smiley).

Also, we wrapped the whole test in a big block and put a comment on top to mention the ticket ID from the bug tracker. That way, it’s easier to see why this test exists and we can reference the commit to the  perl6/roast  repository in the ticket discussion when we close it (or have someone close it for us).

Next up, we have to “bump up the plan”, which means we go to the beginning of the test file and increase the line that calls “plan” with a number by 3 (which is exactly how many more ok/not ok outputs we expect our test case to generate).

Then we can either fork  perl6/roast  on github and make a pull-request from our change or submit a git format-patch created patch via IRC, the bug tracker, or the mailing lists.

Note that I didn’t commit anything I wrote here yet. If you’re faster than the other readers of this blog, you can feel free to go ahead and submit this. If you’re not, feel free to select a different ticket to improve upon.

Finally, if you apply for a commit bit – meaning the right to directly commit to the repositories on github – make sure to mention I sent you to get 50% off of your first 10 commits; what an  incredible deal!

来源： < http://perl6advent.wordpress.com/2013/12/17/day-17-of-a-new-contributor/ >  