Day 13 – Bags and Sets December 13, 2012


过去几年，我写了很多这种代码的变种：

 my %words;
 for slurp .comb (/\w+/).map( * .lc) -> $word {
      %words{$word}++;
 }


(此外:  slurp.comb(/\w+/).map(*.lc)  从指定的标准输入或命令行读取文件，遍历数据中的单词，然后小写化该单词。 eg ： perl6 slurp.pl score.txt)

Perl6引入了两种新的组合类型来实现这种功能。 在这种情况下，半路杀出个KeyBag 代替了 hash:  

 my %words := KeyBag.new;
 for slurp.comb(/\w+/).map(*.lc) -> $word {
      %words{$word}++;
 }


这种情况下，为什么你会喜欢 KeyBag多于 散列呢，难道是前者代码更多吗？很好，如果你想要的是一个正整数值的散列的话，KeyBag 将更好地表达出你的意思。

 > %words{"the"} = "green";
 未处理过的异常：不能解析数字：green


然而KeyBag有几条锦囊妙计。首先，四行代码初始化你的 KeyBag 不是很罗嗦，但是Perl 6能让它全部写在一行也不会有问题：

 my %words := KeyBag.new(slurp.comb(/\w+/).map(*.lc));


KeyBag.new  尽力把放到它里面的东西变成KeyBag的内容。给出一个列表，列表中的每个元素都会被添加到 KeyBag 中，结果和之前的代码块是完全一样的。

如果你不需要在创建bag后去修改它，你可以使用 Bag 来代替 KeyBag。不同之处是 Bag 是 不会改变 的；如果 %words 是一个 Bag，则 %words{$word}++ 是非法的。如果对你的程序来说，不变没有问题的话，那你可以让代码更紧凑。

my %words := bag slurp.comb(/\w+/).map(*.lc);  # 散列 %words 不会再变化

bag 是一个有用的子例程，它只是对任何你给它的东西上调用 Bag.new 方法。（我不清楚为什么没有同样功能的 keybag 子例程）

Bag  和  KeyBag  有几个雕虫小技。它们都有它们自己的 .roll 和 .pick 方法，以根据给定的值来权衡它们的结果：


> my $bag = bag "red" => 2, "blue" => 10;
> say $bag.roll(10);
> say $bag.pick(*).join(" ");
blue blue blue blue blue blue red blue red blue
blue red blue blue red blue blue blue blue blue blue blue

This wouldn’t be too hard to emulate using a normal  Array , but this version would be:


> $bag = bag "red" => 20000000000000000001, "blue" => 100000000000000000000;
> say $bag.roll(10);
> say $bag.pick(10).join(" ");
blue blue blue blue red blue red blue blue blue
blue blue blue red blue blue blue red blue blue

They also work with all the standard  Set  operators, and have a few of their own as well. Here’s a simple demonstration:


 sub MAIN($file1, $file2) {
      my $words1 = bag slurp ( $file1 ).comb(/\w+/).map(*.lc);
      my $words2 = set slurp ( $file2 ).comb(/\w+/).map(*.lc);
      my $unique = ($words1 (-) $words2);
      for $unique .list .sort({ -$words1{$_} })[^10] -> $word {
          say "$word: { $words1{$word} }";
      }
 }



传递两个文件名，这使得 Bag 从第一个文件中获取单词，让 Set 从第二个文件中获取单词，然后使用 集合差 操作符 (-) 来计算只在第一个文件中含有的单词，按那些单词出现的频率排序，然后打印出前10 个单词。 

这是介绍 Set 的最好时机。就像你从上面猜到的一样，Set 跟 Bag 的作用很像。不同的地方在于，它们都是散列，而 Bag 是从Any到正整数的映射，Set 是从 Any 到 Bool::True的映射。集合Set 是不可改变的，所以也有一个 可变的 KeySet .

在 Set 和 Bag 之间，我们有很丰富的操作符： 操作符 Unicode “Texas” 结果类型
 属于 ∈ (elem) Bool
 不属于 ∉ !(elem) Bool
 包含 ∋ (cont) Bool
 不包含 ∌ !(cont) Bool
 并集 ∪ (|) Set 或 Bag
 交集 ∩ (&) Set 或 Bag
 差集 (-) Set
 set symmetric difference (^) Set
 子集 ⊆ (<=) Bool
 非子集 ⊈ !(<=) Bool
 真子集 ⊂ (<) Bool
 非真子集 ⊄ !(<) Bool
 超级 ⊇ (>=) Bool
 非超级 ⊉ !(>=) Bool
 真超级 ⊃ (>) Bool
 非真超级 ⊅ !(>) Bool
 bag multiplication ⊍ (.) Bag
 bag addition ⊎ (+) Bag


它们中的大多数都能不言自明。返回Set 的操作符在做运算前会将它们的参数提升为 Set。 返回Bag 的操作符在做运算前会将它们的参数提升为 Bag 。 返回Set 或Bag 的操作符在做运算前会将它们的参数提升为 Bag ，如果它们中至少有一个是 Bag 或 KeyBag，否则会转换为 Set； 在任何一种情况下，它们都返回提升后的类型。

eg：

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


 下面是作者放在 github上的 Demo：


I’ve placed my full set of examples for this article and several data files to play with on  Github . All the sample files should work on the latest very latest Rakudo from Github; I think all but  most-common-unique.pl  and  bag-union-demo.pl  should work with the latest proper Rakudo releases. Meanwhile those two scripts will work on Niecza, and with any luck I’ll have the bug stopping the rest of the scripts from working there fixed in the next few hours.

A quick example of getting the 10 most common words in Hamlet which are not found in Much Ado About Nothing:

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


Posted in  2012  |  1 Comment »