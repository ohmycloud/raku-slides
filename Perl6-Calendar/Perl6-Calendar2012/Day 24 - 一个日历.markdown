Day 24 – An Advent Calendar December 24, 2012


Recently I was unpacking some boxes of books and came across a book entitled " BASIC Computer Programs for the Home " by Charles D. Sternberg. Apparently my father had purchased this book in the early 1980s and had given it to me. In any case, my name was scrawled in the front cover in the manner an adolescent me would have done.

Mostly this book is filled with simple BASIC programs that manage simple databases of various things: recipes, household budget, address book, music collections, book collections, school grades, etc. But the program that caught my eye and made me think of the Perl 6 Advent Calendar was one for printing a calendar starting at a particular month.

Now, the version in this book is a little simple in that it asks for the starting month, year, the day of the week that the first month starts on, and how many months to print. I wanted something a little more like the Unix utility cal(1) program. Luckily, Perl 6 has date handling classes as part of the  specification  and both major implemenations, Rakudo and  Niecza , have actual implementations of these which should make creating the calendar quite easy.

For reference, the output of the Unix cal(1) utility looks like this:

       December 2012
    Su Mo Tu We Th Fr Sa
                       1
     2  3  4  5  6  7  8
     9 10 11 12 13 14 15
    16 17 18 19 20 21 22
    23 24 25 26 27 28 29
    30 31                

It also has some options to change the output in various ways, but I just want to focus on reproducing the above basic output.

I'll need a list of month names and weekday abbreviations:

    constant @months = <January February March April May June July
                        August September October November December>;
    constant @days = <Su Mo Tu We Th Fr Sa>;

And it looks like the month and year are centered above the days of the week. Generating a calendar for May shows this to be the case, so I'll need a routine that centers text:

    sub center(Str $text, Int $width) {
        my $prefix = ' ' x ($width - $text.chars) div 2;
        my $suffix = ' ' x $width - $text.chars - $prefix.chars;
        return $prefix ~ $text ~ $suffix;
    }

Now, the mainline code needs two things: a month and a year. From this it should be able to generate an appropriate calendar. But, we should have a reasonable default for these values I think. Today's month and year seem reasonable to me:
    sub MAIN(:$year = Date.today.year, :$month = Date.today.month) {

but if it's not today's month and year, then it's some arbitrary month and year we need info about. To do this we construct a new Date object from the month and year given.
        my $dt = Date.new(:year($year), :month($month), :day(1) );

Looking at the calendar generated for December, it seems like we may actually output up to 6 rows of numbers since the month can start and end on a partial week. In order to implement this, I think I'll need some "slots" for each day. Each slot will either be empty or will contain the day of the month. The number of empty slots at the beginning of the month correspond to the day of the week that the first of the month occurs on. If the first is on Sunday, there will be 0 empty slots, if the first is on a Monday there will be 1 empty slot, if the first is on a Tuesday, there will be 2 empty slots, etc. This is remarkably similar to the number we get when we interrogate a Date object for the day of the week. The only wrinkle is that it returns 7 for Sunday when we actually need a 0. That's easily remedied with a modulus operator however:

        my $dt = Date.new(:year($year), :month($month), :day(1) );
        my $ss = $dt.day-of-week % 7;
        my @slots = ''.fmt("%2s") xx $ss;

That gives us the empty slots at the beginning, but what about the ones that actually contain the days of the month? Easy enough, we'll just generate a number for each day of the month using the Date object we created earlier.

        my $days-in-month = $dt.days-in-month;
        for $ss ..^ $ss + $days-in-month {
            @slots[$_] = $dt.day.fmt("%2d");
            $dt++
        }

Now we've got an array with appropriate values in the appropriate positions, all that's left is to actually output the calendar. Using the header line for our weekdays as a metric for the width of the calendar, and the routine we created for centering text, we can output the header portion of the calendar:

        my $weekdays = @days.fmt("%2s").join: " ";
        say center(@months[$month-1] ~ " " ~ $year, $weekdays.chars);
        say $weekdays;

Then we iterate over each slot and output the appropriate values. If we've reached the end of the week or the end of the month, we output a newline:

        for @slots.kv -> $k, $v {
            print "$v ";
            print "\n" if ($k+1) %% 7 or $v == $days-in-month;
        }

Putting it all together, here is the final program:

    #!/usr/bin/env perl6
 
    constant @months = <January February March April May June July
                        August September October November December>;
    constant @days = <Su Mo Tu We Th Fr Sa>;
 
 
    sub center(Str $text, Int $width) {
        my $prefix = ' ' x ($width - $text.chars) div 2;
        my $suffix = ' ' x $width - $text.chars - $prefix.chars;
        return $prefix ~ $text ~ $suffix;
    }
 
    sub MAIN(:$year = Date.today.year, :$month = Date.today.month) {
        my $dt = Date.new(:year($year), :month($month), :day(1) );
        my $ss = $dt.day-of-week % 7;
        my @slots = ''.fmt("%2s") xx $ss;
 
        my $days-in-month = $dt.days-in-month;
        for $ss ..^ $ss + $days-in-month {
            @slots[$_] = $dt.day.fmt("%2d");
            $dt++
        }
 
        my $weekdays = @days.fmt("%2s").join: " ";
        say center(@months[$month-1] ~ " " ~ $year, $weekdays.chars);
        say $weekdays;
        for @slots.kv -> $k, $v {
            print "$v ";
            print "\n" if ($k+1) %% 7 or $v == $days-in-month;
        }
    }

Normally, cal(1) will highlight today's date on the calendar. That's a feature I left out of my calendar implementation but it could easily be added with  Term::ANSIColor . Also, there's a little bit of coupling between the data being generated in the slots and the output processing (the slots are all formatted to be 2 characters wide in anticipation of the output). There are some other improvements that could be done, but for a first cut at a calendar in Perl 6, I'm happy. :-)


Posted in  2012  |  2 Comments »
Day 23 – Macros December 23, 2012


Syntactic macros. The Lisp gods of yore provided humanity with this invention, essentially making Lisp a programmable programming language. Lisp adherents often look at the rest of the programming world with pity, seeing them fighting to invent wheels that were wrought and polished back in the sixties when giants walked the Earth and people wrote code in all-caps.

And the Lisp adherents see that the rest of us haven’t even gotten to the best part yet, the part with syntactic macros. We’re starting to get the hang of automatic memory management, continuations, and useful first-class functions. But macros are still absent from this picture.

In part, this is because in order to have proper syntactic macros, you basically have to look like Lisp. You know, with the parentheses and all. Lisp ends up having almost no syntax at all, making every program a very close representation of a syntax tree. Which really helps when you have macros starting to manipulate those same trees. Other languages, not really wanting to look like Lisp, find it difficult-to-impossible to pull off the same trick.

