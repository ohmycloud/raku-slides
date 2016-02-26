title: Perl 6 中的变量
date: 2015-07-15 13:30:46
tags: Perl6
categories: Perl 6
---

<blockquote class="blockquote-center">走到途中才忽然发现，我只剩下一副模糊的面目，和一条不能回头的路</blockquote>


变量名以一个叫做魔符 sigil 的特殊字符开头, 后面跟着一个可选的第二个叫做 `twigil` 的特殊字符, 然后是一个标识符.

## Sigils

```perl
符号	   类型约束	                      默认类型     Flattens      Assignment
$	     Mu (no type constraint)      Any          No           item
&        Callable	                  Callable     No           item
@	     Positional                   Array        Yes          list
%	     Associative	              Hash         Yes          list
```

Examples:

```perl
my $square = 9 ** 2;
my @array  = 1, 2, 3;   # Array variable with three elements
my %hash   = London => 'UK', Berlin => 'Germany';
```

不带符号的变量也是可行的, 查看 [无符号变量](http://doc.perl6.org/language/variables#Sigilless_variables).

## 项和列表赋值

有两种类型的赋值, item 赋值和 list 赋值. 两者都使用 = 号操作符. 根据 = 号左边的语法来区别 = 是 item 赋值还是 list 赋值.

Item 赋值把等号右侧的值放到左侧的变量(容器)中.

例如, 数组变量(@符号)在列表赋值时清空数组自身, 然后把等号右侧的值都放进数组自身中. 跟 Item 赋值相比, 这意味着等号左侧的变量类型始终是 Array, 不管右侧是什么类型.

赋值类型(item 或 list)取决于当前表达式或声明符看到的第一个上下文:

```perl
my $foo = 5;            # item assignment
say $foo.perl;          # 5

my @bar = 7, 9;         # list assignment
say @bar.WHAT;          # Array
say @bar.perl;          # [7, 9]<>

(my $baz) = 11, 13;     # list assignment
say $baz.WHAT;          # Parcel
say $baz.perl;          # (11, 13)
```

如果内部赋值是一个声明符(例如 my), 就使用 item 赋值, 它比逗号和列表赋值的优先级更高:

```perl
my @array;
@array = my $num = 42, "str";   # item assignment: uses declarator
say @array.perl;                # [42, "str"]<> (an Array)
say $num.perl;                  # 42 (a Num)
```

类似地, 如果内部赋值是一个用于声明符初始化的表达式, 则内部表达式的上下文决定赋值的类型:

```perl
my $num;
my @array = $num = 42, "str";    # item assignment: uses expression
say @array.perl;                 # [42, "str"]<> (an Array)
say $num.perl;                   # 42 (a Num)

my ( @foo, $bar );
@foo = ($bar) = 42, "str";       # list assignment: uses parens
say @foo.perl;                   # [42, "str"]<> (an Array)
say $bar.perl;                   # $(42, "str")  (a Parcel)
```

然而, 如果内部赋值既不是声明符又不是表达式, 而是更大的表达式的一部分, 更大的表达式的上下文决定赋值的类型:

```perl
my ( @array, $num );
@array = $num = 42, "str";    # list assignment
say @array.perl;              # [42, "str"]<> (an Array)
say $num.perl;                # [42, "str"]<> (an Array)
```

这是因为整个表达式是 `@array = $num = 42, "str"`, 而 `$num = 42` 不是单独的表达式.

## 无符号变量

在 Perl 6 中创建不带符号的变量也是可能的:

```perl
my \degrees = pi / 180;
my \θ       = 15 * degrees;
```

然而, 这些无符号变量并不创建容器. 那意味着上面的 `degrees` 和 `θ` 实际上直接代表 `Nums`. 为了说明, 我们定义一个无符号变量后再赋值:

```perl
θ = 3; # Dies with the error "Cannot modify an immutable Num"
```

## Twigils

`Twigils` 影响变量的`作用域`。请记住 twigils 对基本的魔符插值没有影响，那就是，如果  `$a` 内插， `$^a`, `$*a`, `$=a`, `$?a`, `$.a`, 等等也会内插. 它仅仅取决于 `$`.


```perl
* 动态
! 属性(类成员)
? 编译时变量
. 方法(并非真正的变量)
< 匹配对象索引(并非真正的变量)
^ 自我声明的形式位置参数
: 自我声明的形式命名参数
= Pod 变量
~ 子语言
```

## *

动态变量

```perl
    my $lexical   = 1;
    my $*dynamic1 = 10;
    my $*dynamic2 = 100;

    sub say-all() {
        say "$lexical, $*dynamic1, $*dynamic2";
    }

    # prints 1, 10, 100
    say-all();

    {
        my $lexical   = 2;
        my $*dynamic1 = 11;
        $*dynamic2    = 101; # 注意,这儿没有使用 my 来声明

        # prints 1, 11, 101
        say-all();
    }

    # prints 1, 10, 101
    say-all();
```

`$lexical` 不是在调用者的作用域内被查找, 而是在 `&say-all` 被定义的作用域那儿
也就是第一行的 `$lexical = 1` 了. 另外两个动态作用域变量在调用者的作用域内被查找, 所以值为 11 和 101
第三个 `&say-all` 被调用后,  `$*dynamic1` 不再是 11 了. 但是 `$*dynamic2` 仍然是 101.

## !

属性是变量, 存在于每个类的实例中. 通过 `!` 符号它们可以从类的里面直接被访问到:

```perl
    class Point {
        has $.x;
        has $.y;

        method Str() {
            "($!x, $!y)"
        }
    }
```

注意属性是怎样被声明为 `$.x` 和 `$.y` 的, 但是仍然能够通过 `$!x` 和 `$!y` 访问到属性. 这是因为 在 Perl 6 中, 所有的属性都是`私有的`, 并且在类中能使用 `$!attribute-name` 直接访问这些属性. Perl 6 能自动为你生成访问方法.

## ?


编译时"常量", 可通过 `?` twigil 访问. 编译器对它们很熟悉, 并且编译后不能被修改. 常用的一个例子如下:

```perl
say "$?FILE: $?LINE"; # prints "hello.pl: 23" if this is the 23 line of a
                      # file named "hello.pl".
```

尽管不能在运行时改变它们, 用户可以(重新)定义这种常量.

```perl
constant $?TABSTOP = 4; # this causes leading tabs in a heredoc or in a POD
                        # block's virtual margin to be counted as 4 spaces.
```

## .


`.` twigil 真的不是用于变量的. 实际上, 看下面的代码:

```perl
    class Point {
        has $.x;
        has $.y;

        method Str() {
            "($.x, $.y)" # 注意我们这次使用 . 而不是 !
        }
    }
```

对自身调用了方法 x 和 方法 y, 这是自动为你生成的, 因为在你声明你的属性的时候, 你使用的是 `.` twigil 。 注意,  子类可能会覆盖那些方法. 如果你不想这个发生, 请使用 `$!x` 和 `$!y` 代替。

`.` twigil 只是调用了一个方法也表明下面是可能的

```perl
    class SaySomething {
        method a() { say "a"; }
        method b() { $.a; }
    }

    SaySomething.a; # prints "a"
```

## <

 `<` twigil 是 `$/<...>` 的别名,  `$/` 是匹配变量.

## ^

`^` twigil 为 block 块 或 子例程 声明了一个形式位置参数.  形如 `$^variable` 的变量是一种占位变量. 它们可用在裸代码块中来声明代码块的形式参数. 看下面代码中的块:

```perl
for ^4 {
    say "$^seconds follows $^first";
}
```

which prints

```perl
1 follows 0
3 follows 2
```

有两个形式参数，就是 `$first` 和 `$second`.  注意, 尽管 `$^second` 在代码中出现的比 `$^first` 早,  `$^first` 依然是代码块中的第一个形式参数. 这是因为占位符变量是以 Unicode 顺序排序的.

子例程也能使用占位符变量, 但是只有在子例程没有显式的参数列表时才行. 这对普通的块也适用

```perl
sub say-it    { say $^a; } # valid
sub say-it()  { say $^a; } # invalid
              { say $^a; } # valid
-> $x, $y, $x { say $^a; } # 非法, 已经有参数列表 $x,$y,$x 了
```

占位符变量语法上不能有类型限制. 也注意, 也不能使用单个大写字母的占位符变量, 如 `$^A`

## :

声明命名参数

## =

访问 Pod 变量

```perl
=begin Foo
...
=end Foo

#after that, $=Foo gives you all Foo-Pod-blocks
```

## ~

```perl
$~MAIN       the current main language (e.g. Perl statements)
$~Quote      the current root of quoting language
$~Quasi      the current root of quasiquoting language
$~Regex      the current root of regex language
$~Trans      the current root of transliteration language
$~P5Regex    the current root of the Perl 5 regex language
```

You may supersede or augment those languages in your current lexical scope by doing

```perl
augment slang Regex {  # derive from $~Regex and then modify $~Regex
    token backslash:std<\Y> { YY };
}
```

or

```perl
supersede slang Regex { # completely substitute $~Regex
    ...
}
```

## 变量声明符和作用域

通常, 使用 `my` 关键字创建一个新的变量就足够了:


```perl
 my $amazing-variable = "World";
 say "Hello $amazing-variable!"; # Hello World!
```

然而, 有很多声明符能改变作用域的细节

```perl
声明符 作用
my    作为词法作用域名字的开头
our   作为包作用域名字的开头
has   作为属性名的开头
anon  作为私有名字的开头
state 作为词法作用域但是持久名字的开头
augment 给已存在的名字添加定义
supersede 替换已存在名字的定义
```

还有两个类似于声明符的前缀, 但是作用于预定义变量:

```perl
前缀  作用
temp  在作用域的最后恢复变量的值
let   如果 block 成功退出就恢复变量的值
```

### my 声明符

使用 `my` 声明一个变量给变量一个词法作用域. 这意味着变量只在当前块中存在.例如:

```perl
{
my $foo = "bar";
say $foo; # -> "bar"
}
say $foo; # !!! "Variable '$foo' is not declared"
```

它抛出异常,因为只要我们在同一个作用域内 `$foo` 才被定义. 此外, 词法作用域意味着变量能在新的作用域内被临时地重新定义:


```perl

my $location = "outside";

sub outer-location {
    # Not redefined:
    say $location;
}

outer-location; # -> "outside"

sub in-building {
    my $location = "inside";
    say $location;
}

in-building;    # -> "inside"
outer-location; # -> "outside"
```



如果变量被重新定义了, 任何引用外部变量的代码会继续引用外部变量.
所以, 在这儿, `&outer-location` 仍然打印外部的 `$location`:


```perl
sub new-location {
    my $location = "nowhere"
    outer-location;
}

new-location; # -> "outside"
```

为了让 `new-location` 能打印 nowwhere, 需要使用 `*` twigil 让 $location 变为动态变量.
对于子例程来说, `my` 是默认作用域, 所以 `my sub x( ) { }` 和 `sub x( ) { }` 是一样的.

### our 声明符

our 跟 my 的作用类似, 除了把别名引入到符号表之外:

```perl
module M {
    our $Var;
    # $Var available here
}

# Available as $M::Var here.
```

### has 声明符


has 作用域在类的实例或 role 的属性上, 还有类或 roles 的方法上. has 隐式作用于方法上, 所以

```perl
has method x( ) { }
```

等价于:

```perl
method x( ) { }
```

### anon 声明符

`anon` 声明符阻止符号本安装在词法作用域内, 还有方法表中, 和其它任何地方.
例如, 你可以使用 `anon` 声明一个知道自己名字的子例程, 但是仍然不会被安装到作用域内:

```perl
my %operations =
    half   => anon sub half($x)   { $x / 2  },
    square => anon sub square($x) { $x * $x },
    ;
say %operations<square>.name;       # square
say %operations<square>(8);         # 64
```

### state 声明符

### augment 声明符

使用 `augment`, 你可以给已经存在的类或 grammars 增加属性和方法.

因为类通常使用 our 作用域, 因此是全局的, 这意味着修改全局状态, 这是强烈不鼓励的, 对于大部分情况, 有更好的方法.

```perl
# don't do this
use MONKEY-TYPING;
augment class Int {
    method is-answer { self == 42 }
}
say 42.is-answer;       # True
```

### supersede 声明符

### temp 前缀

像 my 一样, temp 在作用域的末尾恢复旧的变量值. 然而, temp 不创建新的变量.

```perl
my $cookies = 5;

sub buy-cookie { $cookies++ }

{
    my $cookies = 42;
    buy-cookie;   # Increments the outer $cookies variable
    say $cookies; # 42
                  # the outer $cookies variable is 6 now
}

{
    temp $cookies = 42;
    # Still the same $cookies, but a new value:
    buy-cookie;
    say $cookies; # -> 43
}

# Old value is restored
say $cookies; # -> 6
```

### let 前缀

跟 temp 类似, 但是只在 block 退出成功时才恢复变量值.

## 类型约束和初始化

变量可以有类型约束, 约束在声明符和变量名之间:

```perl
my Int $x = 42;
$x = 'a string'; # throws an X::TypeCheck::Assignment error
```

如果一个标量有类型约束但是没有初始值, 它会使用类型约束的类型对象来初始化.

```perl
my Int $x;
say $x.^name;    # Int
say $x.defined;  # False
```

没有显式类型约束的标量的类型为 Mu, 但是默认会是 Any 类型的对象.

带有 @ 符号的变量会被初始化为空的数组; 带有 % 符号的变量会被初始化为空的散列.

变量的默认值可以使用 `is default` 特性设置, 通过把 Nil 赋值给变量来重新应用默认值:

```perl
my Real $product is default(1);
say $product;                       # 1
$produce *= 5;
say $product;                       # 5
$product = Nil;
say $product;                       # 1
```

## 特殊变量

经常使用的变量

每个代码块中都有3个特别的变量:

```perl
变量	意义
$_	  特殊变量
$/	  正则匹配
$!	  异常
```

### $_

`$_` 是特殊变量，在没有显式标识的代码块中，它是默认参数。所以诸如 `for @array { ... }` 和 `given $var { ... }` 之类的结构会将变量绑定给 `$_`.

```perl
for <a b c> { say $_ }  # sets $_ to 'a', 'b' and 'c' in turn
say $_ for <a b c>;     # same, even though it's not a block
given 'a'   { say $_ }  # sets $_ to 'a'
say $_ given 'a';       # same, 尽管这不是一个块
```

CATCH 块将 `$_` 设置为捕获到的异常。 `~~` 智能匹配操作符。
对 `$_` 调用一个方法可以省略特殊变量 `$_` 的名字，从而写的更短：

```perl
.say;                   # 与 $_.say 相同
```

`m/regex/` 和 `/regex/` 正则匹配 和 `s/regex/subst/` 替换是作用于 `$_` 上的.

```perl
say "Looking for strings with non-alphabetic characters...";
for <ab:c d$e fgh ij*> {
    .say if m/<!alpha>/;
}
```

输出:

```perl
Looking for strings with non-alphabetic characters...
ab:c
d$e
ij*
```

### $/

`$/` 是匹配变量。它存储着最近一次正则匹配的结果，通常包含 `Match` 类型的对象。

```perl
'abc 12' ~~ /\w+/;  # 设置 $/ 为一个Match 对象
say $/;             # abc
```

Grammar的 parse 方法会把调用者的 `$/` 设置为 `Match object` 的结果。

```perl
use XML;
XML.parse(slurp "filename.xml");
say $/;
```

其他匹配变量是 `$/` 元素的别名：

```perl
$0          # same as $/[0]
$1          # same as $/[1]
$<named>    # same as $/<named>
```

### 位置属性

如果正则中有捕获分组, `$/` 中会有位置属性. 它们由圆括号组成.

```perl
'abbbbbcdddddeffg' ~~ / a (b+) c (d+ef+) g /;
say $/[0]; # ｢bbbbb｣
say $/[1]; # ｢dddddeff｣
```
这些捕获分组也能使用 `$0`,`$1`,`$2` 等便捷形式取得:

```perl
say $0; # ｢bbbbb｣
say $1; # ｢dddddeff｣
```

要获取所有的位置属性, 使用 `$/.list`, `@$/`,`@( )` 中的任意一个都可以:

```perl
say @().join; # bbbbbdddddeff
```

### 命名属性

如果正则中有命名捕获分组, `$/` 可以有命名属性, 或者正则调用了另一个正则:

```perl
'I.... see?' ~~ / \w+ $<punctuation>=[ <-[\w\s]>+ ] \s* $<final-word> = [ \w+ . ] /;
say $/<punctuation>; # ｢....｣
say $/<final-word>;  # ｢see?｣
```

这些命名捕获分组也能使用便捷形式获取:

```perl
say $<punctuation>; # ｢....｣
say $<final-word>;  # ｢see?｣
```

要获取所有的命名属性, 使用 `$/.hash`,  `%$/`, `%()`中的任何一个:

```perl
say %().join;  # "punctuation     ....final-word  see?"
```

### $!

`$!` 是错误变量.

## 编译时 "常量"

```perl
$?FILE      所在文件
$?LINE      所在行
&?ROUTINE   所在子例程
&?BLOCK     所在块
%?LANG      What is the current set of interwoven languages?
```

其它编译时常量：

```perl
$?KERNEL    Which kernel am I compiled for?
$?DISTRO    Which OS distribution am I compiling under
$?VM        Which virtual machine am I compiling under
$?XVM       Which virtual machine am I cross-compiling for
$?PERL      Which Perl am I compiled for?
$?SCOPE     Which lexical scope am I in?
$?PACKAGE   Which package am I in?
$?MODULE    Which module am I in?
$?CLASS     Which class am I in? (as variable)
$?ROLE      Which role am I in? (as variable)
$?GRAMMAR   Which grammar am I in?
$?TABSTOP   How many spaces is a tab in a heredoc or virtual margin?
$?USAGE     The usage message generated from the signatures of MAIN subs.
$?ENC       Default encoding of Str.encode/Buf.decode/various IO methods.
```

## 动态变量

```perl
$*ARGFILES  神奇的命令行输入句柄
@*ARGS      来自命令行的参数
$*IN        标准输入文件句柄
$*OUT       标准输出文件句柄
$*ERR       标准错误文件句柄
$*TZ        系统的本地时区
$*CWD       当前工作目录
```

其他变量

```perl
$*PROGRAM_NAME     Path to the current executable as it was typed in on the
                   command line, or C<-e> if perl was invoked with the -e flag.
$*PID              当前进程的进程ID
$*OS               在哪种操作系统下被编译(e.g. Linux).
$*OSVER            当前操作系统的版本.
$*EXECUTABLE_NAME  当前运行的可执行perl 的名字
```
