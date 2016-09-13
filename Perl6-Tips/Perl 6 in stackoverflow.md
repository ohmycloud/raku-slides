[How do I chain to an inline block in Perl 6?](http://stackoverflow.com/questions/37979519/how-do-i-chain-to-an-inline-block-in-perl-6)

我想修改一个数组(我在这个例子中使用了 `splice`, 但是它也可能是修改数组的任何操作)并返回修改后的数组 - 和 `slice` 不一样, slice 返回的是从数组中抠出的项。我可以很容易地通过在数组中存储一个 block 来做到, 就像下面这样:

```perl6
my $1 = -> $a { splice($a,1,3,[1,2,3]); $a };
say (^6).map( { $_ < 4 ?? 0 !! $_ } ).Array;
# [0 0 0 0 4 5]
say (^6).map( { $_ < 4 ?? 0 !! $_ } ).Array.$1;
# [0 1 2 3 4 5]
```

我怎么把由 `$1` 代表的 block 内联到单个表达式中呢？ 下面的解决方法不正确:

```perl6
say (^6).map( { $_ < 4 ?? 0 !! $_ } ).Array.(-> $a { splice($a,1,3,[1,2,3]); $a })
Invocant requires a type object of type Array, but an object instance was passed.  Did you forget a 'multi'?
```

解决方法是添加一个 `&` 符号:

```perl6
say (^6).map( { $_ < 4 ?? 0 !! $_ } ).Array.&(-> $a { splice($a,1,3,[1,2,3]); $a })
# 输出 [0 1 2 3 4 5]
```


## [Getting a positional slice using a Range variable as a subscript](http://stackoverflow.com/questions/38535690/getting-a-positional-slice-using-a-range-variable-as-a-subscript)

```perl6
my @numbers = <4 8 16 16 23 42>;
.say for @numbers[0..2]; # this works
# 4
# 8
# 15

# but this doesn't
my $range = 0..2;
.say for @numbers[$range];
# 16
```

最后的那个下标看起来好像把 `$range` 解释为range中元素的个数(3)。怎么回事?

## 解决方法

使用 `@numbers[|$range]` 把 range 对象展平到列表中。或者在 **Range** 对象上使用绑定来传递它们。

```perl6
# On Fri Jul 2016, gfldex wrote:
my @numbers =  <4 8 15 16 23 42>; my $range = 0..2; .say for @numbers[$range];

# OUTPUT«16»
# expected:
# OUTPUT«4\n 8\n 15»


# 这是对的, 并且还跟 "Scalar container implies item" 规则有关.
# Changing it would break things like the second evaluation here:

my @x = 1..10; my @y := 1..3; @x[@y]
# (2 3 4)

@x[item @y]
# 4

# 注意在签名中 range 可以被绑定给 @y, 而特殊的 Range 可以生成一个像 @x[$(@arr-param)] 的表达式
# 这在它的语义中是不可预期的。

# 同样, 绑定给 $range 也能提供预期的结果
my @numbers =  <4 8 15 16 23 42>; my $range := 0..2; .say for @numbers[$range];
# OUTPUT«4␤8␤15␤»

# 这也是预期的结果, 因为使用绑定就没有标量容器来强制被当成一个 item 了。
# So, all here is working as designed.
```

或者：

```perl6
.say for @numbers[@($range)]
# 4
# 8
# 15
```


绑定到标量容器的符号输出一个东西
可以达到你想要的选择包含：

前置一个 @ 符号来得到单个东西的复数形式：numbers[@$range]; 或者以不同的形式来声明 ragne 变量, 以使它直接工作。
对于后者, 考虑下面的形式:

```perl6
# Bind the symbol `numbers` to the value 1..10:
my \numbers = [0,1,2,3,4,5,6,7,8,9,10];

# Bind the symbol `rangeA` to the value 1..10:
my \rangeA  := 1..10;
# Bind the symbol `rangeB` to the value 1..10:
my \rangeB   = 1..10;

# Bind the symbol `$rangeC` to the value 1..10:
my $rangeC  := 1..10;

# Bind the symbol `$rangeD` to a Scalar container
# and then store the value 1..10 in it:`
my $rangeD   = 1..10;

# Bind the symbol `@rangeE` to the value 1..10:
my @rangeE  := 1..10;

# Bind the symbol `@rangeF` to an Array container and then
# store 1 thru 10 in the Scalar containers 1 thru 10 inside the Array
my @rangeF   = 1..10;

say numbers[rangeA];  # (1 2 3 4 5 6 7 8 9 10)
say numbers[rangeB];  # (1 2 3 4 5 6 7 8 9 10)
say numbers[$rangeC]; # (1 2 3 4 5 6 7 8 9 10)
say numbers[$rangeD]; # 10
say numbers[@rangeE]; # (1 2 3 4 5 6 7 8 9 10)
say numbers[@rangeF]; # (1 2 3 4 5 6 7 8 9 10)
```

绑定到标量容器(`$rangeD`)上的符号总是产生单个值。在 `[...]`下标中单个值必须是数字。
对于 range, 被当作单个数字时, 产生的是 range 的长度。
