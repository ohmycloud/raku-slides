Day 05 – Changes in specification and operational fallout By   Liztormato


Perl 6 has become much more stable in the past year. There have however been some potentially disrupting changes to the Perl 6 specification, followed by implementation changes to adhere to that new spec. bless() changes

One of the most visible changes is the removal of an object candidate in bless(). If you wanted to call bless() yourself in your code, rather than supplying your own BUILD() method, you needed to provide an object candidate as the first parameter. Over the years, this turned out to basically always be * (as in Whatever). Which is pretty useless and an obstacle for future optimisations. So TimToady  invoked rule #2  to remove that first parameter.

The changes to calls to bless() in the core setting were implemented by moritz++. For those Perl 6 modules in the wild, a warning was added:
Passing an object candidate to Mu.bless is deprecated

The first parameter would then be removed and execution would continue.

This has the disadvantage of generating a warning  every  time you create an object of that class with the deprecated call to bless(). So there must be a better way to do this! Enter “is DEPRECATED”

It turns out there  is  a better way. Already in June 2012, pmichaud++  added an “is DEPRECATED” routine trait  that did nothing until earlier this year when I decided to add some functionality to it. Initially it was just a  warn , but that just had the same annoying quality as the warning with bless().

Since the idea behind the “is DEPRECATED” trait was not specced yet, I figured I could turn it any way I wanted, unless I would not be forgiven by the #perl6 crowd. So I re-used an idea I had had at former $work, already years ago. Instead of warning at the moment a transgression is spotted, it feels better, especially for these types of deprecations, to just remember  where  these transgressions take place. Only when the program is finished, report the transgressions that were spotted (on STDERR).

One of the other standard methods that has been deprecated in Perl 6, is ucfirst(). One should use the tc() (for “title case”) method instead. So what happens if you  do  call ucfirst()? That is easily demonstrated with a one-liner:
$ perl6 -e 'say "foo".ucfirst; say "done"'
Foo
done
Saw 1 call to deprecated code during execution.
================================================================================
Method ucfirst (from Cool) called at:
  -e, line 1
Please use 'tc' instead.
--------------------------------------------------------------------------------
Please contact the author to have these calls to deprecated code adapted,
so that this message will disappear!

After this has been live in the repo for a while, and spectested, and since nobody on #perl6 complained, I decided to  spec this behavior  not only for routines, but also for attributes and classes. Unfortunately, the latter ones have not been implemented yet (although you  can  already specify the traits). But there is a  patch -p1  coming up, which should give me some quality time to look at this. So why is bless(*) not properly DEPRECATED

Indeed. Why? Simply because I missed it. So I just fixed this: nothing like blog-driven development! So this one-liner now says:
$ perl6-p -e 'class A { method new { self.bless(*) } }; say A.new'
A.new()
Saw 1 call to deprecated code during execution.
================================================================================
Method bless (from Mu) called at:
  -e, line 1
Please use a call to bless without initial * parameter instead.
--------------------------------------------------------------------------------
Please contact the author to have these calls to deprecated code adapted,
so that this message will disappear! So how do you specify the text?

The “is DEPRECATED” trait currently takes one parameter: the string to be shown between  Please use  and  instead . If you don’t specify anything, the text  something else  will be assumed. Since that is not entirely useful, it is advised to always specify a text that makes sense in that context. Additional parameters may be added in the future to allow for more customisation, but so far they have not been needed. Conclusion

Perl 6 will continue to evolve. Changes  will  still be made. To not break early adopter’s code, any non-compatible changes in the implementation of Perl 6 can be marked as deprecated without interfering with the execution of existing programs much. Perl 6 module authors can do the same should they feel the need to change the API of their modules.

来源： < http://perl6advent.wordpress.com/2013/12/04/spec-changes-and-operational-fallout/ >  