title: Perl 6 Examples

date: 2015-08-23T23:59:26Z

tags: Perl6

categories: Perl 6

------

<blockquote class='blockquote-center'>总是学不会 再聪明一点 记得自我保护 必要时候讲些 善意谎言 — 学不会·林俊杰</blockquote>



## 斐波拉契数列（Fibonacci Sequence）

- analytic

``` perl
use v6;

sub fibonacci (Int $n where 0..*  --> Int) {
    constant phi = (1 + sqrt 5) / 2;

    return round( phi**($n+1) / sqrt 5);
}

for 0..1000 -> $i {
    say $i.fmt('%3d'), ': ', fibonacci($i);
}

```

这种方法计算前1000个斐波拉契数大约为0.746s（2015.7.Rakudo, 以下都是）。

- 迭代

``` perl
use v6;

sub fibonacci (Int $n) {
    state @sequence = 1,1;

    while @sequence.elems <= $n {
        @sequence.push( @sequence[*-2] + @sequence[*-1] );
    }

    return @sequence[$n];
}

for 0..1000 -> $i {
    say $i.fmt('%3d'), ': ', fibonacci($i);
}
```

这种遍历法大概需要 1 秒多。

- 递归

``` perl
use v6;

sub fibonacci (Int $n where 0..*) {
    if $n == 0 | 1 {
        return 1;
    }
    else {
        return fibonacci($n-1) + fibonacci($n-2);
    }
}

for 0..1000 -> $i {
    say $i.fmt('%3d'), ': ', fibonacci($i);
}
```

比较慢。第 20 个之后越来越慢。

- 递归 - 超运算符

``` perl
sub fibonacci (Int $n where 0..*) {
    if $n == 0 | 1 {
        return 1;
    }
    else {
        return [+] ($n-1, $n-2)».&fibonacci;
    }
}

for 0..1000 -> $i {
    say $i.fmt('%3d'), ': ', fibonacci($i);
}
```

和上面差不多。

- 递归 - map

``` perl
sub fibonacci (Int $n where 0..*) {
    if $n == 0 | 1 {
        return 1;
    }
    else {
        return [+] map &fibonacci, ($n-1, $n-2);
    }
}

for 0..1000 -> $i {
    say $i.fmt('%3d'), ': ', fibonacci($i);
}
```

同上。

- 递归 - multi

``` perl
use v6;

multi fibonacci (0)  { 1 }

multi fibonacci (1)  { 1 }

multi fibonacci (Int $n --> Int) {
    return fibonacci($n-1) + fibonacci($n-2);
}

for 0..1000 -> $i {
    say $i.fmt('%3d'), ': ', fibonacci($i);
}
```

比上一个稍快。

- 递归 - multi_cached

``` perl
multi fibonacci (0)  { 1 }

multi fibonacci (1)  { 1 }

my %cached;
multi fibonacci (Int $n --> Int) {
    return %cached{$n} //= fibonacci($n-1) + fibonacci($n-2);
}

for 0..1000 -> $i {
    say $i.fmt('%3d'), ': ', fibonacci($i);
}
```

0.849s 执行完毕。

- 递归 - multi_cached_state

``` perl
multi fibonacci (0)  { 1 }

multi fibonacci (1)  { 1 }

multi fibonacci (Int $n --> Int) {
    state %cached;
    return %cached{$n} //= fibonacci($n-1) + fibonacci($n-2);
}

for 0..1000 -> $i {
    say $i.fmt('%3d'), ': ', fibonacci($i);
}
```

0.885s

- 递归 - multi_cached_trait

``` perl
multi fibonacci (0)  { 1 }

multi fibonacci (1)  { 1 }

multi fibonacci (Int $n --> Int) is cached {
    fibonacci($n-1) + fibonacci($n-2);
}

for 0..1000 -> $i {
    say $i.fmt('%3d'), ': ', fibonacci($i);
}
```

目前报错。

- 序列

``` perl
use v6;

sub fibonacci (Int $n) {
    constant @sequence :=  1, 1, *+* ... *;

    return @sequence[$n];
}

for 0..1000 -> $i {
    say $i.fmt('%3d'), ': ', fibonacci($i);
}
```

1.6s多。 其中 `:=` 是惰性赋值。按需求值。

- 序列 - inline

``` perl
sub fibonacci (Int $n) {
    (1, 1, *+* ... *)[$n];
}

for 0..1000 -> $i {
    say $i.fmt('%3d'), ': ', fibonacci($i);
}
```

Finished in 133.808s.



## 排序

- bogosort

``` perl
#! /usr/bin/env perl6
use v6;

sub bogosort ( *@list ) {

    until [!after] @list {
        @list .= pick(*);
    }

    return @list;
}

#my @data = 6, 7, 2, 1, 8, 9, 2;
my @data =  < p e r l s i x >;

say 'input  = ' ~          @data;
say 'output = ' ~ bogosort @data;
```

输出：

``` 
input  = p e r l s i x
output = e i l p r s x
[Finished in 1.326s]
```

- mergesort

