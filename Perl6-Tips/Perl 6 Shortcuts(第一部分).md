

[查看原文](http://blogs.perl.org/users/zoffix_znet/2016/02/perl-6-shortcuts-part-1.html)

快捷(Shortcuts)是一个具有争议性的话题。有些人认为它让代码更快更易读。有些人认为它让代码变得更难度如果人们不熟悉那些快捷的话。这篇文章仅仅告诉你 Shortcuts 的东西, 用不用取决于你。让我们开始把。

## 类属性的公开 Getter/Setter

"getter" 和 "setter" 的概念在很多语言中是共通的: 在你的类中有一个 "东西", 并且你写了一个方法来设置或获取那个东西的值。以啰嗦的 Perl 6 方式来写, 这样的一个设置看起来像这样:

``` perl6
class Foo {
    has $!attr = 42;
    method attr is rw { $!attr }
}

my  $obj = Foo.new;
say $obj.attr;
    $obj.attr = 72;
say $obj.attr;

# 输出>>
# 42
# 72
```

这就像它本来的那样简洁, 但公共属性通常足以使编写这点儿代码变得恼人。这就是为什么 `$.` twigil 存在的原因。单独使用它会创建一个 "getter"; 如果你还想要一个 "setter", 需要使用 `is rw` 特性:

``` perl6
class Foo { has $.attr is rw = 42; }
my  $obj = Foo.new;
say $obj.attr;
    $obj.attr = 72;
say $obj.attr;

# 输出>>:
# 42
# 72
```

我们把属性上的 `$!` twigil 更改为 `$.` twigil, 并且它为我们创建了一个公共的方法。继续!

## 在方法调用中省略圆括号

下面这样的代码你不会经常看见, 代码末尾有一整吨的圆括号。确保它们都能匹配!

``` perl6
$foo.log( $obj.nukanate( $foo.grep(*.bar).map(*.ber) ) );
```

对于那些想起  [popular webcomic](https://xkcd.com/297/) 的人来说, Perl 6 还有一个备选项:

``` perl6
$foo.log: $obj.nukanate: $foo.grep(*.bar).map: *.ber;
```

如果方法在方法调用链的最后, 你可以省略它的圆括号并使用一个冒号 : 代替。除了 `.grep`, 我们上面所有的调用在链中都是最后的(last in chain), 所以我们避免了很多圆括号。有时我也喜欢在冒号后面换行开始写东西。

还要注意: 你总是可以省略方法调用中的圆括号, 如果你没有提供任何参数的话; 也不需要分号。

## 没有逗号的具名参数

如果你正调用一个提供只有具名参数的方法或子例程的话, 你可以省略参数之间的逗号。有时候, 我也喜欢把每个参数作为新行叠放在一块儿:

``` perl6
class Foo {
    method baz (:$foo, :$bar, :$ber) { say "[$foo, $bar, $ber]" }
}
    sub    baz (:$foo, :$bar, :$ber) { say "[$foo, $bar, $ber]" }

Foo.baz:
    :foo(42)
    :bar(72)
    :ber(100);

baz :foo(42) :bar(72) :ber(100);

# OUTPUT>>:
# [42, 72, 100]
# [42, 72, 100]
```

再次, 这在当你提供只有具名参数的时候才有效。有很多很多其它使用同样形式提供参数或 Pairs 但是你又不能省略逗号的地方。

## 具名参数/Pairs 中的整数

‘如果参数或 Pair 接收一个正整数作为值, 就把数字写在冒号和键的名字之间:

``` perl6
say DateTime.new: :2016year :2month :1day :16hour :32minute;

# 输出>>:
# 2016-02-01T16:32:00Z
```

这是其中之一当你第一次学习它的时候看起来不和谐的东西, 但是你会很快习惯它。它读起来很像英语:

``` perl6
my %ingredients = :4eggs, :2sticks-of-butter, :4cups-of-suger;
say %ingredients;

# OUTPUT>>:
# cups-of-sugar => 4, eggs => 4, sticks-of-butter => 2
```

## 具名参数/Pairs 中的布尔值

使用键自身的名字来标示 **True**, 在键名和冒号之间插入一个感叹号来标示 **False**:

``` perl6
sub foo (:$bar, :$ber) { say "$bar, $ber" }
foo :!bar :ber;

my %hash = :!bar, :ber;
say %hash;

# OUTPUT>>:
# False, True
# bar => False, ber => True
```

注意: 这也能应用在副词上!

## 具名参数/Pairs 中的 Lists

如果你正提供一个 quote-word 结构给一个期望某种 listy 的具名参数/pair, 那么你可以省略圆括号; 在键和  quote-words 之间不留任何空格就是了:

``` perl6
sub foo (:@args) { say @args }
foo :args<foo bar ber>;

my %hash = :ingredients<milk eggs butter>;
say %hash;

# OUTPUT>>:
# (foo bar ber)
# ingredients => (milk eggs butter)
```

## 传递变量给具名参数/Pairs

你认为具名参数就这样了吗？还有一个更酷的 shortcut: 假设你有一个变量并且它和具名参数拥有相同的名字… 就通过使用变量自身把它传递进来好了, 代替键, 在冒号之后:

``` perl
sub hashify (:$bar, :@ber) {
    my %hash = :$bar, :@ber;
    say %hash;
}

my ( $bar, @ber )  = 42, (1..3);
hashify :$bar :@ber;

# OUTPUT>>:
# bar => 42, ber => [1..3]
```

注意我们既没有在 sub 调用中也没有在我们创建的 hash 中重复键的名字。它们是从变量的名字中派生出来的。

## Subs 作为方法调用

如果你有一个 sub 想在某些东西上作为方法调用, 就在 sub 那儿前置一个 `&`符号就好。 调用者会是第一个位置参数, 所有其它参数像往常那样传递。

``` perl
sub be-wise ($self, $who = 'Anonymous') { "Konw your $self, $who!" }

'ABC'.&be-wise.say;
'ABC'.&be-wise('Zoffix').say;

# OUTPUT>>:
# Know your ABC, Anonymous!
# Know your ABC, Zoffix!
```

这实质上是一种不那么难看的在某个实例上调用 `.map`的方式, 但是多数时候它的可读性更好。

``` perl
sub be-wise ($self, $who = 'Anonymous') { "Know your $self, $who!" }

'ABC'.map({be-wise $_, 'Zoffix'})».say;
say be-wise 'ABC', 'Zoffix';

# OUTPUT>>:
# Know your ABC, Zoffix!
# Know your ABC, Zoffix!
```

为了完整性, 但不是过度使用, 你可以内联调用甚至使用一个 pointy block 来设置签名!

``` perl6
'ABC'.&('Know your ' ~ *).say;
'ABC'.&( -> $self, $who = 'Anonymous' {"Know your $self, $who!"} )('Zoffix')
    .say;

# OUTPUT>>:
# Know your ABC
# Know your ABC, Zoffix!
```

## Hyper 方法调用

因为我们谈到了 .map 的快捷方式, 记住 » hyper 操作符。在方法调用的点号之前使用它以标示你想在调用者的每个元素身上调用点号后面跟着的方法, 而不是调用者本身。

``` perl6
(1, 2, 3)».is-prime.say;
(1, 2, 3)>>.is-prime.say;

# OUTPUT>>:
# (False True True)
# (False True True)
```



## 总结

- 使用 `$.` twigil 来声明公共属性
- 使用 `:`代替圆括号
- 只含具名参数的 Methods/sub 调用不需要逗号
- 通过把整数值写在键和冒号之间传递 Int 值
- 使用键自身来指定一个 True 布尔值
- 使用键自身, 并在键名和冒号之间插入一个 ! 号来指定一个 **False** 值
- 当值是 quote-word 结构时, 把它写在键后面, 不含任何圆括号
- 当变量和键的名字相同时, 把它直接用作键(包括符号), 不用指定任何值
- 在 sub 那儿前置一个 `&`, 当把它作为方法调用时
- 使用 » 操作符来对列表中的每个元素调用一个方法
