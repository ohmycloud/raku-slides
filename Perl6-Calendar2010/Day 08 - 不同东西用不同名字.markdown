2010 年 Perl6 圣诞月历(八)不同东西用不同名字

Perl5 的新手们，总会很奇怪的说为啥自己没法倒装呢？Perl 里有内置的 reverse 命令，但好像压根不起作用啊：

$ perl -E "say reverse 'hello'"
    hello

当他们去问一些有经验的 perler 的时候，解决办法很快就有了。因为 reverse 有两种操作模式，分别工作在标量和列表环境下，用来倒装字符串和列表元素：

$ perl -E "say scalar reverse 'hello'"
    olleh

比较悲剧的是这个情况和大多数的 perl 语境是不一致的。比方说，绝大多数的操作符和函数由自己决定语境，并在这个语境下分析数据。好比 + 和 * 作用于数字， . 作用于字符串。所以说他们代表一个操作并且提供语境，而 reverse 却不是。

在 Perl6 里，我们从过去的错误里吸取教训以摆脱历史的窘境。所以我们把列表倒叙，字符串翻转，哈希反演分开成了三个操作：

    # 字符串翻转，改名叫flip
    $ perl6 -e 'say flip "hello"'
    olleh
    # 列表倒叙
    $ perl6 -e 'say join ", ", reverse <ab cd ef>'
    ef, cd, ab
    # 哈希反演，叫invert
    $ perl6 -e 'my %capitals = France => "Paris", UK => "London";
              say %capitals.invert.perl'
    ("Paris" => "France", "London" => "UK")

注意哈希的反演和其他两个不同。因为哈希的值不要求是唯一的，所以反演后，哈希结构可能会被改变，或者某些值被覆盖……

如果必要的话，使用者可以自己决定返回哈希结构时的操作方式。比如下面就是一种无损的方式：

my %inverse;
    %inverse.push( %original.invert );

这个方法会在键值对存在的情况下，把新值push在原有值的队尾变成一个数组：

    my %h;
    %h.push('foo' => 1);    # foo => 1
    %h.push('foo' => 2);    # foo => [1, 2]
    %h.push('foo' => 3);    # foo => [1, 2, 3]

这三个函数，都会强制转换他们的参数。也就是说，如果你传递一个列表给 flip ，这个列表会被强制成字符串后再翻转返回。

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2010/%E7%AC%AC%E5%85%AB%E5%A4%A9:%E4%B8%8D%E5%90%8C%E4%B8%9C%E8%A5%BF%E5%8F%AB%E4%B8%8D%E5%90%8C%E5%90%8D%E5%AD%97.markdown >  