``` perl
#! /usr/bin/env perl6
use v6;

sub merge (@a, @b) {
    gather while @a && @b {
        if @a[0] before @b[0] { take @a.shift }
        else                  { take @b.shift }
    },
    @a,
    @b;
}

sub mergesort ( *@list ) {
    return @list if @list.elems <= 1;

    my $middle = @list.elems div 2;
    my @left   = mergesort @list[ 0 ..^ $middle ];
    my @right  = mergesort @list[ $middle .. *  ];

    return merge(@left, @right);
}

# my @data = 6, 7, 2, 1, 8, 9, 5, 3, 4;
my @data = < p e r l s i x >;

say "input  = {           @data  }";
say "output = { mergesort(@data) }";
```

输出：

``` 
input  = p e r l s i x
output = e i l p r s x
[Finished in 0.337s]
```

- mergesort_functional

``` perl
#! /usr/bin/env perl6
use v6;

multi merge ([], @ys) { @ys }

multi merge (@xs, []) { @xs }

multi merge ([$x, *@xs], [$y, *@ys]) {
    $x before $y ?? ($x, merge @xs, [$y, @ys])
                 !! ($y, merge [$x, @xs], @ys)
}


multi mergesort ( [] ) {  []  }

multi mergesort ([$x]) { [$x] }

multi mergesort (@xs)  {
    merge
        mergesort( @xs[0 ..^ @xs.elems div 2] ),
        mergesort( @xs[@xs.elems div 2 .. * ] )
}

 my @data = 6, 7, 2, 1, 8, 9, 5, 3, 4;
#my @data = < p e r l s i x >;

say "input  = {           @data  }";
say "output = { mergesort(@data) }";
```

输出：

``` 
input  = 6 7 2 1 8 9 5 3 4
output = 1 2 3 4 5 6 7 8 9
[Finished in 0.373s]
```

- mergesort_functional_given

``` perl
#! /usr/bin/env perl6
use v6;

multi merge ([], @ys) { @ys }

multi merge (@xs, []) { @xs }

multi merge ([$x, *@xs], [$y, *@ys]) {
    $x before $y ?? ($x, merge @xs, [$y, @ys])
                 !! ($y, merge [$x, @xs], @ys)
}


multi mergesort ( [] ) {  []  }

multi mergesort ([$x]) { [$x] }

multi mergesort (@xs)  {
    given @xs.elems div 2 -> $middle {
        merge
            mergesort( @xs[ 0 ..^ $middle ] ),
            mergesort( @xs[ $middle .. *  ] )
    }
}


 my @data = 6, 7, 2, 1, 8, 9, 5, 3, 4;
#my @data = < p e r l s i x >;

say "input  = {           @data  }";
say "output = { mergesort(@data) }";
```

输出：

``` 
input  = 6 7 2 1 8 9 5 3 4
output = 1 2 3 4 5 6 7 8 9
[Finished in 0.375s]
```

- mergesort_functional_interleaved

``` perl
#! /usr/bin/env perl6
use v6;

multi merge ([], @ys) { @ys }

multi merge (@xs, []) { @xs }

multi merge ([$x, *@xs], [$y, *@ys]) {
    $x before $y ?? ($x, merge @xs, [$y, @ys])
                 !! ($y, merge [$x, @xs], @ys)
}


multi mergesort ( [] ) {  []  }

multi mergesort ([$x]) { [$x] }

multi mergesort (@xs)  {
    merge
        mergesort( @xs[0,2...*] ),
        mergesort( @xs[1,3...*] )
}

 my @data = 6, 7, 2, 1, 8, 9, 5, 3, 4;
#my @data = < p e r l s i x >;

say "input  = {           @data  }";
say "output = { mergesort(@data) }";
```

输出：

``` 
input  = 6 7 2 1 8 9 5 3 4
output = 1 2 3 4 5 6 7 8 9
[Finished in 0.34s]
```



- quicksort



``` perl
#! /usr/bin/env perl6
use v6;

sub quicksort( *@list ) {
    return @list if @list.elems < 2;

    my $pivot = @list.shift;
#     my $pivot = @list.=pick(*).shift;

    my (@before, @after);
    for @list -> $elem {
        if $elem before $pivot { @before.push($elem); }
        else                   { @after.push($elem);  }
    }

    return quicksort(@before),
           $pivot,
           quicksort(@after);
}

#my @data = 6, 7, 2, 1, 8, 9, 5, 3, 4;
my @data = < p e r l s i x >;

say "input  = {           @data  }";
say "output = { quicksort(@data) }";
```

输出：

``` 
input  = p e r l s i x
output = e i l p r s x
[Finished in 0.246s]
```

- quicksort_classify

``` perl
#! /usr/bin/env perl6
use v6;

multi quicksort(  []  ) {    };
multi quicksort(  Mu  ) {    };

multi quicksort( [$x] ) { $x };

multi quicksort( [$pivot, *@xs] ) {
    given @xs.classify:{ $^elem before $pivot ?? 'pre' !! 'post'} {
        quicksort( .<pre>  ),
        $pivot,
        quicksort( .<post> );
    }
}

#my @data = 6, 7, 2, 1, 8, 9, 5, 3, 4;
my @data = < p e r l s i x >;

say "input  = {           @data  }";
say "output = { quicksort(@data) }";
```

输出：

``` 
input  = p e r l s i x
output =  e i  l p  r  s x
[Finished in 0.303s]
```



- quicksort_functional

