title:  Abundant and Deficient Numbers

date: 2016-01-24

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>原来！</blockquote>

#### 问题描述

*abundant* 数是其所有因子的和大于该数，而deficient数是其因子的和小于该数。

例如, 考虑数字 21。它的因子是 1, 3, 7 和 21, 这些因子的和是32。 因为 32 小于 2 x 21, 所以 21 是 deficient。它的差额是 2 x 21 - 32 = 10。

12 是第一个 abundant 数。它的因子是 1, 2, 3, 4, 6 和 12, 并且它们的和是 28。 因为 28 大于 2 x 12, 所以 12 是 abundant。它们的差额是 28 - 2 x 12 = 4。

#### 输入描述

你会给定一个整数, 每行一个。例如:

``` perl6
18
21
9
```

#### 输出描述

你的程序应该打印信息, 如果数字是 deficient, abundant(和它的abundance), 或者都不。例如:

``` perl6
18 abundant by 3
21 deficient
9 ~~neither~~ deficient
```

#### 输入挑战

``` perl6
111  
112 
220 
69 
134 
85 
```

#### 挑战输出:

``` perl6
111 ~~neither~~ deficient 
112 abundant by 24
220 abundant by 64
69 deficient
134 deficient
85 deficient
```

[smls](https://www.reddit.com/user/smls)

``` perl6
for lines() -> $n {
    my $sum = (1..$n/2).grep($n %% *).sum;
    say "$n " ~ ($sum > $n ?? "abundant by {$sum - $n}" !!
                 $sum < $n ?? "deficient" !! "neither");
}
```

或者

``` perl6
for lines() -> $n {
    given (1..$n/2).grep($n %% *).sum {
        when * > $n { say "$n abundant by {$_ - $n}" }
        when * < $n { say "$n deficient" }
        default     { say "$n neither" }
    }
}
```

