# Day 16 – Quoting on Steroids

by liztormato

前些天,有一个关于字符串插值的博客. 博客中的大多数例子就使用了双引号字符串.
```perl
my $a = 42;
say "a = $a"; # a = 42
```
双引号字符串的价值已经很强大了. 但是归根结底, 它们只是叫做 Q 的更通用和可延伸性引用结构的特例.

Q结构的基本功能

最常用的形式里, Q 仅仅复制字符串, 而不更改字符串或插值
```perl
my $a = 42;
say Q/foo $a \n/; # foo $a \n
```
你可以添加副词到 Q[ ... ], 来改变字符串格式化的方式. 例如, 如果你想插值标量, 你可以添加 :s 在 Q 后面. 如果你想插值诸如 \n 之类的反斜线符号, 你可以添加 :b. 而且你可以合并它们:

```perl
my $a = 42;
say Q:s/foo $a\n/;   # foo 42\n
say Q:b/foo $a\n/;   # foo $a NL
say Q:s:b/foo $a\n/; # foo 42 NL
```

如果你想知道什么是 NL, 它其实就是 U+2424 符号, 意思是换行 .在你的浏览器里面应该包含一个字符 N 和 一个字符 L, 代表着换行.
事实上, 副词列表的基本功能如下:

    short       long            作用
    =====       ====            ===============
    :q          :single         插值 \\, \q and \' (or whatever)
    :s          :scalar         插值 $ vars
    :a          :array          插值 @ vars
    :h          :hash           插值 % vars
    :f          :function       插值 & calls
    :c          :closure        插值 {...} 表达式
    :b          :backslash      插值 \n, \t, etc. (implies :q at least)
	
 :q (:single) 等同于单引号语法. 
 如果你想在双引号字符串中开启冗长模式, 你可以这样写:
```perl
my $a = 42;
say Q :scalar :array :hash :function :closure :backslash /foo $a\n/; # foo 42 NL
```
当然, 你也可以指定副词的简写形式, 并且别用空格分隔它们. 所以, 如果你想看到更少的冗余:
```perl 
my $a = 42;
say Q:s:a:h:f:c:b/foo $a\n/; # foo 42  NL
```
对于任何副词(它就是具名参数,实际上) , 顺序无关紧要:
```perl
my $a = 42;
say Q:f:s:b:a:c:h/foo $a\n/; # foo 42 NL
```

认真地讲, 那仍很拗口. 所以提供了更短的形式: :qq

    short       long            作用
    =====       ====            ===============
    :qq         :double         Interpolate with :s, :a, :h, :f, :c, :b

所以,你能:
```perl
my $a = 42;
say Q:double/foo $a\n/; # foo 42␤
say Q:qq/foo $a\n/; # foo 42␤
```

Q:qq 其实就是 Q:s:a:h:f:c:b.

双引号里还有双引号呢? 对那些情况, Q:qq 形式也能用, 但仍然很啰嗦. 概要 2 因此指出:
实际上, 所有的 quote-like 形式来自于带有副词的Q结构:
    q//         Q:q//
    qq//        Q:qq//
这意味着我们可以把最后例子中的 Q:qq 缩短为 qq (并且能让双引号中还有双引号,而不会引起问题)
```perl
my $a = 42;
say qq/foo "$a"\n/; # foo "42"␤
```

q// 和 qq// 也支持(同样) 副词.  使用 q// 看起来最有用, 例如结合 :s , 也能在单引号中插值标量:
```perl
my $a = 42;
say q:s/foo "$a"\n/; # foo "42"\n
```
然而, 副词(就像命名参数) 只是 Pair 的简写形式: :s 其实是 s => True. 并且 :!s 其实是 s => False.
我们能把这应用到引号结构中吗? 答案是 : 可以, 你能! 

```perl
say qq:!s:!c/foo "$x{$y}"\n/; # foo "$x{$y}"␤
```
尽管我们指定了 qq// , 标量也没有被插值, 因为 :!s 副词. 并且 代码块没有被插值, 因为 :!c . 所以, 如果你想使用所有的引号功能, 除了一个或几个, 你可以反转那个副词来禁用那个功能

一些 Q 结构的高级功能

引用功能在这里并没有停止. 下表是一些 Rakudo Perl 6 中已经起作用的其他功能:

    short       long            功能
    =====       ====            ===============
    :x          :exec           作为命令执行并返回结果
    :w          :words          按单词分隔结果 (no quote protection)
    :ww         :quotewords     按单词分隔结果(with quote protection)
    :to         :heredoc        Parse result as heredoc terminator
	

qq:x// 可以简写为 qqx//
 插值并作为外部程序执行
```perl
my $w = 'World';
say qqx/echo Hello $w/; # Hello World
```
 作为单引号单词进行插值(请查看单引号发生了什么):
```perl
.say for qw/ foo bar 'first second' /;
```

    foo
    bar
    'first
    second'

 作为单引号单词进行插值. 这会确保平衡的引号会被看作一个整体(请再次查看单引号发生了什么):
```perl
.say for qww/ foo bar 'first second' /;
```
    foo
    bar
    first second

 插值变量到 heredoc:
```perl
my $a = 'world';
say qqto/FOO/;
  Hello $a
  FOO
```
    Hello world␤

文本会被自动扩展为跟目标字符串同样数量的缩进

## 结论

Perl 6 有一个非常强大的引用结构 Q[ ... ] , 从这儿派生出了其他引用结构. 还有一些副词还没有实现, 但是这儿提到的都能工作.

如果你想要进一步简写, 就定义一个 macro:

    macro qx { 'qq:x ' }          # equivalent to P5's qx//
    macro qTO { 'qq:x:w:to ' }    # qq:x:w:to//
    macro quote:<❰ ❱> ($text) { quasi { {{{$text}}}.quoteharder } }