``` perl
#! /usr/bin/env perl6
use v6;

multi quicksort(  []  ) {    };

multi quicksort( [$x] ) { $x };

multi quicksort( [$pivot, *@xs] ) {
    quicksort(@xs.grep: * before $pivot),
    $pivot,
    quicksort(@xs.grep: * !before $pivot);
}

#my @data = 6, 7, 2, 1, 8, 9, 5, 3, 4;
my @data = < p e r l s i x >;

say "input  = {           @data  }";
say "output = { quicksort(@data) }";
```

输出:

``` 
input  = p e r l s i x
output =  e i l  p  r  s x
[Finished in 0.27s]
```



## pm 模块

首先把自定义的 Bank.pm 模块复制到 Perl 6 的 lib 目录下：

``` perl
cp Bank.pm /Users/chenyf/.rakudobrew/moar-nom/install/share/perl6/site/lib
```

Bank.pm

``` perl
#! /usr/bin/perl6
use v6;

class Ident {
    subset Pattern of Str where / \d**3 '-' \d**3 '-' \d**3 /;

    has Str $.name              = '????';
    has Str $.ID  where Pattern = '000-000-000';
}

role Taxable [:$THRESHOLD = 100_000] {
    constant GENERAL_TAX_RATE = 0.01;

    has %.tax_record;

    method tax_credits {...}

    method calculate_tax () {
        my $tax_payable = ($.balance min $THRESHOLD) * GENERAL_TAX_RATE 
                          - $.tax_credits;

        %!tax_record{now} = $tax_payable;

        return $tax_payable;
    }
}

class Account
    does Taxable
{
    subset ID of Str where / <alpha>**4 <digit>**5 /;

    state ID $next_account_ID = 'AAAA00001';

    has Str     $.name        = die 'Must provide account name';
    has Numeric $.balance     = 0;
    has ID      $.ID          = $next_account_ID++;

    method deposit(Numeric $amount where *>0) {
        $!balance += $amount;
    }

    method withdraw(Numeric $amount where *>0) {
        fail "Insufficient funds to withdraw $amount"
            if $.balance < $amount;
        $!balance -= $amount;
    }

    method description () {
        "$.ID ($.name): balance=$.balance";
    }

    method tax_credits { 0 }
}

class Bank {
    has Ident   $!ident     handles< name ID >;
    has Account %!accounts;

    submethod BUILD (|args) {
        $!ident .= new(|args);
    }

    method add_account(Account $account) {
        %!accounts{$account.ID} = $account;
    }

    method close_account(Str $ID) {
        return %!accounts{$ID} :delete
            // fail "No such account";
    }

    multi method get_account(Account::ID $ID) {
        return %!accounts{$ID} // fail "No such account";
    }

    multi method get_account(Any $name) {
#        return %!accounts.values.grep({.name ~~ $name});
        self.for_each_account({.take if .name ~~ $name});
    }

    method for_each_account (&action_on) {
        gather for %!accounts.values -> $account is rw {
            action_on($account);
        }
    }

    method collect_taxes () {
        self.for_each_account: {
            my $tax = .calculate_tax();
            .withdraw($tax);
            take .ID => $tax;
        }
    }

    method report () {
        say "[ {self.ID} [{self.name}] ]";         # Or: say "[ $.ID [$.name] ]";
        self.for_each_account(*.description.say);
        say '';
    }
}


class Account::Corporate
    is Account
    does Taxable[THRESHOLD => 1_000_000]
{
    has Str $.company_ID;

    method tax_credits { 5_000 }

    method description () {
        callsame() ~ "  [$.company_ID]";
    }
}
```

该模块的功能是计算银行存款汇率等。下面使用这个模块：



- demo

``` perl
#! /usr/bin/env perl6
use v6;

use Bank;

my Bank $bank .= new(:ID('123-456-789'));

$bank.add_account: Account.new(:name('Leslie Grace')                  );
$bank.add_account: Account.new(:name('Dana McKenna'), :balance(10_000));
$bank.add_account: Account.new(:name('AstroDynamic'), :balance(   2e7));
$bank.add_account: Account.new(:name('Jan van Quod'), :balance( 9_999));
$bank.add_account: Account.new(:name('OmniCorp LLC'), :balance(   1e6));
$bank.report;

$bank.get_account('AAAA00003').deposit(100);
$bank.get_account('Jan van Quod')».deposit(2);
$bank.get_account(/D.na/)».deposit(2);
#$bank.get_account(*)».deposit(99);
$bank.report;

given $bank.close_account('AAAA00005') {
    say "Closed $^account.perl()\n";
    $bank.report;
}

$bank.close_account('ZZZZ99999');

$bank.get_account('AAAA00001').withdraw(1001);
$bank.report;
```

输出：

