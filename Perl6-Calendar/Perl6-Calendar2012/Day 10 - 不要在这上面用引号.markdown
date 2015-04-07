第十天:不要在这上面用引号





在很多地方，Perl6 都提供给你更合理的默认设置以便在大多数情况下让你的工作变得更简单有趣。引号也不例外。 基础

最常见的两种引号就是单引号和双引号。单引号最简单：让你引起一个字符串。唯一的“魔法”就是你可以用反斜杠逃逸一个单引号。而因为反斜杠的这个作用，你可以用 \\ 来表示反斜杠本身了。不过其实这个做法也是没必要的，反斜杠自己可以直接传递。下面是一组例子：

**> say 'Everybody loves Magical Trevor'**
Everybody loves Magical Trevor
**> say 'Oh wow, it\'s backslashed!'**
Oh wow, it's backslashed!
**> say 'You can include a \\ like this'**
You can include a \ like this
**> say 'Nothing like \n is available'**
Nothing like \n is available
**> say 'And a \ on its own is no problem'**
And a \ on its own is no problem

双引号，额，从字面上看就知道了，两倍自然更强大了。:-) 它支持反斜杠逃逸，但更重要的是他支持内插。也就是说变量和闭包可以放进双引号里。大大的帮你节约使用连接操作符或者字符串格式定义等等的时间。下面是几个简单的例子：

**> say "Ooh look!\nLine breaks!"**
Ooh look!
Line breaks!
**> my $who = 'Ninochka'; say "Hello, dear $who"**
Hello, dear Ninochka
**> say "Hello, { prompt 'Enter your name: ' }!"**
Enter your name: _Jonathan_
Hello, Jonathan!

(that is, an array or hash subscript, parentheses to make an invocation, or a method call) 上面第二个例子展示了标量内插，第三个则展示了闭包也可以插入双引号字符串里。闭包产生的值会被字符串化然后插入字符串中。那除了 $ 开头的呢？ 规则是这样的：所有的都可以插入，但前提是它们被某些后置框缀(译者注：postcircumfix)(也就是带下标或者扩的数组或者哈希，可以做引用或者方法调用)允许。事实上你也可以把他们都存进标量里。

**> my @beer = <Chimay Hobgoblin Yeti>;**
Chimay Hobgoblin Yeti
**> say "First up, a @beer[0]"**
First up, a Chimay
**> say "Then @beer[1,2].join(' and ')!"**
Then Hobgoblin and Yeti!
**> say "Tu je &prompt('Ktore pivo chces? ')"**
Ktore pivo chces? _Starobrno_
Tu je Starobrno

这里你看到了一个数组元素的内插，一个被调用了方法的数组切片的内插和一个函数调用的内插。后置框缀规则意味着我们再也不会砸掉你口年的邮箱地址了(译者注：邮箱地址里有@号)。

**> say "Please spam me at blackhole@jnthn.net"**
Please spam me at blackhole@jnthn.net 选择你自己的分隔符

单/双引号对大多数情况下都很好用，不过如果你想在字符串里使用这些引号的时候咋办？继续用反斜杠不是什么好主意。其实你可以自定义其他字符做为引号字符。Perl6 替你选好了。 q 和 qq 引号结构后面紧跟的字符就会被作为分隔符。如果这个字符有相对应的关闭符，那么就自动查找这个（比如，如果你用了一个开启花括号 { ，那么字符串就会在闭合花括号 } 处结束。注意你还可以使用多字符开启符和闭合符（不过要求是相同字符重复组成的多字符））。另外， q 的语义等同于单引号， qq 的语义等同于双引号。