The Perl languages love the difficult-to-impossible. Perl programmers publish half a dozen difficult-to-impossible solutions to CPAN  before breakfast. And, because Perl 6 is awesome and syntactic macros are awesome, Perl 6 has syntactic macros.

It is known, Khaleesi. What are macros?

For reasons even I don’t fully understand, I’ve put myself in charge of implementing syntactic macros in Rakudo. Implementing macros means understanding them. Understanding them means my brain melts regularly. Unless it fries. It’s about 50-50.

I have this habit where I come into the  #perl6  channel, and exclaiming “macros are just X!” for various values of X. Here are some samples:
Macros are just syntax tree manipulators.
Macros are just “little compilers”.
Macros are just a kind of templates.
Macros are just routines that do code substitution.
Macros allow you to safely hand values back and forth between the compile-time world and the runtime world.


But the definition that I finally found that I like best of all comes from scalamacros.org :

Macros are functions that are called by the compiler during compilation. Within these functions the programmer has access to compiler APIs. For example, it is possible to generate, analyze and typecheck code.

While we only cover the “generate” part of it yet in Perl 6, there’s every expectation we’ll be getting to the “analyze and typecheck” parts as well. Some examples, please?

Coming right up.
macro checkpoint {
  my $i = ++(state $n);
  quasi { say "CHECKPOINT $i"; }
}
 
checkpoint;
for ^5 { checkpoint; }
checkpoint;

The  quasi  block is Perl 6′s way of saying “a piece of code, coming right up!”. You just put your code in the  quasi  block, and return it from the macro routine.

This code inserts “checkpoints” in our code, like little debugging messages. There’s only three checkpoints in the code, so the output we’ll get looks like this:
CHECKPOINT 1
CHECKPOINT 2
CHECKPOINT 2
CHECKPOINT 2
CHECKPOINT 2
CHECKPOINT 2
CHECKPOINT 3

Note that the “code insertion” happens at compile time. That’s why we get five copies of the  CHECKPOINT 2  line, because it’s the same checkpoint running five times. If we had had a subroutine instead:
sub checkpoint {
  my $i = ++(state $n);
  say "CHECKPOINT $i";
}

Then the program would print 7 distinct checkpoints.
CHECKPOINT 1
CHECKPOINT 2
CHECKPOINT 3
CHECKPOINT 4
CHECKPOINT 5
CHECKPOINT 6
CHECKPOINT 7

As a more practical example, let’s say you have logging output in your program, but you want to be able to switch it off completely. The problem with an ordinary logging subroutine is that with something like:
LOG "The answer is { time-consuming-computation() }";

The  time-consuming-computation()  will run and take a lot of time even if  LOG  subsequently finds that logging was turned off. (That’s just how argument evaluation works in a non-lazy language.)

A macro fixes this:
constant LOGGING = True;
 
macro LOG($message) {
  if LOGGING {
    quasi { say {{{$message}}} };
  }
}

Here we see a new feature: the  {{{ }}}  triple-block. (Syntax is likely to change in the near future, see below.) It’s our way to mix template code in the  quasi  block with code coming in from other places. Doing say $message;  would have been wrong, because  $message  is a syntax tree of the message to be logged. We need to inject that syntax tree right into the  quasi , and we do that with a triple-block.

The macro  conditionally  generates logging code in your program. If the constant  LOGGING  is switched on, the appropriate logging code will replace each  LOG  macro invocation. If  LOGGING  is off, each macro invocation will be replaced by literally nothing.

Experience shows that running no code at all is very efficient. What are syntactic macros?

A lot of things are called “macros” in this world. In programming languages, there are two big categories:
Textual macros.  They substitute code on the level of the source code text. C’s macros, or Perl 5′s source filters, are examples.
Syntactic macros.  They substitute code on the level of the source code syntax tree. Lisp macros are an example.


Textual macros are very powerful, but they represent the kind of power that is just as likely to shoot half your leg off as it is to get you to your destination. Using them requires great care, of the same kind needed for a janitor gig at Jurassic Park.

The problem is that textual macros don’t  compose  all that well. Bring in more than one of them to work on the same bit of source code, and… all bets are off. This puts severe limits on modularity. Textual macros, being what they are, leak internal details all over the place. This is the big lesson from Perl 5′s source filters, as far as I understand.

Syntactic macros compose wonderfully. The compiler is  already  a pipeline handing off syntax trees between various processing steps, and syntactic macros are simply more such steps. It’s as if you and the compiler were two children, with the compiler going “Hey, you want to play in my sandbox? Jump right in. Here’s a shovel. We’ve got work to do.” A macro is a shovel.

And syntactic macros allow us to be  hygienic , meaning that code in the macro and code outside of the macro don’t step on each other’s toes. In practice, this is done by carefully keeping track of the macros context and the mainline’s context, and making sure wires don’t cross. This is necessary for safe and large-scale composition. Textual macros don’t give us this option at all. Future

Both of the examples in this post work already in Rakudo. But it might also be useful to know where we’re heading with macros in the next year or so. The list is in the approximate order I expect to tackle things.
Un-hygiene.  While hygienic macros are the sane and preferable default, sometimes you  want  to step on the toes of the mainline code. There should be an opt-out, and escape hatch. This is next up.
Introspection.  In order to analyze and typecheck code, not just generate it, we need to be able to take syntax trees coming in as macro arguments, and look inside of them. There are no tools for that yet, and there’s no spec to guide us here. But I’m fairly sure people will want this. The trick is to come up with something that doesn’t tie us down to one compiler’s internal syntax-tree format. Both for the sake of compiler interoperability and future compatibility.
Deferred declarations.  The sandbox analogy isn’t so frivolous, really. If you declare a class inside a  quasi  block, that declaration is limited (“sandboxed”) to within that  quasi  block. Then, when the code is injected somewhere in the mainline because of a macro invocation, it should actually run. Fortunately, as it happens, the Rakudo internals are factored in such a way that this will be fairly straightforward to implement.
Better syntax.  The triple-block syntax is probably going away in favor of something better. The problem isn’t the syntax so much as the fact that it currently only works for terms. We want it to work for basically all syntactic categories. A solid proposal for this is yet to materialize, though.


With each of these steps, I expect us to find new and fruitful uses of macros. Knowing my fellow Perl 6 developers, we’ll probably find some uses that will shock and disgust us all, too. In conclusion

Perl 6 is awesome because it puts  you , the programmer, in the driver seat. Macros are simply more of that.

Implementing macros makes your brain melt. However, using them is relatively straightforward.


Posted in  2012  |  4 Comments »




Posted in  2012  |  2 Comments »
Day 21 – Collatz Variations December 21, 2012