``` perl
[ 123-456-789 [????] ]
AAAA00004 (Jan van Quod): balance=9999
AAAA00001 (Leslie Grace): balance=0
AAAA00005 (OmniCorp LLC): balance=1000000
AAAA00002 (Dana McKenna): balance=10000
AAAA00003 (AstroDynamic): balance=20000000

[ 123-456-789 [????] ]
AAAA00004 (Jan van Quod): balance=10001
AAAA00001 (Leslie Grace): balance=0
AAAA00005 (OmniCorp LLC): balance=1000000
AAAA00002 (Dana McKenna): balance=10002
AAAA00003 (AstroDynamic): balance=20000102

Closed Account.new(name => "OmniCorp LLC", balance => 1000000e0, ID => "AAAA00005", tax_record => {}<>)

[ 123-456-789 [????] ]
AAAA00004 (Jan van Quod): balance=10001
AAAA00001 (Leslie Grace): balance=0
AAAA00002 (Dana McKenna): balance=10002
AAAA00003 (AstroDynamic): balance=20000102

No such account
  in method close_account at /Users/chenyf/.rakudobrew/moar-nom/install/share/perl6/site/lib/Bank.pm:67
  in block <unit> at /Users/chenyf/Downloads/Perl6_Transparadigm_examples/04.bank_demo.pl:26

Actually thrown at:
  in block <unit> at /Users/chenyf/Downloads/Perl6_Transparadigm_examples/04.bank_demo.pl:26

[Finished in 0.768s]
```



- demo_inheritance

``` perl
#! /usr/bin/env perl6
use v6;

sub show ($text) {
    say '';
    say ('____/ ' ~ $text ~ ' \_________________________________________________').substr(0,50);
}

use Bank;

my Bank $bank .= new(:ID('123-456-789'), :name('Bank of Evil'));

$bank.add_account: Account.new(:name('Leslie Grace'), :balance( 1_000));
$bank.add_account: Account.new(:name('Dana McKenna'), :balance(10_000));
$bank.add_account: Account.new(:name('Jan van Quod'), :balance( 9_999));

$bank.add_account: Account::Corporate.new(:name('AstroDynamic'), :balance(2e7) :company_ID('ASDY'));
$bank.add_account: Account::Corporate.new(:name('OmniCorp LLC'), :balance(1e6) :company_ID('OMNI'));

show 'Status';
$bank.report;

show 'Taxes collected';
.say for $bank.collect_taxes();

show 'Status';
$bank.report;

$bank.collect_taxes();

show 'Tax records';
$bank.for_each_account({ say .name, ': ', .tax_record });

show 'Culling acounts';
given $bank {
    .for_each_account: {
        .close_account($^account.ID).say
            if $^account.balance < 10_000;
    }
}

show 'Status';
$bank.report;
```

输出：

``` perl
____/ Status \____________________________________
[ 123-456-789 [Bank of Evil] ]
AAAA00004 (AstroDynamic): balance=20000000  [ASDY]
AAAA00001 (Leslie Grace): balance=1000
AAAA00005 (OmniCorp LLC): balance=1000000  [OMNI]
AAAA00002 (Dana McKenna): balance=10000
AAAA00003 (Jan van Quod): balance=9999


____/ Taxes collected \___________________________
AAAA00004 => 5000
AAAA00001 => 10
AAAA00005 => 5000
AAAA00002 => 100
AAAA00003 => 99.99

____/ Status \____________________________________
[ 123-456-789 [Bank of Evil] ]
AAAA00004 (AstroDynamic): balance=19995000  [ASDY]
AAAA00001 (Leslie Grace): balance=990
AAAA00005 (OmniCorp LLC): balance=995000  [OMNI]
AAAA00002 (Dana McKenna): balance=9900
AAAA00003 (Jan van Quod): balance=9899.01

____/ Tax records \_______________________________
AstroDynamic: Instant:1440413601.447466 => 5000, Instant:1440413601.463112 => 5000
Leslie Grace: Instant:1440413601.450753 => 10, Instant:1440413601.465823 => 9.9
OmniCorp LLC: Instant:1440413601.452933 => 5000, Instant:1440413601.468346 => 4950
Dana McKenna: Instant:1440413601.454860 => 100, Instant:1440413601.470238 => 99
Jan van Quod: Instant:1440413601.457399 => 99.99, Instant:1440413601.471551 => 98.9901
____/ Culling acounts \___________________________
Account.new(name => "Leslie Grace", balance => 980.1, ID => "AAAA00001", tax_record => {"Instant:1440413601.450753" => 10.0, "Instant:1440413601.465823" => 9.9}<>)
Account.new(name => "Dana McKenna", balance => 9801.0, ID => "AAAA00002", tax_record => {"Instant:1440413601.454860" => 100.0, "Instant:1440413601.470238" => 99.0}<>)
Account.new(name => "Jan van Quod", balance => 9800.0199, ID => "AAAA00003", tax_record => {"Instant:1440413601.457399" => 99.99, "Instant:1440413601.471551" => 98.9901}<>)

____/ Status \____________________________________
[ 123-456-789 [Bank of Evil] ]
AAAA00004 (AstroDynamic): balance=19990000  [ASDY]
AAAA00005 (OmniCorp LLC): balance=990050  [OMNI]

[Finished in 0.817s]
```



- demo_unary_dot

``` perl
#! /usr/bin/env perl6
use v6;

use Bank;

my Bank $bank .= new(:ID('123-456-789'));

given $bank {
    .add_account: Account.new(:name('Leslie Grace'), :balance( 1_000));
    .add_account: Account.new(:name('Dana McKenna'), :balance(10_000));
    .add_account: Account.new(:name('AstroDynamic'), :balance(   2e7));
    .add_account: Account.new(:name('Jan van Quod'), :balance( 9_999));
    .add_account: Account.new(:name('OmniCorp LLC'), :balance(   1e6));
    .report;

    .get_account('AAAA00003').deposit(100);
    .report;

    say .close_account('AAAA00005');
    .report;

    .get_account('AAAA00001').withdraw(1001);
    .report;
}
```