**> say q{C'est la vie}**
C'est la vie
**> say q{{Unmatched } and { are { OK } in { here}}**
Unmatched } and { are { OK } in { here
**> say qq!Lottery results: {(1..49).roll(6).sort}!**
Lottery results: 12 13 26 34 36 46 定界符(Heredoc)

所有的引号结构都允许你包含多行内容。不过，还有更好的办法：定界文档。还是用 q 或者 qq 开始，然后跟上 :to 副词来定义我们期望在文本最后某行匹配的字符。让我们通过下面这个感人的故事看看它是怎么工作的。

print q:to/THE END/
    Once upon a time, there was a pub. The pub had
    lots of awesome beer. One day, a Perl workshop
    was held near to the pub. The hackers drank
    the pub dry. The pub owner could finally afford
    a vacation.
    THE END

脚本的输出如下：

Once upon a time, there was a pub. The pub had
lots of awesome beer. One day, a Perl workshop
was held near to the pub. The hackers drank
the pub dry. The pub owner could finally afford
a vacation.

注意输出文本并没有像源程序那样缩进。定界符会自动清楚缩进到终端的级别。如果我们用 qq ，我们也可以往定界符里插入东西。注意这些都是通过字符串的 ident 方法实现的，但是如果你的字符串里没有内插，我们会在编译期的时候调用 ident 作为一种优化手段。

你同样可以有多个定界符，包括调用定界符里的数据的方法也是可以的（注意下面的程序就调用了 lines 方法）。

my ($input, @searches) = q:to/INPUT/, q:to/SEARCHES/.lines;
    Once upon a time, there was a pub. The pub had
    lots of awesome beer. One day, a Perl workshop
    was held near to the pub. The hackers drank
    the pub dry. The pub owner could finally afford
    a vacation.
    INPUT
    beer
    masak
    vacation
    whisky
    SEARCHES
 
for @searches -> $s {
    say $input ~~ /$s/
        ?? "Found $s"
        !! "Didn't find $s";
}

这个程序输出是：

Found beer
Didn't find masak
Found vacation
Didn't find whisky 自定义引号结构的引号副词

单/双引号的语义，也是 q 和 qq 的语义，已经可以解决绝大多数情况了。不过如果你有这么种情况：你要输出内插闭包而不是标量怎么办？这时候就要用上引号副词了。它们决定你是否开启引号特性。下面是例子：

**> say qq:!s"It costs $10 to {<eat nom>.pick} here."**
It costs $10 to eat here.

这里我们使用了 qq 语义，但是关闭里标量内插，这意味着我们可以放心往里写价钱而不用担心他会试图解析成上一次正则匹配的第十一个捕获值。注意这里使用的标准的冒号对( colonpair )语法。如果你希望从一个最基础的引号结构开始，然后自己手动的一个个打开选项，那么你应该使用 Q 结构。

**> say Q{$*OS\n&sin(3)}**
$*OS\n&sin(3)
**> say Q:s{$*OS\n&sin(3)}**
MSWin32\n&sin(3)
**> say Q:s:b{$*OS\n&sin(3)}**
MSWin32
&sin(3)
**> say Q:s:b:f{$*OS\n&sin(3)}**
MSWin32
0.141120008059867

这里我们用了无特性引号结构，然后打开附加特性，地一个是标量内插，然后是反斜杠逃逸，然后函数内插。注意我们同样可以选择自己希望的任何分隔符。 引号结构是一门语言

最后，值得一提的是：当解析器进入引号结构的时候，其实他是切换成解析另外一个语言了。当我们用副词构建引号结构的时候，他只不过是把这些额外的角色混合进基础的引号语言里来开启额外的特性。好奇的童鞋可以看这里： Rakudo 怎么做到的 。而当我们碰到闭包或者其他内插的时候，解析器再临时切换回主语言。所以你可以这样写：

**> say "Hello, { prompt "Enter your name: " }!"**
Enter your name: Jonathan
Hello, Jonathan!

解析器不会困惑于内插的闭包里又带有其他双引号字符串的问题。因为我们解析主语言，然后切换到引号语言，然后返回主语言，然后重新再返回引号语言来解析这个程序里的字符串里的闭包里的字符串。这就是 Perl6 解析器送给我们的圣诞节礼物，俄罗斯套娃娃。

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2012/%E7%AC%AC%E5%8D%81%E5%A4%A9:%E4%B8%8D%E8%A6%81%E5%9C%A8%E8%BF%99%E4%B8%8A%E9%9D%A2%E7%94%A8%E5%BC%95%E5%8F%B7.markdown >  