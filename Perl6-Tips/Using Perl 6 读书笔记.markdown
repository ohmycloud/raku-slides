 
 
 
                  

          
                                                                                   
  第二章 基础
 
假设有一场乒乓球比赛，比赛结果以这种格式记录：
Player1 Player2 | 3:2
这意味着选手1与选手2的比分为3:2, 你需要一个脚本算出每位选手 赢了几场比赛 并且 胜了几局 。
输入数据（存储在一个叫做scores的文件中）像下面这样：
 
1 Beth Ana Charlie Dave
2 Ana Dave       | 3:0
3 Charlie Beth   | 3:1
4 Ana Beth        | 2:3
5 Dave Charlie  | 3:0
6 Ana Charlie    | 3:1
7 Beth Dave      | 0:3
 第一行是选手清单。随后每一行记录着比赛结果。
 
这里使用Perl6给出一种解决方案：
1 use v6;
2
3 my $file = open 'scores';
4 my @names = $file.get.words ;  # get方法 读入一行，每调用一次get，读取一行
5 #  > @names .perl  #   Array.new("1", "Beth", "Ana", "Charlie", "Dave")
6 my %matches ;  # 赢得 比赛次数
7 my %sets ;         # 赢得 比赛局数
8
9 for $file .lines -> $line {    # .lines 是 惰性 的
10 my ($pairing, $result) = $line.split(' | ');      # 对剩下的每一行调用 split 操作
11 my ($p1, $p2)              = $pairing .words ;    # 提取选手1和选手2的 名字
12 my ($r1, $r2)                = $result.split(':');    # 提取比赛比分
13
14 %sets {$p1} += $r1;  # 选手1赢得的比赛 局数
15 %sets {$p2} += $r2;  # 选手2赢得的比赛 局数
16
17 if $r1 > $r2 { # 如果每场比赛中，选手1赢的局数多于选手2，则选手1赢得的比赛数+1，反之选手2的+1
18 %matches { $p1 }++;
19 } else {
20 %matches { $p2 }++;
21 }
22 }
23
24 my @sorted = @names.sort( { %sets{$_} } ).sort({ %matches{$_} } ).reverse;
25
26 for @sorted -> $n {
27 say " $n has won %matches{$n} matches and %sets{$n} sets";
28 }
 
输出如下：
Ana has won 2 matches and 8 sets
Dave has won 2 matches and 6 sets
Charlie has won 1 matches and 4 sets
Beth has won 1 matches and 4 sets
 
每个 Perl 6程序应该以 use v6 ;作为开始，它告诉编译器程序期望的是哪个版本的Perl。
 
在Perl6中，一个变量名以一个魔符打头，这个魔符是一个非字母数字符号，诸如$,@,%或者 &,还有更少见的双冒号 ::
内置函数 open 打开了一个名叫 scores 的文件，并返回一个 文件句柄 ，即一个代表该文件的 对象 。赋值符号=将句柄赋值给左边的变量，这意味着 $file 现在存储着该文件句柄。
 
my @names = $file.get.words;
 
 上边这句的右侧对存储在 $file 中的 文件句柄 调用了 get 方法， get 方法从文件中读取并 返回一行 ，并 去掉行的末尾 。 . words   也是一个方法，用于从get 方法返回的 字符串 上。 .words 方法将它的组件--它操作的字符串，分解成一组单词，这里即意味着不含空格的字符串。它把 单个字符串 'Beth Ana Charlie Dave' 转换成 一组 字符串 'Beth', 'Ana', 'Charlie', 'Dave'.最后，这组字符串存储在数组@names中。  
1 my %matches;
2 my %sets;
 
 
在比分计数程序中， %matches 存储每位选手赢得的比赛数。  %sets 存储每位选手赢得的比赛局数。 
 
1 for $file.lines -> $line {
2 ...
3 }
 
for循环中 $file.lines 产生一组从文件 scores 读取的行，从 上次 $file.lines 离开的地方开始 ，一直到文件 末尾 结束。
在第一次循环中， $line 会包含字符串 Ana Dave | 3:0; 在第二次循环中，$line 会包含 Charlie Beth | 3:1,以此类推。
 
1 my ($pairing, $result) = $line.split(' | ');
 
split此处是一个方法，字符串 '|' 是它的参数。
 
第一次循环结束：
Variable       Contents
$line             'Ana Dave | 3:0'
$pairing        'Ana Dave'
$result          '3:0'
$p1               'Ana'
$p2              'Dave'
$r1               '3'
$r2              '0'
 
1 my @sorted = @names.sort({ %sets {$_} }).sort({ %matches {$_} }).reverse;
 
 
这一句是排序，先按 比赛局数 多少排序，再按 赢得的比赛数 排序，然后反转。
打印选手名字的时候以胜负次序排序，代码必须使用选手的 分数 ，而非他们的名字来进行排序。sort 方法 的参数是一个 代码块 ，用于将数组元素（选手的名字）转换成用于排序的数据。数组的元素通过变量 $_ 传递到代码块中。
 
最简单的使用分数排序选手的方法应该是 @names.sort( { %matches {$_} } ),这是通过使用 赢得比赛的次数 来进行排序。然而，Ana和Dave都赢了两场比赛。还需要比较谁赢的的比赛局数多，才能决定比赛的排名。
 
在 双引号 括起的字符串中， 标量 和 花括号中的变量 能进行变量插值。
 
1 my $names = 'things';
2 say ' Do not call me $names ' ;   # Do not call me $names
3 say "Do not call me $names"; # Do not call me things
 
花括号中的数组进行插值后会变成用 空格 分隔的条目。花括号中的散列插值后每个 散列键值对单独成为一行 ，每行包含一个健，随后是一个tab符号，然后是键值，最后是一个新行符。
 
TODO: explain <...> quote-words
1 say "Math: { 1 + 2 } "     # Math: 3
2 my @people = <Luke Matthew Mark>;
3 say "The synoptics are: {@people} " # The synoptics are: Luke Matthew Mark
4
5 say " {%sets} " ; # From the table tennis tournament
6
7 # Charlie 4
8 # Dave 6
9 # Ana 8
10 # Beth 4
 
当数组和散列变量直接出现在双引号字符串中（并且不在花括号{}里），它们只在它们的名字后跟着一个  postcircumfix ----一对括号，后面跟着语句时才会进行插值。在变量名和后置环缀之间进行方法调用也是可以的（ 例如   @flavours .sort () ）


1 my @flavours = <vanilla peach>;
2
3 say "we have @flavours";      # we have @flavours ，这里没进行插值
4 say "we have @flavours [0] "; # we have vanilla，后置环缀，变量名字后面跟着一对儿括号
5 # so-called "Zen slice"
6 say "we have @flavours[] ";   # we have vanilla peach
7
8 # 以后置环缀结尾的方法调用
9 say "we have @flavours.sort() "; # we have peach vanilla
10
11 # 链式方法调用 :
12 say "we have @flavours .sort.join (', ')";
13 # we have peach, vanilla
 
练习：
 
例子中的第一行选手的名字是多余的，你可以在参加比赛的选手中找出所有选手的名字！ 如果例子中的第一行被省略了，你如何更改程序？提示：%hash.keys 返回散列 %hash中的所有键。
 
答案: 移除此行： my @names = $file.get.words; 并且将
     my @sorted = @names.sort({ %sets{$_} }).sort({ %matches{$_} }).reverse;
     变成:
     my @sorted = %sets.keys.sort ({ %sets{$_} }).sort({ %matches{$_} }).reverse;
 
 
2. 除了移除冗余，你也可以用它来提醒我们，如果一个选手没有在第一行的名字清单中被提到，例如因为输入错误，你该怎样修改你的程序？
 
答案:引入另外一个散列，合法选手的名字作为键，当读取选手名字的时候查找该散列：
1
2 my @names = $file.get .split (' ');
3 my %legitimate-players;
4 for @names -> $n {      #  -> 两侧要有 空格
5 %legitimate-players{$n} = 1;
6 }
7
8 ...
9
10 for $file.lines -> $line {
11 my ($pairing, $result) = $line.split(' | ');
12 my ($p1, $p2)             = $pairing.split(' ');
13       for $p1, $p2 -> $p {
14             if !%legitimate-players{$p} {
15             say "Warning: '$p' is not on our list!";
16             }
17       }
18
19 ...
20 }
 
                                                                                                                             第三章 操作符
 
use v6;
 
my @scores = 'Ana' => 8, 'Dave' => 6, 'Charlie' => 4, 'Beth' => 4;
 
my $screen-width = 30;
 
my $label-area-width = 1 + [max] @scores » .key » .chars ;
my $max-score = [max] @scores » .value ;
my $unit = ($screen-width - $label-area-width) / $max-score;
my $format = '%- ' ~ $label-area-width ~ "s%s\n";
 
for @scores {
printf $format, .key , 'X' x ($unit * .value );
}
 
