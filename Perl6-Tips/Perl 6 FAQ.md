

源文件可以在 [github](https://github.com/perl6/faq)上找到.



## General

### Rakudo 和 Perl 6 的区别是什么？

Rakudo 是 Perl 6 的一个实现。目前它是完成度最好的但是过去也有其它的实现, 将来也可能会有其它实现。Perl 6 是语言的定义。很多场合

这两个名字可以宽松地使用并互相替换。

### 作为一个 Perl 6 初学者我应该安装什么？

如果你是一个 Linux 或 Mac 用户, 你可能需要下载 [Rakudo Star](http://rakudo.org/downloads/star/) 并通过编译 MoarVM 版本安装（一个简单的处理）

如果你是一个 Windows 32 或 64 位用户, 那么 Rakudo Star 二进制版本在 rakudo 网站也能获得。你需要 Windows Git 来使用 panda。

Linux 和 Mac 二进制版本稍后也可能从供应商和第三方那儿获取到。尽管供应商版本可能过时了。

### 作为一个中高级用户我想跟进 Rakudo 开发

安装类似于 Perl 5 的 perlbrew -- rakudobrew , 和 同等的 Python 还有 Ruby工具。

### 从哪里能找到关于 Perl 6 的好文档？

最令人信赖的信息能在 perl6.org 或那儿的直接链接。

http://www.perl6.org/documentation/ 和 http://doc.perl6.org/

### 什么是 Perl 6 spec？

"spec" 指的是 Perl 6的官方测试套件。它被称作 roast 并被托管在 [github](https://github.com/perl6/roast) 上.

它被用来测量一个 Perl 6 的实现有多彻底。

### 有没有 Perl 6 的术语相关的项目？

查看 [S99](http://design.perl6.org/S99.html)

### 我是一个 Perl 5程序员. Perl 5 和 Perl 6 的区别在哪儿？

查看 http://doc.perl6.org/language.html

## 模块

### Perl 6 有 CPAN 吗? 或者 Perl 6 会使用 Perl 5 的 CPAN 吗?

Perl 6 还没有像 CPAN 那样成熟的模块仓库. 但是 [modules.perl6.org](http://modules.perl6.org/) 有很多已知的 Perl 6 模块, [panda](https://github.com/tadzik/panda/) 能在 Rakudo 上安装这些模块.

### 我能在 Perl 6 中使用 Perl 5的模块吗？

使用 Inline::Perl5 能很好地运行 Perl 5的 Catalyst 和 DBI。

### 我能在 Perl 6 中使用 C 和 C++ 吗？

[Nativecall](http://docs.perl6.org/language/nativecall) 让这个特别容易。

### Nativecall 找不到 libfoo.so 并且我只有 libfoo.so.1.2!

这在 Debian 那样的系统中很常见。 你需要安装 "libfoo-dev" 来为丢失的文件设置符号链接。

### 所有的传统 Unix 库函数去哪儿了？

使用 Nativecall 访问它们很容易。

### Rakudo 有核心标准库吗?

Rakudo 是一个包含最小电量的编译器发布（Test 和 Nativecall等等），像 linux 内核一样。

Rakudo Star 是一个带有一些有用模块的 rakudo, 并且更多的模块可以从生态系统里安装。

## 语言特性

### 我怎么 dump Perl 6的数据结构(就像 Perl 5 的 Data::Dumper 和类似的)？

examples:

``` perl6

my $foo="bar"
dd $foo        # Str $foo = "bar"
say :$foo.perl # :foo("bar")
say :$foo.gist # foo => bar

```

生态系统中还有模块来做这个事情, 例如 [Data::Dump](https://github.com/tony-o/perl6-data-dump/) 使用颜色来 Dump。

### 我怎么在 Perl 6提示符（REPL）中找到历史命令行？

从生态系统中安装 [Linenoise](https://github.com/hoelzro/p6-linenoise/).

作为一种选择, 在 UNIX 那样的系统中可以安装 rlwrap。这在类 Debian 系统中可以通过`apt-get install rlwrap` 安装。

### 为什么 Rakudo 编译器有时候报错更友好？
如果 `SORRY!` 出现在输出中, 则错误是编译时错误, 否则是运行时错误。
Examples:

```perl6

say 1/0     # Attempt to divide 1 by zero using div

sub foo ( Int $a, Int $b ) {...}
foo(1)      # ===SORRY!=== Error while compiling ...

```

### 什么是 (Any)?
[Any](http://doc.perl6.org/routine/type%2FAny) 是一个用于新类的默认超类(superclass)的顶层类。
它经常在这样的上下文出现：变量被定义但没有被赋值， 这里它类似于其它语言中的 undef 或 null 值。
examples:

```perl6
my $foo;
say $foo;       # (Any) 注意圆括号表明的类型对象
say $foo.^name  # Any

```
(Any) 不应该被用于检查definedness。 在 Perl 6中, definedness 可能是一个对象。 通常实例是被定义的, 而类型对象是未定义的。

```perl6

say 1.defined       # True
say (Any).defined   # False

```

### so 是什么?

`so` 是一个松散优先级的操作符, 它强制上下文为 `Bool`.  `not` 的

`so` 拥有和 `?`前缀操作符同样的语义, 就像 `and` 是 `&&` 的低优先级版本一样.

用法示例:

``` perl6

say so 1|2 == 2;    # Bool::True

```

在这个例子中, 比较的结果(结果是 Junction)在打印之前被转换为 Bool 值了.

### 签名中的那些 :D 和 :U 是什么东东？
在 Perl 6 中, 类和其它类型是对象, 并且传递自身类型的类型检测。
例如如果你声明一个变量

```perl6

my Int $x = 42;

```

那么, 你不仅可以给它赋值整数（即， Int 类的实例）, 还能给它赋值 Int 类型对象自身：

```perl6

$x = Int

```

如果你想排除类型对象, 你可以追加一个 :D 类型微笑符, 它代表"定义"（definite）:

```perl6

my Int:D $x = 42;
$x = Int;  # dies with:
           # Type check failed in assignment to $x;
           # expected Int:D but got Int

```

 同样地, `:U` 约束为未定义的值, 即类型对象。
 要显式地允许类型对象或实例, 你可以使用 `:_`。

### 签名中的 --> 是什么东东？

`-->` 是一个返回值约束, 在编译时被检查。
Example:

```perl6

sub foo ( Int $a, Int $b --> Int ) {
        return $a + $b;
}

foo(2,3.1)
# ===SORRY!===  ... Calling foo(Int, Rat) will never work
#    with declared signature (Int $a, Int $b --> Int)

```

### Any 和 Mu 的区别是什么?



`Mu` 是所派生出的所有其它类型的基类型. `Any` 是从  `Mu`派生来的, 代表着任何类型的 Perl 6 值. 主要区别是, `Any` 不包含 `Junction`.

子例程参数的默认类型是 `Any`, 以至于当你声明 `sub foo ($a)` 时, 你真正表达的是 `sub foo (Any $a)` . 类似地, 类的声明被假定继承自 `Any`, 除非使用了像 `is Mu` 这样的 trait 特征.



### 怎么从 Junction 中提取值?



如果你想从 junction 中提取值(特征态), 那你可能正误入歧途.  Junctions 作为匹配器, 而不是使用它们做代数.

如果你还是想那样做, 你可以滥用自动穿引(autothreading):

``` perl6

sub eigenstates(Mu $j) {
    my @states;
    -> Any $s { @states.push: $s }.($j);
    @states;
}

say eigenstates(1|2|3).join(', ');
# prints 1, 2, 3 or a permutation thereof

```



### 如果 Str 是不可变的, 那么 `s///` 是怎么工作的? 如果 Int 是不可变的, `$i++` 是怎么工作的?



在 Perl 6 中, 很多基本类型是不可变的, 但是保存它们的变量不是. `s///` 作用于变量上, 在这个变量中放入一个新创建的字符串对象. 同样地, `$i++` 作用于 `$i` 变量上, 而不是作用在它里面的值身上.

请查看:  [documention on containers](http://doc.perl6.org/language/containers)



### 什么是数组引用和自动解引用? 我仍然需要 @ 符号吗?



在 Perl 6 中, 几乎所有的东西都是引用. 所以谈论 taking references 没有多大意义. 不像 Perl 5 那样, Perl 6 的标量标量也能直接包含数组:

``` perl6

my @a = 1, 2, 3;
say @a;                 # "1 2 3\n"
say @a.WHAT;            # (Array)

my $scalar = @a;
say $scalar;            # "1 2 3\n"
say $scalar.WHAT;       # (Array)

```

最大的区别是, 标量变量中的数组在列表上下文中不会被展平(flattern):

``` perl6

my @a = 1, 2, 3;
my $s = @a;

for @a { ... }          # loop body executed 3 times
for $s { ... }          # loop body executed only once

my @flat = @a, @a;
say @flat.elems;        # 6

my @nested = $s, $s;
say @nested.elems;      # 2

```

你可以使用 `@( ... )` 或通过在表达式身上调用 `.list` 方法来强制展平, 使用 `$( ... )` 或通过在表达式身上调用 `.item` 方法强制为 item  上下文(不展平).

`[...]` 数组字面值不会被展平到列表中.

更多查看: [the documentation on containers and flattening](http://doc.perl6.org/language/containers)



### 为什么还要符号? 你不能失去它们吗?



有几个原因:



- 它们使插值变量到字符串中变得更容易
- 它们为不同的变量组成微型命名空间, 因此避免了名字冲突.
- 它们允许简单的 单数/复数 区别



### Perl 6 有协程吗? 什么是 yield ?



​    Perl 6 没有 Python 那样的 `yield` 语句, 但是它通过惰性列表却能提供类似的功能. 有两种很潮的方式来写出能返回惰性列表的子例程:

``` perl6

# first method, gather/take
my @values := gather while have_data() {
    # do some computations
    take some_data();
    # do more computations
}

# second method, use .map or similar method
# on a lazy list
my @squares := (1..*).map(-> $x { $x * $x });

```



### 为什么我需要反斜线(unspace)在多行上分割方法调用?

(请在这儿添加答案)



### 为什么我不能从 new 方法初始化私有属性, 我怎么修复它?



这样的代码:

``` perl6

class A {
    has $!x;
    method show-x {
        say $!x;
    }
}
A.new(x => 5).show-x;

```

不会打印出 5. Private 属性是私有的, 这意味着私有属性在外面是不可见的. 如果默认的构造器能够初始化私有属性, 那么这些私有属性就会泄露到公共 API 中.

如果你仍旧想让它工作, 你可以添加一个 `submethod BUILD` 来初始化它们:

``` perl6
class B {
    has $!x;
    submethod BUILD(:$!x) { }
    method show-x {
        say $!x;
    }
}
A.new(x => 5).show-x;

```

`BUILD` 由默认的构造器使用用户传递给构造器的所有具名参数调用(直接地, 查看更多细节[object-construction-and-initilization](http://perlgeek.de/blog-en/perl-6/object-construction-and-initialization.html)). `:$!x` 是名为 `x` 的具名参数, 当使用名为 `x` 的具名参数来调用时, 它的值被绑定到属性 `$!x` 上.

但是如果你允许从外面设置私有属性, 相反它们应该被设置为公共属性.

### say 和 print 怎么不同, 为什么不同?



最明显的区别是, `say` 在输出后面添加了一个换行符, 而 `print` 没有.

但是还有另外一个区别: `print` 通过对每一个传递来的 item 调用 `Str` 方法来把它的参数转换为字符串, 相反,  `say` 使用  `gist` 方法. 前者是为计算机设计的, 后者是为人类.

或者它俩被解析的方式不同, `$obj.Str` 给出一个字符串表示, `$obj.gist` 是对象的一个简短总结, 适合编程人员的快速识别, `$obj.perl` 打印一个 Perlish 的表示.

例如, 类型对象, 也是熟知的 “未定义值”, 字符串化为一个空的字符串和警告, 而 `gist` 方法返回由一对圆括号包裹的类型的名字.(用于表明除了类型之外什么也没有).

``` perl6

my Date $x;     # $x now contains the Date type object
print $x;       # empty string plus warning
say $x;         # (Date)\n

```

所以, `say` 优化的用于调试和向人们展示, `print` 更适合于产生用于其它程序的输出.

### token 和 rule 之间的区别是什么?



`regex` , `token` 和 `rule` 这三个都引入了正则表达式, 但是语义略微有一点不同.

`token` 隐含了 `:ratchet` 或 `:r` 修饰符, 这阻止了规则的回溯.

`rule` 隐含了 `:ratchet` 和  `:sigspace` (缩写为 `:s`)修饰符, 这因为着规则不会回溯, 并且它把 regex中的文本中空白当作 `<.ws>` 调用(例如匹配空白, 除了在两个单词字符之间之外, 它是可选的).  regex 开头的空白和备选分支中每个分支开头的空白会被忽略.

`regex` 声明不带任何隐含修饰符的普通 regex.



### die 和 fail 之间的区别是什么?



`die` 抛出一个异常.

如果 `use fatal;` (它是动态作用域的)在作用域中, `fail` 也会抛出一个异常. 否则它从调用它的子例程中返回一个 `Failure`.

`Failure` 是一个 “未抛出的” 或 “软的” 异常.它是一个含有异常的对象, 当这个 Failure 被用作普通的对象时会抛出一个异常.

Failure 从 `defined` 检查中返回 False, 并且你可以使用 `exception` 方法提取出异常.



### 为什么 wantarray 或 want 不见了? 我能在不同的上下文中返回不同的东西吗?



Perl 拥有 `wantarray` 函数来告诉你这是在空上下文, 标量上下文,还是在列表上下文中调用的. Perl 6 没有与之等价的结构, 因为上下文不是向内流动的,  例如, 子例程不知道调用所在的上下文.

一个愿意是因为 Perl 6 有多重分派, 在这样一个例子中:

``` perl6

multi w(Int $x) { say 'Int' }
multi w(Str $x) { say 'Str' }
w(f());

```

没办法决定子例程 `f` 的调用者想要一个字符串还是想要一个整数, 因为它还不知道调用者是什么. 通常这要求解决 halting 问题, 在这个问题上, 即使写 Perl 6编译器的人也会遇到麻烦.

在 Perl 6 中达到上下文敏感的方式是返回一个知道怎样响应方法调用的对象.

例如, regex 匹配返回 Match [对象](http://doc.perl6.org/type/Match), 该对象知道怎样响应列表索引, 散列索引, 并能变成匹配的字符串.



### 为什么我不能把所有的数值都赋值给 Num 类型的变量?



``` perl6

my Num $x = 42;
# dies with
# Type check failed in assignment to '$x'; expected 'Num' but got 'Int'

```

[Num](http://doc.perl6.org/type/Num) 是浮点类型, 与 [ integers](http://doc.perl6.org/type/Int) 不兼容. 如果你想要一个允许任何数字值的类型约束, 使用 [Numeric](http://doc.perl6.org/type/Numeric) (它也允许[复数](http://doc.perl6.org/type/Complex)), 或 [Real](http://doc.perl6.org/type/Real)如果你想排除复数.



## Meta Questions and Advocacy



### Perl 6 什么时间会准备好? 就是现在吗?



编程语言和它们的编译器的准备就绪不是一个二元决策. 因为它们(语言和实现)能进化, 它们平稳地发展变得更可用. 根据你对编程语言的要求, 它可能适合也可能不适合你.

请查看 [功能对比矩阵](http://perl6.org/compilers/features) 了解更详尽的实现了的功能.

请注意, Larry Wall 已经在 FOSDEM 2015 会议上宣布, 一个产品级的 Rakudo Perl 6 将会在 2015 圣诞节发布.



### 为什么我要学习 Perl 6? 它有什么了不起的吗?

Perl 6 统一了很多其它编程语言中不经常有的伟大想法. 虽然其中的几种语言提供了其中的某些功能, 但是没有提供全部.

不像大部分语言那样, 它提供了：



- 足够清晰的正则表达式
- 像 PEG 那样用于解析的 grammars
- 惰性列表
- 强大的元对象系统
- 值的 junction
- 像偏函数和柯里化那样的高阶函数功能更易获取
- 对于子类型(继承)和代码复用(role 应用)的单独机制
- 可选的类型标注(渐进类型)
- 对于子例程和方法, 基于数量, 类型和其它代码约束的强大的运行时多重分派
- 词法导入



它还提供了：



- 闭包
- 匿名类型
- roles 和 traits
- 具名参数
- 嵌套签名
- 签名中对象的解包
- 惊艳,优雅的语法(不像 Lisp)
- 更易懂, 显式的作用域规则(不像 Python)
- 不依赖 eval 的强健的元对象系统(不像 Ruby)
- 富有表现力的子例程签名(不像Perl 5)
- 状态变量
- 不像很多动态语言那样, 调用一个缺失的子例程会在编译时被捕捉到, 并且在某些情况下, 不匹配的签名也能在编译时被捕捉到.



请查看 [功能比较矩阵](http://perl6.org/compilers/features) 获取更多信息.





### 为什么不把它叫做除了 Perl 以外的其它东西?

很多人建议, Perl 6 跟之前的 Perl 版本的区别太大了, 我们应该考虑给它改名, 或者考虑到 Perl 6 伤害了 Perl 5, 仅仅拥有同样的名字却有更高的版本号.

Perl 6 仍然叫做 “Perl" 的主要原因是:



- Perl 6 仍然是一个 perlish 风格的语言, 和之前的版本遵守相同的底层思想(用于微型命名空间的符号, 条条大路通罗马, 吸收了很多自然语言的思想..)
- Perl 6 的代码很 perlish.
- Perl 仍然是一个强健的品牌名, 我们不想马上抛弃它
- 找到一个替代的名字很困难. 而且, “camelia” 和 “rakudo" 不是合适的编程语言名
- 即使 Perl 6 更改了它的名字, Perl 5 也不大可能增加它的版本号为 6.因为 Perl 6 已经根植于人们的头脑中了

### Perl 6 对我来说足够快了吗?
那取决于你正在做什么。Perl 6 一直奉行“做对的事情然后做的更快”的哲学进行开发。对于某些东西来说它够快了, 但是需要做的更多。
Perl 6 大部分是由志愿者开发的, 但是 Perl 6 的性能在不久的将来有待提高, 因为 MoarVM 后端包含一个现代的即时（JIT）编译器。
Perl 5 程序员应该意识到 Perl 6 在面向对象方面有很多内建函数并且还有更多其它的。
简单的基准测试会误导除非你在你的 Perl 5脚本中包含了诸如 Moose, 类型检测模块等。

下面这个粗超的基准测试, 使用了所有诸如此类的一般说明, 能展示 Perl 6 在某些类似任务上能和 Perl 5的速度接近。
在你的系统上尝试下, 你可能会感到很惊讶!

```perl6

# perl 6 version
use v6;

class Foo { has $.i is rw};

for (1..1_000_000) -> $i {
    my $obj = Foo.new;
    $obj.i = $i;
    say $obj.i;
}

# perl 5 version
package Foo;
use 5.10.0;
use Moose;

has i => ( is=> 'rw');

for my $i (1..1_000_000) {
    my $obj = Foo->new;
    $obj->i($i);
    say $obj->i;
}

__PACKAGE__->meta->make_immutable;

1;

```

### 更多问题

(目前还没有)
