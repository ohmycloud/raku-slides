
# 2009
## 有用的和有意思的循环

让我们来看一个基本的例子.


```perl
for 1, 2, 3, 4 { .say }
```


  这是一个最简单清晰的语法的例子.在这并没有使用`括号`来包起整个列表的语句,象这种写法可以贯穿整个 Perl 6. 通常比起 Perl 5 来你没有必要写那么多的括号了.

很象 Perl 5 , 这个循环中的值会默认存到 `$_` .在这个方法调用的 say 其实就是 `$_.say`.注意在 Perl 6 中,你不能直接只打一个 say  而不加参数,它会默认使用 $_ 来传参.你需要使用 `.say` 。要么明确的指定是 `$_`.

下面这个语法块并不是一个普通的块.它能通过一个尖的指向,来告诉你的 循环变量传进去的参数的名字 .

```perl  
for 1, 2, 3, 4 -> $i { $i .say }
```

    如果你调用的 return 内部有这个,将返回闭合的子函数.
    这个尖尖也能取 多个 参数.象下面这样.
1
2
3

```perl
>  for 1, 2, 3, 4 -> $i , $j { "$i, $j" .say }
1 2
3 4
```

实际做了些什么啦？就是你在列表进行迭代时一次取了`两个`元素 . 如果你不明确指明参数的话,就退化到 Perl 5 一样使用 `$_`.

我们可以意识到这个我们能做什么,比如迭代一个列表。当然,也可以是一个数组的值.

```perl
for @array { .say }
```

  这是一个非常简单的例子,我们可能更加喜欢使用 `map:`

```perl  
@array.map : *.say;
```

如果对你来讲 顺序 和连续的并不重要,你可以使用 `hyperoperator（超运算符）`,上一个文章中也讲过这个,今天的主题也不详细讲这个了.

```perl
 @array».say;
```

我们也能使用 范围构造器中缀操作符 `..` 来生成一个数字的列表：


```perl
  for 1..4 { .say }
```


有一个最通用的功能,就是我们想些生成一个从 `0` 开始到 `$n` 的数字的列表,比如常用的数组下标.我们可以写成 `0 .. $n-1`或者另一个不同的范围构造器 `0..^$n`.但在 Perl 6 中提供了一个短的快捷的方法就是使用前缀的 `^`.


```perl
for ^4 { .say }
```


0
1
2
3

一个常用的理由是,人们在 Perl 5 中常常退回到 C 风格的循环的原因是必须知道 for 的成员数组中索引的位置,或者因为必须并行的迭代二个和更多的数组.Perl 6 提供了一个短的快捷方法,就是中缀的 Z 这个 zip 操作符.


```perl
for @array1 Z @array2 -> $one , $two { ... }
```

假设二个数组是相同的长度`$one` 会是第一个 `@array1` 的成员元素,`$two` 会是相应的位置 `@array2` 的成员元素.如果是不同的长度的话.迭代会停止到短的那个数组结束的长度.
        我们可以很容易地在迭代数组包含进索引：

```perl
for ^Inf Z @array -> $index , $item { ... }
```

如果一个无限长的列表,会让你害怕使用上面用法的话,可以象下面这样,使用前缀操作符 `^` 来取出数组元素的长度.

```perl
for ^@array.elems Z @array -> $index , $item { ... }
```

上面这个可以得到相同的结果,但是更加优雅.因为中缀操作符 `Z` 操作时,第一个元素的长度决定了什么整个长度.

```perl
for @array.kv -> $index , $item { ... }  
```

`@array.kv` 会返回 `keys` 和 `values` 的交错,这个 `$key` 是数组元素的下标.所以同时迭代这二个可能是你比较想要的效果.
希望这篇文章让你了解 Perl 6 灵活的循环相关的一些概念,它们可以灵活的使用在各种常见任务上.在这之前,我要回答最后一个问题,我知道有人一直在想这个问题.怎么样一次性迭代四个数组.

```perl
for @one Z @two Z @three Z @four -> $one , $two , $three , $four { ... }
```

这是一个关联列表中缀操作符,这样使用,是不是一种享受？

## 超运算符

pmichaud 在昨天介绍了 Perl 6 的 hyper 运算符,我这要进一步来探索 Perl6 中强大的元操作的特性.
首先,为简单起见,我将编写一个 lsay 的函数,可以轻松地得到好看的列表值的输出.这个 sub 是用我们用 Perl 来创建的

  our sub lsay( @a ) { @a.perl.say }

接下来我们看 hyperoperator 的例子.在这个中,我们使用 `>>` 和 `<<` 来替换 `»` 和 `«`, 主要因为这样更加容易看(我怕我会需要眼镜). `»`和`«` 是语言中真实的形式,但较长的 ASCII 字符版本也是可以正常工作的.

首先.来个基本的:
添加两个相同长度的列表

```perl
> (1, 2, 3, 4) <<+>> (3, 1, 3, 1)
4, 3, 6, 5
> (1, 2, 3, 4) >>+<< (3, 1, 3, 1)
4, 3, 6, 5
```

如果数组的长度是相同的,上面这两种形式之间没有区别.但是,如果长度是不同的：

```perl
> (1, 2, 3, 4) <<+>> (3, 1)
4, 3, 6, 5
> (1, 2, 3, 4) >>+<< (3, 1)
```

    Sorry, lists on both sides of non-dwimmy hyperop are not of same length : left: 4 elements, right: 2 elements

  这规则是, 象诸如此类的尖尖是用来表明 hyperoperator 使用时,当一端比另一端短,可以延长短的那一端来进行扩展延伸.

象如果是尖尖指向内部,是指不能进行扩展延伸.当然,还可以有各种组合都是可以的.所以你也能指出只有`左边`能扩展延伸 (`<<+<<`),也可以只指出只有`右边`能(`>>+>>`).当然也能二边都是可以扩展延伸 (`<<+>>`),或者二边都不能扩展延伸 (`>>+<<`).  R 语言中也有向量的循环法则。
单标量扩展延伸如下：

```perl
> (1, 2, 3, 4) >>+>> 2
3, 4, 5, 6
> 3 <<+<< (1, 2, 3, 4)
4, 5, 6, 7
```

因此,这就是基本的使用中缀操作符 hyperoperator 的方法.您还可以使用前缀和后缀运算符：
单边运算时，元素要能漏到操作符的左边(  如`@a>>++`  )或右边（ 如 `~<<`  ）。想象一下漏斗，总是从大的口向小的口漏。
所以操作符前面或后面接什么样的超运算符要取决于操作数是在操作符的前面（用`>>`）或后面(用`<<`)

```perl
> ~<<(1, 2, 3, 4)    # ~(1,2,3,4)
```

超运算符就是在普通运算符的后面，加强普通运算符的功能。如

```perl
> ~<< "1" , "2" , "3" , "4"
> -<<(1, 2, 3, 4)
-1 -2 -3 -4
> my @a = (1, 2, 3, 4);
@a>>++;
@a ;    # 单边运算时，@a与>>之间不能有空格，如不能写成@a >>+
2, 3, 4, 5
```

你也能这样:

```perl
> (0, pi/4, pi/2, pi, 2*pi)>>.sin  # R 中向量化的运算
0, 0.707106781186547, 1, 1.22464679914735e-16, -2.44929359829471e-16
> (-1, 0, 3, 42)>>.Str
"-1" , "0" , "3" , "42"
```

这其实就是只是想说 `>>.` 是调用列表中的每一个成员的一种方法。点 (.)也是一个操作符

其他说明：hyperoperators 并不只是只能和内置操作符一起工作.他们也将能跟你定义以及任何新的运算符工作的很好（即大多数的的都能正常在现在的 Rakudo 上工作）.

只要给放在适当的地方.如`@a >>/=>>2` 整个数组成员都除以 2. 他们将来能和更多的结构一起工作,如多维列表,树与哈希;我们可 S03 Hyper operators .(据我所知,有些功能还尚未在 Rakudo 正常实现)

我并不知道是否有很多代码示例中广泛使用 hyperoperators. 但 LastOfTheCarelessMen’s Vector 是一个非常好的实现.它使用单循环直接的实现了一个 N 维向量类.

