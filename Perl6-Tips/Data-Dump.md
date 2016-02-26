title: 'Data::Dump'

date: 2015-08-05 13:46:11

tags: Perl6

categories: Perl 6

------

<blockquote class="blockquote-center">每一颗眼泪 是一万道光 最昏暗的地方也变得明亮
— 一万次悲伤·逃跑计划
</blockquote>

## for Perl 6

你们选对了, 这就是满足你们快速打印数据需要的. 如果你已经安装了 `Term::ANSIColor`的话,输出就会亮瞎你的狗眼!

## 选项

### indent

默认缩进为 2

``` perl
<...>
say Dump({ some => object }, :indent(4));
<...>
```

### max-recursion

默认为 50

``` perl
<...>
say Dump({ some => object }, :max-recursion(3));
<...>
```

### :color( )

默认为 `:color(true)`, 安装了 `Term::ANSIColor`的情况下输出会带颜色. 当为 `:color(False)` 时关闭彩色.

## 用法

``` perl
use Data::Dump;

say Dump(%( 
  key1 => 'value1',
  key256 => 1,
));
```

输出:



``` perl
{
  key1   => "value1".Str,
  key256 => 1.Int,
}
```

注意: 如果你已经安装了 `Term::ANSIColor`, 那么接下来就会让你吃惊了. 所以, 做好思想准备.



## 噢, 你想 `Dump` 你的自定义类?

就是这样, 你们城里人真会玩.

``` perl
use Data::Dump;

class E {
  has $.public;
  has Int $!private = 5;
  method r(Str $a) { };
  method s($b, :$named? = 5) { };
  method e returns Int { say $!private; };
};

say Dump(E.new);
```

输出:

``` perl
E :: (
  $!private => 5.Int,
  $!public  => (Any),

  method e () returns Int {...},
  method public () returns Mu {...},
  method r (Str $a) returns Mu {...},
  method s (Any $b, Any :named($named) = 5) returns Mu {...},
)
```

github: [Data::Dump](https://github.com/tony-o/perl6-data-dump)