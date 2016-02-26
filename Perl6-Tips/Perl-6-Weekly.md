title: Perl 6 Weekly 0816
date: 2015-08-17 16:21:03
tags: Perl6
categories: Perl 6
---

<blockquote class="blockquote-center">你你我我随缘曾邂逅 笑笑喊喊想起总荒缪 进进退退如何能永久 冷冷暖暖都必须承受
— 随缘·温兆伦
</blockquote>

1、[在 Perl 6 中怎样检查文件的时间戳属性？](http://stackoverflow.com/questions/30264548/how-do-i-check-file-timestamp-attributes-in-perl-6)



在 Perl 6 中怎样检查文件的时间戳属性？ 在 Perl 5 中是使用文件测试操作符  [file test operators ](http://perldoc.perl.org/functions/-X.html), 在 Perl 6 中是使用来自于 [`IO::FileTestable` role](http://doc.perl6.org/type/IO::FileTestable) 的方法 (e.g. `.modified`, `.accessed` and `.changed`) 。

例如:

``` perl
my $filename = "sample.txt";
my $seconds_since_epoch = $filename.IO.accessed;
my $readable_timestamp  = DateTime.new($filename.IO.accessed);

say "File '$filename' was last accessed at '$readable_timestamp', which is {$seconds_since_epoch.Num} seconds since the epoch";
```

2、我正尝试生成包含 10 个随机随机序列的 [FASTQ 文件](https://en.wikipedia.org/wiki/FASTQ_format)， 序列由随机品质分数构成。我原来是使用下面的代码，它工作良好:

``` perl
my @seq  = (rand_fa_seq() for ^10);
my @qual = (rand_qual()   for ^10);

@seq.perl.say;
@qual.perl.say;

sub rand_fa_seq
{
    return join("", roll(20,"ACGT".comb));

}

sub rand_qual
{
    return join("", roll(20,"EFGHIJ".comb))
}
```

等价于：

``` perl
sub rand-fa-seq($n = 20) { <A C G T>.roll($n).join }
sub rand-qual($n = 20)   { <E F G H I J>.roll($n).join }

my @seq  = rand-fa-seq() xx 10;
my @qual = rand-qual() xx 10;
```

3、[在 Perl 6 中使用 "列表解析” 生成非平方数列表](http://stackoverflow.com/questions/30414206/list-of-non-squares-using-list-comprehension-in-perl-6)


在 Perl 6 中我怎样使用 "列表解析" 创建一组非平方数? 我在  [Rosetta Code](http://rosettacode.org/wiki/Sequence_of_Non-squares#Perl_6)  那儿看到了如何打印一组非平方数的代码：

``` perl
sub nth_term (Int $n) { $n + round sqrt $n }

say nth_term $_ for 1 .. 22;
```

目前为止我看到的最接近的东西是使用  `for` 关键字。 但是因为这实际上仅仅是一个内联（inline）循环，我认为这从技术上来讲并不是列表解析，尽管它看起来相似：

``` perl
my @y = ($_**2 + 1 for 1 .. 10);
```

但是，我真正想知道是否有一种 “列表解析 “ 的方法来创建可在数学上描述的诸如非平方数的列表。这儿有一个我用来创建一组非平方数的方法（直到 30）：

``` perl
my @non_squares = grep {sqrt($_) != floor(sqrt($_))}, 1 .. 30;
```

我怎样用列表解析来实现它呢？



实际上， 你的例子  `my @y = ($_**2 + 1 for 1 .. 10);`  是 Perl 6 方式写成的列表解析。你还可以添加一个条件测试， 就像 [Perl 6 design document S04](http://design.perl6.org/S04.html#Loop_statements) 中建议的那样：

> 为了轻松地书写列表解析， 循环语句修饰符允许包含单个条件语句修饰符：
> 
> ...
> 
> ``` perl
> sub odd(Int $n) {return $n % 2}
> @evens = ($_ * 2 if .&odd for 0..100);
> ```

这个就是怎样写一个 Perl 6 列表解析的非平方数（直到 30）：

``` perl
my @non_squares = ($_ if .sqrt != .sqrt.Int for 1 .. 30);
```

------

一丢丢解释：在每次 for 循环迭代中， 从 1 到 30 这个范围中的当前数字会被赋值给默认变量 `$_`（等价于 it）。没有调用者的方法调用会默认在 “it" 身上调用（例如 `.sqrt` 等价于 `$_.sqrt`）。 所以，对于 1到30中的每一个数字，它的平方根被检查以查看它是否有非整数平方根。 如果是真， 那它就被包含在列表中。



4、[Perl 6 中的 Print 函数和冒号](http://stackoverflow.com/questions/30982697/print-and-colon-in-perl-6)

我想知道在 Perl 6 中冒号与方法和函数调用有什么关系。

我在 [Perl6 spec test (S32-io)](https://github.com/perl6/roast/blob/master/S32-io/copy.t) 中看到了这个(我添加了注释):

``` perl
$fh.print: "0123456789A";   # prints '0123456789A' to the file
```

据我所知，这等价于：

``` perl
$fh.print("0123456789A");   # prints '0123456789A' to the file
```

这两种方式看起来都接收多个参数而且展平列表也没问题：

``` perl
$fh.print: "012", "345", "6789A";   # prints '0123456789A' to the file
$fh.print("012", "345", "6789A");   # prints '0123456789A' to the file

my @a = <012 345 6789A>;

$fh.print(@a);   # prints '0123456789A' to the file
$fh.print: @a;   # prints '0123456789A' to the file
```

存在这两种语法一定有某种原因。 使用这种或另一种语法有某种理由吗？

我还注意到，当作为方法使用时， 我们不得不使用带有 `:` 或 `()`的 print：

``` perl
$fh.print(@a);   # Works
$fh.print: @a;   # Works!
$fh.print @a;    # ERROR!
```

当使用带冒号的 print 函数时，还有一些有意思的行为。 在这种情况下, ： 和 () 不等价：

``` perl
print @a;  # Prints '0123456789A' (no newline, just like Perl 5)
print(@a); # Ditto
print: @a; # Prints '012 345 6789A' followed by a newline (at least in REPL)

print  @a, @a; # Error (Two terms in a row)
print: @a, @a; # Prints '012 345 6789A 012 345 6789A' followed by a newline (in REPL) 
```

然后我尝试在脚本文件中使用print。这对于打印到标准输出有效：

``` 
print @a;

```

然而， 这不会打印到标准输出：

``` 
print: @a, @a;

```

但是方法版本的工作良好：

``` perl
$fh.print: @a, @a; # Prints '0123456789A0123456789A' to the file
```

我感觉我已经理解了这个， 但是不能用语言表达出来。有人可以解释下使用 print 的这些变化吗。 还有， 这些行为会因为  Great List Refactor 而改变吗？

------

Answer：

使用冒号代替圆括号的一个主要原因是通过移除一组圆括号，它能使代码更清晰。在其它方面它们真的一样。

当你使用 `print: @a` ， 那你真正在做的就是在行上放置一个标签， 并让 @a 落进去（fall-through）。这在 REPL 中会调用带有值的 say 方法。

如果你没有在方法调用中使用括号或冒号，， 那么方法会以无参数方式调用。

------

你可以交换方法的顺序，还有调用者，如果你使用冒号的话。

``` perl
say $*ERR: 'hello world'; # $*ERR.say('hello world')
```

| 我刚刚确认了， 就像你说的， `print: @a` 就是 `label: @a`,   `label` 可以是任何东西. – [Christopher Bottoms](http://stackoverflow.com/users/215487/christopher-bottoms) [Jun 26 at 14:12](http://stackoverflow.com/questions/30982697/print-and-colon-in-perl-6#comment50169331_30988281) |                                          | 
| ---------------------------------------- | ---------------------------------------- | 
|                                          | 换句话说，冒号能代替方法调用的圆括号，但不能代替子例程调用。 – [Christopher Bottoms](http://stackoverflow.com/users/215487/christopher-bottoms) [Jun 26 at 14:12](http://stackoverflow.com/questions/30982697/print-and-colon-in-perl-6#comment50169347_30988281) | 

5、[排序散列键值对儿](http://stackoverflow.com/questions/31745631/sorting-hash-kv-pairs)

``` perl
my %hash =
    two   => 2,
    three => 3,
    one   => 1,
;

for %hash.sort(*.key)».kv -> ($key, $value) {
    say "'$key' => '$value'";
}
```

 `%hash.sort({.key})».kv` 和上面的  `sort` 等价吗?

为什么这个 sort 没有 hyper `»`  提示就不会工作?

------

这个 [`sort`](http://doc.perl6.org/routine/sort)方法返回一个 [Pairs](http://doc.perl6.org/type/Pair) 的列表。

因为在列表身上调用  [`.kv`](http://doc.perl6.org/routine/kv) 会返回一个索引, Pair 列表, 这不是你想要的; 你不能单单在列表身上调用   [`.kv`](http://doc.perl6.org/routine/kv) 。所以你必须通过在每个 Pair 身上调用 .kv 方法分别从列表中的   [Pair](http://doc.perl6.org/type/Pair) 中取出键和值, 这正是 ».kv 所做的。

你还可以使用 [`.map(*.kv)`](http://doc.perl6.org/routine/map) 代替。

`».kv` 语法允许把工作展开到多个线程中执行, 如果那样做有意义的话。



(当前的 Rakudo仅以半随机的顺序工， 以防止人们错误地使用该特性 )

------

通过在签名中使用副词以提取属性， 这是另一种 loop 写法：

``` perl
for %hash.sort -> (:$key, :$value) {
  say "'$key' => '$value'";
}

for %hash.sort -> $pair (:$key, :$value) {
  say $pair;
  say $key === $pair.key and $value === $pair.value; # True␤
}

# :$key is short for :key($key)
for %hash.sort -> (:key($k), :value($v)) {
  say "'$k' => '$v'";
}
```

这对其它没有方法创建一组它们公用属性的对象有用：

``` perl
class C { has $.a; has $.b; has $.c; has $!private-value }
my $c = 5;
my $obj = C.new(:a<A>,:b(1),:$c);

given $obj -> ( :$a, :b($b), :$c) ) {
  say "$a $b $c";   # A 1 5
}

# ignore $.a by using an unnamed scalar
given $obj -> ( :a($), :$b, :$c ) { ... }

# places any unspecified public attributes in %others
given $obj -> ( :$a, :$b, *%others ) {
  .say for keys %others; # c␤
}

# 忽略任何未指定的属性
# useful to allow subclasses to add more attributes
# 或仅仅丢弃掉任何你不关心的值
given $obj -> ( :$a, :$b, *% ) { ... }

# 失败，因为它没有处理公用的 c 属性
# in the sub-signature
given $obj -> ( :$a, :$b ) { ... }
```

关于签名能做什么，那只是开始。



所有下面的，在子例程和方法签名中都是被允许的，非强制性的， 对于这个例子杀伤力过大。这在 multi subs 和 multi methods 中对于限制可能的候选者真的很有用。

``` perl
for 'one' => 1, 1/3
->
  # Type is an alias to the object type
  ::Type Any $_ # Any is the default type requirement

  # the public attributes of the object
  (
    ::A-Type Any :key(   :numerator(   $a ) ),
    ::B-Type Any :value( :denominator( $b ) ) where $b >= 1,
  )
{
  my Type $obj = $_; # new variable declared as having the same type
  my A-Type $new-a = $a;
  my B-Type $new-b = $b;

  # could have used $_.^name or .^name instead of Type.^name
  # so you don't actually have to add the alias to the signature
  # to get the name of the arguments type
  say Type.^name, ' ', $_;
  say '  ', A-Type.^name, ' ', $a;
  say '  ', B-Type.^name, ' ', $b;
}

Pair one => 1
  Str one
  Int 1
Rat 0.333333
  Int 1
  Int 3
```

------

至于使用  [`.sort({.key})`](http://doc.perl6.org/routine/sort), 恩, 那从根本上来说是同一个东西, 因为 [`sort`](http://doc.perl6.org/routine/sort)  在那儿接受任何 [Callable](http://doc.perl6.org/type/Callable) 

我要指出, 你甚至不需要为 [`sort`](http://doc.perl6.org/routine/sort)  提供参数, 因为它默认比你给它的东西智能。

Perl 6 有很多创建和访问 [Callable](http://doc.perl6.org/type/Callable)  东西的方式。所以任何下面一种都可以工作：

``` perl
*.key
{ .key } # { $_.key }
-> $_ { .key } # basically what the previous line turns into
{ $^placeholder-var.key }
sub ($_) { .key }
&a-subroutine-reference # you would have to create the subroutine though
```

还有， 因为所有普通的操作符实际上都是子例程，你可以在需要  [Callable](http://doc.perl6.org/type/Callable) 的其它地方使用它们：

``` perl
&infix:<+> # the subroutines responsible for the numeric addition operator
&[+] # ditto

&prefix:<++>
&postfix:<++>

# etc
```