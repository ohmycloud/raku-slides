title:  Day 19 – Introspection

date: 2016-02-04

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>这一生圆或缺当归在你心间！</blockquote>

Perl 6 支持"泛型, roles 和 多重分发", 它们都是很好的特点, 并且已经在其它 advent calendar 中发布过了。



但是今天我们要看的是 **MOP**。 "MOP"代表着元对象协议("Meta-Object Protocol")。那意味着, 它们实际上是你能从用户那边改变的一部分, 而不是对象、类等定义语言的东西。



实际上, 在 Perl 6中, 你可以为类型添加方法, 移除某个方法, 包裹方法, 使用更多能力增强类([OO::Actors](https://github.com/jnthn/oo-actors)  和 [OO::Monitors](https://github.com/jnthn/oo-monitors) 就是两个这样的例子), 或者你可以完全重定义它(并且, 例如, 使用 Ruby-like 的对象系统。[这儿有个例子](https://github.com/edumentab/rakudo-and-nqp-internals-course))。



但是今天, 我们首先看一下第一部分: 自省。在类型创建完之后查看它的类型, 了解它, 并使用这些信息。



我们将要创建的模块是基于 [Sixcheck](https://github.com/vendethiel/sixcheck) 模块(一个 [QuickCheck-like](https://en.wikipedia.org/wiki/QuickCheck) 模块)的需求: 为某个类型生成一些随机数据, 然后把数据喂给我们正测试的函数, 并检查某些后置条件(post-condition)。



所以, 我们先写出第一个版本:

``` perl6
my %special-cases{Mu} = 
  (Int) => -> { (1..50).pick },
  (Str) => -> { ('a'..'z').pick(50).join('') },
;

sub generate-data(Mu:U \t) {
    %special-cases{t} ?? %special-cases{t}() !! t.new;
}

generate-data(Int);
```

注意以下几点:

- 我们给 %special-cases 指定了键的类型。那是因为默认地, 键的类型为 **Str**。显然地, 我们不想让我们的类型字符串化。我们实际上做的是指定它们为"Mu"的子类(这在类型"食物链"的顶端)。
- 我们在 **Int** 和 **Str** 周围放上圆括号, 以避免字符串化。
- 我们在函数参数类型中使用了 `:U`。那意味着那个值必须是未定义的(undefined)。类型对象(就像 Int、Str 等等)是未定义的, 所以它能满足我们(你可能见过一个叫 Nil 的不同的未知值)。
- 类型对象实际上是对象, 就像其它任何对象一样。这就是为什么我们在类型对象上调用 `.new`方法, 例如, 它和直接调用 `Int.new`相同(那对一致性和 [autovivification](https://design.perl6.org/S09.html#Autovivification) 很有用)。
- 我们为 *Int* 和 *Str* 提供了fallback, 因为调用 *Int.new* 和 *Str.new* ( 0 和 "" )不会在我们创建的数据中给我们任何随机化。
- Perl 6 在函数中自动返回最后一个表达式。所以不需要在那儿放上一个 *return*。

我们用代码生成数据, 公平且公正。但是我们需要生成更多那样简单的数据。



我们至少需要支持带有属性的类: 我们想查看属性列表, 为它们的类型生成数据, 并把它们喂给构造器。



我们要能够看到类的内部。用 Perl 6 的术语来说, 我们将要到达的是元对象协议([Meta-Object Protocol](https://perl6advent.wordpress.com/2010/12/22/day-22-the-meta-object-protocol/))。首先我们定义一个类:

``` perl6
class Article {
    has Str $.title;
    has Str $.content;
    has Int $.view-count;
}

# 我们可以这样手动创建一个实例
Article.new(title      => "Perl 6 Advent, 第 19 天",
            content    => "Magic!",
            view-count => 0
            );
```

但是我们不想亲手创建那个文章 (article)。我们想把那个 **class** Article 传递给我们的 *generate-data* 函数, 并返回一个 Article(里面带有随机数据)。让我们回到我们的 *REPL*...

``` perl6
say Article.^attributes;         # (Str $!title Str $!content Int $!view-count)
say Article.^attributes[0].WHAT; # (Attribute)
```

如果你点击了 MOP 链接, 你不会对我们得到一个含有 3 个元素的数组感到惊讶。如果你仍旧对该语法感到惊讶, 那么 `.^`是元方法调用。意思是 `a.^b`会被转换为 `a.HOW.b(a)`。



如果我们想知道我们可以访问到什么, 我们问它就是了(移除了匿名的那些):

``` perl6
Attribute.^methods.grep(*.name ne '<anon>'); 
# (compose apply_handles get_value set_value 
#      container readonly package inlined WHY set_why Str gist)

Attribute.^attributes # Method 'gist' not found for invocant of class 'BOOTSTRAPATTR'
```

哎吆… 看起来这有点太 meta 了。幸好, 我们能使用 Rakudo 的一个非常好的属性: 它的大部分都是用 Perl 6写的! 要查看我们可以得到什么, 我们查看[源代码](https://github.com/rakudo/rakudo/blob/nom/src/core/Attribute.pm)就好了:

``` perl6
# has Str $!name;
...
# has Mu $!type;
```

我们得到了键的名字, 还有去生成值的类型。让我们看看...

``` perl6
> say Article.^attributes.map(*.name)
($!title $!content $!view-count)
> say Article.^attributes.map(*.type)
((Str) (Str) (Int))
```

天才! 看起来是正确的。(如果你想知道为什么我们得到 `$!`（私有的） twigils, 那是因为 `$.`只意味着将会生成的一个 getter 方法)。属性本身仍然是私有的, 并且在类中是可访问的。



现在, 我们唯一要做的事情就是创建一个循环...



``` perl6
my %args;

for Article.^attributes -> $attr {
    %args{$attr.name.substr(2)} = generate-data($attr.type);
}
say %args.perl;
```

这是一个将会打印什么的例子:

``` perl6
{:content("muenglhaxrvykfdjzopqbtwisc"), :title("rfpjndgohmasuwkyzebixqtvcl"), :view-count(45)}
```

每次你运行你的代码你都会得到不同的结果(然而我不认为它会创建一篇值得阅读的文章…)。剩下唯一要做的就是把它们传递给 Article 的构造函数:

``` perl6
say Article.new(|%args);
```

(前缀 `|`允许我们把 *%args* 作为具名参数传递, 而不是单个位置参数)。再次, 你应该会打印这些东西:

``` perl6
Article.new(title => "kyvphxqmejtuicrbsnfoldgzaw", content => "jqbtcyovxlngpwikdszfmeuahr", view-count => 26)
```

呀! 我们设法在不了解 Article 的情况下胡乱地(blindly)创建了一个 Article 实例。 我们的代码能够用于为任何期望传递它的类属性的构造函数生成数据。好了!

PS: 留个作业! 移动到 generate-data 函数, 以至于我们能给 Article 添加一个 User $.author 属性, 并且构建好这个函数。祝你好运!