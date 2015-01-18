Day 13 – Roasting Rakudo Star By   Coke
Roasting Rakudo Star

When is Perl 6 going to be Ready? We get this question a lot in the Perl 6 community, and the answer is never
as simple as we or the inquirers would like.

One part of the answer involves the specification; When we have an implementation that passes all of the tests marked “perl 6.0”, that will be  a  Perl 6.

Many people think of the specs as the  Synopses , but Patrick Michaud makes a good point that the specification is really more about the  tests .

Thus it was recognized early on (in Synopsis 1) that acceptance tests provide a far more objective measure of specification conformance than an English description. There are likely things that need to be “spec” that cannot be fully captured by testing… but I still believe that the test suite should be paramount.

Every language feature must have corresponding spec tests. Trying to find a test? Tests are broken up first by Synopsis (which themselves follow the numbering scheme of the Camel chapters), with multiple directories broken out by a group of features, then individual tests. For example, Synopsis 4 (S04) is about Blocks and Statements, including phasers. So to find the tests for the BEGIN phaser, you’ll want  S04-phasers/begin.t  in the roast suite.

We call the specification tests roast to follow in the tradition of “smoke test”, and also because TimToady can’t resist a punny backronym: “Repository Of All Spec Tests’.

Each of these files tries to thoroughly test something from the Synopsis including a lot of edge cases that aren’t necessarily mentioned in the prose. This goes to Patrick’s point about the tests being the more canonical answer about what the spec is. Are we there yet? Just a little further…  

So, how can we use these tests to determine if we’re done?

Each time a developer adds a feature or a language designer documents something in the Synopses, the team must add corresponding tests in roast – each change in the Synopses text may potentially increase the gap between prose and tests, and we have to regularly verify that both sets of documents are in agreement.

The tests even turn out to inform the prose, because they are concrete code – if you cannot write a coherent test, not just because it isn’t implemented in one of the compilers yet, but because it’s inefficient or breaks other tests, this will in turn require changes to the Synopses. Over the course of Perl 6′s development, compiler authors have pushed back on the specification in this way.

Before the compiler author checks in any code, ideally they should run the full spectest suite (roast) to insure not only their new tests work, but also that nothing else broke. This can be time consuming, so it’s possible they might just run a few test files for that particular feature or Synopsis.

So, despite best efforts, failing tests might be introduced. Even if you run all of roast, something might work on your compiler, but might have problems on another. Or another VM, or another OS, or hardware, or… So, there’s a need for regular testing that’s outside of the normal code/test/commit (or test/code/commit, if you like) workflow.

Speaking of other compilers and VMs, the current landscape of Perl 6 compilers is dominated by Rakudo. It has the most passing tests, two functioning backends (parrot and the JVM), a third on the way (MoarVM), and a possible fourth (JavaScript) landing in 2014. All of the virtual machines here support a wide variety of actual hardware and OSes. Niecza is another compiler, implemented in C#. It passes a substantial number of tests. We also test Pugs (targeting Haskell), but only for historical reasons. Roasting

It can take a while to build and run the full roast suite for even a single compiler, and we are trying to keep track of between four and six at the moment (And that’s just for one architecture!) So, with limited infrastructure, rather than have a continual integration, we setup a single daily run that builds the latest version of every compiler from a fresh checkout using a shared copy of roast (so we can compare like to like), and then saves out the information into a  github repository  so we can see the current state. Github provides a nice interface for viewing the  CSV data .

So, every day, we get a list of which test files are failing for each compiler/backend, which of the compilers is in the lead. When Rakudo/JVM started passing more spectests than Rakudo/Parrot, we were able see that  immediately  on the daily run.  Given the historical data available in the github repository, one could easily chart out things like ( click to embiggen )

number of passing tests per compiler/backend on the first of each month during 2013 Ecosystem  

But that’s just the compiler. The Rakudo team bundles a distribution called Rakudo Star (also spelled Rakudo *) that includes many modules from the Perl 6 ecosystem – kind of a mini-CPAN. This source distribution includes everything you need to build Rakudo from scratch and get a bunch of usable modules. Right now it’s Rakudo/Parrot, but work is being done for the distribution to support Rakudo/JVM and other backends.

We’ve had issues in the past where modules didn’t keep up with spec changes, and the person cutting the Star release would find issues with modules just before a release, causing delays.

Now we have a daily test that builds Rakudo Star, using the latest version of every module, Rakudo, NQP, and runs all the module tests, allowing us to catch any deprecation warnings or test errors as soon as they are made, rather than when we’re trying to cut a release. It’s  plain text  at the moment, but functions well as a warning indicator. Test to the Future

Two other projects are in place for testing:
Colomon has an ad hoc process that tests  all  the modules in the ecosystem, not just star.
japhb has created a  benchmark suite  to help us prevent performance regressions across the various compilers. Here’s a video presentation .


Going forward, we need to setup and encourage the use of a smoke server so that we can take the daily runs on the testing platform, and combine them with the results from other platforms, compilers, etc.

Drop by the #perl6 channel on freenode or leave a comment here if you want to chat more about testing!

来源： < http://perl6advent.wordpress.com/2013/12/13/day-13-roasting-rakudo-star/ >  