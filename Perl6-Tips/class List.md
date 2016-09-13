

```perl6
﻿
my class List is Iterable does Positional { .. }

```

**List** 以序列化的方式存储 items并且潜在是惰性的。

默认列表和数组的索引从 0 开始。

你可以给列表中的元素赋值如果它们是容器的话。使用数组以使列表中的每个元素存储在容器中。

#### Items, Flattening and Sigils
在 Perl 6 中, 把 **List** 赋值给一个标量变量不会丢死信息。不同之处在于迭代通常会把标量中的列表(或其它任何像列表的东西, 例如 Parcel 和 数组)当作单个元素。

```perl6

my @a = 1, 2, 3;
for @a { }      # 三次迭代

```
```perl6

my $s = @a;
for $s { }      # 一次迭代
for @a.item { } # 一次迭代
for $s.list { } # 三次迭代

```
**Lists** 通常会插值(展开)除非它们通过一个 item(scalar)容器访问:(GLR 的影响？)

```perl6

my @a = 1, 2, 3;
my @flat   = @a, @a;           # two elements
my @nested = @a.item, @a.item; # two elements

```
`.item` 通常能被写为 `$( ... )`, 而在数组变量上甚至写为  `$@a`。

#### Methods
##### elems

```perl6

multi sub    elems($list)  returns Int:D
multi method elems(List:D:) returns Int:D

```
返回列表中元素的个数。

##### end

```perl6

multi sub    end($list)  returns Int:D
multi method end(List:D:) returns Int:D

```


返回列表中最后一个元素的索引

##### keys

```perl6

multi sub    keys($list)  returns List:D
multi method keys(List:D:) returns List:D

```
返回一个索引列表( 例如 `0..(@list.elems-1)` )



##### values

```perl6

multi sub    values($list)  returns List:D
multi method values(List:D:) returns List:D

```


返回列表的一份拷贝。

##### kv

```perl6

multi sub    kv($list)  returns List:D
multi method kv(List:D:) returns List:D

```
返回索引和值的交替的列表。 例如：

```perl6

<a b c>.kv

```
返回

```perl6

0, 'a', 1, 'b', 2, 'c'

```
##### pairs

```perl6

multi sub    pairs($list)   returns List:D
multi method pairs(List:D:) returns List:D

```

返回一个 pairs 的列表, 使用索引作为键, 列表值作为键值。
```perl6

<a b c>.pairs   # 0 => 'a', 1 => 'b', 2 => 'c'

```
##### join

```perl6

multi sub    join($separator, *@list) returns Str:D
multi method join(List:D: $separator) returns Str:D

```


把列表中元素当作字符串, 在元素之间插入 `$separator` 并把所有东西连接成单个字符串。

例如:

```perl6

join ', ', <a b c>;     # 'a, b, c'

```
##### map

```perl6

multi sub    map(&code, *@elems) returns List:D
multi method map(List:D: &code) returns List:D

```
对每个元素调用 `&code` 并且把值收集到另外一个列表中并返回它。这个过程是惰性的。 `&code`只在返回值被访问的时候调用。

例子:

```perl6

> ('hello', 1, 22/7, 42, 'world').map: { .WHAT.perl }
Str Int Rat Int Str
> map *.Str.chars, 'hello', 1, 22/7, 42, 'world'
5 1 8 2 5

```
##### grep

```perl6

multi sub    grep(Mu $matcher, *@elems) returns List:D
multi method grep(List:D:  Mu $matcher) returns List:D

```
返回一个使用 `$matcher` 智能匹配的惰性列表。元素是以出现在原列表中的顺序返回的。

例子:

```perl6

> ('hello', 1, 22/7, 42, 'world').grep: Int
1 42
> grep { .Str.chars > 3 }, 'hello', 1, 22/7, 42, 'world'
hello 3.142857 world

```
##### first

```perl6

multi sub    first(Mu $matcher, *@elems)
multi method first(List:D:  Mu $matcher)

```


返回列表中第一个匹配 $matcher 的元素, 当没有匹配值时, 失败。

例子:

```perl6

say (1, 22/7, 42).first: * > 5;     # 42
say $f = ('hello', 1, 22/7, 42, 'world').first: Complex;

```
```perl6

>  ('hello', 1, 22/7, 42, 'world',1+2i).first: Complex;
1+2i
say $f.perl; #  Failure.new(exception => X::AdHoc.new(payload => "No values matched"))

```
##### classify

