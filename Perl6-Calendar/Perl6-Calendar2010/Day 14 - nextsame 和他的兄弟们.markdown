2010 年 Perl6 圣诞月历(十四) nextsame 和他的兄弟们

也许你已经很熟悉在 JAVA 中用关键字 super 来代表给基类的方法或者构造。Perl6 中也有类似的方法。不过在多重继承和混淆的世界里，叫它 super 的意义不大，所以我们叫它 —— nextsame 。看看下面的例子吧：

class A {
    method sing {
        say "life is but a dream.";
    }
}
&nbsp_place_holder;
class B is A {
    method sing {
        say ("merrily," xx 4).join(" ");
        nextsame;
    }
}
&nbsp_place_holder;
class C is B {
    method sing {
        say "row, row, row your boat,";
        say "gently down the stream.";
        nextsame;
    }
}

然后，当你调用 C.new.sing 的时候，我们的类继承结果如下：

row, row, row your boat,
gently down the stream.
merrily, merrily, merrily, merrily,
life is but a dream.

你现在知道 C.sing 是怎样一步步从 B.sing 到 A.sing 的了。这些转换当然就是由 nextsame 调用来的。嗯，你看，跟 java 的 super 很像吧~

除了继承链外， nextsame 在其他地方也能发挥作用。下面这个例子就不涉及面向对象：

sub bray {
    say "EE-I-EE-I-OO.";
}
&nbsp_place_holder;
# 啊，忘了加上第一行了~
&bray.wrap( {
    say "Old MacDonald had a farm,";
    nextsame;
} );
&nbsp_place_holder;
bray(); # Old MacDonald had a farm,
        # EE-I-EE-I-OO.

嗯，这就是另一个 nextsame 不叫 super 的原因了：它不一定要有基类，可以是无关基类的。相反，它还有一些更为普遍的现象。那是什么呢？

每次我们运行一个调用的时候，都要花费掉一点语言的运行时间用来确认调用应该怎样正确的运行。这个部分叫做 dispatcher (调度)。调度可以确保 multi 函数的调用恰当的工作：

multi foo(    $x) { say "Any argument" }
multi foo(Int $x) { say "Int argument" }
foo(42) # Int argument

(而且如果在 multi 的第二个子程序里继续用 nextsame 的话，又会再调度到第一个去——不过目前 Rakudo 还没实现这个……)

在Perl6 里，调度无处不在！调度参与方法调用的过程，这样方法可以顺延整个继承链，就像本文最上面的例子那样；调度包裹着子例程，这样别的代码可以调用被包裹的代码；调度还出现在 multi 调度里，以便相互调用……总之，调度的原则是一样的，只是表现形式不一样而已。

而 nextsame 就是一个很友好的跟你周围的调度器直接交谈的方式。对了，顺便说一下， nextsame 这个命名，是因为它指示调度器去顺延到下一个( next )有着相同( same )签名的候选人。它还有其他变种，比如，你可以用在混淆里：

class A {
    method foo { "OH HAI" }
}
&nbsp_place_holder;
role LogFoo {
    method foo {
        note ".foo was called";
        nextsame;
    }
}
&nbsp_place_holder;
my $logged_A = A.new but LogFoo;
&nbsp_place_holder;
say $logged_A.foo; # .foo was called
                   # OH HAI

我喜欢这种利用混淆来注入的做法。我曾经写过一篇 博文关于这个反面的 。jnthn 还写过 一个perl6模块 来利用它。

虽然这么酷，但是 nextsame 其实不是什么新奇玩意儿。事实上，它不过是顺着面向对象的调用链的调度器的另一个例子而已。因为在角色( role ) LogFoo 和 but 混合起来的时候，自动创建了一个匿名子类，一切和 LogFoo 一样。这样角色的 nextsame 其实还是归结到继承链上的 nextsame 了。（但是我在用它的时候，用不着多多了解它。只要它还是这么神奇和好用就行了）

总之， nextsame 可以在各种你希望它起作用的地方运行，而且实现的就是你想要的效果。它就是顺着去找下一个东东嘛~

嗯， nextsame 还有关系很近几个表兄弟：

nextsame Defer with the same arguments, don't return

callsame Defer with the same arguments, then return

nextwith($p1, $p2, …) Defer with these arguments, don't return

callwith($p1, $p2, …) Defer with these arguments, then return

一般情况下， nextsame 能用的地方，他们也都能用~~

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2010/%E7%AC%AC%E5%8D%81%E5%9B%9B%E5%A4%A9:nextsame%E5%92%8C%E4%BB%96%E7%9A%84%E5%85%84%E5%BC%9F%E4%BB%AC.markdown >  