The  Collatz sequence  is one of those interesting “simple” math problems that I’ve run into a number of times. Most recently a blog post on  programming it in Racket  showed up on Hacker News. As happens so often, I instantly wanted to implement it in Perl 6.

 sub collatz-sequence(Int $start) {
      $start, { when * %% 2 { $_ / 2 }; when * !%% 2 { 3 * $_ + 1 }; } ... 1;
 }
  
 sub MAIN(Int $min, Int $max) {
      say [max] ($min..$max).map({ +collatz-sequence($_) });       
 }


This is a very straightforward implementation of the Racket post’s  max-cycle-length-range  as a stand-alone p6 script.  collatz-sequence generates the sequence using the p6 sequence operator. Start with the given number. If it is divisible by two, do so:  when * %% 2 { $_ / 2 } . If it is not, multiply by three and add 1:  when * !%% 2 { 3 * $_ + 1 } . Repeat this until the sequence reaches 1.

MAIN(Int $min, Int $max)  sets up our main function to take two integers. Many times I don’t bother with argument types in p6, but this provides a nice feedback for users:

 > perl6 collatz.pl blue red
 Usage:
    collatz.pl <min> <max>


The core of it just maps the numbers from  $min  to  $max  (inclusive) to the length of the sequence ( +collatz-sequence ) and then says the max of the resulting list ( [max] ).

Personally I’m a big fan of using the sequence operator for tasks like this; it directly represents the algorithm constructing the Collatz sequence in a simple and elegant fashion. On the other hand, you should be able to memoize the recursive version for a speed increase. Maybe that would give it an edge over the sequence operator version?

Well, I was wildly wrong about that.

 sub collatz-length($start) {
      given $start {
          when 1       { 1 }
          when * !%% 2 { 1 + collatz-length(3 * $_ + 1) }
          when * %% 2  { 1 + collatz-length($_ / 2) }
      }
 }
  
 sub MAIN($min, $max) {
      say [max] ($min..$max).map({ collatz-length($_) });       
 }


This recursive version, which makes no attempt whatsoever to be efficient, is actually better than twice as fast as the sequence operator version. In retrospect, this makes perfect sense: I was worried about the recursive version making a function call for every iteration, but the sequence version has to make two, one to calculate the next iteration and the other to check and see if the ending condition has been reached.

Well, once I’d gotten this far, I thought I’d better do things correctly. I wrote two framing scripts, one for timing all the available scripts, the other for testing them to make sure they work!

 my @numbers = 1..200, 10000..10200;
  
 sub MAIN(Str $perl6, *@scripts) {
      my %results;
      for @scripts -> $script {
          my $start = now;
          qqx/$perl6 $script { @numbers }/;
          my $end = now;
  
          %results{$script} = $end - $start;
      }
  
      for %results.pairs.sort(*.value) -> (:key($script), :value($time)) {
          say "$script: $time seconds";
      }
 }


This script takes as an argument a string that can be used to call a Perl 6 executable and a list of scripts to run. It runs the scripts using the specified executable, and times them using p6′s  now  function. It then sorts the results into order and prints them. (A  similar script  I won’t post here tests each of them to make sure they are returning correct results.)

In the new framework, the Collatz script has changed a bit. Instead of taking a min and a max value and finding the longest Collatz sequence generated by a number in that range, it takes a series of numbers and generates and reports the length of the sequence for each of them. Here’s the sequence operator script in its full new version:

 sub collatz-length(Int $start) {
      +($start, { when * %% 2 { $_ / 2 }; when * !%% 2 { 3 * $_ + 1 }; } ... 1);
 }
  
 sub MAIN(*@numbers) {
      for @numbers -> $n {
          say "$n: " ~ collatz-length($n.Int);
      }
 }


For the rest of the scripts I will skip the  MAIN  sub, which is exactly the same in each of them.

Framework established, I redid the recursive version starting from the new sequence operator code.

 sub collatz-length(Int $n) {
      given $n {
          when 1       { 1 }
          when * %% 2  { 1 + collatz-length($_ div 2) }
          when * !%% 2 { 1 + collatz-length(3 * $_ + 1) }
      }
 }


The sharp-eyed will notice this version is different from the first recursive version above in two significant ways. This time I made the argument  Int $n , which instantly turned up a bit of a bug in all implementations thus far: because I used  $_ / 2 , most of the numbers in the sequence were actually rationals, not integers! This shouldn’t change the results, but is probably less efficient than using Int s. Thus the second difference about, it now uses  $_ div 2  to divide by 2. This version remains a great improvement over the sequence operator version, running in 4.7 seconds instead of 13.3. Changing  when * !%% 2  to a simple  default  shaves another .3 seconds off the running time.

Once I started wondering how much time was getting eaten up by the when  statements, rewriting that bit using the ternary operator was an obvious choice.

 sub collatz-length(Int $start) {
      +($start, { $_ %% 2 ?? $_ div 2 !! 3 * $_ + 1 } ... 1);
 }


Timing results: Basic sequence 13.4 seconds. Sequence with  div  11.5 seconds. Sequence with  div  and ternary 9.7 seconds.

That made me wonder what kind of performance I could get from a handcoded loop.

 1
 2
 3
 4
 5
 6
 7
 8
 sub collatz-length(Int $n is copy) {
      my $length = 1;
      while $n != 1 {
          $n = $n %% 2 ?? $n div 2 !! 3 * $n + 1;
          $length++;
      }
      $length;
 }


That’s by far the least elegant of these, I think, but it gets great performance: 3 seconds.

Switching back to the recursive approach, how about using the ternary operator there?

 sub collatz-length(Int $n) {
      return 1 if $n == 1;
      1 + ($n %% 2 ?? collatz-length($n div 2) !! collatz-length(3 * $n + 1));
 }


This one just edges out the handcoded loop, 2.9 seconds.

