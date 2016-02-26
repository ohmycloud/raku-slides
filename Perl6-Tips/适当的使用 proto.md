title:  适当的使用 proto

date: 2016-02-18

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>去年的家书两行, 读来又热泪盈眶！</blockquote>

原文在此[Apropos proto: Perl6.c multi thoughts](http://blogs.perl.org/users/yary/2016/02/apropos-proto-perl6c-multi-thoughts.html)

Multi 程序相当整洁, 但对于我来说是不彻底的。一些背景 — 有人可能这样计算阶乘:

``` perl6
multi fac(0) { 1 }
multi fac(Int $n where 1..Inf) { $n * fac( $n-1 ) }
say fac(4); # 24
```

现在假设我们要把我们的递归 multi-sub 作为一个回调传递会怎样呢？

``` perl6
given &fac -> $some_fun { say "some_fun(4)=", $some_fun(4) }
```

现在... 定义一个匿名的 multi-sub 怎么样？

``` perl6
my $anon_fac = do {
    multi hidden_fac(0) { 1 }
    multi hidden_fac(Int $n where 1..Inf) { $n * fac( $n - 1 ) }
    &hidden_fac };
   
say $anon_fac(4); # 24
```

这也会有作用, 但是有点 hack 的味道, 并且我们的 multi-sub 并不是真正的匿名。它仅仅是被隐藏了。真正匿名的对象不会在任何作用域中安装, 而在这个例子中, "hidden_fac" 被安装在 "do" block 中的本地作用域中。

Perl 6说明书没有排除匿名的 multi 程序, 而且事实上

``` perl6
my $anon_fac = anon multi sub(0) { 1 }
```

会报一个错误:

> Cannot use 'anon' with individual multi candidates. Please declare an anon-scoped proto instead

不能对单独的 multi 候选者使用 `anon`。请声明一个 anon-scoped 的 **proto** 代替。

让我们回到原先那个以 "multi fac(0) { 1 }" 开始的例子。当编译器看到它, 就会在同一个作用域中为我们创建一个"proto fac" 作为 *multi* 定义。*proto* 的作用就像一个分发器(dispatcher) — 从概念上讲, 当我们调用 fac(4) 的时候, 我们让 *proto fac* 为我们从 *multi facs* 中挑选一个出来以调用。

我们可以提前显式地定义一个 *proto*, 而且我们甚至能通过指定它的所有程序都需要 **Int** 类型的参数来对默认的 "proto" 加以改良。

``` perl6
proto fac_with_proto(Int) { * }
multi fac_with_proto(0)   { 1 }
multi fac_with_proto(Int $n where 1..Inf) { $n * fac( $n - 1 ) }
say fac_with_proto(4); # 24
```

因此, *anon muiti sub* 抛出的错误 — *Please declare an anon-scoped proto instead* — 正是告诉我们 "没有要安装到的作用域, 我不能为你获取一个 proto。 使用你自己的 *anon proto*, 并把这个程序附加给它"。

好的, 花蝴蝶, 感谢你的提醒! 我试试...

``` perl6
my $fac_proto = anon proto uninstalled-fac(Int) { * };
say $fac_proto.name; # uninstalled-fac
```

好极了! 现在所有我们要做的就是给那个 *proto* 添加 *multi*s。

**$fac_proto** 是一个 **Sub** 对象, 它有方法来告诉你候选者, 但是没有办法设置(**set**) 候选者。并且我找不到任何方式在创建时传递一个候选者列表。

## 适当的修补

什么会让 *proto/multi* 干净并且正交是一种方式去

- 在编译时指定候选者
- 在运行时添加候选者

这有点像

``` perl6
my $future_fac = Proto( :dispatch( sub (Int) {*} ),
                        :candidates( [sub (0) {1}] ),
                        :mutable );

$future_fac.candidates.push(
    sub (Int $n where 1..Inf) { $n * fac( $n-1 ) }
  );

$future_fac(4); # 24
```

我假定了一个 **Sub** 的子类 **Proto** 以揭露 multi 程序的内部工作原理。这个构造函数会允许定义任何 *proto* 声明符所做的: 签名 & 默认程序和名字。 还有, 它会允许在初始的候选者列表中传递一个属性。

最后, 那个对象自身会让候选者方法返回一个数组, 而不是一个不可变列表, 如果 *Proto* 是使用 *mutable* 属性创建的话。不指定 *mutable* 将意味着所有的 *multi*s 需要在编译时添加, 而不允许在运行时添加。