[N维向量](https://github.com/LastOfTheCarelessMen/Vector/blob/master/lib/Vector.pm)

## reduce 和 hyper 元操作符

Hyper  亢奋的；精力旺盛的 Hyper[ˈhaɪpə(r)]

今天是第四天,在这个小盒子中,你会见到一些有意思的实现阶乘的函数

```perl
sub fac( Int $n ) {
        [*] 1.. $n
}
```

Okay, 它是怎么工作的？ 今天的 Advent 的盒子就是为了给你提供答案.
Perl 6 有一些不同的"元操作符"是用来修改现有的运算符完成更加强大的功能.
这个方括号中是一个有关“reduce metaoperator”的元操作符的例子,它是中缀运算符,会变成列表操作,操作是在后面各个元素的中间来, 例如,表达式

```perl
 [+] 1, $a , 5, $b
```

  它相当于

```perl
   1 + $a + 5 + $b
```

这为我们提供了非常便利的机制“计算整个列表中的所有元素之和”：

```perl
$sum = [+] @a ; # @a 中所有元素之和
```


更多的中缀运算符(包含用户自己定义的),都能放到这个方括号来减少操作符;


```perl
$prod   = [*] @a ;         # 相乘 @a 中所有的元素
$mean   = ([+] @a ) / @a ; # 计算 @a 的平均值
$sorted = [<=] @a ;        # 如果 @a 元素是数字排序就为 true
$min    = [min] @a , @b ;  # find the smallest element of @a and @b combined
```

在那个阶乘的子函数中,表达示 `[*] 1..$n` 返回全部 `1` 到 `$n` 之间所有乘数的乘积.

另一个非常有用的元操作符是 "hyper" 操作符,放置 `>>`（与`|`或）`<<` 在操作符的二边(一边),使得那个操作 "hyper"（更亢奋）.这个是用来操作列表中所有的成员,来进行这个包起来的运算符的操作.象下面的例子,我们来打算从 @a 和 @b 中成对的取出数据来进行运算后存入 @c.

```perl
@c = @a >>+<< @b ;
```

如果是在 Perl 5 中,我们需要写成象才面这样才能完成.

```perl
for ( $i = 0; $i < @a ; $i ++) {
        $c [ $i ] = $a [ $i ] + $b [ $i ];
}
```

这只是有点长.

正如上面的方括号中,我们可以使用Hyper作用在各种运算符上,包括用户定义操作符：
  注：可以这样记忆 `<<` 和 `>>` 操作符，它们就像是`漏斗`，`<<`  让元素从`右边`漏入，`>>` 让元素从`左边`漏入，然后进行运算。


```perl
# 对 @xyz 中所有的元素进行 ++ 的操作
@xyz >>++
```



```perl
# 从@a 和 @b 中找出最小的元素放到 @x 中
@x = @a   >>min<< @b ;
```


我们还可以`翻转<<的角度`,使标量的行为像一个`数组`：


```perl
# @a 中每个成员都乘 3.5  
my @a=2,4,6;
@b = @a   >>*>> 3.5;  
```

这其实相当于 `@b = @a   >>*<< (3.5,3.5,3.5）` 较短的向量会被自动循环使用！模仿 R 语言的短向量自动循环。
如果右边的向量没有左边的长，箭头就指向那个单个向量。


```perl
# @x 中每个成员都乘以 $m 然后在加 $b
@y = @x   >>*>> $m >>+>> $b ;
```


```perl
# 颠倒 @x 中所有的成员
@inv = 1  <</<< @x ;
```



```perl
# concatenate @last, @first to produce @full
@full = ( @last   >>~>> ', ' )  >>~<< @first ;
```



```perl
> my @string=<I LOVE YOU>
I LOVE YOU
> @string >>~>>'-' >>~>> "szx"
I-szx LOVE-szx YOU-szx
```

`>>~<<` 两侧的元素个数必须相同！
当然,reductions 和 hyper 操作符也能联合表达式


```perl
  # 计算 @x 的平方和
  $sumsq = [+] ( @x   >>**>> 2);
```

还有很多其他元操作符,包括X（cross交叉）,R（reverse反向）,S（顺序sequential）.事实上,这只是在恰当的位置放个运算符,如`+=,*=,?=`,只是元形式的后缀等号运算,它相当于：


```perl
$a += 5;     # same as $a = $a + 5;
$b = 7;      # same as $b = $b 7;
$c min= $d ; # same as $c = $c min $d;  
```


## static types 和 multi subs.

打开Advent 这第三个盒子,这次我们要读到什么啦？啊….真好.这次没想到有二个礼物.这个盒子中放着 `static types` 和 `multi subs`.
在 Perl 5 中,`$scalar` 的标量只能包含二种东西引用或值,这值可以是任何东西,能是整数,字符,数字,日期和你的名字.这通常是非常方便的,但并不明确.
在 Perl6 中给你机会修改标量的类型 .如果你这个值比较特别,你可以直接放个类型名在 `my` 和 `$variable` 的中间.象下面的例子,是在设置値一定要是一个 Int 型的数据,来节约 cpu 判断类型的时间,和让你更少的程序上出错.

```perl
my Int $days = 24;
```

其它的标量类型如下：

```perl
my Str $phrase   = "Hello World" ;
my Num $pi       = 3.141e0;
my Rat $other_pi = 22/7;
```

如果你还是想用老的设置值的方法,你可以不声明类型或使用 Any 的类型代替.

今天盒子中的第二个礼物 `multi subs` 也很容易,因为我们会手把手教你.到底什么是 `multi subs` ? 简单的来讲 `multi subs` 可以让我们 重载 `sub` 的名字 .当然 `Multi subs` 可以做更多其它的事情,所以下次其它作者的礼物中也会有这个,但现在我们会先介绍几个非常有用的一些 sub .


```perl
multi sub identify(Int $x) {
    return "$x is an integer.";
}

multi sub identify(Str $x) {
    return qq<"$x" is a string.>;
}

multi sub identify(Int $x, Str $y) {
    return "You have an integer $x, and a string \"$y\".";
}

multi sub identify(Str $x, Int $y) {
    return "You have a string \"$x\", and an integer $y.";
}

multi sub identify(Int $x, Int $y) {
    return "You have two integers $x and $y.";
}

multi sub identify(Str $x, Str $y) {
    return "You have two strings \"$x\" and \"$y\".";
}

say identify(42);
say identify("This rules!");
say identify(42, "This rules!");
say identify("This rules!", 42);
say identify("This rules!", "I agree!");
say identify(42, 24);
```

还有两个礼物很有优势吧.你可以尝试多使用他们,我们会不断的丰富这个 Advent 的树,并不断放更多的礼物,希望你能多来看看.

## .comb your constraints

我们以前 advent 了解过的内容,对于今天所要介绍的礼物非常有用,今天要讲两个东西： comb 方法和 constraints 的概念。

constraints 和原来那章节中提到的`静态变量`定义的相同,constraints 可以让我们在写程序的时候就更方便的在子函数和方法上进行控制.

在很多其它的程序中,你可以通过参数调用子函数并可以在参数进入的时候就通过 `constraints` 来验证输入的内容.这样我们就能在程序声明的时候就验证输入的内容,不在需要等到程序运行的时候.

下面是一个基本的例子,如果是一个整数和偶数,在子函数中它会不能处理下去.在 Perl 5 中的实际基本就象下面这样子了：

```perl
 sub very_odd
 {
    my $odd = shift;
    unless ($odd % 2)
    {
        return undef;
    }
    # 在这接着处理奇数.
 }
```

在 Perl 6 中,我们可以只需要简单的：

```perl
  sub very_odd(Int $odd where {$odd % 2})
  {
        # 在这接着处理奇数.
  }
```

如果你试图来传入一个偶数来调用 very_odd.你会直接得到一个 error.不要担心：你可以使用 multi sub 的功能来给偶数一个机会:


```perl
  multi sub very_odd(Int $odd where {$odd % 2})
   {
       # Process the odd number here
  }
  multi sub very_odd(Int $odd) { return Bool::False; }
```

我们在使用成对的 `.comb` 方法时,这个 `constraints` 是非常有用.

为什么正好是 `.comb` ? 当我们早上梳整我们的头发时,我们先通常使用梳子来梳成你想要的样子(线条),然后在你的头上固定梳成的样子.前面讲的内容在这非常象.split.在这也一样,你`不是真想`要切开字符串,而是你想达到一个什么样目的.这一段简单的代码,来说明这两种目标：


```perl
  >say "Perl 6 Advent".comb(/<alpha>/).join('|');
  P|e|r|l|A|d|v|e|n|t
  >say "Perl 6 Advent".comb(/<alpha>+/).join('|');
  Perl|Advent
```

正则表达式有可能另一天会拿出来讲,但是我们先快速了解一下是没有坏处的.这个第一行,会输出 `P|e|r|l|A|d|v|e|n|t`. 它会取得每个字母然后放到一个暂时的数组中,然后使用 `join` 管道连接起来这是目的.第二行也有点象,但它捕获了更多的字母,会输出 `Perl|Advent` 这是第二个的目标单词.
这个 `.comb` 是非常非常强大,然而,你得到你梳出来的输出,你就能操作这个串了如果你有一个基本的ASCII十六进制字符的字符串,可以使用的 hyperoperators 超的操作符转变各自的块成为等效的 ASCII 字符！

```perl
say "5065726C36".comb(/<xdigit>**2/)».fmt("0x%s")».chr
```

    # Outputs "Perl6"

```perl
say "5065726C36".comb(/<xdigit>**2/)
```

    50 65 72 6C 36
`**`在正则里是量词，表示重复前面的十六进制数两次，合起来就是每两个字符分一下。

如果你提心这个,你可以使用 `.map` 的方法：

```perl
say "5065726C36".comb(/<xdigit>**2/).map: { chr '0x' ~ $_ } ;
```

    #Outputs "Perl6"
记的,这是 Perl.做任何事情都不只一种方法.
今天给完了所有礼物,我现在向你挑战.有 KyleHasselbacher 的协助,我们能使用约束`.comb` 和 `.map` 做出一个像样的版本的古老的凯撒加密法.

```perl
 use v6;

 sub rotate_one( Str $c where { $c.chars == 1 }, Int $n ) {
    return $c if $c !~~ /<alpha>/;
    my $out = $c.ord + $n;
    $out -= 26 if $out > ($c eq $c.uc ?? 'Z'.ord !! 'z'.ord);
    return $out.chr;
 }

 sub rotate(Str $s where {$s.chars}, Int $n = 3)
 {
    return ($s.comb.map: { rotate_one( $_, $n % 26 ) }).join( '' );
 }

 die "Usage:\n$*PROGRAM_NAME string number_for_rotations" unless @*ARGS == 2;

 my Str $mess   = @*ARGS[0];
 my Int $rotate = @*ARGS[1].Int;

 say qq|"$mess" rotated $rotate characters gives "{rotate($mess,$rotate)}".|;
```

我希望你在休息的时候,可以使用目前为止在 Perl 6 中和今天的礼物中的学到的内容来编写编码算法.毕竟,编程语言本身只有更多的使用,才能让它变的更优秀.

## 一个正则表达式的故事

By perlpilot

在 advent 的第十天,我们有一个故事做为礼物……

曾几何时,在比你想象的更近的时候,一个叫 Tim 的学 Perl 6 程序的学生,工作中出现了一个简单的解析相关的问题.他的老板（我们叫他 C 先生）曾问过他,解析日志文件中包含着库存信息,确保在文件内是唯一有效的行.文件中每行内是这样的：
    <part number> <quantity> <color> <description>

所以这个 Perl 6 的学生,他用熟悉正则表达式写了一个可爱的小正则表达式,可以用来找出有效的行.代码检查每行内容是这样写的：


```perl
next unless $line ~~ / ^^ \d+ \s+ \d+ \s+ \S+ \s+ \N* $$ /
```

使用 `~~` 操作符的原因是因为,右侧的正则表达式会匹配左侧标量.在正则内部,`^^` 是匹配行的开头,`\d+` 是用来匹配一个或者多个数字(由零件编号 part number 和数量 quantity 组成的),`\S+` 是用来匹配一个或者多个非空白字符,
 `\N*` 来匹配零个或者多个非换行符,`\s+` 匹配空白之间的这些东西和 `$$` 用来匹配行结束.
在 Perl 6 中,正则表达式的每个单独的部分可以使用空格来让它更具可读性,所以更加好,这个空格不会是正则的一部分只用来分隔.

但 C 先生决定最好信息的每个部分都可以从提取来验证. Tim 想了一下,“没问题,我只要使用括号来捕获”.下面就是全部需要做的：


```perl
next unless $line ~~ / ^^ (\d+) \s+ (\d+) \s+ (\S+) \s+ (\N*) $$ /
```

在成功的模式匹配以后,每个括号内都存着匹配到的对象本身(`$/`),可以通过 `$/[0]`,`$/[1]`,`$/[2]` 或 `$/[3]`.它可以通过特殊的变量 `$0`,`$1`,`$2`,`$3`访问.Tim 和他老板 C 先生都很高兴.

但随后发现了一些行中,没有从描述信息中给颜色信息分开,这些行其实也是有效的.在行中颜色信息和描述信息有个特殊的组合方式.他们总是象下面这样：

    <part number> <quantity> <description> (<color>)

在这像以前一样,可以加入包括任意数量的空格在字符中. Tim 认为,“现在这个本来简单的解析程序似乎突然更加复杂了”.幸运的是,Tim 可以找一个地方寻求帮助.他迅速登录到 `irc.freenode.org`,加入 `#perl6` 通道 并请求大家协助.有人建议他使用名字来命名他的正则表达式的各个部分,来使事情变得更容易.然后使用交替的方法来匹配这个正则表达式的最后一部分的多种可能.

首先,Tim 尝试给正则能捕获到的每个部分都加上一个名字,详细信息可以见 Perl 6 正则的纲要,下面是他所做的：

```perl
next unless $line ~~
    / ^^ $<product>=(\d+) \s+ $<quantity>=(\d+) \s+ $<color>=(\S+) \s+ $<description>=(\N*) $$ /
```

现在,成功的匹配后,每各部分都可以匹配到对象中不同的东西,通过特殊的变量 `$<Product>`,`$<quantity>`,`$<color>` 和 `$<description>`.
这比预期的更容易,让 Tim 感到非常有信心.接着,他需要补充：交替区分两种不同的有效行：

```perl
next unless $line ~~ / ^^
    $<product>=(\d+) \s+ $<quantity>=(\d+) \s+
    [
    | $<description>=(\N*) \s+ '(' $<color>=(\S+) ')'
    | $<color>=(\S+) \s+ $<description>=(\N*)
    ]
  $$
/
```


为了从正则表达式中的交替和其余部分隔离开,Tim 使用了分组括号（`[ and ]`）在要交替检查的部分.
这个分组是正则的一部分,其中像圆括号是唯一没有捕捉到 `$0` 的, 由于必须匹配到精确的圆括号, Tim 使用了另一个有用的 Perl6 正则表达式的优势：带引号的字符串字面匹配.因为分配给正则表达式的中 `$<color>` 和 `$<description>` 总是会在适当部分包含字符串.

Tim 非常的扬眉吐气！他展示了他的代码给 Mr.C,并表扬到 "干得好 Tim！";

然而,经过成功过后,Tim 开始以更挑剔的眼光来看他的工作.对于一些行中描述之后颜色,它有可能是 `( color)` or `(color )` or`( color )`.他目前正则表达式是正常的,但如果描述中包括的颜色的部分象前面一样时,并不是所有匹配颜色的会设置 `$<color>`. Tim 初步修复,通过加入更多的 `\s*`：


```perl
next unless $line ~~ / ^^
    $<product>=(\d+) \s+ $<quantity>=(\d+) \s+
    [
    | $<description>=(\N*) \s+ '(' \s* $<color>=(\S+) \s* ')'
    | $<color>=(\S+) \s+ $<description>=(\N*)
    ]
  $$
/
```

这运行的非常良好,但正则表达式的开始显得有点凌乱.Tim 再次使用 #perl6 来让人帮助.

这时候有个名叫 PerlJam 告诉他,“你为什么不把你的正则表达式放到 `grammar` 中？这可以让你分配给每片到变量来匹配对象”“ Wha?? Tim 不知道 PerlJam 讲的是什么.通过简短的交流后,Tim 了解后,并知道在哪里查看必须的相关信息后.然后感谢 PerlJam,并在次回到了程序上.这一次的正则表达式几乎消失,因为它使用了 grammar.什么是 grammar ？,看下面匹配的代码：


```perl
grammar Inventory {
    regex product     { \d+ }
    regex quantity    { \d+ }
    regex color       { \S+ }
    regex description { \N* }
    regex TOP { ^^ <product> \s+ <quantity>  \s+
                [
                | <description> \s+ '(' \s* <color> \s*  ')'
                | <color> \s+ <description>
                ]
                $$
    }
}
# ...在来到代码开始的地方
next unless Inventory.parse($line);
```

以前的正则表达式中各自的变量变成了 grammar 中的命名正则表达式.在 Perl 6 的正则表达式中的命名正则是由括在尖括号内的名称来匹配（`< and >`）.当 `Grammar.parse` 调用来匹配一个标量时（会操作这特定的命名正则 `TOP`）行为是完全和以前一样,因为命名的正则表达相当于其它正则表达式的一部分,匹配的文本保存到匹配对象中,并引用该名称.

虽然仍然有改进的余地,Tim 和 Mr.C 对这个结果感到非常高兴.

完
注：默认情况下,允许启用空格注解； 所以,虽然在 Perl 5 中您可以用“hello there”本身来匹配“hello there”,但在 Perl 6 中,您必须将其改为 /hello `<sp>` there/.这样就可以在正则表达中将条件清晰地分离开来.

Perl 6 正则表达式可以被复用.在匹配单一的词时,复用正则表达式是很荒谬的；但在解析配置文件时,几乎必须要复用正则表达式（这取决于配置文法的复杂度、发生修改的频率等）.这样性能也会高很多.

在 Perl 5 中, Regexp::Common 模块,已经在尝试复用正则表达式,但是,因为 Perl 5 不允许复用正则表达式,所以不得不将它们封装在一个模块接口中. Perl 6 完全支持这种复用.
[其它参数资料：](http://www.ibm.com/developerworks/cn/linux/l-cpregex.html)

## 类, 属性, 方法和其它

By jnthnwrthngtn

我非常兴奋地撕下今天的礼物上闪亮的包装纸,里面是无可争议的 Perl 6 的对象模型,它内置了其类声明,角色组成,自豪的元模型(meta-model).除了有先进的功能外,让我们看看在 Perl 6 中是多么容易写一个类.


```perl
class Dog {
    has $.name;
    method bark($times) {
        say "w00f! " x $times;
    }
}
```

我们开始使用一个 class 的关键字.如果你有学过 Perl5 的话,你能想到的类有点像包(package)的变种,这个关键字为您提供一个优雅的语义.

接下来,我们使用 has 的关键字来声明属性访问器方法.这个"."的东西名叫 twigil. Twigil 是用来告诉你指定变量的作用域.它是"属性 + 存取方法"的组合.它的选项是：


```perl
has $!name;       # 私有; 只能在内部可见
has $.name is rw; # Generates an l-value accessor
```

接下来是方法的使用,并介绍使用 method 的关键字.在对象中的方法象包中的子函数,不同之处在于方法是放在类的方法列表的条目中.
它还能自动取得调用者(invocant),所以你如果没有在参数列表中加入参数.它是会给自我传递过去.在 Perl 5 中需要我们显示的写 `$self = shift`.

所有的类都继承一个叫 new 的默认的构造器,会自动的映射命名参数到属性,所有传进的参数会存到属性中.我们可以调用 Dog 的构造器(这个 Dog 的类的对象,并取得一个新的实例).


```perl
my  $fido = Dog.new(name => 'Fido');
say $fido.name;  # Fido
$fido.bark(3);   # w00f! w00f! w00f!
```

请注意,Perl 6 中的方法调用操作符是"."而不是 Perl 5 中使用的"->".它缩短了 50％ 并更加合适从其他语言转过来的开发人员.

当然,很容易实现继承,下面我们建一个叫 puppy 子类 ,直接使用 is 加父类的名字就行了.


```perl
class Puppy is Dog {
    method bark($times) {
        say "yap! " x $times;
    }
}
```

这也支持委托,详细作用见下面的 FQA.


```perl
class DogWalker {
    has $.name;
    has Dog $.dog handles (dog_name => 'name');
}
my $bob = DogWalker.new(name => 'Bob', dog => $fido);
say $bob.name;      # Bob
say $bob.dog_name;  # Fido
```

在这里,我们声明指出我们想调用 DogWalker 类的名为 dog_name 的方法,并设置这个方法转到 Dog 类中包含名为 name 的方法.重命名只是其中的一个可选方式;委托常常有很多其它的实现方法.

内心深层之美比外在更加重要.所以,在整洁的语法之下是使用 meta-model(元模型)想法来实现对象.类,属性和方法都是 Perl 6 中最重要和 Meta-object 的.我们可以在运行时使用这些内省对象.

```perl
for Dog.^methods(:local) -> $meth {
    say "Dog has a method " ~ $meth.name;
}
```

这个 `.^` 的操作是 `.` 操作的变种,用来替换元类(metaclass-描述类的这个对象)的调用.在这里,我们提供该类所定义的方法(Method)的列表,我们使用  `:local` 来排除那些从父类的继承. 这不只是给我们一个名字列表,而是方法对象的列表.其实我们直接使用这个对象来调用方法,但在这种情况下,我们只要它的名字就行.

让你了解 Meta-programming 并附送一个扩展 Perl6 的对象的功能：只要你知道声明一个方位,使用 method 的关键字让它在编译时在调用元类中的  add_method 来变成实际的方法.所以在 Perl 6 中,不仅为您提供了强大的对象模型,但也提供了机会,用来实现其它的特性,以满足未来我们还没有想到的需求.

这些都只是 Perl 6 的对象模型所提供的伟大的事情中的一些,也许我们会发现更多的东西在其他礼品中. :-)

注：
面向对象的概念

首先,我们定义几个预备性的术语.

```perl
构造器 (constructor):   创建一个对象的函数.
实例 (instance)：  一个对象的实例化实现.
标识 (identity)：  每个对象的实例都需要一个可以唯一标识这个实例的标记.
实例属性 (instance attribute)：  一个对象就是一组属性的集合.
实例方法 (instance method)：  所有存取或者更新对象某个实例一条或者多条属性的函数的集合.
类属性(class attribute)：  属于一个类中所有对象的属性,不会只在某个实例上发生变化.
类方法(class method)：  那些无须特定的对性实例就能够工作的从属于类的函数.
委托 (Delegation)： 　在对象需要执行某个工作时并不直接处理，而是要求另一个对外象代为处理(有时只处理部分工作),所以这时第二个对象代表第一个对象来执行该操作。
调用者(invocant):   对类来讲,调用者是包的名字,对实例方法来讲,调用者是指定对象的引用.换句话讲,调用者就是调用方法的那种东西,有的文章叫他为代理(agent)施动者(actor).
抽象类(abstract class):抽象类实现类的占位符，主要用来定义行为，而子类用来实现这个行为。
```

## arguments and parameters

By carl

在第９天的 advent 中…我打开了　…这是有关 parameters 和 arguments
你也许了解或者不了解 Perl5 的 是怎么处理函数参数的.先让你看看,它通常象下面的这个例子这样：

```perl
sub sum {
   [+] @_
}
say sum 100, 20, 3; # 123
```

这个 [+] 是在 Perl 6 中的,但我们也可以写成 Perl 5 风格的

```perl
my $i = 0;
$i _= $_ for @_;
$i;
```

我们要想到上面这些区别,这些在 Perl 6 中非常重要,也就是为什么我们讲 Perl 6 比 Perl 5 好.当你调用函数时.你可以从 @_ 找到你的参数.你然后取出它们来做一些操作.
这是非常灵活的.因为它不会对参数做任何默认的处理,程序会全部传给你来进行处理.当然这也同样是令人厌烦因为样样都要自己处理,但很方便我们来进行扩展进行参数的检查,看下面这个虚构的例子.


```perl
sub grade_essay {
  my ($essay, $grade) = @_;
  die 'The first argument must be of type Essay'
    unless $essay ~~ Essay;
  die 'The second argument must be an integer between 0 and 5'
    unless $grade ~~ Int && $grade ~~ 0..5;

  %grades{$essay} = $grade;
}
```

(如果在 Perl 5 中,你需要使用 isa 来替换　~~　和使用 %grades 来替换成 $grades 才能正常工作.除了这些,都在 Perl6 中工作)

现在,这一刻,看看上面的内容,看到手册中的参数验证的实现,你是不是开始有点绝望吗？你感觉到了吧？好.
在 Perl 5 中的解决方法是使用优秀的 CPAN 模块,象 `Sub::Signatures` 和 `MooseX::Declare`,然后在你的程序中使用这些模块,并按照模块设置就行了.

在 Perl 6 的中的解决方法是,给你参数设置默认范围. 我在想看了下面这些时, “请确保键盘前的你不会流口水”.在 Perl 6 中,我会写这样来写子函数：

```perl
sub grade_essay(Essay $essay, Int $grade where 0..5) {
  %grades{$essay} = $grade;
}
```

现在我们见到,在这程序运行会对这个长版本的参数进行检查,没有必要在导入其它的 CPAN 的模块了.

有时,我们可以提供一些默认的值给参数：

```perl
sub entreat($message = 'Pretty please, with sugar on top!', $times = 1) {
    say $message for ^$times;
}
```

如果这些参数的默认的值是不固定的,可以使用老的方式来传参数.


```perl
sub xml_tag ($tag, $endtag = matching_tag($tag) ) {...}
```

如果您的参数是不确定的,对这种可选的参数可以加一个 ? 的标记.

```perl
sub deactivate(PowerPlant $plant, Str $comment?) {
  $plant.initiate_shutdown_sequence();
  say $comment if $comment;
}
```

有一个特性,我特别喜欢,我们可以在调用时通过参数名字来引用参数,这样你可以以喜欢的任何顺序传递命名参数.这样会永远记得在这个函数中参数本来的顺序：

```perl
sub draw_line($x1, $y1, $x2, $y2) { ... }

draw_line($x1, $y1, $x2, $y2); # phew. got it right this time.
draw_line($x1, $x2, $y1, $y2); # dang! :-/
```

这的方法是引用参数的名字,来使得这个问题被解决：


```perl
draw_line(:x1($x1), :y1($y1), :x2($x2), :y2($y2)); # works
draw_line(:x1($x1), :x2($x2), :y1($y1), :y2($y2)); # also works!
```

冒号的意思是 "这来自命名参数", 整个结构读作:name_of_parameter($variable_passed_in).这可以使用的参数和变量具有相同的名称,但有一个简短形式：

```perl
draw_line(:$x1, :$y1, :$x2, :$y2); # works
draw_line(:$x1, :$x2, :$y1, :$y2); # also works!
```

我喜欢短形式.我觉得它使我的代码更具可读性.

如果作为 API 的作者,要强迫别人使用命名参数 – 例如还是在 draw_line 的情况下 – 你只需要提供在子程序参数前的冒号.


```perl
sub draw_line(:$x1, :$y1, :$x2, :$y2 ) { ... } # optional nameds
```

但要小心注意,命名参数默认是可选的.换句话说,上述内容相当于：


```perl
sub draw_line(:$x1?, :$y1?, :$x2?, :$y2?) { ... } # optional nameds
```

如果你想明确地指出必需的参数,可以追加！对下面的这些参数：


```perl
sub draw_line(:$x1!, :$y1!, :$x2!, :$y2!) { ... } # required nameds
```

现在调用这个,就像他们是普通的顺序位置参数传递进来.

关于可变参数呢？假如你想传递的参数是不确认多少个数量,比如参数是数组,可以在它前面带有“*”：

```perl
sub sum(*@terms) {
  [+] @terms
}
say sum 100, 20, 3;  # 123
```

我使用同样的例子来提出一个观点：当你不提供任何符号到您的子程序时,你最终是得到的符号其实是是 `*@_` .这是模拟 Perl 5 中的行为.

但数组前面的 * 号是仅用来捕获的位置参数(positional arguments).如果你想捕捉命名参数(named arguments),你要使用 “slurpy hash”：

```perl
sub detect_nonfoos(:$foo!, *%nonfoos) {
  say "Besides 'foo', you passed in ", %nonfoos.keys.fmt("'%s'", ', ');
}

detect_nonfoos(:foo(1), :bar(2), :baz(3));
# Besides 'foo', you passed in 'bar', 'baz'
```

哦,这可能是一个很好的通过以命名的参数传递哈希的方法,像这样：


```perl
detect_nonfoos(foo => 1, bar => 2, baz => 3);
# Besides 'foo', you passed in 'bar', 'baz'
```

这里的 Perl 5 中的一个重要区别：默认参数是只读的：


```perl
sub increase_by_one($n) {
  ++$n
}

my $value = 5;
increase_by_one($value); # boom
```

在这让参数只读,主要有两个原因,其一为了效率.当变量只读时可以使其最佳化,其二要鼓励程序员写程序时有个正确的习惯,只会有一点点不习惯.
所以这个功能不仅是为优化好,更是为了让你有个更好的灵魂.

下面是你需要做的工作：


```perl
sub increase_by_one($n is rw) {
   ++$n
}

my $value = 5;
say increase_by_one($value); # 6
```

有时可能你想让你的这个参数可以读写(RW),但是有时你可能更想修改传进来的参数复本.当你想使用这个 copy 时:


```perl
sub format_name($first, $middle is copy, $last) {
    $middle .= substr(0, 1);
    "$first $middle. $last"
}
```

原内容将保持不变.

在 Perl 6 中,当传递一个数组或哈希时,默认情况下它并不会给数组和哈希拉平成几个参数.相反,当你想让参数扁平化时可以使用"|".


```perl
sub list_names($x, $y, $z) {
    "$x, $y and $z"
}

my @ducklings = <huey dewey louie>;
try {
    list_names(@ducklings);
}
say $!; # 'Not enough positional parameters passed;
# got 1 but expected 3'
say list_names(|@ducklings); # 'huey, dewey and louie'
```


同样,如果扁平化一个哈希,其参数内容将作为命名的参数(named arguments)发送到函数.

正如您传送数组和哈希一样,你也可以传送代码块：


```perl
sub traverse_inorder(TreeNode $n, &action) {
    traverse_inorder($n.left, &action) if $n.left;
    action($n);
    traverse_inorder($n.right, &action) if $n.right;
}
```

下面前三个印记符号(@ % & )其实是类型约束：

```perl
@ Array (actually, Positional)
% Hash (actually, Associative)
& Code (actually, Callable)

$ 的印记是工作在不受约束的版本.
```

当心！常出的简单的小陷阱是人们常常落入指定类型约束两次,还都是同一个类型：


```perl
sub f(Array @a) { ... } # WRONG, unless you mean Array of Array
sub f( @a)      { ... } # probably what you meant
sub f(Int @a)   { ... } # Array of Int
```

你学到这,你应得的另一个 Perl6 单行…

```perl
$ perl6 -e '.fmt("%b").trans("01" => " #").say for <734043054508967647390469416144647854399310>.comb(/.**7/)'
```


##  Going to the Rats
As I hinted at back in the in the Day 1 post, Perl 6 has rational numbers. They are created in the most straightforward fashion, by dividing an integer with another integer. But it can be a bit hard to see that there is anything unusual about the result:

```perl
> say (3/7).WHAT
Rat()
> say 3/7
0.428571428571429
```

When you convert a Rat to a Str (for example, to “say” it), it converts to a decimal representation. This is based on the principle of least surprise: people generally expect 1/4 to equal 0.25. But the precision of the Rat is exact, rather than the approximation you’d get from a floating point number like a Num:

```perl
> say (3/7).Num + (2/7).Num + (2/7).Num - 1;
-1.11022302462516e-16
> say 3/7 + 2/7 + 2/7 - 1
0
```

The most straightforward way to see what is going on inside the Rat is to use the .perl method. .perl is a standard Perl 6 method which returns a human-readable string which, when eval’d, recreates the original object as closely as is possible:

```perl
> say (3/7).perl
3/7
You can also pick at the components of the Rat:
> say (3/7).numerator
3
> say (3/7).denominator
7
> say (3/7).nude.perl
[3, 7]
```

All the standard numeric operators and operations work on Rats. The basic arithmetic operators will generate a result which is also a Rat if that is possible; the rest will generate Nums:

```perl
> my $a = 1/60000 + 1/60000; say $a.WHAT; say $a; say $a.perl
Rat()
3.33333333333333e-05
1/30000
> my $a = 1/60000 + 1/60001; say $a.WHAT; say $a; say $a.perl
Num()
3.33330555601851e-05
3.33330555601851e-05
> my $a = cos(1/60000); say $a.WHAT; say $a; say $a.perl
Num()
0.999999999861111
0.999999999861111
```

(Note that the 1/60000 + 1/60000 didn’t work in the last official release of Rakudo, but is fixed in the Rakudo github repository.)
There also is a nifty method on Num which creates a Rat within a given tolerance of the Num (default is 1e-6):

```perl
> say 3.14.Rat.perl
157/50
> say pi.Rat.perl
355/113
> say pi.Rat(1e-10).perl
312689/99532
```

One interesting development which has not made it into the main Rakudo build yet is decimal numbers in the source are now spec’d to be Rats. Luckily this is implemented in the ng branch, so it is possible to demo how it will work once it is in mainstream Rakudo:

```perl
> say 1.75.WHAT
Rat()
> say 1.75.perl
7/4
> say 1.752.perl
219/125
```

One last thing: in Rakudo, the Rat class is entirely implemented in Perl 6. The source code is thus a pretty good example of how to implement a numeric class in Perl 6.

## .pick your game

December 15, 2009
又一个大学学期结束了，或者快要结束了，对于身在美国的大多数来说。这个礼物会有些乐趣，他可以 .pick 东西。
.pick 允许从一个列表中选择随机的元素，先来看看Perl5 的语法：


```perl
my @dice = (1, 2, 3, 4, 5, 6);
my $index = int (rand() * scalar @dice);
print $dice[$index] . "\n";
```

> 5

Perl 6 可以简化这，同时能选择多个元素.


```perl
my @dice = 1..6;
say @dice.pick(2).join(" ");
```


    > 3 4

仅仅使用一套骰子，你就可以和你的朋友们进行角色扮演的会话了。现在让我们看看使用 10 次6面的骰子会有多少攻击：


```perl
my @dice = 1..6;
say @dice.pick(10).join(" ");
```

    > 5 3 1 4 2 6

对那些怀疑者，上面的结果并非拼写错误。 `.pick` 的行为实际上和它的名字是一致的。当你把某个东西选出来，你通常不会把它放回去了。如果你想把它们再放回去，允许同一个项目被再次选中，请在第二个参数中使用副词 :repalce。


```perl
my @dice = 1..6;
say @dice.pick(10, :replace).join(" ");
```

    > 4 1 5 6 4 3 3 5 1 1

Note to game masters: don’t invite me to your D&D games unless you need someone with terrible dice luck. ;)
There is no specific order the list items have to be in for .pick to work its magic. Take the values of monopoly money, for instance:


```perl
my @dice = <1 5 10 20 50 100 500>;
say @dice.pick(10, :replace).join(" ");
```

    > 20 50 100 500 500 10 20 5 50 20

When dice aren’t available, a deck of cards is usually on hand. This version is very basic, but is meant to get ideas going.


```perl
use v6;
class Card
{
  has $.rank;
  has $.suit;

  multi method Str()
  {
    return $.rank ~ $.suit;
  }
}

my @deck;
for <A 2 3 4 5 6 7 8 9 T J Q K> -> $rank
{
  for <♥ ♣ ♦ ♠> -> $suit
  {
    @deck.push(Card.new(:$rank, :$suit));
  }
}
# Shuffle the cards.
@deck .= pick(*);
say @deck.Str;
```

    > Not outputting the results here.

What does the pick(*) do? Call that a sneak peak for another gift. For now, see if you can improve on the card code and make a deck class.
With that, I hope I have proven that Perl 6 is fun. It certainly gets a high mark from me. ✓

##  Whatever

by Moritz

Whatever 在 Perl 6 中是一种类型，在它出现的上下文中，Whatever 代表着它知道的任何东西。
例子：


```perl
1..*                 # infinite range
my @x = <a b c d e>;
say @x[*-2]          # indexing from the back of the array
                     # returns 'd'
say @x.map: * ~ 'A'; # concatenate A to whatever the
                     # thing is we pass to it
say @x.pick(*)       # randomly pick elements of @x
                     # until all are used up

say @array[*-5] 等价于：
say @array[-> $x { $x-5 }]; # $x 是数组元素的个数

my $make-index = -> $x { $x-5 };
say @array[$make-index];
```

所以这是怎么回事？
有些用法看起来很明显： `*` 在 `term` 位置上会产生一个 `Whatever` 对象， 并且有些内置函数(例如 List.pick) 知道怎么处理这个 `Whatever` 对象。
编辑器读取代码后， 知道怎么解析项和操作符：


```perl
say  2 + 4
|    | | |
|    | | + term (literal number)
|    | + operator (binary +)
|    +  term (literal number)
+ term (listop), which expects another term
```

所以，当你写下：
`* * 2`
编译器会把 第一个 `*` 解释为 `项`， 把第二个 `*` 解释为 `操作符`
上面那行代码生成了一个代码块： `* * 2` 等价于 `-> $x { $x * 2 }`， 你可以想任何其它子例程或 `block` 一样调用它：


```perl
my $x = * * 2;
say $x(4);     # says 8
```


同样地：


```perl
say @x.map: * ~ 'A';
```


等价于

```perl
say @x.map: -> $x { $x ~ 'A' };
```

而

```perl
say @x.map: *.succ;
```

等价于

```perl
say @x.map: -> $x { $x.succ };
```

Whatever 在排序时很有用 — 例如， 根据数字大小排序( 前缀 '+' 意味着获取某个东西的数字值)：

```perl
@list.sort: +*
```

