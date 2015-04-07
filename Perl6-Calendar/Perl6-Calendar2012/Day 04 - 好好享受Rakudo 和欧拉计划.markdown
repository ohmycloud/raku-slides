Day 4 – Having Fun with Rakudo and Project Euler December 4, 2012


Rakudo, the leading Perl6 implementation, is not perfect, and performance is a particularly sore subject. However, the pioneer does not ask  ‘Is it fast?’ , but rather  ‘Is it fast enough?’ , or perhaps even  ‘How can I help to make it faster?’ .

To convince you that Rakudo can indeed be fast enough, we’ll take a shot at a bunch of  Project Euler  problems. Many of those involve brute-force numerics, and that’s something Rakudo isn’t particularly good at right now. However, that’s not necessarily a show stopper: The less performant the language, the more ingenious the programmer needs to be, and that’s where the fun comes in.

All code has been tested with Rakudo 2012.11.

We’ll start with something simple: Problem 2

By considering the terms in the Fibonacci sequence whose values do not exceed four million, find the sum of the even-valued terms.

The solution is beautifully straight-forward:
    say [+] grep * %% 2, (1, 2, *+* ...^ * > 4_000_000);

Runtime: 0.4s

Note how using operators can lead to code that’s both compact and readable (opinions may vary, of course). We used
whatever stars  *  to create lambda functions
the sequence operator (in its variant that excludes the right endpoint)  ...^  to build up the Fibonacci sequence
the divisible-by operator  %%  to grep the even terms
reduction by plus  [+]  to sum them.


However, no one forces you to go crazy with operators – there’s nothing wrong with vanilla imperative code: Problem 3

What is the largest prime factor of the number 600,851,475,143?

An imperative solution looks like this:

    sub largest-prime-factor($n is copy) {
        for 2, 3, *+2 ... * {
            while $n %% $_ {
                $n div= $_;
                return $_ if $_ > $n;
            }
        }
    }
 
    say largest-prime-factor(600_851_475_143);

Runtime: 2.6s

Note the  is copy  trait, which is necessary as Perl6 binds arguments read-only by default, and that integer division  div  is used instead of numeric division  / .

Nothing fancy going on here, so we’ll move along to Problem 53

How many, not necessarily distinct, values of  n C r , for 1 ≤ n ≤ 100, are greater than one-million?

We’ll use the feed operator  ==>  to factor the algorithm into separate steps:

    [1], -> @p { [0, @p Z+ @p, 0] } ... * # generate Pascal's triangle
    ==> (*[0..100])()                     # get rows up to n = 100
    ==> map *.list                        # flatten rows into a single list
    ==> grep * > 1_000_000                # filter elements exceeding 1e6
    ==> elems()                           # count elements
    ==> say;                              # output result

Runtime: 5.2s

Note the use of the  Z  meta-operator to zip the lists  0, @p  and  @p, 0 with  + .

The one-+ generating Pascal’s triangle has been stolen from Rosetta Code , another great resource for anyone interested in Perl6 snippets and exercises.

Let’s do something clever now: Problem 9

There exists exactly one Pythagorean triplet for which a + b + c = 1000. Find the product abc.

Using brute force  will work  (solution courtesy of Polettix), but it won’t be fast (~11s on my machine). Therefore, we’ll use a bit of algebra to make the problem more managable:

Let  (a, b, c)  be a Pythagorean triplet

    a < b < c
    a² + b² = c²

For  N = a + b + c  it follows

    b = N·(N - 2a) / 2·(N - a)
    c = N·(N - 2a) / 2·(N - a) + a²/(N - a)

which automatically meets  b < c .

The condition  a < b  gives the constraint
    a < (1 - 1/√2)·N

We arrive at

    sub triplets(\N) {
        for 1..Int((1 - sqrt(0.5)) * N) -> \a {
            my \u = N * (N - 2 * a);
            my \v = 2 * (N - a);
 
            # check if b = u/v is an integer
            # if so, we've found a triplet
            if u %% v {
                my \b = u div v;
                my \c = N - a - b;
                take $(a, b, c);
            }
        }
    }
 
    say [*] .list for gather triplets(1000);

Runtime: 0.5s

Note the declaration of sigilless variables  \N ,  \a , …, how  $(…)  is used to return the triplet as a single item and  .list  – a shorthand for $_.list  – to restore listy-ness.

The sub  &triplets  acts as a generator and uses  &take  to yield the results. The corresponding  &gather  is used to delimit the (dynamic) scope of the generator, and it could as well be put into  &triplets , which would end up returning a lazy list.

We can also rewrite the algorithm into dataflow-driven style using feed operators:

    constant N = 1000;
 
    1..Int((1 - sqrt(0.5)) * N)
    ==> map -> \a { [ a, N * (N - 2 * a), 2 * (N - a) ] }
    ==> grep -> [ \a, \u, \v ] { u %% v }
    ==> map -> [ \a, \u, \v ] {
        my \b = u div v;
        my \c = N - a - b;
        a * b * c
    }
    ==> say;

Runtime: 0.5s

Note how we use destructuring signature binding  -> […]  to unpack the arrays that get passed around.

There’s no practical benefit to use this particular style right now: In fact, it can easily hurt performance, and we’ll see an example for that later.

It  is  a great way to write down purely functional algorithms, though, which in principle would allow a sufficiently advanced optimizer to go wild (think of auto-vectorization and -threading). However, Rakudo has not yet reached that level of sophistication.

But what to do if we’re not smart enough to find a clever solution? Problem 47

