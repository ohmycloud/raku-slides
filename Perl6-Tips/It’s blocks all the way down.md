[It’s blocks all the way down](https://gfldex.wordpress.com/2016/07/19/its-blocks-all-the-way-down/)

当我在 [glot.io](https://glot.io/new/perl6) 上玩 Perl 6 的时候我知道它们真的很像带有简单程序的 docker：

```perl6
dir('/')>>.Str.say;
```

我想知道递归到目录里面是否还有更好的方法。 IO::Path.dir 会返回一个 IO::Path 对象的 Seq 序列。那就是为什么 `>>.` 超运算符会有效。它当然不会递归因为没有用来进行递归的子例程, 经过一段时间的冥思苦想我找到了我找了很久的东西。

在 Perl 6 中带有一个位置参数的 block 块是可调用的(Callable)。那个参数被绑定给主题变量 `$_`。 那是我们为什么能做:

```perl6
for 1,2,3 {.say}
```

递归到目录中会很容易如果我们把 `Str '/'` 变成 IO::Path 对象并且检测我们是否得到了一个目录并且使用那个元素调用那个 block 块。那个 block 块需要一个名字, 这个我们可以通过使用 `my &block = {Nil}` 做到, 或者我们使用编译时变量 `&?BLOCK`。

```perl6
for '.' {
    .Str.say when !.IO.d;
    .IO.dir()>>.&?BLOCK.IO.d
}
```

`.&?BLOCK` 形式会把调用看作像方法调用一样, 这意味着 `.` 号左侧的对象会成为调用的第一个参数, 在调用者所属的地方。

我相信这是一个相当好的关于怎样使用 `&?BLOCK` 来避免嵌套循环和短变量的例子。这会在稍后被添加到文档中。

在 [Zoffix](http://perl6.party/) 的友好帮助下, 那个例子被进一步优化了。

```perl6
{ .d && .dir».&?BLOCK || .put }(".".IO)
```



















