在这个例子中，我们计算一下每位选手在竞标赛中赢得比赛的局数。
my @scores = 'Ana' => 8, 'Dave' => 6, 'Charlie' => 4, 'Beth' => 4;   这一句局包含了三个不同的操作符 = 和 => 和 ,
以字符串连接操作符 ~ 为例， $string ~= "text" 等价于 $string = $string ~"text".
 
=> 操作符（大键号）创建了一个键值对对象，一个键值对存储着键和值；键在 => 操作符的左侧，值在右侧。这个操作符有一个特殊的特性：编译器会把 =>操作符左侧的任何 裸标识符 解释为一个 字符串 。你也可以这样写：
 
my @scores = Ana => 8, Dave => 6, Charlie => 4, Beth => 4;
 
最后 逗号操作符 , 构建了一个 对象序列 ，在该情况下，所谓的对象就是键值对。
 
这三个操作符都是 中缀操作符 ，这意味着它在两个条目之间。
 
一个项前面可以有0个或多个前缀操作符，所以你可以写比如 4 + -5。+ 号（一个中缀操作符）的后面，编译器期望一个项，为了将 - 号解释为项 5 的一个前缀。
 
my $label-area-width = 1 + [max] @scores » .key » .chars;
 
» 是一个特殊的符号，打印不出来可以用两个大于号>>代替。
中缀操作符 max 返回两个值中的较大者，所以 2 max 3 返回 3。 方括号 包裹着一个 中缀操作符 让Perl 将该中缀操作符应用到列表中的元素之间 。[max] 1,5,3,7 和 1 max 5 max 3 max 7 一样，结果都为7.
 
同样地，[+]用来计算列表元素的和，[*]用来计算列表元素的积，[ <= ]用来检查一个列表的值是否按递增排序。
 
@scores».key».chars
 
> my @scores = Ana => 8, Dave => 6, Charlie => 4, Beth => 4;
Ana     8 Dave  6 Charlie       4 Beth  4
> @scores.key
Method 'key' not found for invocant of class 'Array'
> @scores >> .key
Ana Dave Charlie Beth
就像@variable.method 在@variable上调用一个方法一样 ，@array».method 对@array中的每一项调用method方法 ，并且返回一个返回值的列表。即@scores>>.key返回一个列表。
 
> @scores>>.key>>.chars  #每个名字含有几个字符
3 4 7 4
 
表达式 [max] @scores».key».chars 给出(3,4,7,4)中的最大值。它与下面的表达式相同：
1 @scores[0].key.chars
2 max @scores[1].key.chars
3 max @scores[2].key.chars
4 max ...
 
 
> @scores[0]
"Ana" => 8
>  @scores[0].key
Ana
 
1 my $format = '%- ' ~ $label-area-width ~ "s%s\n";
2 for @scores {
3 printf $format, .key, 'X' x ($unit * .value);
4 }
 
定义一个格式，%-表示左对齐，~是字符串连接操作符.for循环中，@scores中的每一项被绑定给特殊变量$_, .key是每项的键，即名字， .value是每项的键值，即得分。小 x 是字符串重复操作符。
 
3.1 关于优先级的的一句话
 
my @scores = 'Ana' => 8, 'Dave' => 6, 'Charlie' => 4, 'Beth' => 4;
 
等号右侧产生一个列表（因为逗号，操作符），这个列表由对儿组成（因为 =>）,并且结果赋值给数组变量。
在Perl5中会这样解释:
1 (my @scores = 'Ana') => 8, 'Dave' => 6, 'Charlie' => 4, 'Beth' => 4;
以至于数组@scores中只有一个项，表达式的其余部分被计算后丢弃。
 
优先级规则控制着编译器如何解释这一行。Perl 6的优先级规则申明 中缀操作符 => 比 , 中缀操作符对于参数的绑定更紧，而逗号操作符比 等号赋值操作符绑定的更紧。
 
实际上有两种不同优先级的赋值操作符。当赋值操作符右侧是一个标量时，使用较紧优先级的项赋值操作符，否则使用较松优先级的列表赋值操作符。（如同螺丝的松紧）
比较 $a = 1, $b = 2 和@a = 1, 2，前者是在一个列表中赋值给两个变量，后者是将含有两个项的一个列表赋值给一个变量。
 
1 say 5 - 7 / 2; # 5 - 3.5 = 1.5
2 say (5 - 7) / 2; # (-2) / 2 = -1
 
Perl 6 中的优先级可以用圆括号改变，但是如果圆括号直接跟在标识符的后面而不加空格的话，则会被解释为参数列表。例如：
say(5 - 7) / 2; # -2
只打印出了 5-7 的值。
 
                                                                             优先级表
 
 

 
3.2 比较和智能匹配
 
1 my @a = 1, 2, 3;
2 my @b = 1, 2, 3;
3
4 say @a === @a; # Bool::True
5 say @a === @b; # Bool::False
6
7 # these use identity for value
8
9 say 3 === 3 # Bool::True
10 say 'a' === 'a'; # Bool::True
11
12 my $a = 'a';
13 say $a === 'a'; # Bool::True
> @b===@a
False
> @a eqv @b
True
> '2' eqv 2
False
 
只有当两个对象有相同的类型和相同的结构时， eqv 操作符才返回 True。在前面定义的例子中，@a  eqv  @b 结果为 True， 因为 @a 和 @b 各自包含相同的值，另一方面， '2' eqv 2 返回 'False' ,因为一个参数是字符串，另一个是整数，类型不相同。
 
3.2.1 数字比较
 
使用 == 中缀操作符查看两个对象是否有相同的数字值。如果某个对象不是数字，Perl 会在比较之前尽力使其数字化。如果没有更好的方式将对象转换为数字，Perl 会使用默认的数字 0 。
 
1 say 1 == 1.0; # Bool::True
2 say 1 == '1'; # Bool::True
3 say 1 == '2'; # Bool::False
4 say 3 == '3b'; # fails
 
跟数字比较相关的还有 <,<=,>,>= 。如果两个对象的数字值不同，使用 != 会返回 True 。
 
如果你将数组或列表作为数字，它会计算列表中项的个数。
1my @colors = <red blue green>;
2
3 if @colors == 3 {
4 say "It's true, @colors contains 3 items";
5 }
 
3.2.2  字符串比较
Perl 6 中使用 eq 比较字符串，必要时会将其参数转换为字符串。
1 if $greeting eq 'hello' {
2 say 'welcome';
3 }
 
Table 3.2: Operators and Comparisons
 数字比较 字符串比较 意思
 == eq 等于
 != ne 不等于
 !== !eq 不等于
 < lt 小于
 <= le 小于或等于
 > gt 大于
 >= ge 大于或等于

 
例如，'a' lt 'b' 为 true，'a' lt 'aa' 也为 true。 != 是 !==的便捷形式，它实际是 ! 元操作符加在 中缀操作符 ==之前。同样地， ne 和 !eq 是一样的。
 
三路操作符
 
三路操作符有两个操作数，如果左侧较小，返回 Order::Increase ，两侧相等则返回 Order::Same，如果右侧较小则返回 Order::Decrease。对于数字使用 三路操作符 <=> ,对于字符串，使用三路操作符 leg （取自 lesser，equal，greater）。中缀操作符 cmp 是一个对类型敏感的三路操作符，它像 <=> 一样比较数字，像 leg 一样比较字符串，（举例来说）并且比较键值对儿时，先比较键，如果键相同再比较键值：
 

1 say 10 <=> 5; # +1
2 say 10 leg 5; # because '1' lt '5'
3 say 'ab' leg 'a'; # +1, lexicographic comparison
 
三路操作符的典型用处就是用在排序中。列表中的.sort 方法能使用一个含有两个值的块或一个函数，比较它们，并返回一个小于，等于或大于 0 的值。 sort  方法根据该返回值进行排序：
 
1 say ~<abstract Concrete>.sort;
2 # output: Concrete abstract
3
4 say ~<abstract Concrete>.sort:  -> $a, $b { uc($a) leg uc($b) };
5 # output: abstract Concrete
 
默认的，比较是大小写敏感的，通过比较它们的大写变形，而不是比较它们的值，这个例子使用了大小写敏感排序。
 
3.2.3智能匹配
 
使用 ~~ 做正确的事情。
 
1 if $pints-drunk ~~ 8 {
2 say "Go home, you've had enough!";
3 }
4
5 if $country ~~ 'Sweden' {
6 say "Meatballs with lingonberries and potato moose, please."
7 }
8
9 unless $group-size ~~ 2..4 {
10 say "You must have between 2 and 4 people to book this tour.";
11 }
 
智能匹配总是根据 ~~右侧值的类型来决定使用哪种比较。上个例子中，比较的是数字、字符串和范围。
智能匹配的工作方式 $answer ~~ 42 等价于 42.ACCPETS( $answer ).对 ~~ 操作符右侧的操作数调用 ACCEPTS 方法，并将左操作数作为参数传入。
 
 
 
