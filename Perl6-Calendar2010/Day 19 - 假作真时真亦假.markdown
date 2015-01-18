​ 2010 年 Perl6 圣诞月历(十九)假作真时真亦假


今天的圣临礼物是教大家怎么用混淆完成一个小邪恶滴目的，吼吼~看起来这个功能挺疯狂的，其实有时候蛮有用的。先看下面这个用 but 的例子：

my $value = 42 but role { method Bool  { False } };
say $value;    # 42
say ?$value;   # False

你看，我们改变了 $value 的 .Bool 方法。他不影响程序里其他所有的整数，哪怕别的变量也是 42。一般情况下，对于 Int 型， .Bool 方法（通过 ? 操作符）返回值依据是是否等于 0。但这次它永远都返回 false 了。

事实上，我们还可以写的更简单，因为 False 是一个枚举值：
my $value = 42 but False;

因为 False 是 Bool 值，所有它会自动重载 .Bool 方法。这是 Perl6 的一种转换方法。其他的值，也会对应的重载。

这样在有的时候，这个东西就比较有用了：在 Perl5 里，你用 system 调用 shell 的时候，得牢牢记住在 shell 里，返回 0 才是正常的：

if ( system($cmd) == 0 ) {  # 或者!system($cmd)
    # ...
}

而在 Perl6 中，对应的 run 命令返回的是上面说的这种重载过的 Int，当且仅当返回值是 0 的时候，它的 bool 变成了 True，这正是我们想要的额！

if run($cmd) {  #不需要否定了
    # ...
}

好了，现在进入最疯狂的部分 —— 我们可以重载布尔值的布尔方法：

my $value = True but False;
say $value;    # True
say ?$value;   # False

没错，Perl6 允许你这样自己踢自己屁股~~虽然我也不知道除了捣乱外怎么会有人愿意这么做，但是我还是很高兴看到 Perl6 保持这种微妙的跟踪和重载类型的心态。我可没有……

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2010/%E7%AC%AC%E5%8D%81%E4%B9%9D%E5%A4%A9:%E5%81%87%E4%BD%9C%E7%9C%9F%E6%97%B6%E7%9C%9F%E4%BA%A6%E5%81%87.markdown >  