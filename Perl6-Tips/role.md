
- Composition and mix-ins
- Sigils
- Typed data structures
- Traits



所以到底什么是 `role` 呢？ role 是零个或多个方法和属性的集合。

role 不像 class，它不能被实例化（如果你尝试了，会生成一个 class）。Perl 6 中 Classes 是可变的，而 roles 是不可变的。



## 申明 Roles 就像申明 Class 一样：

使用关键字 `role`来引入 role, 在 role 中声明属性和方法就像在 Perl 6 的类中声明属性和方法那样。

``` perl
role DebugLog {
    has @.log_lines;
    has $.log_size is rw = 100;
    method log_message($message) {
        @!log_lines.shift if
        @!log_lines.elems >= $!log_size;
        @!log_lines.push($message);
    }
}
```

## Role Composition

- 使用 `does` trait 将 role 组合到 Class 中：

``` perl
class WebCrawler does DebugLog {
    ...
}
```

- 这会把方法和属性添加到 class WebCrawler 里面去。
- 结果就像它们起初被写到 class 中一样。

## Mix-ins

- 允许 role 的功能被添加到每个对象的根基上
- 不影响其它的类实例
- role 中的方法总是覆盖对象中已经存在的方法

## Mix-ins Example

- 假设我们想跟踪某个对象发生了什么
- Mix in the DebugLog role

``` perl
$acount does DebugLog;
```

- 然后, 我们可以输出被登记的行

``` perl
$account.log_lines».say;
```

- 现在我们只需给`log_message`方法添加调用
- 我们可以使用`.?`操作符, 这会调用某个方法, 如果方法存在的话

``` perl
class Account {
    method change_password($new) {
        self.?log_message(
            "changing password to $new";
        )
        ...
    }
}
```

## Sigil = 接口协定

- 在 Perl 6 中, 符号表明接口协定
- 这个接口协定由 role 定义
- 你可以只把东西放在带有符号的变量中, 如果该变量遵守(`does`)了要求的 role 的话
- 例外: 带有 `$`的变量可以存储任何东西(如果没有使用类型约束的话)

## @ = Positional

- `@`符号表明它是一个 `Positional`role
- 保证会有一个方法后环缀让你能调用
- This is that gets called when you do an index positionally into something

``` perl
say @fact[1];
say @fact.postcircumfix:<[ ]>(1);
```

- 注意: 优化器(如果有的话)可能发出更轻量级的东西

## % = Associative

- `%` 表明它是一个关联型(Associative)的 role
- 要有一个方法后环缀 `postcircumfix:<{}>`让你调用
- This is that gets called when you do an index associatively into something

``` perl
say %price<Cheese>;
say %price.postcircumfix:<{ }>('Cheese');
```

## & = Callable

- `&`表明它是一个 Callable 的 role
- 东西要能被调用
- 这个 role 被诸如 `Block`、`Sub`、`Method`之类的东西遵守
- 要求实现后环缀 `postcircumfix:<()>`

使用带有 block 的 class 关键字引入一个类：

``` perl
class Puppy {
    ...
}
```

 或使用

``` perl
class Puppy;

...

1;
```

把类相关的东西单独写进一个文件

## Role 也可以被初始化

```perl

role BarChart {
    has Int @.bar-values;
    has $.b is rw;
    method plot {
        say @.bar-values;
    }
}

my $chart = BarChart.new(bar-values => [1,2,3], b => "Camelia");
say $chart.b;
say $chart.bar-values;
$chart.b = "Rakudo";
say $chart.b;
say BarChart.^methods;
```
如果你初始化了 role, 那么它就变为类了。
