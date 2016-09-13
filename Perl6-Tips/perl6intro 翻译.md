
## 函数式编程

在本章中，我们将看看一些有利于函数式编程的功能。

###   函数是一等公民

函数/子例程是一等公民:

- 它们能作为参数传递
- 它们能从另外一个函数中返回
- 它们能被赋值给变量

`map` 函数是用来说明这个概念的极好例子。`map` 是高阶函数, 它接收另外一个函数作为参数。

**脚本**

```perl
my @array = <1 2 3 4 5>;
sub squared($x) {
    $x ** 2
}
say map(&squared, @array);
```

**输出**

```
(1 4 9 16 25)
```

**解释**

我们定义了一个叫做 `squared` 的子例程, 它接收一个数字并返回该数字的二次幂。下一步, 我们使用 `map` 这个高阶函数并传递给它两个参数, 一个子例程和一个数组。结果是所有数组元素的平方组成的列表。

注意当传递子例程作为参数时, 我们需要在子例程的名字前添加一个 `&` 符号。

###  闭包

在 Perl 6 中所有的代码对象都是闭包, 这意味着它们能从外部作用域(outer scope)引用词法变量(lexical variables)。

###  匿名函数

**匿名函数**也叫做**拉姆达**(lambda)。

匿名函数没有绑定到标识符(匿名函数没有名字)。

让我们使用匿名函数重写 `map` 那个例子。

```perl
my @array = <1 2 3 4 5>;
say map(-> $x {$x ** 2}, @array);
```

我们没有声明子例程并把它作为参数传递给 `map`, 而是在里面直接定义了匿名函数。

匿名函数 `-> $x {$x ** 2}` 没有句柄并且不能被调用。

按照 Perl 6 的说法我们把这个标记叫做 **pointy block**。

pointy block 也能用于把函数赋值给变量:

```perl
my $squared = -> $x {
    $x ** 2
}
say $squared(9);
```

###  链式调用

在 Perl 6中, 方法可以链接起来, 你不再需要把一个方法的结果作为参数传递给另外一个方法了。

我们假设你有一个数组。你被要求返回该数组的唯一值, 并且按从大到小的顺序排序。

你可能会通过写出近似于这样的代码来解决那个问题:

```perl
my @array       = <7 8 9 0 1 2 4 3 5 6 7 8 9 >;
my @final-array = reverse(sort(unique(@array)));
say @final-array;
```

首先我们在 `@array` 身上调用 `unique` 函数, 然后我们把它的结果作为参数传递给 `sort` 函数, 再然后我们把结果传递给 `reverse` 函数。

和上面的例子相比, Perl  6 允许链式方法。

上面的例子可以像下面这样写, 利用**方法链**的优点:

```perl
my @array       = <7 8 9 0 1 2 4 3 5 6 7 8 9 >;
my @final-array = @array.unique.sort.reverse;
say @final-array;
```

你已经看到链式方法看起来有多清爽啦。

###  Feed 操作符

**feed 操作符**, 在有些函数式编程语言中也叫**管道**, 然而它是链式方法的一个更好的可视化产出。

**向前流**

```perl
my @array = <7 8 9 0 1 2 4 3 5 6>;
@array ==> unique()
       ==> sort()
       ==> reverse()
       ==> my @final-array;
say @final-array;
```

**解释**

```
从 `@array` 开始 然后 返回一个唯一元素的列表
                 然后 排序它
                 然后 反转它
                 然后 把结果保存到 @final-array 中
```

就像你看到的那样, 方法的流向是自上而下的。

**向后流**

```perl
my @array = <7 8 9 0 1 2 4 3 5 6>;
my @final-array-v2 <== reverse()
                   <== sort()
                   <== unique()
                   <== @array;
say @final-array-v2;
```

**解释**

向后流就像向前流一样, 但是是以反转的顺序写的。

方法的流动方向是自下而上。

###  Hyper 操作符

**hyper 操作符** `».` 会在列表的所有元素身上调用一个方法并返回所有结果的一个列表。

```perl
my @array = <0 1 2 3 4 5 6 7 8 9 10>;
sub is-even($var) { $var %% 2 };

say @array».is-prime;
say @array».&is-even;
```

使用 hyper 操作符我们能调用 Perl 6 中已经定义过的方法, 例如. `is-prime` 告诉我们一个数字是否是质数。

此外我们能定义新的子例程并使用 hyper 操作符调用它们。但是这时我们必须在方法的名字前面加上 `&` 符号。例如. `&is-even`。

这很实用因为它使我们不必写 `for` 循环就可以迭代每个值。

###  Junctions

**junction** 是值的逻辑叠加。

在下面的例子中 `1|2|3` 是一个 junction。

```perl
my $var = 2;
if $var == 1|2|3 {
    say "The variable is 1 or 2 or 3"
}
```

junctions 的使用常常触发**自动线程化**; 每个 junction 元素都执行该操作, 并且所有的结果被组合到一个新的 junction 中并返回。

###  Lazy Lists

**惰性列表**是被惰性求值的列表。

惰性求值延迟表达式的计算直到需要时, 并把结果存储到查询表中以避免重复计算。

惰性列表的优点包括:

