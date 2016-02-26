title:  How do you add a method to an existing class in Perl 6?

date: 2016-01-13

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>鸿雁, 向苍天, 对对排成行！</blockquote>

## How do you add a method to an existing class in Perl 6?


Int 类有一个方法叫做 `is-prime`, 我想为 `Int`类型添加其它的方法。

```perl
class MyInt is Int {
    method is-even () returns Bool:D {
        return False if self % 2;
        return True;
        }
    }

my $n = MyInt.new(138);
say $n.is-even;
```
通过类的继承也是一种方法, 但是不是我想要的。Swift 中可以通过扩展来实现, Perl 6 中有一个 `add_method`方法:

```perl
method add_method(Metamodel::MethodContainer: $obj, $name, $code)
```
这会给元类(meta class)添加一个方法, 使用 `$name` 作为调用的方法名。这只会在类型被组合前使用。

```perl
Int.^add_method( 'is-even', method () returns Bool:D {
    return False if self % 2;
    return True;
    } );

say 137.is-even;
say Int.^methods;
```

如果我调用 `Int.^methods`时, `is-even`没有出现。但是上面的代码能被调用并起作用了。

## 词法方法

我可以让方法不依附于任何类, 并且能在对象上调用该方法:

```perl
my &is-even = method (Int:D :) returns Bool:D { self %% 2 };
```

这构建了一个 `Callable` （查看以下 `&is-even.WHAT`）。 在签名中, 我把它约束为一个定义了的 Int 类型的值(`Int:D`), 但是没有给它名字。我在类型约束后面添加冒号来说明第一个参数是调用者。现在我能把这个方法应用到任何我想要的对象上:

```perl
say 137.&is-even;
say 138.&is-even;
say "foo".&is-even;  # works, although inside is-even blow up
```