等价于：

```perl
my $desc = -> $a, $b { $a <=> $b }
@list.sort: $desc
```

而把列表元素作为字符串排序  (前缀 '~' 意思是获取某个东西的字符串值)：

```perl
@list.sort: ~*
```


##  Junctions
December 13, 2009
Among the many exciting things in Perl 6, junctions are one of my favourites. While I know I don’t really comprehend everything you can do with them, there are a few useful tricks which I think most people will appreciate, and it is those which I’m going to cover as today’s gift.
Junctions are values which have (potentially) more than one value at once. That sounds odd, so let’s get thinking about some code which uses them. First, let’s take an example. Suppose you want to check a variable for a match against a set of numbers:

```perl
if $var == 3 || $var == 5 || $var == 7 { ... }
```

I’ve never liked that kind of testing, seeing as how it requires much repetition. With an any junction we can rewrite this test:

```perl
if $var == any(3, 5, 7) { ... }
```

How does this work? Right near the core of Perl 6 is a concept called junctive autothreading. What this means is that, most of the time, you can pass a junction to anything expecting a single value. The code will run for each member of the junction, and the result will be all those results combined in the same kind of junction which was originally passed.
In the sample above, the infix:<==> operator is run for each element of the junction to compare them with $var. The results of each test are combined into a new any junction, which is then evaluated in Boolean context by the if statement. An any junction in Boolean context is true if any of its values are true, so if $var matches any value in the junction, the test will pass.
This can save a lot of duplicated code, and looks quite elegant. There’s another way to write it, as any junctions can also be constructed using the infix:<|> operator:

```perl
if $var == 3|5|7 { ... }
```

What if you want to invert this kind of test? There’s another kind of junction that’s very helpful, and it’s called none:


```perl
if $var == none(3, 5, 7) { ... }
```

As you may have guessed, a none junction in Boolean context is true only if none of its elements are true.
Junctive autothreading also applies in other circumstances, such as:

```perl
my $j = any(1, 2, 3);
my $k = $j + 2;
```

What will this do? By analogy to the first example, you can probably guess that $k will end up being any(3, 4, 5).
There is an important point to note in these examples. We’re talking about junctive autothreading, which should give you a hint. By the Perl 6 spec, the compiler is free to run these multiple operations on junctions in different threads so that they can execute in parallel. Much as with hyperoperators, you need to be aware that this could happen and avoid anything which would make a mess if run simultaneously.
The last thing I want to talk about is how junctions work with smartmatching. This is really just another instance of autothreading, but there are some other junction types which become particularly useful with smartmatching.
Say you have a text string, and you want to see if it matches all of a set of regexes:

```perl
$string ~~ /<first>/ & /<second>/ & /<third>/
```

Assuming, of course, you have defined regexes called first, secondand third. Rather like |, & is an infix operator which creates junctions, this time all junctions which are only true if all their members are true.
The great thing about junctions is that they have this behaviour without the routine you’re passing them to having to know about it, so you can pass junctions to almost any library or core function and expect this kind of behaviour (it is possible for a routine to deliberately notice junctions and treat them how it prefers rather than using the normal autothreading mechanism). So if you have a routine which takes a value to smartmatch something against, you can pass it a junction and get that flexibility in the smartmatch for free. We use this in the Perl 6 test suite, with functions like Test::Util::is_run, which runs some code in another interpreter and smartmatches against its output.
To finish off, here are some other useful things you can do with junctions. First, checking if $value is present in @list:

```perl
any(@list) == $value
```

Junction constructors can work quite happily with the elements of arrays, so this opens up many possibilities. Others include:

```perl
all(@list) > 0; # All members greater than zero?
all(@a) == any(@b); # All elements of @a present in @b?
```

Go experiment, and have fun!

##   Modules and Exporting
December 12, 2009
Today I’d like to talk about a fairly fundamental subject: libraries.
To write a library in Perl 6, we use the “module” keyword:

```perl
module Fancy::Utilities {
    sub lolgreet($who) {
        say "O HAI " ~ uc $who;
    }
}
```

Put that in Fancy/Utilities.pm somewhere in $PERL6LIB and we can use it like the following:

```perl
use Fancy::Utilities;
Fancy::Utilities::lolgreet('Tene');
```

That’s hardly ideal.  Just like in Perl 5, we can indicate that some symbols from the module should be made available in the lexical scope of the code loading the module.  We’ve got a rather different syntax for it, though:

```perl
# Utilities.pm
module Fancy::Utilities {
  sub lolgreet($who) is export {
    say "O HAI " ~ uc $who;
  }
}
```



```perl
# foo.pl
use Fancy::Utilities;
lolgreet('Jnthn');
If you don’t specify further, symbols marked “is export” are exported by default.  We can also choose to label symbols as being exported as part of a different named group:
module Fancy::Utilities {
sub lolgreet($who) is export(:lolcat, :greet) {
  say "O HAI " ~ uc $who;
}
sub nicegreet($who) is export(:greet, :DEFAULT) {
  say "Good morning, $who!"; # Always morning?
}
sub shortgreet is export(:greet) {
  say "Hi!";
}
sub lolrequest($item) is export(:lolcat) {
  say "I CAN HAZ A {uc $item}?";
}
}
```

Those tags can be referenced in the code loading this module to choose which symbols to import:


```perl
use Fancy::Utilities; # Just get the DEFAULTs
use Fancy::Utilities :greet, :lolcat;
use Fancy::Utilities :ALL; # Everything marked is export
Multi subs are export by default, so you only need to label them if you want to change that.
multi sub greet(Str $who) { say "Good morning, $who!" }
multi sub greet() { say "Hi!" }
multi sub greet(Lolcat $who) { say "O HAI " ~ $who.name }
Classes are just a specialization of modules, so you can export things from them as well.  In addition, you can export a method to make it available as a multi sub.  For example, the setting exports the “close” method from the IO class so you can call “close($fh);”
class IO {
    ...
    method close() is export {
        ...
    }
    ...
}
```

Perl 6 does support importing symbols by name from a library, but Rakudo does not yet implement it.



##  Roles

by jnthnwrthngtn
As the snow falls outside, we grab a glass of mulled wine – or maybe a cup of eggnog – to enjoy as we explore today’s exciting gift – roles!
Traditionally in object oriented programming, classes have taken on two tasks: instance management and re-use. Unfortunately, this can end up pulling classes in two directions: re-use wants them to be small and minimal, but if they’re representing a complex entity then they need to support all of the bits it needs. In Perl 6, classes retain the task of instance management. Re-use falls to roles.
So what does a role look like? Imagine that we are building up a bunch of classes that represent different types of product. Some of them will have various bits of data and functionality in common. For example, we may have a BatteryPower role.

```perl
role BatteryPower {
    has $.battery-type;
    has $.batteries-included;
    method find-power-accessories() {
        return ProductSearch::find($.battery-type);
    }
}
```

At first glance, this looks a lot like a class: it has attributes and methods. However, we can not use a role on its own. Instead, we must compose it into a class, using the does keyword.

```perl
class ElectricCar does BatteryPower {
    has $.manufacturer;
    has $.model;
}
```

Composition takes the attributes and methods – including generated accessors – from the role and copies them into the class. From that point on, it is as if the attributes and methods had been declared in the class itself. Unlike with inheritance, where the parents are looked at during method dispatch, with roles there is no runtime link beyond the class knowing to say “yes” if asked if it does a particular role.
Where things get really interesting is when we start to compose multiple roles into the class. Suppose that we have another role, SocketPower.

```perl
role SocketPower {
    has $.adapter-type;
    has $.min-voltage;
    has $.max-voltage;
    method find-power-accessories() {
        return ProductSearch::find($.adapter-type);
    }
}
```

Our laptop computer can be plugged in to the socket or battery powered, so we decide to compose in both roles.
class Laptop does BatteryPower does SocketPower {
}
We try to run this and…BOOM! Compile time fail! Unlike with inheritance and mix-ins, role composition puts all of the roles on a level playing field. If both provide a method of the same name – in this case, find-power-accessories – then the conflict will be detected as the class is being formed and you will be asked to resolve it. This can be done by supplying a method in our class that says what should be done.

```perl
class Laptop does BatteryPower does SocketPower {
    method find-power-accessories() {
        my $ss = $.adapter-type ~ ' OR ' ~ $.battery-type;
        return ProductSearch::find($ss);
    }
}
```

This is perhaps the most typical use of roles, but not the only one. Roles can also be taken and mixed in to an object (on a per-object basis, not a per-class basis) using the does and but operators, and if filled only with stub methods will act like interfaces in Java and C#. I won’t talk any more about those in this post, though: instead, I want to show you how roles are also Perl 6’s way of achieving generic programming, or parametric polymorphism.
Roles can also take parameters, which may be types or just values. For example, we may have a role that we apply to products that need to having a delivery cost calculated. However, we want to be able to provide alternative shipping calculation models, so we take a class that can handle the delivery calculation as a parameter to the role.

```perl
role DeliveryCalculation[::Calculator] {
    has $.mass;
    has $.dimensions;
    method calculate($destination) {
        my $calc = Calculator.new(
            :$!mass,
            :$!dimensions
        );
        return $calc.delivery-to($destination);
    }
}
```

Here, the ::Calculator in the square brackets after the role name indicates that we want to capture a type object and associate it with the name Calculator within the body of the role. We can then use that type object to call .new on it. Supposing we had written classes that did shipping calculations, such as ByDimension and ByMass, we could then write:

```perl
class Furniture does DeliveryCalculation[ByDimension] {
}
class HeavyWater does DeliveryCalculation[ByMass] {
}
```

In fact, when you declare a role with parameters, what goes in the square brackets is just a signature, and when you use a role what goes in the square brackets is just an argument list. Therefore you have the full power of Perl 6 signatures at your disposal. On top of that, roles are “multi” by default, so you can declare multiple roles with the same short name, but taking different types or numbers of parameters.
As well as being able to parametrize roles using the square bracket syntax, it is also possible to use the of keyword if each role takes just one parameter. Therefore, with these declarations:

```perl
role Cup[::Contents] { }
role Glass[::Contents] { }
class EggNog { }
class MulledWine { }
```

We may now write the following:


```perl
my Cup of EggNog $mug = get_eggnog();
my Glass of MulledWine $glass = get_wine();
```

You can even stack these up.

```perl
role Tray[::ItemType] { }
my Tray of Glass of MulledWine $valuable;
```

The last of these is just a more readable way of saying Tray[Glass[MulledWine]]. Cheers!
About these ads
Like this:

Like Loading...

# 2010

## 第二天:用main函数控制命令行交互



2010 年 Perl6 圣诞月历(二)用 main 函数控制命令行交互

在 UNIX 环境下，很多脚本都是要从命令行里获取运行参数的。Perl6 上，实现这个相当简单~比如下面这样：

```perl
    $ cat add.pl
    sub MAIN ($x, $y) {
        say $x + $y
    }
    $ perl6 add.pl 3 4
    7
    $ perl6 add.pl too many arguments
    Usage:
    add.pl x y
```

只要定义一个带命名变量的 MAIN 函数，你就可以获得一个命令行分析器。然后命令行参数就被自动绑定到 `$x` 和 `$y` 上了。如果不匹配，还有温馨的 Usage 提示~~

当然，你可能更喜欢自己定制 Usage 信息。那么自己动手，编写 USAGE 函数好了：

```perl
    $ cat add2.pl
    sub MAIN($x, $y) {
        say $x + $y
    }
    sub USAGE () {
        say "Usage: add.pl <num1> <num2>";
    }
    $ perl6 add2.pl too many arguments
    Usage: add.pl <num1> <num2>
```

更进一步的，你可以用 `multi` 指令声明多种 MAIN 函数以完成一种可替代的语法，或者根据某些**常量**做出不同反应，比如：

```perl
    $ cat calc
    #!/usr/bin/env perl6

    multi MAIN('add', $x, $y)  { say $x + $y }
    multi MAIN('div', $x, $y)  { say $x / $y }
    multi MAIN('mult', $x, $y) { say $x * $y }
    $ ./calc add 3 5
    8
    $ ./calc mult 3 5
    15
    $ ./calc
    Usage:
    ./calc add x y
    or
    ./calc div x y
    or
    ./calc mult x y
```

还有命名参数对应不同的选项的情况：

```perl
    $ cat copy.pl
    sub MAIN($source, $target, Bool :$verbose) {
        say "Copying '$source' to '$target'" if $verbose;
        run "cp $source $target";
    }
    $ perl6 copy.pl calc calc2
    $ perl6 copy.pl  --verbose calc calc2
    Copying 'calc' to 'calc2'
```

这里申明变量 `$verbose` 类型为 Bool，也就是不接受赋值。如果没有这个类型约束的话，它是需要赋值的，就像下面这样：

```perl
    $ cat do-nothing.pl
    sub MAIN(:$how = 'fast') {
        say "Do nothing, but do it $how";
    }
    $ perl6 do-nothing.pl
    Do nothing, but do it fast

    $ perl6 do-nothing.pl --how=well
    Do nothing, but do it well

    $ perl6 do-nothing.pl what?
    Usage:
    do-nothing.pl [--how=value-of-how]
```

总之，Perl6 提供了内置的命令行解析功能和使用帮助说明，你只要声明好函数就行了。

## 文件操作

目录
不再用 `opendir` 和其他神马滴，Perl6 中有专门的 `dir` 函数，用来列出指定目录（默认是当前所在目录）下所有的文件。好了，直接贴代码：

```perl
    dir
    dir 't' # t 目录下的文件
```

dir 还有一个可选的命名参数 `test`，用来 `grep` 结果，这样：

```perl
   dir 'src/core', test => any(/^C/, /^P/)
```

创建目录，还是 mkdir 函数没错啦~

文件

最简单的读取文件的办法，是直接使用 `slurp` 函数，这个函数以标量形式返回文件的内容，这样：

```perl
slurp 'VERSION'
```

当然原始的文件句柄方式还是有效的，这样：

```perl
    my $fh = open 'CREDITS'
    $fh.getc #读取一个字符
    $fh.get  #读取一行（译者注：这两看起来好有 C 语言的赶脚啊）
    $fh.close;

    $fh = open 'new', :w  # 以可写方式打开
    $fh.print('foo')
    $fh.say('bar')
    $fh.close;
    say slurp('new')
```

文件测试
如果要测试文件是否存在以及文件的具体类型，直接使用`~~`操作符就搞定了，还是用代码说话：

```perl
  'LICENSE'.IO ~~ :e     # 文件(广义的)是否存在
  'LICENSE'.IO ~~ :d     # 那么他是目录么？
  'LICENSE'.IO ~~ :f     # 那么是文件么(狭义的)？

```


File::Find

如果这些个标准特性还不够，那模块就派上用场了。File::Tools 包里的 File::Find 模块可以递归你指定的目录找你要的东西然后列出来。这个模块应该是跟着 Rakudo Star 一起打包了，如果你只裸装了 Rakudo，那么用 neutro 命令安装也是挺方便的~~
额，还是要例子？好吧~很简单的一行 `find(:dir, :type, :name(/foo/))`，这就会在 `t/dir1` 目录下，寻找名字匹配 foo 的文件，然后以树的形式列出来~不过要注意的是：这命令的返回可不是文本标量，而是一个个包括他们的完整路径在内的对象，而且还提供文件本身以及文件所在目录的访问器！更多信息，直接看文档吧。
有用的示例
1、创建新文件

```perl
open('new', :w).close
```

2、匿名文件句柄

```perl
    given open('foo', :w) {
        .say('Hello, world!');
        .close
    }
```


## 第四天 – 序列操作符

By Colomon
去年，有一个序列操作符的简要梳理

```perl
my @even-numbers  := 0, 2 ... *;    # 算术序列
my @odd-numbers   := 1, 3 ... *;
my @powers-of-two := 1, 2, 4 ... *; # 几何序列
```

这些现在在Rakudo里面实现了：

```perl
> my @powers-of-two := 1, 2, 4 ... *; 1;
1
> @powers-of-two[^10]
1 2 4 8 16 32 64 128 256 512
```

(注意：这篇文章中所有的代码例子都已经在Rakudo的 REPL 下面运行过了。因为变量 @powers-of-two 是一个无限惰性列表，我已经在行尾添加了 `1;` 以至于 REPL 打印出 1 而不是进入到一个无限循环里面。2015.5月份的 REPL 已经不需要加 `1;` 了。

我们需要削减这个无限列表让Rakudo不会花费无限长的时间来计算它。这种情况下，我使用 [^10] ,这其实是说 "给我前 10 个元素"。（注意，当你把一个惰性列表绑定到一个数组变量上时，被计算过的值是会被记忆的，这是一种快捷的缓存。

序列操作符  ... 是一个生成惰性列表的强大工具。上面的例子仅仅暗示了它能做什么。给定一个数字，它就从这个数字开始往下计数（除非序列的终点是一个更小的数字，这种情况下，它会倒数）

```perl
> 1 ... 10
1 2 3 4 5 6 7 8 9 10
> 5 ... 1
5 4 3 2 1
```

 给定两个数字来开始一个序列，它会把这当作一个算术序列，把前两个元素的差异添加到最后一个生成的元素上来产生下一个元素。如果给定三个元素，它会检查它们是否代表一个算术序列的开始或者它是否是一个几何序列，然后继续这个序列。
当然，很多有趣的序列既非算术序列也非几何序列，这时，你需要显式地提供一个 sub 来生成序列中的下一个数：

```perl
> my @Fibonacci := 0, 1, -> $a, $b { $a + $b } ... *; 1;
1
> @Fibonacci[^10]
0 1 1 2 3 5 8 13 21 34
```

  上面的 `-> $a, $b { $a + $b }` 是一个 pointy block (或者是一个匿名函数)，它带有 2个参数并返回它们的和。这个序列操作符计算出该block 有多少个参数，然后从当前序列的末尾传递所需的参数来生成序列的下一个数字，以此类推，循环下去。
或者也可以中断循环，目前为止，所有的例子都有一个 星号 * 放在右边，它意味着“没有终止条件”。如果你反而在那里放上一个数字，这个列表就会终止在那个数字。


```perl
> 1, 1.1 ... 2
1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2
> 1, 1.1 ... 2.01
... Rakudo spins its wheels, because this is an infinite list ...
> (1, 1.1 ... 2.01)[^14]
1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3
```

第一个列表很自然地终止了，但是第二个列表漏掉了终止数，它会循环下去。结果就是一个无限列表，所以我把它限制到前 14 个元素，以至于我们能明白它正在做什么。
那些有做浮点数学背景的人可能会气急败坏地说反复增加0.1直到精确到2 为止很危险。

在Perl6中，没有这个问题，因为它会在可能的地方使用有理数（例如.分数)。如果我想找出所有 10000以下的斐波纳契数，要找到到何处停止的那个精确的数字是很大的问题。幸运的是，就像你能使用块来指定怎样生成序列中的下一个元素一样，你可以使用块来测试序列是否结束：

```perl
> 0, 1, -> $a, $b { $a + $b } ... -> $a { $a > 10000 };
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765 10946
```


尖头块 `-> $a { $a > 10000 }` 创建了一个含有一个参数的块，并且当参数大于 10000 时返回真；这就是我们需要的测试。

除了我们所期待的所有斐波那契数小于10000。 我们生成的裴波纳契数有一个大于10000的，当传递一个块作为终止测试时，该序列操作符所有的元素直到那个块返回真为止，然后它返回最后一个元素，然后停止。但是有一种替代形式的操作符能做同样的事情：

```perl
> 0, 1, -> $a, $b { $a + $b } ...^ -> $a { $a > 10000 };
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765
```

从 `...` 转换为 `...^` 意味着结果列表不包含让终止测试返回真时的第一个元素。
有两点旁注. 在Perl6中这真是一种冗长的指定序列的方法。在这里我没有空间解释所谓的闭包，但是去年的文章已经说过它们。使用闭包，你可以将上一个序列写为：

```perl
> 0, 1, * + * ...^ * > 10000;
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765
```

这样写是否清晰完全取决于你，条条大路通罗马。
并且，序列操作符的左侧可以是任何列表，甚至是惰性的。这意味着你可以很容易的使用一个终止块来得到已存在的惰性列表的有限的一部分：

```perl
> my @Fibonacci := 0, 1, * + * ... *; 1;
1
> @Fibonacci ...^ * > 10000
0 1 1 2 3 5 8 13 21 34 55 89 144 233 377 610 987 1597 2584 4181 6765
> @Fibonacci[30]
832040
```

