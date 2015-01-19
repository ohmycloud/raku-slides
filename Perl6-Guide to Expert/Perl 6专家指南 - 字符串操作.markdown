# Perl 6专家指南 - 字符串操作
> 分类: Perl6

##自动将字符串转换为数字

examples/scalars/add.p6
```perl
#!/usr/bin/env perl6
use v6;

my $a = prompt "First number:";
my $b = prompt "Second number:";

my $c = $a + $b;

say "\nResult: $c";
```

## 字符串操作
examples/scalars/string_operators.p6
```perl
#!/usr/bin/env perl6
use v6;

my $x = "Hello";
my $y = "World";

# ~ 是连接操作符,连接字符串
my $z = $x ~ " " ~ $y;   # the same as "$x $y"
say $z;                 # Hello World

my $w = "Take " ~ (2 + 3);
say $w;                         # Take 5
say "Take 2 + 3";               # Take 2 + 3
say "Take {2 + 3}";             # Take 5

$z ~= "! ";             #   the same as 
$z = $z ~ "! ";
say "'$z'";             # 'Hello World! '
```
  ~ 连接2个字符串.
就像上面见到的那样，任何操作符都能使用花括号语法插入到字符串中。.

## 字符串连接
examples/scalars/concat.p6
```perl
#!/usr/bin/env perl6
use v6;

my $a = prompt "First string:";
my $b = prompt "Second string:";

my $c = $a ~ $b;

say "\nResult: $c";
``
字符串重复操作
examples/scalars/string_repetition.p6
```perl
#!/usr/bin/env perl6
use v6;

my $z = "Hello World! ";

# x is the string repetition operator
my $q = $z x 3;
say " ' $q ' ";         # 'Hello World! Hello World! Hello World! '
```