输出：

``` perl
[ 123-456-789 [????] ]
AAAA00004 (Jan van Quod): balance=9999
AAAA00001 (Leslie Grace): balance=1000
AAAA00005 (OmniCorp LLC): balance=1000000
AAAA00002 (Dana McKenna): balance=10000
AAAA00003 (AstroDynamic): balance=20000000

[ 123-456-789 [????] ]
AAAA00004 (Jan van Quod): balance=9999
AAAA00001 (Leslie Grace): balance=1000
AAAA00005 (OmniCorp LLC): balance=1000000
AAAA00002 (Dana McKenna): balance=10000
AAAA00003 (AstroDynamic): balance=20000100

Account.new(name => "OmniCorp LLC", balance => 1000000e0, ID => "AAAA00005", tax_record => {}<>)
[ 123-456-789 [????] ]
AAAA00004 (Jan van Quod): balance=9999
AAAA00001 (Leslie Grace): balance=1000
AAAA00002 (Dana McKenna): balance=10000
AAAA00003 (AstroDynamic): balance=20000100

Insufficient funds to withdraw 1001
  in method withdraw at /Users/chenyf/.rakudobrew/moar-nom/install/share/perl6/site/lib/Bank.pm:43
  in block <unit> at /Users/chenyf/Downloads/Perl6_Transparadigm_examples/04.bank_demo_unary_dot.pl:22

Actually thrown at:
  in block <unit> at /Users/chenyf/Downloads/Perl6_Transparadigm_examples/04.bank_demo_unary_dot.pl:22

[Finished in 0.738s]
```

## LZW

