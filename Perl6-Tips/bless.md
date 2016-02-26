title:  bless

date: 2016-01-22

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>流星划过黑夜不再恐惧, 总有遗憾所以美丽。</blockquote>

## bless 方法

``` perl
method bless(*%attrinit) returns Mu:D
```

相比 `new`方法来说更低层级别的对象构造方法。

创建一个和调用者同类型的新对象, 使用具名参数来初始化属性, 并返回创建后的**对象**。

在自定义构造函数时可以使用该方法:

``` perl
class Point {
    has $.x;
    has $.y;

    # multi 是可选的
    multi method new($x, $y) {
        self.bless(:$x, :$y);
    }
}

# 重写构造函数后, 不需要传具名参数了
my $p = Point.new(-1, 1);
say $p.x; # -1
```

> 虽然你可以自定义构造函数, 记得它会让子类继承变得更困难。


```perl
use v6;

# bless 的原理
class Dog {
    has $.name;
    my $.counter; # 类方法
    # 重写 new 方法, 使用位置参数创建实例
    method new ($newName) {
        $.counter++;
        self.bless(name => $newName);
    }
}

my $dog = Dog.new("yayaya");
say $dog.name;   # yayaya
say Dog.counter; # 1
```

## 让我们创建一个对象

在 Perl 6 中创建一个对象相当容易。 作为类的作者你真的不必关心(至少在最简单的情况下), 你从 `Mu` 类继承了一个默认的构造函数。作为类的使用者, 你仅仅写出 `MyClass.new(attrib1 => $value1)` 就能创建一个 `MyClass`类的对象, 同时初始化了一个公开的属性 **attrib1**。

## 运行初始化代码

如果你想在对象创建中运行某些初始化代码, 那么你一点儿也没有必要动用 `new`方法。使用 **BUILD** 子方法:

``` perl
class C {
    submethod BUILD {
        say "创建一个 C 的实例";
    }
}

C.new();  # 创建一个 C 的实例
```

**BUILD** submethod 由构造函数自动调用, 并且可以处理任何必要的初始化。**BUILD** submethod 也能接收用户传递给 `new()` 方法的具名参数。

(以防你疑惑,  **submethod** 是**不能**被子类继承的方法。)

因为 **BUILD** 运行在尚未完全构建好的对象上,  属性只有在被声明为具名参数的时候才可以被访问:

``` perl
submethod BUILD(:$!attr1, :$!attr2) {
    # 这儿可以使用 $!attr1 和 $!attr2
}
```

该语法也自动的使用和 `new`方法同名的具名参数的值初始化属性 。

``` perl
use v6;

class Cat {
    has $.fullname;
    has $.nickname;

    submethod BUILD(:$!fullname, :$!nickname) {
        say "造了一只猫, 它的全名是 $!fullname, 它的昵称是 $!nickname";
    }
}

# 造了一只猫, 它的全名是 Camelia, 它的昵称是 Rakudo Star
Cat.new(fullname => 'Camelia', nickname => 'Rakudo Star');
```

所以下面的两个类声明, 表现一样:

``` perl
class D {
    has $.x;
}
# and
class D {
    has $!x;                   # 私有属性
    submethod BUILD(:$!x) {}   # 允许 D.new( x => $x )
    method x() {$!x}           # accessor
}
```

这也解释了 `has $.x` 等价于 `has $!x` 加上 accessor 的原理。

## 自定义构造函数

假如你对具名参数不感冒, 而你想自定义一个接收**一个**强制位置参数的构造函数。那样你就需要自定义 `new`方法。要创建一个对象, 被重写的 new 方法中**必须**调用 `self.bless`：

``` perl
class C {
    has $.size;
    method new($x) {
        self.bless(*, size => 2 * $x);
    }
}

say C.new(3).size; # 接收一个位置参数, 打印出 6
```

`bless`的第一个参数 *****号告诉它创建一个空对象自身。

如果你想开启额外的具名参数, 那很容易:

``` perl
class C {
    has $.size;
    method new($x, *%remaining) {
        self.bless(*, size => 2 * $x, |%remaining);
    }
}
```

注意, 这两个概念(自定义 new() 和 BUILD() (sub)methods) 是正交的; 你一次可以使用它俩, 它俩能和谐共处。

## 属性的默认值

为属性提供默认值的最方便的方式是在声明属性的时候为属性提供默认值:

``` perl
class Window {
    has $.height = 600;
    has $.width  = $.height * 1.618;
    ...
}
```

默认值只会用在底层属性没有被 `new` 或 `BUILD`接触的时候使用。

## 理解对象初始化

假如你有一个类 C 继承自类 B, 那么创建一个类 C 的对象的处理看起来是这样:

![img](http://ww3.sinaimg.cn/mw690/6c9ce165jw1f08izmvvedj20cs09rdga.jpg)

用户调用 `C.new`, 这反过来调用 `self.bless(*, |args)`。**bless** 方法创建了一个新的存储新创建对象的 **P6Opaque** 对象。这就是调用上图中的 **CREATE**。

分配完存储空间和属性初始化之后,  `new`把控制权传给**BUILDALL**(顺带传递所有的具名参数), 这反过来会从层级树的顶端开始, 调用继承层级树上所有类的 **BUILD** 方法,  最后调用类 C 的 **BUILD** 方法。

这样的设计允许你花费最少的力气来替换初始化的一部分, 尤其是自定义 **new** 和 **BUILD** 方法会很容易写。

``` perl
use v6;

class B {
    has $.name;

    submethod BUILD(:$!name) {
        say "调用了 B 的 BUILD, 我叫 $!name"
    }
}

class C is B {
    has $.nickname;

    submethod BUILD(:$!nickname, :$name) {
        say "调用了 C 的 BUILD, 我叫 $!nickname, 我爸爸是 $name"
    }
    method new(:$nickname) {
        self.bless(nickname => 'Camelia', name => 'Lucy');
    }
}

my $c = C.new(nickname => 'HANMEIMEI');
```

打印：

``` perl
调用了 B 的 BUILD, 我叫 Lucy
调用了 C 的 BUILD, 我叫 Camelia, 我爸爸是 Lucy
```