第四章 子例程和 签名
 
 
一个子例程就是一段执行特殊任务的 代码片段 。 它可以对提供的数据（实参）操作，并产生结果（返回值）。 子例程的 签名 是 它所含的参数 和 它 产生的返回值 的 描述 。 从某一意义上来说，第三章描述的操作符也是Perl 6用特殊方式解释的子例程。
 
4.1 申明子例程
 一个子例程申明由几部分组成。首先， sub 表明你在申明一个子例程，然后是 可选的子例程的名称 和 可选的签名 。子例程的主体是一个用花括号扩起来的代码块。
默认的，子例程是 本地作用域 的，就像任何使用 my 申明的变量一样。这意味着， 一个子例程只能在它被申明的作用域内被调用 。使用 our 来申明子例程可以使其在 当前包 中可见。
 
 
  
1 {
2 our sub eat () {
3 say "om nom nom";
4 }
5
6 sub drink () {
7 say "glug glug";
8 }
9 }
10 our &eat; # makes the package-scoped sub eat available in this lexical scope
11
12 eat(); # om nom nom
13 drink(); # 失败, can't drink outside of the block
our 也能让子例程从包或模块的外部是可见的：
 
1 module EatAndDrink {
2 our sub eat() {
3 say "om nom nom";
4 }
5
6 sub drink() {
7 say "glug glug";
8 }
9 }
10 EatAndDrink: :eat (); # om nom nom
11 EatAndDrink::drink(); # fails, not declared with "our"
 
你也可以 导出 一个子例程，让它在另外的作用域内可见。
 
