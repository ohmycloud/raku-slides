

受Jnthn之前关于Grammar::Debugger模块的文章的启发，我开始认真考虑实现一个简单的Perl6文法分析器的难度，好像其实并没有想象中那么困难 。

至于这个分析要达到的程度，我只想着简单统计一下每个规则被执行的次数以及累计的执行时间。我想到的接口是非常简单的---- 一个多重哈希，最外层是文法的名称，第二层是文法中每个规则的名字，最后是实际的执行时间。所以时间信息将会像这样来访问：

say "MyGrammar::MyRule was called " ~ %timing ~ "times";
say "and took " ~ %timing ~ " seconds to execute";

但是首先，我得先去搞明白jnthn的代码都做了些什么。

从外部看，基本办法就是用一个自定义的元对象取代正常的文法元对象，这个自定义元对象继承了正常对象的绝对多数行为。但是用自定义元对象取代正常元对象会返回一个例程 ，这个例程在调用原有的方法的同时收集时间信息。

在看 jnthn的代码 ，我发现如果方法名是以!开头，或者是'parse'、'CREATE'、'Bool'、'defined'或者'MATCH'，那我们直接返 回原版的方法不作任何修改。这让我们不跟踪私有方法或者顶多偶尔跟踪一些不是文法的一部分但是被文法所使用的那些方法。(译者注：原文but are used by it的主语未知，此处翻译存疑)在我的简单分析器里，我需要获取文法名称，这步只需要调用"my $grammar = $obj.WHAT.perl"，也就是说我需要在这个例外的列表里加上perl字段。否则只会得到一个无穷递归...

不管怎么说，对于这些不符合上述标准的方法名称，我们都需要返回一个自定义例程，用以累计时间和自增调用计数。看起来很简单，下面就是代码了(就是还没经过多少测试) ：

my %timing;
 
my class ProfiledGrammarHOW is Metamodel::GrammarHOW is Mu {
 
    method find_method($obj, $name) {
        my $meth := callsame;
        substr($name, 0, 1) eq '!' || $name eq any() ??
            $meth !!
            -> $c, |$args {
                my $grammar = $obj.WHAT.perl;
                %timing{$grammar} //= {};                   # 激活文法哈希
                %timing{$grammar}{$meth.name} //= {};       # 激活方法哈希
                my %t := %timing{$grammar}{$meth.name};
                my $start = now;                            # 获取开始时间
                my $result := $meth($obj, |$args);          # 调用原有方法
                %t += now - $start;                   # 累计执行时间
                %t++;
                $result
            }
    }
 
    method publish_method_cache($obj) {
        # 无缓存，所以都命中find_method了
    }
}
 
sub get-timing is export { %timing }
sub reset-timing is export { %timing = {} }
 
my module EXPORTHOW { }
EXPORTHOW.WHO. = ProfiledGrammarHOW;

如果上述代码保存在了一个叫"GrammarProfiler.pm"的文件里，那你使用的时候需要在所有做了文法声明的脚本开头添加"use GrammarProfiler;"。这样在你分析完文法后，可以调用get-timing()获得记录有每个规则执行时间的哈希，或者调用reset- timing()清除这个信息。

当然，一个更完整的分析器需要做的事情比这个多多了，也会提供更多的分析选项。但本文对于快速入门来说应该还是比较有用了

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2011/%E7%AC%AC%E4%B8%83%E5%A4%A9:%E5%B0%9D%E8%AF%95%E5%86%99%E4%B8%80%E4%B8%AA%E7%AE%80%E5%8D%95%E7%9A%84%E6%96%87%E6%B3%95%E5%88%86%E6%9E%90%E5%99%A8.markdown >  