- 通过避免不必要的计算带来的性能提升
- 构建潜在的无限数据结构的能力
- 定义控制流的能力

我们使用中缀操作符 `...` 来创建惰性列表。

惰性列表拥有一个**初始元素**, 一个**发生器**和一个**结束点**。

**简单的惰性列表**

```perl
my  $lazylist = (1 ... 10);
say $lazylist;
```

初始元素为 1 而结束点为 10。因为没有定义发生器所以默认的发生器为 successor(+1)。换句话说, 这个惰性列表可能返回(如果需要的话)下面的元素 (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)。

**无限惰性列表**

```perl
my  $lazylist = (1 ... Inf);
say $lazylist;
```

该列表可能返回(如果需要的话) 1 到无穷大之间的任何整数, 换句话说, 可以返回任何整数。

**使用推断发生器创建惰性列表**

```perl
my  $lazylist = (0,2 ... 10);
say $lazylist;
```

初始的元素是 0 和 2 而结束点是 10。虽然没有定义发生器, 但是使用了初始元素, Perl 6 会把生成器推断为 (+2)。

这个惰性列表可能返回(如果需要的话)下面的元素 (0, 2, 4, 6, 8, 10)。

**使用定义的发生器创建惰性列表**

```perl
my  $lazylist = (0, { $_ + 3 } ... 12);
say $lazylist;
```

在这个例子中, 我们在闭合 `{ }` 中显式地定义了一个发生器。

这个惰性列表可能返回(如果需要的话)下面的元素 (0, 3, 6, 9, 12)。

> 当使用显式的发生器时, 结束点必须是发生器能返回的一个值。
>
> 如果在上面的例子中我们使用的结束点是 10 而非 12, 那么发生器就不会停止。发生器会跳过那个结束点。
>
> 二选一, 你可以使用 `0 ...^ * > 10` 代替 `0 ... 10`。你可以把它读作: 从 0 直到第一个大于 10(不包括它)的值
>
> **这不会使发生器停止**
>
> ```perl
> my  $lazylist = (0, { $_ + 3 } ... 10);
> say $lazylist;
> ```
>
> **这会使发生器停止**
>
> ```perl
> my  $lazylist = (0, { $_ + 3 } ...^ * > 10);
> say $lazylist;
> ```
>
> 

## 类和对象

在上一章中我们学习了 Perl 6 中函数式编程的便利性。在这一章中我们将看看 Perl 6 中的面向对象编程。

###  介绍

面向对象编程是当今广泛使用的范式之一。**对象**是一组绑定在一起的变量和子例程。

其中的变量叫做**属性**, 而子例程被叫做**方法**。属性定义对象的**状态**, 而方法定义对象的**行为**。

**类**定义一组**对象**结构。

为了理解它们之间的关系, 考虑下面的例子:

| 房间里有 4 个 people   | **objects** => 4 people                  |
| ----------------- | ---------------------------------------- |
| 这 4 个人是 humans    | **class** => Human                       |
| 它们有不同的名字,年纪,性别和国籍 | **attribute** => name,age,sex,nationality |

按面向对象的说法, 对象是类的**实例**。

考虑下面的脚本:

```perl
class Human {
    has $name;
    has $age;
    has $sex;
    has $nationality;
}

my $john = Human.new(name => 'John',
                     age  => 23,
                     sex  => 'M'
                     nationality => 'American')
say $john;
```

`class` 关键字用于定义类。

`has` 关键字用于定义类的属性。

`.new` 方法被称之为 **构造函数**。它创建了对象作为类的实例。

在上面的例子中, 新的变量 `$john` 保存了由 `Human.new()` 所定义的新 "Human" 实例。

传递给 `.new()` 方法的参数用于设置底层对象的属性。

类可以使用 `my` 来声明一个本地作用域:

```perl
my class Human {

}
```

### 封装

封装是一个面向对象的概念, 它把一组数据和方法捆绑在一块。

对象中的数据(属性)应该是**私有的**, 换句话说, 只能从对象内部访问它。

为了从对象外部访问对象的属性, 我们使用叫做**存取器**的方法。

下面两个脚本拥有同样的结果。

**直接访问变量**:

```perl
my  $var = 7;
say $var;
```

**封装**

```perl
my $var = 7;
sub sayvar {
    $var;
}
say sayvar;
```

`sayvar` 是一个存取器。它让我们通过不直接访问这个变量来访问这个变量。

在 Perl 6 中使用  **twigils** 使得封装很便利。

Twigils 是第二 ***符号***。它们存在于符号和属性名之间。

有两个 twigils 用在类中:

- `!` 用于显式地声明属性是私有的
- `.` 用于为属性自动生成存取器

默认地, 所有的属性都是私有的, 但是总是用 `!` twigil 是一个好习惯。

为了和我说的相一致, 我们应该把上面的类重写成下面这样:

```perl
class Human {
    has $!name;
    has $!age;
    has $!sex;
    has $!nationality;
}

my $john = Human.new(name => 'John', age => 23, sex => 'M', nationality => 'American');
say $john;
```

给脚本追加这样的的语句: `say $john.age`;

它会返回这样的错误: `Method 'age' not found for invocant of class 'Human'`。