(我坚持最后的检查只是为了说明@Fibonacci 在超过10000之后依然会继续。
这才触及到序列能做什么的皮毛，更多的信息，查看 细则中的 “List infix precedence”，然后下拉到序列操作符（尽管如此，注意这还没有全部实现！它是一个极其复杂的操作符。）

我还要告诉你的是，序列操作符不局限于工作于数字，如果你显式地指定了你自己的生成器，你可以生成任何类型的序列。但是我喜欢将这保留到未来的圣诞节礼物。

## 第五天 – 为什么Perl语法是你想要的

圣临月第五天，您或许有些失望没能看到 Perl6 酷呆了的新玩法~这次会是直观的解释一些编程语言的运行原理。
作为样例，先说下面这两行吧：

```perl
say 6 / 3;
say 'Price: 15 Euro' ~~ /\d+/;
```

嗯，两行代码的运行结果分别是 2 和 15。相信这对 perl 程序员来说没什么可奇怪的。但你再细看看，两行都有斜杠`/`，却为了完全不一样的目的，第一个是数值运算，第二 个是正则匹配。

Perl 怎么知道一个 `/` 号意味着什么？这当然不是简单的看 `/` 号后面的文本来决定，因为正则表达式可以看起来跟普通代码一样。
答案是：Perl 会持续跟踪他的预期。Perl 预期中最重要的两样东西就是：词和操作符。

一个词可以是像 23 或者 str 这样的文字。当解释器发现这样一个文字，然后后面就会是一个语句的结束（即分号;），或者一个操作符像 `+/*` 等等。过了这个操作符，解 释器又开始预期下一个词。
其实这就是问题的答案了：当解释器预期为词的时候，斜线 / 就代表正则表达式的开始；当预期为操作符的时候，斜线 / 就代表数字的除法运算。

这种做法造成了深远的后果。子函数运行可以不加括号，而在函数名后面，perl 预期一个词开端的参数列表。另一方面，类型名必须跟在操作符后面，所以，所有的类型名必 须在解析时就是已知的。
这样，很多字符都可以重复使用在不同的语法环境下了。

## 第六天 – X和 Z 元操作符

                                 -- By Matthew Walton


Perl 6中一个新的创意就是元操作符，这种元操作符和普通的操作符结合改变了普通操作符的行为。这种元操作符有很多，但这里我们只关注它们中的两个: `X` 和 `Z`
X 操作符你可能已经见过它作为中缀交叉操作符的普通角色。它将列表联合在一起，每个列表中各取一个元素：

```perl
    > say ((1, 2) X ('a', 'b')).perl
    ((1, "a"), (1, "b"), (2, "a"), (2, "b"))
```

然而,这个中缀操作符infix:<X> 其实是 将 X 操作符应用到 列表连接操作符    infix:<,>上的简便形式。事实上，你可以这样写：  

    > say ((1, 2) X, (10, 11)).perl
    ((1, 10), (1, 11), (2, 10), (2, 11))
如果你喜欢.所以你将 X 应用到不同的中缀操作符上面会发生什么？   应用到  infix:<+> 上呢？

    > say ((1, 2) X+ (10, 11)).perl
    (11, 12, 12, 13).list
 它做了什么？它不是从每个组合中挑出所有的元素列表，这个操作符将中缀操作符 + 应用到元素间，并且结果不是一个列表，而是一个数字，是那个组合中所有元素的和。
这对任何中缀操作符都有效。看看 字符串连接 `infix:< ~ >`：

    > say ((1, 2) X~ (10, 11)).perl
    ("110", "111", "210", "211")
或者也许数值相等操作符infix:< == >

    > say ((1, 2) X== (1, 1)).perl
    (Bool::True, Bool::True, Bool::False, Bool::False)

但是这篇文章也是关于 Z 元操作符的。我们期望你已经知道他是什么了。如果你遇见过 中缀操作符 Z，它当然是 Z, 的便捷形式。


    > say ((1, 2) Z, (3, 4)).perl
    ((1, 3), (2, 4))
    > say ((1, 2) Z+ (3, 4)).perl
    (4, 6).list
    > say ((1, 2) Z== (1, 1)).perl
    (Bool::True, Bool::False)

Z,然后,依次操作每个列表的每个元素，同时操作每个列表中的第一个元素，然后同时操作第二对儿，然后第三对儿，不管有多少。当到达列表的结尾时停止。

Z也是惰性的,所以你可以将它用在两个无限列表上，它会尽可能多地生成你需要的结果。X 只能处理左边是无限列表的列表，否则它不会设法得到任何东西。

在写这篇文章的时候，Rakudo 正好出现了一个 bug，就是 `infix:<Z>` 和 `infix:<Z,>`不是完全一样的:后者产生一个展开的列表. S03 表明后者的行为是正确的。

These metaoperators, then, become powerful tools for performing operations encompassing the individual elements of multiple lists, whether those elements are associated in some way based on their indexes as with Z, or whether you just want to examine all possible combinations with X.


有一个键和值得列表，你想得到一个散列？ 容易！

    my %hash = @keys Z=> @values;

或者，也许你想并行遍历两个列表？

    for @a Z @b -> $a, $b { ... }

或者三个?

    for @a Z @b Z @c -> $a, $b, $c { ... }

或者你能从扔3次有10个面的骰子的所有数字组合中，得到所有可能的总数：

    my @d10 = 1 ... 10;
    my @scores = (@d10 X+ @d10) X+ @d10;

如果你想看到一些在真实世界这些原操作符的用途，看看 Moritz Lenz’s 写的  Sudoku.pm 数独解算器。

##  第七天 词法变量

编程总是件很难持续做下去的事情。串几行代码很容易，根据想法做一个原型也是轻松愉快的。但随着程序慢慢变大，维护时间慢慢变长，事情慢慢就棘手起来了……最后，如果不幸的话，我们就得被迫重构——不是因为早先的问题复杂，而是因为程序本身复杂了……在不断的调试中急白了头的程序员们，早就不记得到底要怎么扩展程序以完成目的了……
所以我们回溯一下编程史，找找对着复杂性的办法。而答案就在那里，不来不去——`限制长度`。当你架构一个成百上千模块组成的大型程序的时候，你必须能够让这些组件通过表面上很小的设置进行交互——否则你就等着被乱七八糟的组合干死吧。

在各层次的编程上，我们都可以看到这么一个原则。因为他就只关心这一件事情：分散注意，专一的做一件事情！BCNF 范式、monads (译者注：不知道这东东咋翻译)、单子，例程，类，角色，模块，包等。这些都是在督促和指导我们限制编程的长度。这样我们才不会输在组
合学上。而这方面最简单的例子，就是词法变量。


```perl
{
    my $var;
    # $var可见
}
# $var不可见
```

哈哈，这就是今天要介绍的一个非常酷的功能了！非常有趣的说~
Perl从第一版开始，在这方面一直不太对。比如Perl5的默认变量作用域是包。而这就是全局变量的一种。我在某个代码块里定义了一个变量，其他地方居然也能看到……


```perl
$ perl -v
This is perl 5, version 12, subversion 1 (v5.12.1)
$ perl -E '{ $var = 42 }; say $var'
42
$ perl -wE '{ my $var= 42 }; say $var'
Name "main::var" used only once: possible typo at -e line 1.
Use of uninitialized value $var in say at -e line 1.
```

在Perl6里，词法变量变成了默认设置。在 Rakudo 上运行上面的代码，根本无法通过编译：

```perl
$ perl6 -e '{ $var = 42 }; say $var'
===SORRY!===
Symbol '$var' not predeclared in <anonymous>
$ perl6 -e '{ my $var = 42 }; say $var'
===SORRY!===
Symbol '$var' not predeclared in <anonymous>
```

好了，你可能说：“嗯，可以减少点打错字的可能了”。这当然没错，但是更重要的是：这让你认真坦诚的对待`变量作用域`。这对你控制代码复杂性很有利！

我们可以说出很多很多解释来说明为啥 Perl5 这么做。比如 Perl5 已经建议大家 `use warnings;` `use strict;` ，比如 Perl5 承诺的向后兼容，嗯，很伟大的做法，而 Perl1 压根没打算用来写大型程序和管理带来的复杂性；比如全局变量在单行模式下的各种方便……
Perl6 内置的强制你从小处着手，帮你在系统扩容的时候，更苛责的关注架构基础。在变量方面，也就是在脚本和模块中，将词法变量作为默认设置。不过在 perl -e 执行的单行命令中，默认依然是全局变量。（ Rakudo 还没有实现这个，目前单行依然是词法变量，期待实现的那天~）
继续。好像到这里你感觉词法变量的价值已经说完了？没有！正确设计的结果可是令人惊讶和奖金源源不断啊~考虑一下这个子程序：


```perl
sub counter($start_value) {
    my $count = $start_value;
    return { $count++ };
}
```

这里返回的是一个代码块。所以每次我们调用 `counter()` 的时候，得到的都是一小片断开的代码。然后看看当我创建两片这样的代码后的结果：

```perl
my $c1 = counter(5);
say $c1();           # 5
say $c1();           # 6
&nbsp_place_holder;
my $c2 = counter(42);
say $c2();           # 42
say $c1();           # 7
say $c2();           # 43
```

看到了吧， `$c1` 和 `$c2` 是完全分开的，他们相互独立互不影响。尽管他们都写成 $count 的样子，看起来真是差不多，但他们都有自己独立的存储单元——因为每次我们运行进入那个代码块的时候，就是一次重新开始。这个小代码块从运行中的计数器里返回，这些计数器里保留了存储单元的对应关系。（他“关闭”这个存储单元，保护它不被 GC 回收掉。这类代码块叫闭包）
这个闭包看起来像是个轻量级的对象？gxgx，他们确实就是。闭包背后的原则，即规范对闭包值的访问方式，与面向对象背后的封装和信息的原则是一样的。他们都是尽力限制事情的程度，在事情变得糟糕的时候，帮忙减少其影响和损失。
你可以用词法变量做些很有趣的事情，比如闭包；而包变量不行。词法变量最酷啦！吼吼~~

## 第八天  不同东西用不同名字

Perl5 的新手们，总会很奇怪的说为啥自己没法倒装呢？Perl 里有内置的 reverse 命令，但好像压根不起作用啊：

```perl
$ perl -E "say reverse 'hello'"
    hello
```

当他们去问一些有经验的 perler 的时候，解决办法很快就有了。因为 reverse 有两种操作模式，分别工作在标量和列表环境下，用来倒装字符串和列表元素：

```perl
$ perl -E "say scalar reverse 'hello'"
    olleh
```

比较悲剧的是这个情况和大多数的 perl 语境是不一致的。比方说，绝大多数的操作符和函数由自己决定语境，并在这个语境下分析数据。好比 + 和 * 作用于数字，. 作用于字符串。所以说他们代表一个操作并且提供语境，而 reverse 却不是。
在 Perl6 里，我们从过去的错误里吸取教训以摆脱历史的窘境。所以我们把列表倒叙，字符串翻转，哈希反演分开成了三个操作：

```perl
    # 字符串翻转，改名叫flip
    $ perl6 -e 'say flip "hello"'
    olleh
    # 列表倒叙
    $ perl6 -e 'say join ", ", reverse <ab cd ef>'
    ef, cd, ab
    # 哈希反转，叫invert

    my %capitals = France => "Paris", UK => "London";
    say %capitals.invert.perl;
    ("Paris" => "France", "London" => "UK")
```

注意哈希的反演和其他两个不同。因为哈希的值不要求是唯一的，所以反演后，哈希结构可能会被改变，或者某些值被覆盖……
如果必要的话，使用者可以自己决定返回哈希结构时的操作方式。比如下面就是一种无损的方式：

```perl
my %inverse;
   %inverse.push( %original.invert );
```

这个方法会在键值对存在的情况下，把新值push在原有值的队尾变成一个数组：

```perl
    my %h;
    %h.push('foo' => 1);    # foo => 1
    %h.push('foo' => 2);    # foo => [1, 2]
    %h.push('foo' => 3);    # foo => [1, 2, 3]
```

这三个函数，都会强制转换他们的参数。也就是说，如果你传递一个列表给 flip，这个列表会被强制成字符串后再翻转返回。

## 第十天 – Feed operators

By Perlpilot
 使用Perl 5 编程一段时间的人可能遇到或写过下面这样相似的代码：

```perl
my @new = sort { ... } map { ... } grep { ... } @original;
```

在这个构造中，数据从 @original 数组流进 grep，然后按顺序，流进 map ，然后流进 sort，最后将结果赋值给 @new 数组。因为它们每个都将列表作为它们最终的参数，仅仅通过位置，数据从一个操作符向左流进下一个操作符。

Perl 6, 从另一方面，通过引入流向操作符让数据从一个操作符流进另一个操作符，让这种思想更明确。上面的Perl 5 代码能使用 Perl 6 重写：

```perl
my @new <== sort { ... } <== map { ... } <== grep { ... } <== @original;
```

注意条条大路通罗马，这个在Perl 6 中更能体现。你也可以跟Perl 5 的写法相同：

```perl
my @new = sort { ... }, map { ... }, grep { ... }, @original;
```

唯一不同的是额外的`逗号`。
所以，我们从这些流向操作符得到了什么？通常，当我们阅读代码的时候，你是从左向右读的，在原来的 Perl 5 代码中，你可能从左到右阅读你的代码直到你发现正在处理的结构，其流向是从右向左的，然后你跳到末尾，按照从右往左的方式再读一遍。 在Perl 6 中，现在有一个突出的句法标记，告诉你数据向左流动的性质。

这样写也可以：

```perl
@original ==> grep { ... } ==> map { ... } ==> sort { ... }  ==> my @new;
```

下面是一些使用流向操作符的例子：

```perl
my @random-nums = (1..100).pick(*);  # 100个随机数
my @odds-squared <== sort <== map { $_ ** 2 } <== grep { $_ % 2 } <== @random-nums;
say ~@odds-squared;

> my @a= (1..100).pick(*);

> @a ==> grep {$_ % 2} ==> map { $_ ** 2} ==> sort {$^a <=> $^b} ==> my @c;
1 9 25 49 81 121 169 225 289 361 441 529 625 729 841 961 1089 1225 1369 1521 1681 1849 2025 2209 2401 2601 2809 3025 3249 3481 3721 3969 4225 4489 4761 5041 5329 5625 5929 6241 6561 6889 7225 7569 7921 8281 8649 9025 9409 9801


> my @odds-squared <== sort {$^b <=> $^a} <== map { $_ ** 2 } <== grep { $_ % 2 } <== @random-nums   # 降序排列
9801 9409 9025 8649 8281 7921 7569 7225 6889 6561 6241 5929 5625 5329 5041 4761 4489 4225 3969 3721 3481 3249 3025 2809 2601 2401 2209 2025 1849 1681
1521 1369 1225 1089 961 841 729 625 529 441 361 289 225 169 121 81 49 25 9 1

> my @rakudo-people = <scott patrick carl moritz jonathan jerry stephen>;
> @rakudo-people ==> grep { /at/ } ==> map { .ucfirst } ==> my @who-it's-at;
> say ~@who-it's-at;    # Patrick Jonathan

> [+](my @a) <== map {$_ **2} <==  1..10   # 385 ， 1 到 10 的平方和
> [+]() <== map {$_ **2} <==  1..10
385
```


## 第十二天 – 智能匹配

By Ttjjss
还记得[Perl 6 Advent](http://perl6advent.wordpress.com/2010/12/04/the-sequence-operator/) 序列操作符吗?因为最后一个参数它接受的是一个上限，这让序列的生成停止了，例如：

```perl
    1, 2, 4 ... 32;         # 1 2 4 8 16 32
    1, 2, 4 ... * > 10;     # 1 2 4 8 16
    > 1,2,4 ... * > 100;
    1 2 4 8 16 32 64 128
    > 1,2,4 ...^ * > 100;
    1 2 4 8 16 32 64
```

你能看到，在第一种情况下，使用了数值相等。第二个更有意思： `*>10` 在内部被重写为一个闭包，像这样 `-> $x { $x > 10 }` (through currying).

序列操作符做了一些不可思议的比较，根据匹配者的类型。这种比较就叫做智能匹配，并且是在Perl6中重复出现的一个概念，例如：

```perl
    # after the 'when' keyword:
    given $age {
        when 100    { say "congratulations!"      }
        when * < 18 { say "You're not of age yet" }
    }
    # after 'where':
    subset Even of Int where * %% 2;
    # 显式地使用智能匹配操作符:
    if $input ~~ m/^\d+$/ {
        say "$input is an integer";
    }
    # arguments to grep(), first() etc.:
    my @even = @numbers.grep: Even;
```

在智能操作符 ~~ 的右侧，并且在 when 和 where 的后面，要匹配的值被设置为 主题变量 `$_`. This allows us to use constructs that operate on $_, like regexes created with m/.../ and .method_call.

下面是一些智能操作符的用法：

```perl

    $foo ~~ Str             #它的类型是 Str吗?
    $foo ~~ 6               #它等于 6 吗?
    $foo ~~ "bar"           #或者它是 "bar" 吗?
    $foo ~~ / \w+ '-' \d+ / # 它匹配某个模式吗?
    $foo ~~ (15..25)        # 它的值在 15 和 25 之间吗?
    $foo ~~ -> $x { say 'ok' if 5 < $x < 25 } # 调用闭包
    $foo ~~ [1, *, 1, *, 1, *] # 含有6个元素的数组，是否其所有的奇数元素的值都为 1?
```

[智能匹配的全部表现可以在这找到：](http://perlcabal.org/syn/S03.html#Smart_matching).

智能匹配没有特殊的操作符，而大部分智能匹配的情况会返回 Bool值，对正则进行匹配会返回一个Match 对象

你可能开始怀疑：一个正确的，内置的类型，我怎么将它用在我自己的类中？你需要为它写一个特别的 ACCEPTS方法。假如我们有一个叫Point 的类：


```perl
    class Point {
        has $.x;
        has $.y;
        method ACCEPTS(Positional $p2) {
            return $.x == $p2[0] and $.y == $p2[1]
        }
    }
```

一切都清楚了吗?让我们看看它是如何工作的:

```perl
    my $a = Point.new(x => 7, y => 9);
    say [3, 5] ~~ $a; # Bool::False
    say (7, 9) ~~ $a; # Bool::True
```

 现在能恰当地做到你想要的，甚至使用你自己的类。

## 第 16 天 - Perl 6 里的时间

今天是圣诞月历的第 0x10 天，是时候学习一下 perl6 里的时间了。S32::Temporal 简介在过去一年中有了大量的修改，今天我们就来介绍一下在 perl6 实现中关于时间的一些基础知识。

time 和 now 是两个可以返回当前时间（至少是你的系统认为的当前时间）的词。简单的展示一下：

```perl
> say time; say now;
```

1292460064
Instant:2010-12-16T00:41:4.873248Z

第一个明显的区别，前者返回的是 POSIX 格式的数值型的结果；而后者返回的是一个瞬间的对象。如果你想获取秒级以下小数点位或者说闰秒，请用 now ；如果不用，那用 time 获取 POSIX 格式就够了。随你的便。
DateTime和他的伙伴
大多数时候，你要的不是当前时间。这种时候，你需要的是 DateTime 。比如还是获取当前时间：

```perl
my $moment = DateTime.new(now); # 或者DateTime.new(time)
```

你有两种方式来创建 DateTime 对象：

```perl
my $dw = DateTime.new(:year(1963), :month(11), :day(23), :hour(17), :minute(15));
```

这是 UTC 时区，如果你要更改时区的话，再加上 :timezone 就好了。这个格式里，只有 :year 是必须的，其他的默认就是1月1号半夜0点0分。
上面这种写法确实乏味，你可以采用 ISO8601 格式的输入，来创建一个 DateTime 对象：

```perl
my $dw = DateTime.new("1963-11-23T17:15:00Z");
```

其中Z 表示 UTC ，想改变的话，把 Z 替换成 +hhmm 或者 -hhmm 就好了。hh 表示小时，mm 表示分钟。
此外，还有一个更简略的 Date 对象。只包括年月日的：

```perl
my $jfk = Date.new("1963-11-22"); # 你也可以用:year 等的写法
```

引入 Date 对象，是吸取了 CPAN 上 DateTime 模块的教训：有时候你压根不关心什么时区啊闰秒啊的。 Date 对象非常容易处理，比如它有内置的 .succ 和 .pred 方法，用来简单的递增和递减。

```perl
$jfk++; # 肯尼迪遇刺后的第二天
```

最后…
以上就是关于 Perl6 里的时间的内容了，想了解更多细节，去看看规范吧；或者去社区里提问

## 第十九天 - 假作真时真亦假

今天的圣临礼物是教大家怎么用混淆完成一个小邪恶滴目的，吼吼~看起来这个功能挺疯狂的，其实有时候蛮有用的。先看下面这个用 but 的例子：

```perl
my $value = 42 but role { method Bool  { False } };
say $value;    # 42
say ?$value;   # False
```

你看，我们改变了 `$value` 的 `.Bool` 方法。他不影响程序里其他所有的整数，哪怕别的变量也是 42。一般情况下，对于 Int 型，`.Bool` 方法（通过?操作符）返回值依据是是否等于 0。但这次它永远都返回 false 了。
事实上，我们还可以写的更简单，因为 False 是一个枚举值：

```perl
my $value = 42 but False;
```

因为 False 是 Bool 值，所有它会自动重载 .Bool 方法。这是 Perl6 的一种转换方法。其他的值，也会对应的重载。
这样在有的时候，这个东西就比较有用了：在 Perl5 里，你用 system 调用 shell 的时候，得牢牢记住在 shell 里，返回 0 才是正常的：

```perl
if ( system($cmd) == 0 ) {  # 或者!system($cmd)
    # ...
}
```

而在 Perl6 中，对应的 run 命令返回的是上面说的这种重载过的 Int，当且仅当返回值是 0 的时候，它的 bool 变成了 True，这正是我们想要的额！

```perl
if run($cmd) {  #不需要否定了
    # ...
}
```

好了，现在进入最疯狂的部分 —— 我们可以重载布尔值的布尔方法：

```perl
my $value = True but False;
say $value;    # True
say ?$value;   # False
```

没错，Perl6 允许你这样自己踢自己屁股~~虽然我也不知道除了捣乱外怎么会有人愿意这么做，但是我还是很高兴看到 Perl6 保持这种微妙的跟踪和重载类型的心态。我可没有……

## Day 21 – transliteration and beyond

By Carl
转换听起来像拉丁词根,意味着字母的变化。这就是 Str.trans 方法所做的。

```perl
say "GATTACA".trans( "TCAG" => "0123" );  # prints "3200212\n"
```

使用过Perl5 的人马上意识到这就是 `tr/tcag/0123/` .

 下面是一个例子，使用 ROT-13算法加密文本：

```perl
sub rot13($text) { $text.trans( "A..Za..z" => "N..ZA..Mn..za..m" ) }
```

当 `.trans` 方法看到那些 `..` 区间时，它会在内部将那些字母展开 (所以 "n..z" 意思是 "nopqrstuvwxyz"). 因此,rot13子例程的最终效果是将ASCII字母表的特定部分映射到其他部分。

在 Perl5 中，两个点跟一个破折号相同，但是在Perl6 中我们让那两个点 .. 代表 范围的概念，在主程序中，在正则中，还有在这里，转换。
要注意的是， .trans 方法是不会改变原来的字符串； 它不会噶边 $text ,而是返回一个新的值。这在Perl6中也是一个通用的旋律。要改变原值，请使用  `.=trans`

```perl
$kabbala.=trans("A..Ia..i" => "1..91..9");
```

(并且，它不仅仅适用于 .trans 方法，它对所有方法都适用。)
当Perl 6 就是 Perl 6，.trans 方法包含了一个秘密武器：
假如我们想转义一些HTML，即，根据下面这个表来替换东西：

```perl
    & => &amp;
    < => &lt;
    > => &gt;
```

但是我们不想关心替换还要按顺序进行：

```perl
    foo         => bar
    foolishness => folly
```

在上面的例子中，如果前面的替换先发生，就不回有后面的替换出现了---这可能不是你想要的。通常，我们想在短的子串之前，尝试并匹配最长的子串。
所以，这看起来我们需要一个最长记号的替换匹配，以避免因为偶然的重复替换而产生的无限循环。
那就是 Perl 6 的 .trans 方法所提供的。这就是它的秘密武器：嵌入两个数组而非字符串. 对于HTML转义，我们所需要的就是：

```perl
my $escaped = $html.trans(
    [ '&',     '<',    '>'    ] =>
    [ '&amp;', '&lt;', '&gt;' ]
);
```

替换的顺序问题和避免循环就不用我们关心了。

## 第二十二天 - Meta-Object Protocol

你有没有想过用你最爱的编程语言写一个类——但是不是按部就班的写类定义，而是通过几行代码？有些语言提供了 API 来完成这个功能。这些 API 的后面，就是元对象协议( Meta-Object Protocol )，简称 MOP 。
Perl6 就有 MOP ，你可以自己创建类、角色、语法，添加方法和属性，并且内省类。比如我们可以调用 MOP 查看 Rakudo 是如何实现 Rat 类型（有理数）的。调用 MOP ，只要把一般的 `.` 换成 `.^` 就可以了。


```perl
$ perl6
> say join ', ', Rat.^attributes
$!numerator, $!denominator
> # 列出全部方法比较多，所以随机选几个
> say join ', ', Rat.^methods(:local).pick(5)
unpolar, ceiling, reals, Str, round
> say Rat.^methods(:local).grep('log').[0].signature.perl
:(Numeric $x: Numeric $base = { ... };; *%_)
```


显示出来的这几行信息相信都是不言自明了。Rat 有两个属性，`$!numerator` 和 `$!denominator` ；有很多方法，其中 log 方法可接受的第一个变量是数值型 invocant(译者注：不知道怎么翻译，反正就是对象本身的引用 $_[0] )，用冒号标记过；第二个变量参数是可选的，名字是 $base ，它设有一个默认值，不过 Rakudo 不打算告诉你……

Perl6 的数据库接口代码里有一个很不错的使用实例。它有一个选项用来记录对象的调用，但是只是记录一部分特定角色（比如和连接管理或者数据检索有关的）。下面是 dbi 里的代码：


```perl
sub log-calls($obj, Role $r) {
     my $wrapper = RoleHOW.new;
     for $r.^methods -> $m {
         $wrapper.^add_method($m.name, method (|$c) {
             # 打印日志信息，note() 函数输出到标准错误
             note ">> $m";
             nextsame;
         });
     }
     $wrapper.^compose();
     # does 操作符和 but 类似，不过只修改一个对象的拷贝
     $obj does $wrapper;
}
role Greet {
     method greet($x) {
         say "hello, $x";
     }
}
class SomeGreeter does Greet {
     method LOLGREET($x) {
         say "OH HAI "~ uc $x;
     }
}
my $o = log-calls(SomeGreeter.new, Greet);
# 记录日志啦，因为由 Greet 角色提供了
$o.greet('you');
# 没记录，因为没角色提供这个
$o.LOLGREET('u');
```

运行结果如下：

    >> greet
    hello, you
    OH HAI U

所以说，有了 MOP ，除了指定的语法，你还可以像普通接口一样访问类、角色、语法和属性。这给了面向对象更大的灵活性，可以轻松的内省和修改对象了。

## 第23天 -  一些精彩的排序示例

继续我们的圣临礼物。
排序是一个非常非常常见的编程任务。Perl6 加强了它的 `.sort` 功能来帮助大家更好的排序。
最最正常的默认写法是这样的：

```perl
my @sorted = @unsorted.sort; # 或者 这样
sort @unsorted;
```

和 Perl5 一样，也是可以自定义函数的：

```perl
    # 数值比较
    my @sorted = @unsorted.sort: { $^a <=> $^b };
    # 或者用函数调用的形式
    my @sorted = sort { $^a <=> $^b }, @unsorted;
    # 字符串比对 ( 跟Perl5的cmp一样 )
    my @sorted = @unsorted.sort: { $^a leg $^b };
    # 类型依赖比对
    my @sorted = @unsorted.sort: { $^a cmp $^b };
```

你也可以把 `:` 换成 `()` ，然后再跟上一些方法进行后续处理，比如：

```perl
my @topten = @scores.sort( { $^b <=> $^a } ).list.munch(10);
```

小提示： $a 和 $b 不再像在 Perl5 中那样有特殊含义了，在 sort 代码块里用别的命名变量 `$var` 、位置变量 `$^var` 或者其他任何的都跟在其他代码段里一样。
你可以直接在排序的时候直接就做好变换函数：

```perl
my @sorted = @unsorted.sort: { foo($^a) cmp foo($^b) };
```

不过 foo() 会在重复执行，如果列表不大也就罢了，如果比较大的话……如果 foo() 还是个计算密集型的……你懂的！
在这种情况下，Perl5 里有个习惯就是使用施瓦茨( Schwartzian )变换。施瓦茨变换的做法就是 decorate-sort-undecorate，foo() 函数只用执行一次：

```perl
    @sorted =
        map  { $_->[0] }
        sort { $a->[1] cmp $b->[1] }
        map  { [$_, foo($_)] }
        @unsorted;
```

Perl6 里，你一样可以使用施瓦茨变换，不过 Perl6 内置了一些智能方法。如果你有一个函数，它接受的参数个数是 0 或 1 ，Perl6 会自动的替你启用施瓦茨变换。

现在让我们来看一些例子吧。

- 不区分大小写的排序：
把每个元素都改成小写，然后把数组按照小写的次序排好返回。

```perl
my @sorted = @unsorted.sort: { .lc };
```


- 单词长度排序：

把每个元素的单词按照从短到长排序。

```perl
my @sorted = @unsorted.sort: { .chars };
```

或者从长到短:

```perl
my @sorted = @unsorted.sort: { -.chars };
```


- 多次排序比较：

你可以在 sort 代码块里放多个比较函数，sort 会注意执行直到退出。比如在单词长度的基础上，再按照 ASCII 码的顺序排序。

```perl
.say for @a.sort: { $^a.chars, $^a } ;
```


不过，在 Rakudo 里好像运行有点问题……它只会比较长度不会比较数值，也就是说， 10 排在 2 的前面。（没关系，TMTONTDI）
perl6 里的 sort 本身是稳定工作的，你可以重复使用。

```perl
.say for @a.sort.sort: { $^a.chars };
```

不过这样 sort 有两次调用，no fashion ！所以你还可以这么写：

```perl
.say for @a.sort: { $^a.chars <=> $^b.chars || $^a leg $^b };
```

不过这下你有两个参数了，perl6 没法自动给你启动施瓦茨变换了。
又或者，你可以加上一个给自然数排序的函数：

```perl
.say for @a.sort: { $^a.chars.&naturally, $^a };
```


“给自然数排序？”我好像听到你们的哭声了，“哪里有？”
很高兴你们这么问，现在继续解决这个问题。

- 自然数排序

标准的词法排序是按照 ASCII 次序的。先是自然数，然后是大写字母，最后是小写字母。所以人们在排序的时候经常得到这样的结果：

```perl
    0
    1
    100
    11
    144th
    2
    21
    210
    3rd
    33rd
    AND
    ARE
    An
    Bit
    Can
    and
    by
    car
    d1
    d10
    d2
```


完全正确，但是没用……尤其是对非程序员来说，更郁闷了就……
真正的自然排序，应该是先按数学量级排自然数，然后才是大小写字母。比如上面那个例子，应该排成这样：

```perl
    0
    1
    2
    3rd
    11
    21
    33rd
    100
    144th
    210
    An
    AND
    and
    ARE
    Bit
    by
    Can
    car
    d1
    d2
    d10
```


所以，我们必须的在排序的时候加上一点转换了。
我使用 `.subst` 方法，这是我们所熟悉的 `s///` 操作符的面向对象形式。

```perl
.subst(/(\d+)/, -> $/ { 0 ~ $0.chars.chr ~ $0 }, :g)
```

第一部分，捕获一个连续的数字，然后由 `->$/{}` 构成一个尖块，意思是：“传递匹配到 `$/` 的数组到 `{}` 代码里”。然后代码里替换成用 0 按照数量级排序的顺序联结的字符串。这个 0 是以 ASCII 字符串出现，联结在原始字符串上的。最后 `/g` 表示全局替换。
如果也不区分大小写，那么：

```perl
.lc.subst(/(\d+)/, -> $/ { 0 ~ $0.chars.chr ~ $0 }, :g)
```

改成子例程的方式：

```perl
    sub naturally ($a) {
        $a.lc.subst(/(\d+)/, -> $/ { 0 ~ $0.chars.chr ~ $0 }, :g)
    }
```


看起来很不错了，不过还有点小问题，比如 THE 、 The 和 the 会按照他们在列表里的顺序返回，而不是我们预计的顺序。有个简单的解决办法，就是在转换过的元素的结尾，加上一个中断。所以最终结果是：

```perl
    sub naturally ($a) {
        $a.lc.subst(/(\d+)/, -> $/ { 0 ~ $0.chars.chr ~ $0 }, :g) ~ "\x0" ~ $a
    }
```


然后你看，这个子例程只有一个参数，所以我们还可以用上施瓦茨变换了：


```perl
.say for <0 1 100 11 144th 2 21 210 3rd 33rd AND ARE An Bit Can and by car d1 d10 d2>.sort: { .&naturally };
```

或者用来给 ip 排序：

```perl
my @ips = ((0..255).roll(4).join('.')for 0..99);
    .say for @ips.sort: { .&naturally };
```

    4.108.172.65
    5.149.121.70
    10.24.201.53
    11.10.90.219
    12.83.84.206
    12.124.106.41
    12.162.149.98
    14.203.88.93
    16.18.0.178
    17.68.226.104
    21.201.181.225
    23.61.166.202
以及目录排序啊等等各种数字与字母的混合体~~
最后，圣诞快乐，排序快乐，愿施瓦茨与你同在！

# 2011

## The Flip-Flop operator

Perl5有一个二元操作符叫做flip-flop,它为假直到它的第一个参数被计算为真，然后它保持真(反转)，直到第二个参数计算为真，然后在那里它又变成假(flop)。 这真是太有用了，以至于Perl6也有flip-flop,只是它拼写为ff,并有一些变异：

```perl
    ff
    ff^
    ^ff
    ^ff^
```

音调符号^意味着在那个结尾跳过结尾。
…或许一些例子更能说明问题…

```perl
for 1..20 { .say if $_ == 9  ff  $_ == 13; }     # 9 10 11 12 13
for 1..20 { .say if $_ == 9  ff^ $_ == 13; }     # 9 10 11 12
for 1..20 { .say if $_ == 9 ^ff  $_ == 13; }     # 10 11 12 13
for 1..20 { .say if $_ == 9 ^ff^ $_ == 13; }     # 10 11 12
```


每个例子中，我们遍历从1到20的数字范围，并且在flip-flop返回真时输出那些数字。每次循环中，flip-flop 操作符的左边(`$_ == 9`) 和 flip-flop操作符的右边 (`$_ == 13`)都会被计算。 (这里我已经在 flip-flop操作符的两侧使用了简单的数字比较，但是，一般任何布尔表达式都能使用。

每个 flip-flop 操作符的实例维护它们的内部状态以决定什么时候返回TRUE或False.所有的flip-flop操作符在它们的内部状态被设置为返回False时出现，直到它们被反转然后开始返回 TRUE.

在第一个和第二个例子中，当`$_ == 9` 时，flip-flop 操作符反转它们的内部状态为 TRUE ，然后立即返回 TRUE.在第三个和第四个例子中，当`$_== 9`时，flip-flop操作符将它们的内部状态设置为 TRUE,但是它们在那次遍历中返回 False ，因为前置的 ^符号。
类似地，在上面的第一个和第三个例子中，一旦RHS求值为真时， flip-flop操作符在下一次循环中将它们的内部状态反转回FALSE,然后返回True.在第三个和第四个例子中，flip-flop操作符在RHS返回真时立即反转为FALSE.
让flip-flop操作符反转但从不flop,在RHS上使用*：

```perl
    for 1..20 { .say if $_ == 15 ff *; }     # 15 16 17 18 19 20
```

Perl6有另外一套 flip-flop操作符，功能与上面提到的差不多，除了，在LHS变成真的时候，RHS不被求值。这很有用，当flip-flop操作符的RHS 和LHS 都同时求值为真的时候，These operators are spelled 这些操作符被拼写为  fff, fff^, ^fff, and ^fff^.


## Idiomatic Perl 6
December 23, 2011

下面大多数的例子使用 4 种版本展示代码：

-  Non-idiomatic Perl 5,
-  then made idiomatic.
-  Perl 5 idiom, naively translated into Perl 6,
-  then made idiomatic.

从 1 到 4 越来越清晰和简洁



- 随机选择数组元素


```perl
$z = $array[ int(rand scalar(@array)) ];
$z = $array[ rand @array ];
```



```perl
$z = @array[ rand*@array ];
$z = @array.pick;
```


- 循环遍历数组的键（索引）


```perl
for ( my $i=0; $i<@array; $i++ ) {...}
for my $i ( 0 .. $#array )       {...}
```



```perl
for 0 .. @array.end -> $i {...}
for @array.keys -> $i     {...}
```


- 整除


```perl
( ($x - ($x % 3) ) / 3 )
int( $x / 3 )
```



```perl
Int( $x / 3 )   # 首字母需大写
$x div 3        # 整除运算符
```


- 打印数组元素的个数


```perl
say scalar @array;
say 0+@array;
```



```perl
say 0+@array;          # Identical in Perl 6
say +@array;           # + 强制新的“数值”上下文
say @array.elems;      # .elems 方法更清楚.
```

- 每隔5 次 做些事情


```perl
if ( ($x/5) == int($x/5) ) {...}
if ( !($x % 5) )           {...}
```



```perl
if !($x % 5) {...}
if $x %% 5   {...}     # %% means "is evenly divisible by"
```


- Do something $n times, 直到 $n-1

```perl
for ( $_=0; $_ < $n; $_++ ) {...}
for ( 0 .. ($n-1) )         {...}
```



```perl
for 0 ..^ $n {...}
for ^$n      {...}     # ^9 means 0 ..^ 9, or 0..8
```


eg：

    > .say for ^5

0
1
2
3
4

Bare method calls are *always* methods on $_, eliminating Perl 5's confusion on which functions default to $_.


- 按空白分割

```perl
@words = split /\s+/, $_;
@words = split;           # Default is useful, but not intuitive
```



```perl
@words = .split(/\s+/);  # split() 现在没有默认的模式
@words = .words;         # split 的旧的行为现在成为了一个单独的方法.words
```

- 将字符串分割成单独的字符

```perl
@chars = map { substr $word, $_, 1 } 0..length($word);
@chars = split '', $word;# Split on nothingness
```



```perl
@chars = $word.split('');
@chars = $word.comb;     # Default is to "keep everything"
```

 eg：

```perl
> my $word='Perl6'
Perl6
> my @chars=$word.split('')
P e r l 6
> my @chars=$word.split('').join('->')
P->e->r->l->6
> my @chars=$word.comb
P e r l 6
> my @chars=$word.comb.join(':')
P:e:r:l:6
```


- 无限循环

```perl
for (;;)  {...}    # Spoken with a 'C' accent
while (1) {...}
```


```perl
while 1   {...}
loop      {...}   # 没有给出限定条件，所以默认无止尽
```

- 按原来的顺序返回列表中的唯一元素

```perl
my %s, @r; for @a  { push @r, $_ if !$s{$_}; $s{$_}++; } return @r;
my %s; return grep { !$s{$_}++ } @a;    # or List::MoreUtils::uniq
```



```perl
my %s; return grep { !%s{$_}++ }, @a;
return @a.uniq;
```


- 将列表中的所有元素求和

```perl
my $sum = 0; for my $num (@a) { $sum += $num }
my $sum; $sum += $_ for @a;    # or List::Util::sum
```


```perl
my $sum = @a.reduce(*+*);
my $sum = [+] @a;              # [op] 将op操作符应用到整个列表
```



```perl
@alpha = 'A' .. 'Z';
@a = qw{ able baker charlie };
%meta = ( foo => 'bar', baz => 'quz' );
@squares = map { $_ * $_ }, @a;
@starts_with_number = grep { /^\d/ }, @a;
```

钻石操作符还在：

- Process each line from STDIN or from command-line files.


```perl
for my $file (@ARGV) { open FH, $file; while (<FH>) {...} }
while (<>) {...}               # Null filehandle is magical
```



```perl
for $*ARGFILES.lines {...}
for lines()          {...}     # lines() defaults to $fh = $*ARGFILES
```

- 将散列初始化为一个常量


```perl
my %h;   for (@a) { $h{$_} = 1 }
my %h = map { $_ => 1 } @a;
```



```perl
my %h = map { $_ => 1 }, @a;
my %h = @a X=> 1;
```


eg：


```perl
> my @a=<Perl Python Ruby Perl6>
Perl Python Ruby Perl6
> my %h= @a X=> 1
("Perl" => 1, "Python" => 1, "Ruby" => 1, "Perl6" => 1).hash
```


- Hash initialization for enumeration

```perl
my %h;   for (0..$#a) { $h{ $a[$_] } = $_ }
my $c;   my %h = map  { $_ => ++$c } @a;
```



```perl
my $c;   my %h = map { $_ => ++$c }, @a;
("Perl" => 1, "Python" => 2, "Ruby" => 3, "Perl6" => 4).hash
```



```perl
my %h = @a Z=> 1..*;       # ("Perl" => 1, "Python" => 2, "Ruby" => 3, "Perl6" => 4).hash
my %h = @a.pairs».invert;  # if zero based , ("Perl" => 0, "Python" => 1, "Ruby" => 2, "Perl6" => 3).hash
```

 > @a.pairs
0 => "Perl" 1 => "Python" 2 => "Ruby" 3 => "Perl6"

- Hash initialization from parallel arrays

```perl
my %h;   for (@a) { $h{$_} = shift @b }
my %h;   @h{@a} = @b;
```


```perl
my %h;   %h{@a} = @b;
my %h = @a Z=> @b;
```

eg:

```perl
> my @b=<Larry Gao Mztiz Larry_Wall>
Larry Gao Mztiz Larry_Wall
> my %h= @a Z=> @b
("Perl" => "Larry", "Python" => "Gao", "Ruby" => "Mztiz", "Perl6" => "Larry_Wall").hash
```

- 交换两个变量

```perl
my $temp = $x; $x = $y; $y = $temp;
( $x, $y ) = ( $y, $x );
```


```perl
 ( $x, $y )  = $y, $x;
 ( $x, $y ) .= reverse;   # .= makes reverse into a "mutating" method
 # Tastes great on array swaps, too!   @a[ $j, $k ] .= reverse;
```

- Rotate array left by 1 element

```perl
my $temp = shift @a; push @a, $temp;
push @a, shift @a;
```



```perl
@a.push: @a.shift;
@a .= rotate; # Python Ruby Perl6 Perl
```

- 创建一个对象

```perl
my $pet = new Dog;
my $pet = Dog->new;
```



```perl
my $pet = Dog.new;
my Dog $pet .= new;    # $pet *always* isa Dog; Compiler can optimize!
```

Combining transformation with selection was an advanced idiom in Perl 5. The new return values for if provide a bite-sized idiom.

- Three copies of elements > 5

```perl
 @z = map { ($_) x 3 } grep { $_ > 5 } @y;    # map,grep
 @z = map { $_ > 5 ? ($_) x 3 : () } @y;      # map as grep
```



```perl
@z = map { $_ > 5 ?? ($_) xx 3 !! Nil }, @y;
@z = @y.map: { $_ xx 3 if $_ > 5 };          # !if == Empty list
@z = ($_ xx 3 if $_ > 5 for @y);             # List comprehension
```

- 3到7之间的随机整数，包含3和7

```perl
do { $z = int rand 8 } until $z >= 3;
$z = 3 + int rand 5;
```



```perl
$z = 3 + Int(5.rand);
$z = (3..7).pick;
```


- 在无限循环中每次循环加 3


```perl
for ( my $i = 1; ; $i++ ) { my $n = 3 * $i; ... }
for ( my $n = 3; ; $n += 3 ) {...}
```



```perl
loop ( my $n = 3; ; $n += 3 ) {...}
for 3, * + 3 ... * -> $n      {...}      # `...` is the "sequence" operator
for 3, 6, 9 ... * -> $n       {...}      # `...` can infer from example list
```

- 遍历区间, 不包含开始点和结束点

```perl
for my $i ( $start .. $limit ) { next if $i == $start or $i == $limit; ... }
for my $i ( ($start+1) .. ($limit-1) ) {...}
```



```perl
for ($start+1) .. ($limit-1) -> $i {...}
for $start    ^..^ $limit    -> $i {...}
```


# 2012

## 一个日历


```perl
#!/usr/bin/env perl6

    constant @months = <January February March April May June July August September October November December>;
    constant @days = <Su Mo Tu We Th Fr Sa>;

    sub center(Str $text, Int $width) {
        my $prefix = ' ' x ($width - $text.chars) div 2;
        my $suffix = ' ' x $width - $text.chars - $prefix.chars;
        return $prefix ~ $text ~ $suffix;
    }

    sub MAIN(:$year = Date.today.year, :$month = Date.today.month) {
        my $dt = Date.new(:year($year), :month($month), :day(1) );
        my $ss = $dt.day-of-week % 7;
        my @slots = ''.fmt("%2s") xx $ss;

        my $days-in-month = $dt.days-in-month;
        for $ss ..^ $ss + $days-in-month {
            @slots[$_] = $dt.day.fmt("%2d");
            $dt++
        }

        my $weekdays = @days.fmt("%2s").join: " ";
        say center(@months[$month-1] ~ " " ~ $year, $weekdays.chars);
        say $weekdays;
        for @slots.kv -> $k, $v {
            print "$v ";
            print "\n" if ($k+1) %% 7 or $v == $days-in-month;
        }
    }
```


## Bags and Sets

December 13, 2012
过去几年，我写了很多这种代码的变种：

```perl
my %words;
for slurp.comb(/\w+/).map(*.lc) -> $word {
    %words{$word}++;
}
```

(此外: slurp.comb(/\w+/).map(*.lc) 从指定的标准输入或命令行读取文件，遍历数据中的单词，然后小写化该单词。 eg ： perl6 slurp.pl score.txt)
Perl6引入了两种新的组合类型来实现这种功能。 在这种情况下，半路杀出个KeyBag 代替了 hash:

```perl
my %words := KeyBag.new;
for slurp.comb(/\w+/).map(*.lc) -> $word {
    %words{$word}++;
}
```

这种情况下，为什么你会喜欢 KeyBag多于 散列呢，难道是前者代码更多吗？很好，如果你想要的是一个正整数值的散列的话，KeyBag将更好地表达出你的意思。
    > %words{"the"} = "green";

未处理过的异常：不能解析数字：green
然而KeyBag有几条锦囊妙计。首先，四行代码初始化你的 KeyBag 不是很罗嗦，但是Perl 6能让它全部写在一行也不会有问题：

```perl
my %words := KeyBag.new(slurp.comb(/\w+/).map(*.lc));
```

KeyBag.new 尽力把放到它里面的东西变成KeyBag的内容。给出一个列表，列表中的每个元素都会被添加到 KeyBag 中，结果和之前的代码块是完全一样的。
如果你不需要在创建bag后去修改它，你可以使用 Bag 来代替 KeyBag。不同之处是 Bag 是不会改变的；如果 %words 是一个 Bag，则 %words{$word}++ 是非法的。如果对你的程序来说，不变没有问题的话，那你可以让代码更紧凑。

```perl
my %words := bag slurp.comb(/\w+/).map(*.lc);  # 散列 %words不会再变化
```

bag 是一个有用的子例程，它只是对任何你给它的东西上调用 Bag.new 方法。（我不清楚为什么没有同样功能的 keybag 子例程）
Bag 和 KeyBag 有几个雕虫小技。它们都有它们自己的 .roll 和 .pick 方法，以根据给定的值来权衡它们的结果：

```perl
> my $bag = bag "red" => 2, "blue" => 10;
> say $bag.roll(10);
> say $bag.pick(*).join(" ");
blue blue blue blue blue blue red blue red blue
blue red blue blue red blue blue blue blue blue blue blue
This wouldn’t be too hard to emulate using a normal Array, but this version would be:
> $bag = bag "red" => 20000000000000000001, "blue" => 100000000000000000000;
> say $bag.roll(10);
> say $bag.pick(10).join(" ");
blue blue blue blue red blue red blue blue blue
blue blue blue red blue blue blue red blue blue

sub MAIN($file1, $file2) {
    my $words1 = bag slurp($file1).comb(/\w+/).map(*.lc);
    my $words2 = set slurp($file2).comb(/\w+/).map(*.lc);
    my $unique = ($words1 (-) $words2);
    for $unique.list.sort({ -$words1{$_} })[^10] -> $word {
        say "$word: { $words1{$word} }";
    }
}
```

传递两个文件名，这使得 Bag 从第一个文件中获取单词，让 Set 从第二个文件中获取单词，然后使用 集合差 操作符 (-) 来计算只在第一个文件中含有的单词，按那些单词出现的频率排序，然后打印出前10 个单词。
这是介绍 Set 的最好时机。就像你从上面猜到的一样，Set 跟 Bag 的作用很像。不同的地方在于，它们都是散列，而 Bag 是从Any到正整数的映射，Set 是从 Any 到 Bool::True的映射。集合Set 是不可改变的，所以也有一个 可变的 KeySet .
在 Set 和 Bag 之间，我们有很丰富的操作符：


```perl

操作符	Unicode	“Texas”	结果类型

属于	∈	(elem)	Bool
不属于	∉	!(elem)	Bool
包含	∋	(cont)	Bool
不包含	∌	!(cont)	Bool

并集	∪	(|)	Set 或 Bag
交集	∩	(&)	Set 或 Bag
差集	        (-)	Set

子集	⊆	(<=)	Bool
非子集	⊈	!(<=)	Bool
真子集	⊂	(<)	Bool
非真子集	⊄	!(<)	Bool

超级	⊇	(>=)	Bool
非超级	⊉	!(>=)	Bool
真超级	⊃	(>)	Bool
非真超级	⊅	!(>)	Bool

bag multiplication	⊍	(.)	Bag
bag addition	⊎	(+)	Bag
set symmetric difference (^)	Set
```



它们中的大多数都能不言自明。返回Set 的操作符在做运算前会将它们的参数提升为 Set。返回Bag 的操作符在做运算前会将它们的参数提升为 Bag 。返回Set 或Bag 的操作符在做运算前会将它们的参数提升为 Bag ，如果它们中至少有一个是 Bag 或 KeyBag，否则会转换为 Set； 在任何一种情况下，它们都返回提升后的类型。
eg：

```perl
> my $a = bag <a a a b b c>;  # bag(a(3), b(2), c)
> my $b = bag <a b b b>;      # bag(a, b(3))

> $a (|) $b;
bag("a" => 3, "b" => 3, "c" => 1)

> $a (&) $b;
bag("a" => 1, "b" => 2)

> $a (+) $b;
bag("a" => 4, "b" => 5, "c" => 1)

> $a (.) $b;
bag("a" => 3, "b" => 6)
```

[下面是作者放在 github上的 Demo：](https://github.com/colomon/perl6-set-bag-demo)

A quick example of getting the 10 most common words in Hamlet which are not found in Much Ado About Nothing:

```perl
> perl6 bin/most-common-unique.pl data/Hamlet.txt data/Much_Ado_About_Nothing.txt
```

ham: 358
queen: 119
hamlet: 118
hor: 111
pol: 86
laer: 62
oph: 58
ros: 53
horatio: 48
clown: 47

## 超棒的匿名函数

Perl6 对函数有很好的支持。Perl6 令人惊叹的把函数声明包起来，让你可以用各种方法来定义一个函数又不丢失任何特性。你可以定义参数类型、可选参数、命名参数，甚至在子句里也可以。如果我不知道更好的理由的话，我可能都在怀疑这是不是在补偿 Perl5 里那个相当基本的参数处理（咳咳 ，@_，你懂的）。
除开这些，Perl6 也允许你定义没有命名的函数。

```perl
sub {say "lol, I'm so anonymous!" }
```

这有什么用？你不命名它，就没法调用它啊，对不？错！
你可以保存这个函数到一个变量里。或者从另一个函数里 return 这个函数。或者传参给下一个函数。事实上，当你不命名你的函数的时候，你随后要运行什么代码就变得非常清晰了。就像一个可执行的" todo "列表一样。

现在让我们说说匿名函数可以给我们做点什么。在 Perl6 里它看起来会是什么样子呢？
嗯，就用最著名的排序来做例子吧。你可能想象 Perl6 有一个 sort_lexicographically 函数和一个 sort_numberically 函数。不过其实没有。只有一个 sort 函数。当你需要具体用某种形式的排序时，你就可以传递一个匿名函数给 sort 。

```perl
my @sorted_words   = @words.sort({ ~$_ });
my @sorted_numbers = @numbers.sort({ +$_ });
```

（从技术上来说，这是块，不是函数。不过如果你不打算在里面使用 return 的话，差异不大。）
当然你可以做的比这两个排序办法多多了。你可以通过鞋子大小排序，或者最大地面速度，或者自燃可能性的降序等等。因为你可以把任何逻辑作为一个参数传递进去。面向对象的教徒们对这种模式可非常自豪，还专门命名为“依赖注入”。
想想看，map 、 grep 和 reduce 都很依赖这种函数传递。我们有时候把这种传递函数给函数的做法叫“高阶编程”，好像这是某些高手的特权似的。但其实这是一个非常有用而且可以普通使用的技能。
上面的示例都是在当前执行时就运行函数了。其实这里没什么限制。我们可以创建函数，然后稍后再运行：

```perl
sub make_surprise_for($name) {
    return sub { say "Sur-priiise, $name!" };
}

my $reveal_surprise = make_surprise_for("Finn");    #

# 目前什么都没发生
# 等着
# 继续等着
# 等啊等啊等啊
$reveal_surprise();        # "Sur-priiise, Finn!"
```


`$reveal_surpirse` 里的函数记住了 `$name` 变量值，虽然原始函数是在很早之前传递进去的参数。棒极了！这个效果就叫在 `$name` 变量上闭合的匿名函数。不过这里可没什么技术 -- 反正很棒就是了。
事实上，如果放在其他主要存储机制比如数组和散列旁边再看匿名函数本身，这感觉是很自然的事情。所有这些都可以存储在变量里，作为参数传递或者从函数里返回。一个匿名数组允许你保存序列给以后调用。一个匿名散列允许你存储映射给以后调用。一个匿名函数允许你存储计算或者行为给以后调用。
本月晚些时候，我会写篇介绍怎样通过 Perl6 的动态域来创建漂亮的 DSL-y 接口。我们可以看到匿名函数在那里是怎么发挥作用的。

##  第九天:最长标示匹配

Perl6 正则表达式偏好尽可能的匹配最长的选择。

```perl
say "food and drink" ~~ / foo | food /;   # food
```

这跟 Perl5 不一样。Perl5 更喜欢上面例子中的第一个选择，结果匹配的是 "foo" 。
如果你希望的话，你依然可以按照优先匹配的原则运行，这个原则隐藏在稍长选择操作符 `||` 背后：

```perl
say "food and drink" ~~ / foo || food /;  # foo
```

...就是这样。这就是最长标记匹配。 ☺ 短文完毕。
“喂，等等！”你听见你绝望而惊讶的大叫了，满足你希望让每天的 Perl6 圣临历走的慢一点的愿望。“为什么说最长标记匹配很重要？谁会在意这个？”
我很高兴你这样问。事实证明，最长标记匹配（简称 LTM ）在如何解析的时候和我们的直觉配合相当默契。如果你创造了一门语言，你希望人们可以声明一个叫 forest_density 的变量而不用提及这个单词和循环里用的 for 语法冲突，LTM 可以做到。
我喜欢“奇怪的一致性”这个说法 -- 尤其当程序语言设计的共性让大家越来越雷同的时候。这里就是一种在类和语法之间的一致性。 Perl6 基本上把这种一致性发挥到了极致。让我简单的阐述下我的意思。
现在我们习惯于写一个类，总体来看，类差不多是长这个样子的：

```perl
class {
    method
    method
    method
}
```

奇怪的是，语法有个非常类似的结构：

```perl
grammar {
    rule
    rule
    rule
}
```

（实际上关键词有 regex，token 和 rule，不过当我们把他当作一个组来讨论的时候，我们暂时统一叫做 rules）
我们同样习惯于派生子类（class B is A），然后添加或者重写方法来产生一个新旧行为在一起的组合。Pelr6 提供了 multi methods ，它允许你添加相同名字的新方法，而且不重写原有的，它只尝试匹配所有的到新方法而已。这个调度是由一个（通常自动生成的） proto method 处理的。它负责调度给所有合格的候选者。

这些是怎样用语法和角色运行起来的呢？额，首先它从原有的里面派生出新的语法，和派生子类一样。（事实上，底层是 完全 相同的机制。语法不过是有个不同元类对象的类罢了。）新的角色也会重写原有的角色，和你在方法上习惯的一样。
S05 有个漂亮的解析信件的示例。然后派生出来解析正式信件的语法：

```perl
     grammar Letter {
         rule text     {    }
         rule greet { [Hi|Hey|Yo] $=(\S+?) , $$}
         rule body     { +? }   # note: backtracks forwards via +?
         rule close { Later dude, $=(.+) }
     }

     grammar FormalLetter is Letter {
         rule greet { Dear $=(\S+?) , $$}
         rule close { Yours sincerely, $=(.+) }
     }
```

派生出来的 FormalLetter 重写了 greet 和 close，但是没重写 body。
但是这一切在 multi 方法下也能正常运行吗？我们是不是可以定义一种“原型角色”来允许我们在一个语法里用同样的名字有多种角色，内容各不相同？比如，我们可能希望用一个角色 term 来解析语言，不过有很多不同的 terms：字符串、数字……而且数字可能是十进制、二进制、八进制、十六进制等……

Perl6 语法可以包含一个原型角色，然后你可以定义、重定义同名角色随便多少次。显然让我们回到文章最开始的 / foo | food /。所有你起了相同名字的角色会编译成一个大的 alternation（译者注：轮流选择，不确定怎么翻译更好）。

不仅如此 -- 调用其他角色的角色，有些可能是原型角色，这些也会全部扁平化到一个大的 LTM 轮流选择里。实践中，这意味着一个 term 的所有可能会一次被全部尝试一遍，机会平等。没哪个会因为自己是先定义的所以胜出，只有最长匹配的那个选择才胜出。

这个奇怪的一致性说明事实上，在调用某个方式的时候，最具体的方法胜出，而且这个“最具体”必须加上引号。签名里参数描述类型越好，方法就越具体。
在分析某个角色的时候，同样是最具体的角色胜出，不过这里“最具体”必须成功解析才行。角色描述下一步进入的文本越详细，角色就越具体。
这就是奇怪的一致性。因为表面上方法和角色看起来就是完全不一样的怪兽。
我们真心相信我们理解了派生语法的原理并且得到了一门新的语言。 LTM 就是最合适的因为它允许新旧角色通过一个公平和可预测的办法混杂在一起。角色不是因为他们定义的前后而胜出，而是因为它能最好的解析文本。这才是挑选精英的办法。

事实上，Perl6 编译器自己就是这样工作的。它使用 Perl6 语法解析你的程序，这个语法是可以派生的……不管你在程序里什么时候声明了一个新操作符，都会给你派生出一个新的语法。新操作符的解析就作为新角色加入到新语法里。然后把解析剩余程序的任务交给新的语法。你的新操作符会胜过那写相同但匹配更短的，不过输给相同但匹配更长的。

## 开开心心玩Rakudo和Euler项目

Perl6 实现的领先者 Rakudo ，目前还不完美，说起性能也尤其让人尴尬。然而先行者不会问“他快么？”，而会问“他够快么？”，甚至是“我怎样能帮他变得更快呢？”。
为了说服你Rakudo已经能做到足够快了。我们准备尝试做一组Euler项目测试。其中很多涉及强行的数值计算，Rakudo目前还不是很擅长。不过我们可没必要就此顿足：语言性能降低了，程序员就要更心灵手巧了，这正是乐趣所在啊。
所有的代码都是在Rakudo 2012.11上测试通过的。
We’ll start with something simple: 先从一些简单的例子开始：
问题2

想想斐波那契序列里数值不超过四百万的元素，计算这些值的总和。
办法超级简单：

```perl
say [+] grep * %% 2, (1, 2, *+* ...^ * > 4_000_000);
```

运行时间：0.4秒

注意怎样使用操作符才能让代码即紧凑又保持可读性(当然这点大家肯定意见不一)。我们用了：

- 无论如何用 * 创建 lambda 函数
- 用序列操作符...^来建立斐波那契序列
- 用整除操作符%%来过滤元素
- 用[+]做reduce操作计算和

当然，没人强制你这样疯狂的使用操作符 -- 香草(vanilla)命令式的代码也没问题：
问题3

600851475143的最大素因数是多少？
命令式的解决方案是这样的：

```perl
sub largest-prime-factor($n is copy) {
    for 2, 3, *+2 ... * {
        while $n %% $_ {
            $n div= $_;
            return $_ if $_ > $n;
        }
    }
}

say largest-prime-factor(600_851_475_143);
```

运行时间：2.6秒

注意用的`is copy`，因为 Perl6 的绑定参数默认是`只读`的。还有用了`整数除法div`，而没用数值除法的`/`。
到目前为止都没有什么特别的，我们继续：

问题53

n从1到100， <sup>n</sup>C<sub>r</sub>的值，不一定要求不同，有多少大于一百万的？

我们将使用流入操作符==>来分解算法成计算的每一步：

```perl
[1], -> @p { [0, @p Z+ @p, 0] } ... * # 生成杨辉三角
==> (*[0..100])()                     # 生成0到100的n行
==> map *.list                        # 平铺成一个列表
==> grep * > 1_000_000                # 过滤超过1000000的数
==> elems()                           # 计算个数
==> say;                              # 输出结果
```

运行时间：5.2s

注意使用了Z操作符和+来压缩 0,@p 和 @p,0 的两个列表。
这个单行生成杨辉三角的写法是从Rosetta代码里偷过来的。那是另一个不错的项目，如果你对 Perl6 的片段练习很感兴趣的话。

让我们做些更巧妙的：
问题9

存在一个毕达哥拉斯三元数组让 `a +b + c = 1000` 。求a、b、c的值。

暴力破解可以完成 (Polettix 的解决办法)，但是这个办法不够快（在我机器上花了11秒左右）。让我们用点代数知识把问题更简单的解决。
先创建一个 (a, b, c) 组成的毕达哥拉斯三元数组:
a < b < c
a² + b² = c²
要求 N = a + b +c 就要符合：
b = N·(N - 2a) / 2·(N - a)
c = N·(N - 2a) / 2·(N - a) + a²/(N - a)
这就自动符合了 b < c 的条件。
而 a < b 的条件则产生下面这个约束：
a < (1 - 1/√2)·N
我们就得到以下代码了：


```perl
sub triplets(\N) {
    for 1..Int((1 - sqrt(0.5)) * N) -> \a {
        my \u = N * (N - 2 * a);
        my \v = 2 * (N - a);

        # 检查 b = u/v 是否是整数
        # 如果是，我们就找到了一个三元数组
        if u %% v {
            my \b = u div v;
            my \c = N - a - b;
            take $(a, b, c);
        }
    }
}

say [*] .list for gather triplets(1000);
```

运行时间：0.5s

注意 sigilless (译者注：实在不知道这个怎么翻译)变量\N，\a……的声明，$(...)是怎么用来把三元数组作为单独元素返回的，用`$_.list`的缩写.list来恢复其列表性。
&triplets 子例程作为生成器，并且使用 &take 切换到结果。相应的 &gather 用来划定生成器的(动态)作用域，而且它也可以放进 &triplets，这个可能返回一个懒惰列表。
我们同样可以使用流操作符改写成数据流驱动的风格：

```perl
constant N = 1000;

1..Int((1 - sqrt(0.5)) * N)
==> map -> \a { [ a, N * (N - 2 * a), 2 * (N - a) ] }
==> grep -> [ \a, \u, \v ] { u %% v }
==> map -> [ \a, \u, \v ] {
    my \b = u div v;
    my \c = N - a - b;
    a * b * c
}
==> say;
```

运行时间：0.5s

注意我们是怎样用解压签名绑定 -> [...] 来解压传递过来的数组的。
使用这种特殊的风格没有什么实质的好处：事实上还很容易影响到性能，我们随后会看到一个这方面的例子。
写纯函数式算法是个超级好的路子。不过原则上这就意味着让那些足够先进的优化器乱来（想想自动向量化和线程）。不过Rakudo还没到这个复杂地步。
但是如果我们没有聪明到可以找到这么牛叉的解决办法，该怎么办呢？

问题47

求第一个连续四个整数，他们有四个不同的素因数。
除了暴力破解，我没找到任何更好的办法：

```perl
constant $N = 4;

my $i = 0;
for 2..* {
    $i = factors($_) == $N ?? $i + 1 !! 0;
    if $i == $N {
        say $_ - $N + 1;
        last;
    }
}
```

这里，&fators 返回素因数的个数，原始的实现差不多是这样的：

```perl
sub factors($n is copy) {
    my $i = 0;
    for 2, 3, *+2 ...^ * > $n {
        if $n %% $_ {
            ++$i;
            repeat while $n %% $_ {
                $n div= $_
            }
        }
    }
    return $i;
}
```

运行时间：unknown (33s for N=3)

注意 repeat while ...{...} 的用法, 这是do {...} while(...);的新写法。
我们可以加上点缓存来加速程序：

```perl
BEGIN my %cache = 1 => 0;

multi factors($n where %cache) { %cache{$n} }
multi factors($n) {
    for 2, 3, *+2 ...^ * > sqrt($n) {
        if $n %% $_ {
            my $r = $n;
            $r div= $_ while $r %% $_;
            return %cache{$n} = 1 + factors($r);
        }
    }
    return %cache{$n} = 1;
}
```

运行时间：unknown (3.5s for N=3)

注意用 BEGIN 来初始化缓存，不管出现在源代码里哪个位置。还有用 multi 来启用对 &factors 的多样调度。where 子句可以根据参数的值进行动态调度。
哪怕有缓存，我们依然无法在一个合理的时间内回答上来原来的问题。现在我们怎么办？只能用点骗子手段了Zavolaj – Rakudo版本的NativeCall – 来在C语言里实现因式分解.
事实证明这还不够好，所以我们继续重构剩下的代码，添加一些原型声明：

```perl
use NativeCall;

sub factors(int $n) returns int is native('./prob047-gerdr') { * }

my int $N = 4;

my int $n = 2;
my int $i = 0;

while $i != $N {
    $i = factors($n) == $N ?? $i + 1 !! 0;
    $n = $n + 1;
}

say $n - $N;
```

运行时间：1m2s (0.8s for N=3)

相比之下，完全使用C语言实现这个算法，运行时间在0.1秒之内。所以目前Rakudo还没法赢得任何一种速度测试。
重复一下，用三种办法做一件事：
问题29

在 2 ≤ a ≤ 100 和 2 ≤ b ≤ 100 的情况下由a<sup>b</sup>生成的序列里有多少不一样的元素？
下面是一个很漂亮但很慢的解决办法，可以用来验证其他办法是否正确：

```perl
say +(2..100 X=> 2..100).classify({ .key ** .value });
```

运行时间：11s

注意使用 X=> 来构造笛卡尔乘积。用对构造器 => 防止序列被压扁而已。
因为Rakudo支持大整数语义，所以在计算像100100这种大数的时候没有精密度上的损失。
不过我们并不真的在意幂的值，不过用基数和指数来唯一标示幂。我们需要注意基数可能自己本身就是前面某次的幂值：

```perl
constant A = 100;
constant B = 100;

my (%powers, %count);

# 找出那些是之前基数的幂的基数
# 分别存储基数和指数
for 2..Int(sqrt A) -> \a {
    next if a ~~ %powers;
    %powers{a, a**2, a**3 ...^ * > A} = a X=> 1..*;
}

# 计算重复的个数
for %powers.values -> \p {
    for 2..B -> \e {
        # 上升到 \e 的幂
        # 根据之前的基数和对应指数分类
        ++%count{p.key => p.value * e}
    }
}

# 添加 +%count 作为一个需要保存的副本
say (A - 1) * (B - 1) + %count - [+] %count.values;
```

运行时间：0.9s

注意用序列操作符 ...^ 推断集合序列，只要提供至少三个元素，列表赋值 %powers{...} = ... 就会无休止的进行下去。
我们再次用数据驱动的函数式的风格重写一遍：

```perl
sub cross(@a, @b) { @a X @b }
sub dups(@a) { @a - @a.uniq }

constant A = 100;
constant B = 100;

2..Int(sqrt A)
==> map -> \a { (a, a**2, a**3 ...^ * > A) Z=> (a X 1..*).tree }
==> reverse()
==> hash()
==> values()
==> cross(2..B)
==> map -> \n, [\r, \e] { (r) => e * n }
==> dups()
==> ((A - 1) * (B - 1) - *)()
==> say();
```

运行时间：1.5s

注意我们怎么用 &tree 来防止压扁的。我们可以像之前那样用 X=> 替代 X ，不过这会让通过 ->  \n, [\r, \e] 解构变得很复杂。
和预想的一样，这个写法没像命令式的那样执行出来。怎么才能正常运行呢？这算是我留给读者的作业吧。
最后


## 解析 IPv4 地址

Perl6 的正则现在是一种子语言了，很多语法没有变:
/\d+/
捕获数字：
/(\d+)/
现在 `$0` 存储着匹配到的数字，而不是 Perl 5 中的 `$1`. 所有的特殊变量 `$0`,`$1`,`$2` 在 Perl6 里就是 `$/[0]`, `$/[1]`, `$/[2]`. 在Perl 5 中，`$0` 是脚本或程序的文件名，但是这在 Perl6 中变成了 `$*EXECUTABLE_NAME` .

Should you be interested in getting all of the captured groups of a regex match, you can use @(), which is syntactic sugar for @($/).
The object in the $/ variable holds lots of useful information about the last match. For example, $/.from will give you the starting string position of the match.
But $0 will get us far enough for this post. We use it to extract individual features from a string.

修饰符现在放在前面了:

```perl
$_ = '1 23 456 78.9';
say .Str for m:g/(\d+)/; # 1 23 456 78 9
```

匹配所有看起来像这样的东西很有用，以至于它有一个专门的 `.comb` 方法：

```perl
$str.comb(/\d+/);
```

如果你对  `.split`很熟悉，你可以想到 `.comb` 就是它的表哥，它匹配  `.split`丢弃的东西 。
Perl 5 中匹配 IPv4地址的正则如下:

```perl
/(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/
```

这在 Perl6中是无效的。首先，{} 块在 Perl 6 的 正则中是真正的代码块；它们包含 Perl6 代码。第二，在 Perl 6 中请使用   `** N..M` (或 `** N..*`)  代替 `{N,M}`

在 Perl 6 中匹配1到3位数字的正则如下:

```perl
/\d ** 1..3/
```

匹配 Ipv4地址：

```perl
/(\d**1..3) \. (\d**1..3) \. (\d**1..3) \. (\d**1..3)/
```

那仍有点笨拙。在Perl6的正则中，你可以使用重复操作符 % ，下面是重复 (\d ** 1..3) 这个正则 4次，并使用 . 点号 作为分隔符。

```perl
/ (\d ** 1..3) ** 4 % '.' /
```

% 操作符是一个量词修饰符，所以它只跟在一个像 * 或 + 或 ** 的量词后面。 上面的正则意思是 匹配 4 组数字，在每组数字间插入一个直接量 点号 .
你也可能注意到 `\.` 变成了 `'.'` ,它们是一样的。

```perl
$_ = "Go 127.0.0.1, I said! He went to 173.194.32.32.";

say .Str for m:g/ (\d ** 1..3) ** 4 % '.' /;
# output: 127.0.0.1 173.194.32.32
```

或者我们可以使用 .comb:

```perl
$_ = "Go 127.0.0.1, I said! He went to 173.194.32.32.";
my @ip4addrs = .comb(/ (\d ** 1..3) ** 4 % '.' /);   # 127.0.0.1 173.194.32.32
```

如果我们对单独的数字感兴趣：

```perl
$_ = "Go 127.0.0.1, I said! He went to 173.194.32.32.";
say .list>>.Str.perl for m:g/ (\d ** 1..3) ** 4 % '.' /;
# output: ("127", "0", "0", "1") ("173", "194", "32", "32")
```


## 引号

在很多地方，Perl6 都提供给你更合理的默认设置以便在大多数情况下让你的工作变得更简单有趣。引号也不例外。
基础

最常见的两种引号就是单引号和双引号。单引号最简单：让你引起一个字符串。唯一的“魔法”就是你可以用反斜杠转义一个单引号。而因为反斜杠的这个作用，你可以用 `\\` 来表示反斜杠本身了。不过其实这个做法也是没必要的，反斜杠自己可以直接传递。下面是一组例子：

```perl
> say 'Everybody loves Magical Trevor’;
Everybody loves Magical Trevor
> say 'Oh wow, it\'s backslashed!’;
Oh wow, it's backslashed!
> say 'You can include a \\ like this’;
You can include a \ like this
> say 'Nothing like \n is available’;
Nothing like \n is available
> say 'And a \ on its own is no problem’;
And a \ on its own is no problem
```

双引号，额，从字面上看就知道了，两倍自然更强大了。:-) 它支持反斜杠转义，但更重要的是他支持`内插`。也就是说`变量`和`闭包`可以放进双引号里。大大的帮你节约使用连接操作符或者字符串格式定义等等的时间。下面是几个简单的例子：

```perl
> say "Ooh look!\nLine breaks!"
Ooh look!
Line breaks!
> my $who = 'Ninochka'; say "Hello, dear $who"
Hello, dear Ninochka
> say "Hello, { prompt 'Enter your name: ' }!"
Enter your name: _Jonathan_
Hello, Jonathan!
```

(that is, an array or hash subscript, parentheses to make an invocation, or a method call) 上面第二个例子展示了标量内插，第三个则展示了闭包也可以插入双引号字符串里。闭包产生的值会被字符串化然后插入字符串中。那除了 `$` 开头的呢？ 规则是这样的：所有的都可以插入，但前提是它们被某些后置框缀(译者注：postcircumfix)(也就是带下标或者扩的数组或者哈希，可以做引用或者方法调用)允许。事实上你也可以把他们都存进标量里。


```perl
> my @beer = <Chimay Hobgoblin Yeti>;
Chimay Hobgoblin Yeti
> say "First up, a @beer[0]"
First up, a Chimay
> say "Then @beer[1,2].join(' and ')!"
Then Hobgoblin and Yeti!
> say "Tu je &prompt('Ktore pivo chces? ')"
Ktore pivo chces? _Starobrno_
Tu je Starobrno
```

这里你看到了一个数组元素的内插，一个被调用了方法的数组切片的内插和一个函数调用的内插。后置框缀规则意味着我们再也不会砸掉你口年的邮箱地址了(译者注：邮箱地址里有@号)。


```perl
> say "Please spam me at blackhole@jnthn.net"
Please spam me at blackhole@jnthn.net
```


选择你自己的分隔符

单/双引号对大多数情况下都很好用，不过如果你想在字符串里使用这些引号的时候咋办？继续用反斜杠不是什么好主意。其实你可以自定义其他字符做为引号字符。Perl6 替你选好了。q和qq引号结构后面紧跟的字符就会被作为分隔符。如果这个字符有相对应的关闭符，那么就自动查找这个（比如，如果你用了一个开启花括号{，那么字符串就会在闭合花括号}处结束。注意你还可以使用多字符开启符和闭合符（不过要求是相同字符重复组成的多字符））。另外，q的语义等同于单引号，qq的语义等同于双引号。


```perl
> say q{C'est la vie}
C'est la vie
> say q{{Unmatched } and { are { OK } in { here}}
Unmatched } and { are { OK } in { here
> say qq!Lottery results: {(1..49).roll(6).sort}!
Lottery results: 12 13 26 34 36 46
```


定界符(Heredoc)

所有的引号结构都允许你包含多行内容。不过，还有更好的办法：定界文档。还是用 q 或者 qq 开始，然后跟上 :to 副词来定义我们期望在文本最后某行匹配的字符。让我们通过下面这个感人的故事看看它是怎么工作的。


```perl
print q:to/THE END/
    Once upon a time, there was a pub. The pub had
    lots of awesome beer. One day, a Perl workshop
    was held near to the pub. The hackers drank
    the pub dry. The pub owner could finally afford
    a vacation.
    THE END
```


脚本的输出如下：
Once upon a time, there was a pub. The pub had
lots of awesome beer. One day, a Perl workshop
was held near to the pub. The hackers drank
the pub dry. The pub owner could finally afford
a vacation.

注意输出文本并没有像源程序那样缩进。定界符会自动清楚缩进到终端的级别。如果我们用 qq ，我们也可以往定界符里插入东西。注意这些都是通过字符串的 ident 方法实现的，但是如果你的字符串里没有内插，我们会在编译期的时候调用 ident 作为一种优化手段。
你同样可以有多个定界符，包括调用定界符里的数据的方法也是可以的（注意下面的程序就调用了 lines 方法）。


```perl
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
```


这个程序输出是：
Found beer
Didn't find masak
Found vacation
Didn't find whisky


自定义引号结构的引号副词

单/双引号的语义，也是 q 和 qq 的语义，已经可以解决绝大多数情况了。不过如果你有这么种情况：你要输出内插闭包而不是标量怎么办？这时候就要用上引号副词了。它们决定你是否开启引号特性。下面是例子：


```perl
> say qq:!s"It costs $10 to {<eat nom>.pick} here."
It costs $10 to eat here.
```

这里我们使用了 qq 语义，但是关闭里标量内插，这意味着我们可以放心往里写价钱而不用担心他会试图解析成上一次正则匹配的第十一个捕获值。注意这里使用的标准的冒号对( colonpair )语法。如果你希望从一个最基础的引号结构开始，然后自己手动的一个个打开选项，那么你应该使用 Q 结构。


```perl
> say Q{$*OS\n&sin(3)}
$*OS\n&sin(3)
> say Q:s{$*OS\n&sin(3)}
MSWin32\n&sin(3)
> say Q:s:b{$*OS\n&sin(3)}
MSWin32
&sin(3)
> say Q:s:b:f{$*OS\n&sin(3)}
MSWin32
0.141120008059867
```


这里我们用了无特性引号结构，然后打开附加特性，地一个是标量内插，然后是反斜杠转义，然后函数内插。注意我们同样可以选择自己希望的任何分隔符。
引号结构是一门语言

最后，值得一提的是：当解析器进入引号结构的时候，其实他是切换成解析另外一个语言了。当我们用副词构建引号结构的时候，他只不过是把这些额外的角色混合进基础的引号语言里来开启额外的特性。好奇的童鞋可以看这里： Rakudo 怎么做到的。而当我们碰到闭包或者其他内插的时候，解析器再临时切换回主语言。所以你可以这样写：


```perl
> say "Hello, { prompt "Enter your name: " }!"
Enter your name: Jonathan
Hello, Jonathan!
```

解析器不会困惑于内插的闭包里又带有其他双引号字符串的问题。因为我们解析主语言，然后切换到引号语言，然后返回主语言，然后重新再返回引号语言来解析这个程序里的字符串里的闭包里的字符串。这就是 Perl6 解析器送给我们的圣诞节礼物，俄罗斯套娃娃。

# 2013
## Heredocs, Theredocs, Everywheredocs docs

So let’s say you’ve got a bit of documentation to print out, a help statement perhaps. You could use an ordinary string, but it always looks like something you really shouldn’t be doing.

```perl
sub USAGE {
    say "foobar Usage:
./foobar <args> <file>

Options:

...
";
}
```

Perl 6 has a much better idea for you, fortunately: heredocs! They work a bit differently from Perl 5, and are now invoked using the adverb :heredoc on quoting constructs:

```perl
say q:heredoc/END/;
Hello world!
END
```

When you use :heredoc, the contents of the string are no longer the final contents; they become the string that signifies the end of a heredoc. q"END" results in the string "END", q:heredoc"END"results in everything before the next END to appear on its own line.
You will have also noticed that heredocs only start on the next possible line for them to start, not immediately after the construct closes. That semicolon after the construct never gets picked up as part of a heredoc, don’t worry :) .
The :heredoc adverb is nice, but it seems a bit long, doesn’t it? Luckily it has a short form, :to, which is much more commonly used. So that’s what we’ll be using through the rest of the post.


```perl
say q:to"FIN";
Hello again.
FIN
```


You can use any sort of string for the delimiter, so long as there’s no leading whitespace in it. A null delimiter (q:to//) is fine too, it just means you end the heredoc with two newlines, effectively a blank line.
And yes, delimiters need to be on their own line. This heredoc never ends:


```perl
say q:to"noend";
HELLO WORLD noend
```

A note about indentation: look at this heredoc


```perl
say q:to[finished];
  Hello there
    everybody
finished
```


Which of those three heredoc lines decides how much whitespace is removed from the beginning of each line (and thus sets the base level of indentation)? It’s the line with the end delimiter, “finished” in the last example. Lines with more indentation than the delimiter will appear indented by however much extra space they use, and lines with less indentation will be as indented as the delimiter, with a warning about the issue.
(Tabs are considered to be 8 spaces long, unless you change $?TABSTOP. This usually doesn’t matter unless you mix spaces and tabs for indentation anyway though.)
It doesn’t matter how much the delimiter indentation is, all that matters is indentation relative to the delimiter. So these are all the same:


```perl
say q:to/END/;
HELLO
  WORLD
END
```


```perl
say q:to/END/;
    HELLO
      WORLD
    END
```


```perl
say q:to/END/;
               HELLO
                 WORLD
               END
```

One other thing to note is that what quoting construct you use will affect how the heredoc contents are parsed, so

```perl
say q:to/EOF/;
$dlrs dollars and {$cnts} cents.
EOF
```

Interpolates nothing,


```perl
say q:to:c/EOF/;
$dlrs dollars and {$cnts} cents.
EOF
```

Interpolates just `{$cnts}` (the :c adverb allows for interpolation of just closures), and


```perl
say qq:to/EOF/;
$dlrs dollars and {$cnts} cents.
EOF
```

Interpolates both `$dlrs` and `{$cnts}`.
Here’s the coolest part of heredocs: using more than one at once! It’s easy too, just use more than one heredoc quoting construct on the line!


```perl
say q:to/end1/, qq:to/end2/, Q:to/end3/;
This is q.\\Only some backslashes work though\t.
$sigils don't interpolate either.
end1
This is qq. I can $interpolate-sigils as well as \\ and \t.
Neat, yes?
end2
This is Q. I can do \\ no \t such $things.
end3
```


Which, assuming you’ve defined $interpolate-sigils to hold the string "INTERPOLATE SIGILS", prints out

```perl
    This is q.\Only some backslashes work though\t.
    $sigils don't interpolate either.
    This is qq. I can INTERPOLATE SIGILS as well as \ and   .
    Neat, yes?
    This is Q. I can do \\ no \t such $things.
```

After every end delimiter, the next heredoc to look for its contents starts.
Of course, indentation of different heredocs will help whenever you have to stack a bunch of them like this.


```perl
say qq:to/ONE/, qq:to/TWO/, qq:to/THREE/, qq:to/ONE/;
The first one.
ONE
    The second one.
    TWO
The third one.
THREE
    The fourth one.
    ONE
```


Which outputs:

```perl
    The first one.
    The second one.
    The third one.
    The fourth one.
```

(And yes, you don’t have to come up with a unique end delimiter every time. That could have been four `q:to/EOF/` statements and it’d still work.)
One final note you should be aware of when it comes to heredocs. Like the rest of Perl 6 (barring a couple of small exceptions), heredocs are read using one-pass parsing (this means your Perl 6 interpreter won’t re-read or skip ahead to better understand the code you wrote). For heredocs this means Perl 6 will just wait for a newline to start reading heredoc data, instead of looking ahead to try and find the heredoc.
As long as the heredoc contents and the statement that introduces the heredoc are part of the same compilation unit, everything’s fine. In addition to what you’ve seen so far, you can even do stuff like this:


```perl
sub all-info { return q:to/END/ }

This is a lot of important information,
and it is carefully formatted.
END
```


(If you didn’t put the brace on the same line, it would be part of the heredoc, and then you’d need another brace on a line afterEND.)
However, things like BEGIN blocks start compiling before normal code, so trying that last one with BEGIN block fails:



```perl
BEGIN { say q:to/END/ }
This is only the BEGINning.
END
```


You have to put the heredoc inside the BEGIN block, with the quoting construct, in order to place them in the same compilation unit.


```perl
BEGIN {
    say q:to/END/;
    This is only the BEGINning.
    END
}
```

That’s it for heredocs! When should you use them? I would say whenever you need to type a literal newline (by hitting Enter) into the string. Help output from the USAGE sub is probably the most common case. The one at the beginning could easily (and more readably) be written as


```perl
sub USAGE {
    say q:to"EOHELP";
        foobar Usage:
        ./foobar <args> <file>

        Options:

        ...
        EOHELP
}
```

## Parsing and generating recurring dates
By Moritz
There are a lot of events that are scheduled on particular days of the week each month, for example the regular Windows Patch Day on the second Tuesday of each month, or in Perl 6 land that Rakudo Perl 6 compiler release, which is scheduled for two days after the Parrot release day, which again is scheduled for the third Tuesday of the month.
So let's write something that calculates those dates.
The specification format I have chosen looks like 3rd tue + 2 for the Rakudo release date, that is, two days after the 3rd Tuesday of each month (note that this isn't always the same as the 3rd Thursday).
Parsing it isn't hard with a simple grammar:


```perl
grammar DateSpec::Grammar {
    rule TOP {
        [<count><.quant>?]?
        <day-of-week>
        [<sign>? <offset=count>]?
    }
    token count { \d+ }
    token quant { st | nd | rd | th }
    token day-of-week { :i
        [ mon | tue | wed | thu | fri | sat | sun ]
    }
    token sign { '+' | '-' }
}
```

As you can see, everything except the day of the week is optional, so sun would simply be the first Sunday of the month, and 2 sun - 1 the Saturday before the second Sunday of the month.
Now it's time to actually turn this specification into a data structure that does something useful. And for that, a class wouldn't be a bad choice:


```perl
my %dow = (mon => 1, tue => 2, wed => 3, thu => 4,
        fri => 5, sat => 6, sun => 7);

class DateSpec {
    has $.day-of-week;
    has $.count;
    has $.offset;

    multi method new(Str $s) {
        my $m = DateSpec::Grammar.parse($s);
        die "Invalid date specification '$s'\n" unless $m;
        self.bless(
            :day-of-week(%dow{lc $m<day-of-week>}),
            :count($m<count> ?? +$m<count>[0] !! 1),
            :offset( ($m<sign> eq '-' ?? -1 !! 1)
                    * ($m<offset> ?? +$m<offset> !! 0)),
        );
    }
```

We only need three pieces of data from those date specification strings: the day of the week, whether the 1st, 2nd, 3rd. etc is wanted (here named $.count), and the offset. Extracting them is a wee bit fiddly, mostly because so many pieces of the grammar are optional, and because the grammar allows a space between the sign and the offset, which means we can't use the Perl 6 string-to-number conversion directly.
There is a cleaner but longer method of extracting the relevant data using an actions class.
The closing } is missing, because the class doesn't do anything useful yet, and that should be added. The most basic operation is to find the specified date in a given month. Since Perl 6 has no built-in type for months, we use a Date object where the .day is one, that is, a Date object for the first day of the month.

```perl
   method based-on(Date $d is copy where { .day == 1}) {
        ++$d until $d.day-of-week == $.day-of-week;
        $d += 7 * ($.count - 1) + $.offset;
        return $d;
    }
```

The algorithm is quite simple: Proceed to the next date (++$d) until the day of week matches, then advance as many weeks as needed, plus as many days as needed for the offset. Date objects support addition and subtraction of integers, and the integers are interpreted as number of days to add or subtract. Handy, and exactly what we need here. (The API is blatantly copied from theDate::Simple Perl 5 module).
Another handy convenience method to implement is next, which returns the next date matching the specification, on or after a reference date.


```perl
    method next(Date $d = Date.today) {
        my $month-start = $d.truncated-to(month);
        my $candidate   = $.based-on($month-start);
        if $candidate ge $d {
            return $candidate;
        }
        else {
            return $.based-on($month-start + $month-start.days-in-month);
        }
    }
}
```

Again there's no rocket science involved: try the date based on the month of $d, and if that's before $d, try again, but with the next month as base.
Time to close the class :-).
So, when is the next Rakudo release? And the next Rakudo release after Christmas?


```perl
my $spec = DateSpec.new('3rd Tue + 2');
say $spec.next;
say $spec.next(Date.new(2013, 12, 25));
```

Output:
2013-12-19
2014-01-23

The code works fine on Rakudo with both the Parrot and the JVM backend.
Happy recurring hollidates!

## Hashes and pairs

Hashes are nice. They can work as a kind of “poor man’s objects” when creating a class seems like just too much ceremony for the occasion.

```perl
my $employee = {
    name => 'Fred',
    age => 51,
    skills => <sweeping accounting barking>,
};
```

花括号可以省略:

```perl
my %employee =
    name => 'Fred',
    age => 51,
    skills => <sweeping accounting barking>,
;
```

散列的最后一项的末尾可以添加一个逗号。
Hashes make great “configuration objects”, too. You want to pass some options into a routine somewhere, but the options (for reasons of future compatibility, perhaps) need to be an open set.


```perl
my %options =
    rpm => 440,
    duration => 60,
;
$centrifuge.start(%options);
```


Actually, we have two options with that last line. Either we pass in the whole hash like that, and the method in the centrifuge class will need to look like this:


```perl
method start(%options) {
    # probably need to start by unpacking options here
    # ...
}
```

Or we decide to “gut” the hash as we pass it in, effectively turning it into a bunch of named arguments:

```perl
$centrifuge.start( |%options );  # means :rpm(440), :duration(60)
```


强制参数


```perl
method start(:$rpm!, :$duration!) {
    # ...
}
```

(In this case, we probably want to put in those exclamation marks, to make those named parameters obligatory. Unless we’re fine with providing some of them with a default, such as `:$duration = 120`.)

前缀操作符 `prefix:<|>` 其实叫做“展开” 或 “插值”。 在 Perl 6 中， 数组被展开为位置参数，散列被展开为命名参数。


```perl
my @args = "Would you like fries with that?", 15, 5;
say substr(|@args);    # fries

my %details = :year(1969), :month(7), :day(16),
              :hour(20),     :minute(17);
my $moonlanding = DateTime.new( |%details );
```

Perl 6 散列的项真的很像命名参数。当然它们不是， 它们只是散列中的键和值。但确实太像了。我们有 2 种语法来写一个散列的项。 一个是 胖箭头 语法：


```perl
my %opts = blackberries => 42;
```

一个是命名参数语法：

```perl
my %opts = :blackberries(42);
```

他们俩各有千秋。 后者比较 nice 的是它能够混合变量：


```perl
my $blackberries = 42;
my %opts = :$blackberries;   # 等价于  :blackberries($blackberries)
```

如果不重复单词 blackberries，使用 胖箭头语法就做不到了。

所以散列的项（一个键+一个键值）在 Perl 6 中变的更像一个东西。
在 Perl 6 中， 通过使用  `:blackberries(42)` 语法 或  `:$blackberries` 语法，让散列的项更突出。不仅如此， 把散列传递到子例程中时也是一项一项传递烦人，这让项更加突出。
最后，我们妥协了，意识到这样一串散列的项可以作为一个单位， 所以我们给它一个名字叫 Pair。散列是由一串串 Pair 对象（无序的）组成的。
所以，

```perl
say %employee.elems;
```

打印出 “3″… 这就是散列 `%employee` 中 Pair 对象的数量。

But in the end, Pair objects even turn out to have a sort of independent existence, graduating from their role as hash constituents. For, example, you can treat them as cons pairs and simulate Lisp lists with them:


```perl
my $lisp-list = 1 => 2 => 3 => Nil;  # it's nice that infix:<< => >> is right-associative
```


And then, as a final trick, let’s dynamically extend the Pair class to recognize arbitrary cadr-like method calls. (Note that.^add_fallback is not in the spec and currently Rakudo-only.)


```perl
Pair.^add_fallback(
    -> $, $name { $name ~~ /^c<[ad]>+r$/ },  # should we handle this? yes, if /^c<[ad]>+r$/
    -> $, $name {                            # if it turned out to be our job, this is what we do
        -> $p {
            $name ~~ /^c(<[ad]>*)(<[ad]>)r$/;        # split out last 'a' or 'd'
            my $r = $1 eq 'a' ?? $p.key !! $p.value;    # choose key or value
            $0 ?? $r."c{$0}r"() !! $r;                            # maybe recurse
        }
    }
);

$lisp-list.caddr.say;    # 3
```

Whee!

## Adverbly Adverby Adverbs

By Lueinc
两种创建Pair对象的方法：

```perl
my %h = debug => True;
```

还有一种是冒号记法

```perl
my %h = :debug(True);
```

今天，我会向你展示冒号记法是如何有用，Perl 6将它们用作主要的语言特性
什么是副词？
在自然语言中，副词没有动词与形容词的意思变化的明显。例如
The dog fetched the stick.                               # 狗叼回了棒子
仅仅是狗所做的表现。通过加上副词，例如:
The dog quickly fetched the stick.          # 狗很快地叼回了棒子
声明狗能在很短的时间完成这件事。副词能让变化很激烈，就像看到的：
This batch of cookies was chewy.                # 饼干很难嚼
This batch of cookies was oddly chewy.  # 饼干极其难嚼
第二个句子，使用副词 “oddly”，让你知道那饼干不是面包师的目标。Perl6中的副词表现的跟上面的任务很像，告诉函数和其它语言特性做它们想做的
副词基础
副词是使用冒号+副词的语法来表达的。通常，你将它们用作开关。
开启副词的方式就像这样：

```perl
:adverb
```

它和这一样：

```perl
:adverb(True)
```

关闭副词长这样：

```perl
:!adverb
```

它就像这样：

```perl
:adverb(False)
```

如果你传递的是字符串直接量，例如

```perl
:greet('Hello')
:person("$user")
```

你可以用下面的代替：

```perl
:greet<Hello>
:person«$user» or :person<<$user>>
```

只要字符串中没有空格（尖括号形式实际上创建一列项，用空格分隔）
你也可以缩写变量如果变量的名字和键的名字相同。

```perl
:foo($foo)
:$foo
```

如果你提供一个十进制数，有两种写法：

```perl
:th(4)
:4th
```

(The :4th form only works on quoting construct adverbs, like `m//`and `q[]`, in Rakudo at the moment.)
注意，副词的反义形式 (`:!adv`) 和 符号形式 (`:$foo`, `:@baz`) 不能给予值， 因为你已经给了它一个值了。


```perl
> my $foo = 'Fooo'; my $bar = 'Barrr';
Fooo
Barrr
> my %h = :$foo, :$bar;
bar => Barrr, foo => Fooo
> say %h<foo>;
Fooo
```


函数调用中的副词
函数调用中的副词用法更像具名参数，但仍计为副词。
下面是例子：


```perl
foo($z, :adverbly);
foo($z, :bar, :baz);
foo($z, :bar :baz);
```

每个副词都是一个具名参数，所以使用多个逗号分隔每个副词，就像分隔其它参数一样。注意你也可以像最后一个例子中一样，允许你叠加副词。
作用在操作符上的副词

副词能作用于操作符上，就像它们在函数中做的那样。它们优先级比项的赋值高，比条件的优先级低。
例子：


```perl
foo($z) :bar :baz  # 等价于 foo($z, :bar, :baz)
1 / 3 :round       # applies to /
$z & $y :adverb    # applies to &
```

When it comes to more complex cases, it’s helpful to remember that adverbs work similar to how an infix operator at that precedence level would (if it helps, think of the colon as a double bond in chemistry, binding both “sides” of the infix to the left-hand side). It operates on the loosest precedence operator no looser than adverbs.当情况复杂的时候， 记住副词与中缀操作符在那个优先级上的效果相似（如果有用，把冒号看作化学里面的双键（如H2C=CH2(乙烯)。碳原子与碳原子C=C以双键结合。）把中缀操作符的两侧绑定到左边）它作用于优先级最低（比副词优先级高）的操作符


```perl
1 || 2 && 3 :adv   # applies to ||
1 || (2 && 3 :adv) # applies to &&
!$foo.bar() :adv   # applies to !
!($foo.bar() :adv) # applies to .bar()
@a[0..2] :kv       # applies to []
1 + 2 - 3 :adv     # applies to -
1 ** 2 ** 3 :adv   # applies to the leftmost **
```

Notice that the behavior of adverbs on operators looser than adverbs is currently undefined.


```perl
1 || 2 and 3 :adv  # error ('and' too loose, applies to 3)
1 and 2 || 3 :adv  # applies to ||
```


作用在引号结构上的副词

各种引号那样的结构也通过副词改变行为。
(注意：这儿没有提供副词的详尽信息。 S02 和 S05 里面有更详细的介绍)
例如，让一个引号结构表现为单引号并插值闭包， 则你需要写成这样：


```perl
q:c 'Hello, $name. You have { +@msgs } messages.'
#  是的，字符 c 和 字符 ' 之间需要空格
```

这会输出：Hello, `$name`. You have 12 messages.
(这表明@msgs 数组有12个元素)
如果你想让双引号结构不插值标量，你会使用副词 :s 的反义形式 :!s

```perl
qq:!s ' ... etc ...'
```

正则 Regexes 允许你在 regex 外部使用副词之外， 还允许你在 regex 内部使用副词。在某些不能使用副词的情况下，内部副词允许你使用那些副词带来的功能。

```perl
$a ~~ m:i/HELLO/; # matches HELLO, hello, Hello ...
$a ~~ /:i HELLO/; # same
regex Greeting {
    :i HELLO
}                 # same
```

要记住的是作用在引号结构上的副词必须使用圆括号来传递值。这是因为，通常出现在副词后面的括号会被作为值传递给副词，这与你可以选择自己的引号括号的权利冲突了。

```perl
m:nth(5)// # OK
m:nth[5]// # Not OK
q:to(EOF)  # passing a value to :to, no delimiters found
q:to (EOF) # string delimited by ()
```


使用你自己的副词
所以你决定给你的函数添加你自己定义的副词。如果你记得的话，副词和具名参数基本上是一样的东西。所以，为了给你的函数创建副词，你仅仅只需要声明具名参数就好了：

```perl
sub root3($number, :$adverb1, :$adverb2) {
    # ... snip ...
}
```

给副词一个默认值就和位置参数一样，并且让某个副词必须出现，只需在副词名后面添加一个感叹号就好了：


```perl
sub root4($num, :$adv1 = 42, :$adv2, :$adv3!) {
    # default value of $adv1 is 42,
    # $adv2 is undefined (boolifies to False)
    # $adv3 must be supplied by the user
}
```

如果你想捕捉别人扔给你的所有副词，你可以使用 slurpy 散列：


```perl
sub root3($num, *%advs) {
    # %advs 包含所有传递给该函数的副词 :adverbs
    # that were passed to the function.
}
```

如果你在MAIN子例程定义了具名参数，它们会变成命令行选项！
操作符也是一样，因为操作符就是特殊语法的函数！
既然你已经学会了怎样把简陋的 Pair 应用到更多不止 Hashes 上面， 我希望你能在你的代码中快速使用它们， 并愉快地阅读剩下的 advent！

## Slicing with adverbs, the only way!

By Liztormato
在散列切片和数组切片中你能使用哪些副词呢？

```perl
名称	            描述
:exists	元素是否存在
:delete	移除元素，返回真，如果有元素被移除的话
:kv	            将键和值作为Parcel返回
:p	            return key(s) and value(s) as Parcel of Pairs
:k	          只返回键
:v	          只返回值
```


`:exists`
这个副词代替 `.exists`方法。 副词为散列和数组提供了统一的接口，可以一次检查多个元素。 .exists方法只允许一次检查单个键。
例子更有说服力。检查单个键是否存在：

```perl
$ perl6 -e 'my %h = a=>1, b=>2; say %h<a>:exists’
True
```

如果我们将这扩展到切片上，我们会得到一堆布尔值

```perl
$ perl6 -e 'my %h = a=>1, b=>2; say %h<a b c>:exists'
True True False
```

返回结果是 （Parcel）
注意，如果我们仅仅请求一个键，我们取回的是一个布尔值，不是一个只含一个布尔值的Parcel.


```perl
$ perl6 -e 'my %h = a=>1, b=>2; say (%h<a>:exists).WHAT’
(Bool)
```

如果很清楚地知道我们是在处理多个键，或者在编译时不清楚我们仅仅处理单个键，我们得到 一个 Parcel：


```perl
$ perl6 -e 'my %h = a=>1, b=>2; say (%h<a b c>:exists).WHAT’
(Parcel)
$ perl6 -e 'my @a="a"; my %h = a=>1, b=>2; say (%h{@a}:exists).WHAT'
(Parcel)
```

有时，知道某些东西不存在更方便。你可以很方便的在副词前面前置一个 叹号 ! 来反转副词 ，无论如何，它们其实真的很像具名参数


```perl
$ perl6 -e 'my %h = a=>1, b=>2; say %h<c>:!exists'
True
```


`:delete`
只有这个副词能改变散列或数组，它代替的是 .delete方法

```perl
$ perl6 -e 'my %h = a=>1, b=>2; say %h<a>:delete; say %h.perl'
("b" => 2).hash
```

当然，你也可以删除切片


```perl
$ perl6 -e 'my %h = a=>1, b=>2; say %h<a b c>:delete; say %h.perl'
1 2 (Any)
().hash
```

注意对于一个不存在的值会返回 (Any)，如果你碰巧给定散列一个默认的值，它会长这样：

```perl
$ perl6 -e 'my %h is default(42) = a=>1, b=>2; say %h<a b c>:delete; say %h.perl'
1 2 42
().hash
```

像 `:exists` 一样，你可以反转 `:delete` 副词，但是没有太多意义。因为副词本质上是具名参数，你可以让:delete属性带条件参数。


```perl
$ perl6 -e 'my $really = True; my %h = a=>1, b=>2; say %h<a b c>:delete($really); say %h.perl'
1 2 (Any)
().hash
```

因为传递给副词的值是真的，删除才真正发生。然而，如果你传递一个假值：

```perl
$ perl6 -e ‘my $really; my %h = a=>1, b=>2; say %h<a b c>:delete($really); say %h.perl'
1 2 (Any)
("a" => 1, "b" => 2).hash
```

它没有删除。注意返回值没有变化。删除操作就没有执行。如果你使用子例程或方法处理一些常规的切片，这会很方便，并且，你想用一个可选参数表明切片是否也被删除：仅仅将参数传递为副词的参数！

:kv, :p, :k, :v
kv 属性返回键值对，  :p属性返回一对Parcel， :k 和 :v属性只返回键和值


```perl
$ perl6
> my %h = a => 1, b => 2;
("a” => 1, "b” => 2).hash
> %h<a>:kv
a 1
> %h<a>:p  # 注意:p 返回的是 Parcel
"a" => 1
> %h<a>:k
a
> %h<a>:v
1
```


注意下面返回值的不同

```perl
> %h<a b c>
1 2 (Any)
> %h<a b c>:v
1 2
```

因为 :v 属性起着过滤的作用，过滤掉 Any. 但是，有时候你不需要这种行为。反转那个属性就可以达到目的：


```perl
> %h<a b c>:k
a b
> %h<a b c>:!k
a b c
```


将副词组合在一块
你也可以将几个副词结合在一块作用到 散列或切片上。最有用的组合是用 :exist 和:delete中的一个或两个，结合 :kv, :p, :k, :v中的其中之一。一些例子，例如将散列中的切片放到另外一个散列中：


```perl
$ perl6 -e 'my %h = a=>1, b=>2; my %i = (%h<a c>:delete:p).list; say %h.perl; say %i.perl'  # delete返回删除的东西
("b” => 2).hash
("a” => 1).hash
```

下面返回的是删除掉的键：

```perl
$ perl6 -e 'my %h = a=>1, b=>2; say %h<a b c>:delete:k’
a b
```

数组不是散列
在数组中，元素的键是数组的索引，所以，显示数组中定义有值的元素的索引，我们可以使用 :k属性


```perl
$ perl6 -e 'my @a; @a[3] = 1; say @a[]:k'
3
```

或使用数组中的所有元素创建一个 Parcel：

```perl
$ perl6 -e 'my @a; @a[3] = 1; say @a[]:!k’
0 1 2 3
```

然而，从数组中删除一个元素，和把 Nil 赋值给它类似，所以它会返回它默认的值（通常是 (Any))

```perl
> my @a=^10;
0 1 2 3 4 5 6 7 8 9
$ perl6 -e 'my @a = ^10; @a[3]:delete; say @a[2,3,4]; say @a[2,3,4]:exists'
2 (Any) 4
True False True
```

如果我们给数组指定了默认值，结果会稍有不同：

```perl
$ perl6 -e 'my @a is default(42) = ^10; @a[3]:delete; say @a[2,3,4]; say @a[2,3,4]:exists'
2 42 4
True False True
```

所以，即使元素不存在了，它也能返回一个定义好的值

## A Grammar with duplicate checking

By Dwarring
今天的例子构建了一个 grammar 用于追踪打牌。一个或多个玩家， 每个玩家手上只有 5 张牌。每次发牌不允许有重复纸牌：

A simple Card Game Grammar
To start with, here’s the basic grammar (no duplicate checks yet):

```perl
grammar CardGame {

    rule TOP { ^ <deal> $ }

    rule deal {
        <hand>+ % ';'
    }

    rule hand  { [ <card> ]**5 }
    token card { <face><suit>  }

    proto token suit {*}
    token suit:sym<♥>  {<sym>}
    token suit:sym<♦>  {<sym>}
    token suit:sym<♣>  {<sym>}
    token suit:sym<♠>  {<sym>}

    token face {:i <[2..9]> | 10 | j | q | k | a }
}

say CardGame.parse("2♥ 5♥ 7♦ 8♣ 9♠");
say CardGame.parse("2♥ a♥ 7♦ 8♣ j♥");
```

最高阶层的 rule 包含一个 deal （发牌）。 deal 由一个或多个使用 ; 隔开的 hands（一手牌）组成。每手牌 hand 有 5 张纸牌。
每张纸牌由一个 face 和一个 suite 代表。face 有 A、J、Q、K 或 2-10. 后面跟着花色 suite：♥ (红心) ♦ (方块) ♣ (梅花) or ♠ (黑桃)。
[我们可以使用纸牌字符， Unicode 6.0新引入的，但是还未被广泛支持]
不出所料，第一茬 grammar 能就解析任意手牌：

```perl
say CardGame.parse("a♥ a♥ 7♦ 8♣ j♥");
# 一手, duplicate a♥
say CardGame.parse("a♥ 7♥ 7♦ 8♣ j♥; 10♥ j♥ q♥ k♥ a♥");
# 两手, duplicate j♥
```

检测重复

我们开始给这个 grammar 添加一个 Perl 6变量申明。这将用于追踪纸牌：

```perl
rule deal {
    :my %*PLAYED = ();
    <hand>+ % ';'
}
```

这申明了 `%*PLAYED`。 '%*' twigil  表明那是一个散列， '*' 表明它是动态作用域的。
动态作用域不仅仅用于子例程和方法调用。它也能无缝地和 grammar rules、tokens和 actions 用在一起。
因为是动态作用域， `%*PLAYED`  对于 deal rule 的调用者是可见的； hand token 和它的调用者， card token。
%*PLAYED 对于任何随后被调用的 actions 也是可见的。所以通过为 card token 创建一个 action 我们能够追踪和报告重复：

```perl
class CardGame::Actions {
    method card($/) {
       my $card = $/.lc;
       say "Hey, there's an extra $card"
           if %*PLAYED{$card}++;
   }
}

my $a = CardGame::Actions.new;
say CardGame.parse("a♥ a♥ 7♦ 8♣ j♥", :actions($a));
# "Hey there's an extra a♥"
say CardGame.parse("a♥ 7♥ 7♦ 8♣ j♥; 10♥ j♥ q♥ k♥ a♦",
                   :actions($a));
# "Hey there's an extra j♥"
```

这可能就是所有用于追踪和报告重复的代码了。grammar 申明和 action 是分开的， 还有一个动态作用域的散列。

不接收重复
我们要求当出现重复时，让解析失败。把重复检查的 grammar 语法移动到里面就好了：

```perl
token card {<face><suit>
    <?{
        # only allow each card to appear once
        my $card = $/.lc;
        say "Hey, there's an extra $card"
            if %*PLAYED{$card};

        ! %*PLAYED{$card}++;
     }>
}
```

这在<?{ 和 }>  之间引入了一个断言. 当这段代码值为 True 时， rule 就成功， 当单次发牌同一张纸牌出现多于一次时card token 失败：


```perl
say CardGame.parse("2♥ 7♥ 2♦ 3♣ 3♦");
# legitimate, parses

say CardGame.parse("a♥ a♥ 7♦ 8♣ j♥");
# fails with message: Hey, there's an extra a♥

say CardGame.parse("a♥ 7♥ 7♦ 8♣ j♥; 10♥ j♥ q♥ k♥ a♦");
# fails with message: Hey, there's an extra j♥
```

## Unary Sort

By Moritz
在Perl5中按数值大小排序：


```perl
use v5;
my @sorted = sort { $a <=> $b } @values;
```

Perl6 提供类似的选择：


```perl
use v6;
my @sorted = sort { $^a <=> $^b }, @values;
```

主要区别在于，参数不是通过全局变量 `$a` 和 `$b` 来传递，而是作为 comparator的参数传递。 comparator 可以是任何能掉调用的东西,即具名或匿名的子例程或代码块。{ $^a <=> $^b}语法对于sort也不特殊，我仅仅用了占位变量来展示和Perl5 的相似之处。 下面的写法一样：


```perl
my @sorted = sort -> $a, $b { $a <=> $b }, @values;
my @sorted = sort * <=> *, @values;
my @sorted = sort &infix:«<=>», @values;
```


The first one is just another syntax for writing blocks, `* <=> *` use* to automatically curry an argument, and the final one directly refers to the routine that implements the <=> "space ship" operator (which does numeric comparison).


```perl
# 按照散列中定义的顺序排序单词:
my %rank = a => 5, b => 2, c => 10, d => 3;
say sort { %rank{$^a} <=> %rank{$^b} }, 'a'..'d';  # b d a c ,升序排列
 #          ^^^^^^^^^^     ^^^^^^^^^^  code duplication
```



```perl
# 不区分大小写排序
say sort { $^a.lc cmp $^b.lc }, @words;
 #          ^^^^^^     ^^^^^^  代码重复
```


因为我们酷爱便捷憎恨重复，Perl 6 提供了更短的方案：

```perl
# sort words by a sort order defined in a hash:
say sort { %rank{$_} }, 'a'..'d';

# sort case-insensitively
say sort { .lc }, @words;
```


sort足够聪明地知道代码块现在只有一个参数，并使用它将输入列表中的每个元素映射为新值。这与Schwartzian Transform很相似，但是很方便，因为它是内置的。所以，现在代码块起着转换者的角色，而非比较器。
如果你想按数字顺序比较，你可以强制元素在数字上下文中进行比较，使用 + 号：


```perl
my @sorted-numerically = sort +*, @list;
```

如果你想按相反的顺序比较数字，就使用 `-*` 代替好了。

# 2014

## Data munging in Perl 6 vs Perl 5

案例学习: 生成成绩报告单

```perl
example.txt
STDOUT
Peter	B
Celine	A-
Zsófia	B+
João	F
Maryam	B+
秀英	B-
Finn	D+
Aarav	A
Emma	F
Omar	B
```

输出报告单：


```perl
Zsófia's grade: B+
List of students with a failing grade:
  João, Emma
Distribution of grades by letter:
  A: 2 students
  B: 5 students
  D: 1 student
  F: 2 students
```

example.txt 是一个文本文件， 每行一个学生姓名和分数，中间用空格分割。
我们希望我们的脚本能解析这样的文件并打印含有如下信息的报告：

学生名为 “Zsófia”的成绩
所有不及格学生的名字 (i.e. worse than D-),
根据字母( 不带 +/- ) 把成绩分组。得到学生成绩的分布。
让我们一步步来：

Part 1: 样板

Perl 5


```perl
#!/usr/bin/env perluse warnings;
use strict;use feature 'say';
use utf8;
binmode STDOUT, ':utf8';
```

Perl 6


```perl
#!/usr/bin/env perl6
```

在 Perl 6 中所有这些都为我们做好了。

Part 2: 读取并解析输入

Perl 5


```perl
open my $fh, '<:utf8', "grades.txt"
    or die "Failed to open file: $!";
my %grade;
while (<$fh>) {
    m/^(\w+) \s+ ([A-F][+-]?)$/x
        or die "Can't parse line '$_'";
   $grade{$1} = $2;
};
```


Perl 6


```perl
my %grade = "grades.txt".IO.lines.map: {
   m:s/^(\w+) (<[A..F]><[+-]>?)$/
        or die "Can't parse line '$_'";
    ~$0 => ~$1
};
```

在 Perl 6 中， 对文件名字符串调用 .IO 方法会返回一个代表文件系统路径的对象， 我们可以继续在这个对象上调用  .lines 方法，得到文件的所有行的一个惰性列表。 “Lazy” 意味着它只会从磁盘中按需读取新行，当我们使用 .map 方法遍历列表元素的时候， 这样能使用单个赋值操作就能优雅地初始化一个散列。
我们不需要让文件句柄识别 Unicode ，也不用管文件句柄是否正确关闭， 这在 Perl 6 中都是默认发生的。
 .method: ... 语法也可以写为  .method(...),  前者使 map 看起来更像一个 block 语句，并减少了括号凌乱。
 :s (“sigspace”) 正则修饰符使解析 tokens 间的空白更优雅。 但 Perl 6 中的字符类比 Perl 5 复杂了一丢丢。
正则捕获结果变量($0, $1, …) 返回一个完整的  Match 对象 - 它为复杂使用场景增加了很多灵活性， 但是这里我们只想保留字符串， 所以使用 ~ 前置操作符字符串化了匹配对象。

Part 3: 查看数据的特定项

Perl 5


```perl
say "Zsófia's grade: $grade{Zsófia}";
```

Perl 6


```perl
say "Zsófia's grade: %grade<Zsófia>";
```

Perl 6 总是把散列中的 `{ }`  中的东西解析为表达式， 使用 `< >` 表示字面值。

Part 4: 过滤数据

Perl 5


```perl
say "List of students with a failing grade:";
say "  " . join ", ",  grep { $grade{$_} ge "E" } keys %grade;
```


Perl 6


```perl
say "List of students with a failing grade:";
say "  " ~ %grade.grep(*.value ge "E")».key.join(", ");
```

Perl 6 中允许我们按执行顺序把一些列方法写为链式操作。有一个重要区别：Perl 6 能让我们直接遍历散列的项， 散列中每一项都是一个 Pair 对象（Pair 对象能使用 .key 和.value 方法)。

The `*`   Whatever star 用于定义一个简单的回调，而不用写一个花括号块。
The `».` hyper operator 用于对 .grep 返回的 Pairs  的每个 Pair 上调用 一次 .key  方法，得出姓名列表

Part 5: 从数据中创建频率分布

Perl 5


```perl
say "Distribution of grades by letter:";
my %freq;
$freq{substr $grade{$_}, 0, 1}++ for keys %grade;
say "  $_: $freq{$_} student".($freq{$_} != 1 ? "s" : "")    for sort keys %freq;
```

Perl 6

```perl
say "Distribution of grades by letter:";
say "  {.key}: {+.value} student{"s" if .value != 1}"
    for %grade.classify(*.value.comb[0]).sort(*.key);
```

计数和分组实在太常见了， Perl 6 提供了 `.classify`  方法。
classify 方法里需要指定要分组的项（这里是 代表 `%grade` 条目的 Pair 对象 ）， 这些项应该根据什么规则进行分组（这里是根据第一个字母的值， 它代表分数（没有 +/-））。
这生成一个匿名的散列，散列的值是匿名数组。


```perl
%("B" => ["Peter" => "B", "Zsófia" => "B+", "Maryam" => "B+",
 "秀英" => "B-", "Omar" => "B"],  "A" => ["Celine" => "A-", "Aarav" => "A"],  "F" => ["João" => "F", "Emma" => "F"],  "D" => ["Finn" => "D+"])
```

因为我们只对每组元素的个数感兴趣， 我们使用 + 前置操作符数字化每个值然后打印它， 在数组前面添加 + 符号会得到数组元素的个数。
在 term 位置上一个 单独的 .method  方法等价于 `$_.method`,  意思是对当前循环变量调用该方法。
任意代码的返回值能使用花括号 {} 插值到字符串中。
if 语句能被用作表达式 - 当条件为 false 时，返回空列表，然后被字符串化为空字符串。
对字符串调用不带参数的 `.comb`  会生成该字符串的一个字符列表。