Can we do better than that? How about memoization?  is cached  is supposed to be part of Perl 6; neither implementation has it yet, but last year’s  Advent calendar has a Rakudo implementation  that still works. Using the last version changed to  sub collatz-length(Int $n) is cached {  works nicely, but takes 3.4 seconds to execute. Apparently the overhead of caching slows it down a bit. Interestingly, the non-ternary recursive version does speed up with  is cached , from 4.4 seconds to 3.6 seconds.

Okay, instead of using a generic memoization, how about hand-coding one?

 sub collatz-length(Int $n) {
      return 1 if $n == 1;
      state %lengths;
      return %lengths{$n} if %lengths.exists($n);
      %lengths{$n} = 1 + ($n %% 2 ?? collatz-length($n div 2) !! collatz-length(3 * $n + 1));
 }


Bingo! 2.7 seconds.

I’m sure there are lots of other interesting approaches for solving this problem, and encourage people to send them in. In the meantime, here’s my summary of results so far: Script Rakudo Niecza
 bin/collatz-recursive-ternary-hand-cached.pl 2.5 1.7
 bin/collatz-recursive-ternary.pl 3 1.7
 bin/collatz-loop.pl 3.1 1.7
 bin/collatz-recursive-ternary-cached.pl 3.2 N/A
 bin/collatz-recursive-default-cached.pl 3.5 N/A
 bin/collatz-recursive-default.pl 4.4 1.8
 bin/collatz-recursive.pl 4.9 1.9
 bin/collatz-sequence-ternary.pl 9.9 3.3
 bin/collatz-sequence-div.pl 11.6 3.5
 bin/collatz-sequence.pl 13.5 3.8


The table was generated from  timing-table-generator.pl .


Posted in  2012  |  12 Comments »
Day 20 – Dynamic variables and DSL-y things December 20, 2012


Today, let’s talk about DSLs. Post from the past: a motivating example

Two years ago I wrote  a blog post about Nim , a game played with piles of stones. I just put in ASCII diagrams of the actual Nim stone piles, telling myself that if I had time, I would put in fancy SVG diagrams, generated with Perl 6.

Naturally, I didn’t have time. My self-imposed deadline ran out, and I published the post with simple ASCII diagrams.

But time is ever-regenerative, and there for people who want it. So, let’s generate some fancy SVG diagrams with Perl 6. Have bit array, want SVG

What do we need, exactly? Well, a subroutine that takes an array of piles as input and generates an SVG file would be a really good start.

Let’s take the last “image” in  the post  as an example:
3      OO O
4 OOOO
5 OOOO    O

For the moment, let’s ignore the numbers at the left margin; they’re just counting stones. We summarize the piles themselves as a kind of bitmap, which also forms the input to the function:
my @piles =
    [0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 0, 1, 1, 0, 1],
    [1, 1, 1, 1, 0, 0, 0, 0, 1];
 
nim-svg(@piles);

At this point, we need only create the  nim-svg  function itself, and make it render SVG from this bitmap. Since I’ve long since tired of outputting SVG by hand, I use the  SVG module , which comes bundled with Rakudo Star.
use SVG;
 
sub nim-svg(@piles) {
    my $width = max map *.elems, @piles;
    my $height = @piles.elems;
 
    my @elements = gather for @piles.kv -> $row, @pile {
        for @pile.kv -> $column, $is_filled {
            if $is_filled {
                take 'circle' => [
                    :cx($column + 0.5),
                    :cy($row + 0.5),
                    :r(0.4)
                ];
            }
        }
    }
 
    say SVG.serialize('svg' => [ :$width, :$height, @elements ]);
}

I think you can follow the logic in there. The subroutine simply iterates over the bitmap, turning 1s into circles with appropriate coordinates. That’s it?

Well, this will indeed generate an SVG image for us, with the stones correctly placed. But let’s look again at the input that helped create this image:
    [0, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 0, 1, 1, 0, 1],
    [1, 1, 1, 1, 0, 0, 0, 0, 1];

Clearly, though we can discern the stones and gaps in there if we squint in a bit-aware programmer’s fashion, the input isn’t… visually attractive. (The zeroes even look like stones, even though they’re gaps!) We can do better

Instead of using a bit array, let’s start from the desired SVG image and try to make the input look like that.

So, this is what I would prefer to write instead of a bitmask:
nim {
  _ _ _ _ _ _ _ _ o;
  o o o o _ o o _ o;
  o o o o _ _ _ _ o;
}

That’s better. That looks more like my original ASCII diagram, while still being syntactic Perl 6 code. Making a DSL

Wikipedia talks about a DSL as a language “dedicated to a particular problem domain”. Well, the above way of specifying the input would be a DSL dedicated to solving the draw-SVG-images-of-Nim-positions domain. (Admittedly a fairly narrow domain. But I’m mostly out to show the potential of DSLs in Perl 6, not to change the world with this particular DSL.)

Now that we have the desired end state, how do we connect the wires and make the above work? Clearly we need to declare three subroutines:  nim ,  _ ,  o . (Yes, you can name a subroutine  _ , no sweat.)
sub nim(&block) {
    my @*piles;
    my @*current-pile;
 
    &block();
    finish-last-pile();
 
    nim-svg(@*piles);
}
 
sub _(@rest?) {
    unless @rest {
        finish-last-pile();
    }
    @*current-pile = 0, @rest;
    return @*current-pile;
}
 
sub o(@rest?) {
    unless @rest {
        finish-last-pile();
    }
    @*current-pile = 1, @rest;
    return @*current-pile;
} Ok… explain, please?

A couple of things are going on here.
The two variables  @*piles  and  @*current-pile  are  dynamic variables  which means that they are visible not just in the current lexical scope, but also in all subroutines called before the current scope has finished. Notably, the two subroutines  _  and  o .
The two subroutines  _  and  o  take an optional parameter. On each row, the rightmost  _  or  o  acts as a silent “start of pile” marker, taking the time to do a bit of bookkeeping with the piles, storing away the last pile and starting on a new one.
Each row in the DSL-y input basically forms a chain of subroutine calls. We take this into account by both incrementally building the @*current-pile  array at each step, all the while returning it as (possible) input for the next subroutine call in the chain.


And that’s it. Oh yeah, we need the bookkeeping routine  finish-last-pile , too:
sub finish-last-pile() {
    if @*current-pile {
        push @*piles, [@*current-pile];
    }
    @*current-pile = ();
} So, it works?

Now, the whole thing works. We can turn this DSL-y input:
nim {
  _ _ _ _ _ _ _ _ o;
  o o o o _ o o _ o;
  o o o o _ _ _ _ o;
}

…into this SVG output:
<svg
  xmlns="http://www.w3.org/2000/svg"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  width="9" height="3">
 
  <circle cx="8.5" cy="0.5" r="0.4" />
  <circle cx="0.5" cy="1.5" r="0.4" />
  <circle cx="1.5" cy="1.5" r="0.4" />
  <circle cx="2.5" cy="1.5" r="0.4" />
  <circle cx="3.5" cy="1.5" r="0.4" />
  <circle cx="5.5" cy="1.5" r="0.4" />
  <circle cx="6.5" cy="1.5" r="0.4" />
  <circle cx="8.5" cy="1.5" r="0.4" />
  <circle cx="0.5" cy="2.5" r="0.4" />
  <circle cx="1.5" cy="2.5" r="0.4" />
  <circle cx="2.5" cy="2.5" r="0.4" />
  <circle cx="3.5" cy="2.5" r="0.4" />
  <circle cx="8.5" cy="2.5" r="0.4" />
</svg>

Yay! Summary

The principles I used in this post are fairly easy to generalize. Start from your desired DSL, and create the subroutines to make it happen. Have dynamic variables handle the communication between separate subroutines.

DSLs are nice because they allow us to shape the code we’re writing around the problem we’re solving. Using relatively little “adapter code”, we’re left to focus on describing and solving problems in a natural way, making the programming language rise to our needs instead of lowering ourselves down to its needs.


Posted in  2012  |  2 Comments »
Day 19 – Gather and/or Coroutines December 19, 2012


Today I’ll write about coroutines, gather-take and why they are as much fun as one another. But since it’s all about manipulating control flow, I took the liberty to reorganize the control flow of this advent post, so coroutines will finally appear somewhere at the end of it. In the meantime I’ll introduce the backstory, the problems that coroutines solved and how it looks from the Perl 6 kitchen.

LWP::Simple is all fun and games, but sometimes you can’t afford to wait for the result to come. It would make sense to say “fetch me this webpage and drop me a note when you’re done with it”. That’s non trivial though; LWP::Simple is a black box, which we tell “get() this, get() that” and it gives us the result back. There is no possible way to intercept the internal data it sends there and around. Or is there?

If you look at Perl 5′s AnyEvent::HTTP, you’ll see that it reimplemented the entire HTTP client to have it non-blocking. Let’s see if we can do better than that.

First thing, where does LWP::Simple actually block? Behind our backs it uses the built-in IO::Socket::INET class. When it wants data from it, it calls .read() or .recv() and patiently waits until they’re done. If only we could somehow make it not rely on those two directly, hmm…

„I know!”, a gemstone-fascinated person would say, „We can monkey-patch IO::Socket::INET”. And then we have two problems. No, we’ll go the other way, and follow the glorious path of Dependency Injection.

That sounds a bit scary. I’ve heard about as many definitions of Dependency Injection as many people I know. The general idea is to not create objects inside other objects directly; it should be possible to supply them from the outside. I like to compare it to elimination of „magic constants”. No one likes those; if you think of classes as another kind of magic constants which may appear in somebody else’s code, this is pretty much what this is about. In our case it looks like this:

# LWP::Simple make_request
my IO::Socket::INET $sock .= new(:$host, :$port);

There we go. “IO::Socket::INET” is the magic constant here; if you want to use a different thing, you’re doomed. Let’s mangle it for a bit and allow the socket class to come from the outside.

We’ll add an attribute to LWP::Simple, let’s call it $!socketclass
has $.socketclass = IO::Socket::INET;

If we don’t supply any, it will just fallback to IO::Socket::INET, which is a sensible default. Then, instead of the previous .new() call, we do
my $sock = $!socketclass.new(:$host, :$port);

The actual patch ( https://github.com/tadzik/perl6-lwp-simple/commit/93c182ac2 ) is a bit more complicated, as LWP::Simple supports calling get() not only on constructed objects but also on type objects, which have no attributes set, but we only care about the part shown above. We have an attribute $!socketclass, which defaults to IO::Socket::INET but we’re free to supply another class – dependency-inject it. Cool! So in the end it’ll look like this:

class Fakesocket is IO::Socket::INET {
    method recv($) {
        note 'We intercepted recv()';
        callsame;
    }
 
    method read($) {
        note 'We intercepted read()';
        callsame;
    }
}
 
# later
my $lwp = LWP::Simple.new(socketclass => Fakesocket);

And so our $lwp is a fine-crafted LWP::Simple which could, theorically, give the control flow back to us while it waits for read() and recv() to finish. So, how about we put theory into practice? Here start the actual coroutines, sorry for being late :)

What do we really need in our modified recv() and read()? We need a way to say „yeah, if you could just stop executing and give time to someone else, that would be great.” Oh no, but we have no threads! Luckily, we don’t need any. Remember lazy lists?
my @a := gather { for 1..* -> $n { take $n } }

So on one hand we run an infinite for loop, and on the other we have a way to say „give back what you’ve come up with, I’ll catch up with you later”. That’s what take() does: it temporarily jumps out of the gather block, and is ready to get back to it whenever you want it. Do I hear the sound of puzzles clicking together? That’s exactly what we need! Jump out of the execution flow and wait until we’re asked to continue.

class Fakesocket is IO::Socket::INET {
    method recv($) {
        take 1;
        callsame;
    }
 
    method read($) {
        take 1;
        callsame;
    }
}
 
# later
my @a := gather {
    $lwp.get("http://jigsaw.w3.org/HTTP/300/301.html");
    take "done";
}
 
# give time to LWP::Simple, piece by piece
while ~@a.shift ne "done" {
    say "The coroutine is still running"
}
say "Yay, done!";

There we go! We just turned LWP::Simple into a non-blocking beast, using almost no black magic at all! Ain’t that cool.

We now know enough to create some syntactic sugar around it all. Everyone likes sugar.

module Coroutines;
my @coroutines;
enum CoroStatus <still_going done>;
 
sub async(&coroutine) is export {
    @coroutines.push($(gather {
        &coroutine();
        take CoroStatus::done;
    }));
}
 
#= must be called from inside a coroutine
sub yield is export {
    take CoroStatus::still_going;
}
 
#= should be called from mainline code
sub schedule is export {
    return unless +@coroutines;
    my $r = @coroutines.shift;
    if $r.shift ~~ CoroStatus::still_going {
        @coroutines.push($r);
    }
}

We maintain a list of coroutines currently running. Our async() sub just puts a block of code in the execution queue. Then every call to yield() will make it jump back to the mainline code. schedule(), on the other hand, will pick the first available coroutine to be run and will give it some time to do whatever it wants.

Now, let us wait for the beginning of the post to catch up.


Posted in  2012  |  2 Comments »
Day 18 – Formulas: resistance is futile December 18, 2012


Today, Perl turns 25: happy birthday Perl! There’s too much to say about this language, its philosophy, its culture, … So here, I would just thank all people who make Perl a success, for such a long time. Introduction

A formula is “an entity constructed using the  symbols  and formation rules  of a given  language “, according to  Wikipedia  as of this writing. These words sound really familiar for any Perl 6 users who have already played with  grammars , however this is not the purpose of this article. Instead, the aim is to demonstrate how the  Perl 6  language can be easily extended in order to use formulas  literally  in the code.

There are many domains, like Mathematics, Physics, finance, etc., that use their own specific languages. When writing programs for such a domain, it could be less error-prone and simpler to use its specific language instead of using a specific API. For example, someone who has knowledge in electronic may find the formula below:
4.7kΩ ± 5%

far more understandable than the following piece of code:
my $factory MeasureFactory.getSharedInstance();
my $resistance = $factory.createMeasure(value     => 4700,
                                        unit      => Unit::ohm,
                                        precision => 5);

The formula  4.7kΩ ± 5%  will be used all along this article as an example. Symbol  k : return a modified value

Let’s start with the simplest symbol:  k . Basically this is just a multiplier placed after a numeric value. To make the Perl 6 language support this new operator, there’s no need to know much about Perl 6 guts: operators are just funny looking sub-routines:
sub postfix:<k> ($a) is tighter(&infix:<*>) { $a * 1000 }

This just makes  4.7k  return  4.7 * 1000 , for example. To be a little bit picky, such kind of multiplier should not be used without a unit (ex.  Ω ) and not be coupled to another multiplier (ex.  μ ). This would have made this article a little bit more complex, so this is left as an exercise to the reader :) Regarding the  tighter  trait, it is already well explained in three   other  articles . Symbols  % : return a closure