[LZW算法](http://baike.baidu.com/view/401141.htm)



- demo

``` perl
#! /usr/bin/env perl6
use v6;

sub compress(Str $uncompressed --> List)  {
    # Build a look-up table of encoded representations
    # (each ASCII char represented by its equivalent codepoint)
    my %code_for = map { $^ASCII.chr => $^ASCII }, ^256;

    # Loop and collect each encoding...
    gather {
        # Track which characters we've seen but not yet encoded
        my $already_seen = "";

        # Walk through each single character...
        for $uncompressed.comb -> $next_char {
            # Now we've seen that next character as well
            my $now_seen = $already_seen ~ $next_char;

            # If new char sequence is known, keep looking
            if %code_for{$now_seen}:exists {
                $already_seen = $now_seen;
            }
            # Otherwise, we have an unknown sequence of chars
            else {
                # Emit encoding for what we've previously seen
                take %code_for{$already_seen};
                # Add encoding for new unknown sequence to table
                %code_for{$now_seen} = %code_for.elems;
                # Restart the current sequence from this char
                $already_seen = $next_char;
            }
        }
        # Emit the encoding for the final sequence (if any)
        take %code_for{$already_seen} if $already_seen ne "";
    }
}

# Convert to codepoints...
my @codes = compress('To be or not to be. That be the question, matey!');
say @codes;
separator;

# Emit as characters...
say @codes>>.chr;
separator;

# Convert to a binary sequence...
my $bits_per_code = @codes.max.log(2).ceiling();
my $format = '%0' ~ $bits_per_code ~ 'b';
my $bits = @codes>>.fmt($format).join;
say $bits;
separator;

say $bits.comb(/.**1..7/).map({:2($^bitpattern).chr}).join;
separator;





sub separator { say '_' x 50 }
```

输出：

``` perl
84 111 32 98 101 32 111 114 32 110 111 116 32 116 257 259 46 32 84 104 97 267 259 268 104 260 113 117 101 115 116 105 111 110 44 32 109 276 101 121 33
__________________________________________________
T o   b e   o r   n o t   t ā ă .   T h a ċ ă Č h Ą q u e s t i o n ,   m Ĕ e y !
__________________________________________________
001010100001101111000100000001100010001100101000100000001101111001110010000100000001101110001101111001110100000100000001110100100000001100000011000101110000100000001010100001101000001100001100001011100000011100001100001101000100000100001110001001110101001100101001110011001110100001101001001101111001101110000101100000100000001101101100010100001100101001111001000100001
__________________________________________________
x@1QoB\7NAt@0\
C aBp4 CDu'h4Ms8,l(2O
__________________________________________________
[Finished in 0.429s]
```

- LZW_functional

``` perl
#! /usr/bin/env perl6
use v6;

# To compress a string...
sub compress(Str $uncompressed) {
    # Encode the character list via a dictionary, from the start
    encode( $uncompressed.comb, code => hash(map {$^ASCII.chr => $^ASCII}, ^256), seen => "" )
}

# Encode an empty list where nothing already seen as nothing
multi encode([], :%code, :$seen where "") {}

# Encode an empty list where something already seen by look-up
multi encode([], :%code, :$seen)          { %code{$seen} }

# Encode an list of one or more uncompressed characters...
multi encode([$next, *@uncompressed], :%code, :$seen)  {
    # If [already-seen plus next char] is a known sequence...
    %code{ $seen~$next }:exists
         # Then encode all of that together
        ?? encode(@uncompressed, :%code, seen => $seen~$next)

         # Else emit encoding for the already-seen sequence
        !! ( %code{$seen},
             # Plus the encoding for the rest of the string...
             encode( @uncompressed,
                     # Add encoding for new sequence to table
                     code => %( %code, $seen~$next => %code.elems ),
                     # Continue encoding from next character
                     seen => $next
             )
           )
}


# Convert to codepoints...
my @codes = compress('To be or not to be. That be the question, matey!');
say @codes;
separator;

# Emit as characters...
say @codes>>.chr;
separator;

# Convert to a binary sequence...
my $bits_per_code = @codes.max.log(2).ceiling();
my $format = '%0' ~ $bits_per_code ~ 'b';
my $bits = @codes>>.fmt($format).join;
say $bits;
separator;

say $bits.comb(/.**1..7/).map({:2($^bitpattern).chr}).join;
separator;





sub separator { say '_' x 50 }
```

输出：

``` perl
84 111 32 98 101 32 111 114 32 110 111 116 32 116 257 259 46 32 84 104 97 267 259 268 104 260 113 117 101 115 116 105 111 110 44 32 109 276 101 121 33
__________________________________________________
T o   b e   o r   n o t   t ā ă .   T h a ċ ă Č h Ą q u e s t i o n ,   m Ĕ e y !
__________________________________________________
001010100001101111000100000001100010001100101000100000001101111001110010000100000001101110001101111001110100000100000001110100100000001100000011000101110000100000001010100001101000001100001100001011100000011100001100001101000100000100001110001001110101001100101001110011001110100001101001001101111001101110000101100000100000001101101100010100001100101001111001000100001
__________________________________________________
x@1QoB\7NAt@0\
C aBp4 CDu'h4Ms8,l(2O
__________________________________________________
[Finished in 0.658s]
```



- validation_concurrent



``` perl
#! /usr/bin/env perl6
use v6;

my @records = (
    { :Name<Damian Conway>, :Age(42), :ID('00012345')  },
    { :Name<Leslie Duvall>, :Age(29), :ID('668')       },
    { :Name<Sam Georgious>, :Age(-2), :ID('00000007')  },
);

sub normalize_data (Hash $record) {
    $record<Name>  .= subst(/<lower>/,{$<lower>.uc}, :g);
    $record<Age> max= 18;
    $record<ID>    .= fmt('%08d');
}

sub report ($outcome) {
    say "\tInvalid record ($outcome)";
}


sub invalid_name ($rec) { "Bad name: $rec" if $rec<Name> !~~ /\S/;        }
sub invalid_age  ($rec) { "Bad age:  $rec" if $rec<Age>  < 18;            }
sub invalid_ID   ($rec) { "Bad ID:   $rec" if $rec<ID>   !~~ /^\d ** 8$/; }


say 'Validating...';
my @invalidations = (
    @records».&invalid_name,
    @records».&invalid_age,
    @records».&invalid_ID,
);

@invalidations».&report;

say 'Normalizing...';
@records».&normalize_data;

say 'Revalidating...';

@invalidations = (
    @records».&invalid_name,
    @records».&invalid_age,
    @records».&invalid_ID,
);

@invalidations».&report;
```

输出：

``` perl
Validating...
postcircumfix:<{ }> not defined for type Str
  in sub invalid_name at -e:67
  in block <unit> at -e:73

Actually thrown at:
  in sub invalid_name at -e:67
  in block <unit> at -e:73

[Finished in 0.374s]
```



- validation_imperative



``` perl
#! /usr/bin/env perl6
use v6;

my @records = (
    { :Name<Damian Conway>, :Age(42), :ID('00012345')  },
    { :Name<Leslie Duvall>, :Age(29), :ID('668')       },
    { :Name<Sam Georgious>, :Age(-2), :ID('00000007')  },
);

sub normalize_data (Hash $record) {
    $record<Name>  .= subst(/<lower>/,{$<lower>.uc}, :g);
    $record<Age> max= 18;
    $record<ID>    .= fmt('%08d');
}

sub report ($outcome) {
    say "\tInvalid record ($outcome)";
}


sub invalid_name ($rec) { "Bad name: $rec" if $rec<Name> !~~ /\S/;        }
sub invalid_age  ($rec) { "Bad age:  $rec" if $rec<Age>  < 18;            }
sub invalid_ID   ($rec) { "Bad ID:   $rec" if $rec<ID>   !~~ /^\d ** 8$/; }


say 'Validating...';
my @invalidations = gather for @records -> $record {
    take invalid_name($record);
    take invalid_age($record);
    take invalid_ID($record);
}

for @invalidations -> $errmsg {
    report( $errmsg );
}

say 'Normalizing...';
for @records -> $record {
    normalize_data($record);
}

say 'Revalidating...';

@invalidations = gather for @records -> $record {
    take invalid_name($record);
    take invalid_age($record);
    take invalid_ID($record);
}

for @invalidations -> $errmsg {
    report( $errmsg );
}
```

输出：

``` perl
Validating...
	Invalid record (Bad ID:   Name	Leslie Duvall Age	29 ID	668)
	Invalid record (Bad age:  Name	Sam Georgious Age	-2 ID	00000007)
Normalizing...
Revalidating...
[Finished in 0.399s]
```



- validation_junctions



``` perl
#! /usr/bin/env perl6
use v6;

my @records = (
    { :Name<Damian Conway>, :Age(42), :ID('00012345')  },
    { :Name<Leslie Duvall>, :Age(29), :ID('668')       },
    { :Name<Sam Georgious>, :Age(-2), :ID('00000007')  },
);

sub normalize_data (Hash $record) {
    $record<Name>  .= subst(/<lower>/,{$<lower>.uc}, :g);
    $record<Age> max= 18;
    $record<ID>    .= fmt('%08d');
}

sub report ($outcome) {
    say "\tInvalid record ($outcome)";
}


sub invalid_name ($rec) { "Bad name: $rec" if $rec<Name> !~~ /\S/;        }
sub invalid_age  ($rec) { "Bad age:  $rec" if $rec<Age>  < 18;            }
sub invalid_ID   ($rec) { "Bad ID:   $rec" if $rec<ID>   !~~ /^\d ** 8$/; }

my $invalid_record = &invalid_name | &invalid_age | &invalid_ID;

say 'Validating...';
report( $invalid_record(all @records) );

say 'Normalizing...';
normalize_data(all @records);

say 'Revalidating...';
report( $invalid_record(all @records) );
```

输出：

``` perl
Validating...
	Invalid record (Bad ID:   Name	Leslie Duvall Age	29 ID	668)
	Invalid record (Bad age:  Name	Sam Georgious Age	-2 ID	00000007)
Normalizing...
Revalidating...
[Finished in 0.399s]
```



- prime_demo
  
  ​

``` perl
#! /usr/bin/env perl6
use v6;

sub is_prime(Int $n) {
    return $n % all(2..$n.sqrt+1);
}


for 1..1001 -> $n {
    say "$n is prime" if is_prime($n);
}
```

输出：

``` perl
1 is prime
3 is prime
5 is prime
7 is prime
11 is prime
13 is prime
17 is prime
19 is prime
23 is prime
29 is prime
31 is prime
37 is prime
41 is prime
43 is prime
47 is prime
53 is prime
59 is prime
61 is prime
67 is prime
71 is prime
73 is prime
79 is prime
83 is prime
89 is prime
97 is prime
101 is prime
103 is prime
107 is prime
109 is prime
113 is prime
127 is prime
131 is prime
137 is prime
139 is prime
149 is prime
151 is prime
157 is prime
163 is prime
167 is prime
173 is prime
179 is prime
181 is prime
191 is prime
193 is prime
197 is prime
199 is prime
211 is prime
223 is prime
227 is prime
229 is prime
233 is prime
239 is prime
241 is prime
251 is prime
257 is prime
263 is prime
269 is prime
271 is prime
277 is prime
281 is prime
283 is prime
293 is prime
307 is prime
311 is prime
313 is prime
317 is prime
331 is prime
337 is prime
347 is prime
349 is prime
353 is prime
359 is prime
367 is prime
373 is prime
379 is prime
383 is prime
389 is prime
397 is prime
401 is prime
409 is prime
419 is prime
421 is prime
431 is prime
433 is prime
439 is prime
443 is prime
449 is prime
457 is prime
461 is prime
463 is prime
467 is prime
479 is prime
487 is prime
491 is prime
499 is prime
503 is prime
509 is prime
521 is prime
523 is prime
541 is prime
547 is prime
557 is prime
563 is prime
569 is prime
571 is prime
577 is prime
587 is prime
593 is prime
599 is prime
601 is prime
607 is prime
613 is prime
617 is prime
619 is prime
631 is prime
641 is prime
643 is prime
647 is prime
653 is prime
659 is prime
661 is prime
673 is prime
677 is prime
683 is prime
691 is prime
701 is prime
709 is prime
719 is prime
727 is prime
733 is prime
739 is prime
743 is prime
751 is prime
757 is prime
761 is prime
769 is prime
773 is prime
787 is prime
797 is prime
809 is prime
811 is prime
821 is prime
823 is prime
827 is prime
829 is prime
839 is prime
853 is prime
857 is prime
859 is prime
863 is prime
877 is prime
881 is prime
883 is prime
887 is prime
907 is prime
911 is prime
919 is prime
929 is prime
937 is prime
941 is prime
947 is prime
953 is prime
967 is prime
971 is prime
977 is prime
983 is prime
991 is prime
997 is prime
[Finished in 1.478s]
```



- 统计



``` perl
#! /usr/bin/env perl6
use v6;

my @values = (1, 1, 3, 4, 4, 4, 4, 5, 5, 5, 7, 7, 12, 12, 1, 7, 7, 99);

say 'mean (a) = ', mean_a(@values);
say 'mean (g) = ', mean_g(@values);
say '    mode = ',   mode(@values);
say '  median = ', median(@values);

sub mean_a (*@list) {
    ([+] @list) / @list.elems;
}

sub mean_g (*@list) {
    ([*] @list) ** (1/@list.elems);
}

sub mode (*@list) {
    given @list.Bag {
        .pairs.grep({$^elem.value == .values.max})».key;
    }
}

sub median (*@list) {
    given @list.sort {
        .elems %% 2
            ?? mean_a( .[*/2-1, */2] )
            !!         .[*/2];
    }
}
```

输出：

``` perl
mean (a) = 10.444444
mean (g) = 4.95872541158849
    mode = 7 4
  median = 5
[Finished in 0.319s]
```



- stats_hybird



``` perl
#! /usr/bin/env perl6
use v6;

my @values = (1, 1, 3, 4, 4, 4, 4, 5, 5, 5, 7, 7, 12, 12, 1, 7, 7, 99);

say 'mean (a) = ', mean_a(@values);
say 'mean (g) = ', mean_g(@values);
say '    mode = ',   mode(@values);
say '  median = ', median(@values);

sub mean_a (*@list) {
    my $sum = [+] @list;
    return $sum / @list.elems;
}

sub mean_g (*@list) {
    my $product = [*] @list;
    return $product ** (1/@list.elems)
}

sub mode (*@list) {
    my $frequencies = @list.Bag;
    my $list_elems  = $frequencies.pairs;
    my $max_freq    = $frequencies.values.max;
    my @max_vals    = $list_elems.grep({.value == $max_freq});

    return @max_vals».key;
}

sub median (*@list) {
    my @sorted = @list.sort;
    return @sorted.elems %% 2 ?? mean_a(@sorted.[*/2, */2-1])
                              !!        @sorted.[*/2]
}
```

输出：

``` perl
mean (a) = 10.444444
mean (g) = 4.95872541158849
    mode = 7 4
  median = 5
[Finished in 0.319s]
```



- stats_imperative



``` perl
#! /usr/bin/env perl6
use v6;

my @values = (1, 1, 3, 4, 4, 4, 4, 5, 5, 5, 7, 7, 12, 12, 1, 7, 7, 99);

say 'mean (a) = ', mean_a(@values);
say 'mean (g) = ', mean_g(@values);
say '    mode = ',   mode(@values);
say '  median = ', median(@values);

sub mean_a (*@list) {
    my $sum;
    for @list -> $elem {
        $sum += $elem;
    }
    return $sum / @list.elems;
}

sub mean_g (*@list) {
    my $product;
    for @list -> $elem {
        $product *= $elem;
    }
    return $product ** (1/@list.elems);
}

sub mode (*@list) {
    my %counts;
    %counts{$_}++ for @list;
    my $max = %counts.values.max;
    return %counts.grep({ .value == $max })».key;
}

sub median (*@list) {
    @list.=sort();

    return @list.elems %% 2
            ?? mean_a( @list[*/2, */2-1] )
            !!         @list[*/2];
}
```

输出：

``` perl
mean (a) = 10.444444
mean (g) = 4.95872541158849
    mode = 4 7
  median = 5
[Finished in 0.316s]
```



- stats_mode_func



``` perl
#! /usr/bin/env perl6
use v6;

my @values = (1, 1, 3, 4, 4, 4, 4, 5, 5, 5, 7, 7, 12, 12, 1, 7, 7, 99);

say 'mean (a) = ', mean_a(@values);
say 'mean (g) = ', mean_g(@values);
say '    mode = ',   mode(@values);
say '  median = ', median(@values);

sub mean_a (*@list) {
    sub sum { [+] @list }
    return sum() / @list.elems;
}

sub mean_g (*@list) {
    sub product { [*] @list }
    return product() ** (1/@list.elems)
}

sub mode (*@list) {
    sub frequencies { @list.Bag                             }
    sub list_elems  { frequencies.pairs                     }
    sub max_freq    { frequencies.values.max                }
    sub max_vals    { list_elems.grep: {.value == max_freq} }

    return max_vals».keys;
}

sub median (*@list) {
    sub sorted { @list.sort }
    return sorted.elems %% 2
                ?? mean_a(sorted.[*/2, */2-1])
                !!        sorted.[*/2]
}
```

输出：

``` perl
mean (a) = 10.444444
mean (g) = 4.95872541158849
    mode = 7 4
  median = 5
[Finished in 0.357s]
```



- stats_OO



``` perl
#! /usr/bin/env perl6
use v6;

class StatList is List {
    method mean_a () {
        sub sum { [+] self }
        return sum() / self.elems;
    }

    method mean_g () {
        sub product { [*] self }
        return product() ** (1/self.elems)
    }

    method median () {
        sub sorted { self.sort }
        return sorted.elems %% 2
                    ?? StatList.new(sorted.[*/2, */2-1]).mean_a()
                    !!              sorted.[*/2];
    }

    method mode () {
        sub frequencies { self.Bag                              }
        sub list_elems  { frequencies.pairs                     }
        sub max_freq    { frequencies.values.max                }
        sub max_vals    { list_elems.grep: {.value == max_freq} }

        return  max_vals».keys;
    }
}

my $list = StatList.new(1,3,5,8,8,11);

say $list.mean_a;
say $list.mean_g;
say $list.median;
say $list.mode;
```

输出：

``` perl
6
4.68393277169202
13
8
[Finished in 0.335s]
```

> 以上所有文件都可以在[这儿](http://www.bit.do/P6TP) 下载到 - a Perl 6 introductory tutorial by Damian Conway

说明：以上脚本的结果都在 Atom 编辑器下运行得到，然而， 需要在终端中打开 Atom，并安装了 script 插件才行。快捷键 `command + i`