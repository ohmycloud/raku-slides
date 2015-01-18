

过去几年，我写过很多下面这种代码的变体：

my %words;
for slurp.comb(/\w+/).map(*.lc) -> $word {
    %words{$word}++;
}

(悄悄说： slurp.comb(/\w+/).map(*.lc) 是Perl的标准技巧之一。用来读取命令行指定的文件或者标准输入，逐个单词输入并改成小写。)

Perl6 引入了两种新的关联类型用来处理这类功能。 KeyBag 就是用来这种情况下作为 Hash 的替代品：

my %words := KeyBag.new;
for slurp.comb(/\w+/).map(*.lc) -> $word {
    %words{$word}++;
}

这种时候为什么会觉得 KeyBag 比 Hash 好呢，还多几个字母呢？嗯，因为他可以把你真需要的做的更好。如果你需要的是一个 Int 类型的值的 Hash ，它可以这样做：

> %words{"the"} = "green";
Unhandled exception: Cannot parse number: green

这是 Niecza 的错误；Rakudo 的稍微好看点，不过重点是出错了；Perl6 检查出来你违反了约定和投诉。

而且 KeyBag 还有更多的好办法。首先，虽然用四行代码来初始化 KeyBag 不是很麻烦，但是 Perl6 完全可以在单行内搞定：
my %words := KeyBag.new(slurp.comb(/\w+/).map(*.lc));

KeyBag.new 尽可能把传进来的存成一个 KeyBag 的值。传进来一个 List ，就把每个元素都加入 KeyBag ，这和前面代码块的结果是一样的。

如果 bag 一旦创建后你就不用再改动了，那你可以使用 Bag 代替 KeyBag 。不同点就是 Bag 不可变；如果 %words 是个 Bag ，那么 %words{$word}++ 是违法的。如果你的应用可以接受不可变，那么代码可以更紧凑成这样：
my %words := bag slurp.comb(/\w+/).map(*.lc);

bag 是一个协助子例程，其实就是在你给的内容上调用 Bag.new 。（我不清楚为什么没有相等的 keybag 子例程）

Bag 和 KeyBag 的好处可还有呢。他们还有自己专属的 .roll 和 .pick 方法，根据给定值权衡他们的结果：

> my $bag = bag "red" => 2, "blue" => 10;
> say $bag.roll(10);
> say $bag.pick(*).join(" ");
blue blue blue blue blue blue red blue red blue
blue red blue blue red blue blue blue blue blue blue blue

用普通的 Array 来模拟也不太难，不过这个版本会是：

> $bag = bag "red" => 20000000000000000001, "blue" => 100000000000000000000;
> say $bag.roll(10);
> say $bag.pick(10).join(" ");
blue blue blue blue red blue red blue blue blue
blue blue blue red blue blue blue red blue blue

所有标准的 Set 操作符都可以正常工作，不过他们还有点自己独有的。下面是示例：

sub MAIN($file1, $file2) {
    my $words1 = bag slurp($file1).comb(/\w+/).map(*.lc);
    my $words2 = set slurp($file2).comb(/\w+/).map(*.lc);
    my $unique = ($words1 (-) $words2);
    for $unique.list.sort({ -$words1{$_} })[^10] -> $word {
        say "$word: { $words1{$word} }";
    }
}

传进去两个文件名，从第一个文件的单词中生成一个 Bag ，第二个文件的单词中生成一个 Set ，然后用集合差异操作符 (-) 来计算哪些单词集合只在第一个文件里，然后根据出现的次序排序，打印前十个。

现在正好介绍 Set 。前面你可能猜测，它和 Bag 的工作模式应该很像。 Bag 是一个从 Any 具体到 Int 的 Hash ， Set 则是一个从 Any 具体到 Bool::True 的 Hash 。 Set 是不可变的。同样也有一个可变的 KeySet 。

在 Set 和 Bag 之间我们有着极丰富的一系列操作符： 操作符 Unicode “Texas” 结果类型
 is an element of ∈ (elem) Bool
 is not an element of ∉ !(elem) Bool
 contains ∋ (cont) Bool
 does not contain ∌ !(cont) Bool
 union ∪ (|) Set or Bag
 intersection ∩ (&) Set or Bag
 set difference (-) Set
 set symmetric difference (^) Set
 subset ⊆ (<=) Bool
 not a subset ⊈ !(<=) Bool
 proper subset ⊂ (<) Bool
 not a proper subset ⊄ !(<) Bool
 superset ⊇ (>=) Bool
 not a superset ⊉ !(>=) Bool
 proper superset ⊃ (>) Bool
 not a proper superset ⊅ !(>) Bool
 bag multiplication ⊍ (.) Bag
 bag addition ⊎ (+) Bag


大多数操作符都是一目了然的。返回 Set 的操作符会在操作之前改变他们的参数成 Set 。返回 Bag 的操作符会在操作之前把参数改成 Bag 。 Set 或者 Bag 都能返回的操作符则会在有参数是 Bag 或者 KeyBag 的适合改变参数成 Bag ，否则成 Set 。其他情况下原样不变。

注意在 Niecza 中集合操作符已经存在有段日子了。但是 Rakudo 里才刚刚加上，而且还只存在 Texas 的变体中。

解释 Bag 的不同并集/交集可能需要非典口舌。普通的并集操作符会选出在两个 bag 中任意一个的最大数目，而交集操作符找出最小的。Bag 添加操作符返回从任意一个 bag 中加入的数量。Bag 乘法给任意一个 bag 做乘法。（这里留个问题，最后一个操作符有什么实际用途 - 如果你知道，请告诉我们！）

> my $a = bag <a a a b b c>;
> my $b = bag <a b b b>;
 
> $a (|) $b;
bag("a" => 3, "b" => 3, "c" => 1)
 
> $a (&) $b;
bag("a" => 1, "b" => 2)
 
> $a (+) $b;
bag("a" => 4, "b" => 5, "c" => 1)
 
> $a (.) $b;
bag("a" => 3, "b" => 6)

我已经把文本中的全部例子和数据文件都放在了 Github 上。所有的例子都可以在 Github 上最新版的 Rakudo 上运行；我想除了 most-common-unique.pl 和 bag-union-demo.pl 其他的脚本应该也都能在最新的 Rakudo 正式版上运行。这两个脚本可以在 Niecza 上运行。如果运气还行的话，或许我能在接下来的几个小时内找到问题然后解决掉。

一个快速入门的例子，用来找出 Hamlet 里有而 Much_Ado_About_Nothing 里没有的 10 个 最常见的单词：

> perl6 bin/most-common-unique.pl data/Hamlet.txt data/Much_Ado_About_Nothing.txt
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

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2012/%E7%AC%AC%E5%8D%81%E4%B8%89%E5%A4%A9:%E8%A2%8B%E5%92%8C%E9%9B%86.markdown >  