Day 15 – Numbers and ways of writing them By   Carl


Consider the humble integer.
my $number-of-dwarfs = 7;
say $number-of-dwarfs.WHAT;   # (Int)

Integers are great. (Well, many of them are.) Computers basically run on integers. Also, God made the integers, and everything else is basically cheap counterfeit knock-offs, smuggled into the Platonic realm when no-one’s looking. If they’re so important, we’d expect to have lots of good ways of writing them in any respectable programming language.

Do we have lots of ways of writing integers in Perl 6? We do. (Does that make Perl 6 respectable? No, because it’s a necessary but not sufficient condition. Duh.)

One thing we might want to do, for example, is write our numbers in other number bases. The need for this crops up now and then, for example if you’re stranded on Binarium where everyone has a total of two fingers:
my $this-is-what-we-humans-call-ten = 0b1010;   # 'b' for 'binary', baby
my $and-your-ten-is-our-two = 0b10;

Or you may find yourself on the multi-faceted world of Hexa X, whose inhabitants (due to an evolutionary arms race involving the act of tickling) sport 16 fingers each:
my $open-your-mouth-and-say-ten = 0xA;    # 'x' is for, um, 'heXadecimal'
my $really-sixteen = 0x10;

If you’re really unlucky, you will find yourself stuck in a file permissions factory, with no other means to signal the outer world than by using base 8:
my $halp-i'm-stuck-in-this-weird-unix-factory = 0o644;

(Fans of other C-based languages may notice the deviation from tradition here: for your own sanity, we no longer write the above number as  0644  — doing so rewards you with a stern (turn-offable) warning. Maybe octal numbers were once important enough to merit a prefix of just  0 , but they ain’t no more.)

Of course, just these bases are not enough. Sometimes you will need to count with a number of fingers that’s not any of 2, 8, or 16. For those special occasions, we have another nice syntax for you:
say :3<120>;       # 15 (== 1 * 3**2 + 2 * 3**1 + 0 * 3**0)
say :28<aaaargh>;  # 4997394433
say :5($n);        # let me parse that in base 5 for you

Yes, that’s the dear old pair syntax, here hijacked for base conversions  from  a certain base. You will recognize this special syntax by the fact that it uses colonpairs ( :3<120> ), not the "fat arrow" ( 3 => 120 ), and that the key is an integer. For the curious, the integer goes up to 36 (at which point we’ve reached ‘z’ in the alphabet, and there’s no natural way to make up more symbols for "digits").

I once used  :4($_)  to  translate DNA into proteins . Perl 6 — fulfilling your bioinformatics dreams!

Oh, and sometimes you want to convert  into  a certain base, essentially taking a good-old-integer and making it understandable for a being with a certain amount of fingers. We’ve got you covered there, too!
say 0xCAFEBABE;            # 3405691582
say 3405691582.base(16);   # CAFEBABE

Moving on. Perl 6 also has rationals.
my $tenth = 1/10;
say $tenth.WHAT;   # (Rat)

Usually computers (and programming languages) are pretty bad at representing numbers such as a tenth, because most of them are stranded on the planet Binarium. Not so Perl 6; it stores your rational numbers exactly, most of the time.
say (0, 1/10 ... 1);            # 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1
say (1/3 + 1/6) * 2;            # 1
say 1/10 + 1/10 + 1/10 == 0.3;  # True (\o/)

The rule here is, if you give some number as a decimal ( 0.5 ) or as a ratio ( 1/2 ), it will be represented as a  Rat . After that, Perl 6 does its darnedest to strike a balance between representing numbers without losing precision, and not losing too much performance in tight loops.

But sometimes you do reach for those lossy, precision-dropping, efficient numbers:
my $pi = 3.14e0;
my $earth-mass = 5.97e24;  # kg
say $earth-mass.WHAT;      # (Num)

You get floating-point numbers by writing things in the scientific notation ( 3.14e0 , where the  e0  means "times ten to the power of 0"). You can also get these numbers by doing some lossy calculation, such as exponentiation.

Do keep in mind that these are  not  exact, and will get you into trouble if you treat them as exact:
say (0, 1e-1 ... 1);             # misses the 1, goes on forever
say (0, 1e-1 ... * >= 1);        # 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 (oops)
say 1e0/10 + 1/10 + 1/10 == 0.3; # False (awww!)

So, don’t do that. Don’t treat them as exact, that is.

You’re  supposed  to be able to write lists of numbers really neatly with the good old Perl 6 quote-words syntax:
my @numbers = <1 2.0 3e0>;
say .WHAT for @numbers;          # (IntStr) (RatStr) (NumStr)

But this, unfortunately, is not implemented in Rakudo yet. (It is implemented in Niecza.)

If you’re into Mandelbrot fractals or Electrical Engineering, Perl 6 has complex numbers for you, too:
say i * i == -1;            # True
say e ** (i * pi) + 1;      # 0+1.22464679914735e-16i

That last one is  really close to 0 , but the exponentiation throws us into the imprecise realm of floating-point numbers, and we lose a tiny bit of precision. (But what’s a tenth of a quadrillionth between friends?)
my $googol = eval( "1" ~ "0" x 100 );
say $googol;                            # 1000…0 (exactly 100 zeros)
say $googol.WHAT;                       # (Int)

Finally, if you have a taste for the infinite, Perl 6 allows handing, passing, and storage of  Inf  as a constant, and it compares predictably against numbers:
say Inf;              # Inf
say Inf.WHAT;         # (Num)
say Inf > $googol;    # True
my $max = -Inf;
$max max= 5;          # (max= means "store only if greater")
say $max;             # 5

Perl 6 meets your future requirements by giving you alien number bases, integers and rationals with excellent precision, floating point and complex numbers, and infinities. This is what has been added — now go forth and multiply.

来源： < http://perl6advent.wordpress.com/2013/12/15/day-15-numbers-and-ways-of-writing-them/ >  