1 # in file Math/Trivial.pm
2 # TODO: find a better example
3 # TODO: explain modules, search paths
4 module Math::Trivial {
5 sub double($x) is export {
6 return 2 * $x;
7 }
 
然后在其它程序或模块中你可以这样写:
1 use Math::Trivial; # imports sub double
2 say double(21); # 21 is only half the truth
 

Perl 6的子例程都是 对象 。你可以将它们 随意传递 并 存储在数据结构中 。编程语言设计者常常将它们称之为first-class 子例程；它们就像数组和散列一样作为语言的 基础 。 
 
First-class 子例程能帮助你解决复杂的问题。例如，为了做出一个微型的ASCII艺术舞蹈图，你可能要建立一个散列， 键是舞蹈动作的名称 ， 键值是匿名散列 。假使使用者能键入一系列舞蹈动作（可能是站在舞蹈平台上或其它外部输入设备）。 你怎么保持一个变量清单中都是合法的行为，允许使用者输入，并 限制输入 是一系列安全的行为呢？
 
1 my %moves =
2 hands-over-head => sub { say '/o\ '  },
3 bird-arms              => sub { say '|/o\| ' },
4 left                         => sub { say '>o '   },
5 right                      => sub { say 'o< '   },
6 arms-up                => sub { say '\o/ '  };
7
8 my @awesome-dance = <arms-up bird-arms right hands-over-head>;
9
10 for @awesome-dance -> $move {
11 %moves{$move}.() ;  # 在散列上调用方法
12 }
13
 
14 # outputs:
15 #\o/
16 # |/o\|
17 # o<
18 # /o\
 
4.2 添加 签名
 
子例程的签名执行两个任务。首先，它申明哪个调用者可能或必须将参数传递给子例程。第二， 它申明子例程中的变量被绑定到哪些参数上 。这些变量叫做参数。Perl 6的签名更深入，它们允许你 限制参数的类型，值和参数的定义 ，并准确匹配复杂数据结构的某一部分。此外，它们也允许你 显式地 指定子例程 返回值的类型 。
 
4.2.1 基础
签名最简单的形式是，绑定到输入参数上的用逗号分隔的一列变量的名字。
 
1 sub order-beer( $type, $pints ) {
2 say ($pints == 1 ?? 'A pint' !! "$pints pints") ~ " of $type, please."
3 }
4
5 order-beer ('Hobgoblin', 1);    # A pint of Hobgoblin, please.
6 order-beer ('Zlatý Bažant', 3);  # 3 pints of Zlatý Bažant, please.


这里使用的 关系绑定 而非赋值就是签名。默认地，在Perl6 中，子例程中引用到传入参数的签名的变量是 只读 的。这意味着你不能从子例程内部修改它们。
如果只读绑定太受限制了，你可以将 is rw (rw是read/write的缩写) 特性应用到参数上以降低这种限制。这个特性说明参数是可读可写的， 这允许你从子例程内部修改参数 。使用的时候必须小心， 因为它会修改传入的原始对象 。 如果你试图传入一个 字面值 ，一个 常量 ，或其它类型的 不可变对象 到一个有 is rw 特性的参数中，绑定会在调用时失败并抛出异常:
 
1 sub make-it-more-so($it is rw ) {
2 $it ~= substr ($it, $it.chars - 1) x 5;
3 }
4
5 my $happy = "yay!";
6 make-it-more-so ($happy);
7 say $happy; # yay!!!!!!  #原始传入对象被修改了
8 make-it-more-so ("uh-oh"); # 失败， 不能修改一个常量
 
如果你想将参数的 本地副本 用在子例程内部而不改变调用者的变量，----使用 is copy 特性：
 
1 sub say-it-one-higher($it is copy ) {
2 $it++;
3 say $it;
4 }
5
6 my $unanswer = 41;
7 say-it-one-higher($unanswer); # 42
8 say-it-one-higher( 41 ); # 42
9 $unanswer ;  #41
 
在诸如C/C++ and Scheme等其它类型的编程语言中,这种广为人知的求值策略就是“按值传递”。当使用 is copy 特性时，只有 本地副本 被赋值。其它任何传递给子例程的参数在调用者的作用域内保持不变。（一个不可变对象是当这个对象被创建后，它的状态不会改变，作为比较，一个可变对象的状态在创建后是会被改变的）
 
4.2.2 传递数组、散列和代码
 
一个变量的魔符表明它的本意用途。 在签名中，变量的魔符也起着限制传入的参数类型的作用 。例如， @ 符号检查传入的对象行使位置角色（一个角色包含像数组和列表的类型）。如果传递的东西不能匹配这样的限制，会引起调用失败：
 
1 sub shout-them( @words ) {
2 for @words -> $w {
3 print uc ("$w ");
4 }
5 }
6
7 my @last_words = <do not want>;
8
9 shout-them(@last_words); # DO NOT WANT
10 shout-them('help'); # Fails; a string is not Positional  字符串不是位置参数
 
 
类似地， % 符号表明调用者必须传递一个行使关系角色的对象；即允许通过<...>或{...} 进行索引的东西。 & 符号要求调用者传递一个诸如匿名散列之类的行使能调用的角色的对象。在那种情况下，你也可以不用 & 符号调用可调用的参数：
 
1 sub do-it-lots( &it , $how-many-times) {
2 for 1..$how-many-times {
3 it();
4 }
5 }
6
7 do-it-lots(sub { say "Eating a stroopwafel" }, 10);   #此处是一个匿名子例程
 
标量使用 $符号，并表明没有限制。什么都可以绑定在它上面，即使它使用另外的符号绑定到一个对象上。
 
4.2.3 插值、数组和散列
 
有时你想从数组中填充占位参数。你可以通过在数组前添加一个垂直竖条或管道字符 ( | ): eat( |@food )     而不是写作eat(@food[0],@food[1], @food[2], ...) 等将它们吸进参数列表。
 
同样地，你可以将散列插值进具名参数:
 
1 sub order-shrimps ( $count , :$from ) {
2 say "I'd like $count pieces of shrimp from the $from , please";
3 }
4
5 my %user-preferences = from => 'Northern Sea';
6
7 order-shrimps (3, |%user-preferences );
8 # I'd like 3 pieces of shrimp from the Northern Sea, please
 
4.2.4 可选参数
为使参数可选，要么给签名的参数赋值为默认值：
1 sub order-steak( $how = 'medium' ) {
2 say "I'd like a steak, $how";
3 }
4
5 order-steak();
6 order-steak('well done');
 
或者在参数名字的后面添加一个问号(?):
1 sub order-burger($type, $side? ) {
2 say "I'd like a $type burger" ~
3 ( defined($side) ?? " with a side of $side" !! "" );
4 }
5
6 order-burger("triple bacon", "deep fried onion rings");
如果没有参数被传递，参数会被绑定成一个 未定义 的值。 defined(...) 函数用来检查是否有值。
 
4.2.5 必不可少的参数
默认地， 位置参数是必不可少的 。然而，你可以通过在参数后面追加一个 感叹号 来显式地指定该参数是必须的：
 
1 sub order-drink($size, $flavor! ) {
2 say "$size $flavor, coming right up!";
3 }
4
5 order-drink('Large', 'Mountain Dew'); # OK
6 order-drink('Small'); # Error
 
4.2.6 具名实参和形参
 
当一个子例程有很多参数时，调用者很难记清传递参数的顺序。这种情况下，通过名字传递参数往往更容易。这样，参数出现的顺序就无关紧要了:
 
1 sub order-beer($type, $pints) {
2 say ($pints == 1 ?? 'A pint' !! "$pints pints") ~ " of $type, please."
3 }
4
5 order-beer(type => 'Hobgoblin', pints => 1);
6 # A pint of Hobgoblin, please.
7
8 order-beer(pints => 3, type => 'Zlatý Bažant');
9 # 3 pints of Zlatý Bažant, please.
 
你也可以指定参数只能按名字被传递（这意味着它不允许按位置传递）。这样的话，在参数名字前加一个冒号：
 
1 sub order-shrimps($count, :$from = 'Northern Sea') {
2 say "I'd like $count pieces of shrimp from the $from, please";
3 }
4
5 order-shrimps(6);    # takes 'Northern Sea'
6 order-shrimps(4, from => 'Atlantic Ocean');
7 order-shrimps(22, 'Mediterranean Sea');   # 不允许, :$from is named only
不像位置参数，命名参数默认是可选的。在命名参数后面追加一个 ! 号使命名参数强制性存在。
 
1 sub design-ice-cream-mixture($base = 'Vanilla', :$name!) {
2 say "Creating a new recipe named $name!"
3 }
4
5 design-ice-cream-mixture(name => 'Plain');
6 design-ice-cream-mixture(base => 'Strawberry chip'); # 错误,没有指定 $name
 
重命名参数
 
Since it is possible to pass arguments to parameters by name, the parameter names should
be considered as part of a subroutine’s public API. Choose them carefully! Sometimes it
may be convenient to expose a parameter with one name while binding to a variable of a
different name:
1 sub announce-time(:dinner($supper) = '8pm') {
2 say "We eat dinner at $supper";
3 }
4
5 announce-time(dinner => '9pm'); # We eat dinner at 9pm
 
参数可以有多个名字，如果你的用户有些是英国人，有些是美国人，你可能这样写：
 
1 sub paint-rectangle(
2 :$x = 0,
3 :$y = 0,
4 :$width = 100,
5 :$height = 50,
6 :color(:colour($c))) {
7
8 # print a piece of SVG that represents a rectangle
9 say qq[<rect x="$x" y="$y" width="$width" height="$height"
10 style="fill: $c" />]
11 }
12
13 # both calls work the same
14 paint-rectangle :color<Blue>;
15 paint-rectangle :colour<Blue>;
16
17 # of course you can still fill the other options
18 paint-rectangle :width(30), :height(10), :colour<Blue>;
 
Alternative Named Argument Syntaxes
命名变量通常是成对的（键值对）。有多种方式可以写成一对儿。各种方法的不同之处就是清晰性，因为每种选择提供不同的引用机制。下面的三种调用是一样的意思：
 
1 announce-time(dinner => '9pm');
2 announce-time(:dinner('9pm'));
3 announce-time(:dinner<9pm>);
如果传递的是布尔值，你可以省略键值对的键值：
 
1 toggle-blender( :enabled); # enables the blender
2 toggle-blender(:!enabled); # disables the blender
 
A named argument of the form :name with no value has an implicit value of Bool::True.
e negated form of this, :!name, has an implicit value of Bool::False.
If you use a variable to create a pair, you can reuse the variable name as the key of the
pair.
 
1 my $dinner = '9pm';
2 announce-dinner :$dinner; # same as dinner => $dinner;
 
pairForms on page 37 lists possible Pair forms and their meanings.

 
You can use any of these forms in any context where you can use a Pair object. For
example, when populating a hash:
 
1 # TODO: better example
2 my $black = 12;
3 my %color-popularities = :$black, :blue(8),
4 red => 18, :white<0>;
5 # 与此相同：
6 # my %color-popularities =
7 # black => 12,
8 # blue => 8,
9 # red => 18,
10 # white => 0;
Finally, to pass an existing Pair object to a subroutine by position, not name, either put
it in parentheses (like (:$thing)), or use the => operator with a quoted string on the
le-hand side: "thing" => $thing.
 
参数的顺序
当位置参数和命名参数都出现在签字中时，所有的位置参数都要出现在命名参数之前：
 
1 sub mix(@ingredients, :$name) { ... } # OK
2 sub notmix(:$name, @ingredients) { ... } # Error
 
Required 位置参数要在可选的位置参数之前。然而，命名参数没有这种限制。
 
1 sub copy-machine($amount, $size = 'A4', :$color!, :$quality) { ... } # OK
2 sub fax-machine($amount = 1, $number) { ... } # Error
 
 
4.2.7 Slurpy 参数
有时候，你会希望让子例程接受任何数量的参数，并且将所有这些参数收集到一个数组中。为了达到这个目的，给签字添加一个数组参数，就是在数组前添加一个 * 号前缀：
 
1 sub shout-them(*@words) {
2 for @words -> $w {
3 print uc("$w ");
4 }
5 }
6
7  #现在你可以传递项
8 shout-them('go'); # GO
9 shout-them('go', 'home'); # GO HOME
 
除了集合所有的值之外，slurpy 参数会展平任何它收到的数组，最后你只会得到一个展平的列表，因此：
 
1 my @words = ('go', 'home');
2 shout-them(@words);
会导致 *@words 参数有两个字符串元素，而非只有单个数组元素。
 
你可以选择将某些参数捕获到位置参数中，并让其它参数被吸进数组参数里。这种情况下， slupy 因该放到最后。相似地， *%hash slurps 所有剩下的未绑定的命名参数到散列 %hash中。Slurpy 数组和散列允许你传递所有的位置参数和命名参数到另一个子例程中。
 
1 sub debug-wrapper(&code, *@positional, *%named) {
2 warn "Calling '&code.name()' with arguments "
3 ~ "@positional.perl(), %named.perl()\n";
4 code(|@positional, |%named);
5 warn "... back from '&code.name()'\n";
6 }
7
8 debug-wrapper(&order-shrimps, 4, from => 'Atlantic Ocean');
 
4.3 返回结果
子例程也能返回值。之前本章中的 ASCII 艺术舞蹈例子会更简单当每个子例程返回一个新字符串：
 
1 my %moves =
2 hands-over-head => sub { return '/o\ ' },
3 bird-arms => sub { return '|/o\| ' },
4 left => sub { return '>o ' },
5 right => sub { return 'o< ' },
6 arms-up => sub { return '\o/ ' };
7
8 my @awesome-dance = <arms-up bird-arms right hands-over-head>;
9
10 for @awesome-dance -> $move {
11 print %moves{$move}.();
12 }
13
14 print "\n";
子例程也能返回多个值（译者注：那不就是返回一个列表嘛）：
 
1 sub menu {
2 if rand < 0.5 {
3 return ('fish', 'white wine')
4 } else {
5 return ('steak', 'red wine');
6 }
7 }
8
9 my ($food, $beverage) = menu();
如果你把 return 语句排除在外，则在子例程内部运行的最后一个语句产生的值被返回。这意味着前一个例子可以简化为：
 
1 sub menu {
2 if rand < 0.5 {
3 'fish', 'white wine'
4 } else {
5 'steak', 'red wine';
6 }
7 }
8
9 my ($food, $beverage) = menu();
 
记得：当子例程中的控制流极其复杂时，添加一个显式的 return 会让代码更清晰，所以 return 还是加上的好。

return 另外的副作用就是执行后立即退出子例程：
 
1 sub create-world(*%characteristics) {
2 my $world = World.new(%characteristics);
3 return $world if %characteristics<temporary>;
4
5 save-world($world);
6 }
...并且你最好别放错你的新单词 $word 如果它是临时的。因为这是你要获取的仅有的一个。
 
 
4.4 返回值的类型
 
像其它现代语言一样，Perl 6 允许你显式地指定子例程返回值的类型。这允许你限制从子例程中返回的值的类型。使用 returns 特性可以做到这样： 
 
1 sub double-up($i) returns Int {
2 return $i * 2;
3 }
4
5 my Int $ultimate-answer = double-up(21);  # 42
当然，使用这个 returns 特性是可选的
 
4.5 Working With Types
 
很多子例程不能完整意义上使用任意参数工作，但是要求参数支持确定的方法或有其它属性。这种情况下，限制参数类型就有意义了，诸如传递不正确值作为参数，当调用子例程时，这会引起Perl 发出错误，或者甚至在编译时，如果编译器足够聪明来捕捉错误。
 
4.5.1 基本类型
最简单的限制子例程接收可能的值的方法是在参数前写上类型名。例如，一个子例程对其参数执行数值计算，这要求它的参数类型是 Numeric：
 
1 sub mean(Numeric $a, Numeric $b) {
2 return ($a + $b) / 2;
3 }
4
5 say mean 2.5, 1.5;
6 say mean 'some', 'strings';
产生输出：
2
Nominal type check failed for parameter '$a';
expected Numeric but got Str instead
nominal 类型是一个人实际类型的名字，这里是 Numeric。
如果多个参数有类型限制，每个参数必须填充它绑定的参数限制的类型
 
 
4.5.2  添加限制
 
有时，类型的名字不足以描述参数的要求。这种情况下，你可能使用 where 代码块添加一个额外的限制：
 
1 sub circle-radius-from-area(Real $area where { $area >= 0 }) {
2 ($area / pi).sqrt
3 }
4
5 say circle-radius-from-area(3); # OK
6 say circle-radius-from-area(-3); # Error
因为这种计算只对非负面积值有意义，该子例程的参数包含了一个限制，对于非负值它会返回真。如果这个限制返回一个假的值，类型检查会失败，当有些东西调用该子例程时。
 
where 之后的代码块是可选的。Perl 通过通过智能匹配where后面的参数来执行检查。 就
例如，它可能接受在某一确定范围中的参数：
 
1 sub set-volume(Numeric $volume where 0..11) {
2 say "Turning it up to $volume";
3 }
 
或者你可以将参数限制为散列的键：
 
1 my %in-stock = 'Staropramen' => 8, 'Mori' => 5, 'La Trappe' => 9;
2
3 sub order-beer(Str $name where %in-stock) {
4       say "Here's your $name";
5       %in-stock{$name}--;
6       if %in-stock{$name} == 0 {
7           say "OH NO! That was the last $name, folks! :'(";
8           %in-stock.delete($name);
9      }
10 }
4.6 抽象参数和具体参数
 
下面检测变量是否定义。
例如，下面是Perl5 代码:
1 sub foo {
2 my $arg = shift;
3 die "Argument is undefined" unless defined $arg;
4
5 # Do something
6 }
在Perl 6 中这样写:
 
1 sub foo(Int:D $arg) {
2 # Do something
3 }
留意附加在参数类型后面的 :D 笑脸。这个动词表明给定的参数必须被绑定到一个具体的对象上。如果不是的话，会抛出一个运行时异常。这就是为什么它那么高兴！作为对比， 动词 :U 用于表明该参数需要一个未定义的或抽象的对象。此外， 动词:_ 允许定义或未定义的值。实际上，使用 :_ 有点多余。
 
最后，动词 :T 能用于表明参数只能是类型对象，例如
 
1 sub say-foobar(Int:T $arg) {
2 say 'FOOBAR!';
3 }
4
5 say-foobar(Int);
6 # FOOBAR!
 
4.7 捕获
签字不仅仅是语法，它们是  first-class 含有一列参数对象的对象。同样地，有一种含有参数集的数据结构,叫捕获。捕获有位置和命名两个部分，表现的就像列表和散列。像列表的那部分含有位置参数，而像散列的那部分含有命名参数。
 
 
4.7.1 创建和使用一个捕获
 
无论你什么时间写下一个子例程调用，你就隐式地创建了一个捕获。然而，它随即被调用消耗了。有时，你想做一个捕获，存储它，然后将一个或多个子例程应用到它包含的一系列参数上。为了这，使用 n(...) 语法。
 
1 my @tasks = n(39, 3, action => { say $^a + $^b }),
2 n(6, 7, action => { say $^a * $^b });
 
这里，@tasks数组最后会包含两个捕获，每个捕获各含有两个位置参数和一个命名参数。捕获中的命名参数出现在哪并没有关系，因为他们是按名字传递，而非按位置。就像数组和散列，使用 | ，捕获也能被展平到参数列表中去:
 
1 sub act($left, $right, :$action) {
2 $action($left, $right);
3 }
4
5 for @tasks -> $task-args {
6 act(|$task-args);
7 }
 
However, in this case it is specifying the full set of arguments for the call, including both
named and positional arguments.
Unlike signatures, captures work like references. Any variable mentioned in a capture
exists in the capture as a reference to the variable. us rw parameters still work with
captures involved.
1 my $value = 7;
2 my $to-change = n($value);
3
4 sub double($x is rw) {
5 $x *= 2;
6 }
7
8 sub triple($x is rw) {
9 $x *= 3;
10 }
11
12 triple(|$to-change);
13 double(|$to-change);
14
15 say $value; # 42
Perl types with both positional and named parts also show up in various other situations. For example, regex matches have both positional and named matches–Match objects themselves are a type of capture. It’s also possible to conceive of an XML node type
that is a type of capture, with named attributes and positional children. Binding this node
to a function could use the appropriate parameter syntax to work with various children
and attributes.
 
4.7.2签字中的捕获
 
All calls build a capture on the caller side and unpack it according to the signature on
the callee side
5
. It is also possible to write a signature that binds the capture itself into a
variable. is is especially useful for writing routines that delegate to other routines with
the same arguments.
1 sub visit-czechoslovakia(|$plan) {
2 warn "Sorry, this country has been deprecated.";
3 visit-slovakia(|$plan);
4 visit-czech-republic(|$plan);
5 }
e benefit of using this over a signature like :(*@pos, *%named) is that these both enforce
some context on the arguments, which may be premature. For example, if the caller
passes two arrays, they would Ęatten into @pos. is means that the two nested arrays
could not be recovered at the point of delegation. A capture preserves the two array
arguments, so that the final callee’s signature may determine how to bind them.
5
An optimizing Perl 6 compiler may, of course, be able to optimize away part or all of this process,
depending on what it knows at compilation time.
46
 
4.8 Unpacking
 
有时候，你只需要使用一个数组或散列的一部分。你可以使用常规的切片获取，或使用签名绑定：
 
1 sub first-is-largest(@a) {
2 my $first = @a.shift;
3 # TODO: either explain junctions, or find a concise way to write without them
5 return $first >= all(@a);
6 }
7
8 # same thing:
9 sub first-is-largest(@a) {
10 my :($first, *@rest) := \(|@a)
11 return $first >= all(@rest);
12 }
the signature binding approach might seem clumsy, but when you use it in the main
signature of a subroutine, you get tremendous power:
1 sub first-is-largest([$first, *@rest]) {
2 return $first >= all(@rest);
3 }
th e brackets in the signature tell the compiler to expect a list-like argument. Instead
of binding to an array parameter, it instead unpacks its arguments into several parameters–in this case, a scalar for the first element and an array for the rest. is subsignature
also acts as a constraint on the array parameter: the signature binding will fail unless the
list in the capture contains at least one item.
Likewise you can unpack a hash by using %(...) instead of square brackets, but you must
access named parameters instead of positional.
1 sub create-world(%(:$temporary, *%characteristics)) {
2 my $world = World.new(%characteristics);
3 return $world if $temporary;
4
5 save-world($world);
6 }
 
# TODO: come up with a good example # maybe steal something from http://jnthn.net/papers/2010-yapc-eu-signatures.pdf
# TODO: generic object unpacking
 
4.9 Currying
 
Consider a module that provided the example from the \Optional Parameters" section:
1 sub order-burger( $type, $side? ) { ... };
If you used order-burger repeatedly, but oen with a side of french fries, you might wish
that the author had also provided a order-burger-and-fries sub. You could easily write
it yourself:
1 sub order-burger-and-fries ( $type ) {
2 order-burger( $type, side => 'french fries' );
3 }
If your personal order is always vegetarian, you might instead wish for a order-the-usual
sub. is is less concise to write, due to the optional second parameter:
1 sub order-the-usual ( $side? ) {
2 if ( $side.defined ) {
3 order-burger( 'veggie', $side );
4 }
5 else {
6 order-burger( 'veggie' );
7 }
8 }
Currying gives you a shortcut for these exact cases; it creates a new sub from an existing
sub, with parameters already filled in. In Perl 6, curry with the .assuming method:
1 &order-the-usual := &order-burger.assuming( 'veggie' );
2 &order-burger-and-fries := &order-burger.assuming( side => 'french fries' );
48
e new sub is like any other sub, and works with all the various parameter-passing
schemes already described.
1 order-the-usual( 'salsa' );
2 order-the-usual( side => 'broccoli' );
3
4 order-burger-and-fries( 'plain' );
5 order-burger-and-fries( :type<<double-beef>> );
 
4.10 自省
 
子例程和他们的签名都是对象。除了调用它们，你可以学习它们的东西，包括它们的参数的细节：
 
1 sub logarithm(Numeric $x, Numeric :$base = exp(1)) {
2        log($x) / log($base);
3        }
4
5 my @params = &logarithm.signature.params;
6 say @params.elems, ' parameters';
7
8       for @params {
9            say "Name: ", .name;
10          say " Type: ", .type;
11          say " named? ",     .named ?? 'yes' !! 'no';
12          say " slurpy? ",        .slurpy ?? 'yes' !! 'no';
13          say " optional? ", .optional ?? 'yes' !! 'no';
14  }
输出：
2 parameters
 
Name: $x
   Type: Numeric()
   named? no
   slurpy? no
   optional? no
Name: $base
   Type: Numeric()
   named? yes
   slurpy? no
   optional? yes
 


&logarithm.signature 返回这个子例程的签名，并对签名调用.params 方法，返回一个参数对象的列表。这些对象中的每个对象都详细描述一个参数。
Table 4.2: Methods in the Parameter class
# stolen straight from S06, adapted a bit
 

 
 
 
 
签名的自省允许你创建一个能获取并传递正确数据到子例程的接口，例如，你可以 创建一个知道如何获取用户输入的web表单生成器，检测它，然后根据通过自省获得的信息you could build a web form generator that knew
how to get input from a user, validate it, and then call a routine with it based upon the
information obtained through introspection. A similar approach might generate a command line interface along with some basic usage instructions.
Beyond this, traits (traits) allow you to associate extra data with parameters. is metadata can go far beyond that which subroutines, signatures, and parameters normally provide.
 
 
4.11   MAIN 子例程
 
Frequent users of the UNIX shells might have noticed a symmetry between postional
and named arguments to routines on the one hand, and argument and options on the
command line on the other hand.
is symmetry can be exploited by declaring a subroutine called MAIN. It is called every time the script is run, and its signature counts as a specification for command line
arguments.
 
1 # script roll-dice.pl
2 sub MAIN($count = 1, Numeric :$sides = 6, Bool :$sum) {
3       my @numbers = (1..$sides).roll($count);
4       say @numbers.join(' ');
5       say "sum: ", [+] @numbers if $sum;
6      }
7 # TODO: explain ranges, .pick and [+]
 
执行该脚本时可以带参数也可以不带参数：
 
$ perl6 roll-dice.pl
4
$ perl6 roll-dice.pl 4
1 4 2 4
$ perl6 roll-dice.pl --sides=20 3
18 1 2
$ perl6 roll-dice.pl --sides=20 --sum 3
9 14 12
sum: 35
$ perl6 roll-dice.pl --unknown-option
Usage:
roll-dice.pl [--sides=<Numeric>] [--sum] [<count>]
 
命名参数可以跟很多GNU工具一样，使用 --name=value 语法提供，而位置参数使用它们的值就好了。
 
如果选项没有要求参数，MAIN 签字里的参数需要被标记为 Bool 类型。
使用未知选项或太多或太少的参数会触发一个自动生成的用法通知，它可以用一个普通的 USAGE 子例程重写：
 
1  sub MAIN(:$really-do-it!) { ... }
2      sub USAGE() {
3      say "This script is dangerous, please read the documentation first";
4    }
 
 
第八章 子类
 
1 enum Suit <spades hearts diamonds clubs>;
2 enum Rank (2, 3, 4, 5, 6, 7, 8, 9, 10,
3                     'jack', 'queen', 'king', 'ace');
4
5 class Card {
6      has Suit $.suit;
7      has Rank $.rank;
8
9 method Str {
10       $.rank.name ~ ' of ' ~ $.suit.name;
11      }
12 }
13
14 subset PokerHand of List where { .elems == 5 && all(|$_) ~~ Card }
15
16 sub n-of-a-kind($n, @cards) {
17      for @cards>>.rank.uniq -> $rank {
18      return True if $n == grep $rank, @cards>>.rank;
19     }
20 return False;
21 }
22
23 subset Quad of PokerHand where               { n-of-a-kind(4, $_) }
24 subset ThreeOfAKind of PokerHand where { n-of-a-kind(3, $_) }
25 subset OnePair of PokerHand where           { n-of-a-kind(2, $_) }
26
27 subset FullHouse of PokerHand where OnePair & ThreeOfAKind;
28
29 subset Flush of PokerHand where -> @cards { [==] @cards>>.suit }
30
31 subset Straight of PokerHand where sub (@cards) {
32           my @sorted-cards = @cards.sort({ .rank });
33           my ($head, @tail) = @sorted-cards;
34           for @tail -> $card {
35                   return False if $card.rank != $head.rank + 1;
36                  $head = $card;
37             }
38  return True;
39 }
40
41 subset StraightFlush of Flush where Straight;
42
43 subset TwoPair of PokerHand where sub (@cards) {
44            my $pairs = 0;
45            for @cards>>.rank.uniq -> $rank {
46                 ++$pairs if 2 == grep $rank, @cards>>.rank;
47  }
48 return $pairs == 2;
49 }
50
51 sub classify(PokerHand $_) {
52      when StraightFlush    { 'straight flush', 8    }
53      when Quad                { 'four of a kind', 7    }
54      when FullHouse         { 'full house', 6         }
55      when Flush                 { 'flush', 5                 }
56      when Straight             { 'straight', 4             }
57      when ThreeOfAKind   { 'three of a kind', 3 }
58      when TwoPair             { 'two pair', 2            }
59      when OnePair             { 'one pair', 1            }
60      when *                        { 'high cards', 0         }
61 }
62
63 my @deck = map -> $suit, $rank { Card.new(:$suit, :$rank) },
64                        (Suit.pick(*) X Rank.pick(*));
65
90
66 @deck .= pick(*);
67
68 my @hand1;
69 @hand1.push(@deck.shift()) for ^5;
70 my @hand2;
71 @hand2.push(@deck.shift()) for ^5;
72
73 say 'Hand 1: ', map { "\n $_" }, @hand1>>.Str;
74 say 'Hand 2: ', map { "\n $_" }, @hand2>>.Str;
75
76 my ($hand1-description, $hand1-value) = classify(@hand1);
77 my ($hand2-description, $hand2-value) = classify(@hand2);
78
79 say sprintf q[The first hand is a '%s' and the second one a '%s', so %s.],
80 $hand1-description, $hand2-description,
81 $hand1-value > $hand2-value
82         ?? 'the first hand wins'
83         !! $hand2-value > $hand1-value
84                    ?? 'the second hand wins'
85                    !! "the hands are of equal value"; # XXX: this is wrong
 
第九章 模式匹配
 
 
 
尽管 Perl 6 中描述的语法跟 PCRE 和 POSIX 已经不一样了，我们还是叫它们regex.
 
eg：查找连续重复2次的单词
my $s = 'the quick brown fox jumped over the the lazy dog';
if $s ~~ m/ << (\w+) \W+ $0 >> / {say "Found '$0' twice in a row";}
Found 'the' twice in a row
 
<< 和 >> 是单词边界。
 
1 if 'properly' ~~ m/ perl / {
2 say "'properly' contains 'perl'";
3 }
 
m/ ... / 结构创建了一个正则表达式。默认地，正则表达式中的空格是无关紧要的，你可以写成 m/perl/, m/ perl /,甚至 m/p e rl/。
 
只有单词字符，数字和下划线在正则表达式中代表字面值。其它所有的字符可能有特殊的意思。如果你想搜索逗号，星号或其它非单词字符，你必须引起或转义它：
 
1 my $str = "I'm *very* happy";
2
3 # quoting
4 if $str ~~ m/ ' *very* ' / { say '\o/' }
5
6 # escaping
7 if $str ~~ m/ \* very \* / { say '\o/' }
 
正则表达式支持特殊字符，点( . ) 匹配任意一个字符。
 
1 my @words = <spell superlative openly stuff>;
2
3 for @words -> $w {
4 if $w ~~ m/ pe.l / {
5 say "$w contains $/ ";
6 } else {
7 say "no match for $w";
8 }
9 }
 
这打印：
spell contains pell
superlative contains perl
openly contains penl
no match for stuff
 
点匹配了l,r和n，但是在句子 the spectrosco pe l acks resolution 中正则表达式默认忽略单词边界。
特殊变量 $/ 存储匹配到的对象，这允许你检测匹配到的文本。
 
 
 
Table 9.1: 反斜线序列和它们的意思
 
 
\加上一个大写字母代表上面表格的相反意思：\W 匹配一个非单词字符，　\N 匹配一个不是换行符的单个字符。
 
这些匹配超越了ASCII表的范围—— \d 匹配拉丁数字、阿拉伯数字和梵文数字和其它数字， \s 匹配非中断空白，等等。这些字符类遵守Unicode关于什么是字母、数字等的定义。
 
你可以自定义你的字符类，将合适的字符列在嵌套的尖括号和方括号中： <[ ... ]>
 
1 if $str ~~ / <[aeiou]> / {
2 say "'$str' contains a vowel";
3 }
4
5 # negation with a -
6 if $str ~~ / < - [aeiou]> / {
7 say "'$str' contains something that's not a vowel";
8 }
 
也可以在字符类中使用范围操作符：
 
1 # match a, b, c, d, ..., y, z
2 if $str ~~ / <[a..z]> / {
3 say "'$str' contains a lower case Latin letter";
4 }
你也可以使用 + 和 - 操作符将字符添加到字符类 或 从字符类中减去字符：
 
1 if $str ~~ / <[a..z] + [0..9]> / {
2 say "'$str' contains a letter or number";
3 }
4
5 if $str ~~ / <[a..z] - [aeiou]> / {
6 say "'$str' contains a consonant（辅音）";
7 }
 
 
在字符类里面，非单词字符不需要被转义，一般使用它们的特殊意义。所以 /<[+.*]>/匹配一个加号，或一个点或一个星号。需要转义的就是反斜线 / 和破折号 -  。
 
1 my $str = 'A character [b] inside brackets';
2 if $str ~~ / '[ ' < - [ \[ \] ]> ']' / ) {  #  \[ \] 匹配 一个 非[ 和 非] 字符
3 say "Found a non-bracket character inside square brackets';
4 }
 
