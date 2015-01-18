Day 6 – The X and Z metaoperators
By Matthew Walton


Perl6中一个新的创意就是元操作符，这种元操作符和普通的操作符结合改变了普通操作符的行为。这种远操作符有很多，但这里我们只关注它们中的两个 X 和 Z 
X 操作符你可能已经见过它作为中缀交叉操作符的普通角色。它将列表联合在一起，每个列表中各取一个元素：


> say ((1, 2) X ('a', 'b')).perl
((1, "a"), (1, "b"), (2, "a"), (2, "b"))
然而,这个中缀操作符infix
:<X> 其实是 将 X 操作符应用到 列表连接操作符    infix:<,>上的简便形式。事实上，你可以这样写：  


> say ((1, 2) X, (10, 11)).perl
((1, 10), (1, 11), (2, 10), (2, 11))
如果你喜欢.所以你将 X 应用到不同的中缀操作符上面会发生什么？   应用到  infix:<+> 上呢？


> say ((1, 2) X+ (10, 11)).perl
(11, 12, 12, 13).list
 它做了什么？它不是从每个组合中挑出所有的元素列表，这个操作符将中缀操作符 + 应用到元素间，并且结果不是一个列表，而是一个数字，是那个组合中所有元素的和。
这对任何中缀操作符都有效。看看 字符串连接 infix:< ~ >：


> say ((1, 2) X~ (10, 11)).perl
("110", "111", "210", "211")
或者也许数值相等操作符infix:< == >


> say ((1, 2) X== (1, 1)).perl
(Bool::True, Bool::True, Bool::False, Bool::False)


但是这篇文章也是关于 Z 元操作符的。我们期望你已经知道他是什么了。如果你遇见过 中缀操作符 Z，它当然是 Z, 的便捷形式。


> say ((1, 2) Z, (3, 4)).perl
((1, 3), (2, 4))
> say ((1, 2) Z+ (3, 4)).perl
(4, 6).list
> say ((1, 2) Z== (1, 1)).perl
(Bool::True, Bool::False)
Z,然后,依次操作每个列表的每个元素，同时操作每个列表中的第一个元素，然后同时操作第二对儿，然后第三对儿，不管有多少。当到达列表的结尾时停止。


Z也是惰性的,所以你可以将它用在两个无限列表上，它会尽可能多地生成你需要的结果。X 只能处理左边是无限列表的列表，否则它不会设法得到任何东西。


在写这篇文章的时候，Rakudo 正好出现了一个 bug，就是 infix:<Z> 和 infix:<Z,>不是完全一样的:后者产生一个展开的列表. S03 表明后者的行为是正确的。


These metaoperators, then, become powerful tools for performing operations encompassing the individual elements of multiple lists, whether those elements are associated in some way based on their indexes as with Z, or whether you just want to examine all possible combinations with X.


有一个键和值得列表，你想得到一个散列？ 容易！


my %hash = @keys Z=> @values;
或者，也许你想并行遍历两个列表？


for @a Z @b -> $a, $b { ... }
或者三个?


for @a Z @b Z @c -> $a, $b, $c { ... }
或者你能从扔3次有10个面的骰子的所有数字组合中，得到所有可能的总数：
my @d10 = 1 ... 10;
my @scores = (@d10 X+ @d10) X+ @d10;
如果你想看到一些在真实世界这些原操作符的用途，看看 Moritz Lenz’s 写的  Sudoku.pm 数独解算器。