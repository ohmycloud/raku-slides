# Perl 6专家指南 - 数字运算符 (2.4)
> 分类: Perl6



## 数字运算符
数字运算符可以用在标量值上面。


examples/scalars/numerical_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

my $x = 3;
my $y = 11;

my $z = $x + $y;
say $z;             # 14

$z = $x * $y;
say $z;             # 33
say $y / $x;       # 3.66666666666667

$z = $y % $x;       # (模)
say $z;             # 2

$z += 14;           # is the same as   $z = $z + 14;
say $z;             # 16

$z++;               # is the same as   $z = $z + 1;
$z--;               # is the same as   $z = $z - 1;

$z = 23 ** 2;       # 幂
say $z;             # 529
```

## Hello World - 插值
与Perl5中使用一样.

examples/scalars/hello_world_variable_interpolation.p6
```perl
#!/usr/bin/env perl6
use v6;

my $name     = "Foo";
my $greeting = "Hello $name";
say $greeting;
```
prints

  Hello Foo