Find the first four consecutive integers to have four distinct prime factors. What is the first of these numbers?

This is a problem where I failed to come up with anything better than brute force:

    constant $N = 4;
 
    my $i = 0;
    for 2..* {
        $i = factors($_) == $N ?? $i + 1 !! 0;
        if $i == $N {
            say $_ - $N + 1;
            last;
        }
    }

Here,  &factors  returns the number of prime factors. A naive implementations looks like this:

    sub factors($n is copy) {
        my $i = 0;
        for 2, 3, *+2 ...^ * > $n {
            if $n %% $_ {
                ++$i;
                repeat while $n %% $_ {
                    $n div= $_
                }
            }
        }
        return $i;
    }

Runtime: unknown (33s for N=3)

Note the use of  repeat while … {…} , the new way to spell  do {…} while(…); .

We can improve this by adding a bit of caching:

    BEGIN my %cache = 1 => 0;
 
    multi factors($n where %cache) { %cache{$n} }
    multi factors($n) {
        for 2, 3, *+2 ...^ * > sqrt($n) {
            if $n %% $_ {
                my $r = $n;
                $r div= $_ while $r %% $_;
                return %cache{$n} = 1 + factors($r);
            }
        }
        return %cache{$n} = 1;
    }

Runtime: unknown (3.5s for N=3)

Note the use of  BEGIN  to initialize the cache first, regardless of the placement of the statement within the source file, and  multi  to enable multiple dispatch for  &factors . The  where  clause allows dynamic dispatch based on argument value.

Even with caching, we’re still unable to answer the original question in a reasonable amount of time. So what do we do now? We cheat and use  Zavolaj  – Rakudo’s version of NativeCall – to  implement the factorization in C .

It turns out that’s still not good enough, so we refactor the remaining Perl code and add some native type annotations:

    use NativeCall;
 
    sub factors(int $n) returns int is native('./prob047-gerdr') { * }
 
    my int $N = 4;
 
    my int $n = 2;
    my int $i = 0;
 
    while $i != $N {
        $i = factors($n) == $N ?? $i + 1 !! 0;
        $n = $n + 1;
    }
 
    say $n - $N;

Runtime: 1m2s (0.8s for N=3)

For comparison, when implementing the algorithm completely in C, the runtime drops to under 0.1s, so Rakudo won’t win any speed contests just yet.

As an encore, three ways to do one thing: Problem 29

 a b  在 2 ≤ a ≤ 100 且 2 ≤ b ≤ 100 时能生成多少个不同的项?

   一个美丽但很慢的方法能用来检测其它解决方案是否正确：
    say +(2..100 X=> 2..100).classify({ .key ** .value });  # 9183

Runtime: 11s

Note the use of  X=>  to construct the cartesian product with the pair constructor  =>  to prevent flattening.

注意 =>的使用，使用 pair 构造操作符 => 来构造笛卡尔积，以防止被展开。

Because Rakudo supports big integer semantics, there’s no loss of precision when computing large numbers like 100 100 .

However, we do not actually care about the power’s value, but can use base and exponent to uniquely identify the power. We need to take care as bases can themselves be powers of already seen values:

    constant A = 100;
    constant B = 100;
 
    my (%powers, %count);
 
    # find bases which are powers of a preceeding root base
    # store decomposition into base and exponent relative to root
    for 2..Int(sqrt A) -> \a {
        next if a ~~ %powers;
        %powers{a, a**2, a**3 ...^ * > A} = a X=> 1..*;
    }
 
    # count duplicates
    for %powers.values -> \p {
        for 2..B -> \e {
            # raise to power \e
            # classify by root and relative exponent
            ++%count{p.key => p.value * e}
        }
    }
 
    # add +%count as one of the duplicates needs to be kept
    say (A - 1) * (B - 1) + %count - [+] %count.values;

Runtime: 0.9s

Note that the sequence operator  ...^  infers geometric sequences if at least three elements are provided and that list assignment %powers{…} = …  works with an infinite right-hand side.

Again, we can do the same thing in a dataflow-driven, purely-functional fashion:

    sub cross(@a, @b) { @a X @b }
    sub dups(@a) { @a - @a.uniq }
 
    constant A = 100;
    constant B = 100;
 
    2..Int(sqrt A)
    ==> map -> \a { (a, a**2, a**3 ...^ * > A) Z=> (a X 1..*).tree }
    ==> reverse()
    ==> hash()
    ==> values()
    ==> cross(2..B)
    ==> map -> \n, [\r, \e] { (r) => e * n }
    ==> dups()
    ==> ((A - 1) * (B - 1) - *)()
    ==> say();

Runtime: 1.5s

Note how we use  &tree  to prevent flattening. We could have gone with  X=>  instead of  X  as before, but it would make destructuring via  -> \n, [\r, \e]  more complicated.

As expected, this solution doesn’t perform as well as the imperative one. I’ll leave it as an exercise to the reader to figure out how it works exactly ;) That’s it

Feel free to add your own solutions to the  Perl6 examples repository under  euler/ .

If you’re interested in bioinformatics, you should take a look at Rosalind  as well, which also has its own (currently only sparsely populated) examples directory  rosalind/ .

Last but not least, some solutions for the  Computer Language Benchmarks Game  – also known as the Debian language shootout – can be found under  shootout/ .

You can contribute by sending pull requests, or better yet, join #perl6 on the Freenode IRC network and ask for a commit bit.

Have the appropriate amount of fun!


Posted in  2012  |  3 Comments »


 