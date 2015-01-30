# Day 22 每 The Cool subset of MAIN.

by venndethiel
In the Unix environment, many scripts take arguments and options from the command line. With Perl 6 it＊s very easy to accept those. At least, that＊s what Our 2010 advent post on MAIN says.

But today, we＊re interested in going further, and we＊re going to try to gain more expressiveness from it.
The first Perl 6 feature we＊re going to look at here is subsets. Subsets have a very broad range of applications, but they＊re even better when used in conjunction with MAIN.

Subsets are a declarative way to specify conditions on your type. If you wanted to translate ※A QuiteSmallInt is an Int with a value lesser than 10∪, you can write

subset QuiteSmallInt where * < 10;
In case you don＊t remember from our 2010 advent post about smart matching or our 2011 advent post about multi-method dispatch, here＊s a quick reminder of how you can use subsets with smart matching, multi-method dispatch or typed variables.

say 9 ~~ QuiteSmallInt; # True
say 11 ~~ QuiteSmallInt; # False

multi sub small-enough(QuiteSmallInt) { say "Yes!" }
multi sub small-enough($) { say "No, too big."; }

small-enough(9); # Prints "Yes!"
small-enough(11); # Prints "No, too big."

# You can also use it to type variables
my QuiteSmallInt $n = 9; # Works!
my QuiteSmallInt $n = 11; # Errors out with "Type check failed in assignment to '$n'; ..."
Alright; now that we got this out of the way, what does this buy us?
Well, as we just demonstrated, we can dispatch to different subroutines using those ※where§ conditions.
That goes for MAIN as well.

Say we wanted to take a filepath as the first argument of a MAIN. We＊ll also write two ※companions§ that＊ll give a descriptive error message in case we pass bad arguments.

# a File is a string containing an existing filename
subset File of Str where *.IO.e; # .IO returns an IO::Path object, and .e is for "exists"
subset NonFile of Str where !*.IO.e;

multi sub MAIN(File $move-from, NonFile $move-to) {
  rename $move-from, $move-to;
  say "Moved!";
}
multi sub MAIN($, File $) {
  say "The destination already exists";
}
multi sub MAIN(NonFile $, $) {
  say "The source file doesn't exist";
}
And now, if we try to use it (after saving it as ※main.p6∪)＃

$ touch file1.txt
$ perl6 ./main.p6 file1.txt destination.txt
Moved!
$ perl6 ./main.p6 non-existant.p6 non-existant.txt
The source file doesn't exist!
$ perl6 ./main.p6 destination.txt destination.txt
The destination already exists
Alright, looks good. There＊s a little catch, however: the 每help will display 3 usages, when there＊s only one.

$ perl6 ./main.p6 --help
Usage:
tmp.p6 <move-from> <move-to>
tmp.p6 <Any> (File)
tmp.p6 (NonFile) <Any>
Whoops! We need to find a way to hide them (if you＊re wondering, the ※<Any>§ is because the arguments both are unnamed and untyped).
Luckily enough, Perl6 provides a trait for that: hidden_from_USAGE, added by moritz++ for this advent post (USAGE is the 每help message).

Let＊s add those to our MAINs.

multi sub MAIN(File $move-from, NonFile $move-to) {
  rename $move-from, $move-to;
  say "Moved!";
}
multi sub MAIN($, File $) is hidden_from_USAGE {
  say "The destination already exists";
}
multi sub MAIN(NonFile $, $) is hidden_from_USAGE {
  say "The source file doesn't exist";
}
And now, the USAGE is correct:

$ perl6 ./main.p6 --help
Usage:
tmp.p6 <move-from> <move-to>
Okay, now, we just need to add a description.

The second Perl6 feature we＊re going to use is Pod.
Pod is an easy-to-use markup language, which you can embed to document your code.

#= Rename a file
multi sub MAIN(File $move-from, NonFile $move-to) {
  rename $move-from, $move-to;
  say "Moved!";
}

# You can write it in multiple lines, though in USAGE they'll be collapsed
# (joined by a space)

#={Rename
a
file}
multi sub MAIN(File $move-from, NonFile $move-to) {
  rename $move-from, $move-to;
  say "Moved!";
}
Both versions above will print the same 每help:

$ perl6 ./main.p6 --help
Usage:
tmp.p6 <move-from> <move-to> -- Rename a file
And now you have everything you need to create a nice CLI interface :-).