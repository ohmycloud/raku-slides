第三天:Whatever实现布局管理器



简介

本文旨在展示 Whatever -- Perl6 众多有趣的玩意儿之一 -- 可以有助于轻松的实现和使用复杂的东西，比如说布局管理器。简单的说，布局管理器是图形界面的一部分，负责对象(比如窗口，部件)的空间布置。为了简单起见，本文实现的布局管理器会遵循以下三个规则：
there are only two kinds of widgets: terminal or container, the latter can contain other widgets of either kind;
只有两种部件：终端或者容器，后者可以包含其他各种类型的部件；
a widget cannot be overlapped, except for containers which fully contain their sub-widgets; and
部件不可以重叠，容纳子部件的容器除外；
only the height can be adjusted, this size can be either static, dynamic, or intentionally left unspecified.
只能调整高度，这个值你可以是静态的，动态的，或者留空。
用法

从用户角度来说，这个布局管理器的目的就是尽可能的简单易用。比如，指定下面这样一个从文本程序转换来的典型的接口绝对不能太难。在这个例子里，接口和 body 部件是容器，其他的都是终端：

接口 (X 行)
+----> +------------------------------------------+
|      | 菜单栏 (1 行)                            |  body (剩余空间)
|      +------------------------------------------+ <----+
|      | 子部件 1 (剩余空间的三分之一)            |      |
|      |                                          |      |
|      |                                          |      |
|      +------------------------------------------+      |
|      | 子部件 2 (剩余空间)                      |      |
|      |                                          |      |
|      |                                          |      |
|      |                                          |      |
|      |                                          |      |
|      |                                          |      |
|      +------------------------------------------+ <----+
|      | 状态栏 (1 行)                            |
+----> +------------------------------------------+

The user don't know what the remaining space is in advance because such an interface is arbitrary resizable. As a consequence it should be specified as a non-predefined value; this is where * — the Whatever object — comes in handy. This object is interesting for two reasons: 用户不需要知道剩余空间有多少，因为这个接口是可以任意调整大小的。所以它被制定为一个非预定义的值。这就是我们的 Whatever 对象派上用场的地方了。因为如下两个原因，whatever对象才变得如此有趣：
从用户角度出发，非静态大小的定义非常简单：子部件1(动态)就是* / 3，子部件2(未定义)就是*；
从开发者角度出发，Perl6 自动转换 $size = * / 3 成一个闭包： x -> x / 3 。然后可以像普通函数一样调用： $size($x) 。


这样，上面的GUI就可以翻译成下面几行代码：

my $interface =
    Widget.new(name => 'interface', size => $x, sub-widgets => (
        Widget.new(name => 'menu bar', size => 1),
        Widget.new(name => 'main part', size => *, sub-widgets => (
            Widget.new(name => 'subpart 1', size => * / 3),
            Widget.new(name => 'subpart 2', size => *))),
        Widget.new(name => 'status bar', size => 1))); 实现

终端部件的绘制非常简单，因为绝大多数工作都是容器的。他们负责计算剩余空间以及统一分发那些未定义大小的部件：

class Widget {
    has $.name;
    has $.size is rw;
    has Widget @.sub-widgets;
 
    method compute-layout($remaining-space? is copy, $unspecified-size? is copy) {
        $remaining-space //= $!size;
 
        if @!sub-widgets == 0 {  # Terminal
            my $computed-size = do given $!size {
                when Real     { $_                  };
                when Callable { .($remaining-space) };
                when Whatever { $unspecified-size   };
            }
 
            self.draw($computed-size);
        }
        else {  # Container
            my @static-sizes   =  grep Real,     @!sub-widgets».size;
            my @dynamic-sizes  =  grep Callable, @!sub-widgets».size;
            my $nb-unspecified = +grep Whatever, @!sub-widgets».size;
 
            $remaining-space -= [+] @static-sizes;
 
            $unspecified-size = ([-] $remaining-space, @dynamic-sizes».($remaining-space))
                                 / $nb-unspecified;
 
            .compute-layout($remaining-space, $unspecified-size) for @!sub-widgets;
        }
    }
 