原因是 `$!age` 是私有的并且只能用于对象内部。 尝试在对象外部访问它会返回一个错误。

现在用 `has $.age` 代替 `$!age` 并看看 `say $john.age;` 的结果是什么。



###  具名参数 vs. 位置参数

在 Perl 6 中, 所有的类继承了一个默认的 `.new` 构造函数。

通过为他提供参数, 它能用于创建对象。

只能提供**具名参数**给默认的构造函数。

如果你考虑到上面的例子, 你会看到所有提供给 `.new` 方法的参数都是按名字定义的:

- name => 'John'
- age     => 23

假如我不想在每次创建新对象的时候为每个属性提供一个名字呢?

那么我需要创建另外一个接收**位置参数**的构造函数。

```perl
class Human {
    has $.name;
    has $.age;
    has $.sex;
    has $.nationality;

    # 重写默认构造函数的新构造函数
    method new ($name, $age, $sex, $nationality) {
        self.bless(:$name, :$age, :$sex, :$nationality);
    }
}

my $john = Human.new('John', 23, 'M', 'American');
say $john;
```

能接收位置参数的构造函数需要按上面那样定义。

### 方法

#### 介绍

方法是对象的子例程。

像子例程一样, 方法是一种打包一组功能的手段, 它们接收**参数**, 拥有**签名**并可以被定义为 **multi**。

方法是使用关键字 `method` 来定义的。

正常情况下, 方法被要求在对象的属性身上执行一些动作。这强制了封装的概念。对象的属性只能在对象里面使用方法来操作。在对象外面, 只能和对象的方法交互, 并且不能访问它的属性。

```perl
class Human {
  has $.name;
  has $.age;
  has $.sex;
  has $.nationality;
  has $.eligible;
  method assess-eligibility {
      if self.age < 21 {
          $!eligible = 'No'
      } else {
          $!eligible = 'Yes'
      }
  }
}

my $john = Human.new(name => 'John', age => 23, sex => 'M', nationality => 'American');
$john.assess-eligibility;
say $john.eligible;
```

一旦方法定义在类中, 它们就能在对象身上使用**点记号**来调用:

`object.method` 或像上面的例子那样: `$john.assess-eligibility`。

在方法的定义中, 如果我们需要引用对象本身以调用另一个方法, 则使用 `self` 关键字。

在方法的定义中, 如果我们需要引用属性, 则使用 `!` , 即使属性是使用 `.` 定义的。

理由是 `.` twigil 做的就是使用 `!` 声明一个属性并自动创建存取器。

在上面的例子中, `if self.age < 21` 和  `if $!age < 21` 会有同样的效果, 尽管它们从技术上来讲是不同的:

- `self.age` 调用了 `.age` 方法(存取器)

​       二选一, 还能写成 `$.age`

- `$!age` 是直接调用那个变量

#### 私有方法

正常的方法能从类的外面在对象身上调用。

**私有方法**是只能从类的内部调用的方法。

一个可能的使用情况是一个方法调用另外一个执行特定动作的方法。连接外部世界的方法是公共的而被引用的那个方法应该保持私有。我们不想让用户直接调用它, 所以我们把它声明为私有的。

私有方法的声明需要在方法的名字前使用 `!` twigil。

私有方法是使用 `!` 而非 `.` 调用的。

```perl
method !iamprivate {
    # code goes in here
}

method iampublic {
    self!iamprivate;
    # do additional things
}
```

###  类属性

**类属性**是属于类自身而非类的对象的属性。

它们能在定义期间初始化。

类属性是使用 `my` 关键字而非 `has` 关键字声明的。

它们是在类自己身上而非它的对象身上调用的。

```perl
class Human {
    has $.name;
    my  $.counter = 0;
    method new($name) {
      Human.counter++;
      self.bless(:$name);
    }
}
my $a = Human.new('a');
my $b = Human.new('b');

say Human.counter;
```

###  访问类型

到现在为止我们看到的所以例子都使用存取器来从对象属性中获取信息。

假如我们需要修改属性的值呢?

我们需要使用下面的 `is rw` 关键字把它标记为 `read/write`。

```perl
class Human {
    has $.name;
    has $.age is rw;
}
my $john = Human.new(name => 'John', age => 21);
say $john.age;

$john.age = 23;
say $john.age;
```

默认地, 所有属性都声明为只读, 但是你可以显式地使用 `is readonly` 来声明。

### 继承

####  介绍

**继承**是面向对象编程的另一个概念。

当定义类的时候, 很快我们会意思到很多属性/方法在很多类中是共有的。

我们应该重复代码吗?

不! 我们应该使用**继承**。

假设我们想定义两个类, 一个类是 Human, 一个类是 Employees。

Human 拥有两个属性: name 和 age。

Employees 拥有 4  个属性: name, age, company 和 salary。

尝试按下面定义类:

```perl
class Human {
    has $.name;
    has $.age;
}

class Employee {
    has $.name;
    has $.age;
    has $.company;
    has $.salary;
}
```

虽然上面的代码技术上是正确的, 但是概念上差。

更好的写法是下面这样:

```perl
class Human {
    has $.name;
    has $.age;
}
class Employee is Human {
    has $.company;
    has $.salary;
}
```

