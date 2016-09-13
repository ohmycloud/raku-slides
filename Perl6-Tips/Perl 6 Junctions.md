[薛定谔欧文](https://en.wikipedia.org/wiki/Erwin_Schr%C3%B6dinger)应该是喜欢 Perl 6 的, 因为他的著名的[薛定谔的猫](https://en.wikipedia.org/wiki/Schr%C3%B6dinger%27s_cat)可以用 Perl 6 的 [Junction](https://docs.perl6.org/type/Junction)表达:

```perl6
my $cat = 'dead' | 'alive';
say "cat is both dead and alive" if $cat eq 'dead' and $cat eq 'alive';

# OUTPUT:
# cat is both dead and alive
```

这里面发生了什么事情? 我会告诉你全部的!

## Anyone 游戏?

拿最简单的来说, Junctions 允许你把一堆值当作单个值。例如, 你可以使用 `any` Junction 来测试一个变量是否等于所给定值中的任意一个:

```perl6
say 'it matches!' if 'foo' eq 'foo' | 'bar' | 'ber';
say 'single-digit prime' if 5 == any ^9.grep: *.is-prime;

my @values = ^100;
say "it's in there!" if 42 == @values.any;

# OUTPUT:
# it matches!
# single-digit prime
# it's in there!
```

要从一堆值中创建一个 `any` Junction, 你可以使用 `|` 中缀操作符、调用 `any` 函数或者使用 `.any` 方法。上面的条件会返回 True 如果 Junction 中的任意一个(`any`) 值匹配所给定的值的话。事实上, 没有人能阻止你在两端都使用 Junction:

```perl6
my @one = 1..10;
my @two = 5..15;
say "There's overlap!" if @one.any == @two.any;

# OUTPUT:
# there's overlap!
```

运算符会返回 True 如果 `@one` 中的任意一个值(`any`) 在数值上等于 `@two` 中的任意一个值(`any`)的话。这个语法糖很甜, 但是我们还可以做的更多。


## All for One and Any for None

`any` Junction 唯一一个你能获得的 Junction。你还可以选择 `all`、`any`、`one` 和 `none`。当在布尔上下文中时, 它们的意思就像下面这样; 构建 Junction 的函数/方法名和 Junction 自身的名字一样并且下面还列出了构建 Junction 的中缀操作符:

- `all` — 所有的值都被计算为 True(使用中缀 `&`)
- `any` — 至少其中的一个值被计算为 True(使用中缀 `|`)
- `one` — 正好其中有一个值被计算为 True(使用中缀 `^`)
- `none` — 没有一个值被计算为 True(没有可用的中缀)

使用 `all` JUnction 时要特别注意:

```perl6
my @values = 2, 3, 5;
say 'all primes' if @values.all ~~ *.is-prime;

my @moar-values;
say 'also all primes' if @moar-values.all ~~ *.is-prime;
```

即使它没有值的时候也会返回 True, 这可能不是你想要的。在那些情况下, 你可以使用:

```perl6
my @moar-values;
say 'also all primes' if @moar-values and @moar-values.all ~~ *.is-prime; 
```

## Call Me, Baby

 你可以把 Junctions 用作并不期望 Junction 的子例程的参数。那么会发生什么呢? 对于每一个 Junctioned 的值, 那个子例程都会被调用一次, 并且返回值会是一个 Junction：
 
```perl6
 sub caculate-things($n) {
     say "$n is prime"          if $n.is-prime;
     say "$n is an even number" if $n %% 2;
     say "$n is pretty big"     if $n > 1e6;
     $n²;
 }
 
my @values = 1, 5, 42, 1e10.Int;
say 'EXACTLY ONE square is larger than 1e10'
    if 1e10 < calculate-things @values.one;

# OUTPUT:
# 5 is a prime
# 42 is an even number
# 10000000000 is an even number
# 10000000000 is pretty big
# EXACTLY ONE square is larger than 1e10
```

暴露的副作用可能有点太过神奇并且你可能不想在生产代码中看到它, 但是使用一个子例程来修改原来的 Junctioned 化的值是相当能接受的。执行一个数据库查询来获取"实际的"值并且在之后计算那个条件怎么样：

```perl6
use v6;
use DBIish;

my $dbh = DBIish.connect: 'SQLite', :database<test.db>;

sub lookup ($id) {
    given $dbh.prepare: 'SELECT id, text FROM stuff WHERE id = ?' {
        .execute: $id;
        .allrows[0][1] // '';
    }
}

my @ids = 3, 5, 10;
say 'yeah, it got it, bruh' if 'meow' eq lookup @ids.any;

# OUTPUT (the database has a row with id = 5 and text = 'meow'):
# yeah, it got it, bruh
```


## 我们一直在期盼你, 请坐。

那个游戏变化了当你的子例程正好期望一个 Junction 作为参数的时候。

```perl6
sub do-stuff (Junction $n) {
    say 'value is even'  if $n %% 2;
    say 'value is prime' if $n.is-prime;
    say 'value is large' if $n > 1e10;
}

do-stuff (2, 3, 1e11.Int).one;
say '---';
do-stuff (2, 3, 1e11.Int).any;

# OUTPUT:
# value is large
# ---
# value is even
# value is prime
# value is large
```

当我们提供了一个 `one` Junction 时, 只有正好满足给定值中的其中一个条件才会被触发。当我们提供一个 `any` Junction 时, 满足条件的任何一个给定值都会触发。

但是! 你没有必要非等着世界为你分发 Junctions。你自己制造一个怎么样呢, 还能在测试条件时节省代码:

```perl6
sub do-stuff (*@v) {
    my $n = @v.one;
    say "$n is even"  if $n %% 2;
    say "$n is prime" if $n.is-prime;
    say "$n is large" if $n > 1e10;
}

do-stuff 2, 3, 1e11.Int;
say '---';
do-stuff 42;

# OUTPUT:
# one(2, 3, 100000000000) is large
# ---
# one(42) is even
```

## 没有人想过将来吗?

还有一个小秘密: Junctions 被设计为时[自动线程化](https://en.wikipedia.org/wiki/Automatic_parallelization)的(即 auto-threaded)。尽管在写这篇文章的时候它们只会使用仅仅一个线程, 你不应该依赖它们能以任何可预测的顺序被执行。自动线程化会在 2018 年的某个时间被实现, 所以保持关注... 你不必做任何事情, 你的值得自动线程化的复杂 Junctioned 化的操作可能会在几年之内变得更快。

## 结论

Perl 6 的 Junctions 是值的叠加态, 它允许你测试多个值就像它们是一个值一样。除了提供非常短并且易读的语法, Junctions 还允许你使用子例程变换叠加值或者使用副作用。

你还可以生成显式操作 Junctions 的子例程或者把提供的多个值转换成 Junctions 以简化代码。

最后, Junctions 被设计为能使用所有你计算机所提供的可用能力并且在不久的将来会做成自动线程化。


Junctions 很精彩, 使用它们, 玩的开心!
























































