量词 跟Perl5 中的用法相似：如 ? 表示重复前面的东西0次或一次； *表示重复前面的东西0次或多次，+ 号表示重复前面的东西 1次或多次。
 
最普遍的量词是 ** ，当它后面接一个数字number时，表示匹配前面的东西number 次。Perl 5 中用 {m,n}
当 ** 后面跟着 一个范围时，它能匹配范围中的任何数字次数的东西
 
1 # match a date of the form 2009-10-24:
2 m/ \d**4 '-' \d\d '-' \d\d /
3
4 # match at least three 'a's in a row:
5 m/ a ** 3..* /
 
可以使用 % 号在量词后面指定一个 分隔符 ：
  '1,2,3' ~~ / \d+ % ',' /
分隔符也可以是一个正则表达式。
 
贪婪匹配和非贪婪匹配：
 
1 my $html = '<p>A paragraph</p> <p>And a second one</p>';
2
3 if $html ~~ m/ '<p>' .* '</p>' / {
4 say 'Matches the complete string!';
5 }
6
7 if $html ~~ m/ '<p>' .*? '</p>' / {
8 say 'Matches only <p>A paragraph</p>!';
9 }
 
 
1 my $ingredients = 'milk, flour, eggs and sugar';
2 # prints "milk, flour, eggs"
3 $ingredients ~~ m/ [\w+]+ % [\,\s*] / && say "|$/|";
# |milk, flour, eggs|
这里 \w 匹配一个单词，并且 [\w+]+ % [\,\s*]  匹配至少一个单词，并且单词之间用逗号和任意数量的空白分隔。
> '1,2,3' ~~ / \d+ % ',' / && say "|$/|";
|1,2,3|
%必须要跟在量词后面，否则报错。
 