```perl6

multi sub    classify(&mapper, *@values) returns Hash:D
multi method classify(List:D: &mapper)   returns Hash:D

```


根据映射器把一列值转换成代表那些值的类别的散列; 散列的每个键代表着将要归入列表的一个或多个值的类别。比如字符个数， 元素多少， 键值就是根据 mapper 得到的这个类别下的元素， 它来自于原始列表：

例子：

```perl6

say classify { $_ %% 2 ?? 'even' !! 'odd' }, (1, 7, 6, 3, 2);
# ("odd" => [1, 7, 3], "even" => [6, 2]).hash;

say ('hello', 1, 22/7, 42, 'world').classify: { .Str.chars };
# ("5" => ["hello", "world"], "1" => [1], "8" => [22/7], "2" => [42]).hash

```
##### Bool

```perl6

multi method Bool(List:D:) returns Bool:D

```


如果列表至少含有一个元素则返回 True, 如果列表为空则返回 False。

##### Str

```perl6

multi method Str(List:D:) returns Str:D

```


字符串化列表中的元素并使用空格把这些元素连接起来。( 和 `.join(' ')` 一样)。

##### Int

```perl6

multi method Int(List:D:) return Int:D

```


返回列表中元素的数量(和 `.elems` 一样)

##### pick

```perl6

multi sub    pick($count, *@list) returns List:D
multi method pick(List:D: $count = 1)

```


从调用者身上随机返回 $count 个不重复的元素。 如果 * 作为 $count 传递进来或 $count 大于或等于列表的大小, 那么就以随机序列的方式返回列表中的所有元素。

例子:

```perl6

say <a b c d e>.pick;           # b
say <a b c d e>.pick: 3;        # c a e
say  <a b c d e>.pick: *;       # e d a b c

```
##### roll

```perl6

multi sub    roll($count, *@list) returns List:D
multi method roll(List:D: $count = 1)

```


返回一个 $count 个元素的惰性列表, 每个元素都从列表中随机选择。每个随机选择都是独立的.

如果给 $count 传递了* 号, 则返回一个惰性的, 从原列表中随机选取元素的无限列表。

```perl6

say <a b c d e>.roll;       # b
say <a b c d e>.roll: 3;    # c c e
say roll 8, <a b c d e>;    # b a e d a e b c

```
```perl6

my $random_digits := (^10).roll(*);1;
say $random_digits[^15];    # 3 8 7 6 0 1 3 2 0 8 8 5 8 0 5

```
##### eager

```perl6

multi method eager(List:D:) returns List:D

```
急切地计算列表中的所有元素, 并返回调用者。如果列表标示它是"konw inifinite" 的, 急切求值可以停止在探测到的无限的点上。

##### reverse

```perl6

multi sub    reverse(*@list ) returns List:D
multi method reverse(List:D:) returns List:D

```


以相反的顺序返回一个含有相同元素的列表。

注意 reverse 总是指反转列表中的元素, 如果你想反转字符串中的字符, 那么使用 flip。

例子：

```perl6

say <hello world!>.reverse      #  world! hello
say reverse ^10                 # 9 8 7 6 5 4 3 2 1 0

```
##### rotate

```perl6

multi sub    rotate(@list,  Int:D $n = 1) returns List:D
multi method rotate(List:D: Int:D $n = 1) returns List:D

```


以 $n 个元素旋转列表, 这把原列表分成两部分, 旋转中心就是在这两部分之间:



```perl6

<a b c d e>.rotate(2);   # <c d e a b>
<a b c d e>.rotate(-1);  # <e a b c d>

```
##### sort

```perl6

multi sub    sort(*@elems)      returns List:D
multi sub    sort(&by, *@elems) returns List:D
multi method sort(List:D:)      returns List:D
multi method sort(List:D:, &by) returns List:D

```


列表排序, 最小的元素首先。默认使用 `infix:<cmp>` 排序列表中的元素。

如果提供了 `&by`, 那么它接收两个参数, 它由列表元素对儿调用, 并且应该返回 Order::Increase, Order::Same 或 Order::Decrease.

如果 `&by`只接受一个参数, 那么列表元素是通过 `by($a)  cmp by($b)` 来排序的。`&by` 的返回值被缓存起来,  以使每个列表元素只调用一次 `&by`。