`is` 关键字定义了继承。

按面向对象的说法, Employee 是 Human 的**孩子**, 而 Human 是 Employee 的**父亲**。

所有的子类继承了父类的属性和方法, 所以没有必要重新它们。

####  重写

类从它们的父类中继承所有的属性和方法。

有些情况下, 我们需要让子类中的方法表现得和继承的方法不一样。

为了做到这, 我们在子类中重新定义方法。

这个概念就叫做**重写**。

在下面的例子中, `introduce-yourself` 方法被 Employee 类继承。

```perl
class Human {
    has $.name;
    has $.age;
    method introduce-yourself {
      say 'Hi 我是人类, 我的名字是 ' ~ self.name;
    }
}

class Employee is Human {
    has $.company;
    has $.salary;
}

my $john = Human.new(name => 'John', age => 23,);
my $jane = Employee.new(name => 'Jane', age => 25, company => 'Acme', salary => 4000);

$john.introduce-yourself;
$jane.introduce-yourself;
```

重写工作如下:

```perl
class Human {
    has $.name;
    has $.age;
    method introduce-yourself {
      say 'Hi 我是人类, 我的名字是 ' ~ self.name;
    }
}

class Employee is Human {
    has $.company;
    has $.salary;
    method introduce-yourself {
      say 'Hi 我是一名员工, 我的名字是 ' ~ self.name ~ ' 我工作在: ' ~ self.comapny;
    }
}

my $john = Human.new(name =>'John',age => 23,);
my $jane = Employee.new(name =>'Jane',age => 25,company => 'Acme',salary => 4000);

$john.introduce-yourself;
$jane.introduce-yourself;
```

根据对象所属的类, 会调用正确的方法。

####  Submethods

**Submethods** 是一种子类继承不到的方法。

它们只能从所声明的类中访问。

它们使用 `submethod` 关键字定义。

### 多重继承

在 Perl 6 中允许多重继承。一个类可以继承自多个其它的类。

```perl
class bar-chart {
  has Int @.bar-values;
  method plot {
    say @.bar-values;
  }
}

class line-chart {
  has Int @.line-values;
  method plot {
    say @.line-values;
  }
}

class combo-chart is bar-chart is line-chart {
}

my $actual-sales   = bar-chart.new(bar-values => [10,9,11,8,7,10]);
my $forecast-sales = line-chart.new(line-values => [9,8,10,7,6,9]);

my $actual-vs-forecast = combo-chart.new(bar-values => [10,9,11,8,7,10],
                                         line-values => [9,8,10,7,6,9]);
say "实际的销售: ";
$actual-sales.plot;
say "预测的销售: ";
$forecast-sales.plot;
say "实际 vs 预测:";
$actual-vs-forecast.plot;
```

`输出`

```
实际的销售: 
[10 9 11 8 7 10]
预测的销售: 
[9 8 10 7 6 9]
实际 vs 预测:
[10 9 11 8 7 10]
```

**解释**

`combo-chart` 类应该能持有两个序列, 一个是绘制条形图的实际值, 另一个是绘制折线图的预测值。

这就是我们为什么把它定义为 `line-chart` 和 `bar-chart` 的孩子的原因。

你应该注意到了, 在 `combo-chart` 身上调用 `plot` 方法并没有产生所要求的结果。它只绘制了一个序列。

发生了什么事?

`combo-chart` 继承自 `line-chart` 和 `bar-chart`, 它们都有一个叫做 `plot` 的方法。当我们在 `combo-chart` 身上调用那个方法时, Perl 6 内部会尝试通过调用其所继承的方法之一来解决冲突。

**纠正**

为了表现得正确, 我们应该在 `combo-chart` 中重写 `plot` 方法。

```perl
class bar-chart {
  has Int @.bar-values;
  method plot {
    say @.bar-values;
  }
}

class line-chart {
  has Int @.line-values;
  method plot {
    say @.line-values;
  }
}

class combo-chart is bar-chart is line-chart {
  method plot {
    say @.bar-values;
    say @.line-values;
  }
}

my $actual-sales = bar-chart.new(bar-values => [10,9,11,8,7,10]);
my $forecast-sales = line-chart.new(line-values => [9,8,10,7,6,9]);

my $actual-vs-forecast = combo-chart.new(bar-values => [10,9,11,8,7,10],
                                         line-values => [9,8,10,7,6,9]);
say "实际的销售: ";
$actual-sales.plot;
say "预测的销售: ";
$forecast-sales.plot;
say "实际 vs 预测:";
$actual-vs-forecast.plot;
```

`输出`

```
实际的销售: 
[10 9 11 8 7 10]
预测的销售: 
[9 8 10 7 6 9]
实际 vs 预测:
[10 9 11 8 7 10]
[9 8 10 7 6 9]
```

###  Roles

**Roles** 在它们是属性和方法的集合这个意义上和类有点类似。

Roles 使用关键字 `role` 声明, 而想实现该 role 的类可以使用 `does` 关键字。

**使用 roles 重写多重继承的例子**