The next symbol is  % : it is commonly used to compute a ratio of something , that’s why  5%  shouldn’t naively be transformed into  0.05 . Instead, it creates a closure that computes the given percent of whatever  you want:
sub postfix:<%> ($a) is tighter(&infix:<*>) { * * $a / 100 }

It’s now possible to write  $f = 5%; $f(42)  or  5%(42)  directly, and this returns  2.1 . It is worth saying this doesn’t conflict with the infix:<%>  operator (modulo), that is,  5 % 42  still returns  5 . Symbol  Ω : create a new  Measure  object

Let’s go on with the  Ω  symbol. One possibility is to tie the unit and the value in the same object, as in the  Measure  class defined below. The ACCEPTS  method is explained later but the idea in this case is that two Measure  objects with two different units can’t match together:
enum Unit <volt ampere ohm>;
 
class Measure {
    has Unit $.unit;
    has $.value;
 
    method ACCEPTS (Measure:D $a) {
        $!unit == $a.unit && $!value.ACCEPTS($a.value);
    }
}

Then, one operator per unit can be defined in order to  hide  the underlying API, that is, to allow  4.7kΩ  as an equivalent of Measure.new(value => 4.7k, unit => ohm) :
sub postfix:<V> (Real:D $a) is looser(&postfix:<k>) {
    Measure.new(value => $a, unit => volt)
}
sub postfix:<A> (Real:D $a) is looser(&postfix:<k>) {
    Measure.new(value => $a, unit => ampere)
}
sub postfix:<Ω> (Real:D $a) is looser(&postfix:<k>) {
     Measure.new(value => $a, unit => ohm)
}

