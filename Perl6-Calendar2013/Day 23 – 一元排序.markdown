# Day 23 – Unary Sort -- By   Moritz


在Perl5中按数值大小排序：
```perl
use v5;
my @sorted = sort { $a <=> $b } @values;
```
Perl6 提供类似的选择：
```perl
use v6;
my @sorted = sort { $ ^ a <=> $ ^ b }, @values;
```
主要区别在于，参数不是通过**全局变量** $a 和 $b 来传递，而是作为 comparator的参数传递。 comparator 可以是任何能调用的东西,即具名或匿名的**子例程**或**代码块**。 { $^a <=> $^b}语法对于sort也不特殊，我仅仅用了**占位变量**来展示和Perl5 的相似之处。 
下面的写法一样：
```perl
my @sorted = sort -> $a, $b { $a <=> $b } , @values;
my @sorted = sort * <=> * , @values;
my @sorted = sort &infix:« <=> », @values;
```

第一个只是代码块的另一种语法, * <=> * 使用 * 自动柯里化参数, 最后一个直接引用实现 <=> 宇宙飞船操作符的子例程(它的作用是数值比较)

## 按照散列中定义的顺序排序单词:
    my %rank = a => 5, b => 2, c => 10, d => 3;
    say sort { %rank{$^a} <=> %rank{$^b} }, 'a'..'d';  # b d a c ,升序排列
    #          ^^^^^^^^^^     ^^^^^^^^^^ 代码重复
 
## 不区分大小写排序
    say sort { $^a.lc cmp $^b.lc }, @words;
    #          ^^^^^^     ^^^^^^  代码重复

因为我们酷爱便捷憎恨重复，Perl 6 提供了更短的方案：

    # sort words by a sort order defined in a hash:
    say sort { %rank{$_} }, 'a'..'d';
     
    # sort case-insensitively
    say sort { .lc }, @words;

sort足够聪明地知道代码块现在只有**一个**参数，并使用它将输入列表中的每个元素映射为新值。这与 Schwartzian Transform 很相似，但是很方便，因为它是内置的。所以，现在代码块起着转换者的角色，而非比较器。

如果你想按数字顺序比较，你可以强制元素在数字上下文中进行比较，使用 + 号：
    my @sorted-numerically = sort + *, @list;
如果你想按相反的顺序比较数字，就使用 -* 代替好了。