```perl
role bar-chart {
  has Int @.bar-values;
  method plot {
    say @.bar-values;
  }
}

role line-chart {
  has Int @.line-values;
  method plot {
    say @.line-values;
  }
}

class combo-chart does bar-chart does line-chart {
  method plot {
    say @.bar-values;
    say @.line-values;
  }
}

my $actual-sales = bar-chart.new(bar-values => [10,9,11,8,7,10]);
my $forecast-sales = line-chart.new(line-values => [9,8,10,7,6,9]);

my $actual-vs-forecast = combo-chart.new(bar-values => [10,9,11,8,7,10],
                                         line-values => [9,8,10,7,6,9]);
say "实际的销售: ";
$actual-sales.plot;
say "预测的销售: ";
$forecast-sales.plot;
say "实际 vs 预测:";
$actual-vs-forecast.plot;
```

运行上面的脚本你会看到结果是一样的。

现在你问问自己, 如果 roles 表现得像类的话那么它们的用途是什么呢?

要回答你的问题, 修改第一个用于展示多重继承的脚本,  这个脚本中我们忘记重写 `plot` 方法了。

```perl
role bar-chart {
  has Int @.bar-values;
  method plot {
    say @.bar-values;
  }
}

role line-chart {
  has Int @.line-values;
  method plot {
    say @.line-values;
  }
}

class combo-chart does bar-chart does line-chart {
}

my $actual-sales = bar-chart.new(bar-values => [10,9,11,8,7,10]);
my $forecast-sales = line-chart.new(line-values => [9,8,10,7,6,9]);

my $actual-vs-forecast = combo-chart.new(bar-values => [10,9,11,8,7,10],
                                         line-values => [9,8,10,7,6,9]);
say "Actual sales:";
$actual-sales.plot;
say "Forecast sales:";
$forecast-sales.plot;
say "Actual vs Forecast:";
$actual-vs-forecast.plot;
```

`输出`

```
===SORRY!===
Method 'plot' must be resolved by class combo-chart because it exists in multiple roles (line-chart, bar-chart)
```

**解释**

如果多个 roles 被应用到同一个类中, 会出现冲突并抛出一个编译时错误。

这是比多重继承更安全的方法, 其中冲突不被认为是错误并且简单地在运行时解决。

Roles 会提醒你有冲突。

### 内省

**内省**是获取诸如对象的类型、属性或方法等对象属性的信息的过程。

```perl
class Human {
  has Str $.name;
  has Int $.age;
  method introduce-yourself {
    say 'Hi i am a human being, my name is ' ~ self.name;
  }
}

class Employee is Human {
  has Str $.company;
  has Int $.salary;
  method introduce-yourself {
    say 'Hi i am a employee, my name is ' ~ self.name ~ ' and I work at: ' ~ self.company;
  }
}

my $john = Human.new(name =>'John',age => 23,);
my $jane = Employee.new(name =>'Jane',age => 25,company => 'Acme',salary => 4000);

say $john.WHAT;
say $jane.WHAT;
say $john.^attributes;
say $jane.^attributes;
say $john.^methods;
say $jane.^methods;
say $jane.^parents;
if $jane ~~ Human {say 'Jane is a Human'};
```

内省使用了:

- `.WHAT`  返回已经创建的对象所属的类。
- `.^attributes` 返回一个包含该对象所有属性的列表。
- `.^mtethods` 返回能在该对象身上调用的所有方法。
- `.^parents` 返回该对象所属类的所有父类。
- `~~` 叫做智能匹配操作符。如果对象是从它所进行比较的类或任何它继承的类创建的, 则计算为 True。

##  异常处理

### 捕获异常

**异常**是当某些东西出错时发生在运行时的特殊行为。

我们说异常被抛出。

考虑下面这个运行正确的脚本:

```perl
my Str $name;
$name = "Joanna";
say "Hello " ~ $name;
say "How are you doing today?"
```

`输出`

```
Hello Joanna
How are you doing today?
```

现在让这个脚本抛出异常:

```perl
my Str $name;
$name = 123;
say "Hello " ~ $name;
say "How are you doing today?"
```

`输出`

```
Type check failed in assignment to $name; expected Str but got Int
   in block <unit> at exceptions.pl6:2
```

你应该看到当错误出现时(在这个例子中把数组赋值给字符串变量)程序会停止并且其它行的代码不会被执行, 即使它们是正确的。

**异常处理**是捕获已经抛出的异常的过程以使脚本能继续工作。

```perl
my Str $name;
try {
  $name = 123;
  say "Hello " ~ $name;
  CATCH {
    default {
      say "Can you tell us your name again, we couldn't find it in the register.";
    }
  }
}
say "How are you doing today?";
```

`输出`

```
Can you tell us your name again, we couldn't find it in the register.
How are you doing today?
```

异常处理是使用 `try-catch` block 完成的。

```perl
try {
  # code goes in here
  # 如果有东西出错, 脚本会进入到下面的 CATCH block 中
  # 如果什么错误也没有, 那么 CATCH block 会被忽略
  CATCH {
    default {
      # 只有抛出异常时, 这儿的代码才会被求值
    }
  }
}
```

`CATCH` block 能像定义 `given` block 那样定义。这意味着我们能捕获并处理各种不同类型的异常。