```perl6

say (3, -4, 7, -1, 2, 0).sort;                  # -4 -1 0 2 3 7
say (3, -4, 7, -1, 2, 0).sort: *.abs;           # 0 -1 2 3 -4 7
say (3, -4, 7, -1, 2, 0).sort: { $^b leg $^a }; # 7 3 2 0 -4 -1

```
reduce

```perl6

multi sub    reduce(&with, *@elems)
multi method reduce(List:D: &with)

```


把 `&with` 应用到列表中的第一个和第二个值上, 然后把 `&with`应用到那个计算的结果值和第三个值上, 以此类推。按照那种方式生成单个项。

注意 reduce 是一个隐式的循环。

```perl6

say (1, 2, 3).reduce: * - *;    # -4

```
##### splice

```perl6

multi sub    splice(@list,  $start, $elems?, *@replacement) returns List:D
multi method splice(List:D: $start, $elems?, *@replacement) returns List:D

```


从列表中删除从 $start 索引开始的 $elems 个元素, 返回删除的元素并用 @replacement 来代替它。如果省略了 $elems, 所有从 $index 开始的元素都被删除。

```perl6

my @foo = <a b c d e f g>;
say @foo.splice(2, 3, <M N O P>);       # c d e
say @foo;                               # a b M N O P f g

```
##### pop

```perl6

multi sub    pop(List:D )
multi method pop(List:D:)

```
从列表中移除并返回最后一项。如果列表为空则失败。

```perl6

> my @foo = <a b>;
> @foo.pop;  # b
> pop @foo   # a
> pop @foo   # Element popped from empty list

```
##### push

```perl6

multi sub    push(List:D, *@values) returns List:D
multi method push(List:D: *@values) returns List:D

```


把 @values 添加到列表的末尾, 并返回修改后的列表。 如果列表是无限列表则失败。

例子:

```perl6

my @foo = <a b c>;
@foo.push: 1, 3 ... 11;
say @foo;                   # a b c 1 3 5 7 9 11

```
##### shift

```perl6

multi sub    shift(List:D )
multi method shift(List:D:)

```
从列表中移除并返回第一项元素。 如果列表为空则失败。

```perl6

my @foo = <a b>;
say @foo.shift;     # a
say @foo.shift;     # b
say @foo.shift;     # Element shifted from empty list

```
##### unshift

```perl6

multi sub    unshift(List:D, *@values) returns List:D
multi method unshift(List:D: *@values) returns List:D

```


添加 @values 到列表的开头, 并返回修改后的列表。 如果列表是无限列表则失败。

```perl6

my @foo = <a b c>;
@foo.unshift: 1, 3 ... 11;
say @foo;                   # 1 3 5 7 9 11 a b c

```
##### combinations

```perl6

multi method combinations (List:D: Int:D $of)          returns List:D
multi method combinations (List:D: Range:D $of = 0..*) returns List:D
multi sub    combinations ($n, $k)                     returns List:D

```


Int 变体返回调用者列表所有的 $of-combinations 组合。例如:

```perl6

say .join('|') for <a b c>.combinations(2);

```
打印

```

a|b
a|c
b|c

```
因为  'a', 'b', 'c' 的所有 2-combinations 是  ['a', 'b'], ['a', 'c'], ['b', 'c'].



Range 变体把所有单独的组合组合到单个列表中, 所以:

```perl6

say .join('|') for <a b c>.combinations(2..3);

```
打印

```

a|b
a|c
b|c
a|b|c

```


因为那是一个所有 2-和3-combinations 组合的列表。

子例程 `combinations($n, $k)` 等价于 `(^$n).combinations($k)`, 所以：

```perl6

.say for combinations(4, 2)

```
打印

```

0 1
0 2
0 3
1 2
1 3
2 3

```
##### permutations

```perl6

multi method permutations(List:D:) returns List:D
multi sub    permutations($n)      returns List:D

```
返回列表所有可能的组合作为数组的列表。所以:

```perl6

say .join('|') for <a b c>.permutations

```
打印

```

a|b|c
a|c|b
b|a|c
b|c|a
c|a|b
c|b|a

```


The subroutine form , so

permutations 把所有列表元素当作可区别的, 所以 (1, 1, 2).permutations 仍旧返回 6 个元素的列表, 即使只有 3 个不同的排列。

`permutations($n)` 等价于 `(^$n).permutations`, 所以:

```perl6

.say for permutations 3;

```
打印

```

1 2 3
1 3 2
2 1 3
2 3 1
3 1 2
3 2 1

```
