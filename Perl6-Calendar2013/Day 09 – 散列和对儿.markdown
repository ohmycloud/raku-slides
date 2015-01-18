Day 09 – Hashes and pairs By   Carl


Hashes are nice. They can work as a kind of “poor man’s objects” when creating a class seems like just too much ceremony for the occasion.
my $employee = {
    name => 'Fred',
    age => 51,
    skills => <sweeping accounting barking>,
};

Perl (both 5 and 6) takes hashes seriously. So seriously, in fact, that there’s a dedicated sigil for them, and by using it you can omit the braces in the above code:
my %employee =
    name => 'Fred',
    age => 51,
    skills => <sweeping accounting barking>,
;

Note that Perl 6, just as Perl 5, allows you to use barewords for hash keys. People coming from Perl 5 seem to expect that we’ve dropped this feature — I don’t know why, but I suspect that as much as they like the ability, they also feel that it’s secretly “dirty” or “wrong” somehow, and thus they just assume that hash keys need to be quotes in Perl 6. Don’t worry, fivers, you can omit the quotes there without any feelings of guilt!

Another nice thing is that final comma. Yes, Perl allows a comma even after the last hash entry. This makes rearranging lines later a lot less of a hair-pulling experience, because all lines have a final comma. So a big win for maintainability, and not a lot of extra bookkeeping for the Perl 6 parser.

Hashes make great “configuration objects”, too. You want to pass some options into a routine somewhere, but the options (for reasons of future compatibility, perhaps) need to be an open set.
my %options =
    rpm => 440,
    duration => 60,
;
$centrifuge.start(%options);

Actually, we have two options with that last line.  Either  we pass in the whole hash like that, and the method in the centrifuge class will need to look like this:
method start(%options) {
    # probably need to start by unpacking options here
    # ...
}

Or  we decide to “gut” the hash as we pass it in, effectively turning it into a bunch of named arguments:
$centrifuge.start( |%options );  # means :rpm(440), :duration(60)

In which case the method declaration will have to look like this instead:
method start(:$rpm!, :$duration!) {
    # ...
}

(In this case, we probably want to put in those exclamation marks, to make those named parameters obligatory. Unless we’re fine with providing some of them with a default, such as  :$duration = 120 .)

The “gut” operator  prefix:<|>  is really called “flattening” or “interpolation”. I really like how, in Perl 6, arrays flatten into positional parameters, and hashes flatten into named parameters. Decades after the fact, it gives some extra rationale to making arrays and hashes special enough to have their own sigils.
my @args = "Would you like fries with that?", 15, 5;
say substr(|@args);    # fries
 
my %details = :year(1969), :month(7), :day(16),
              :hour(20), :minute(17);
my $moonlanding = DateTime.new( |%details );

This brings us neatly into my next point: hash entries in Perl 6 really try to look like named parameters. They aren’t, of course, they’re just keys and values in a hash. But they try really hard to look the same. So much so that we even have *two* syntaxes for writing a hash entry. We have the fat-arrow syntax:
my %opts = blackberries => 42;

And we have the named argument syntax:
my %opts = :blackberries(42);

They each have their pros and cons. One of the nice things about the latter syntax is that it mixes nicely with variables, and (in case your variables are fortunately named) eliminates a bit of redundancy:
my $blackberries = 42;
my %opts = :$blackberries;   # means the same as :blackberries($blackberries)

We can’t do that in the fat-arrow syntax, not without repeating the word  blackberries . And no-one likes to do that.

So hash entries (a key plus a value) really become more of a thing in Perl 6 than they ever were in Perl 5. In Perl 5 they’re a bit of a visual hack, since the fat-arrow is just a synonym for the comma, and hashes are initialized through lists.

In Perl 6, hash entries are syntactically pulled into visual pills through the  :blackberries(42)  syntax, and even more so through the  :$blackberries  syntax. Not only that, but we’re passing hashes into routines entry by entry, making the entries stand out a bit more.

In the end, we give up and realize that we care a bunch about those hash entries as units, so we give them a name:  Pair . A hash is an (unordered) bunch of  Pair  objects.

So when you’re saying this:
say %employee.elems;

And the answer comes back “3″… that’s the number of  Pair objects in the hash that were counted.

But in the end,  Pair  objects even turn out to have a sort of independent existence, graduating from their role as hash constituents. For, example, you can treat them as cons pairs and simulate Lisp lists with them:
my $lisp-list = 1 => 2 => 3 => Nil;  # it's nice that infix:<< => >> is right-associative

And then, as a final trick, let’s dynamically extend the  Pair  class to recognize arbitrary cadr-like method calls. (Note that .^add_fallback  is not in the spec and currently Rakudo-only.)
Pair.^add_fallback(
    -> $, $name { $name ~~ /^c<[ad]>+r$/ },  # should we handle this? yes, if /^c<[ad]>+r$/
    -> $, $name {                            # if it turned out to be our job, this is what we do
        -> $p {
            $name ~~ /^c(<[ad]>*)(<[ad]>)r$/;        # split out last 'a' or 'd'
            my $r = $1 eq 'a' ?? $p.key !! $p.value; # choose key or value
            $0 ?? $r."c{$0}r"() !! $r;               # maybe recurse
        }
    }
);
 
$lisp-list.caddr.say;    # 3

Whee!

来源： < http://perl6advent.wordpress.com/2013/12/09/day-09-hashes-and-pairs/ >  