```perl
try {
  #code goes in here
  #if anything goes wrong, the script will enter the below CATCH block
  #if nothing goes wrong the CATCH block will be ignored
  CATCH {
    when X::AdHoc { #do something if an exception of type X::AdHoc is thrown }
    when X::IO { #do something if an exception of type X::IO is thrown }
    when X::OS { #do something if an exception of type X::OS is thrown }
    default { #do something if an exception is thrown and doesn't belong to the above types }
  }
}
```

###  抛出异常

和捕获异常相比, Perl  6 也允许你显式地抛出异常。

有两种类型的异常可以抛出:

- ad-hoc 异常
- 类型异常

**ad-hoc**

```perl
my Int $age = 21;
die "Error !";
```

**typed**

```perl
my Int $age = 21;
X::AdHoc.new(payload => 'Error !').throw;
```

使用 `die` 子例程后面跟着异常消息来抛出 Ad-hoc 异常。

Typed 异常是对象, 因此上面的例子中使用了 `.new()` 构造函数。

所有类型化的异常都是从类 `X` 开始, 下面是一些例子:

`X::AdHoc` 是最简单的异常类型

`X::IO` 跟 IO 错误有关。

`X::OS` 跟 OS 错误有关。

`X::Str::Numeric` 跟把字符串强制转换为数字有关。

