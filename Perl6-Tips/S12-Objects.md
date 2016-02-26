title:  S12-Objects

date: 2016-01-07

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>她是真的很好. -- 胡歌</blockquote>

## 标题

大纲 12： 对象(Objects)

## 版本

创建于： 2004-08-27

上次修改时间： 2014-8-26

版本：134

## 概述

这个大纲总结了第12个启示录, 它探讨关于面向对象的编程。

## 类 (Classes)

[S12-class/lexical.t lines 12–61](https://github.com/perl6/roast/blob/master/S12-class/lexical.t#L12-L61)

[S12-class/basic.t lines 13–50](https://github.com/perl6/roast/blob/master/S12-class/basic.t#L13-L50)

[S14-roles/lexical.t lines 12–47](https://github.com/perl6/roast/blob/master/S14-roles/lexical.t#L12-L47)

类是使用关键字 `class` 声明的模块。 至于模块, 即公共存储, 接口, 并且类的名字通过包和它的名字来表示, 这总是(但不必须)一个全局的名字。 类是一个模块, 因此能导出东西, 但是类添加了更多的行为来支持 Perl 6 的标准的基于类的 OO。

作为类型对象(type object), 类名代表了它的类型的所有可能值, 因此在计算那种类型的普通对象能做什么时, 类型对象能用作任何属于该类型的"真实"对象的代理。 类对象是一个对象, 但是它不是一个类(`Class`), 因为 Perl 6 中没有强制性的 `Class` 类, 还因为在Perl 6 中类型对象被认为是未定义的。 我们想基于类的和基于原型的 OO 编程这两个都支持。所以, 所有的元编程是通过当前对象的 `HOW` 对象来完成的, 这可以把元编程代理给任何它喜欢的元模型上。 然而, 默认地, 从 `Mu` 派生的对象支持相当标准的基于类的模型。

有两种基本的类声明语法:

``` perl
    unit class Foo; # 文件的剩余部分是类的定义
    has $.foo

    class Bar { has $.bar } # block 是类的定义
```

第一种形式只有当第一种声明是在一个编译单元(即文件或 EVAL 字符串)中时被允许。

如果类的主体以一个主操作符为单个`prefix:<...>`（yada）listop 开始的语句, 那么只引入类名而不定义, 并且在同一个作用域中第二次声明那个类不会抱怨重新定义。（语句修饰符允许在这样的 `...` 操作符上。）因此你可以向前声明你的类:

``` perl
calss A { ... } # 引入 A 作为类名而不定义
class B { ... } # 引入 B 作为类名而不定义

my A $root .= new(:a(B));

class A {
    has B $.a;
}

class B {
    has A $.b;
}
```

就像这个例子展示的那样, 这允许互相递归类的定义(但是它不允许递归继承)。

通过 `augment` 声明符来扩展类也是可以的, 但是那被认为有点不符合常规并且不应用于向前声明。

一个具名的类声明能作为表达式的一部分出现, 就像具名子例程声明那样。

类主要用于实例管理, 而非代码复用。 当你只是想提取共有的代码时考虑使用 roles。

Perl 6 支持多重继承, 匿名类和自动装箱。

[S12-class/anonymous.t lines 5–81](https://github.com/perl6/roast/blob/master/S12-class/anonymous.t#L5-L81)

所有的 public 方法调用在 C++ 里就是虚的。

你可能派生自任何内置类型, 但是像`Int`这样的低级别派生可能只增加行为, 而不改变表示。使用构成 and/or 代理来改变表示。

因为 Perl 6 中没有裸字, 裸的类名必须被预先声明好。你可以预先声明一个 stub 类并在之后填充它就像你在子例程中的那样。

[S12-class/declaration-order.t lines 14–21](https://github.com/perl6/roast/blob/master/S12-class/declaration-order.t#L14-L21)

[S12-class/stubs.t lines 4–40](https://github.com/perl6/roast/blob/master/S12-class/stubs.t#L4-L40)

你可以使用 `::` 前缀来强制一个名字解释为类名或类型名。 在左值上下文中, `::` 前缀是一个 no-op, 但是在声明式的上下文中, 它在声明的作用域中绑定了一个新的类型名, 伴随着任何其它通过声明声明的东西。

[S12-class/literal.t lines 7–25](https://github.com/perl6/roast/blob/master/S12-class/literal.t#L7-L25)

如果没有 `my` 或其它作用域声明符, 那么一个裸的 `class` 声明符声明了一个 `our`声明符, 即一个在当前包中的名字。 因为类文件开始解析于 `GLOBAL` 包中, 文件中第一个声明的类把它自己安装为一个全局的名字, 之后的声明随后把它们自己安装在当前类中而不是全局的包中。

因此, 要在当前的包(或模块, 或类)中声明一个内部的类, 那使用 `our class` 或仅仅 `class`。  要声明一个本地作用域的类, 使用 `my class`。 类的名字总是从最内的作用域开始搜索, 直到最外层的作用域。 至于起始的 `::`, 类名中出现的 `::` 不是暗示全局性(不像 Perl 5)。 所以外层的搜索能查看搜索过的名字空间的孩子。

内部的 class 或 role 在一般的上下文中必须被本地作用域化, 如果它依赖于任何一般的参数或类型的话; 并且这样的内部类或 role 也叫做泛型。

### 类的特性(Class traits)

类的特性使用 `is` 来设置:

``` perl
    class MyStruct is rw { ... }
```

#### 单继承

`isa` 也仅仅是一个特性, 碰巧是另一个类:

``` perl
    class Dog is Mammal { ... }
```

#### 多重继承

多重继承使用多个 	`is` 来指定：

``` perl
class Dog is Mammal is Pet { ... }
​```	
#### 合成
Roles 使用 `does` 代替 `is`:
​```perl
class Dog is Mammal does Pet { ... }
```

#### also 声明符

你也可以使用 `also` 声明符把这些都放在里面:

``` perl
class Dog {
    also is Mammal;
    also does Pet;
}
```

（然而, also 声明符主要用在 roles 中）

### 元类(Metaclasses)

每个对象（包括任何基于类的对象）代理给它的元类的一个实例上。你能通过 `HOW` 方法来获取元类的任何对象, HOW 方法返回那个元类的实例。 在 Perl 6 中, 一个"类"对象仅仅被认为是一个"空的"实例, 更合适的叫法是 "原型" 或 "泛型" 对象, 或仅仅叫 "类型对象"。 Perl 6 真的没有任何名为 `Class` 的类。 各种各样的类型是通过这些未定义的类型对象来命名的, 这被认为是和他们自己的实例化版本拥有相同的类型。但是这样的类型对象是惰性的, 并且不能管理类实例的状态。

管理实例的实际对象是通过 HOW 语法所指向的元类对象。 所以当你说 "Dog"的时候, 你指的即是一个包又是一个类型对象, 后者指的是通过 HOW 来表示类的对象。 类型对象区别实例对象不是通过拥有不同的类型, 而是就谁被定义而言的。有些对象可能告诉你它们被定义了, 而其它对象可能告诉你它们没有被定义。 那归结于对象, 并取决于元对象如何选择去分发 `.defined` 方法。

### 闭合类(Closed classes)

类默认是开放和非最终(non-final) 的, 但是它们能很容易地被整个程序闭合或定型, 而非被它们自己。 然而使用动态加载或子程序的平台可能不想批量闭合或定型类。(这特么都是什么?)

### 私有类

私有类能使用 `my` 来声明; 在 Perl 6 中, 大部分隐私问题是使用词法作用域(my)来处理的。词法默认很重要的事实也意味着类导入的任何名字默认也是私有的。



在 grammars 中, 不能使用 grammars 属性, 所以你能从一个不相关的 grammar 中调用一个 grammar。这能通过在闭包中创建一个本地作用域的 grammars 来模仿那种行为。闭包捕获的词法变量就能用在像 grammars 属性那样的地方了。



### 类的成分

`class`声明(特别地, role 合成)是严格的编译时语句。特别地, 如果类声明出现在嵌套作用域里面, 那么类声明被约束为, 构成和任何可能的实现一样。所有的 roles 和 超类必须被限制为非重新装订的只读值; 任何 traits 的参数会只在非拷贝上下文中被求值。类声明限定的名字是非重新装订的并且是只读的, 所以它们能被用作超类。

### 匿名的类声明

在匿名的类声明中, 如果需要 `::` 本身就代表了匿名类的名字:

``` perl
class { ... }                    # ok
class is Mammal { ... }          # 错误
class :: is Mammal { ... }       # ok
class { also is Mammal; ... }    # also ok
```

### 方法

方法是类中使用 `method` 关键字声明的子例程:

``` perl
method doit ($a, $b, $c) { ... }
meyhod doit ($self: $a, $b, $c) { ... }
method doit (MyName $self: $a, $b, $c) { ... }
method doit (::?CLASS $self: $a, $b, $c) { ... }
```

### 调用者

调用者的声明是可选的。你总是使用关键字 `self`来访问当前调用者。你不需要声明调用者的类型, 因为调用者的词法类是被任何事件知晓的, 因为方法必须声明在调用者的类中, 尽管真实的(虚拟的)类型可能是词法类型派生出来的类型。你可以声明一个限制性更强的类类型, 但是那对于多态可能是坏事儿。你可以显式地使用词法类型来type 调用者, 但是任何为此做的检查会被优化掉，(当前的词法导向的类总是可以命名为 `::?CLASS` 即使在匿名类中或 roles 中)

[S12-attributes/recursive.t lines 46–97](https://github.com/perl6/roast/blob/master/S12-attributes/recursive.t#L46-L97)

要标记一个显式的调用者, 在它后面放上一个冒号就好了:

``` perl
method doit ($x: $a, $b, $c) { ... }
```

如果你使用数组变量为 Array 类型声明一个显式的调用者, 你可以在列表上下文中直接使用它来生成它的元素

``` perl
method push3 (@x: $a, $b, $c) { ... any(@x) ... }
```

注意 `self`项直接指向了方法所调用的对象上, 因此:

``` perl
class A is Array {
    method m() { .say for self }
}
A.new(1, 2, 3).m; # 1\n2\n\3
```

会打印3行输出。

### 私有方法

私有方法是使用 `!` 声明的:

[[S12-methods/private.t lines 6–44](https://github.com/perl6/roast/blob/master/S12-methods/private.t#L6-L44)]

``` perl
method !think (Brain $self: $thought)
```

(这样的方法对普通方法调用是完全不可见的, 实际上是使用不同的语法, 即使用 `!` 代替 `.` 字符。 看下面。)

### 方法作用域

不像大部分的其它声明符, `method`声明符不是默认为 `our`语义, 或者甚至 `my` 语义, 而是 `has`语义。所以, 不是安装一个符号到词法的或包的符号表中, 它们只是在当前类或 role 中通过调用它的元对象来安装一个公共的或私有的方法。（同样适用于 `submethod` 声明符 — 查看下面的 "Submethod"）.



使用一个显式的 `has`声明符对声明没有影响。你可以在本地作用域中使用`my`或在当前包中使用 `our`来给方法安装额外的别名。这些别名使用 `&foo`别名来命名, 并返回一个能叫做子例程的 `Routine`对象, 这时你必须提供期望的调用者作为第一个参数。



### 方法调用

要使用普通的方法分发语义来调用普通的方法, 使用点语法记法或间接对象记法:

[S12-methods/instance.t lines 13–243](https://github.com/perl6/roast/blob/master/S12-methods/instance.t#L13-L243)

``` perl
$obj.doit(1,2,3)
doit $obj: 1, 2, 3
```

间接对象记法现在要求调用者后面要有一个冒号, 即使冒号后面没有参数:

[S12-methods/indirect_notation.t lines 5–57](https://github.com/perl6/roast/blob/master/S12-methods/indirect_notation.t#L5-L57)

``` perl
$handle.close;
close $handle:;
```

要拒绝方法调用并且只考虑 subs, 仅仅从调用行那儿省略冒号即可：

``` perl
close($handle);
close $handle;
```

然而, 这儿内置`IO`类定义的方法 `close （）`是导出的, 它默认把 `multi sub close (IO)` 放在作用域中。因此, 如果 `$handle`对象是一个 IO 对象的话, 那么上面的两个子例程调用仍旧被转换成方法调用。



点调用记法可以省略调用者, 如果调用者是 `$_`:

``` perl
.doit(1,2,3)
```

方法调用使用的是 C3 方法解析顺序。

#### 花哨的方法调用

注意对于私有方法没有对应的记法。

``` perl
!doit(1,2,3)     # 错, 会被解析为 not(doit(1,2,3))
self!doit(1,2,3) # ok
```

对于方法名有几种间接的形式。你可以使用引起的字符串替换标识符, 它会被求值为引起, 引起的结果用作方法名。

[S12-methods/indirect_notation.t lines 58–76](https://github.com/perl6/roast/blob/master/S12-methods/indirect_notation.t#L58-L76)

``` perl
$obj."$methodname"(1,2,3) # 使用 $methodname 的内容作为方法名
$obj.'$methodname'(1,2,3) # 没有插值; 调用名字中带有 $ 符号的方法

$obj!"$methodname"() # 间接调用私有方法名
```

在插值中, 双引号形式不可以包含空白。这在双引号中以点结尾的字符串中达到用户期望的那样:

[S02-literals/misc-interpolation.t lines 96–120](https://github.com/perl6/roast/blob/master/S02-literals/misc-interpolation.t#L96-L120)

``` perl
say "Foo = $foo.";
```

如果你真的想调用带有空格的方法, 那你使用一个闭包插值来进行约束:

``` perl
say "Foo = {$foo."a method"()}"; # OK
```



















