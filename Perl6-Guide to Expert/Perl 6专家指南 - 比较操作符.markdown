# Perl 6专家指南 -> 比较操作符
> 分类: Perl6


## 比较操作符
有两种相关的比较操作符. 一种是比较数字，一种是比较字符串,基于 ASCII表。
See also S03-operators.pod

```perl
  3 == 4               # false
  '35' eq 35.0         # false
  '35' == 35.0         # true
  13 > 2               # true
  13 gt 2               # false !!!
  "hello" == "world"   # throws exception
  "hello" eq "world"   # false
  "hello" == ""         # throws exception
  "hello" eq ""         # false
```
 ##  examples/scalars/comparison_operators.p6
```perl
 #!/usr/bin/env perl6
use v6;

say 4       == 4 ?? "TRUE" !! "FALSE";     # TRUE
say 3       == 4 ?? "TRUE" !! "FALSE";     # FALSE
say "3.0"   == 3 ?? "TRUE" !! "FALSE";     # TRUE
say "3.0"   eq 3 ?? "TRUE" !! "FALSE";     # FALSE
say 13     >   2 ?? "TRUE" !! "FALSE";     # TRUE
say 13     gt 2 ?? "TRUE" !! "FALSE";     # FALSE
#say "foo"   == "" ?? "TRUE" !! "FALSE";     # TRUE
say "foo"   eq "" ?? "TRUE" !! "FALSE";     # FALSE
#say "foo"   == "bar" ?? "TRUE" !! "FALSE"; # TRUE
say "foo"   eq "bar" ?? "TRUE" !! "FALSE"; # FALSE
```

  不能转换字符串为数字：十进制数字必须以合法数字或点开头