Regarding the  ACCEPTS  method, it is used by  ~~ , the smartmatch operator, to check if the left operand can  match  the right operand, the one with the  ACCEPTS  method. In other terms,  $a ~~ $b  is equivalent to  $b.ACCEPTS($a) . Typically, this allows the  intuitive  comparison between two different types, like scalars and containers for example.

In this example, this method is overloaded to ensure two  Measure objects can match only if they have the same unit and if their values match. That means  4kΩ ~~ 4.0kΩ  is  True  whereas  4kΩ ~~ 4kV  is False . Actually, there are many units that  can  mix altogether, typically currencies (¥€$) and the ones  derived  from the  International System of Unit . But as usual, when something is a little bit more complex, it is left as an exercise to the reader ;) Symbol  ± : create a  Range  object

There’s only one symbol left so far:  ± . In the example, it is used to indicate the  tolerance  of the resistance. This tolerance could be either absolute (expressed in  Ω ) or relative (expressed in  % ), thus the new infix:<±>  operator has several signatures and have to be declared with a  multi  keyword. In both cases, the  value  is a new  Range objects with the right bounds:
multi sub infix:<±> (Measure:D $a, Measure:D $b) is looser(&postfix:<Ω>) {
    die if $a.unit != $b.unit;
    Measure.new(value => Range.new($a.value - $b.value,
                                   $a.value + $b.value),
                unit => $a.unit);
}
 
multi sub infix:<±> (Measure:D $a, Callable:D $b) is looser(&postfix:<Ω>) {
    Measure.new(value => Range.new($a.value - $b($a.value),
                                   $a.value + $b($a.value)),
                unit => $a.unit);
}

Actually, any  Callable  object could be used in the second variant, not only the closures created by the  %  operators.

So far, so good! It’s time to check in the Perl6 REPL interface if everything works fine:
> 4.7kΩ ± 1kΩ
Measure.new(unit => Unit::ohm, value => 3700/1..5700/1)
 
> 4.7kΩ ± 5%
Measure.new(unit => Unit::ohm, value => 4465/1..4935/1)

It looks good, so all the code above ought to be moved into a dedicated  module  in order to be re-used at will. Then, a customer could load it and write literally:
my $resistance = 4321Ω;
die "resistance is futile" if !($resistance ~~ 4.7kΩ ± 5%);

As of this writing, this works both in  Niecza  and  Rakudo , the two most advanced implementations of Perl 6. Symbols that aren’t operators

Symbols in a formula are not always operators, they can be symbolic constants too, like π. In many languages, constants are just  read-only variables , which sounds definitely weird: a variable isn’t supposed to be … variable? In Perl 6, a constant can be a read-only variable too (hmm) or a  read-only term  (this sounds better). For example, to define the constant term  φ :
constant φ = (1 + sqrt(5)) / 2; Conclusion

In this article the Perl 6 language was slightly extended with several new  symbols  in order to embed simple formulas. Although it is possible to go further by changing the Perl 6 grammar in order to embed more specific languages, that is, languages that don’t have the same grammar rules. Indeed, there are already two such languages supported by Perl 6: regexp and  quotes . The same way, Niecza use a custom  language to connect its portable parts to the unportable. Bonus: How to type these exotic symbols?

Most of the Unicode symbols can be type in Xorg — the most used interface system on Linux — thanks to the  Compose  key, also named Multi  key. When this special key is pressed, all the following key-strokes are somewhat merged in order to  compose  a symbol.

There’s plenty of documentation about this support elsewhere on Internet, so only the minimal information is provided here. First, to map the  Compose  key to the  Caps Lock  key, write in a X terminal:
sh> setxkbmap -option compose:caps

Some compositions are likely already defined, for instance  <caps> followed by  +  then  -  should now produce  ± , but both  Ω  and  φ  are likely not defined. One solution is to write a
~/.XCompose  file with the following content:
include "%L" # Don't discard the current locale setting.
 
<Multi_key> <o> <h> <m>      : "Ω"  U03A9
<Multi_key> <O> <underscore> : "Ω"  U03A9
<Multi_key> <underscore> <O> : "Ω"  U03A9
 
<Multi_key> <p> <h> <y> : "φ"  U03C6
<Multi_key> <o> <bar>   : "φ"  U03C6
<Multi_key> <bar> <o>   : "φ"  U03C6

This takes effect for each newly started applications. Feel free to leave a comment if you know how to add such a support on other
systems.


