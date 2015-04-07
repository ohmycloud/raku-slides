

Perl6 是在词法作用域上建立的。变量，子例程、常量甚至类型都会被词法先检查一遍。子例程只能在词法作用域里被查找。

所以它只适合从同一个词法作用域的模块里导入符号表。我经常写这样的代码：

use v6;
 
# 脚本的主函数
sub deduplicate(Str $s) {
    my %seen;
    $s.comb.grep({!%seen{ .lc }++}).join;
}
 
# 正常调用
multi MAIN($phrase) {
    say deduplicate($phrase)
}
 
# 如果你用 --test 参数调用脚本，它会运行单元测试
multi MAIN(Bool :$test!) {
    # imports &plan, &is etc. only into the lexical scope
    use Test;
    plan 2;
    is deduplicate('just some words'), 'just omewrd', 'basic deduplication';
    is deduplicate('Abcabd'), 'Abcd', 'case insensitivity';
}

这个脚本会删除命令行里除了第一次出现以外的所有字符：

$ perl6 deduplicate 'Duplicate character removal'
Duplicate hrmov

但是如果你用 --test 参数调用，它运行的是自己的单元测试：

$ perl6 deduplicate --test
1..2
ok 1 - basic deduplication
ok 2 - case insensitivity

因为测试函数只在部分程序里有需求 - 更精确的说是在词法作用域里 - use 语句是在作用域里面的，导入的符号表也被限制在这个作用域里。所以如果试图在例程外使用 Test 的 is 函数，你只会得到一个编译时报错。

你可能会问：“为什么？”。从程序员的角度看，它减少了（可能是意料之外没注意到的）名字冲突。同理，词法变量比全局变量也要安全一些。

从语言设计的角度看，词法导入、运行时不可变的词法作用域和子例程只在词法中查找三样结合起来，就允许在编译期解析子例程名字，也就可以做一些很优雅的事情，比如检测未声明函数的调用，编译期参数类型检查，以及其他各种优化等等。

不过子例程不过是冰山一角罢了。Perl6 的语法非常灵活，你可以修改自定义操作符和宏。这两者可以被导出，然后再导入到词法作用域。这意味着默认情况下，语言的修改也是词法下的。所以你可一安全的加载任何修改语言的扩展，不会碰上哪个库无法使用的危险 -- 库压根看不到语言的变化。

所以概括一下，词法导入就是封装的另一个体现。

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2012/%E7%AC%AC%E5%85%AD%E5%A4%A9:%E8%AF%8D%E6%B3%95%E5%AF%BC%E5%85%A5.markdown >  