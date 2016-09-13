

## Perl 6 中的 `.` 和 `!` **twigil** 是什么？

`.` **twigil** 的意思是"这是类公用的",  `!` **twigil** 的意思是“这是类私有的”, 只能用在类的内部。

``` perl
class ScoreKeeper {
    has @.options;
    has %!player-points;
}
```

普通的符号表明了词法作用域或包作用域, 但是 **twigils** 就像是 **sigils** 的兄弟, 表明了不同的作用域, 它影响了变量的作用域。`.` 和 `!` 是二级 **sigils**。

属性存在于每个类的实例中, 在类的内部, 可以直接使用 `!`访问到实例的属性:

``` perl
class Point {
    has $.x;
    has $.y;
    method Str() {
        "($!x, $!y)"
    }
}
```

那么 `.` **twigil** 和 `!` **twigil** 之间有什么关系呢？下面看一个例子:

``` perl
use v6;

class Point {
    has $.x;
    has $.y;

    method Str() {
        # 注意这次我们使用 . 而非 !
        "\$.x 等价于 self.x()".say  if $.x == self.x();
        "\$.y 等价于 self.y()".say  if $.y == self.y();
    }

    method print() {
        say self.x(); # 调用实例的名为 x 的方法
        say self.y(); # 调用实例的名为 y 的方法
    }
}

my $point = Point.new(x => 10, y => 20);
$point.Str;   
$point.print; 
```

会输出:

``` perl
$.x 等价于 self.x()
$.y 等价于 self.y()
10
20
```

注意到, 属性被声明为 `$.x` 和 `$.y`, 但是在类的内部仍旧能通过 `$!x` 和 `$!y`来访问属性。这是因为在 Perl 6 中所有的属性都是私有的并且在类中可以通过 `$!attribute-name`直接访问这些属性。 Perl 6 可以为你自动生成`存取方法`。

公共属性拥有 `.` twigil, 私有属性拥有 `!` twigil。

`has $.x` 就是私有属性 `has $!x` 加上一个`getter`方法, 即 `method x() { ... }`

`has $.x is rw` 就是私有属性 `has $!x` 加上一个`getter/setter`方法。

## . **twigil** 就是调用了与属性同名的方法

``` perl
class SaySomething {
    method a() { say "a";  }

    method b() { $.a;      }
    method c() { self.a(); } # 这证明了 $.a 的 . twigil 做了一次隐式的实例方法调用。
}

SaySomething.b; # 打印 "a"
SaySomething.c; # 打印 "a"
```

## . **twigil** 中自动生成的方法可以被子类重写

``` perl
use v6;

class Point {
    has $.x;
    has $.y;
}

class Circle is Point {
    has $!radius;

    # 重写父类中的 x() 方法和 y() 方法
    method x() {
        "I am x point in a Circle";
    }
    method y() {
        "I am y point in a Circle";
    }
}

my $circle = Circle.new(radius => 10);
$circle.x().say; # I am x point in a Circle
$circle.y.say;   # I am y point in a Circle
```

如果不想子类重写父类中的方法, 那么在父类中声明属性的时候, 使用 `!` **twigil** 替代 `.` **twigil**

