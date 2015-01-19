# Perl 6专家指南 - 三元操作符
> 分类: Perl6


## 三元操作符
examples/scalars/ternary.p6
```perl
use v6;
my $age = 42;

if $age > 18 {
    say "Above 18";
} else {
    say "Below 18";
}

say $age > 18 ?? "Above 18" !! "Below 18";
```

语法：   COND ?? VALUE_IF_TRUE !! VALUE_IF_FALSE