    method draw(Real $size is copy) {
        "+{'-' x 25}+".say;
        "$!name ($size lines)".fmt("| %-23s |").say;
        "|{' ' x 25}|".say while --$size > 0;
    }
}

Here, any Callable object can be used to specify a dynamic size, as far as it takes the computed remaining space as argument. That means it is possible to specify more sophisticated dynamic size by passing a code Block. For example, { max(5, $^x / 3) } ensures the widget has a proportional size that can't decrease below 5. 这样，所有可以调用的对象都能用来指定一个动态大小，只要它带上计算好的剩余空间作为参数。这意味着我们可以通过传递代码块来指定更加复杂的动态大小。比如， { max(5, $^x / 3) } 可以保证部件有个成比例的大小，但最小又不会低于5。 结论

It's time to check if this trivial layout manager works correctly both in Rakudo and Niecza, the two most advanced implementations of Perl 6. The following test is rather simple, it creates and draws an interface, then resize it and draws it again: 现在是时候检查一下我们这个弱弱的布局管理器是否在 Perl6 两个最先进的实现 Rakudo 和 Niecza 上都能正常运行了。下面这个检测非常简单，创建并绘制一个接口，然后改变其大小重新绘制：

my $interface =
    Widget.new(name => 'interface', size => 11, sub-widgets => (
        Widget.new(name => 'menu bar', size => 1),
        Widget.new(name => 'main part', size => *, sub-widgets => (
            Widget.new(name => 'subpart 1', size => * / 3),
            Widget.new(name => 'subpart 2', size => *))),
        Widget.new(name => 'status bar', size => 1)));
 
$interface.compute-layout;  # 绘制
$interface.size += 3;       # 调整
$interface.compute-layout;  # 重新绘制

调整大小前后的结果分别如下。和最开先的很类似吧～

+-------------------------+            +-------------------------+
| 菜单栏 (1 lines)        |            | 菜单栏 (1 lines)        |
+-------------------------+            +-------------------------+
| 子部件 1 (3 lines)      |            | 子部件 1 (4 lines)      |
|                         |            |                         |
|                         |            |                         |
+-------------------------+            |                         |
| 子部件 2 (6 lines)      |            +-------------------------+
|                         |            | 子部件 2 (8 lines)      |
|                         |            |                         |
|                         |            |                         |
|                         |            |                         |
|                         |            |                         |
+-------------------------+            |                         |
| 状态栏 (1 lines)        |            |                         |
                                       |                         |
                                       +-------------------------+
                                       | 状态栏 (1 lines)        |

最后，像这么灵活的程序在 Perl6 里实现起来是非常简单的：语言核心里已经把一切都准备好了。显然这个简单的布局管理器还不完善，像健康检查，多维度等一大把东西都是缺失的。不过这些正好留给读者，呼呼～有什么问题或者评论，欢迎来IRC(#perl6 freenode)。 额外附赠

像前面看到的， $!size 可以是 Whatever，但不会是你想要的任何(whatever)东西。比如一个负的真或一个不正确的字符串。再强调一次， Perl6 提供了一个简单而强大的特性：约束类型。简单说就是你可以通过一组约束定义一个新的类型：

subset PosReal of Real where * >= 0;
subset Size where {   .does(PosReal)
                   or .does(Callable) and .signature ~~ :(PosReal --> PosReal)
                   or .does(Whatever) };
has Size $.size is rw;

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2012/%E7%AC%AC%E4%B8%89%E5%A4%A9:Whatever%E5%AE%9E%E7%8E%B0%E5%B8%83%E5%B1%80%E7%AE%A1%E7%90%86%E5%99%A8.markdown >  