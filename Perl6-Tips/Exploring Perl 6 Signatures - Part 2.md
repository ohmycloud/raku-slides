
在我们探索 Perl 6 签名的[第一部分](http://friedo.com/blog/2016/01/exploring-perl-6-signatures-part-1)中, 我们了解了怎么使用 Perl 6 强大而灵活的类型系统来约束具名参数和位置参数是如何被传递给子例程和方法的。我们还涉及了怎么使用 *slurp* 签名来创建能接收任意具名和位置参数列表的可变函数。

Perl 6 的签名系统提供了更多。在这篇文章中我们将验证其中更高级的特性, 它们让 Perl 6 的调用语义更强大。

## Class 约束

你可以使用签名来指定传递进函数中的参数的类型约束。你使用的类型可以是任意类名。

```perl6

sub foo( Numeric $foo, Str $bar) {
    say "my string is $bar and my number is $foo"
}

```

这个签名要求我们传递 **Numeric** 和 **Str** 类型的参数。但是因为 Perl 6 的内置类型实际上就是类(classes), 并且因为 **Numeric** 拥有几个子类型, 我们可以传递进任何数字类型, 它都能工作:

```perl6

foo(42, "blah");
foo(42.99, "yoohoo");
foo(3+9i, "hellooooooo");
# etc

```

我们自己定义的类中签名的工作原理也一样。

```perl6

class Foo {
    has $.prop is rw;
}

sub inspect-a-foo( Foo $my-foo ) {
    say "this foo's property is " ~ $my-foo.prop;
}

my $f = Foo.new( prop => 42 );
inspect-a-foo($f);
# this foo's property is 42

```

在上面的例子中,  子例程 *inspect-a-foo* 只会接收 **Foo** 类型的参数, 或者 **Foo** 的子类。

## 带有 **where** block 的特异性

通过在签名中使用 *where* 子句, Perl 6 允许我们更进一步的限制子例程的参数。*where* 子句接收任何 code block, 这个 `code block` 必须返回一个 true 值以使类型约束通过。

```perl6

sub foo(Int $positive where { $positive > 0 } ) {
    say "我很确信 $positive 是正的!"
}

sub bar( Foo $foo where { $foo.prop.isa( Int ) and $foo.prop > 40 } ) {
    say "这个 Foo 的属性是一个大于 40 的整数"
}

```

可以指定多个 *where* 子句来约束多个参数。

```perl6

sub quadrant2( Real $x where { $x < 0 }, Real $y where { $y > 0 } ) {
    say "at the point ($x, $y)"
}

quadrant2( 1, 1 );
# Constraint type check failed for parameter '$x'
quadrant2( -1, -1 );
# Constraint type check failed for parameter '$y'
quadrant2( -1, 1 );
# at the point (-1, 1)

```

约束块儿(Constraint blocks)甚至不需要是 *blocks*。事实上, 任何 **Callable** 类都可以。因此, 你可以很容易地获得功能函数的约束检测, 它们能在多个不同的子例程之间循环利用。

```perl6

sub is-positive( Real $n ) { $n > 0  }
sub is-negative( Real $n ) { $n < 0  }
sub is-zero( Real $n )     { $n == 0 }

sub quadrant1( Real $x where is-positive( $x ), Real $y where is-positive( $y ) ) { ... }
sub quadrant2( Real $x where is-negative( $x ), Real $y where is-positive( $y ) ) { ... }
sub quadrant3( Real $x where is-negative( $x ), Real $y where is-negative( $y ) ) { ... }
sub quadrant4( Real $x where is-positive( $x ), Real $y where is-negative( $y ) ) { ... }
sub x-axis( Real $x, Real $y where is-zero( $y ) ) { ... }
sub y-axis( Real $x where is-zero( $x ), Real $y ) { ... }
sub origin( Real $x where is-zero( $x ), Real $y where is-zero( $y ) ) { ... }

```

## Return Types

每个 Perl 6 子例程也能指定它自己的返回值类型作为签名的一部分。这可以使用 *returns* 关键字来显式地指定, 但是我更喜欢用快捷形式的 `-->` 操作符, 它在签名自身之内。下面声明的两个子例程是等价的:

```perl6

sub are-they-equal( Str $foo, Str $bar ) returns Bool {
    $foo eq $bar
}

sub are-they-equal( Str $foo, Str $bar --> Bool ) {
    $foo eq $bar
}

```

毫无疑问地, 如果返回错误的类型 Perl 6 会抛出错误。

## 自省

Perl 6 中子例程是一等对象。但是 Perl 6 带来了一大堆新的内省工具, 包含询问子例程的签名信息的能力。每个子例程的签名实际上就是 **Signature** 类的一个对象。我们能找出子例程的元数和返回值类型。我们甚至能够在签名中抓取一个 **Parameter** 对象的列表。

```perl6

sub are-they-equal( Str $foo, Str $bar ) returns Bool {
    $foo eq $bar
}

say &are-they-equal.signature.arity;    # 2
say &are-they-equal.signature.returns;  # (Bool)

my @params = &are-they-equal.signature.params;
say @params[0].name;      # $foo
say @params[0].type;      # (Str)
say @params[0].sigil;     # $

```

总之, Perl 6 的签名很好很强壮。