Tags: DSL ,  operator ,  unicode
Posted in  2012  |  2 Comments »
Day 17 – Perl 6 from 30,000 feet December 17, 2012


Many people have heard of Perl 6, especially in the greater Perl community.  However, Perl 6 has a complicated ecosystem which can be a littled daunting, so as a newcomer to the Perl 6 community myself, I thought I would share what I’ve learned. How do I install Perl 6?

It’s simple; you can just download one of the existing implementations of the language (as Perl 6 is a specification), build it, and install it! There are several implementations out there right now, in various states of completion.  Rakudo  is an implementation that targets Parrot, and is the implementation that I will discuss most in this post. Niecza is another implementation that targets the CLR (the .NET runtime). For more information on these implementations and on other implementations, please see  Perl 6 Compilers . Perl 6 is an ever-evolving language, and any compiler that passes the official test suite can be considered a Perl 6 implementation. You mentioned “Parrot”; what’s that?

Parrot  is a virtual machine that is designed to run dynamically typed languages. Along with the virtual machine, it includes tools for generating virtual machine code from intermediate languages (named PIR and PASM), as well as a suite of tools to make writing compilers easier. What is Rakudo written in?

Rakudo itself is written primarly in Perl 6, with some bits of C for some of the lower-level operations, like binding method arguments and adding additional opcodes to the Parrot VM. It may seem strange to implement a Perl 6 compiler in Perl 6 itself; Rakudo uses NQP for building itself. What’s NQP?

NQP (or Not Quite Perl 6) is an implementation of Perl 6 that is focused on creating compilers for the Parrot Compiler Toolkit. It is currently focused on targetting Parrot, but in the future, it may support various compilation targets, so you will be able to use Rakudo to compile your Perl 6 programs to Parrot opcodes, a JVM class file, or perhaps Javascript so you can run it in the browser. NQP is written in NQP, and uses a pre-compiled version of NQP to compile itself.

I hope that this information was useful to you, dear reader, and that it helps to clarify the different pieces of the Perl 6 ecosystem. As I learn more about each piece, I intend to write blog posts that will hopefully help others to get started contributing to Perl 6!

-Rob


Posted in  2012  |  1 Comment »
Day 16 – Operator precedence December 16, 2012
All the precedence men

As I was taking a walk today, I realized one of the reasons why I like Perl. Five as well as six. I often hear praise such as “Perl fits the way I think”. And I have that feeling too sometimes.

If I were the president (or prime minister, as I’m Swedish), and had a bunch of advisers, maybe some of them would be yes-men, trying to give me advice that they think I will want to hear, instead of advice that would be useful to me. Some languages are like that, presenting us with an incomplete subset of the necessary tools. The Perl languages, if they were advisers, wouldn’t be yes-men. They’d give me an accurate view of the world, even if that view would be a bit messy and hairy sometimes.

Which, I guess, is why Perl five and six are so often used in handling messy data and turning it into something useful.

To give a few specific examples:
Perl 5 takes quotes and quoting  very  seriously. Not just strings but lists of strings, too. (See the  qw  keyword.) Perl 6 does the same, but takes quoting further. See  see the recent post on quoting .
jnthn shows in  yesterday’s advent post  that Perl 6 takes compiler phases seriously, and allows us to bundle together code that belongs together conceptually but not temporally. We need to do this because the world is gnarly and running a program happens in phases.
Grammars in Perl 6 are not just powerful, but in some sense honest, too. They don’t oversimplify the task for the programmer, because then they would also limit the expressibility. Even though grammars are complicated and intricate, they  should  be, because they describe a process (parsing) that is complicated and intricate.
Operators

Perl is known for its many operators. Some would describe it as an “operator-oriented” language. Where many other language will try to guess how you want your operators to behave on your values, or perhaps demand that you pre-declare all your types so that there’ll be no doubt, Perl 6 carries much of the typing information in its operators:
my $a = 5;
my $b = 6;
 
say $a + $b;      # 11 (numeric addition)
say $a * $b;      # 30 (numeric multiplication)
 
say $a ~ $b;      # "56" (string concatenation)
say $a x $b;      # "555555" (string repetition)
 
say $a || $b;     # 5 (boolean disjunction)
say $a && $b;     # 6 (boolean conjunction)

Other languages will want to bunch together some of these for us, using the  +  operator for both numeric addition and string concatenation, for example. Not so Perl. You’re meant to choose yourself, because the choice matters. In return, Perl will care a little less about the types of the operands, and just deliver the appropriate result for you.

“The appropriate result” is most often a number if you used a numeric operator, and a string if you used a string operator. But sometimes it’s more subtle than that. Note that the boolean operators above actually preserved the numbers 5 and 6 for us, even though internally it treated them both as true values. In C, if we do the same, C will unhelpfully “flatten” these results down to the value 1, its spelling of the value  true . Perl knows that truthiness comes in many flavors, and retains the particular flavor for you. Operator precedence

“All operators are equal, but some operators are more equal than others.” It is when we combine operators that we realize that the operators have different “tightness”.
say 2 * 3 + 1;      # 7, because (2 * 3) + 1
say 1 + 2 * 3;      # 7, because 1 + (2 * 3), not 9

We can always be 100% explicit and surround enough of our operations with parentheses… but when we don’t, the operators seem to order themselves in some order, which is not just simple left-to-right evaluation. This ordering between operators is what we refer to as “precedence”.

No doubt you were taught in math class in school that multiplications should be evaluated before additions in the way we see above. It’s as if factors group together closer than terms do. The fact that this difference in precedence is useful is backed up by centuries of algebra notation. Most programming languages, Perl 6 included, incorporates this into the language.

By the way, this difference in precedence is found between other pairs of operators, even outside the realm of mathematics:
      Additive (loose)    Multiplicative (tight)
      ================    ======================
number      +                       *
string      ~                       x
bool        ||                      &&

It turns out that they make as much sense for other types as they do for numbers. And group theory bears this out: these other operators can be seen as a kind of addition and multiplication, if we squint. Operator precedence parser

Deep in the bowels of the Perl 6 parser sits a smaller parser which is very good at parsing expressions. The bigger parser which parses your Perl 6 program is a really good  recursive-descent  parser. It works great for creating syntax trees out of the larger program structure. It works less well on the level of expressions. Essentially, what trips up a recursive-descent parser is that it always has to create AST nodes for all the possible precedence levels, whether they’re present or not.

So this smaller parser is an  operator-table  parser. It knows what to do with each type of operator (prefix, infix, postfix…), and kind of weaves all the terms and operators into a syntax tree. Only the precedence levels actually used show up in the tree.

The optable parser works by comparing each new operator to the top operator on a stack of operators. So when it sees an expression like this:
$x ** 2 + 3 * $x - 5

