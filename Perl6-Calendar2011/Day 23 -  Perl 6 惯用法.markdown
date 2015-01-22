# Day 23 – Idiomatic Perl 6
                                          -- December 23, 2011


下面大多数的例子使用 4 种版本展示代码：


- 1. Non-idiomatic Perl 5,
- 2. then made idiomatic.
- 3. Perl 5 idiom, naively translated into Perl 6,
- 4. then made idiomatic.
从 1 到 4 越来越清晰和简洁
Idiom ==> Word
(Movin' on up)

## 随机选择数组元素
```perl
$z = $array[ int(rand scalar(@array)) ];
$z = $array[ rand @array ];
#
$z = @array[ rand *@array ];
$z = @array.pick ;           
``` 
 
## 循环遍历数组的键（索引）
```perl
for ( my $i=0; $i<@array; $i++ ) {...}
for my $i ( 0 .. $#array )       {...}
#
for 0 .. @array.end -> $i        {...}
for @array.keys -> $i           {...}
``` 
 
## 整除
```perl
( ($x - ($x % 3) ) / 3 )
int( $x / 3 )
#
Int ( $x / 3 )   # 首字母需大写
$x div 3        # 整除运算符
``` 
 
## 打印数组元素的个数
```perl
say scalar @array;
say 0+@array;
#
say 0+@array;          # Identical in Perl 6
say +@array;           # + 强制新的“数值”上下文
say @array.elems;      # .elems 方法更清楚.
``` 
 
## 每隔5 次 做些事情
```perl
if ( ($x/5) == int($x/5) ) {...}
if ( !($x % 5) ) {...}
#
if !($x % 5) {...}
if $x %% 5 {...}           # %% means "is evenly divisible by"
``` 
 
## Do something $n times, 直到 $n-1
```perl
for ( $_=0; $_ < $n; $_++ ) {...}
for ( 0 .. ($n-1) ) {...}
#
for 0 ..^ $n {...}
for ^$n      {...}     # ^9 means 0 ..^ 9, or 0..8
```
eg：

    > .say for ^10
    0
    1
    2
    3
    4
    5
    6
    7
    8
    9
Bare method calls are *always* methods on $_, eliminating Perl 5's confusion on which functions default to $_.

## 按空白分割
```perl
@words = split / \s+ /, $_;
@words = split;          # Default is useful, but not intuitive
#
@words = .split(/\s+/);  # split() 现在没有默认的模式
@words = .words;         # split 的旧的行为现在成为了一个单独的方法.words
``` 
##  将字符串分割成单独的字符
```perl
@chars = map { substr $word, $_, 1 } 0..length($word);
@chars = split '', $word; # Split on nothingness
#
@chars = $word.split('');
@chars = $word .comb ;      # Default is to "keep everything"
```
 eg：

    > my $word='Perl6'
    Perl6
    > my @chars=$word.split('')
    P e r l 6
    > my @chars=$word.split('').join('->')
    P->e->r->l->6
    > my @chars=$word.comb
    P e r l 6
    > my @chars=$word.comb.join(':')
    P:e:r:l:6
 
## 无限循环
```perl
for (;;) {...}    # Spoken with a 'C' accent
while (1) {...}
#
while 1 {...}
loop {...}        # 没有给出限定条件，所以默认无止尽
```

## 按原来的顺序返回列表中的唯一元素
```perl
my %s, @r; 
for @a { push @r, $_ if !$s{$_}; $s{$_}++; } 
return @r;

my %s; 
return grep { !$s{$_}++ } @a;    # or List::MoreUtils::uniq
#
my %s; return grep { !%s{$_}++ }, @a;
return @a .uniq ;
``` 
## 将列表中的所有元素求和
```perl
my $sum = 0; for my $num (@a) { $sum += $num }
my $sum; $sum += $_ for @a;    # or List::Util::sum
#
my $sum = @a.reduce ( * + * );
my $sum = [+] @a;   # [op] 将op操作符应用到整个列表

@alpha = 'A' .. 'Z'; 
@a = qw{ able baker charlie };
%meta = ( foo => 'bar', baz => 'quz' );
@squares = map { $_ * $_ }, @a;
@starts_with_number = grep { /^\d/ }, @a;
```
钻石操作符还在：
##  Process each line from STDIN or from command-line files.
```perl
for my $file (@ARGV) { open FH, $file; while (<FH>) {...} }
while (<>) {...}               # Null filehandle is magical
#
for $*ARGFILES.lines {...}
for lines() {...}              # lines() defaults to $fh = $*ARGFILES
```

## 将散列初始化为一个常量
my %h;   for (@a) { $h{$_} = 1 }
my %h = map { $_ => 1 } @a;
#
my %h = map { $_ => 1 }, @a;
my %h = @a X=> 1;
``` 
eg：

    > my @a=<Perl Python Ruby Perl6>
    Perl Python Ruby Perl6
    > my %h= @a X=> 1
    ("Perl" => 1, "Python" => 1, "Ruby" => 1, "Perl6" => 1).hash
     
## Hash initialization for enumeration
     my %h;   for (0..$#a) { $h{ $a[$_] } = $_ }
     my $c;   my %h = map { $_ => ++$c } @a;
    #
     my $c;   my %h = map { $_ => ++$c }, @a;
    > ("Perl" => 1, "Python" => 2, "Ruby" => 3, "Perl6" => 4).hash
    my %h = @a Z=> 1..*; # ("Perl" => 1, "Python" => 2, "Ruby" => 3, "Perl6" => 4).hash
    my %h = @a.pairs » .invert;  # if zero based , ("Perl" => 0, "Python" => 1, "Ruby" => 2, "Perl6" => 3).hash
    > @a .pairs
    0 => "Perl" 1 => "Python" 2 => "Ruby" 3 => "Perl6"
    
    
## Hash initialization from parallel arrays
    my %h;   for (@a) { $h{$_} = shift @b }
    my %h;   @h{@a} = @b;
    #
    my %h;   %h{@a} = @b;
    my %h = @a Z=> @b;
     
    eg:
    
    > my @b=<Larry Gao Mztiz Larry_Wall>
    Larry Gao Mztiz Larry_Wall
    > my %h= @a Z=> @b
    ("Perl" => "Larry", "Python" => "Gao", "Ruby" => "Mztiz", "Perl6" => "Larry_Wall").hash


## 交换两个变量
```perl
my $temp = $x; $x = $y; $y = $temp;
( $x, $y ) = ( $y, $x );
#
( $x, $y ) =   $y, $x;
( $x, $y ) .= reverse;   # .= makes reverse into a "mutating" method
# Tastes great on array swaps, too!   @a[ $j, $k ] .= reverse;
``` 
##  Rotate array left by 1 element
```perl
my $temp = shift @a; push @a, $temp;
push @a, shift @a;
#
@a.push: @a.shift;
@a .= rotate; # Python Ruby Perl6 Perl
``` 
## 创建一个对象
```perl
my $pet = new Dog;
my $pet = Dog->new;
#
my $pet = Dog.new;
my Dog $pet .= new;    # $pet *always* isa Dog; Compiler can optimize!
```
Combining transformation with selection was an advanced idiom in Perl 5. The new return values for if provide a bite-sized idiom.


## Three copies of elements > 5
```perl
@z = map { ($_) x 3 } grep { $_ > 5 } @y;    # map,grep
@z = map { $_ > 5 ? ($_) x 3 : () } @y;      # map as grep
#
@z = map { $_ > 5 ?? ($_) xx 3 !! Nil }, @y;
@z = @y.map: { $_ xx 3 if $_ > 5 };          # !if == Empty list
@z = ($_ xx 3 if $_ > 5 for @y);             # List comprehension
```

## 3到7之间的随机整数，包含3和7
```
do { $z = int rand 8 } until $z >= 3;
$z = 3 + int rand 5;
#
$z = 3 + Int(5.rand);
$z = (3..7).pick ;
``` 
## 在无限循环中每次循环加 3
```perl
for ( my $i = 1; ; $i++ ) { my $n = 3 * $i; ... }
for ( my $n = 3; ; $n += 3 ) {...}
#
loop ( my $n = 3; ; $n += 3 ) {...}
for 3, * + 3 ... * -> $n {...}      # `...` is the "sequence" operator
for 3, 6, 9 ... *  -> $n {...}      # `...` can infer from example list
``` 
## 遍历区间, 不包含开始点和结束点
```perl
for my $i ( $start .. $limit ) { next if $i == $start or $i == $limit; ... }
for my $i ( ($start+1) .. ($limit-1) ) {...}
#
for ($start+1) .. ($limit-1) -> $i {...}
for $start ^..^ $limit -> $i {...}
```