选择分支：
$string ~~ m/ \d**4 '-' \d\d '-' \d\d | 'today' | 'yesterday' /
 一个竖直条意味着分支是并行匹配的，并且最长匹配的分支胜出。两个竖直条会让正则引擎按顺序尝试匹配每个分支，并且第一个匹配的分支胜出。
 
9.1 锚
 
 
 
9.2 捕获
 
圆括号里的匹配被捕获到特殊数组 $/ 中，第一个捕获分组存储在 $/[0]中，第二个存储在  $/[1]中，以此类推。
 
use v6;
my $str = 'Germany was reunited on 1990-10-03, peacefully';
 
if $str ~~ m/ (\d**4) \- (\d\d) \- (\d\d) / {
say 'Year: ',"$/[0]";
say 'Month: ',"$/[1]";
say 'Day: ',"$/[2]";
# usage as an array:
say $/.join('-'); # prints 1990-10-03
}
 
Year: 1990
Month: 10
Day: 03
1990-10-03
 
如果你在捕获后面加上量词，匹配对象中的对应的项是一列其它对象：
 
 
use v6;
my $ingredients = 'eggs, milk, sugar and flour';
 
if $ingredients ~~ m/(\w+)+ % [\,\s*] \s* 'and' \s* (\w+)/ {
say 'list: ', $/[0] .join(' | ');
say 'end: ', " $/[1] ";
}
 
