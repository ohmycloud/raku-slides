第二天:用main函数控制命令行交互



2010 年 Perl6 圣诞月历(二)用 main 函数控制命令行交互

在 UNIX 环境下，很多脚本都是要从命令行里获取运行参数的。Perl6 上，实现这个相当简单~比如下面这样：

$ cat add.pl
    sub MAIN ($x, $y) {
        say $x + $y
    }
    $ perl6 add.pl 3 4
    7
    $ perl6 add.pl too many arguments
    Usage:
    add.pl x y

只要定义一个带命名变量的 MAIN 函数，你就可以获得一个命令行分析器。然后命令行参数就被自动绑定到 $x 和 $y 上了。如果不匹配，还有温馨的 Usage 提示~~

当然，你可能更喜欢自己定制 Usage 信息。那么自己动手，编写 USAGE 函数好了：

    $ cat add2.pl
    sub MAIN($x, $y) {
        say $x + $y
    }
    sub USAGE () {
        say "Usage: add.pl <num1> <num2>";
    }
    $ perl6 add2.pl too many arguments
    Usage: add.pl <num1> <num2>

更进一步的，你可以用 multi 指令声明多种 MAIN 函数以完成一种可替代的语法，或者根据某些常量做出不同反应，比如：

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

还有命名参数对应不同的选项的情况：

$ cat copy.pl
    sub MAIN($source, $target, Bool :$verbose) {
        say "Copying '$source' to '$target'" if $verbose;
        run "cp $source $target";
    }
    $ perl6 copy.pl calc calc2
    $ perl6 copy.pl  --verbose calc calc2
    Copying 'calc' to 'calc2'

这里申明变量 $verbose 类型为 Bool，也就是不接受赋值。如果没有这个类型约束的话，它是需要赋值的，就像下面这样：

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

总之，Perl6 提供了内置的命令行解析功能和使用帮助说明，你只要声明好函数就行了。

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2010/%E7%AC%AC%E4%BA%8C%E5%A4%A9:%E7%94%A8main%E5%87%BD%E6%95%B0%E6%8E%A7%E5%88%B6%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%BA%A4%E4%BA%92.markdown >  