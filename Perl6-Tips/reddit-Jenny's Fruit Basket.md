
#### 问题描述

小詹妮拿着 5 美元去超市买东西,  为新搬来的邻居买水果篮礼物。因为她是个勤奋并缺乏想象力的孩纸, 她打算正好花 5 美元, 不多也不少。

事实上超市里水果的价格并非整数, 正好花光 5 美元并不容易。 - 但是詹妮已经准备好了。她从背包里拿出上网本, 输入她看到过的水果的单价, 并且开启了一个程序为她收集 — 就是这样, 5 美元能买的水果的组合就出现在屏幕上。

**挑战** : 用你选择的语言展示詹妮的程序是什么样子。

- 目标就是 500 美分 (等于 5 美元)
- 解决方法可以包含多种同类型的水果 - 假设它们数量没有限制
- 解决方法没有必要包含所有水果类型
- 对给定的输入检测所有可能的方法



#### 输入描述

每行一种水果 — 规定了水果的**名字**(不含空格的单词)和水果的单价(单位为美分, 整数)

#### 输出描述

每个解决方法一行 — 用以逗号分割的数量+名字对儿, 描述了那种类型要买的水果数。

不要列出数量为 0 的水果。 如果为复数就给名字加 **s**。

#### 输入样本

``` perl6
banana 32
kiwi 41
mango 97
papaya 254
pineapple 399
```

#### 输出样本

``` perl6
6 kiwis, 1 papaya
7 bananas, 2 kiwis, 2 mangos
```

#### 有挑战的输入

``` perl
apple 59
banana 32
coconut 155
grapefruit 128
jackfruit 1100
kiwi 41
lemon 70
mango 97
orange 73
papaya 254
pear 37
pineapple 399
watermelon 500
```

注意, 这种输入有 180 种解决方法。

``` perl
my (@names, @prices) := ($_»[0], $_»[1]».Int given lines».words);

for find-coefficients(500, @prices) -> @quantities {
    say (@names Z @quantities)
        .map(-> [$name, $qty] { "$qty $name"~("s" if $qty > 1) if $qty })
        .join(", ");
}

sub find-coefficients ($goal, @terms) {
    gather {
        my @coefficients;

        loop (my $i = 0; $i < @terms; @coefficients[$i]++) {
            given [+](@coefficients Z* @terms) <=> $goal {
                when Less { $i = 0                      }
                when More { @coefficients[$i] = 0; $i++ }
                when Same { take @coefficients.values   }
            }
        }
    }
}
```

For each iteration of the loop, the array `@coefficients` is "incremented by one" as if its elements were the digits of a number - but not one with a fixed base: instead, it overflows the "digits" whenever the search condition has been exceeded (sum > goal).

The same could possibly be done more elegantly with recursion. And for those who don't like naive bruteforce solutions, this challenge could also be a nice opportunity to try some [dynamic programming](https://en.wikipedia.org/wiki/Dynamic_programming) techniques.

``` perl6
my @fruits = lines».split(" ").sort(-*[1]);
my @names  = @fruits»[0];
my @prices = @fruits»[1]».Int;

for find-coefficients(500, @prices) -> @quantities {
    say (@names Z @quantities)
        .map(-> [$name, $qty] { "$qty $name"~("s" if $qty > 1) if $qty })
        .join(", ");
}

sub find-coefficients ($goal, @terms) {
    gather {
        my @initial = 0 xx @terms;

        my %partials = (0 => [@initial,]);
        my @todo = (@initial,);
        my %seen-partials := SetHash.new;
        my %seen-solutions := SetHash.new;

        while @todo {
            my @current := @todo.shift;
            my $sum = [+] @current Z* @terms;

            next if $sum > $goal;

            %partials{$sum}.push: @current;

            # Find solutions by adding known partials to the current partial
            for %partials{$goal - $sum}[*] -> @known {
                .take if !%seen-solutions{~$_}++ given list @current Z+ @known;
            }

            # Schedule additional iterations
            if $sum <= $goal div 2 {
                for @terms.keys {
                    my @next = @current;
                    @next[$_]++;
                    @todo.push: @next if !%seen-partials{~@next}++;
                }
            }
        }
    }
}
```

Note:

- For the challenge input *(solution space = 1,127,153,664)* it needs only 4296 iterations, at the cost of several hash lookups per iteration.





Perl 5 的解决方案。

``` perl5
#可以求解三元以上的，只是个思路，可以推广。

use strict;
use warnings;
#计算二元方程组
#2x+3y=21

my @number;

while(<DATA>) {
    chomp;
    my ($name, $number) = split;
    push @number,$number;
}

print "@number\n";
 $_="1" x 500;
my %seen;
my $num = 31;
my $count = 0;



$_=~m{
  (.*)\1{$num}
  (.*)\2{40}
  (.*)\3{96}
  (.*)\4{253}
  (.*)\5{398}

  (?{
  my $a=split //,$1;
  my $b=split //,$2;
  my $x=split //,$3;
  my $y=split //,$4;
  my $d=split //,$5;
  $seen{"x=$a,y=$b,a=$x,b=$y,d=$d"}=1 if ($1 x $number[0]) . ($2 x $number[1]) . ($3 x $number[2]) . ($4 x $number[3]) . ($5 x $number[4]) eq $_ ;
  })
  (?!)}x;

foreach my $result (sort keys %seen) {
  print "$result\n";
}

__DATA__
banana 32
kiwi 41
mango 97
papaya 254
pineapple 399
```
