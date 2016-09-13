# [Perl 6: S/// 操作符](http://blogs.perl.org/users/zoffix_znet/2016/04/perl-6-the-s-operator.html)
By [Zoffix Znet](http://blogs.perl.org/users/zoffix_znet/)


来自 Perl 5 背景的我， 第一次使用 Perl 6 的非破坏性替换操作符 `S///` 的经历就像下面这样:

![img](http://upload-images.jianshu.io/upload_images/326727-3a07abee4665adaf.gif?imageMogr2/auto-orient/strip)

进展会更好的。我不但会改善错误信息，而且会解释当前的所有事情。

## 智能匹配

我有问题的原因是因为，看到外形相似的操作符，我就简单地把 Perl 5 中的绑定操作符(`=~`)转换为 Perl 6 中的智能匹配操作符(`~~`) 还期望它能正常工作。事实上我是异想天开。`S///` 操作符没有文档，并且结合令人困惑的(那个时候)警告信息，这就是我痛苦的根源：

```perl6
my $orig = 'meowmix';
my $new  = $orig ~~ S/me/c/;
say $new;

# OUTPUT warning:
# Smartmatch with S/// can never succeed
```
这个丑陋的警告说这儿的 `~~` 操作符是个错误的选择并且确实如此。`~~` 操作符不是 Perl 5 的 `=~` 操作符的等价物。`~~` 智能操作符把它左边的东西起了个叫做 `$_` 的别名，然后 `~~` 计算它右侧的东西，然后在右侧这个东西身上调用 `.ACCEPTS($_)` 方法。这就是所有的魔法。

所以上面的例子实际上发生了:

- 我们到达 `S///` 的时候， `$orig` 被起了个叫做 `$_` 的别名。
- `S///` 非破坏性地在 `$_` 身上执行了替换并返回那个结果字符串。这是智能匹配将要操作的东西。
- 智能匹配，按照 Str 与 Str 相匹配的规则，会根据替换是否发生来给出 True 或 False（令人困惑的是，True 意味着没发生）

结果一路下来，我们并没有得到我们想要的：替换过的字符串。

## 使用 Given

既然我们知道了 `S///` 总是作用在 `$_` 上并且返回替换后的结果，很容易就想到几种方法把 `$_` 设置为我们原来的字符串并把 `S///` 的返回值收集回来，我们来看几个例子：

```perl6
my $orig = 'meowmix';
my $new  = S/me/c/ given $orig;
say $orig;
say $new;

my @orig = <meow cow sow vow>;
my @new  = do for @orig { S/\w+ <?before 'ow'>/w/ };
say @orig;
say @new;

# OUTPUT:
# meowmix
# cowmix
# [meow cow sow vow]
# [wow wow wow wow]
```

第一个作用在单个值上。我们使用后置形式的 *given* 块儿，这让我们避免了花括号（你可以使用 *with* 代替 *given* 得到同样的结果）。`given $orig` 会给 `$orig` 起个叫做 `$_` 的别名。从输出来看，原字符串没有被更改。

第二个例子作用在数组中的一堆字符串身上并且我们使用 *do* 关键字来执行常规的 *for* 循环(那种情况下，它把循环变量别名给 `$_` 了)并把结果赋值给 `@new` 数组。再次，输出显示原来的数组并没有发生改变。

## 副词

`S///` 操作符 -- 就像 `s///` 操作符和某些方法一样 -- 允许你使用正则表达式副词：

```perl6
given 'L?rem Ipsum Dolor Sit Amet' {
    say S:g      /m/g/;  # L?reg Ipsug Dolor Sit Aget
    say S:i      /l/b/;  # b?rem Ipsum Dolor Sit Amet
    say S:ii     /l/b/;  # B?rem Ipsum Dolor Sit Amet
    say S:mm     /o/u/;  # Lürem Ipsum Dolor Sit Amet
    say S:nth(2) /m /g/; # L?rem Ipsug Dolor Sit Amet
    say S:x(2)   /m /g/; # L?reg Ipsug Dolor Sit Amet
    say S:ss/Ipsum Dolor/Gipsum\nColor/; # L?rem Gipsum Color Sit Amet
    say S:g:ii:nth(2) /m/g/;             # L?rem Ipsug Dolor Sit Amet
}
``` 
如你所见，它们以 *:foo* 的形式添加在操作符 **S** 这个部件的后面。你可以大大方方地使用空白符号并且几个副词可以同时使用。下面是它们的意义：

- :g —(长形式：`:global`)全局匹配：替换掉所有的出现
- :i —不区分大小写的匹配
- :ii —(长形式： `:samecase`) 保留大小写：不管用作替换字母的大小写，使用原来被替换的字母的大小写
- :mm —(长形式：`:samemark`) 保留重音符号：在上面的例子中，字母 o 上的分音符号被保留并被应用到替换字母 u 上
- :nth(n) —只替换第 n 次出现的
- :x(n) —至多替换 n 次（助记符: 'x' 作为及时）
- :ss —(长形式：`samespace`)保留空白类型：空白字符的类型被保留，而不管替换字符串中使用的是什么空白字符。在上面的例子中，我们使用换行作为替换，但是原来的空白被保留了。

## 方法形式

`S///` 操作符很好，但是有时候有点笨拙。不要害怕， Perl 6 提供了 `.subst` 方法能满足你所有的替换需求并且消除你对 `.subst/.substr` 的困惑。下面来看例子：

```perl6
say 'meowmix'.subst: 'me', 'c';
say 'meowmix'.subst: /m./, 'c';

# OUTPUT:
# cowmix
# cowmix
```

这个方法要么接收一个正则表达式要么接收一个普通的字符串作为它的第一个位置参数，它是要在调用者里面("meowmix")查找的东西。第二个参数是替换字符串。

通过简单地把它们列为具名 Bool 参数，你也可以使用副词。在 `S///` 形式中， 副词 `:ss` 和 `:ii` 分别表明 `:s`(使空白有意义) 的出现和  `:i`(不区分大小写的匹配) 的出现。在方法形式中，你必须把这些副词应用到正则表达式自身身上：

```perl6
given 'Lorem Ipsum Dolor Sit Amet' {
    say .subst: /:i l/, 'b', :ii;
    say .subst: /:s Ipsum Dolor/, "Gipsum\nColor", :ss;
}

# OUTPUT:
# Borem Ipsum Dolor Sit Amet
# Lorem Gipsum Color Sit Amet
```

## 方法形式的捕获

捕获对于替换操作来说不陌生，所以我们来尝试捕获下方法调用形式的替换：

```perl6
say 'meowmix'.subst: /me (.+)/, "c$0";

# OUTPUT:
# Use of Nil in string context  in block <unit> at test.p6 line 1
# c
```

不是我们要找的。我们的替换字符串构建在达到 `.subst` 方法之前，并且里面的 `$0` 变量实际上指向任何这个方法调用之前的东西，而不是 `.subst` 正则表达式中的捕获。所以我们怎么来修正它呢？

`.subst` 方法的第二个参数也可以接受一个 [Callable](http://docs.perl6.org/type/Callable)。在它里面，你可以使用 `$0, $1, ... $n` 变量，直到你想要的编号，并从捕获中得到正确的值：

```perl6
say 'meowmix'.subst: /me (.+)/, -> { "c$0" };

# OUTPUT:
# cowmix
```

这里，我们为我们的 **Callable** 使用了尖号块儿，但是 **WhateverCode** 和子例程也有效。每次替换都会调用这个 Callable，并且把 [Match](http://docs.perl6.org/type/Match) 对象作为第一个位置参数传递给 Callable， 如果你需要访问它的话。

## 结论

`S///` 操作符在 Perl 6 中是 `s///` 操作符的战友，它不是修改原来的字符串，而是拷贝原来的字符串，修改，然后返回修改过的版本。这个操作符的使用方式跟 Perl 5 中的非破坏性替换操作符的使用方式不同。作为备选， 方法版本的 `.subst` 也能使用。 方法形式和操作符形式的替换都能接收一组副词以修改它们的行为，来满足你的需求。