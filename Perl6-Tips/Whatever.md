title: Whatever
date: 2015-07-16 00:56:22
tags: Perl6
categories: Perl 6
---

<blockquote class="blockquote-center">不再相信相信什么道理 人们已是如此冷漠 不再回忆回忆什么过去 现在不是从前的我
— 无地自容·周晓鸥
</blockquote>

## Whatever 是什么?

Placeholder for unspecified value/parameter - 未指定的值/参数的占位符.

`*` 字面量在 term 位置上创建 **Whatever** 对象.

`*` 的大部分魔法来自于 `Whatever` 柯里化. 当 `*` 作为 item 与很多操作符组合使用时, 编译器会把表达式转换为 `WhateverCode` 类型的闭包.

```perl6

my $c = * + 2;          # same as   -> $x { $x + 2 };
say $c(4);              # 6

```

如果一个表达式中有 N 个 `*`, 则会产生一个含有 N 个参数的闭包:

```perl6
my $c = * + *;          # same as   -> $x, $y { $x + $y }

```

在复杂的表达式中使用 `*` 也会产生闭包:

```perl6

my $c = 4 * * + 5;      # same as   -> $x { 4 * $x + 5 }

```

在 `*` 上面调用方法也会产生闭包:

```perl6

<a b c>.map: *.uc;      # same as	<a b c>.map: -> $char { $char.uc }

```

前面提到, 不是所有的操作符和语法都会把 `*` 柯里化为 `WhateverCode`. 下面这几种情况, `*` 仍旧是 `Whatever` 对象.


```perl6

例外               Example    What it does
逗号               1,*,2      用一个 * 元素生成一个 Parcel
范围操作符          1..*       Range.new(:from(1), :to(*));
序列操作符          1 ... *    无限列表
智能匹配            1 ~~ *     返回 True
赋值               $x = *     把 * 赋值给 $x
绑定               $x := *    把 * 绑定给 $x
列表重复            1 xx *     生成无限列表

```

范围操作符被特殊处理. 它们不使用 `Whatever-stars` 柯里化, 但是它们使用 `WhateverCode` 进行柯里化.

```perl6

say (1..*).WHAT;        # Range
say (1..*-1).WHAT;      # WhateverCode

```

下面这些也能使用:

```perl6

.say for 1..*;          # infinite loop
my @a = 1..4;
say @a[0..*];           # 1 2 3 4
say @a[0..*-2];         # 1 2 3

```

因为 `Whatever-currying` 是纯粹的语法编译器转换, 这不会在运行时把存储的 `Whatever-stars` 柯里化为 `WhateverCodes`.

```perl6

my $x = *;
$x + 2;                 # not a closure, dies because
                        # it can't coerce $x to Numeric

```

存储 `Whatever-stars` 的使用案例像上面提到的那样, 但要把柯里化异常的情况也包含进去. 例如, 如果你想要一个默认的无限序列:

```perl6

my $max    = potential-upper-limit() // *;
my $series = known-lower-limit() ... $max;

```

一个存储后的 '*' 会在智能匹配的特殊情况下生成 `WhateverCode`. 注意, 正被柯里化的并非真正储存的 `*`, 而是在 LHS 上的 `*`.

```perl6

my $constraint = find-constraint() // *;
my $maybe-always-matcher = * ~~ $constraint;

```

如果这个假定的 `find-constraint` 没有找到约束, 则 `maybe-always-matcher` 会对任何东西都返回 `True`.

```perl6

$maybe-always-matcher(555);      # True
$maybe-always-matcher(Any);      # True

```