这打印:
list: eggs | milk | sugar
end: flour
 
第一个捕获(\w+)被量词化了，所以$/[0]包含一列单词。代码调用 .join方法将它转换为字符串。 不管第一个捕获匹配了多少次（并且有$/[0]中有多少元素），第二个捕获$/[1]始终可以访问。
 
作为一种便捷的方式，$/[0] 可以写为 $0, $/[1] 可以写为 $1,等等。这些别名在正则表达式内部也可使用。这允许你写一个正则表达式检测普通的单词重复错误，就像本章开头的例子：
 
my $s = 'the quick brown fox jumped over the the lazy dog';
if $s ~~ m/ << (\w+) \W+ $0 >> / {say "Found '$0' twice in a row";}
Found 'the' twice in a row
 
如果没有第一个单词边界锚点，它会匹配   str and and
beach or la the the table leg. 没有最后的单词边界锚点，它会匹配 the the ory.
 
9.3 命名正则
 
你可以像申明子例程一样申明正则表达式——甚至给它们起名字。假设你发现之前的例子很有用，你想让它更容易被访问。假设你想扩展这个正则让它处理诸如 doesn't 或 isn't 的缩写：
my regex word { \w+ [ \' \w+]? }
my regex dup { « < word = &word > \W+ $<word> » }
if $s ~~ m/ <dup=&dup> / {
say "Found '{ $<dup><word> }' twice in a row";
}
 
这段代码引入了一个名为 word 的正则表达式，它至少匹配一个单词字符，后面跟着一个可选的单引号和更多的单词字符。另外一个名为 dup （duplcate的缩写，副本的意思）的正则包含一个单词边界锚点。
在正则里面，语法 <&word> 在当前词法作用域内查找名为word的正则并匹配这个正则表达式。 <name=&regex> 语法创建了一个叫做 name的捕获，它记录了 &regex 匹配的内容。
 
在这个例子中，dup 调用了名为 word 正则，随后匹配至少一个非单词字符，之后再匹配相同的字符串（ 前面word 正则匹配过的）一次，它以另外一个字符边界结束。这种向后引用的语法记为美元符号 $  后面跟着用尖括号包裹着捕获的名字。
 
在 if 代码块里， $<dup> 是  $/{'dup'} 的快捷写法。它访问正则 dup 产生的匹配对象。dup 也有一个叫 word 的子规则。从那个调用产生的匹配对象用 $<dup><word>来访问。
 
命名捕获让组织复杂正则更容易。
 
9.4 修饰符
 
s修饰符是 :sigspace  的缩写，该修饰符允许可选的空白出现在文本中无论哪里有一个或更多空白字符出现在模式中。它甚至比那更聪明：在两个单词字符之间，空白字符是任意的。该 regex 不匹配字符串 eggs,milk, sugarandflour.
 
use v6;
my $ingredients = 'eggs, milk, sugar and flour';
 
if $ingredients ~~ m/ :s ( \w+ )+ % \,'and' (\w+)/ {
say 'list: ', $/[0].join(' | ');
say 'end: ', "$/[1]";
}
 
list: eggs |  milk |  sugar
end: flour
 
9.5 回溯控制
 
当用 m/\w+ 'en'/ 匹配字符串 oxen时，\w+ 首先匹配全部字符串oxen，因为 +是贪婪的，然后 'en' 不能匹配任何东西。 \w+ 丢弃一个字符，匹配了 oxe，但是 ‘en'还是不能匹配，\w+ 继续丢弃一个字符，匹配 ox, 然后 'en'匹配成功。
 
一个冒号开关（ : ） 可以为之前的量词或分支关闭回溯。 所以 m / \w+: 'en'/不会匹配任何字符串，因为 \w+ 总是吃光所有的单词字符，从不回退。
 
 :ratchet （防止倒转的制轮装置） 修饰符让整个 正则的回溯功能失效，禁止回溯让 \w+ 总是匹配一个完整的单词:
 
1 # XXX: does actually match, because m/<&dup>/
2 # searches for a starting position where the
3 # whole regex matches. Find an example that
4 # doesn't match
5
6 my regex word { :ratchet \w+ [ \' \w+]? }
7 my regex dup { <word=&word> \W+ $<word> }
8
9 # no match, doesn't match the 'and'
10 # in 'strand' without backtracking
11 'strand and beach' ~~ m/<&dup>/
 
 :ratchet 只影响它出现的正则中。外围的正则依然会回溯，所以它能在不同的起始位置重新尝试匹配 正则 word  。正则 { :ratchet ... } 模式太常用了，它有它自己的快捷方式： token { ... } . 惯用的重复单词搜索可能是这样的：
 
1 my token word { \w+ [ \' \w+]? }
2 my regex dup { <word> \W+ $<word> }
 
带有 :sigspace 修饰符的令牌是一个 rule:
1 # TODO: check if it works
2 my rule wordlist { <word>+ % \, 'and' <word> }
 
9.6 替换
 
正则表达式对于数据操作很好用。 subst 方法用一个正则跟一个字符串匹配。
 当subst 匹配的时候，它用它的第二个操作数替换掉匹配到的部分字符串：
 
1 my $spacey = 'with    many     superfluous      spaces';
2
3 say $spacey.subst(rx/ \s+ /, ' ' , :g );
4 # output: with many superfluous spaces
 
默认地，subst执行一个单个替换然后停止。 :g 告诉替换是全局的，它替换每个可能的匹配。
注意  这里使用 rx/ ... / 而不是 m/ ... / 来构建这个正则。前者构建一个正则表达式对象。后者构建一个正则对象然后立即用它匹配主题变量 $_ 。调用subst时使用 m/ ... / 会创建一个匹配对象并且将它作为第一个参数传递，而不是传递正则表达式本身。 
 
9.7其它正则表达式特性
 
有时候你需要调用其它正则，但是不想让它们捕获匹配的文本。当解析编程语言的时候，你可能想删除空白字符和注释。你可以调用 <.otherrule> 完成。如果你用 :sigspace 修饰符，每个连续的空白块调用内建的规则 <.ws> 。使用这个规则而不是使用字符类允许你定义你自己的空白字符版本。
有些时候你仅仅想前视一下以查看下面的字符是否满足某些属性而不消耗这些字符。这在替换中很有用。在一般的英文文本中，你总是在逗号后面添加一个空格。如果某些人忘记了添加空格，正则能够在慵懒的写完之后整理：
 
1 my $str = 'milk,flour,sugar and eggs';
2 say $str.subst(/',' < ?before \w>/, ', ', :g);  #向前查看
3 # output: milk, flour, sugar and eggs
 
内建的 token <alpha> 匹配一个字母表字符，所以你可以重写这个例子：
1 say $str.subst(/',' <?alpha>/, ', ', :g);
前置感叹号反转上面的意思，否定前视:
say $str.subst(/',' <!space>/, ', ', :g);
向后环视<?after>.
Table 9.3: 用环视断言模拟锚点
 

 
9.8 匹配对象
 
1 sub line-and-column(Match $m) {
2        my $line = ($m.orig.substr(0, $m.from).split("\n")).elems;
3        # RAKUDO workaround for RT #70003, $m.orig.rindex(...) directly fails
4        my $column = $m.from - ('' ~ $m.orig).rindex("\n", $m.from);
5       $line, $column;
6 }
7
8    my $s = "the quick\nbrown fox jumped\nover the the lazy dog";
9
10 my token word { \w+ [ \' nw+]? }
11 my regex dup { <word> \W+ $<word> }
12
13 if $s ~~ m/ <dup> / {
14    my ($line, $column) = line-and-column($/);
15    say "Found '{$<dup><word>}' twice in a row";
16    say "at line $line, column $column";
17  }
18
19 # 输出:
20 # Found 'the' twice in a row
21 # at line 3, column 6
 
每个正则匹配返回一个类型为 Match 的对象。在布尔上下文中，匹配对象在匹配成功时返回真，匹配失败时返回假。
 
orig 方法返回它匹配的字符串，from 和 to 方法返回匹配的开始位置和结束点。
 
在前面的例子中， line-and-column 函数探测在匹配中行号出现的位置， 通过提取字符串直到匹配位置($m.orig.substr(0,$m.from)), 用换行符分隔它， 并计算元素个数。它通过从匹配位置向后搜索并计算与匹配位置的不同来计算列数 。index方法在一个字符串中搜索一个字串并且返回在搜寻字符串中的位置。rindex方法与之相同，但是它从字符串末尾想后搜索，所以它查找字串最后出现的位置。
 
Using a match object as an array yields access to the positional captures. Using it as a hash
reveals the named captures. 在前面的例子中, $<dup> 是 $/<dup> 或 $/{ 'dup' } 的快捷写法。这些捕获又是 Match 对象，所以匹配对象实际是匹配树。
 
  caps 方法返回所有的捕获，命名的和位置的，按照它们匹配的文本在原始字符串中出现的顺序返回。返回的值是一个 Pair 对象列表。键值是捕获的名字或数量，键值是对应的 Match 对象。
 
1 if 'abc' ~~ m/(.) <alpha> (.) / {
2            for $/ .caps {
3                    say .key, ' => ', .value;
4
5             }
6 }
7
8 # Output:
9 #          0 => a
10 # alpha => b
11 #        1 => c
 
在这种情况下，捕获以它们在正则中的顺序出现，但是量词可以改变这种情况。即使如此， $/.caps 后面跟着有顺序的字符串，而不是一个正则。
字符串的某一部分匹配但是不是捕获的一部分不会出现在caps 方法返回的值中。
 
为了访问非捕获部分，用 $/. 代替。它返回匹配字符串的捕获和非捕获两部分，跟  caps 的格式相同但是带有一个 ~ 符号作为键。如果没有重叠的捕获（出现在环视断言中）,所有返回的 pair 值连接与匹配部分的字符串相同。
第十章 语法
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

第11章 内建类型、操作符和方法
 
很多操作符需要特别的数据类型才能工作。如果操作数的类型与要求的不同，Perl 会复制一份操作数，并加盖它们转换为需要的类型。例如， $a + $b 会将$a和 $b的副本转换为数字（除非它们已经是数字了）。这种隐式的转换叫做强制变换。除了操作符之外，其它句法元素也强制转换它们的元素： if 和 while 会强制值为真（布尔）， for 会把东西看作列表，等等。
 
11.1 数字
 
最重要的类型是整数型:
Int
 
Int 对象存储任意大小的整数。如果你写出一个只含有数字的字面量，例如 12 ，那它就是整形。
 
Num
Num 是浮点型，它存储固定宽度的符号、尾数和指数。包含 Num 数字的计算通通常很快， though subject to limited precision.
诸如 6.022e23 使用科学计数法标记的是 Ｎum 类型。
 
 
Rat 有理数
Rat, 有理数的简称, 存储分数，不损失精度。它将跟踪它的分子和分母作为整数，所以使用大量的针对对有理数的数学运算会相当慢。因为这，含有大分母的有理数会自动降级为 Num。
 
3.14是有理数。
 
Complex
 
复数有两部分组成:实部和虚部。 If 任一部分是 NaN,则整个数字可能都是 NaN。
复数的形式是 a + bi,其中 bi 是虚数部分，其类型为复数。
 


很多数学函数都有方法和函数两种形式，例如 (-5).abs 和 abs(-5) 结果一样.
 
三角函数 sin, cos, tan, asin, acos, atan, sec, cosec, cotan, asec,
acosec, acotan, sinh, cosh, tanh, asinh, acosh, atanh, sech, cosech, cotanh, asech, acosech 和 acotanh 默认使用弧度作为单位。 你可以指定Degrees, Gradians or Circles参数作为单位。例如,180.sin(Degrees) 近似于 0 。
 
                                      表 11.1 二元数字操作符
    
 
Table 11.2: 一元数字操作符
操作符      描述
             +             转换为数字
-              负
 
 
数学函数和方法
 
 
11.2 字符串
 
根据字符编码，字符串存储为 Str，它是字符序列。 Buf 类型用作存储二进制数据，  encode 方法将 Str  转换为 Buf. decode 相反。
 
字符串操作：
Table 11.4: 二元字符串操作符
操作符 描述
                       ~         连接: 'a' ~'b' 是 'ab'
                    x         重复: 'a' x 2 is 'aa'
 
Table 11.5: 一元 字符串操作符
操作符  描述
                                      ~    转换为字符串: ~1 变成 '1'
 
Table 11.6: 字符串方法/函数
方法/函数                                  描述
                       .chomp                                        移除末尾的新行符
                                                                                       .substr($start,$length)                 提取字符串的一部分。默认的，$length是字符串的剩余部分
                               .chars                                    字符串中的字符数
                .uc                                    大写
              .lc                                       小写
                         .ucfirst                      首字符转换为大写
                      .lcfirst                                           首字符转换为小写
                                                                       .capitalize                                将每个单词的首字符转换为大写，其余字符转换为小写
 
11.3 布尔
 
布尔值要么为真，要么为假。在布尔上下文中，任何值都可以转化为布尔值。决定一个值是真是假要根据值的类型：
 
字符串
 
空字符串和 字符串  "0" 的值为假。任何其它字符串的值为真。
 
数字
除了 0 之外的所有数字的值为真。
 
列表和散列
 
诸如列表和散列等容器类型的值为假，如果它们是空的话，如果至少包含一个值，则为真。
 
诸如 if 之类的结构会自动在布尔上下文中求值。你可以在表达式前面放一个问号 ? 来强制一个显式的布尔上下文。用前缀符号   ! 反转布尔值。
 
1 my $num = 5;
2
3 # 隐式的布尔上下文
4 if $num { say "True" }
5
6 # 显式的布尔上下文
7 my $bool = ?$num ;
8
9 # negated boolean context
10 my $not_num = !$num;
 
 