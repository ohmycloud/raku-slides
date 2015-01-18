Day 10 – Feed operators By   Perlpilot


 使用Perl 5 编程一段时间的人可能遇到或写过下面这样相似的代码：
    my @new = sort { ... } map { ... } grep { ... } @original;

在这个构造中，数据从  @original 数组流进 grep，然后按顺序，流进 map  ，然后流进 sort，最后将结果赋值给 @new 数组。因为它们每个都将列表作为它们最终的参数，仅仅通过位置，数据从一个操作符向左流进下一个操作符。

Perl 6, 从另一方面，通过引入流向操作符让数据从一个操作符流进另一个操作符，让这种思想更明确。上面的Perl 5 代码能使用 Perl 6 重写：
    my @new <== sort { ... } <== map { ... } <== grep { ... } <== @original ;

注意条条大路通罗马，这个在Perl 6 中更能体现。你也可以跟Perl 5 的写法相同：
    my @new = sort { ... } , map { ... } , grep { ... } , @original;

唯一不同的是额外的逗号。

所以，我们从这些流向操作符得到了什么？通常，当我们阅读代码的时候，你是从左向右读的，在原来的 Perl 5 代码中，你可能从左到右阅读你的代码直到你发现正在处理的结构，其流向是从右向左的，然后你跳到末尾，按照从右往左的方式再读一遍。 在Perl 6 中， 在Perl 6中 现在有一个 突出的句法 标记 ， 告诉你 数据 向左 流动的性质 。




这样写也可以：
    @original ==> grep { ... } ==> map { ... } ==> sort { ... }  ==> my @new;

下面是一些使用流向操作符的例子：
    my @random-nums = (1..100).pick(*);  # 100个随机数
    my @odds-squared <== sort <== map { $_ ** 2 } <== grep { $_ % 2 } <== @random-nums;
    say ~@odds-squared;


> my @odds-squared <== sort { $^b <=> $^a } <== map { $_ ** 2 } <== grep { $_ % 2 } <== @random-nums   # 降序排列
9801 9409 9025 8649 8281 7921 7569 7225 6889 6561 6241 5929 5625 5329 5041 4761 4489 4225 3969 3721 3481 3249 3025 2809 2601 2401 2209 2025 1849 1681
1521 1369 1225 1089 961 841 729 625 529 441 361 289 225 169 121 81 49 25 9 1
    my @rakudo-people = <scott patrick carl moritz jonathan jerry stephen>;
    @rakudo-people ==> grep { /at/ } ==> map { .ucfirst } ==> my @who-it's-at;
    say ~@who-it's-at;    # Patrick Jonathan

 [+](my @a) <== map {$_ **2} <==  1..10   # 385 ， 1 到 10 的平方和

> [+]() <== map {$_ **2} <==  1..10
385
来源： < http://perl6advent.wordpress.com/2010/12/10/day-10-feed-operators/ >  