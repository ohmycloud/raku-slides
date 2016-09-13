

定义为 

``` perl
multi roundrobin(List:D: --> Seq)
```

用法

``` perl
roundrobin LISTS
```

## Round-Robin Merge Two Lists of Different Length

**roundrobin**很像 **zip**。不同之处是, `roundrobin`不会在用光元素的列表上停止而是仅仅跳过任何未定义的值：

``` perl
my @a = 1;
my @b = 1..2;
my @c = 1..3;

for flat roundrobin(@a, @b, @c) -> $x { $x.say } # 1,1,1,2,2,3
```

它只是跳过了未定的值, 直到最长的那个列表的元素用完。

``` perl
my @list1 = 'a' .. 'h';
my @list2 = <x y>;
say flat roundrobin @list1, @list2; # a x b y c d e f g h
```

**roundrobin** 返回的是一列 `Seq`, 所以使用 flat 进行展开。

``` perl
my @list1 = 'a' .. 'h';
my @list2 = <x y>;
my $n = 3;
say flat roundrobin @list1.rotor($n - 1, :partial), @list2;

# >>>
# OUTPUT«a b x c d y e f g h»
```

`.rotor`方法把一个列表分解为子列表。



## 交叉两个字符串中的字符

``` perl
#Given:
u = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
l = 'abcdefghijklmnopqrstuvwxyz'

#Wanted:
'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz'
```

方法一：

``` perl
say join '', (u.comb Z l.comb);
```

方法二:

``` perl
say [~] (u.comb Z l.comb);
```

方法三

``` perl
say [~] flat (u.comb Z l.comb);
```
