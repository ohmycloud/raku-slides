## Sneaking into a loop

[Sneaking into a loop]https://gfldex.wordpress.com/2016/08/10/sneaking-into-a-loop/

Zoffix 回答了一个关于 Perl 5s <> 操作符的[问题](http://irclog.perlgeek.de/perl6/2016-08-09#i_12993090)。

```perl6
slurp.words.Bag.sort(-*.value).fmt("%10s3d\n").say;
```

`slurp` 会从 STDIN 中读取整个 "file" 并返回一个 Str。方法 `Str::words` 会按照某种 Unicode 意义的单词把该字符串分割成一个列表。把列表强转为 Bag 则创建一个计数 Hash, 它是如下表述的快捷方式。

```perl6
my %h;
%h{$_}++ for <peter paul marry>;
dd %h;

# # OUTPUT?Hash %h = {:marry(1), :paul(1), :peter(1)}??
```

在关联数组上调用 `.sort(-*.value)` 会按照值的降序排序并返回一个排序后的 Pairs 列表。List::fmt 会调用 Pair::fmt, 它调用 fmt 方法, .key 作为其第二个参数, .value 也作为参数。say 会会使用一个空格连接各个元素并输出到标准输出。最后一步有一点错误因为除了第一行之外的每一行前面都会有一个额外的空格。

```perl6
slurp.words.Bag.sort(-*.value).fmt("%10s => %3d").join("\n").say;
```

手动连接字符串更好。这对于简短的单行程序来说有点多了。我们需要找到最长的单词并使用 `.chars` 来获取列宽。


slurp 会在 `$*IN` 身上调用 `.slurp-rest` 方法。

```perl6
$*IN = <peter paul marry peter paul paul> but role { method slurp-rest { self.Str } };
```

这是一种 hack 因为它会在任何形式的类型检测上失败并且它除了 slurp 之外不会对任何东西起作用。还有, 实际上我们从 `$*IN` 那里解绑 STDIN。不要在工作中使用这个奇淫技巧。


现在我们能开心地吞噬并开始计数了。

```perl6
my %counted-words = slurp.words.Bag;
my $word-width = [max] %counted-words.keys?.chars;
```


并且继续在链子断开的地方继续。

```perl6
%counted-words.sort(-*.value).fmt("%{$word-width}s3d").join("\n").say;
```

问题解决了但是很丑陋。我们把一个单行程序拆开了。我们来修复 fmt 以使它再次完整。

我们想要的是一个 fmt 方法, 它接收一个位置的(Positional), 一个 printf 风格的格式字符串和一个格式字符串中的 block per `%*`。还有, 我们可能需要在 self.fmt 前面放上一个分隔符。

```perl6
my multi method fmt(Positional:D: $fmt-str, *@width where *.all ~~ Callable, :$separator = " "){
    self.fmt(
        $fmt-str.subst(:g, "%*", {
            my &width = @width[$++] // Failure.new("missingh block");
            '%' ~ (&width.count == 2 ?? width(self, $_) !! width(self))
        }), $separator);
}
```

表达式 `*.all ~~ Callable` 检查 [slurp array](https://docs.perl6.org/type/Signature#Slurpy_(A.K.A._Variadic)_Parameters)中的所有元素是否实现了 CALL-ME(那是实际被执行的方法在你执行 foo()的时候)。

然后我们在格式字符串上使用了 `subst` 来替换 `%*`, 替换是一个(闭包)块儿, 它每次匹配被调用一次。而且这儿我们有不错的惯用法。

```perl6
say "1-a 2-b 3-c".subst(:g, /\d/, {<one two three>[$++]});
# one-a two-b three-c
```

匿名状态变量 `$` 从 0  开始计数, 每次代码块执行时增 1。实际上我们在这儿做的就是移除一个循环并给 subst 偷偷加入一个额外的计数器和数组下标。或者可以说我们注册了一个迭代器到 subst 里面的循环中。有人可能会质疑 subst 应该接收一个 Seq 作为它的第二个位置参数, 它会让调用变得冗长。无论如何, 我们把洞补上了。

在第 11 行, 我们从吞噬数组中拿出一个元素或者在没有元素时创建一个 Failure。我们把 block 存储在一个变量中因为我们想在第 12 行中内省。如果那个 block 接收两个位置参数,we feed the topic subst is calling the block with as a 2nd parameter to our stored block. 那碰巧是一个 Match 并且对于影响所匹配的东西可能有用。在我们这个例子中我们对 `%*` 进行匹配并且当前位置由 `$++` 计数。做完那个之后我们得到了一个格式字符串, 它带有一个由用户提供的 fmt 版本的列宽参数。

用户提供的块儿使用一组 Pairs 调用。我们不得不深入一层以得到更大的键。

```perl6
{[max] .values?.keys?.chars}
```  

得到第一列的列宽。


```perl6
print %counted-words.sort(-*.value).&fmt("%*s3d", {[max] .values?.keys?.chars}, separator => "\n");
```


那个时髦的 `.&fmt` 调用是必须的因为我们免费的浮点方法不是 List 的方法。

-- 翻译的好烂。