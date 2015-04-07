

有一位智者曾经说过："程序必须是写给人读的，然后偶尔交给机器去执行而已。"但除了阅读，你的代码还可能被别人所使用，而他们并不打算搞明白你的代码到底做什么了。 这时候就需要文档了。

在Perl5里我们有POD，意思是"Plain Old Documentation(译者注：普通旧文档？感觉怪怪的，好在习惯直接说pod)"。在Perl6里 ，我们有Pod，不过这次可不是什么的简称了。Pod的规范这么写道："Perl6的Pod更加统一，更加紧凑，更富有表现力"。相比Perl5的POD，Pod有些 轻微的改动，但是绝大多数还是一样的，或者说至少是类似的。

Perl6里主要有三种Pod块类型。带分隔符的应该是最明显和简单的类型了：

=begin pod
 
=end pod

段落显得更神奇一点。他们以=for标记开始，以最近的空白航结束（就跟正常的段落一样）：

my $piece = 'of perl 6 code'
=for comment
Here we put whatever we want.
The compiler will not notice anyway.
our $perl6 = 'code continues';

简略跟段落类似。开头的=后面紧跟一个Pod标示符然后是简略的具体内容。嗯，听起来很熟悉吧：
=head1 Shoulders, Knees and Toes

没错，=head在Perl6里没啥特殊的，也就是说，你可以改写成段落的形式：

=for head1
Longer header
than we usually write.

甚至分隔符形式：

=begin head1
This header is longer than it should be
=end head1

实际上任何块都可以改写成分割符形式，段落和简略都行。当然不是所有的块都以=开头。=head跟普通的=pod是区别对待的。怎么做到的？当然是靠Pod渲染器，当 然也靠Perl6编译器本身。在Perl6里，Pod不再是二等公民了（意即程序编译时被忽略），Perl6里的Pod是程序的一部分，执行代码解析和构造抽象语法树 (abstract syntax tree)的时候编译器会一同给Pod块也构建一个AST。然后把这些存在特殊变量$=POD里，以便在运行期检查：

=begin pod
Some pod content
=end pod
say $=POD[0].content[0].content;

say这行看起来有有一点复杂。content的content的神马东东？这到底搞出神马来了？事实上是某些pod里的'content'，解析成普通的段落后，保 存成Pod::Block::Para对象。以=begin开头的分隔符块变成了Pod::Block::Named对象，这个对象包含了几个子对象，它也是上面例子 中的第一个块，也就是结束在了$=POS[0]。

你可能会想："靠，谁会用这么难看的格式啊"。别着急，其实我也不希望真有人这么直接使用AST的。这才是pod渲染器有用的地方呢。看看Pod::To::Text 的例子吧：

=begin pod
=head1 A Heading!
A paragraph! With many lines!
    An implicit code block!
    my $a = 5;
=item A list!
=item Of various things!
=end pod
DOC INIT {
    use Pod::To::Text;
    pod2text($=POD);
}

不过这段程序是没有输出的。因为DOC INIT代码块比较特殊，它和其他的INIT代码块一样运行，但是当-- doc标签传递给编译器的时候，就只有它还能运行了。让我们看看：

$ perl6 --doc foo.pl
   A Heading!
 
   A paragraph! With many lines!
 
       An implicit code block!
       my $a = 5;
 
    * A list!
 
    * Of various things!

其实，当代码里没有DOC INIT的时候，编译器也会生成一个默认的DOC INIT，也就是上面例子中的那个。所以你真的可以忽略这段代码，只在文件里保留Pod，然后perl6 --doc命令就会返回给你相同的结果了。 等等，还有更多的呢！

我说了有三种主要的类型，但是还有一种我之前一直没提。那就是声明。声明的目的就是给Perl6的实际对象做记录。上例子：

#= it's a sheep! really!
    class Sheep {
        #= produces a funny sound
        method bark {
            say "Actually, I don't think sheeps bark"
        }
    }

每个声明块都会附属在它后面的对象上。然后它会存在对象的.WHY属性里。我们可以这么使用它：

say Sheep.WHY.content;                      # it's a sheep! really!
say Sheep.^find_method('bark').WHY.content; # produces a funny sound

在这个情况下，我们也不必关心给我们想看的每一处文档都做一个^find方法。这是Pod::To::Text关心的。如果我们用-- doc参数运行上的代码，可以看到：

class Sheep: it's a sheep! really!
method bark: produces a funny sound

Perl6规范表示，有必要给所有类属性、方法和子例程的全部参数都提供文档。不幸的是，没哪个实现（至少是我知道的）真正做到了这点。

还有一些Pod特性这里没有讲的。比如格式化代码（<和>等）、表格等等。如果你感兴趣的话，可以看看 启示录第二十六节 。这就是用Pod6写完，然后用Pod::To::HTML渲染的。他描述的所有特性目前并没有全部实现，但是大多数已经没问题了。（ 可以参见下面的链接），而且有些模块已经用它来记录文档了（比如Term::ANSIColor模块）。

参考链接：

启示录第二十六节

Pod::To::Text模块源码

Term::ANSIColor模块文档

Pod测试套件（显示了在Rakudo上Pod能做到的）

最后，开开心心写文档~~

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2011/%E7%AC%AC%E5%8D%81%E5%A4%A9:%E6%96%87%E6%A1%A3%E5%8C%96Perl6.markdown >  