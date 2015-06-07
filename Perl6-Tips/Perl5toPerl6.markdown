# Perl 5 to Perl 6

标签（空格分隔）： Perl6

---

[TOC]

##     00  介绍

##     01  字符串、数组、散列

字符串、数组和哈希

概要

```perl
my $five = 5;
print "an interpolating string, just like in perl $five\n";
say 'say() adds a newline to the output, just like in perl 5.10';
```

```perl
my @array = 1, 2, 3, 'foo';
my $sum = @array[0] + @array[1];
if $sum > @array[2] {
    say "not executed";
}
my $number_of_elems = @array.elems;     # 或者使用 +@array
my $last_item = @array[*-1];
```

```perl
my %hash = foo => 1, bar => 2, baz => 3;
say %hash{'bar'};     # 2
say %hash<bar>;       # 同上, 会自动的加上双引号 
                      # 在这使用 %hash{bar} 是错误的
                      # 没加引号的字符, 这会试着调用 bar 函数. 但这不存在
                      # 因为花括号里面的东西会被当做表达式来计算！
```
描述

Perl 6 这些部分很象 Perl 5 - 只会变得更加友好. 声明的语句还是以`分号`终止. 在代码块中最后的语句和在行结束的右大括号的分号终止符是可选的.

变量仍然以记号 (像 $, @, %)开头.

字符串

字符串是用双引号包起来 ( 插值的情况下 ), 或者使用单引号. 反斜杠转义的工作方式和 Perl 5 中一样.

然而插值规则已经改变了一点. 看下面插值
```perl
my $scalar = 6;
my @array = 1, 2, 3;
say "Perl $scalar";         # 'Perl 6'
say "An @array[]";          # 'An 1 2 3', a so-called "Zen slice"
say "@array[1]";            # '2'
say "Code: { $scalar * 2 }" # 'Code: 12'
```
数组和哈希只有当后面跟 `索引` 的时候才会插值 ( 或者 `方法调用`, 象 `some $obj.method()` ), `空索引` 会给整个数据结构做插值操作.

当出现了一个花括号时会执行花括号中的代码`用结果`进行插值操作.

数组

数组还是以 @ 标记开始. 并且他们总是这样 ( 在 Perl 5 中元素文章不是 @ 是 $ ), 就算访问数组中的元素也是使用 @ 开头. ie. 这个索引需要存在, 这个对新手学习就不再会晕了.
```
my  @a = 5, 1, 2;            # 不再需要括号 
say @a[0];                   # 没错, 是以 @ 开头 
say @a[0, 2];                # 数组切片也能正常工作
```
列表的构造是通过 `逗号`, 不再需要括号. `1,` 是一个列表, `(1)` 不是.

既然一切都是对象，你可以调用数组的方法:
```perl
my @b = @a.sort;
@b.elems;                   # 成员元素数量 
if @b > 2 { say "yes" }     # 仍然可以这样 
@b.end;                     # 最后一个索引的位置, 替换 $#array
my @c = @b.map({$_ * 2 });  # 没错, map 也是个方法调用
```
下面的方法是替换老的 `qw/../` 来进行字符数组的构造:
```perl
my @methods = <shift unshift push pop end delete sort map>;
```
哈希

Perl 6 在列表上下文时哈希是列表对. 列表对可以做一些其它的事情, 它可以是子函数的名字, 稍后详述.

就象数组使用的开头的标记不变, 哈希也是一样. 当你创建索引时使用 % 开头. 并且 hash 也有自己的方法调用.
```perl
my %drinks =
    France  => 'Wine',
    Bavaria => 'Beer',
    USA     => 'Coke';

say "The people in France love ",  %drinks{'France'};
my @countries = %drinks.keys.sort;
```
注意, 当你访问哈希的元素是通过 `%hash{...}`, 这个 key 不会象 Perl 5 自动的加引号. 所以 %hash{foo} 并不能访问到索引 "foo" 的元素. 这会调用 `foo()` 的函数. 需要自动的对字符加引号就需要如下这种不同的语法:
```perl
say %drinks<Bavaria>;
```
最后的注意事项

大多内置的方法, 既作为一种方法也可以做为 sub 调用. 所以你可以写在 `sort @array` 或者 `@array.sort`.

最后, 你需要知道这 `[..]` 和 `{...}` 这两个东西, 现在它们只是方法调用的特殊语法, 在这不是绑定数组和哈希. 这意味着, 他们也不会依赖于特定的前缀符号.
```perl
my  $a = [1, 2, 3];
say $a[2];          # 3
```
这意味着, 我们不需要特殊的引用和解引用的语法, 并且您可以创建能够同时充当数组, 哈希和 sub 子函数的对象.

另请参阅

http://perlcabal.org/syn/S02.html, http://perlcabal.org/syn/S29.html

##     02  类型
概要
```perl
my Int $x = 3;
$x = "foo";         # error
say $x.WHAT;        # 'Int()'

# 类型检查 
if $x ~~ Int {
    say '$x contains an Int';
}
```
描述

Perl 6 中有了类型这东西. 在 Perl 6 中任何东西都是对象, 都自己的类型. 变量虽然可以有类型的限制, 并他们并不是必需的.

有一些基本的常用类型, 你必须知道的:

    'a string'      # Str
    2               # Int
    3.14            # Rat (rational number)
    (1, 2, 3)       # Seq

全部 "标准" 的内置类型都是大写字母开头. 全部 "标准" 类型继承 "Any", 所有的类型都继承 Mu.

你可以限制变量存储的值所用的类型, 只要你在声明的时候指定变量类型.
```perl
my Numeric $x = 3.4;
my Int @a = 1, 2, 3;
```
如果试图存一个错误类型的值到变量会提示出错.

类型的声明也适用于数组的包含的元素内容, 所以 `my Str @s` 是指定这个数组只能包含字符串.

有某些类型可以代表更加具体的类型, 象 `integers` (type Int), `rationals` (type Rat) 和 `浮点数` (type Num) 这些都是 Numeric 类型.

自省

你可以通过调用 `.WHAT` 方法了解对象的详细类型.
```perl
say "foo".WHAT;     # Str()
```
如果你想检查一些东西的类型, 有不同的方式, 也需要考虑到类型的继承, 所以建议使用下面的方法:
```perl
if $x ~~ Int {
    say 'Variable $x contains an integer';
}
```
动机

这个类型系统让我们很容易了解所有的细节. 为什么我们需要类型, 使用他们也有很多理由:

[程序更加安全]

如果你声明了一些东西是特定的类型, 你就可以肯定的在上面执行某些操作, 并不需要检查它是什么.

[优化]

当你在编译的时候有类型的信息, 可以执行更多的优化, Perl 6 原则上不一定比 C 慢.

[扩展性]

当有类型信息时, 使用 multiple dispatch 时更加容易细化特定的操作.

另请参阅

http://perlcabal.org/syn/S02.html#Built-In_Data_Types,

##     03  控制结构
概要
```perl
if $percent > 100  {
    say "weird mathematics";
}

for 1..3 {
    # 在循环中使用 $_
    say 2 * $_;
}

for 1..3 -> $x {
    # 有明确的循环变量
    say 2 * $x;
}

while $stuff.is_wrong {
    $stuff.try_to_make_right;
}

die "Access denied" unless $password eq "Secret";
```
描述

大多 Perl 5 的控制结构和 Perl 6 颇为相似, 如果从视觉差异上来讲, 你可以见到在使用 `if`, `while`, `for` 之类不再需要一对括号.

为什么没有括号了, 当任何标识符后面紧跟着 (无空格) 左括号时很容易被解析成子程序调用. 所以 if($x < 3) 很容易理解变成调用 if 函数的调用. 所以这样更加安全, 还不需要写括号.

分支控制

if 功能大部分没在变化, 仍然可以添加 `elsif` 和 `else` 分支. `unless` 仍然存在，但是在 unless 之后没有了 else 分支.
```perl
my $sheep = 42;
if $sheep == 0 {
    say "How boring";
} elsif $sheep == 1 {
    say "One lonely sheep";
} else {
    say "A herd, how lovely!";
}
```
你现在还是可以使用 `if` 和 `unless` 做语句修饰, 即后声明方式来使用.（`倒装句方式`）
```perl
say "you won" if $answer == 42;
```
循环

你可以通过 next 和 last 来控制循环就象 Perl 5 一样.

在这 for 循环现在只用于遍历列表. 默认是操作 `$_` 变量, 除非显式的指出变量名.
```perl
for 1..10 -> $x {
    say $x;
}
```
在这的 `-> $x { ... }` 是叫做 "pointy block" 这就象一个匿名的子函数或者 lisp 中的 lambda 操作.

你也可以使用一个以上的循环变量:
```perl
for 0..5 -> $even, $odd {
    say "Even: $even \t Odd: $odd";
}
```
这也是遍历哈希值的好方法:
```perl
my %h = a => 1, b => 2, c => 3;
for %h.kv -> $key, $value {
    say "$key: $value";
}
```
C-style 的 for 循环现在叫做 loop ( 这是唯一需要括号的循环结构 ):
```perl
loop (my $x = 2; $x < 100; $x = $x**2) {
    say $x;
}
```
另请参阅

