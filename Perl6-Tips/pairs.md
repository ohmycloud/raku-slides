# Pair

```perl6
class Pair does Associative { ... }
```

*Pair* 由两部分组成，一个键(key)和一个值(value)。**Pair**s 可以看作是 **Hash**es 的原子单位，并且 **Pair** 也能用于具名形参和具名实参中。

创建 **Pair**s 有多种语法：

```perl6
Pair.new('key','value')  # 一本正经的方式
'key' => 'value'        # this...
:key<value>             # ...means the same as this
:key<value1 value2>     # But this is  key => <value1 value2>
:$foo                   # short for  foo => $foo
:foo(127)               # short for  foo => 127
:127foo                 # the same   foo => 127
```

还有两个变体:

```perl6
:key                    # same as   key => True
:!key                   # same as   key => False
```

交换键和值：

```perl6
my $p = (6 => 'Perl').antipair;
say $p.key;         # Perl
say $p.value;       # 6
```