it will first compare  **  against  +  and decide that the former is tighter, and thus  $x ** 2  should be put together into a small tree. Later, it compares  +  against  * , and decides to turn  3 * $x  into a small tree. It goes on like this, eventually ending up with this tree structure:
infix:<->
+-- infix:<+>
      +-- infix:<**>
      |    +-- term:<$x>
      |    +-- term:<2>
      +-- infix:<*>
           +-- term:<3>
           +-- term:<$x>

Because leaf nodes are evaluated first and the root node last, this tree structure determines the order of evaluation for the expression. The order ends up being the same as if the expression had these parentheses:
(($x ** 2) + (3 * $x)) - 5

Which, again, is what we’ve learned to expect. Associativity

Another factor also governs how these invisible parentheses are to be distributed: operator  associativity . It’s the concern of how the operator combines with multiple copies of itself, or other sufficiently similar operators on the same precedence level.

Some examples serve to explain the difference:
$x = $y = $z;     # becomes $x = ($y = $z)
$x / $y / $z;     # becomes ($x / $y) / $z

In both of these cases, we may look at the way the parentheses are doled out, and say “well, of course”. Of course we must first assign to $y  and only then to  $x . And of course we first divide by  $y  and only then by  $z . So operators naturally have different associativity.

The optable parser compares not just the precedence of two operators but also, when needed, their associativity. And it puts the parentheses in the right place, just as above. User-defined operators

Now we come back to Perl not being a yes-man, and working hard to give you the appropriate tools for the job.

Perl 6 allows you to define operators. See  my post from last year  on the details of how. But it also allows you to specify precedence and associativity of each new operator.

As you specify a new operator, a new Perl 6 parser is automatically constructed for you behind the scenes, which contains your new operator. In this sense, the optable parser is open and extensible. And Perl 6 gives you exactly the same tools for talking about precedence and associativity as the compiler itself uses internally.

Perl treats you like a grown-up, and expects you to make good decisions based on a thorough understanding of the problem space. I like that.


Posted in  2012  |  2 Comments »
Day 15 – Phasers set to stun December 15, 2012


When writing programs, it’s important not only to separate the concerns that need separating, but also to try and keep related things close to each other. This gives the program a sense of cohesion, and helps to avoid the inevitable problems that arise when updating one part of a program demands an update in another far-away part. One especially tricky problem can be when the things we want to do are distributed over time. This can cause us to move related things apart in order to get them to happen at the times we want.

Phasers in Perl 6 help you keep related concepts together in your code, while also indicating that certain aspects of them should happen at different points during the lifetime of the current program, invocation or loop construct. Let’s take a look at some of them. ENTER and LEAVE

One of the things I had most fun writing in Perl 6 recently was the debugger. There are various things that need a little care. For example, the debugger needs to look out for exceptions and, when they are thrown, give the user a prompt to let them debug why the exception was thrown. However, there is also a feature where, at the prompt, you can evaluate an expression. The debugger shouldn’t re-enter itself if this expression throws, so we need to keep track of if we’re already showing the prompt. This meant setting and clearing a flag. Thing is, the prompt method is relatively lengthy; it has a given/when to identify the various different commands. I could, of course, have set the prompt flag at the start and cleared it at the end. But that would have spread out the concern of maintaining the flag. Here’s what I did instead:
method issue_prompt($ctx, $cur_file) {
    ENTER $in_prompt = True;
    LEAVE $in_prompt = False;
 
    # Lots of stuff here
}

This ensures the flag is set when we enter the method, cleared when we leave the method – and lets me keep the two together. INIT and END

We’re writing a small utility and want to log what happens as we run it. Time wise, we want to:
Open the log file at the start of the program, creating it if needed and overwriting an existing one otherwise
Write log entries at various points during the program’s execution
Close the log file at the end


Those three actions are fairly spread out in time, but we’d like to collect them together. This time, the INIT and END phasers come to the rescue.
sub log($msg) {
    my $fh = INIT open("logfile", :w);
    $fh.say($msg);
    END $fh.close;
}

Here, we use INIT to perform an action at program start time. It turns out that INIT also keeps around the value produced by the expression following it, meaning it can be used as an r-value. This means we have the file handle available to us, and can write to it during the program. Then, at the END of the program, we close the file handle. All of these have block forms, should you wish to do something more involved:
sub log($msg) {
    my $fh = INIT open("logfile", :w);
    $fh.say($msg);
    END {
        $fh.say("Ran in {now - INIT now} seconds");
        $fh.close;
    }
}

Note the second use of INIT in this example, to compute and remember the program start time so we can use it in the subtraction later on. FIRST, NEXT and LAST

These phasers work with loops. They fire the first time the loop body executes, at the end of every loop body execution, and after the last loop body execution. FIRST and LAST are especially powerful in so far as they let us move code that wants to special-case the first and last time the loop body runs inside of the loop construct itself. This makes the relationship between these bits of code and the loop especially clear, and lessens the chance somebody moves or copies the loop and forgets the related bits it has.

As an example, let’s imagine we are rendering a table of scores from a game. We want to write a header row, and also do a little ASCII art to denote the start and end of the table. Furthermore, we’d like to keep track of the best score each time around the loop, and then at the end print out the best score. Here’s how we could write it.
for %scores.kv -> $player, $score {
    FIRST say "Score\tPlayer";
    FIRST say "-----\t------";
    LAST  say "-----\t------";
 
    NEXT (state $best_score) max= $score;
    LAST say "BEST SCORE: $best_score";
 
    say "$score\t$player";
}

Notice how we keep the header/footer code together, as well as being able to keep the best score tracking code together. It’s also all inside the loop, making its relationship to the loop clear. Note how the state variable also comes in useful here. It too is a construct that lets us keep a variable scoped inside a block even if its usage spans multiple invocations of the block. KEEP and UNDO

These are variants of LEAVE that trigger conditional on the block being successful (KEEP) or not (UNDO). A successful block completes without unhandled exceptions and returns a defined value. An unsuccessful block exits due to an exception or because it returns an undefined value. Say we were processing a bunch of files and want to build up arrays of successful files and failed files. We could write something like:
sub process($file) {
    KEEP push @success, $file;
    UNDO push @failure, $file;
 
    my $fh = open($file);
    # ...
}

There are probably a bunch of transaction-like constructs that can also be very neatly implemented with these two. And there’s more!

While I’ve covered a bunch of the phasers here, there are some others. For example, there’s also BEGIN, which lets you do some computation at compile time. Hopefully, though, this set of examples gives you some inspiration in how phasers can be used effectively, as well as a better grasp of the motivation for them. Bringing related things together and setting unrelated things apart is something we need to think carefully about every day as developers, and phasers help us keep related concerns together, even if they should take place at different phases of our program’s execution.

来源： < http://perl6advent.wordpress.com/2012/12/ >  