[http://perlcabal.org/syn/S04.html#Conditional_statements]
##     04  子例程和签名
概要
```perl
# Perl 5 中传参的方式
sub print_arguments {
    say "Arguments:";
    for @_ {
        say "\t$_";
    }
}
```
```perl
# 参数在这个地方使用固定的位置和指定的类型:
sub distance(Int $x1, Int $y1, Int $x2, Int $y2) {
    return sqrt ($x2-$x1)**2 + ($y2-$y1)**2;
}
say distance(3, 5, 0, 1);

# 默认参数 
sub logarithm($num, $base = 2.7183) {
    return log($num) / log($base)
}
say logarithm(4);       # 这会给第二个参数使用默认的值
say logarithm(4, 2);    # 明确的指定第二个参数 

# 命名参数

sub doit(:$when, :$what) {
    say "doing $what at $when";
}
doit(what => 'stuff', when => 'once');     # 'doing stuff at once'
doit(:when<noon>, :what('more stuff'));    # 'doing more stuff at noon'
# illegal: doit("stuff", "now")
```
描述

子函数是使用 sub 关键字来声明, 并且有形式参数列表, 就象 C, Java 和一些其它的语言. 这些参数有 `可选的` 类型约束.

参数默认是 `只读` 的. 可通过 "traits" 来修改成可以读写.
```perl
sub try-to-reset($bar) {
    $bar = 2;         # 禁止修改参数
}

my $x = 2;
sub reset($bar is rw) {
    $bar = 0;         # 可以修改
}
reset($x); say $x;    # 0

sub quox($bar is copy){
    $bar = 3;
}
quox($x); say $x      # still 0
```
参数可以在后面增加一个问号来标记是否`可选`.
```perl
sub foo($x, $y?) {
    if $y.defined {
        say "Second parameter was supplied and defined";
    }
}

sub bar($x, $y = 2 * $x) {
    ...
}
```
命名参数

当你像这样  `my_sub($first, $second)` 调用一个子例程时，`$first`参数绑定到前面的第一个参数，`$second`参数绑定给后面的第二个参数，这就是它们被叫做位置参数的原因。

有时, 我们希望使用更加容易记住的名字, 而不是数字之类. 这是为什么使用命名参数的原因:
```perl
my $r = Rectangle.new(
        x       => 100,
        y       => 200,
        height  => 23,
        width   => 42,
        color   => 'black'
);
```
当你看到这些名字, 你马上知道参数具体是什么含义。

要定义一个命名参数, 你只需要给 `:` 放在参数之前:
```perl
sub area(:$width, :$height) {
    return $width * $height;
}
area(width => 2,  height => 3);
area(height => 3, width => 2 ); # 同上 
area(:height(3), :width(2));    # 同上
```
这最后一个例子使用的是叫 `colon pair syntax` 的语法. 当给使用 `:draw-perimeter` 给其赋布尔值的时候, 你什么都不写默认是 True, 当想给一个参数赋值为布尔类型的 FALSE 的时候，也不需要写明 0，而是用以下格式  :!transparent
```perl
:draw-perimeter              # same as "draw-perimeter => True"
:!transparent                # same as "transparent    => False"
```
在命名参数的声明中, 变量也被用来作为参数. 您可以使用不同的名称:
```perl
sub area(:width($w), :height($h)) {
    return $w * $h;
}
area(width => 2,  height => 3);
```
Slurpy 参数

你给你的 sub 提供参数的时候, 有时并不知道所有的参数个数. 你可以定义一种称作 `slurpy` 参数(在所有普通参数后面), 它会用光剩余的任何参数:
```perl
sub tail ($first, *@rest){
    say "First: $first";
    say "Rest: @rest[]";
}
tail(1, 2, 3, 4);           # "First: 1\nRest: 2 3 4\n"
```
对于哈希, 命名的 slurpy 参数定义是使用有 * 号前缀的哈希参数:
```perl
sub order-meal($name, *%extras) {
    say "I'd like some $name, but with a few modifications:";
    say %extras.keys.join(', ');
}

order-meal('beef steak', :vegetarian, :well-done);
```
插值

默认数组是不能插入到参数的列表中. 所以这不同于 Perl 5 的写法.
```perl
sub a($scalar1, @list, $scalar2) { // @list 不会吃光剩下所有的参数
    say $scalar2;
}

my @list = "foo", "bar";
a(1, @list, 2);                  # 2
```
这也意味着, 默认的情况下你不能使用一个列表做为参数列表:
```perl
my @indexes = 1, 4;
say "abc".substr(@indexes)       # 不能实现你想做的
```
( 实际的情况是, 这里的第一个参数需要的是一个 Int, 需要被强制转换成 Int, 所以你可以写成 `"abc."substr(@indexes.elems)`  ).

当然, 你也可以使用前缀 `|` 来完成你想要的行为
```perl
say "abcdefgh".substr(|@indexes) #  结果 bcde, 等同于 "abcdefgh".substr(1, 4)
```

Multi Subs

实际上, 你其实可以定义多个同名的 sub , 但接收不同的参数列表:
```perl
multi sub my_substr($str) { ... }                          # 1
multi sub my_substr($str, $start) { ... }                  # 2
multi sub my_substr($str, $start, $end) { ... }            # 3
multi sub my_substr($str, $start, $end, $subst) { ... }    # 4
```
现在，不管你什么时候调用一个子例程，能匹配上述参数列表的子例程会被选中执行。

这个 multis 并不只是可以工作在`参数数量不等`的情况上, 也可以用于在`不同的参数类型`的时候:
```perl
multi sub frob(Str $s) { say "Frobbing String $s"  }
multi sub frob(Int $i) { say "Frobbing Integer $i" }

frob("x");      # Frobbing String x
frob(2);        # Frobbing Integer 2
```
动机

没有人会怀疑显式的子函数签名的实用性: 打字更少，重复的参数检查更少，代码自行记录更多。命名参数的值也已经讨论过。

这些功能还有益于自省. 例如, 当传递给一个块或者子例程给 `Array.sort`, 而那一段代码只需要一个参数，它会自动为您完成 一个Schwartzian转换（见http://en.wikipedia.org/wiki/Schwartzian_transform ）- 这样的功能在Perl 5中是不可能的，由于缺乏显式的签名，这意味着 sort 永远不知道代码块需要多少个参数。

Multi subs 这个功能也非常有用, 因为它可以使用新类型来覆盖内建命令. 比如, 你想有一个版本的 Perl6 是本地化上来正确处理土耳其字符串，这对大小写转换是使用的不同寻常的规则时非常好用.

这时, 不需要修改语言本身. 你只需要加入一个新的类型 TurkishStr, 并为原生的函数加入一个 multi subs:
```perl
multi uc(TurkishStr $s) { ... }
```
现在, 所有这个对字符串处理就会自动对应他们的语言类型, 那么你可以像正常的内置函数一样使用 uc 了。
由于操作符也是子例程，所以这些改进对于操作符也有效。


另请参阅

http://perlcabal.org/syn/S06.html

##     05  对象和类
概要
```perl
class Shape {
    method area { ... }    # literal '...'
    has $.colour is rw;
}

class Rectangle is Shape {
    has $.width;
    has $.height;

    method area {
        $!width * $!height;
    }
}

my $x = Rectangle.new(
        width   => 30.0,
        height  => 20.0,
        colour  => 'black',
    );
say $x.area;                # 600
say $x.colour;              # black
$x.colour = 'blue';
```
描述

Perl 6 比起 Perl 5 更加好的地方在于强大完整的对象模型. 它可以通过关键字创建类, 角色, 属性和方法, 并可以封装私有属性和方法. 事实上, 这个很象 Perl 5 中的 Moose( 这东西的灵感来自 Perl 6 的对象系统).

有两种方法来声明类:
第一个方法是 `文件一开始` 就有一个 `class ClassName;` 并一直延伸到文件的末尾. 
```perl
class ClassName;
# 类定义放在这里
```

第二种方法是类名后跟一个块, 块中所有的内容都被认为是当前类的定义.
```perl
class YourClass {
    # 类定义放在这里
}
# 更多的类和其它的代码
```
方法 Methods

方法定义是使用 `method` 关键字. 在方法内部可以使用 `self` 来指向对象本身.

你也可以通过参数来给调用者一个不同的名字. 并附加一个冒号 : 来给它.

Public 公有方法可以通过语法 `$object.method` 来调用, 有参数的话,可以使用 `$object.method(@args)` 或者 `$object.method: @args` 来调用.
```perl
class SomeClass {
    # these two methods do nothing but return the invocant
    method foo {
        return self;
    }
    method bar(SomeClass $s: ) {
        return $s;
    }
}
my SomeClass $x .= new;
$x.foo.bar                      # same as $x
```
( 这个 `my SomeClass $x .= new` 其实是 `my SomeClass $x = SomeClass.new` 的简写. 这之所以正常工作是因为, 这同时也是类型声明, 声明这个变量的类型是一个 SomeClass 的 "typo object", 这个类型对象就表示类的对象)

对象中的方法可以象子函数一样接收参数.

Private 的私有方法可以通过 `method !methodname` 的方式来声明, 通过 `self!method_name` 调用.
```perl
class Foo {
    method !private($frob) {
        return "Frobbed $frob";
    }

    method public {
        say self!private("foo");
    }
}
```
私有方法并不能从类的外面调用.

属性 Attributes

属性声明通过 `has` 关键字, 有个 `twigil` 的功能 ( 单词前有两个符号, 第二个符号在 Perl 6 中叫 `twigil` 有特定的意义 ). 对于私有属性, 这是使用的 `!` 符号, 对于公有属性, 这是使用 `.`  , 公共属性实际上是有公有访问权限的`私有属性`. 所以, 它不能修改, 如果你想修改时, 就需要使用 `!` 来访问实际的属性而不是使用存取器 ( 除非它被标记为 `is rw` ).
```perl
class SomeClass {
    has $!a;
    has $.b;
    has $.c is rw;

    method set_stuff {
        $!a = 1;    # ok, 这时才能写入类的属性
        $!b = 2;    # 同上
        $.b = 3;    # ERROR, 不能写, 因为这是私有只读的属性
    }

    method do_stuff {
        # 你可以使用私有的名字来替换掉公有的那个名字
        # $!b and $.b are really the same thing
        return $!a + $!b + $!c;
    }
}
my $x = SomeClass.new;
say $x.a;       # ERROR! 因为 has $!a 是没有存取器的
say $x.b;       # ok
$x.b = 2;       # ERROR!
$x.c = 3;       # ok
```
继承 Inheritance

继承是通过 `is` 这个关键字.
```perl
class Foo is Bar {
    # 类 Foo  继承类 Bar
    ...
}
```
根据常用的继承规则 - 方法会先直接检查自己的类型, 如果失败, 操作父类 ( 递归 ). 同样的, 一个子类的类型是否符合父类:
```perl
    class Bar { }
    class Foo is Bar { }
    my Bar $x = Foo.new();   # ok, since Foo ~~ Bar
```
在这个例子中 $x 的类型是 Bar, 它允许分配一个对象类型 Foo 给它, 因为每个 "Foo 都是 Bar 之下".

类也可以继承多个其它的类:
```perl
class ArrayHash is Hash is Array {
    ...
}
```
尽管多重继承会附加很多问题, 人们通常会反对这么使用. 所以`角色`往往是一个更安全的选择.

角色 Roles

现实的世界是不分层, 所以有时很难给一切都使用层次结构继承. 这也是为什么 Perl 6 中有角色的原因之一.  除了你不能由角色直接创建对象, 也不能使用相同的名字组成.类和角色还是很相似的. 相同方法名的角色会互相混淆发生冲突, 但类就不会, 因为类是包含有继承关系的, 可以很好的解决这种命名冲突.

虽然类主要针对的是类型一致性, 但角色才是在 Perl6 的`代码重用`的主要手段。
```perl
role Paintable {
    has $.colour is rw;
    method paint { ... }
}
class Shape {
    method area { ... }
}

class Rectangle is Shape does Paintable {
    has $.width;
    has $.height;
    method area {
        $!width * $!height;
    }
    method paint() {
        for 1..$.height {
            say 'x' x $.width;
        }
    }
}

Rectangle.new(width => 8, height => 3).paint;
```

另请参阅

http://perlcabal.org/syn/S12.html
http://perlcabal.org/syn/S14.html
http://www.jnthn.net/papers/2009-yapc-eu-roles-slides.pdf
http://en.wikipedia.org/wiki/Perl_6#Roles

##     06  上下文
概要
```perl
my @a = <a b c>;
my $x = @a;
say $x[2];          # c
say (~2).WHAT;      # (Str)
say +@a;            # 3
if @a < 10 { say "short array"; }
```
描述

当你写了一些如下的东西
`$x = @a`

在 Perl 5 中 `$x` 包含的信息会比 `@a` 少很多 - 它包含只有 @a 中元素的个数 ( 因为列表环境 ). 要保存所有的信息, 你只能明确的指出它是一个`引用`: `$x = \@a`.

在 Perl 6 中是反过来的: 默认你不会丢失任何东西, 标量会存储整个数组. 之所以能这样, 是因为有一个 `item` 的通用上下文 ( 在 Perl 5 中叫 `scalar` ) 和其它更加特定的象数字, 整型和字符上下文. 空和列表上下文保持不变.

你可以强制上下文环境, 通过下面的语法
```perl
语法         上下文

~stuff       String
?stuff       Bool (logical)
+stuff       Numeric
-stuff       Numeric (also negates)
$( stuff )   Generic item context
@( stuff )   List context
%( stuff )   Hash context
stuff.tree   Tree context
```
Tree Context

在 Perl 6 的初期, Tree 上下文在众多的 builtins 里存在两个版本, 一个用于返回普通的列表 flat list, 一个返回 a list of arrays 数组列表 ( 象是数组的数组 ).

现在是通过返回 Parcel 的对象列表, 通过这个 Parcel 对象会根据上下文来返回可能会和可能不会拉平数组.

第一种情况, 比如我们使用中缀操作 `Z` ( 它是 zip 操作的简写 ) 操作符, 交错的从这二个列表中取元素:
```perl
my @a = <a b c> Z <1 2 3>;
say @a.join;                # a1b2c3
```
这所做的事情是, 第一个语句的右边返回 `('a', 1), ('b', 2), ('c', 3)`, 并赋值给一个数组, 它提供列表上下文, 然后接下操作会拉平内部的元素变成整个 @a 的元素成一个普通列表.

我们来看另一种情况, 这时是 tree 上下文
```perl
my @t = (<a b c> Z <1 2 3>).tree;
```
这个 @t 现在包含三对元素, 整个数组都没有拉平到 @t 中, 还是保持着自己的结构, 然后才存入 @t 这时会是一个 Parcel 对象的数组列表.
```perl
for @t -> @inner {
    say "first: @inner[0]  second: @inner[1]"
}
```
会输出:
first: a  second: 1
first: b  second: 2
first: c  second: 3

动机

在设计 Perl 6 的上下文的时候, 这些开发人员选择了不要过在决定一个数据结构在不同上下文中的返回值. 例如, 一个列表在标量上下文中应该返回什么 ? 如果返回一个列表的引用, 好处就是能保留所有的信息, 但是坏处就是在需要做数字比较的时候用处不大. 如果返回一个字符串呢, 在调试阶段就会非常有用. 所以舍弃哪种都有相应的不好的地方。

大多的时候, 你根本不要做这样的选择 - 它都会返回合理的值. 不需要你选择怎么样返回.

对于一些事情, 象 Match 对象, 这种不同的上下文也很大程度上提升了实用性和美感.
另请参阅

http://perlcabal.org/syn/S02.html#Context http://perlgeek.de/blog-en/perl- ... ls-and-context.html

##     07  Rules 
概要
```perl
grammar URL {
    token TOP {
        <schema> '://'
        [<ip> | <hostname> ]
        [ ':' <port>]?
        '/' <path>?
    }
    token byte {
        (\d**1..3) <? $0 < 256 \}>
    }
    token ip {
        <byte> [\. <byte> ] ** 3
    }
    token schema {
        \w+
    }
    token hostname {
        (\w+) ( \. \w+ )\*
    }
    token port {
        \d+
    }
    token path {
        <[ a..z A..Z 0..9 \-_.!~\*'():@&amp;=+$,/ ]>+
    }
}

my $match = URL.parse('http://perl6.org/documentation/');
say $match<hostname>;       # perl6.org
```
描述

译者注: 不同于传统的正则表达式, Perl 6 不需要你记住的元字符的列表. 它通过一个简单的规则进行分类字符. 比如扩展的元语法 metasyntax 形式是 ( `<...>` ) 这样包含着字符. 比如 `<.ws>` 是尖括号包着 `.ws` 表示匹配空格. 其中的 `.` 表示`不要捕获`到正则的变量名 $ 中.

正则表达式已经在 Perl 6 中改良和革新, 这是重大改进之一. 我们不叫它 regular expressions 了. 因为它比起 Perl 5 更加不正规了.

正则表达式有三个大的更改和改进.

语法更加干净

许多小变化使得规则更加容易编写. 例如, dot `.` 现在匹配任何字符, 旧的 Perl 5 中的语义是要除去换行. 现在你可以使用 `\N` 来实现匹配零个或者多个非换行符.

修饰符现在是放在正则表达式的`起始位置`, 并且修改了非捕获组变成是 `[...]`, 这比起旧的 `(?:...)` 更加容易读取和写.

嵌套捕获和 match 对象

在 Perl 5 中, 正则 `(a(b))(c)` 会给 ab 存到 `$1`, b 会存到 `$2` 和 c 存到 `$3`. 这种情况现在改变, 现在 `$0` (枚举从零开始)包含 ab, `$0[0]` or `$/[0][0]` 包含 b, `$1` 存着 c. 所以括号中的每个嵌套级别反映在结果匹配对象的一个新的嵌套级别.

所有匹配变量是别名为 `$/`，也就是所谓的 `Match object`, 它实际上是一个包含了完整的匹配树型结构的对象。

命名的正则和 grammars

在 Perl 6 中开始, 你可以给你所写的正则表达式一个名字, 就象在子函数和方法中一样有自己的名字. 通过 `<name>` 这种方式来在其它地方`重用`. 你可以给多个正则表达式做成 grammars, 这就象类和支持继承和组合.

这些改变使得 Perl 6 的正则表达式和 grammars 比起 Perl 5 更加容易维护和编写.

这些变化的东西比较深, 这个文章中, 我们只能见到表面的东西.

语法更加干净

字母字符 ( 如下划线, 数字和所有 Unicode 字符 `[a-zA-Z0-9_]` ) 是根据字面内容来匹配, 也就是指, 它是什么就是什么, 当使用反斜杠转义这些字符时就会具有特殊的意义 ( 这是元语法 metasyntactic ).

对于所有的其它字符 ( 非 [a-zA-Z0-9_] ) 是反过来的 - 除非它转义(也就是说特殊字符 `*` 就是有特殊含义的，如果你想匹配一个 "星号"，那就要用 "*").
```perl
字面意思         元语法
a  b  1  2      \a \b \1 \2     # 普通字符 [a-zA-Z0-9_]
\* \: \. \?     *  :  .  ?      # 其它字符 非 [a-zA-Z0-9_]
```
并不是全部反斜杠转义的字符都是元语法 metasyntactic tokens 都有特别的含义. 除了 `\a` `\b` `\1` `\2` 外, 可能其它的使用反斜杠转义的并没有确切的定义, 这时这些是非法的.

在正则表达式中还有另一种方法来转义字符串: 使用 `引号`.
```perl
m/'a literal text: $#@!!'/
```
在 Perl 6 中这改变了 `.` 的语义, 这个前面提过, 同时改变的还有 `[…]` 现在用于构建`非捕获组`. 字符类是　`<[...]>`　和非字符类 `<-[...]>`.  `^`　和　`$`　总是匹配 `开始` 和 `结束`的字符串. 匹配 `行的开始`和 `结束` 是使用　`^^`　和　`$$`.

这意味着原来的 `/s` 和 `/m` 修饰都没有了. 修饰符现在是在正则表达式中, 是在一开始的位置给出:
```perl
if "abc" ~~ m:i/B/ {
    say "Match";
}
```
... 这又是使用的 `colon pair` 符号. 你可以使用起来象子函数给个命名参数一样.

修饰符有一个短的和长的形式. 现在老 /x 修饰符是默认的, 即空格会被忽略.
```perl
简写    长的写法            意义
-------------------------------
:i      :ignorecase     忽略大小写 ( 旧的 /i )
:m      :ignoremark     忽略一些标记 ( 重音, 分音符号等 )
:g      :global         全局替换 ( 旧的 /g )
:s      :sigspace       正则表达式匹配所有空格
                        (可选) 空格
:P5     :Perl5          退回到 Perl 5 所兼容正则表达式语法
:4x     :x(4)           Match four times (works for other numbers as well)
:3rd    :nth(3)         Third match
:ov     :overlap        很象 :g, 但这会考虑重叠的匹配
:ex     :exhaustive     Match in all possible ways
        :ratchet        不回溯
```
这里的 `:sigspace` 需要花些时间来解释. 它通过使用了 `<.ws>` 的有名字的正则替换了模式中的空格 ( 这是调用 rule ws 并不保存捕获的结果 ).　你可以覆盖该规则.

的规则默认会匹配二个单词中间所包含的一个或者多个空格. 如果不是单词之间就是匹配零个或者多个空格.

Match 对象

每个匹配会生成一个叫 `match` 对象的东西, 会给这些匹配到的内容存储到指定的变量 `$/` 中.　它是非常有用的. 如果匹配成功并且在布尔上下文中, 它返回 `Bool::True`. 在字符上下文会返回匹配到的字符, 作为一个列表时会返回其中包含的捕获位置, 作为哈希使用时它包含命名捕获. 这个对象有 `.from` 和 `.to` 方法, 会返回包含首先的和最后的字符位置上找到的内容.
```perl
if 'abcdefg' ~~ m/(.(.)) (e | bla ) $<foo> = (.) / {
    say $/[0][0];           # d
    say $/[0];              # cd
    say $/[1];              # e
    say $/<foo>             # f
}
```
这的 `$0`, `$1` 只是 `$/[0]`, `$/[1]` 的别名. 同样 `$/<x>` 和 `$/{‘x’}` 也只是 `$<x>` 的别名.

注意, 任何你通过 `$/[…]` 和 `$/{…}` 访问的都是 `match 对象`( 或者是 match 对象的列表 ). 这可以让你通过 `rules` 创建真实的解析树.

命名正则和 Grammars

正则表达式可以使用旧的风格 `m/…/`, 或者可以使用名字来给他们声明成象子函数和方法一样.
```perl
regex a { ... }
token b { ... }
rule  c { ... }
```
所不同的是 token 隐含了 `:ratchet` 修饰符 ( 这意味着没有回溯, 象 `(?> ... )` 组包含各自的部分 ), 这个 rule 隐含了 `:ratchet` 和 `:sigspace` 两个修饰符.

要调用这些规则 ( 我们会要调用的全部的这些规则, 通过关键字声明后会相互独立 ) 只要使用尖括号中加名称: `<a>` 就可以使用. 这隐含地规则的字符串会放到的当前位置, 存储匹配到的结果到 `$/<a>` 的对象中, 也就是说, 它是也是一个命名捕获. 你也可以使用 `<.a>` 来调用不做命名捕获的匹配 ( 不同处在于加了前缀点 ).

grammar 是一系列规则的组合, 这很象对象中的类 ( 看　SYNOPSIS　中的例子). Grammars 可以继承, 重写规则等.
```perl
grammar URL::HTTP is URL {
    token schema { 'http' }
}
```
动机

Perl 5 的正则表达式常常不太可读, grammars 这个东西是鼓励你把一个大的正则表达式表示成为更可读的, `短的片段`. 命名捕获使规则更加能实现自我文档, 而且很多东西比起以前现在更加一致.

最后, grammars 是如此强大, 你可以用它分析了解每一种编程语言, 包括 Perl6 本身. 这使得 Perl 6 的语法比起 Perl 5 更易于维护和修改.

另请参阅

http://perlcabal.org/syn/Shtml

http://perlgeek.de/en/article/mutable-grammar-for-perl-6

http://perlgeek.de/en/article/longest-token-matching

##     08  分支
概要
```perl
my $x = 4;
if $x == 3|4 {
    say '$x is either 3 or 4'
}
say ((2|3|4)+7).perl        # (9|10|11)
```
描述

Junctions 是叠加的一堆无序的值. 操作 junctions 的时候是对各自己的元素分别执行 ( 甚至是并行的 ), 并且结果组装成原来相同的类型.

在 junction 类型唯一的不同点在于计算布尔上下文时. junction 的中有类型 `any`, `all`, `one` 和 `none`, 不同的中缀运算符表示不同的 junction 类型.
```perl
类型   中缀运算符
any     |
one     ^
all     &
```
`1 | 2 | 3 `等同于 `any(1..3)`.

```perl
my Junction $weekday = any <Monday Tuesday Wednesday
                            Thursday Friday Saturday Sunday>
if $day eq $weekday {
    say "See you on $day";
}
```
在这个例子中 eq 的这个操作因为 Junction 是 any 所以会调用每个元素象 $day, 'Monday', $day, 'Tuesday' 等等. 并将结果放入 any-junction 中来. 在运行的过程中只要结果被确认了 ( 在这个例子中, 只要有任意一个比较返回 '真' ) 它可以会中止其他比较的执行.

这不但对操作符有效, 对子函数也行:
```perl
if 2 == sqrt(4 | 9 | 16) {
    say "YaY";
}
```
为了做到这一点, junction 是放在了正常的类型层次结构之外的:
```perl
                  Mu
                /    \\
               /      \\
             Any     Junction
           /  |  \\
        All other types
```
如果你想写一个函数使用这个 junction 并且不 autothread　这个子函数, 你可以声明这些的参数是 Mu 或者是 Junction.
```perl
sub dump_yaml(Junction $stuff) {
    # we hope that YAML can represent junctions ;-)
    ....
}
```
提醒一句: Junctions 有时的表现会和你的直觉相反. 如果是非 junction 类型的时候 `$a != $b` 和 `!($a == $b)` 总是相同的结果. 如果这些变量中有一个是 junction 类型时, 这个结果就不一样了.
```perl
my Junction $b = 3 | 2;
my $a = 2;
say "Yes" if   $a != $b ;       # Yes
say "Yes" if !($a == $b);       # no output
```
`2 != 3` 是为真, 这 `$a != 2|3` 也是为真. 在其它的时候象 `$a == $b` 比较会返回布尔值 ( True ), 然后在取反为 False.

动机

Perl 的目标是要接近自然语言, 自然语言中你常常会这样讲 "如果这个结果这样或者那样" 而不会讲 "如果这个结果是这样或者这个结果是那样". 很多编程语言都只能使用后者, 感觉有点奇怪. 所以还是 Perl 6 比较好.

这个东西也让你做很多事情容易多了, 不然要使用循环实现同样的功能需要写很多比较.

例如, 有个数组全部都是数字的, 你想知道如果全部的是不是都是非负数, 在 Perl 5 中, 你可能会写成下面这样:
```perl
# Perl 5 code:
my @items = get_data();
my $all_non_neg = 1;
for (@items){
    if ($_ < 0) {
        $all_non_neg = 0;
        last;
    }
}
if ($all_non_neg) { ... }
```
如果你知道 Perl 5 中的这个模块, `List::MoreUtils` 你可能会写成:
```perl
use List::MoreUtils qw(all);
my @items = get_data;
if (all { $_ >= 0 } @items) { ...  }
```
在 Perl 6 中你只需要写成:
```perl
my @items = get_data();
if all(@items) >= 0 { ... }
```
A Word of Warning

很多人知道这个 junctions 非常高兴, 都会大量尝试使用这个.

但要知道 Junctions 并不是一个 sets ( 集合 ); 所以你没法从 junction 中提取元素, 你这样做就错了, 所以你想要这样就要使用 Set 替代.

It is a good idea to use junctions as smart conditions, but trying to build a solver for equations based on the junction autothreading rules is on over-extortion and usually results in frustration.


##     09  比较和智能匹配
概要
```perl
"ab"    eq      "ab"    True
"1.0"   eq      "1"     False
"a"     ==      "b"     failure, because "a" isn't numeric
"1"     ==      1.0     True
1       ===     1       True
[1, 2]  ===     [1, 2]  False
$x = [1, 2];
$x      ===     $x      True
$x      eqv     $x      True
[1, 2]  eqv     [1, 2]  True
1.0     eqv     1       False

'abc'   ~~      m/a/    Match object, True in boolean context
'abc'   ~~      Str     True
'abc'   ~~      Int     False
Str     ~~      Any     True
Str     ~~      Num     False
1       ~~      0..4    True
-3      ~~      0..4    False
```
描述

Perl 6 仍有字符串比较操作符 ( eq, lt, gt, le, ge, ne; cmp 现在叫 leg ) 用于比较字符上下文件的操作. 同样 Perl 5 中的所有数值运算符还是存在.

由于对象是 blessed 的引用, 需要新的方式来进行比较 === 只有当值都相同的时候才返回真. 对于数字和字符串是正常的相等性测试, 其它的东西都是比较二个变量是否引用同一个东西( 象 C++ 中的内存地址比较 );

eqv 的测试是比较二个东西是不是等价的, 比较他们需要它们有相同的类型并也有相同的值. 在容器类型象数组和哈希, 使用 eqv 来进行比较. 二个结构相同的数组结构是不是等价.

智能匹配

perl 6 有一个通用比较符, 叫 "智能匹配" 操作符, 拼写成 ~~. 它是不对称对比的, 一般右边的操作数的类型决定使用哪种比较. 在新版本的 Perl 5 中也存在.

对于数字和字符串是进行简单的相等比较. 智能匹配对于类型和对象是检查类型是否一致. 智能匹配对一个正则表达式是检查是否匹配正则. 如果一个标量会对比 Range 是否在这个范围内能查找到.

还有其它更加高级的匹配形式: 比如你可以检查一个参数列表 ( Capture ) 非常合适子函数参数或者文件测试操作.

你只需要记住, 任何 "这个 $x 是否合适 $y?" 这种问题都可以使用 Perl 6 的智能匹配.

另请参阅

[http://perlcabal.org/syn/Shtml#Smart_matching]

##     10  容器和绑定
Synopsis

```perl
my ($x, $y);
$x := $y;
$y = 4;
say $x;             # 4
if $x =:= $y {
    say '$x and $y are different names for the same thing'
}
```
描述

Perl 6 区分不同的容器和值能存到各自的容器中.

标量变量是一个容器, 并能有像类型的限制, 访问限制 ( 例如, 它可以是只读的 ) 之类的一些属性, 最后它可以被关联到其他容器.

放入值到容器, 叫做分配 assignment. 给两个容器做成别名被称为 '绑定'.

```perl
my @a = 1, 2, 3;
my Int $x = 4;
@a[0] := $x;     # 绑定: 现在 @a[0] 和 $x 是相同的值
@a[0] = 'Foo';   # 错误 'Type check failed'
```
类型 Int 和 Str 的类型是不能改变的, 所以这些对象不能被改变, 但你可以修改这些东西的值 ( 在容器中的值 ):
```perl
my $a = 1;
$a = 2;     # no surprise here
```
绑定也可以在编译的时候就完成, 我们需要使用 `::=` 操作符就可以了.

你可以通过 `=:=` 的操作符来比较二个绑定在一起的东西.

动机

在子函数中的 Exporting 导出和 importing 导入类型和值都是通过别名的方式. 这用于替代 Perl 5 中难以理解的 `typeglob` 的语法, Perl 6 提供的这个简单多了.

另请参阅

[http://perlcabal.org/syn/Shtml#Item_assignment_precedence]

##     11  基本操作符
概要

```perl
# 位运算符
5   +| 3;       # 7
5   +^ 3;       # 6
5   +& 3;       # 1
"b" ~| "d";     # 'f'

# 字符串连接
'a' ~ 'b';      # 'ab'

# 文件测试
if '/etc/passwd'.path ~~ :e { say "exists" }

# 重复
'a' x 3;        # 'aaa'
'a' xx 3;       # 'a', 'a', 'a'

# 三元, 条件运算
my ($a, $b) = 2, 2;
say $a == $b ?? 2 * $a !! $b - $a;

# chained comparisons
my $angle = 1.41;
if 0 <= $angle < 2 * pi { ... }
```
描述

所有的数值运算符 (+, -, /, *, **, %) 在 Perl 6 中保持不变.

由于 |, ^ 和 & 现在 junctions 在使用, 所以位算符改变了语法. 它们现在包含一个上下文前缀, 所以象 +| 是逐位的运算基于数字上下文. ~^ 是对字符串上下文的异或. 位移操作也有相同的上下文前缀.

字符串连接现在是使用的 ~, 因为 . 现在被用于方法调用了.

文件测试, 现在是使用 Pair ( 字符:功能 ) 符号, 在 Perl 5 中的 -e 现在是 :e. 如果你不是想对 $_ 进行检查操作, 你可以使用 $filename.path ~~ :e 的方式来指定路径.

这个重复操作 x 现在分开成二个操作符: x 是重复字符串, xx 是重复的列表.

三元运算符, 原来的 `$condition ? $true : $false`, 现在需要写成 `$condition ?? $true !! $false`.

比较操作符现在可以做成一串的链, 所以你可以根据你的意思, 写成象 `$a < $b < $c`.

动机

这些操作符的改变, 主要是为了写出更加好读好看的代码, 比如给最常使用的东西使用比较短的名字 ( 比如 `.` 现在用于方法调用 ) 和对于比较少使用的操作使用比较长的名字 ( 比如 `~&` 对于子符串进行位操作 );

这些操作符的改变之类都是为了使语言更加象自然语言一样.

另请参阅

[http://perlcabal.org/syn/Shtml#Changes_to_Perl_5_operators]

##     12  懒惰
概要

```perl
my @integers = 0..*;
for @integers -> $i {
    say $i;
    last if $i % 17 == 0;
}

my @even := map { 2 * $_ }, 0..*;
my @stuff := gather {
    for 0 .. Inf {
        take 2 ** $_;
    }
}
```
描述

对于象列表之类, 在 Perl 6 中都是 lazy 的.

之所以叫 lazy 意味着, 这个东西的生成都是尽可能延迟. 当你写象 `@a := map BLOCK, @b`, 这个块并不执行. 当你从 @a 中访问这个东西的时候, 这个 map 函数才开始根据需要一个个执行和填充所需要的数据.

注意这个地方, 是使用的绑定操作符 (`:=`), 而不是分配: 如果直接声明分配的函数会立即创建内容 ( 除非编译器知道这个列表是无限长的, 才不会生成 ), 而使用绑定并不会立即生成内容.

Laziness 的特性可以让你处理无限长度的列表: 他们所占的空间就和你操作这个列表的长度一样大. 所以你没一个个操作完元素之前, 这些并不会生成.

但这存在一些缺陷, 比如列表的排序会失去 Laziness 的特性. 如果这个列表是无限的, 有可能容易出现无限循环.

在正常的情况下, 如果转换成标量 ( 象 List.join ) 也会不使用 Laziness 的特性.

Laziness 的特性可以防止不必要的计算, 所以可以提升性能, 同时保持代码的简单.

当你在 Perl 5 中一行行读文件时, 你之所以不使用 for (<HANDLE>) 是因为会读所有的文件到内存中, 然后才开始迭代, laziness 在这处理是不同的:
```perl
my $file = open '/etc/passwd';
for $file.lines -> $line {
    say $line;
}
```
由于 `$file.lines` 在 Perl 6 中本身就是 `lazy list`, 所以只有物理读到文件时, 才会取到内存中来 ( 当然除了 buffer 的需要外 ).
gather/take

创建 lazy lists 一个非常有用的方式是使用 `gather { take }`. 它象下面这样使用:
```perl
my @list := gather {
    while True {
        # some computations;
        take $result;
    }
}
```
这个 `gather BLOCK` 返回一个 `lazy list`. 只有当有操作必须使用 @list 中的元素时, 这个代码块才会运行至 take 块执行. 这个 take 就象 return 函数. 全部的 take 的返回的内容会构建 @list. 当需要更多的@list 块的元素时, 又会接着从上次的 take 之后执行这个代码块.

`gather/take` 是动态的范围, 所以它可以调用 take 在 gather 块的词法范围之外.
```perl
my @list = gather {
    for 1..10 {
        do_some_computation($_);
    }
}

sub do_some_computation($x) {
    take $x * ($x + 1);
}
```
注意这个 gather 也可以是单个语句声明, 而不是一个块:
```perl
my @list = gather for 1..10 {
    do_some_computation($_);
}
```
控制 Laziness

Laziness 特性有可能会产生其它副作用 ( 当你尝试和学习过 Haskell 时, 你会发现它们中的 IO 系统是有点奇怪. 因为他们是使用的 lazy 特性, 并且没发现什么副作用 ), 当你不想使用这个特性的时候, 可以在前面加个 eager 的关键字.
```perl
my @list = eager map { $block_with_side_effects }, @list;
```
默认的情况下, lazy 只在列表的时候生效. 但你也可以让 lazy 工作在标量上:
```perl
my $ls = lazy { $expansive_computation };
```
动机

在计算机科学中, 大多数的问题都可以通过定义树来解决现实中的问题, 常用的一个方案是进行高效的算法和有效的搜索, 并且, 构建树其实也是非常有趣的部分.

通过 lazy 的列表, 你可以递归定义这个树并且查找它, 这个会特性会自动构造只有你实际使用过的部分.

在一般的情况下, laziness 特性可以让你写程序更加容易, 因为这是透明的. 就算计算的所有结果都会被使用到, 你也不会失去什么. 如果他不使用, 就根本也不会执行.

另请参阅

http://perlcabal.org/syn/Shtml#Lists

##     13  自定义操作符
概要
```perl
multi sub postfix:<!>(Int $x) {
    my $factorial = 1;
    $factorial *= $_ for 2..$x;
    return $factorial;
}

say 5!;                     # 120
```
描述

操作符其实是一个有着特别名字的函数, 并且有一些额外的属性, 象优先级和结合性. 在 Perl 6 中通常的操作符的模式是 term infix term ( 词语 中缀 词语 ), 词语能选择是前面使用前缀运算符,还是使用后缀或者 postcircumfix 操作符.
```perl
1 + 1               infix         ( 中缀 )
+1                  prefix        ( 前缀 )
$x++                postfix       ( 后后缀 )
<a b c>             circumfix     ( 环缀 )
@a[1]               postcircumfix ( 后环缀 )
```
操作符的名字并不限制使用特定的字符, 你可以包含使用任何东西, 除了空白.

上面后面这个运算符的长的名字是它的类型, 操作符用于跟着一个冒号和一个字符串文字或符号或符号的列表, 例如 `infix:<+>` 是 `1+2` 的运算. 其它的例子是 `postcircumfix:<[ ]>` 操作, 它是对 `@a[0]` 的操作.

当你知道这些知识, 你现在可以重新定义新运算符:
```perl
multi sub prefix:<^> (Str $x) {
    2 *  $x;
}
say ^4;                         # 8
```
优先级

中缀表达式象 `$a + $b * $c`, 这中间的 `infix:<*>` 操作符优先级比 `infix:<+>` 高, 这也就是为什么可以计算 `$a + ($b * $c)`.

新运算符的优先级可以通过下面的方式来指定:
```perl
multi sub infix:<foo> is equiv(&infix:<+>) { ...  }
mutli sub infix:<bar> is tighter(&infix:<+>) { ... }
mutli sub infix:<baz> is looser(&infix:<+>) { ... }
```
结合性

很多的中缀操作符只有二个参数. 象执行 `1 / 2 / 4` 中的操作符的结合性是根据结合性顺序来的. 这个 `infix:</>` 操作符是左结合性, 所以执行的解析是 `(1 / 2) / 4` 的顺序来的. 如果是右结合性操作符, 象 `infix:<**>` 在执行 `2 ** 2 ** 4` 时执行的解析顺序是 `2 ** (2 ** 4)`.

Perl 6 中有着更加丰富的结合性: 如 none 是禁止优先级相同的操作符进行链接操作 (例如 `2 <=> 3 <=>` 4 是被禁止的 ), `infix:<,>` 是 list 结合性, 这个 `1, 2, 3` 会被转换成 `infix:<,>(1; 2; 3)`. 还有 `chain` 的结合性: `$a < $b < $c` 会被转换成 `($a < $b) && ($b < $c)`.

```perl
multi sub infix:<foo> is tighter(&infix:<+>)
                      is assoc('left')
                      ($a, $b) {
    ...
}
```

Postcircumfix 和 Circumfix

Postcircumfix 操作符是方法调用:
```perl
class OrderedHash is Hash {
    method postcircumfix:<{ }>(Str $key) {
        ...
    }
}
```
如果你调用 `$object{$stuff}`, 这个 `$stuff` 会当成参数传给方法调用, 这个 `$object` 是一个可用的 self.

Circumfix 的调用意味着这有不同的语法 ( 象 `my @list = <a b c>;` ), 是用于实现宏 (macros):
```perl
macro circumfix:«< >»($text) is parsed / <-[>]>+ / {
    return $text.comb(rx/\S+/);
}
```
这的 is parsed 特性后面跟一个正则表达式解析分隔符之间的所有东西. If no such rule is given, it is parsed as normal Perl 6 code (which is usually not what you want if you introduce a new syntax).

Str.comb 的给一个正则表达式, 并返回所有匹配的文本列表.
"重载" 现有的操作符

很多 (不是全部) 现有的操作符是使用的 multi subs 和方法调用, 所以可以定制新的类型. 添加一个新的 multi sub 就能实现重载操作符了.
```perl
class MyStr { ... }
multi sub infix:<~>(MyStr $this, Str $other) { ... }
```
这也意味着你可以重写看起来是内置对象的特殊对象, 比如 Str, Int etc.

动机

允许用户声明新的操作符和 "重载" 现有的用户定义的类型这非常强大. 如果内置的不合适你使用, 你可以使用自己的新的操作符, 无需编译器本身做任何改变.

它也消除使用语言和修改语言之间的差距.

另请参阅

http://perlcabal.org/syn/Shtml#Operator_overloading

如果你有兴趣了解相关的技术背景, 即 Perl 6 怎么实现这些操作符和其它 grammer 的改变, 你可以读读 http://perlgeek.de/en/article/mutable-grammar-for-perl-6.


##     14  MAIN子例程
概要
```perl
# file doit.pl
#!/usr/bin/perl6 sub MAIN($path, :$force, :$recursive, :$home = '~/') { # do stuff here }

# command line $ ./doit.pl --force --home=/home/someoneelse file_to_process
```
描述

 调用子函数和运行一个类 Unix 的命令行程序从视觉上看, 其实非常相似: 你可以有选项, 可选参数和命名参数.

使用 Perl 6 你可以从中利益很多, 它可以直接处理你的命令行, 并变成一个子函数调用. 你只要你的文件中存在 MAIN 的子函数, 你的脚本就可以正常的执行 ( 此时会给你的参数送给 @*ARGS ).

如果你提交的参数在那个 MAIN 的函数中并不对应, 会自动的帮你生成 usage 的信息.

命令行的参数映射到子程序的参数是这样工作的:
```perl
-name :name -name=value :name

# remember, <...> is like qw(...) --hackers=Larry,Damian :hackers

--good_language :good_language --good_lang=Perl :good_lang --bad_lang PHP :bad_lang


+stuff :!stuff +stuff=healty :stuff but False
```
这个地方的 `$x = $obj but False` 的意思是这个 `$x` 是复制的 `$obj`, 但是在布尔上下文时会给出 `Bool::False`.

因此, 对于简单的 (和一些不是很简单的) 情况下, 你并不需要一个外部命令行参数的处理程序, 你可以直播使用 MAIN 函数实现这一点.

动机

 这背后的动机应该是很明显的: 它使简单的事情变得更加容易, 很多时候给命令行代码传参只需要简单的 MAIN 函数.

另请参阅

http://perlcabal.org/syn/Shtml#Declaring_a_MAIN_subroutine contains the specification.


##     15  Twigils
概要
```perl
class Foo { has $.bar; has $!baz; }

my @stuff = sort { $^b[1] <=> $^a[1]}, [1, 2], [0, 3], [4, 8]; 
my $block = { say "This is the named 'foo' parameter: $:foo" }; 
$block(:foo);

say "This is file $?FILE on line $?LINE"
say "A CGI script" if %*ENV.exists('DOCUMENT_ROOT');
```
描述

 在 Perl 6 中有些变量有两个标记, 这个叫 twigil 标记. 如果它存在, 意味着这个变量不是 "标准" 的变量, 它和普通的有些不同, 例如, %*ENV 这个中的 * 表示是`全局的`, 所以`有不同的作用域`, 因为默认都不是全局的.

你见到在对象属性中公有和私有分别使用 `.` 和 `!` 的 twigil 标记; 这指出他们不是正常的变量, 他们在这是和 self 绑定在一起的变量.

The ^ twigil removes a special case from perl 5. To be able to write

    # beware: perl 5 code sort { $a <=> $b } @array
变量 $a 和 $b 在程序中使用了 strict 的时候来讲是个特例. 在 Perl 6 中, 有个概念叫 self-declared positional parameter, 这的参数有个 ^ 的标记. 它用于定位块中参数的位置, 它不是参数, 它只是用这些变量根据字母顺序填充位置.
```perl
my $block = { say "$^c $^a $^b" }; 
$block(1, 2, 3); # 3 1 2
```
所以你现在可以写成:
```perl
@list = sort { $^b <=> $^a }, @list; 
# or: 
@list = sort { $^foo <=> $^bar }, @list;
```
在正常的情况下, 用于保持定位和命令参数之间的对称, 在 : twigil 也是对命名参数做同样的事情, 所以这些行相当于:
```perl
my $block = { say $:stuff } my $sub = sub (:$stuff) { say $stuff }
```
这的 ? 的 twigil 标记表示在编译的时候就知道的变量和常量, 象 $?LINE 是指当前的行的行号( 原 __LINE__ ), $?DATA 是指文件句柄中的 DATA 区.

 ( Contextual variables )上下文变量它是用 * 的 twigil 标记来标识, 可以用 $* 来访问, 根据上下文的变化而变化的, 先会搜索当前上下文, 再搜索被调用函数的上下文, 以此类推, 所以 $*IN 和 $*OUT 的输出能动态的覆盖.

有个伪 twigil 是 <, 它是象 $<capture> 的一个结构, 这是 $/<capture> 的简写, 用于访问正则表达式匹配了对象后的 Match object.

动机

 当你读 Perl 5 中的 perlvar 文档的时候, 你可以知道, 这有很多的变量, 很多是全局变量, 会影响你的程序.

这的 twigils 会尝试给指定的变量某种顺序, 在另一方面, 他们消除了一些必要的特例. 在对象属性中 twigil 主要用于缩短 self.var 到 $.var (or @.var or whatever).

所以, 这些虽然增加了一些 "标点符号的噪音" 但实际上使得程序更加一致和可读.


##     16  Enums 枚举类型

概要
```perl
enum bit Bool <False True>; 
my $value = $arbitrary_value but True; 
if $value { 
    say "Yes, it's true";  # will be printed 
}

enum Day ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'); 
if custom_get_date().Day == Day::Sat | Day::Sun { 
    say "Weekend"; 
}
```
描述

 枚举是通用的. 它是低层次类, 它可以包含常量, 整数和字符串.

这种常量可以当成子类型 (subtype), 方法和普通的值. 这些可以通过 `but` 操作符, 加入到对象, 看成混合了 enum 到变量:
```perl
my $x = $today but Day::Tue;
```
你也可以使用枚举类型的名字作为一个函数, 并提供一些值做为参数:
```perl
$x = $today but Day($weekday);
```
之后这个对象有一个方法, 可以通过枚举类型的名字来调用, 在这是 Day:
```perl
say $x.Day; # 1
```
第一个常量的值是 0, 接下来是 1 等等, 除非你明确的提供了键值对:
```perl
enum Hackers (:Larry, :Guido, :Paul);
```
你可以使用智能匹配操作符来检查特定的值. 或者使用 `.does`:
```perl
if $today ~~ Day::Fri { say "Thank Christ it's Friday" }
if $today.does(Fri)   { ... }
```
注意, 你可以指定唯一值的名字象 Fri. 如果你不确认你需要提供全名, 象 Day::Fri.

动机

 枚举在 Perl 6 中做了两件事, 一个是 tainted 变量 ( 污染检查相关? ), 另一个是函数返回值问题. 这个问题就是: 很多函数用 return 0 返回, 这个时候函数返回的是 true.

 Enums 也为 debuggin 和 tracing 提供强大和方便附加元数据的功能.

另请参阅

http://perlcabal.org/syn/Shtml#Enumerations


##     17  Unicode (-)
概要

(none)

描述

Perl 5 中的 Unicode 模型有个大问题: 它对于二进制和文本是使用的相同的类型. 例如, 你的程序从网络上的 socket 套接字上读取了 512 个字节, 它一定是一个 byte 串. 但是在 Perl 5 中对这个调用 uc 时, 就会被当成是文本. 推荐的方式是, 先对这个串进行解码, 但是做为子程序, 你接收一个串做为参数时, 你不能可靠的知道, 这到底是被解码了还是没有.

在 Perl 6 中提供了 buf 类型, 这只是 bytes 的集合, 也提供了 Str, 这些是 logical character 字符集合.

logical character仍然是一个模糊的术语. 为了更加准确的解释 Str 的对象, 我们可以见到几个不同的层次: Byte, Codepoint ( 任何 Unicode 的指定的数字都是一个 Codepoint ), Grapheme ( 在视觉上显示为一个字符 ) 和 CharLingua ( 语言上定义的字符 ).

例如, 字符串通过十六进制表示 61 cc 80 是由三个字位元组组成, 但也可以二个 codepoints 组成的名为 LATIN SMALL LETTER A (U+0041) 和 COMBINING GRAVE ACCENT (U+0300), 或者一个 grapheme , 如果你的浏览器能显示, 它看起来象 à.

所以你不能简单地取这个字符串的长度, 你要问一个特定类型的长度:

$str.bytes; $str.codes; $str.graphs;
这还有一个方法名为 chars, 这是返回当前 Unicode 级别的长度, 你可以通过在程序上给个 use bytes 的编译指示来设置为默认 graphemes.

在 Perl 5 中有时很容易错误的串联字符串流和文本字符串. 如果你在 Perl 6 也出现了这个问题, 你可以简单的通过重载连接运算符来简单的识别问题发生在哪.

sub GLOBAL::infix:<~> is deep (Str $a, buf $b)|(buf $b, Str $a) { 

    die "Can't concatenate text string «" ~ $a.encode("UTF-8") "» with byte string «$b»\n"; 

}
编码和解码

 目前 spec 文档中对于 IO 系统非常的低层, 并没有任何的编码和解码层, 这也是为什么这篇文章没有介绍这个部分, 不过肯定, 很快会有下面这样的一种机制:

my $handle = open($filename, :r, :encoding);
正则和 Unicode

正则表达式可以指定 Unicode level, 所以使用 m:codes/./ 会匹配到 codepoint. 如果没有指定 Unicode level 会使用当前的 Unicode level.

字符类象 \w ( 匹配单词字符 ) 会相应的使用 Unicode 标准. 象忽略大小写 (:i) 和重音符 (:a) 和一些会携带找到的模式的替换字符串操作 (:samecase and :sameaccent, short :ii, :aa) 都支持.

动机

 对于大多数编程语言和工具来讲, 能很正确的处理字符是十分困难的. 例如, 在 Perl 5 的 web 应用程序中, 你想使用象 substr 来进行字符的切割时, 很有可能它会撕裂整个字符, 变成半个.

Perl 6 会是第一个内置对 grapheme 级别的字符进行操作的编程语言, 这基本上消除了大部分的你对 Unicode 的担忧, 并和正则表达式相结合, 会成为最强大的字符串处理语言.

对于文本和 byte 字符的数据类型的调试和内省会容易多了.

另请参阅

http://perlcabal.org/syn/S32/Str.html



##     18  Scoping作用域
概要

```perl
for 1 .. 10 -> $a {

    # $a 在这可用 

}

# $a 在这不可用 



while my $b = get_stuff() {

    # $b 在这可用 

}

# $b 在这仍然可用 



my $c = 5;

{

    my $c = $c;

    # $c 在这是没有定义的 

}

# $c 在这是 5 



my $y;

my $x = $y + 2 while $y = calc();

# $x 这仍然可用 
```
描述

语法作用域

Perl 6 中的作用域和 Perl 5 中的比较相似, 一个块会生成一个新的词法范围. 变量名搜索是从最里面的词法范围开始, 如果没有找到, 就查找接下来的外部范围. 就象 Perl 5 中的 my 声明的变量是一个词法变量, 如果使用 our 声明的其实是引入一个包变量的别名的词法变量.

这也有一些细微的差别: 变量在一个代码块的开始位置声明的, 在块的其它位置都可以见到 ( 例如: 在一个 while 循环的条件中 );

Perl 6 永远只能查找到词法范围内所限定名称 ( 名称包含变量和函数 ).

如果你想限制作用域, 你可以在块上使用形式参数:
```perl
if calc() -> $result {

    # 你可以在这使用 $result

}

# $result 在这就不可用了
```
变量在声明后立即可用, 但是 Perl 5 需要在行结尾 ( 可能是分号处 ) 才能使用.
```perl
my $x = .... ;

        ^^^^^

        $x visible here in Perl 6

        but not in Perl 5
```
动态作用域

 原来的 local 关键字, 现在叫 temp, 使用这个, 如果你没有对这个变量进行初始化, 它这个提供的值是上一个名字空间的原来的值 ( 并不会为 undef );

此外还有一种新的被称为 hypothetical 的动态作用域的变量. 如果块中出现了异常, 接下来这个变量会先恢复先前的值, 如果没有, 就保持新的值.
Context variables 上下文变量

 在 Perl 5 里, `$!`, `$_` 是全局变量, 但在 Perl6 里就是上下文变量, 就是根据上下文的变化而变化的, 在 Perl6 中就是所谓的动态作用域 (dynamic scoping).

这解决了一个在 Perl 5 中的老问题, 在 Perl 5 中的 DESTROY 的子函数可以在一个代码块中被调用来退出, 这个会改变全局的变量, 例如下面的错误.
```perl
# Broken Perl 5 code here: sub DESTROY { eval { 1 }; }
eval { my $x = bless {}; die "Death\n"; }; print $@ if $@; # No output here
```
在 Perl 6 中对于这个问题就不在使用隐式的全局变量了.

 ( 在 Perl 5.14 中, 有其它的方式来保护 $@ 的修改, 可以避免这种危害 )

伪包

 对于一个块中, 想访问词法变量范围之外 ( 块内访问块外的词法变量 ) 相同名字变量, 可以使用 OUTER 这个伪包, 方法如下:
```perl
my $x = 3;

{

    my $x = 10;

    say $x;             # 10

    say $OUTER::x;      # 3

    say OUTER::<$x>     # 3

}
```
同样函数可以通过 CALLER 和 CONTEXT 来访问伪包的内容. 这不同之处在于 CALLER 只访问最接近的 caller 的命名空间的变量, CONTEXT 的工作方式很象 UNIX 的环境变量, 得到的是上下文变量的值. 当使用上下文的伪包调用时, 需要在变量声明的时候使用 is context.

动机

 我们知道操作和使用全局变量并不好, 会引起很多问题. 我们目前有很多更加好的作用域的机制来实现, 因此, 全局变量仅用于本质上是全局数据, 象 %*ENV 或者 $*PID.

代码块作用域规则可以极大的简化我们对这些的处理.

下面引用了一段 Perl 5 中 perlsyn 的文档, 我不希望 Perl 6 中还有类似的东西:

NOTE: The behaviour of a "my" statement modified with a statement modifier conditional or loop construct (e.g. "my $x if ...") is undefined. The value of the "my" variable may be "undef", any previously assigned value, or possibly anything else. Don't rely on it. Future versions of perl might do something different from the version of perl you try it out on. Here be dragons.

另请参阅

S04 中有关变量范围: http://perlcabal.org/syn/Shtml.
S02 中所有有的伪包和说明上下文的范围的内容: http://perlcabal.org/syn/Shtml#Names.

## 19 正则的反击


概要

```perl
# normal matching:

if 'abc' ~~ m/../ {
    say $/;                 # ab
}



# 匹配通过隐含的 :sigspace 修饰符

if 'ab cd ef'  ~~ mm/ (..) ** 2 / {
    say $1;                 # cd
}



# substitute with the :sigspace modifier

my $x = "abc     defg";
$x ~~ ss/c d/x y/;
say $x;                     # abx     yefg
```

描述

 由于正则表达式的基本知识都已经涵盖在 lesson 07, 这里有关于正则表达式一些有用的 ( 但不是很有条理 ) 补充.
匹配

 匹配正则表达式时你并不一定需要编写 grammars, 传统的 `m/…/` 现在还是可以接着使用的, 并且还多了个新的兄弟使法, 就是使用 `mm/…/`, 这是隐含的是使用了 `:sigspace` 修饰符. 记住, 这意味着空格在正则表达式中由 `<.ws>` 规则代替的.

 `<.ws>` 是指, 如果在单词的中间有空格, 默认的规则是匹配 `\s+`, 其它的时候匹配 `\s*`.

这的 `:samespace` 修饰符需要非常小心, 空格匹配的 `ws`规则会做为象分割符一样的槽. 这个匹配空格被复制到右侧的相应位置, 然后给中间的字符按前后进行置换. 同样 `:samecase` 修饰符可以简写成 `:ii`, 并且会保存前大小写的信息.
```perl
my $x = 'Abcd';
$x ~~ s:ii/^../foo/;
say $x;                     # Foocd

$x = 'ABC'
$x ~~ s:ii/^../foo/;
say $x                      # FOO
```
例如, 如果你环境变量中很多是大写, 这时你想替换象模块名 Foo 到 Bar 之类的场合非常有用, 因为使用 :ii 修饰符会自动保存大小写的信息.

这种复制字符对应字符的情况, 这有很多智能的版本; 当绑定使用 :sigspace (短写 :s) 修饰符, 它会尝试发现原来字符的模式. 识别出.lc, .uc, .lc.ucfirst, .uc.lcfirst 和 .lc.capitaliz ( Str.capitalize 是每个单词的首字母大写 ). 只要识别出前面这几种模式就会给这些模式应用到后面替换的字符串上.

```perl
my $x = 'The Quick Brown Fox';
$x ~~ s :s :ii /brown.\*/perl 6 developer/;

# $x is now 'The Quick Perl 6 Developer'
```

Alternations 或匹配

 匹配多个条件交替 |, 但它和 Perl 5 比起来还是有些不同. 这个并不是按顺序匹配第一个, 它现在在正则中并行的去匹配, 并取匹配到的最长的一个.
```perl
'aaaa' ~~ m/ a | aaa | aa /;
say $/                          # aaa
```
虽然这可能看起来像一个微不足道的变化, 它影响深远, 并且这对于 grammars 的可扩展性是至关重要的的. 自从 Perl 使用 grammar 来进行解析, 它对于象 ++$a 这种会解析成单个 ++ 的标记, 不然会解析成二个 prefix:<+> 的标记.

对于旧的方式, 顺序匹配第一个找到的可以使用 ||:
```perl
grammar Math::Expression {

    token value {

        | <number>

        | '('

          <expression>

          [ ')' || { fail("Parenthesis not closed") } ]

    }



    ...

}
```
这的 { ... } 是执行的一个闭包, 并且它在表达式失败时调用闭包中的 fail 函数. 这个分支语句用于当前面的 ')' 没找到时才执行, 所以可以使用它来做正则解析错误的提示.

还有其它的方法来做或者的条件, 例如你想给一个数组做 "插值", 这时会使用或者的方式匹配它的值:
```perl
$_ = '12 oranges';

my @fruits = <apple orange banana kiwi>;

if m:i:s/ (\d+) (@fruits)s? / {

    say "You've got $0 $1s, I've got { $0 + 2 } of them. You lost.";

}
```
这还有另一种结构来自动匹配最长的或者条件: multi regexes. 这可以写 multi token name 或者 proto:
```perl
grammar Perl {

    ...

    proto token sigil { * }

    token sigil:sym<$> { <sym> }

    token sigil:sym<@> { <sym> }

    token sigil:sym<%> { <sym> }

    ...



   token variable { <sigil> <twigil>? <identifier> }



}
```
这个例子中的 multiple tokens 叫做 sigil, 会给 sym 做参数化. 当使用这个短名称, 如 sigil 时, 所有的这个标记会去找或者的条件. 你可能认为这个方式来写或者条件的匹配非常麻烦. 但它有个巨大的优势就是可以写 '$'|'@'|'%': 这是非常容易扩展的:
```perl
grammar AddASigil is Perl {

    token sigil:sym<!> { <sym> }

}

# wow, we have a Perl 6 grammar with an additional sigil!
```
你也可以覆盖现有的规则:
```perl
grammar WeirdSigil is Perl {

    token sigil:sym<$> { '°' }

}
```
在这个 grammar 中的 sigil 是一个标量变量 °, 所以每当 grammar 找到一个 sigil 它会查找 。 而不是 $, 但编译器会知道你是使用了正则 `sigil:sym<$>` 来匹配.

接下来你的课程, 给你看一个真实的实例, 这个例子在 Rakudo 是可以正常工作的.



##     20  A Grammar for XML 

概要
```perl
grammar XML {

    token TOP   { ^ <xml> $ };

    token xml   { <text> [ <tag> <text> ]* };

    token text {  <-[<>&]>* };

    rule tag   {

        '<'(\w+) <attributes>*

        [

            | '/>'                 # a single tag

            | '>'<xml>'</' $0 '>'  # an opening and a closing tag

        ]

    };

    token attributes { \w+ '="' <-["<>]>* '"' };

};
```
描述

 到目前为止, 我们看到的都是 Perl 6 语言本身的一些实现的特性. 现在需要告诉你这不是一个纯粹 yy 的语言, 所以讲一些真实的应用, 来向你展示 Perl 强大的语法, 我们这课是使用 Rakudo 上的 grammar 来解析基本的 XML.

你可以看看 http://rakudo.org/how-to-get-rakudo/ 来怎么样安装这个.

Our idea of XML

对于我们的目标 XML 解析是非常简单的: 它是包含了一些纯文本和一些嵌套的的标签并能包含一些可选的属性. 所以我们先写几个可用和不可用的 "XML" 的测试.
```perl

my @tests = (

    [1, 'abc'                       ],      # 1

    [1, '<a></a>'                   ],      # 2

    [1, '..<ab>foo</ab>dd'          ],      # 3

    [1, '<a><b>c</b></a>'           ],      # 4

    [1, '<a href="foo"><b>c</b></a>'],      # 5

    [1, '<a empty="" ><b>c</b></a>' ],      # 6

    [1, '<a><b>c</b><c></c></a>'    ],      # 7

    [0, '<'                         ],      # 8

    [0, '<a>b</b>'                  ],      # 9

    [0, '<a>b</a'                   ],      # 10

    [0, '<a>b</a href="">'          ],      # 11

    [1, '<a/>'                      ],      # 12

    [1, '<a />'                     ],      # 13

);



my $count = 1;

for @tests -> $t {

    my $s = $t[1];

    my $M = XML.parse($s);

    if !($M  xor $t[0]) {

        say "ok $count - '$s'";

    } else {

        say "not ok $count - '$s'";

    }

    $count++;

}
```
这会列出 "good" 和 "bad" 的 XML. 只需要调用 XML.parse($string) 来运行这些测试的的列表. 根据惯例这些匹配的 grammar 的语法, 需要符合 "TOP" 的该规则才行.

 ( 你可以看测试 1, 这个我们并没有 root 标签, 但我们会很容易来加入此限制 ).

grammar 开发

XML 的本质必然是标签嵌套, 所以我们给重点放在了第二个测试上面. 这个上面能使用这个测试脚本中的 top .
```perl
grammar XML {

    token TOP   { ^ <tag> $ }

    token tag   {

        '<' (\w+) '>'

        '</' $0   '>'

    }

};
```
现在运行测试脚本:
```perl
$ ./perl6 xml-pl

not ok 1 - 'abc'

ok 2 - '<a></a>'

not ok 3 - '..<ab>foo</ab>dd'

not ok 4 - '<a><b>c</b></a>'

not ok 5 - '<a href="foo"><b>c</b></a>'

not ok 6 - '<a empty="" ><b>c</b></a>'

not ok 7 - '<a><b>c</b><c></c></a>'

ok 8 - '<'

ok 9 - '<a>b</b>'

ok 10 - '<a>b</a'

ok 11 - '<a>b</a href="">'

not ok 12 - '<a/>'

not ok 13 - '<a />'
```
所以这是使用了简单的规则来解析出了开始标签和结束标签对, 也正确的拒绝掉了无效的 XML 中的四个例子.

第一个测试应该很容易通过，所以让我们试试这个:
```perl
   grammar XML {

       token TOP   { ^ <xml> $ };

       token xml   { <text> | <tag> };

       token text  { <-[<>&]>*  };

       token tag   {

           '<' (\w+) '>'

           '</' $0   '>'

       }

    };
```
(记住, <-[...]> 是一个用于否定的字符类.)

现在运行:
```perl

$ ./perl6 xml-pl

ok 1 - 'abc'

not ok 2 - '<a></a>'

(rest unchanged)
```
为什么处理第第二个测试就工作了? 答案是因为 Rakudo 还不支持 token 的长匹配 ( update 2013=01: 现在支持 ), 这个匹配是顺序的. <text> 匹配空字符串命中, 所以 <text> | <tag> 从来没有尝试匹配 <tag>, 给这二个顺序修改一下会有所帮助.

但我们并不只想无论怎么样都能匹配到纯文本或标签, 我们希望这二个能随机组合起来:
```perl
token xml   { <text> [ <tag> <text> ]*  };
```
([...] 是不会捕捉内容, 象在 Perl 5 中的 (?: ... ) ).

现在这前二个测试都能通过.

第三个测试, ..<ab>foo</ab>dd, 找有开头和结构标记之间的文本, 还要允许有多个标记, 因为不只是唯一中间可以放文本, 还要可以放任意的 XML. 因为这叫 <xml>.
```perl
token tag   {

    '<' (\w+) '>'

    <xml>

    '</' $0   '>'

}
```

./perl6 xml-pl
```perl

ok 1 - 'abc'

ok 2 - '<a></a>'

ok 3 - '..<ab>foo</ab>dd'

ok 4 - '<a><b>c</b></a>'

not ok 5 - '<a href="foo"><b>c</b></a>'

(rest unchanged)
```
我们现在可以专注于属性的实现 ( href="foo" ):
```perl
token tag   {

    '<' (\w+) <attribute>* '>'

    <xml>

    '</' $0   '>'

};

token attribute {

    \w+ '="' <-["<>]>* \"

};
```
这并不会有新的测试通过. 原因是因为签名和属性之间的有空白. 我们不使用 \s+ 或 \s* 而是使用 token 转到 rule, 所以这会有 :sigspace 的修饰符:
```perl
rule tag   {

    '<'(\w+) <attribute>* '>'

    <xml>

    '</'$0'>'

};

token attribute {

    \w+ '="' <-["<>]>* \"

};
```
现在，所有的测试都通过了，除了最后两个:
```perl
ok 1 - 'abc'

ok 2 - '<a></a>'

ok 3 - '..<ab>foo</ab>dd'

ok 4 - '<a><b>c</b></a>'

ok 5 - '<a href="foo"><b>c</b></a>'

ok 6 - '<a empty="" ><b>c</b></a>'

ok 7 - '<a><b>c</b><c></c></a>'

ok 8 - '<'

ok 9 - '<a>b</b>'

ok 10 - '<a>b</a'

ok 11 - '<a>b</a href="">'

not ok 12 - '<a/>'

not ok 13 - '<a />'
```
这些包含在封闭的标签中有单个斜线 /. 这个很容易, 我们只要在我们的 rule 的 tag 中加入这个就好:
```perl
rule tag   {

    '<'(\w+) <attribute>* [

        | '/>'

        | '>' <xml> '</'$0'>'

    ]

};
```
所有的测试都通过了, 我们很高兴, 我们的第一个 grammar 效果很好.

More hacking

 Playing with grammars is much more fun that reading about playing, so here's what you could implement:

     plain text can contain entities like &amp;
     I don't know if XML tag names are allowed to begin with a number, but the current grammar allows that. You might look it up in the XML specification, and adapt the grammar if needed.
     plain text can contain <![CDATA[ ... ]]> blocks, in which xml-like tags are ignored and < and the like don't need to be escaped
     Real XML allows a preamble like <?xml version="0.9" encoding="utf-8"?> and requires one root tag which contains the rest (You'd have to change some of the existing test cases)
     You could try to implement a pretty-printer for XML by recursively walking through the match object $/. (This is non-trivial; you might have to work around a few Rakudo bugs, and maybe also introduce some new captures).

 (Please don't post solutions to this as comments in this blog; let others have the same fun as you had ;-).

 Have fun hacking.

动机

 这个很强大并且有意思

另请参阅

Regexes are specified in great detail in S05: http://perlcabal.org/syn/Shtml.

 More working examples for grammars can be found at https://github.com/moritz/json/ (check file lib/JSON/Tiny/Grammar.pm).
 
 

##     21  Subset types 子集类型
Subset Types 子类型

概要
```perl
subset Squares of Int where { .sqrt.Int**2 == $_ };

multi sub square_root(Squares $x --> Int) {

    return $x.sqrt.Int;

}

multi sub square_root(Num $x --> Num) {

    return $x.sqrt;

}
```
描述

Java 程序员倾向于认为类型就是一个类或者接口 ( 这有点像一个残缺的类 ), 但这种观点是因为对 Perl 6 的了解太有限了. 类型普通普通看法是对容器中可以放什么值进行约束.

传统的一个约束是, 某个东西, 它是一个 X 类的对象或者它是从 X 继承, Perl 6 也有类似的限制象类或者对象 does role Y, 或者这一段代码返回 true 为我们的对象. 这个我们在这叫 subset 类型.
```perl
subset Even of Int where { $_ % 2 == 0 }

# Even 现在是可以象其它类型一样使用了 
my Even $x = 2;

my Even $y = 3; # 类型不匹配错误 
```
( 试试, Rakudo 实现的子类型 ).

你也可以在子函数中使用匿名的子类型.
```perl
sub foo (Int where { ... } $x) { ... }
# or with the variable at the front:
sub foo ($x of Int where { ... } ) { ... }
```
动机

 代码的终极可扩展性就是许任意类型的约束形式: 如果你不喜欢现有的类型系统, 你可以使用基于自己创建的子类型.

这也使的 lib 库更加容易扩展: 用来替换 die 处理不正常的数据, 在子函数和方法上只需要声明所需要的类型的方式, 不正常的数据就会被 multi dispatcher 所拒绝. 如果其它人想处理提交要处理的坏数据时, 因只需要简单的指定所需要的子类型, 就可以正常的工作. 例如, 你可以写一个 lib 库用于处理实数, 你可以通过这种方式扩展, 让他可以处理其它复杂的数字.
##     22  State of the Implementations
##     23  Quoting and Parsing (-)
 引号和解析

概要
```perl
my @animals = <dog cat tiger>
# or
my @animals = qw/dog cat tiger/;
# or 
my $interface = q{eth0};
my $ips = q :s :x /ifconfig $interface/;

# -----------

sub if {

    warn "if() calls a sub\n";

}

if();
```
描述

引号

Perl 6 对引号字符的处理有强大的机制, 你可以对你想要处理的字符串的特性进行`精确的控制`.

Perl 5 中有单引号, 双引号和 `qw(…)` ( 单引号, 按分割的空格 ) 和形式上就是单引号和双引号的同义的 `q(..)` 与 `qq(…)`.

 Perl 6 又定义了一个名为 `Q` 的引号操作来修饰变量. 这 :b ( 反斜杠 ) 修饰符让 \n 之类可以让反斜杠插值, 这个 :s 修饰符可以让标量进行插值. 这个 :c 可以让闭包的函数进行插值 ("1 + 2 = { 1 + 2 }"), :w 用于象 qw/.../ 一样分割单词.

你可以任意组合这些修饰符. 例如, 你也许想 qw/../ 只插标量, 但没其它的? 没问题:
```perl
my $stuff = "honey";
my @list = Q :w :s/milk toast $stuff with\tfunny\nescapes/;
say @list[*-1];                     # prints with\nfunny\nescapes
```
下面是修饰符可用的列表, 基本大部分直接来自 S02 , 所有的这些有很长的名字, 我这个地方省略了.
```perl
特性:

    :q          内插 \\, \q 和 \'
    :b          其他的反斜杠转义序列 \n, \t

操作:

    :x          执行 shell 命令, 返回其结果
    :w          分割空格
    :ww         分割空格, 使用引号保护

变量内插:

    :s          内插值 scalars   ($stuff)
    :a          内插值 arrays    (@stuff[])
    :h          内插值 hashes    (%stuff{})
    :f          内插值 functions (&stuff())

其它:

    :c          内插闭包 closures  ({code})
    :qq         插值下面这些 :s, :a, :h, :f, :c, :b
    :regex      解析正则 
还有一些短的形式:

q       Q:q
qq      Q:qq
m       Q:regex
你也可以省略第一个冒号 : 如果使用引号的简短形式:

symbol      short for
qw          q:w
Qw          Q:w
qx          q:x
Qc          Q:c
# and so on.
```
注意, 有一种形式不能工作, 有些 Perl 5 的程序员容易搞错: 你并不能在 Perl 6 中写 qw(...) 这个圆括号. 它现在是插值调用子函数叫 qw.

解析

 解析开始发挥作用时: 象 identifier(...) 这种都会解析成子函数调用.

`if($x<3)` 它会解析成调用子函数 if. 你可以用空格来防止歧义:
```perl
if ($x < 3) { say '<3' }
```
或者干脆省略括号:
```perl
if $x < 3 { say '<3' }
```
这也意味着 Perl 6 没有关键字, 其它象 use 或 if 关键字, 这也只是特定作用的特殊的语法.

动机

 引号修饰符的各种组合都已经在内部使用, 例如 q:w 用于解析 <...>, 和 :regex 用于 m/.../.

这些暴露给用户, 可以获得非常好的灵活性, 并且可以非常容易的编写宏, 使用提供的引号的语义实现成快捷方式.

当你限制关键字的特性, 你会有很多向后兼容的麻烦, 如果你想改变一个关键字的话.

另请参阅

http://perlcabal.org/syn/Shtml#Literals

##     24  Recude meta operator
Reduction 元操作

概要
```perl
say [+] 1, 2, 3;    # 6
say [+] ();         # 0
say [~] <a b>;      # ab
say [**] 2, 3, 4;   # 2417851639229258349412352



[\+] 1, 2, 3, 4     # 1, 3, 6, 10
[\**] 2, 3, 4       # 4, 81, 2417851639229258349412352



if [<=] @list {
    say "ascending order";
}
```
Description

这个 reduction 的元操作 [...] 可以放入所有的相关的缀操作符, 并把它变成一个列表操作符. 相当于给在这个操作符后面的列表中所有的元素进行前面的缀操作符的操作. 所以象 [op] $i1, $i2, @rest 返回的结果和你写的 $i1 op $i2 op @rest[0] op @rest[1] ... 是相同的.

这个东西非常强大, 你可要使用加 + 操作符就可以实现 sum 的功能, 使用 ~ 放到这个中就能实现 join ( 使用空分隔 ) 等等. 这个有点类似 List.reduce 的功能, 如果你有一些接触到函数式编程, 你可能知道 foldl 和 foldr ( 在 Lisp 和 Hashell 中有 ). 不同处在于 [...] 会涉及到其中的缀操作符的结合性, 所以 [/] 1, 2, 3 会解释成 (1 / 2) / 3 ( 左结合性 ), [**] 1, 2, 3 可以正常的处理成 1 ** (2**3) ( 右结合性 ).

就象其它的操作符一样, 在操作符中间是禁止出现空格, 所以你可以写 [+], 但你不能写 [ + ].

由于比较操作符可串连, 你也可以这样写
```perl
if  [==] @nums       { say "all nums in @nums are the same"     }
    elsif [<]  @nums { say "@nums is in strict ascending order" }
    elsif [<=] @nums { say "@nums is in ascending order"        }
```
你甚至可以没有赋值操作符:
```perl
my @a = 1..3;
[=] @a, 4;          # same as @a[0] = @a[1] = @a[2] = 4;
```
注意这个地方 [...] 总是返回标量, 所以 [,] @list 其实和 [@list] 是一样的.
取得过程中分片的结果

 这个操作符有一种特殊形式使用反斜杠象 [\+]. 它会返回列表的运算的结果的列表的每一部分. 所以 [\+] 1..3 返回的列表是 1, 1+2, 1+2+3, 这个结果当然是 1, 3, 6.
```perl
[\~] 'a' .. 'd'     # <a ab abc abcd>
```
这个右结合性的操作符是从右到左的列表结果, 所以你可以取得象下面一样的结果:
```perl
[\**] 1..3;         # 3, 2**3, 1**(2**3), which is 3, 8, 1
```
多个 reduction 的操作符也可以绑定:
```perl
[~] [\**] 1..3;     # "381" 
```
动机

 程序员是懒惰的, 所以我们并不想我们花了很多时间写了个循环, 其中只放一行用于操作列表所有元素的二元运算符.

List.reduce 也可以做类似的事情, 但它并不是简洁的元操作符 ( [+] @list 比起@list.reduce(&infix:<+>)` ), 注意要小心的的运算符的结合性.

If you're not convinced, play a bit with it (pugs mostly implements it), it's real fun.

另请参阅

##     25  Cross meta operator
 Cross 元操作符

概要
```perl
for <a b> X 1..3 -> $a, $b {
    print "$a: $b   ";
}
# output: a: 1  a: 2  a: 3  b: 1  b: 2  b: 3

.say for <a b c> X 1, 2;
# output: a1\n a2\n b1\n b2\n c1\n c2\n
# (with real newlines instead of \n)
```
描述

这个 cross 操作符 X 用于返回两个或多个列表的笛卡儿积, 这表示它会返回所有可能的元组, 其中第一个元素是第一个列表中的元素，第二元素是第二个列表中的元素等..

如果有另一个操作符放在 X 之后, 这个操作符会被运用到所有的元组元素上, 它的结果也会相应换成这样, 所以 1, 2 X+ 3, 6 会返回 1+3, 1+6, 2+3, 2+6 的操作结果 4, 7, 5, 8.

动机

这个很常见的操作, 常常人们必须遍历两个或两个以上列表的所有可能的组合, 以及交叉其它操作符压缩成的单次迭代, 从而大大简化程序, 并只要使用一行缩进就搞定了.

使用这些元操作符有时不再需要进行循环.

另请参阅

[http://perlcabal.org/syn/Shtml#Cross_operators]

## 26  异常和异常控制

 

概要
```perl
try {
    die "OH NOEZ";
    CATCH { 
        say "there was an error: $!";
    }
}
```
描述

 异常在 Perl 6 中是正常的正常控制流的一部分.

异常隐含着错误 ( 如除以零, 调用不存在的方法, 类型检查失败 ) 或者通过显示的调用 die 之类其它的产生的异常.

当异常发生时, 程序会在所有的函数中寻找相关的 CATCH 关键字或 try 代码段. 如果没有 catch 和 try 被找到, 程序退出, 这个时候可能会打印出一些错误提示但更可能是不会的. 如果 catch 或 try 被找到了, 错误信息会被存在特殊变量 $! 中, catch 中的内容会被执行. 另外, 当只有一个 try 代码段而没有对应的 catch 的时候, try 代码段会返回 undef.

到目前为止讲的异常处理都还比较常规, 但错误处理对程序来说是很复杂的, 有的时候甚至一个普通的函数返回 "return" 也会抛出异常. 这种情况被叫做 "control exceptions"，可以用 CONTROL 块获取到, 或是在每个 routine 定义的时候捕获到。

 看下面这个例子:
```perl
use v6;
my $block = -> { return "block"; say "still here" };

sub s {
    $block.();
    return "sub";
}

say s();
```
这的 return "block" 会抛出一个控制异常, 使其不仅退出当前块 ( 因此不会在屏幕上打印 "still here" ), 还会退出子函数, 这时会补 sub s... 的声明捕捉. 这是有效返回是字符串, 它被做为返回值, 并在最后一行的 say 来打印出来.

嵌入调用 `$block.()` 中放入 `$block.()` 块或者增加 `CONTROL { ... }` 块到程序的主体中可以使其捕获到异常.

和其它编程语言不一样的, 这个 `CATCH/CONTROL` 块是工作在错误被捕获( 不是在外面 ) 的范围内, 这会完全进入词法变量, 这使得更容易产生有用的错误信息, 并且可以防止在处理错误之前, 这个块就被 DESTROY 掉.

不抛出异常

Perl 6 中全部包含了多线程的想法, 尤其是自动并行化. 为了确保不是所有的线程要遭受从一个单独的线程中止而中断, 发明了一种 "软" 异常.

当一个函数调用 fail($obj), 它会返回一个特定的 undef 的值, 其实是包含了 $obj ( 通常是一个错误消息 ) 和 back trace ( 文件名和行号 ). 进程需要在外面对这个特定的未定义的值进行检查, 如果它是未定义的来由自己控制异常抛出.
```perl
my @files = </etc/passwd /etc/shadow nonexisting>;
my @handles = hyper map { open($_) }, @files;
```
在这个例子中 hyper 操作会让 map 尽可能并行的做自己所要做的动作. 当打开一个不存在的文件失败时, 普通的 `die "No such file or directory"` 会中止所有其它的 open 操作. 但如果使用了失败的打开后启用 `fail("No such file or directory")` 来替换 die 操作, 它会给调用者让其来检查包含的 @handles, 并且仍然可以访问完整的错误消息.

如果你不喜欢 "软" 异常的处理, 你可以 `use fatal;` 这会让程序从一开始就给全部的异常的 `fail()` 变成立即抛出的所有异常.

动机

 一个好的编程语言需要异常来处理错误的条件. 总是检查返回值是一种折磨也容易忘记.

由于传统的异常处理可能会影响隐式的并行性. 所以我们需要一个二全其美的解决方案: 不会立即 kill 掉一切, 并且仍然不会丢失任何信息.

## 27 常用的 Perl 6 数据处理的习惯用法

概要
```perl6
# 从键和值的列表创建哈希 
# 方案 1: slices 切片 

my %hash; 
%hash{@keys} = @values; 

# 方案 2: meta operators 元操作 
my %hash = @keys Z=> @values;

# 从数组创建哈希, 给每个数组元素 true 值: 
my %exists = @keys Z=> 1 xx *;

# 限制值的范围, 这是 0 ..  
my $x = -2; 
say 0 max $x min 10;

# dubugging: 给容器中的值 dump 出来, 包含名字, 输出到标准错误 
note :$x.perl;

# 不区分大小写排序 
say @list.sort: *.lc;

# 强制属性 

class Something { 
    has $.required = die "Attribute 'required' is mandatory"; 
}

Something.new(required => 2); # no error 
Something.new() # BOOM
```
描述

 学习一门语言只靠规范是不够的, 它必须在生产中使用. 相反, 你们需要知道如何解决具体问题. 常用的处理模式叫 idioms 惯用用法, 可以帮助我们在每次有问题的时候不用重新发明轮子.

所以这是一些常用的 Perl 6 的习惯用法来操作数据结构.

哈希

**从键和值的列表创建哈希**

```perl
# 方案 1: slices 切片 
my %hash; 
%hash{@keys} = @values; 
```

```perl
# 方案 2: meta operators 元操作 
my %hash = @keys Z=> @values;
```
这个第一个方案和你的 Perl 5 是基本相同的: 使用切片来分配. 第二个方案是使用的 zip 操作符的 Z 操作, 这会 zip 成一个列表,象: `1, 2, 3 Z 10, 20, 30` 变成 `1, 10, 2, 20, 3`,  这的 `Z=>` 是元操作, 在这通过 => ( Pair 创建的操作 ) 来绑定 zip . 所以 `1, 2, 3 Z=> 10, 20, 30` 相当于 `1, 2, 3 Z=> 10, 20,  赋值给哈希一个数组列表变量.

对于存在检查, 这个哈希的值是不什么重要, 主要他们在布尔上下文返回 True. 在这种情况下, 有一个不错的方式来初始化哈希, 给 keys 一个数组或者列表
```perl
my %exists = @keys Z=> 1 xx *;
```
这是一个 lazy, 在右侧 1 组成无穷列表, 并依赖 Z 来结束这个列表.

[Numbers]

有时你从一些其它的地方取得一个数字, 但这个数字有一个自己预先定义的范围 ( 例如, 这样它可以作为一个数组索引 ).

在 Perl 5 中, 你常常会遇到什么 $a = $b > $upper ? $upper : $b, 其它的限制是 lower. 在这个地方我们使用 max 和 min 的中缀运算符, 可以简化成
```perl
my $in-range = $lower max $x min $upper;
```
因为 `$lower max $x` 返回两个数中较大的, 因此切出了这个范围的下端.

这为 `min` 和 `max` 是中缀运算符, 你也可以这样使用:
```perl
$x max= 0; $x min= 10;
```
[Debugging]

 Perl 5 中我们常常使用 `Data::Dumper`, 在 Perl 6 的中我们使用对象的 `.perl` 方法. 这二个都能尽可能生成, 真实的原始数据结构.

这个 `:$var` 生成 => 的键值对 ("colonpair"), 使用变量名做为关键字 ( 但前标记会剥离开 ). 因些, 它们会是 `var => $var` 一样的结构. `note()` 是用于写入标准错误, 并追加一个换行. 所以 `:$var.perl` 是一个获得用于调试, 名称, 目标的变量的值的快捷方式.

[Sorting]

象 Perl 5 中一样, 这个 sort 是内置的. 它可根据所采取的比较函数来比较两个值, 然后排序. 不同于 Perl 5 的是, 这更加智能, 如果你的参数只有一个值会自动使用 transformation.

如果你想过一个 transformed 对值进行比较, 在 Perl 5 中你可以这样:
```perl
# WARNING: Perl 5 code ahead
my @sorted = sort { transform($a) cmp transform($b) } @values;
# or the so-called Schwartzian Transform:

my @sorted = map { $_->[1] }
             sort { $a->[0] cmp $b->[0] }
             map { [transform($_), $_] }
             @values;
```             
上面二个的解决方案的在进行比较的时候, 第一个需要不断重复转换的输入. 第二个方案通过存储原始值转化后的值避免了重复输入, 但它多写了相当多的代码.

Perl 6 会自动使用第二种方案 ( 使用更加有效的 Schwartzian 转换, 避免数组的每个值重复转换 ), 这个转换函数只有一个参数:
```perl
my @sorted = sort &transform, @values;
```
强制属性

 通常我们强制一些属性必须存在, 是为了检查其构造函数中是否存在.

在 Perl 6 中也是这样工作的, 但它更加容易, 更加安全, 当请求每个需要存在属性时:
```perl
has $.attr = die "'attr' is mandatory";
```
这利用了默认值的机制. 当提供一个值, 这个就永远不会执行, 会用于生成默认值, 这个 die 不会触发. 如果有任何构造函数没设置这个值, 就会抛出异常.


## 28 - Currying 柯里化

概要
```perl
  use v6;
  my &f := &substr.assuming('Hello, World');
  say f(0, 2);                # He
  say f(3, 2);                # lo
  say f(7);                   # World

  say <a b c>.map: * x 2;     # aabbcc
  say <a b c>.map: *.uc;      # ABC
  for ^10 {
      print <R G B>.[$_ % *]; # RGBRGBRGBR
  }
```
描述

Currying 和 partial application 用于用一个函数产生新的函数, 或是用一个方法提供一些参数再产生新的方法. 因为可以动态产生很多函数, 这样就省去很多码字的时间, 当函数需要返回一个回调的时候也会非常有用.

假设你想要一个函数用于从 `"Hello, World"` 做各种提取子串操作, 这样做的经典方法是写自己的函数:
```perl
  sub f(*@a) {
      substr('Hello, World', |@a)
  }
```
通过 `assuming` 方法来实现柯里化

Perl 6 提供了一个方法 `assuming` 在代码的对象上, 它可以传递参数给它的调用者成为一体, 并返回调用者的功能的函数.
```perl6
my &f := &substr.assuming('Hello, World');
```
现在 `f(1, 2)` 相当于 `substr('Hello, World', 1, 2)`.

这个 `assuming` 方法也可以工作在操作符上, 因为操作符只是一个奇怪名字的函数. 你想实现一个子函数, 给任何传递给它的数值都增加 2 , 你可以这样写.
```perl6
my &add_two := &infix:<+>.assuming(2);
```
但这是一种很无聊的写法, 所以有另一种选择.

通过 Whatever-Star ( * 号 ) 来实现柯里化
```perl6
  my &add_two := * + 2; 
  say add_two(4);         # 6 
```
星号, 叫 _Whatever_, 是一个占位符参数, 所以整个表达式返回一个闭包. 多个星号 "Whatevers" 在单个表达式中也是可以的, 这样也会创建闭包, 但希望提供更多的参数, 通过形参替换每个 "*" 元素. 所以 `* * 5 + *` 相当于 `-> $a, $b { $a * 5 + $b }`.

```perl6
  my $c = * * 5 + *; 
  say $c(10, 2);                # 52
```  
注意第二个 `*` 是一个中缀运算符, 不是术语, 所以不会被 Whatever-currying 影响.

这的东西是由星号和闭包组成, 直接在语法驱动层实现的, 所以这些是在编译时完成, 所以:
```perl6
  my $star = *; 
  my $code = $star + 2
```
如果这不构造成一个闭包的话, 就会出现 die 并给出一个信息, 必须由这个来做为占位符并返回闭包

  Can't take numeric value for object of type Whatever
Whatever-Star ( * 号 ) 的柯里化比起 `.assuming` 更加灵活, 因为它可以有其它的东西做为第一个参数:

    say  ~(1, 3).map: 'hi' x *    # hi hihihi
这的柯里化的第二个参数是一个字符重复中缀操作 `x`, 所以它在这个地方返回一个闭包. 然后调用前面的数字做为参数, 根据参数生成指定数量的字符.

这对象的方法的调用者也可以是星号.

      say <a b c>.map: *.uc;      # ABC
涉及一个闭包, 给其内容做为参数为其调用 `uc` 的方法.

动机

Perl 5 中也可用于函数式编程, 你可以看看 Jason Dominus' book _Higher Order Perl_.

 Perl 6 努力使用这些更加容易, 从而提供工作让你更加容易构造函数式编程. Currying 和容易的构造闭包是函数式编程的关键. 并且可以很容易的与 map 或者 grep 之类一起使用.

另请参阅

[http://perlcabal.org/syn/Shtml#Built-In_Data_Types]

 <http://hop.perl.plover.com/>

 <http://en.wikipedia.org/wiki/Currying>




