# Perl 6专家指南 - if 语句
> 分类: Perl6



##  if 语句 - 比较值
你可以使用if 语句和其中之一的比较操作符来比较两个值或标量变量。

## examples/scalars/if.p6
```perl
#!/usr/bin/env perl6
use v6;

my $age = 23;
if $age > 18 {
    say "You can vote in most countries.";
}


其他类型的 if 语句
  if COND {
  }
 
  if COND {
  } else {
  }
  
  if COND {
  } elsif COND {
  } elsif COND {
  } else {
  }
```