> 查看异常类型和相关方法的完整列表请到  [http://doc.perl6.org/type.html](http://doc.perl6.org/type.html) 并导航到以 X 开头的类型。



## 正则表达式

正则表达式, 或 **regex** 是一个用于模式匹配的字符序列。

理解它最简单的一种方式是把它看作模式。

```perl
if 'enlightenment' ~~ m/ light / {
    say "enlightenment contains the word light";
}
```

在这个例子中, 智能匹配操作符 `~~` 用于检查一个字符串(enlightenment)是否包含一个单词(light)。

"Enlightenment"  与正则表达式 `m/ light /` 匹配。

### Regex 定义

正则表达式可以按如下方式定义:

- /light/
- m/light/
- rx/light/

除非显式地指定, 否则空白是无关紧要的, `m/light/` 和 `m/ light /` 是相同的。

### 匹配字符

字母数字字符和下划线 `_` 在正则表达式中是按原样写出的。

所有其它字符必须使用反斜线或用引号围起来以转义。

**反斜线**

```perl
if 'Temperature: 13' ~~ m/ \: / {
    say "The string provided contains a colon :";
}
```

**单引号**

```perl
if 'Age = 13' ~~ m/ '=' / {
    say "The string provided contains an equal character = ";
}
```

**双引号**

```perl
if 'name@company.com' ~~ m/ "@" / {
    say "This is a valid email address because it contains an @ character";
}
```

### 匹配字符类

就像之前章节看到的, 匹配字符类很方便。

话虽这么说，更系统的方法是使用 Unicode 属性。

Unicode 属性闭合在 `<: >` 中。

```perl
if "John123" ~~ / <:N> / {
  say "Contains a number";
} else {
  say "Doesn't contain a number"
}

if "John-Doe" ~~ / <:Lu> / {
  say "Contains an uppercase letter";
} else {
  say "Doesn't contain an upper case letter"
}

if "John-Doe" ~~ / <:Pd> / {
  say "Contains a dash";
} else {
  say "Doesn't contain a dash"
}
```

### 通配符

通配符也可以用在正则表达式中。

点 `.` 意味着任何单个字符。

```perl
if 'abc' ~~ m/ a.c / {
    say "Match";
}

if 'a2c' ~~ m/ a.c / {
    say "Match";
}

if 'ac' ~~ m/ a.c / {
    say "Match";
  } else {
    say "No Match";
}
```

### 量词

量词在字符后面用于指定我们期望匹配它前面的东西的次数。

问号 `?` 意思是 0 或 1 次。

```perl
if 'ac' ~~ m/ a?c / {
    say "Match";
  } else {
    say "No Match";
}

if 'c' ~~ m/ a?c / {
    say "Match";
  } else {
    say "No Match";
}
```

星号 `*` 意思是 0 或多次。

```perl
if 'az' ~~ m/ a*z / {
    say "Match";
  } else {
    say "No Match";
}

if 'aaz' ~~ m/ a*z / {
    say "Match";
  } else {
    say "No Match";
}

if 'aaaaaaaaaaz' ~~ m/ a*z / {
    say "Match";
  } else {
    say "No Match";
}

if 'z' ~~ m/ a*z / {
    say "Match";
  } else {
    say "No Match";
}
```

`+` 意思是至少匹配 1 次。

```perl
if 'az' ~~ m/ a+z / {
    say "Match";
  } else {
    say "No Match";
}

if 'aaz' ~~ m/ a+z / {
    say "Match";
  } else {
    say "No Match";
}

if 'aaaaaaaaaaz' ~~ m/ a+z / {
    say "Match";
  } else {
    say "No Match";
}

if 'z' ~~ m/ a+z / {
    say "Match";
  } else {
    say "No Match";
}
```

### 匹配结果

当匹配字符串的正则表达式成功时, 匹配结果被存储在一个特殊的变量 `$/` 中。

**脚本**

```perl
if 'Rakudo is a Perl 6 compiler' ~~ m/:s Perl 6/ {
    say "The match is: " ~ $/;
    say "The string before the match is: " ~ $/.prematch;
    say "The string after the match is: " ~ $/.postmatch;
    say "The matching string starts at position: " ~ $/.from;
    say "The matching string ends at position: " ~ $/.to;
}
```

**输出**

```perl
The match is: Perl 6
The string before the match is: Rakudo is a
The string after the match is:  compiler
The matching string starts at position: 12
The matching string ends at position: 18
```

**解释**

`$/` 返回一个 **Match Object**(匹配 regex 的字符串)。

下面的方法可以在 **Match Object** 身上调用:

`.prematch` 返回匹配前面的字符串

`.postmatch` 返回匹配后面的字符串

`.from` 返回匹配的开始位置

`.to` 返回匹配的结束位置

> 默认地空白在 regex 中是无关紧要的。
>
> 如果我们想在 regex 中包含空白, 我们必须显式地这样做。
>
> regex `m/:s Perl 6/` 中的 `:s` 强制考虑空白并且不会被删除。
>
> 二选一, 我们能把 regex 写为 `m/Perl\s6/` 并使用 `\s` 占位符。
>
> 如果 regex 中包含的空白不止一个, 使用 `:s` 比使用 `\s` 更高效。



### 例子

让我们检查一个邮件是否合法。

我们假设一个合法的电子邮件地址的形式如下:

first name [dot] last name [at] company [dot] (com/org/net)

> 这个例子中用于电子邮件检测的 regex 不是很准确。它的核心意图是用来解释 Perl 6 中的 regex 的功能的。 不要在生产中原样使用它。

**脚本**

```perl
my $email = 'john.doe@perl6.org';
my $regex = / <:L>+\.<:L>+\@<:L+:N>+\.<:L>+ /;

if $email ~~ $regex {
  say $/ ~ " is a valid email";
} else {
  say "This is not a valid email";
}
```

**输出**

```
john.doe@perl6.org is a valid email
```

**解释**

`<:L>`  匹配单个字符
`<:L>+` 匹配单个字符或更多字符
`\.`  匹配单个点号字符
`\@`  匹配单个  [at] 符号
`<:L+:N>` 匹配一个字母和数字
`<:L+:N>+` 匹配一个或多个字母和数字

其中的 regex 可以分解成如下:

- **first name** `<:L>+`
- **[dot]** `\.`
- **last name** `<:L>+`
- **[at]** `\@`
- **company name** `<:L+:N>+`
- **[dot]** `\.`
- **com/org/net** `<:L>+`

可选地, 一个 regex 可以被分解成多个具名 regexes。

```perl
my $email = 'john.doe@perl6.org';
my regex many-letters { <:L>+ };
my regex dot { \. };
my regex at { \@ };
my regex many-letters-numbers { <:L+:N>+ };

if $email ~~ / <many-letters> <dot> <many-letters> <at> <many-letters-numbers> <dot> <many-letters> / {
  say $/ ~ " is a valid email";
} else {
  say "This is not a valid email";
}
```

具名 regex 是使用 `my regex regex-name { regex definition }` 定义的。

具名 regex 可以使用 `<regex-name>` 来调用。

> 更多关于 regexes 的东西, 查看 [http://doc.perl6.org/language/regexes](http://doc.perl6.org/language/regexes)

## Perl 6 模块

Rakudo 自带了 Panda 这个模块安装工具。

要安装指定的模块, 在终端中键入如下命令:

```
panda install "module name"
```

> Perl  6 的模块目录可以在  [http://modules.perl6.org/](http://modules.perl6.org/) 中找到。

### 使用模块

MD5是一个关于密码的散列函数，它产生一个128位的散列值。
MD5有多种加密存储在数据库中的口令的应用程序。当新用户注册时，其证书并不存储为纯文本，而是散列。这样做的理由是，如果该数据库被破解，攻击者将不能够知道口令是什么。

比方说，你需要一个生成密码的MD5哈希以存储在数据库中备用的脚本。

幸运的是， Perl 6 已经有一个能实现MD5算法的模块。我们安装下:

`panda install Digest::MD5`

现在运行下面的脚本:

```perl
use Digest::MD5;
my $password = "password123";
my $hashed-password = Digest::MD5.new.md5_hex($password);

say $hashed-password;
```

为了运行创建哈希的 `md5_hex()` 函数, 我们需要加载需要的模块。`use` 关键字用于加载模块。

## Unicode

Unicode 是编码并表现文本的标准, 它满足了世界上的大部分系统。

UTF-8 是能够以Unicode编码所有可能的字符或代码点的字符编码。

字符的定义是通过:

**字素**: 可见的表示

**代码点**: 赋值给字符的数字

### 使用 Unicode

**让我们看一下使用 Unicode 能输出什么**

```perl
say "a";
say "\x0061";
say "\c[LATIN SMALL LETTER A]";
```

上面 3 行展示了构建字符的不同方法:

1. 直接写出字符(字素)
2. 使用 `\x` 和代码点
3. 使用 `\c` 和代码点名字

**现在我们来输出笑脸**

```perl
say "☺";
say "\x263a";
say "\c[WHITE SMILING FACE]";
```

**组合两个代码点的另外一个例子**

```perl
say "á";
say "\x00e1";
say "\x0061\x0301";
say "\c[LATIN SMALL LETTER A WITH ACUTE]";
```

字母 `á` 可以被写为:

- 使用它的唯一代码点 `\x00e1`
- 或作为 `a` 和 重音符号 `\x0061\x0301` 代码点的组合

**有些方法可以使用**

```perl
say "á".NFC;
say "á".NFD;
say "á".uniname;
```

**输出**

```
NFC:0x<00e1>
NFD:0x<0061 0301>
LATIN SMALL LETTER A WITH ACUTE
```

`NFC` 返回唯一的代码点。

`NFD` 分解(decompose)那个字符并返回每部分的代码点。

`uniname` 返回代码点的名字。

**Unicode 字符可以用作标识符**:

```perl
my $Δ = 1;
$Δ++;
say $Δ;
```

## 并行、并发和异步

在正常情况下, 程序中的所有任务都是相继地运行的。

这可能不是个事儿除非你正尝试去做的东西需要耗费很多时间。

很自然地说, Perl 6 拥有能让你并行地运行东西的功能。

在这个阶段, 注意并行可以是下面两个东西之一是很重要的:

- **任务并行化**: 两个(或更多)独立的表达式并行地运行。
- **数据并行化**: 单个表达式并行地迭代列表中的元素。

让我们从后者开始。

### 数据并行化

```perl
my @array = (0..50000);                     #Array population
my @result = @array.map({ is-prime $_ });   #call is-prime for each array element
say now - INIT now;                         #Output the time it took for the script to complete
```

**考虑上面的例子**

我们只做一个操作 `@array.map({is-prime $_})`。`is-prime` 子例程相继被每个数组元素所调用:

`is-prime @array[0] ` 然后是 `is-prime @array[1]` 然后是 `is-prime @array[2]` 等等。

**幸运的是, 我们能同时在多个数组元素身上调用 `is-prime` 函数:**

```perl
my @array = (0..50000);                         #Array population
my @result = @array.race.map({ is-prime $_ });  #call is-prime for each array element
say now - INIT now;                             #Output the time it took to complete
```

注意表达式中使用的 `race`。这个方法会使数组元素能够并行地迭代。

运行两个例子(使用和不使用 `race`)运行之后, 比较两个脚本运行结束所花费的时间。

> `race` 不会保存元素的顺序。如果你想那样做, 使用 `hyper` 代替。
>
> **race**
>
> ```perl
> my @array = (1..1000);
> my @result = @array.race.map( {$_ + 1} );
> @result».say;
> ```
>
> **hyper**
>
> ```perl
> my @array = (1..1000);
> my @result = @array.hyper.map( {$_ + 1} );
> @result».say;
> ```
>
> 如果你俩个脚本都运行了, 你应该注意到一个排序了一个没有排序。

### 任务并行化

```perl
my @array1 = (0..49999);
my @array2 = (2..50001);

my @result1 = @array1.map( {is-prime($_ + 1)} );
my @result2 = @array2.map( {is-prime($_ - 1)} );

say @result1 == @result2;

say now - INIT now;
```

**考虑上面的例子**:

1. 我们定义了 2 个数组
2. 对每个数组应用不同的操作并保存结果
3. 并检查两个结果是否相同

该脚本等到 `@array1.map( {is-prime($_ +1)} )` 完成然后计算 `@array1.map( {is-prime($_ +1)} )`。

应用到每个数组的俩个操作彼此间没有依赖。

**为什么不并行地执行呢?**

```perl
my @array1 = (0..49999);
my @array2 = (2..50001);

my $promise1 = start @array1.map( {$_ + 1} );
my $promise2 = start @array2.map( {$_ - 1} );

my @result1 = await $promise1;
my @result2 = await $promise2;

say @result1 == @result2;

say now - INIT now;
```

**解释**

`start` 方法计算它后面的代码并返回**promise 类型的对象**或**promise**。

如果代码被正确地求值, 那么 promise 会被**保留**(kept)。

如果代码抛出异常, 那么 promise 会被**破坏**(broken)。

`await` 方法等待一个 **promise**。

如果那个 promise 是被**保留**的, await 会获取到返回值。

如果那个 promise 是被**破坏**的, await 会获取到抛出异常。

检查每个脚本完成所花费的时间。

> 并行总是添加线程开销。如果开销抵消不了运算速度的增长，那么该脚本会显得较慢。
> 这就是为什么，在很简单的脚本中使用 **race**，**hyper**，**start** 和 **await** 实际上可以使它们慢下来。

### 并发和异步

>  关于并发和异步编程的更多信息, 请查看  [http://doc.perl6.org/language/concurrency](http://doc.perl6.org/language/concurrency)

## 社区

很多讨论发生在 [#perl6](irc://irc.freenode.net/#perl6) IRC 频道中。你可以到 [http://perl6.org/community/irc](http://perl6.org/community/irc) 进行任何询问。

[http://pl6anet.org/](http://pl6anet.org/) 是一个 Perl 6 博客聚合器。





