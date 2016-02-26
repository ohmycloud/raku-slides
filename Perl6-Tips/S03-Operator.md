title: S03-Operator

date: 2015-08-14 12:59:26

tags: Perl6

categories: Perl 6

---

<blockquote class="blockquote-center">但我知道 都是我不好 你越不计较 越显得我渺小

— 我知道你都知道·薛之谦

</blockquote>

#### 操作符优先级

[S03-operators/arith.t lines 46–342](https://github.com/perl6/roast/blob/master/S03-operators/arith.t#L46-L342)

[S03-operators/precedence.t  lines 5–200](https://github.com/perl6/roast/blob/master/S03-operators/precedence.t#L5-L200)

Perl 6 拥有和 Perl 5 同等数量的优先级级别，但是它们散布在不同的地方。这儿，我们列出了从最紧凑到最松散的级别，每一级别还有几个例子：

最高优先级到最低优先级：

``` perl6

A  Level             Examples
=  =====             ========
N  Terms             42 3.14 "eek" qq["foo"] $x :!verbose @$array
L  Method postfix    .meth .+ .? .* .() .[] .{} .<> .«» .:: .= .^ .:
N  Autoincrement     ++ --
R  Exponentiation    **
L  Symbolic unary    ! + - ~ ? | || +^ ~^ ?^ ^
L  Multiplicative    * / % %% +& +< +> ~& ~< ~> ?& div mod gcd lcm
L  Additive          + - +| +^ ~| ~^ ?| ?^
L  Replication       x xx
X  Concatenation     ~
X  Junctive and      & (&) ∩
X  Junctive or       | ^ (|) (^) ∪ (-)
L  Named unary       temp let
N  Structural infix  but does <=> leg cmp .. ..^ ^.. ^..^
C  Chaining infix    != == < <= > >= eq ne lt le gt ge ~~ === eqv !eqv (<) (elem)
X  Tight and         &&
X  Tight or          || ^^ // min max
R  Conditional       ?? !! ff fff
R  Item assignment   = => += -= **= xx= .=
L  Loose unary       so not
X  Comma operator    , :
X  List infix        Z minmax X X~ X* Xeqv ...
R  List prefix       print push say die map substr ... [+] [*] any Z=
X  Loose and         and andthen
X  Loose or          or xor orelse
X  Sequencer         <== ==> <<== ==>>
N  Terminator        ; {...} unless extra ) ] }

```

下面使用的两个 `!` 符号通常表示任意一对儿拥有相同优先级的操作符， 上表指定的二元操作符的结合性解释如下(其中 A 代表**结合性**， associativities )：

``` perl6

    结合性     Meaning of $a ! $b ! $c
    =====     =========================
L   left      ($a ! $b) ! $c
R   right     $a ! ($b ! $c)
N   non       ILLEGAL
C   chain     ($a ! $b) and ($b ! $c)
X   list      infix:<!>($a; $b; $c)

```

对于一元操作符， 这解释为:

``` perl6

    结合性     Meaning of !$a!
    =====     =========================
L   left      (!$a)!
R   right     !($a!)
N   non       ILLEGAL

```

(在标准 Perl 中没有能利用结合性的一元操作符，因为在每一优先级级别中， 标准操作符要么一贯地是前缀，要么是后缀。)

注意列表结合性（X）只在同一操作符之间有效。如果两个拥有不同列表结合性的操作符拥有相同的优先级，它们彼此间就会被认为是非结合性的，必须使用圆括号来消除歧义。

[S03-operators/precedence.t lines 211–245](https://github.com/perl6/roast/blob/master/S03-operators/precedence.t#L211-L245)

例如， `X` 交叉操作符和 `Z` **拉链操作符**都有 "list infix" 优先级，但是：

``` perl6
@a X @b Z @c
```

是非法的，必须写成下面的任意一种：

``` perl6
(@a X @b) Z @c
@a X (@b Z @c)
```



如果仅有的列表结合性操作符的实现是二进制的, 那么它会被当作是右结合性的。
标准的优先级层级尝试和它们的结合性相一致, 但是用户定义的操作符和优先级级别可以在同一优先级级别上混合右结合性和左结合性操作符。如果在同一个表达式中不小心使用了有冲突的操作符, 那么操作符彼此之间会被认为是非结合性的, 并且必须使用圆括号来消除歧义。

如果你没有在上面看见你喜欢的操作符, 下面的章节会包含所有按优先级排列的操作符。这儿描述了基本的操作符。

#### Term precedence

这实际上不真的是优先级, 但是它在这里是因为没有操作符的优先级比 term 高. 查看 S02 获取各种 terms 的更详尽的描述. 这里有一些例子:

- Int 字面量

```
42
```

- Num 字面量

```
3.14
```

- 不能插值的 Str 字面量

```
'$100'
```

- 能插值的 Str 字面量

```
"Answer = $answer\n"
```

- 通用的 Str 字面量

```
q["$100"]
qq["$answer"]
```

- Heredoc

```
qq:to/END/
    Dear $recipient:
    Thanks!
    Sincerely,
    $me
    END
```

- 数组构造器

``` perl
    [1,2,3]
```

 `[ ]` 里面提供了列表上下文. 技术上讲, 它实际上提供了一个  `semilist` 上下文, 即一系列分号分割的语句, 每条语句都在列表上下文中解释, 然后被连接成最终的列表.

- 散列构造器

``` perl6

    { }
    { a => 42 }

```

`{ }` 里面要么是空的, 要么是以 pair 或 散列 开头的单个列表, 否则你必须使用 `hash( )` 或 `%( )` 代替.

- Closure

```
{ ... }
```

如果出现在语句那儿, 会立即执行。 否则会延迟内部作用域的求值。

- 捕获构造器

```
\(@a,$b,%c)
```

代表还不知道它的上下文的参数列表的抽取,


- 符号化变量

```
$x
@y
%z
$^a
$?FILE
&func
&div:(Int, Int --> Int)
```

- 符号作为上下文化函数

```
$()
@()
%()
&()
```

- quote-like 记号中的 Regexes

```
/abc/
rx:i[abc]
s/foo/bar/
```

- 转换

```
tr/a..z/A..Z/
```

注意范围使用 `..` 而非 `-`.

- 类型名

```
Num
::Some::Package
```

- 由圆括号环绕的子表达式

```
(1+2)
```

- 带括号的函数调用

```
a(1)
```

一个项后面立即跟着一个圆括号化的表达式总是被当作函数调用，　即使那个标识符也含有前缀意义，　所以那种情况下你从来不用担心优先级。因此：

```
not($x) + 1         # means (not $x) + 1
```

- Pair 构造器

```
:limit(5)
:!verbose
```

- 签名字面量

```
:(Dog $self:)
```

- 使用隐式调用者的方法调用

```
.meth       # call on $_
.=meth      # modify $_
```

注意这只能出现在需要项(term)的地方。需要后缀的地方它就是后缀。如果需要中缀操作符（即, 在项后面, 之间是空格）, .meth 就是语法错误。(.meth 形式在那儿是被允许的因为有一个和方法调用形式在语义上等价但是允许在 = 号和方法名之间于空格存在的特殊 .= 中缀赋值操作符)。

- Listop (leftward)

```
4,3, sort 2,1       # 4,3,1,2
```

就像 Perl 5 中一样, 列表操作符对于它左侧的表达式看起来像一个项(term), 所以它比左侧的逗号绑定的紧凑点, 比右侧的逗号绑定的松散点。-- 查看下面的列表前缀优先级。

#### 方法后缀优先级

所有的方法后缀都以一个点开头, 尽管对于下标来说, 点号是可选的. 因为这些是最紧密的操作符,  你可以看到一系列方法调用作为单独的项, 这个项仅仅要表达一个复杂的名字.

- 标准的单个分发方法调用

```
$obj.meth
```

- 标准单个分发方法调用的变体

```
$obj.+meth
$obj.?meth
$obj.*meth
```

除了普通的 `.` 方法调用之外, 还有 `.*`, `.?`, 和 `.+` 变体来控制如何处理多个同名的相关方法.

- 类限定的方法调用

```
$obj.::Class::meth
$obj.Class::meth    # same thing, 假设预先定义了 Class
```

就跟 Perl 5 一样, 告诉分发器(dispatcher)从哪个类开始搜索, 而不正好是那个被调用的方法。

- 可变方法调用

```
$obj.=meth
```
.= 操作符执行了对左侧对象的就地修改。

- 元方法调用

```
$obj.^meth
```

`.^` 操作符调用了类的元方法(class metamethod); **foo.^bar** 是 `foo.HOW.bar` 的简写。

- 像方法一样的后环缀

```
$routine.()
$array.[]
$hash.{}
$hash.<>
$hash.«»
```

不带点的这些形式有同样的优先级.

- 带点形式的其它后缀操作符

```
$x.++         # postfix:<++>($x)
```

- 带点形式的其它前缀操作符

```
$x.:<++>       # prefix:<++>($x)
```

- 有一个特殊的非中缀操作符 infix:<.> 所以

```
$foo . $bar
```

总是会返回编译时错误来标示用户应该使用中缀操作符 infix<~> 代替。这用于捕获正在学习 Perl 6 的 Perl 5 程序员可能会犯的错误。

#### 自增优先级

S03-operators/overflow.t lines 7–266  

S03-operators/autoincrement.t lines 9–51  

S03-operators/increment.t lines 7–127  

As in C, these operators increment or decrement the object in question either before or after the value is taken from the object, depending on whether it is put before or after. Also as in C, multiple references to a single mutating object in the same expression may result in undefined behavior unless some explicit sequencing operator is interposed. See "Sequence points".

As with all postfix operators in Perl 6, no space is allowed between a term and its postfix. See S02 for why, and for how to work around the restriction with an "unspace".

As mutating methods, all these operators dispatch to the type of the operand and return a result of the same type, but they are legal on value types only if the (immutable) value is stored in a mutable container. However, a bare undefined value (in a suitable Scalar container) is allowed to mutate itself into an Int in order to support the common idiom:

```
say $x unless %seen{$x}++;
```

Increment of a Str (in a suitable container) works similarly to Perl 5, but is generalized slightly. A scan is made for the final alphanumeric sequence in the string that is not preceded by a '.' character. Unlike in Perl 5, this alphanumeric sequence need not be anchored to the beginning of the string, nor does it need to begin with an alphabetic character; the final sequence in the string matching <!after '.'> <rangechar>+ is incremented regardless of what comes before it.

S03-operators/autoincrement.t lines 52–192  

S03-operators/autoincrement.t lines 193–297  

The <rangechar> character class is defined as that subset of characters that Perl knows how to increment within a range, as defined below.

The additional matching behaviors provide two useful benefits: for its typical use of incrementing a filename, you don't have to worry about the path name or the extension:

```
$file = "/tmp/pix000.jpg";
$file++;            # /tmp/pix001.jpg, not /tmp/pix000.jph
```

Perhaps more to the point, if you happen to increment a string that ends with a decimal number, it's likely to do the right thing:

```
$num = "123.456";
$num++;             # 124.456, not 123.457
```

Character positions are incremented within their natural range for any Unicode range that is deemed to represent the digits 0..9 or that is deemed to be a complete cyclical alphabet for (one case of) a (Unicode) script. Only scripts that represent their alphabet in codepoints that form a cycle independent of other alphabets may be so used. (This specification defers to the users of such a script for determining the proper cycle of letters.) We arbitrarily define the ASCII alphabet not to intersect with other scripts that make use of characters in that range, but alphabets that intersperse ASCII letters are not allowed.

If the current character in a string position is the final character in such a range, it wraps to the first character of the range and sends a "carry" to the position left of it, and that position is then incremented in its own range. If and only if the leftmost position is exhausted in its range, an additional character of the same range is inserted to hold the carry in the same fashion as Perl 5, so incrementing '(zz99)' turns into '(aaa00)' and incrementing '(99zz)' turns into '(100aa)'.

``` perl
> my $a = "99zz"
> $a++           # 99zz
> $a++           # 100aa

> my $b = 'zz99'
> $b++           # zz99
> $b++           # aaa00
```

The following Unicode ranges are some of the possible rangechar ranges. For alphabets we might have ranges like:

```
A..Z        # ASCII uc
a..z        # ASCII lc
'Α'..'Ω'    # Greek uc
α..ω        # Greek lc (presumably skipping C<U+03C2>, final sigma)
א..ת        # Hebrew
  etc.      # (XXX out of my depth here)
```

``` perl
> my @a =  'Α'..'Ω'  # Α Β Γ Δ Ε Ζ Η Θ Ι Κ Λ Μ Ν Ξ Ο Π Ρ ΢ Σ Τ Υ Φ Χ Ψ Ω
```

For digits we have ranges like:

``` perl
    0..9        # ASCII
    ٠..٩        # Arabic-Indic
    ०..९        # Devangari
    ০..৯        # Bengali 孟加拉语
    '੦'..'੯'    # Gurmukhi
    ૦..૯        # Gujarati
    ୦..୯        # Oriya
```

etc.

``` perl
> my @b =    '੦'..'੯'   #  ੦ ੧ ੨ ੩ ੪ ੫ ੬ ੭ ੮ ੯
```

Certain other non-script 0..9 ranges may also be incremented, such as

``` perl
    ⁰..⁹        # 上标 (note, cycle includes latin-1 chars)
    '₀'..'₉'    # 下标
    ０..９      # fullwidth digits
```

``` perl
> my @f = '₀'..'₉' # ₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉
```

Ranges that are open-ended simply because Unicode has not defined codepoints for them (yet?) are counted as rangechars, but are specifically excluded from "carry" semantics, because Unicode may add those codepoints in the future. (This has already happened with the circled numbers, for instance!) For such ranges, Perl will pretend that the characters are contiguous for calculating successors and predecessors, and will fail if you run off of either end.

``` perl
    Ⅰ..Ⅻ        # clock roman numerals uc
    ⅰ..ⅻ        # clock roman numerals lc
    ⓪..㊿       # circled digits/numbers 0..50
    ⒜..⒵        # parenthesized lc
    ⚀..⚅        # die faces 1..6
    '❶'..'❿'        # dingbat negative circled 1..10
```

etc.



Note: for actual ranges in Perl you'll need to quote the characters above:

``` perl
    '⓪'..'㊿'   # circled digits/numbers 0..50
```

``` perl
> my @d = '⓪'..'㊿'
```

``` perl
⓪ ⓫ ⓬ ⓭ ⓮ ⓯ ⓰ ⓱ ⓲ ⓳ ⓴ ⓵ ⓶ ⓷ ⓸ ⓹ ⓺ ⓻ ⓼ ⓽ ⓾ ⓿ ─ ━ │ ┃ ┄ ┅ ┆ ┇ ┈ ┉ ┊ ┋ ┌ ┍ ┎ ┏ ┐ ┑ ┒ ┓ └ ┕ ┖ ┗ ┘ ┙ ┚ ┛ ├ ┝ ┞ ┟ ┠ ┡ ┢ ┣ ┤ ┥ ┦ ┧ ┨ ┩ ┪ ┫ ┬ ┭ ┮ ┯ ┰ ┱ ┲ ┳ ┴ ┵ ┶ ┷ ┸ ┹ ┺ ┻ ┼ ┽ ┾ ┿ ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋ ╌ ╍ ...
```

``` perl
> my @e = '❶'..'❿' # ❶ ❷ ❸ ❹ ❺ ❻ ❼ ❽ ❾ ❿
```

If you want to future-proof the top end of your range against further Unicode additions, you may specify it as "whatever":

```
'⓪'..*      # circled digits/numbers up to current known Unicode max
```

Since these non-carrying ranges fail when they run out, it is recommended that you avoid non-carrying rangechars where, for instance, you need to keep generating unique filenames. It's much better to generate longer strings via carrying rangechars in such cases.

Note that all character increments can be handled by lookup in a single table of successors since we've defined our ranges not to overlap.

Anyway, back to string increment. Only rangechars may be incremented; we can't just increment unrecognized characters, because we have to locate the string's final sequence of rangechars before knowing which portion of the string to increment.

Perl 6 also supports Str decrement with similar semantics, simply by running the cycles the other direction. However, leftmost characters are never removed, and the decrement fails when you reach a string like "aaa" or "000".

Increment and decrement on non-Str types are defined in terms of the .succ and .pred methods on the type of object in the Scalar container. More specifically,

```
++$var
--$var
```

are equivalent to

```
$var.=succ
$var.=pred
```

If the type does not support these methods, the corresponding increment or decrement operation will fail. (The optimizer is allowed to assume that the ordinary increment and decrement operations on integers will not be overridden.)

Increment of a Bool (in a suitable container) turns it true. Decrement turns it false regardless of how many times it was previously incremented. This is useful if your %seen hash is actually a SetHash, in which case decrement actually deletes the key from the SetHash.

Increment/decrement of an undefined Numeric, Cool, or Any variable sets the variable to 0 and then performs the increment/decrement. Hence a postincrement returns 0 the first time:

```
my $x; say $x++;    # 0, not Any
```

Autoincrement   prefix:<++> or postfix:<++> operator

```
$x++
++$x;
```

Autodecrement prefix:<--> or postfix:<--> operator

```
$x--
--$x
```

Exponentiation precedence 幂优先级

infix:<**> exponentiation operator

```
$x ** 2
```

Unless the right argument is a non-negative integer the result is likely to be an approximation. If the right argument is of an integer type, exponentiation is at least as accurate as repeated multiplication on the left side's type. (From which it can be deduced that Int**UInt is always exact, since Int supports arbitrary precision. Rat**UInt is accurate to the precision of Rat.) If the right argument is an integer represented in a non-integer type, the accuracy is left to implementation provided by that type; there is no requirement to recognize an integer to give it special treatment. (Coercion of an integer Str via Cool is likely to do the right thing, however.)

Symbolic unary precedence

prefix:<?>, 布尔上下文

```
?$x
```

Evaluates the expression as a boolean and returns True if expression is true or False otherwise. See "so" below for a low-precedence alternative.

prefix:<!>, boolean negation

S03-operators/context-forcers.t lines 162–223  

```
!$x
```

Returns the opposite of what ? would. See "not" below for a low-precedence alternative.

prefix:<+>, numeric context

```
+$x
```

Unlike in Perl 5, where + is a no-op, this operator coerces to numeric context in Perl 6. (It coerces only the value, not the original variable.) For values that do not already do the Numeric role, the narrowest appropriate type of Int, Rat, Num, or Complex will be returned; however, string containing two integers separated by a / will be returned as a Rat (or a FatRat if the denominator overflows an int64). Exponential notation and radix notations are recognized.

Only leading and trailing whitespace are allowed as extra characters; any other unrecognized character results in the return of a failure.

prefix:<->, numeric negation

S03-operators/context-forcers.t lines 100–111  

```
-$x
```

Coerces to numeric and returns the arithmetic negation of the resulting number.

prefix:<~>, 字符串上下文

```
~$x
```

Coerces the value to a string, if it does not already do the Stringy role. (It only coerces the value, not the original variable.) As with numerics, it is guaranteed only to coerce to something Stringy, not necessarily Str.

prefix:<|>,  将对象展开为参数列表

```
| $capture
```

把Capture 值的内容(或 Capture-like)插值进当前的参数列表中, 就像它们被字面地指定那样。

prefix:<||>,  将对象展开为分号列表

```
|| $parcel
```

把 Parcel(或其它有顺序的值)的元素插值到当前参数列表中就像它们被字面地指定一样, 由分号分割, 即, 以多维级别。在列表中的列表上下文之外使用该操作符是错误的; 换句话说, 它必须被绑定到 `**`(slice)参数上而非吞噬参数`*`上。

prefix:<+^>, numeric bitwise negation

```
+^$x
```

Coerces to Int and then does bitwise negation on the number, returning an Int. (In order not to have to represent an infinitude of 1's, it represents that value as some negative in 2's complement form.)

prefix:<~^>, string bitwise negation

```
~^$x
```

Coerces NFG strings to non-variable-encoding string buffer type (such as buf8, buf16, or buf32) and then does negation (complement) on each bit of each integer element, returning a buffer of the same size as the input.

The use of coercion probably indicates a design error, however. This operator is distinguished from numeric bitwise negation in order to provide bit vectors that extend on the right rather than the left (and always do unsigned extension).

prefix:<?^>, boolean negation

```
?^$x
```

Coerces to boolean and then flips the bit. (Same as !.)

prefix:<^>, upto operator

S03-operators/context-forcers.t lines 224–255  

```
^$limit
```

Constructs a range of 0 ..^ +$limit. See "Range and RangeIter semantics".

Multiplicative precedence 乘法优先级

infix:<*>

```
$x*$y
```

Multiplication, resulting in the wider type of the two.

infix:</>

```
$numerator / $denominator
```

Performs division of real or complex numbers, returning a real or complex number of appropriate type.

If both operands are of integer or rational type, the operator returns the corresponding Rat value (except when the result does not fit into a Rat, as detailed in S02).

Otherwise, if either operand is of Complex type, converts both operands to Complex and does division returning Complex.

Otherwise, if either operand is of Num type, converts both operands to Num and does division returning Num. If the denominator is zero, returns an object representing either +Inf, NaN, or -Inf as the numerator is positive, zero, or negative. (This is construed as the best default in light of the operator's possible use within hyperoperators and junctions. Note however that these are not actually the native IEEE non-numbers; they are undefined values of the "unthrown exception" type that happen to represent the corresponding IEEE concepts, and if you subsequently try to use one of these values in a non-parallel computation, it will likely throw an exception at that point.)

infix:<div>, 整除

```
$numerator div $denominator
```

Dispatches to the infix:<div> multi most appropriate to the operand types, returning a value of the same type. Not coercive, so fails on differing types.

Policy on what to do about division by zero is up to the type, but for the sake of hyperoperators and junctions those types that can represent overflow (or that can contain an unthrown exception) should try to do so rather than simply throwing an exception. (And in general, other operators that might fail should also consider their use in hyperops and junctions, and whether they can profitably benefit from a lazy exception model.)

In general, div should give the same result as

```
$x div $y == floor($x/$y)
```

but the return value should be the same type as $x.

This identity stops holding when $x/$y degrades to a Num and runs into precision limits. A div operation on two Int objects must always be done precisely.

``` perl
> 3 div 2     # 1
> 13 div 2    # 6
```

而

``` perl
> 13 div 2.4
```

报错：

``` perl
Cannot call infix:<div>(Int, Rat); none of these signatures match:
    (Int:D \a, Int:D \b)
    (int $a, int $b --> int)
  in block <unit> at <unknown file>:1
```

infix:<%>, modulo

```
$x % $y
```

If necessary, coerces non-numeric arguments to an appropriate Numeric type, then calculates the remainder, which is defined as:

```
$x % $y == $x - floor($x / $y) * $y
```

infix:<%%>, is divisible by

```
$x %% $y
```

Performs a % and then tests the result for 0, returning Bool::True if the $x is evenly divisible by $y, and Bool::False otherwise.

You may use !%% to mean "not divisible by", though % itself generally has the same effect.

infix:<mod>, integer modulo

```
$x mod $y
```

Dispatches to the infix:<mod> multi most appropriate to the operand types, returning a value of the same type. Not coercive, so fails on differing types.

This should preserve the identity

```
$x mod $y == $x - ($x div $y) * $y
```

infix:['+&'], numeric bitwise and

```
$x +& $y
```

Converts both arguments to Int and does a boolean AND between corresponding bits of each integer, returning an Int result.

infix:['+<'], numeric shift left

```
$integer +< $bits
```

infix:['+>'], numeric shift right

```
$integer +> $bits
```

By default, signed types do sign extension, while unsigned types do not, but this may be enabled or disabled with a :signed or :!signed adverb.

infix:<~&>, buffer bitwise and

```
$x ~& $y
```

Coerces NFG strings to non-variable-encoding string buffer type (such as buf8, buf16, or buf32) and then does numeric bitwise AND on corresponding integers of the two buffers, logically padding the shorter buffer with 0 values. returning a buffer sufficiently large to contain all non-zero integer results (which for AND is at most the size of the shorter of the two buffers).

The use of coercion probably indicates a design error, however. This operator is distinguished from numeric bitwise AND in order to provide bit vectors that extend on the right rather than the left (and always do unsigned extension).

infix:['~<'], buffer bitwise shift left

```
$buf ~< $bits
```

infix:['~>'], buffer bitwise shift right

```
$buf ~> $bits
```

Sign extension is not done by default but may be enabled with a :signed adverb.

infix:<?&>, boolean and

```
$x ?& $y
```

Converts both arguments to type Bool and then ANDs those, returning the resulting Bool.

infix:<gcd>, greatest common divisor

```
$x gcd $y
```

Converts both arguments to an integral type and then finds the largest integer that both arguments are evenly divisible by, and returns that integer.

infix:<lcm>, least common multiple

```
$x lcm $y
```

Converts both arguments to an integral type and then finds the smallest integer that is evenly divisible by both arguments, and returns that integer.

Any bit shift operator may be turned into a rotate operator with the :rotate adverb. If :rotate is specified, the concept of sign extension is meaningless, and you may not specify a :signed adverb.

Additive precedence 加法优先级

infix:<+>, numeric addition 数值加法

```
$x + $y
```

Microeditorial: As with most of these operators, any coercion or type mismatch is actually handled by multiple dispatch. The intent is that all such variants preserve the notion of numeric addition to produce a numeric result, presumably stored in a numeric type suitably "large" to hold the result. Do not overload the + operator for other purposes, such as concatenation. (And please do not overload the bitshift operators to do I/O.) In general we feel it is much better for you to make up a different operator than overload an existing operator for "off topic" uses. All of Unicode is available for this purpose.

infix:<->, numeric subtraction 数值减法

```
$x - $y
```

infix:<+|>, numeric bitwise inclusive or

```
$x +| $y
```

Converts both arguments to Int and does a boolean OR between corresponding bits of each integer, returning an Int result.

infix:<+^> numeric bitwise exclusive or

```
$x +^ $y
```

Converts both arguments to Int and does a boolean XOR between corresponding bits of each integer, returning an Int result.

infix:<~|>, buffer bitwise inclusive or

```
$x ~| $y
```

Coerces NFG strings to non-variable-encoding string buffer type (such as buf8, buf16, or buf32) and then does numeric bitwise OR on corresponding integers of the two buffers, logically padding the shorter buffer with 0 values, and returning a buffer sufficiently large to contain all non-zero integer results (which for OR is at most the size of the longer of the two buffers).

The use of coercion probably indicates a design error, however. This operator is distinguished from numeric bitwise OR in order to provide bit vectors that extend on the right rather than the left (and always do unsigned extension).

infix:<~^> buffer bitwise exclusive or

```
$x ~^ $y
```

Coerces NFG strings to non-variable-encoding string buffer type (such as buf8, buf16, or buf32) and then does numeric bitwise XOR on corresponding integers of the two buffers, logically padding the shorter buffer with 0 values. returning a buffer sufficiently large to contain all non-zero integer results (which for XOR is at most the size of the longer of the two buffers).

The use of coercion probably indicates a design error, however. This operator is distinguished from numeric bitwise XOR in order to provide bit vectors that extend on the right rather than the left (and always do unsigned extension).

infix:<?|>, boolean inclusive or

```
$x ?| $y
```

Converts both arguments to type Bool and then ORs those, returning the resulting Bool.

infix:<?^> boolean exclusive or

```
$x ?^ $y
```

Converts both arguments to type Bool and then XORs those, returning the resulting Bool.

eg：

``` perl
my $x=2  # 2
my $y=3  # 3
$x +| $y # 3
$x +^ $y # 1
$x ~| $y # 3
$x ?| $y # True
$x ?^ $y # False
```

Replication 重复操作符

infix:<x>, string/buffer replication

```
$string x $count
```

Evaluates the left argument in string context, replicates the resulting string value the number of times specified by the right argument, and returns the result as a single concatenated string regardless of context.

If the count is less than 1, returns the null string. The count may not be * because Perl 6 does not support infinite strings. (At least, not yet...) Note, however, that an infinite string may someday be emulated with cat($string xx *), in which case $string x * may be a shorthand for that.

``` perl
> 'a' x *              # WhateverCode.new()
> my $a = 'a' x *      # WhateverCode.new()
> say $a               # WhateverCode.new()
> say $a(12)           # 可以传递参数！, 结果为 aaaaaaaaaaaa
```

infix:<xx>, expression repetition operator 表达式重复操作符

```
@list xx $count  # 如果 $count  是 * ，则返回一个无限列表 （懒惰的，因为 列表默认是懒惰的 ）
```

Evaluates the left argument the number of times specified by the right argument. Each evaluation is in list context, and returns a Parcel. The result of all these evaluations is returned as a list of Parcels (which will behave differently depending on whether it's bound into a flat context or a lol context).

If the count is less than 1, returns the empty list, (). If the count is *, returns an infinite list (lazily, since lists are lazy by default).

Since the expression on the left is treated as a thunk that is re-evaluated each time, expressions that rely on this behavior are possible:

```
rand xx *;                # infinite supply of random numbers
[ 0 xx $cols ] xx $rows   # distinct arrays, not the same row replicated
```

Of course, the optimizer can notice when the left side is a constant and avoid re-evaluation. When this is not possible, you can subvert the re-evaluation by use of a temporary.

eg：

``` perl
> my @random= rand xx *;
> @random[0]                # 0.510689533871727
> @random[0]                # 0.510689533871727
> @random[1]                # 0.993102039714483
> @random[2]                # 0.177400471499773
> @random[12]
```

Concatenation 字符串连接

S03-operators/misc.t lines 17–19  

S03-operators/misc.t lines 49–53  

infix:<~>, string/buffer concatenation 字符串 /缓冲 连接

```
$x ~ $y
```

Junctive and (all) precedence

infix:<&>, all() operator

S03-operators/also.t lines 4–27  

```
$a & $b & $c ...
```

By default junctions are allowed to reorder the comparisons in any order that makes sense to the optimizer. To suppress this, use the S metaoperator for force sequential evaluation, which will construct a list of ANDed patterns with the same semantics as infix:<&>, but with left-to-right evaluation guaranteed, for use in guarded patterns:

```
$target ~~ MyType S& *.mytest1 S& *.mytest2
```

This is useful when later tests might throw exceptions if earlier tests don't pass. This cannot be guaranteed by:

```
$target ~~ MyType & *.mytest1 & *.mytest2
```

Junctive or (any) precedence

infix:<|>, any() operator

```
$a | $b | $c ...
```

By default junctions are allowed to reorder the comparisons in any order that makes sense to the optimizer. To suppress this, use the S metaoperator for force sequential evaluation, which will construct a list of ORed patterns with the same semantics as infix:<|>, but with left-to-right evaluation guaranteed, for use in guarded patterns where the left argument is much more easily falsifiable than the right:

```
$target ~~ *.mycheaptest S| *.myexpensivetest
```

This is also useful when you want to perform tests in order of safety:

```
$target ~~ MyType S| *.mysafetest S| *.mydangeroustest
```

infix:<^>, one() operator

```
$a ^ $b ^ $c ...
```

The S^ variant guarantees left-to-right evaluation, and in boolean context short-circuits to false if it sees a second match.

Named unary precedence

Operators of one argument

```
let
temp
```

Note that, unlike in Perl 5, you must use the .meth forms to default to $_ in Perl 6.

There is no unary rand prefix in Perl 6, though there is a .rand method call and an argumentless rand term. There is no unary int prefix either; you must use a typecast to a type such as Int or int. (Typecasts require parentheses and may not be used as prefix operators.) In other words:

```
my $i = int $x;   # ILLEGAL
```

S03-operators/precedence.t lines 201–210  

is a syntax error (two terms in a row), because int is a type name now.

Nonchaining binary precedence 非链式二元操作符

infix:<but>

```
$value but Mixin
```

infix:<does>

```
$object does Mixin
```

Sort comparisons

S03-operators/spaceship.t lines 5–29  

```
$num1 <=> $num2
$str1 leg $str2
$obj1 cmp $obj2
```

These operators compare their operands using numeric, string, or eqv semantics respectively, and if the left operand is smaller, the same, or larger than the right operator, return respectively Order::Less, Order::Same, or Order::More (which numerify to -1, 0, or +1, the customary values in most C-derived languages). See "Comparison semantics".

S03-operators/comparison.t lines 8–12  

Range object constructor 范围对象创建

S03-operators/range.t lines 7–37  

```
$min .. $max
$min ^.. $max
$min ..^ $max
$min ^..^ $max
```

Constructs Range objects, optionally excluding one or both endpoints. See "Range and RangeIter semantics".

Chaining binary precedence 链式二元操作符

S03-operators/equality.t lines 10–54  

S03-operators/relational.t lines 9–95  

All operators on this precedence level may be chained; see "Chained comparisons". They all return a boolean value.

infix:<==> etc.

S03-operators/misc.t lines 26–48  

```
== != < <= > >=
```

As in Perl 5, converts to Num before comparison. != is short for !==.

infix:<eq> etc.

```
eq ne lt le gt ge
```

As in Perl 5, converts to Str before comparison. ne is short for !eq.

Generic ordering

```
$a before $b
$a after $b
```

Smart match

```
$obj ~~ $pattern
```

Perl 5's =~ becomes the "smart match" operator ~~, with an extended set of semantics. See "Smart matching" for details.

To catch "brainos", the Perl 6 parser defines an infix:<=~> operator, which always fails at compile time with a message directing the user to use ~~ or ~= (string append) instead if they meant it as a single operator, or to put a space between if they really wanted to assign a stringified value as two separate operators.

S03-operators/brainos.t lines 15–36  

A negated smart match is spelled !~~.

Container identity

```
VAR($a) =:= VAR($b)
```

See "Comparison semantics".

Value identity

S03-operators/value_equivalence.t lines 15–166  

```
$x === $y
```

For objects that are not value types, their identities are their values. (Identity is returned by the .WHICH metamethod.) The actual contents of the objects are ignored. These semantics are those used by hashes that allow objects for keys. See also "Comparison semantics".

Note that === is defined with an (Any,Any) signature, and therefore autothreads over junctions; hence it cannot be used to determine if two objects are the same, if either or both of them are junctions. However, since .WHICH is a macro that always returns a value and never autothreads, you can easily work around this limitation by saying:

```
$junk1.WHICH eqv $junk2.WHICH
```

[Conjecture: primitive identity is checked with $junk1 \=== $junk2.]

Canonical equivalence

```
$obj1 eqv $obj2
```

Compares two objects for canonical equivalence. For value types compares the values. For object types, compares current contents according to some scheme of canonicalization. These semantics are those used by hashes that allow only values for keys (such as Perl 5 string-key hashes). See also "Comparison semantics".

Note that eqv autothreads over junctions, as do all other comparison operators. (Do not be confused by the fact that these return boolean values; in general, only boolean context forces junction collapse.)

When comparing list-like objects, eqv must preserve lazy semantics of either or both of its arguments. (That is, it may optimize by calling .elems only when it can prove that both its arguments are already fully evaluated.)

[Conjecture: primitive equivalence is checked with $junk1 \eqv $junk2.]

Negated relational operators 反转关系操作符

S03-operators/value_equivalence.t lines 167–199  

```
$num !== 42
$str !eq "abc"
"foo" !~~ /^ <ident> $/
VAR($a) !=:= VAR($b)
$a !=== $b
$a !eqv $b
```

See "Negated relational operators".

Tight and precedence

infix:<&&>, short-circuit and

```
$a && $b && $c ...
```

Returns the first argument that evaluates to false, otherwise returns the result of the last argument. In list context forces a false return to mean (). See and below for low-precedence version.

Tight or precedence

infix:<||>, short-circuit inclusive-or

S03-operators/misc.t lines 54–67  

```
$a || $b || $c ...
```

Returns the first argument that evaluates to a true value, otherwise returns the result of the last argument. It is specifically allowed to use a list or array both as a boolean and as a list value produced if the boolean is true:

```
@a = @b || @c;              # broken in Perl 5; works in Perl 6
```

In list context this operator forces a false return to mean (). See or below for low-precedence version.

infix:<^^>, short-circuit exclusive-or

```
$a ^^ $b ^^ $c ...
```

Returns the true argument if there is one (and only one).Returns the last argument if all arguments are false. Returns Bool::False otherwise (when more than one argument is true). In list context forces a false return to mean (). See xor below for low-precedence version.

S03-operators/short-circuit.t lines 177–237  

This operator short-circuits in the sense that it does not evaluate any arguments after a 2nd true result. Closely related is the reduce operator:

```
[^^] a(), b(), c() ...
```

but note that reduce operators are not macros but ordinary list operators, so c() is always called before the reduce is done.

infix:<//>, short-circuit default operator

```
$a // $b // $c ...
```

Returns the first argument that evaluates to a defined value, otherwise returns the result of the last argument. In list context forces a false return to mean (). See orelse below for a similar but not identical low-precedence version.

Minimum and maximum

S03-operators/minmax.t lines 7–9  

```
$a min $b min $c ...
$a max $b max $c ...
```

These return the minimum or maximum value. See also the minmax listop.

Not all types can support the concept of infinity. Therefore any value of any type may be compared with +Inf or -Inf values, in which case the infinite value stands for "larger/smaller than any possible value of the type." That is,

S03-operators/minmax.t lines 8–9  

```
"foo" min +Inf              # "foo"
"foo" min -Inf              # -Inf
"foo" max +Inf              # +Inf
"foo" max -Inf              # "foo"
```

All orderable object types must support +Inf and -Inf values as special forms of the undefined value. It's an error, however, to attempt to store an infinite value into a native type that cannot support it:

```
my int $max;
$max max= -Inf;     # ERROR
```

Conditional operator precedence 条件操作符优先级

Conditional operator

```
say "My answer is: ", $maybe ?? "yes" !! "no";
```

Also known as the "ternary" or "trinary" operator, but we prefer "conditional" just to stop people from fighting over the terms. The operator syntactically separates the expression into three subexpressions. It first evaluates the left part in boolean context, then based on that selects one of the other two parts to evaluate. (It never evaluates both of them.) If the conditional is true it evaluates and returns the middle part; if false, the right part. The above is therefore equivalent to:

S03-operators/misc.t lines 20–25  

```
say "My answer is: ", do {
    if $maybe {
        "yes";
    }
    else {
        "no";
    }
};
```

It is a syntax error to use an operator in the middle part that binds looser in precedence, such as =.

```
my $x;
hmm() ?? $x = 1 !! $x = 2;        # ERROR
hmm() ?? ($x = 1) !! ($x = 2);    # works
```

Note that both sides have to be parenthesized. A partial fix is even wronger:

```
hmm() ?? ($x = 1) !! $x = 2;      # parses, but WRONG
```

That actually parses as:

```
(
    hmm() ?? ($x = 1) !! $x
) = 2;
```

and always assigns 2 to $x (because ($x = 1) is a valid lvalue).

And in any case, repeating the $x forces you to declare it earlier. The best don't-repeat-yourself solution is simply:

```
my $x = hmm() ?? 1 !! 2;          # much better
```

infix:<?>

To catch likely errors by people familiar with C-derived languages (including Perl 5), a bare question mark in infix position will produce an error suggesting that the user use ?? !! instead.

Flipflop ranges  ff 范围操作符

```
start() ff end()
start() ^ff end()
start() ff^ end()
start() ^ff^ end()
```

Flipflop ranges (sed style)

```
start() fff end()
start() ^fff end()
start() fff^ end()
start() ^fff^ end()
```

Adverbs 副词

Operator adverbs are special-cased in the grammar, but give the appearance of being parsed as trailing unary operators at a pseudo-precedence level slightly tighter than item assignment. (They're not officially "postfix" operators because those require the absence of whitespace, and these allow whitespace. These adverbs insert themselves in the spot where the parser is expecting an infix operator, but the parser continues to look for an infix after parsing the adverb and applying it to the previous term.) Thus,

```
$a < 1 and $b == 2 :carefully
```

does the == carefully, while

```
$a < 1 && $b == 2 :carefully
```

does the && carefully because && is of tighter precedence than "comma". Use

```
$a < 1 && ($b == 2 :carefully)
```

to apply the adverb to the == operator instead. We say that == is the "topmost" operator in the sense that it is at the top of the parse tree that the adverb could possibly apply to. (It could not apply outside the parens.) If you are unsure what the topmost operator is, just ask yourself which operator would be applied last. For instance, in

```
+%hash{$key} :foo
```

the subscript happens first and the + operator happens last, so :foo would apply to that. Use

```
+(%hash{$key} :foo)
```

to apply :foo to the subscripting operator instead.

Adverbs will generally attach the way you want when you say things like

```
1 op $x+2 :mod($x)
```

The proposed internal testing syntax makes use of these precedence rules:

```
$x eqv $y+2  :ok<$x 等价于 $y+2>;
```

Here the adverb is considered to be modifying the eqv operator.

Item assignment precedence 项赋值优先级

S03-binding/subs.t lines 7–117  

S03-binding/nested.t lines 5–344  

S03-binding/arrays.t lines 5–239  

S03-binding/hashes.t lines 5–198  

S03-binding/attributes.t lines 4–81  

infix:<=>

```
$x = 1, $y = 2;
```

With simple lvalues, = has this precedence, which is tighter than comma. (List assignments have listop precedence below.)

infix:['=>'], Pair constructor

```
foo => 1, bar => "baz"
```

Binary => is no longer just a "fancy comma". It now constructs a Pair object that can, among other things, be used to pass named arguments to functions. It provides item context to both sides. It does not actually do an assignment except in a notional sense; however its precedence is now equivalent to assignment, and it is also right associative. Note that, unlike in Perl 5, => binds more tightly than comma.

Assignment operators

```
+= -= **= xx= .= etc.
```

See "Assignment operators".

Loose unary precedence

S03-operators/not.t lines 5–38  

S03-operators/so.t lines 5–30  

prefix:<not>

```
not any(@args) eq '-v' | '-V'
```

Returns a Bool value representing the logical negation of an expression.

prefix:<so>

```
so any(@args) eq '-v' | '-V'
```

Returns a Bool value representing the logical non-negation of an expression. Mostly useful as documentation in parallel to a not when else isn't appropriate:

```
if not $x { print "LOL"; }
mumble();
if so $x { print "SRSLY!" }
```

``` perl
> my @a = <v e i o>         # v e i o
> so any(@a) eq 'v' | 'V'   # True
```

Comma operator precedence 逗号操作符优先级

infix:<,>  参数分隔符

```
1, 2, 3, @many
```

不像 Perl5 ，逗号操作符从来不返回最后一个值 （ 在标量上下文它返回一个列表代替）

- infix:<:>, the invocant marker 冒号，引用创建者

``` perl
say $*OUT: "howdy, world"  # howdy, world
say($*OUT: "howdy, world") # howdy, world
push @array: 1,2,3
push(@array: 1,2,3)
\($object: 1,2,3, :foo, :!bar)
```

冒号操作符就像逗号那样解析，但是把参数左边标记为调用者，这会把函数调用转换为方法调用。它只能在参数列表或捕获的第一个参数身上使用，用在其它地方会解析失败。当用在捕获中时，尚不知道捕获会被绑定到哪个签名上；如果绑定到一个非方法的签名身上，调用者仅仅转换成第一个位置参数，就像冒号就是一个逗号一样。

为了避免和其它冒号形式混淆，冒号中缀操作符后面必须跟上空格或终止符。它前面可以有空格也可以没有空格。

注意：和下面的中缀操作符区别开。

```
@array.push: 1,2,3
@array.push(1,2,3): 4,5,6
push(@array, 1,2,3): 4,5,6
```

这是把普通函数或方法转换为列表操作符的特殊形式。 这种特殊形式只在点语法形似的方法调用后被识别， 或者在方法或函数调用的右圆括号之后。

这种特殊形式不允许介于中间的空格， 但是允许在下一个参数之前有空格。 在所有情况下， 冒号会被尽可能地解析为副词的开头，或者调用者标记者（上面描述的中缀）

which is a special form that turns an ordinary function or method call into a list operator. The special form is recognized only after a dotty method call, or after the right parenthesis of a method or function call. The special form does not allow intervening whitespace, but requires whitespace before the next argument. In all other cases a colon will be parsed as the start of an adverb if possible, or otherwise the invocant marker (the infix described above).

Another way to think of it is that the special colon is allowed to add listop arguments to a parenthesized argument list only after the right parenthesis of that argument list, with the proviso that you're allowed to shorten .foo(): 1,2,3 down to .foo: 1,2,3. (But only for method calls, since ordinary functions don't need the colon in the first place to turn into a listop, just whitespace. If you try to extend a function name with a colon, it's likely to be taken as a label.)

冒号的另一种特殊方式是, 允许正好在参数列表的右侧圆括号之后为圆括号括住的参数列表添加 listop 参数，附带条件是你被允许把 `.foo(): 1,2,3` 缩短为 `.foo: 1,2,3`.

(但是只对方法调用， 因为普通的函数不需要第一个位置的冒号转换为 listop， 空格就够了。 如果你尝试使用冒号扩展函数， 它很可能被看作标签。)

```
foo $obj.bar: 1,2,3     # special, means foo($obj.bar(1,2,3))
foo $obj.bar(): 1,2,3   # special, means foo($obj.bar(1,2,3))
foo $obj.bar(1): 2,3    # special, means foo($obj.bar(1,2,3))
foo $obj.bar(1,2): 3    # special, means foo($obj.bar(1,2,3))
foo($obj.bar): 1,2,3    # special, means foo($obj.bar, 1,2,3)
foo($obj.bar, 1): 2,3   # special, means foo($obj.bar, 1,2,3)
foo($obj.bar, 1,2): 3   # special, means foo($obj.bar, 1,2,3)
foo $obj.bar : 1,2,3    # infix:<:>, means $obj.bar.foo(1,2,3)
foo ($obj.bar): 1,2,3   # infix:<:>, means $obj.bar.foo(1,2,3)
foo $obj.bar:1,2,3      # 语法错误
foo $obj.bar :1,2,3     # 语法错误
foo $obj.bar :baz       # 副词, means foo($obj.bar(:baz))
foo ($obj.bar) :baz     # 副词, means foo($obj.bar, :baz)
foo $obj.bar:baz        # extended identifier, foo( $obj.'bar:baz' )
foo $obj.infix:<+>      # extended identifier, foo( $obj.'infix:<+>' )
foo: 1,2,3              # label at statement start, else infix
```



这个故事的寓意是：如果你不知道冒号是怎样结合的，就使用空格或圆括号让它清晰。

- List infix precedence 列表中缀优先级

List infixes all have list associativity, which means that identical infix operators work together in parallel rather than one after the other. Non-identical operators are considered non-associative and must be parenthesized for clarity.

 列表中缀操作符都有列表结合性，这意味着，同一个中缀操作符是同步起作用的，而不是一个接着一个。不同的操作符被认为是非结合性的，为了明确，必须用括号括起来。

- infix:<Z>,  the zip operator

S03-operators/misc.t lines 110–115  

``` perl
    1,2 Z 3,4   # (1,3),(2,4)
```

``` perl
> 2,5,7 [Zmin] 3,4,5     # 两两比较, 2 4 5
> my @a=3,6,9            # 3 6 9
> my @b=4,5,10           # 4 5 10
> @a [Zmin] @b           # 3 5 9
> my @a = (1,2,9,3,5)    # 1 2 9 3 5
> my @b = (2,3,5,1,9)    # 2 3 5 1 9
> my @c = (2,3,4,5,1)    # 2 3 4 5 1
> @a [Zmin] @b [Zmin] @c # 1 2 4 1 1
> @a [Zmax] @b [Zmax] @c # 2 3 9 5 9
```

- infix:<minmax>,  minmax 操作符

```
@a minmax @b
```

返回@a和@b中最小值和最大值的一个范围。

``` perl
> my @a = 2,4,6,8;
> my @b = 1,3,5,7,9;
> @a minmax @b         # 1..9
```

- infix:<X>,  交叉操作符

S03-metaops/cross.t lines 6–19  

``` perl
1,2 X 3,4          # (1,3), (1,4), (2,3), (2,4)
```

和 zip 操作符相比， X 操作符返回元素交叉后的列表。例如，如果只有 2 个列表，第一个列表中取一个元素和第二个列表中取一个元素组成 pair 对儿，第二个元素变化的最迅速。

最右边的列表先遍历完。因此， 你写：

``` perl
<a b> X <1 2>
```

你会得到：

``` perl
('a', '1'), ('a', '2'), ('b', '1'), ('b', '2')
```

这在平的上下文会变成一个展平的列表，在 list of list 上下文中会变成列表中的列表

S03-metaops/cross.t lines 20–29  

``` perl
say flat(<a b> X <1 2>).perl    #  ("a", "1", "a", "2", "b", "1", "b", "2").list
say lol(<a b> X <1 2>).perl     # (("a", "1"), ("a", "2"), ("b", "1"), ("b", "2"))
```

这个操作符是列表结合性的，所以：

``` perl
1,2 X 3,4 X 5,6
```

生成

``` perl
(1,3,5),(1,3,6),(1,4,5),(1,4,6),(2,3,5),(2,3,6),(2,4,5),(2,4,6)
```

另一方面，如果任一列表为空，你会得到一个空列表。

尽管X两边的列表可能是无限的，在操作符 X的右边使用无限列表可能会产生意想不到的结果，例如：

``` perl
<a b> X 0..*
```

会产生

``` perl
('a',0), ('a',1), ('a',2), ('a',3), ('a',4), ('a',5), ...
```

并且你绝对不会到达 'b'。如果你左侧的列表只包含单个元素，然而，这可能有用，尤其是如果 X 用作元操作符时。看下面。

``` perl
say lol(<a b> X <1 2>).perl    # ("a", "1", "a", "2", "b", "1", "b", "2")
```

Cross metaoperators 交叉操作符

``` perl
@files X~ '.' X~ @extensions
1..10 X* 1..10
@x Xeqv @y
```

等等

一个常见的用法是让一个列表只含有单个元素在操作符 X 的一边或另一边：

```
@vector X* 2;                 # 每个元素都乘以 2
$prefix X~ @infinitelist;     # 在无限列表的每个元素前面前置一个元素
```

``` perl
> my $prefix = ' - '
> my @a =<1 2 3 4 5>
> $prefix X~ @a       #  - 1  - 2  - 3  - 4  - 5
```

这时右边有一个无限列表是可以的。

See "Cross operators".

- infix:<...>, 序列操作符.

S03-sequence/arity-2-or-more.t lines 4–49  

S03-sequence/basic.t lines 4–98  

S03-sequence/limit-arity-2-or-more.t lines 4–35  

作为一个中缀操作符， `...` 操作符的左右两侧都有一个列表，并且为了产生`想要的值`的序列，序列操作符 `...` 会尽可能地对序列进行惰性求值。列表被展平后求值。就像所有的中缀操作符一样， ... 序列操作符比逗号的优先级要低，所以你没必要在逗号列表的两侧加上圆括号。

序列操作符 `...` 以右侧列表的第一个值开始。这只在右侧的列表中， ... 序列操作符唯一感兴趣的值；any additional list elements are treasured up lazily to be returned after the ... is done.

 ... 右侧的第一个值是序列的端点或界限，这是序列操作符 ... 从左侧生成的。

一旦我们知道了序列的边界，左侧的列表会一项一项地被求值，并且普通数字或字符串值被无差异地传递（在右侧边界允许的程度内）如果序列中的任何值匹配到边界值，序列会终止，包括那个最后的边界值在内。要排除边界值，使用  ...^ 代替。

Internally, these two forms are checking to see if an anonymous loop is going to terminate, where the loop is what is returning the values of the sequence. Assuming the next candidate value is in $x and the first element of the right side is in $limit, the two operators are implemented respectively as:

在内部，这两种形式用于检测匿名的循环是否会终止，而循环返回序列中的值。假设下一个候选的值存储在 $x 中，并且右侧序列中的第一个值存储在 $limit 中，这两个操作符各自实现为：

``` perl
    ...     last($x) if $x ~~ $limit;
    ...^    last     if $x ~~ $limit;
```

Since this uses smartmatching via the ~~ operator (see "Smart matching" below), the usual smartmatching rules apply. If the limit is *, the sequence has no limit. If the limit is a closure, it will be evaluated for boolean truth on the current candidate, and the sequence will continue as long as the closure returns false. If the limit is a closure with more than 1 - or infinite - arguments the appropriate number of elements from the end of the sequence - or the whole sequence so far - are passed. It's quite possible for a sequence to return fewer values than are listed if the very first value matches the end test:

如果边界是 * ,序列就没有界限。如果边界是一个闭包，它会在当前候选对象中进行布尔真值求值，并且序列会一直继续只要闭包返回false。如果边界是一个含有一个或无限参数的闭包，

``` perl
    my $lim = 0;
    1,2,3 ...^ * > $lim      # returns (), since 1 > 0
```

这个操作符如果只能把左边的值原样返回就太乏味了。它的强大来自于能从旧值生成新值。你可以，例如，使用一个存在的生成器产生一个无穷列表：

``` perl
    1..* ... * >= $lim
    @fib ... * >= $lim
```

eg：

``` perl
> 1..* ... * >= 10  # 1 2 3 4 5 6 7 8 9 10
```



更一般地，如果 ... 操作符左侧列表中的下一项是一个闭包，它不会被返回。他会在已经存在的列表的末尾被调用以产生一个新值。闭包中变量的数目决定了要使用多少前置值作为输入来生成序列中的下一个值。例如，以2为步长计数只需要一个参数：

``` perl
    2, { $^a + 2 } ... *           # 2,4,6,8,10,12,14,16...
```

生成裴波纳契序列一次需要两个参数：

``` perl
    1, 1, { $^a + $^b } ... *      # 1,1,2,3,5,8,13,21...
```

任何特定的函数也有效，只要你把它作为列表中的一个值而不是调用它：

``` perl
    1, 1, &infix:<+> ... *         # 1,1,2,3,5,8...
    1, 1, &[+] ... *               # 同上
    1, 1, *+* ... *                # 同上
```

``` perl
> sub infix:<jia>($a,$b){ return $a+$b }
> 1 jia 5 # 6
> 1,1,&[jia] ... * # 1 1 2 3 5 8 13 21 34 55 89 144 233 377 ......
```



更一般地，函数是一元的，这种情况下左侧列表中任何额外的值会被构建为人类可读的文档：

``` perl
    0,2,4, { $_ + 2 } ... 42        #  0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42
```

使用闭包：

``` perl
> 0,2,4,-> $init {$init+2} ... 42   # 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 34 36 38 40 42
```

``` perl
    0,2,4, *+2 ... 42           # same thing
    <a b c>, { .succ } ... *    # same as 'a'..*
```

函数也可以不是单调函数：

``` perl
    1, -* ... *                # 1, -1, 1, -1, 1, -1...
    False, &prefix:<!> ... *   # False, True, False...
```

函数也可以是 0-ary 的， 这个时候让闭包成为第一个元素是 okay 的：

S03-sequence/arity0.t lines 4–45  

```
{ rand } ... *             # 一组随机数
```

函数还可以是吞噬的（n-ary），在这种情况下，所有前面的值都被传递进来（这意味着它们必须都被操作符缓存下来，所以性能会经受考验， 你可能会发现自己空间泄露了）



函数的数量不必与返回值的数量匹配， 但是如果确实匹配， 你可能会插入不相关的序列：

S03-sequence/misc.t lines 20–29  

``` perl
    1,1,{ $^a + 1, $^b * 2 } ... *   # 1,1,2,2,3,4,4,8,5,16,6,32...
    1,1, ->$a,$b {$a+1,$b*2} ... *  # 同上
```

注意在这种情况下任何界限测试被应用到从函数返回的整个 parcel 上， 这个 parcel 包含两个值。

除了那些函数签名所隐含的约束，序列操作符从一个没有对序列作类型约束的显式函数中生成。如果函数的签名和已存在的值不匹配，那么序列终止。

S03-sequence/misc.t lines 5–12  

如果没有提供生成闭包， 并且序列是数字的，而且序列明显还是等差的或等比的（通过检查它的最后 3 个值），那么序列操作符就会推断出合适的函数：

``` perl
1, 3, 5 ... *    # 奇数
1, 2, 4 ... *    # 2的幂
10,9, 8 ... 0    # 倒数
```

即， 假设我们调用了最后 3 个数字  `$a`, `$b`, 和 `$c`，然后定义：

``` perl
$ab = $b - $a;
$bc = $c - $b;
```

如果 `$ab == $bc` 并且 `$ab` 不等于0， 那么我们通过函数 `*+$ab` 可以推断出等差数列。如果 `$ab` 为 0，并且那3个值看起来像数字，那么函数推断为 `*+0`。

如果它们看起来不像数字，那么根据 `$b cmp $c` 的结果是 Increasing 还是 Decreasing 来决定选择的函数是 `*.succ` 还是 `*.pred`。

如果 `cmp` 返回 `Same` 那么会假定函数是同一个。

如果 `$ab != $bc` 并且 `none($a,$b,$c) == 0`， 那么会使用除法而非减法做类似的计算来决定是否需要一个等比数列。定义：

``` perl
$ab = $b / $a;
$bc = $c / $b;
```

如果两者的商相等（并且是有限的），那么会推断出等比函数  `{$_ * $bc}`。

如果目前为止只有 2 个值， $a 和 $b, 并且差值 $ab 不为 0, 那么我们就假定函数为 `*+$ab` 的等差数列。

如果 `$ab` 是 0， 那么再次， 我们使用  `*+0` 还是 `*.succ/*.pred` 取决于那两个值看起来是不是数字。

如果只有一个值，我们总是通过 *.succ 假定增量（这可能被强制为 .pred 通过检查界限，就像下面指定的那样）因此这些结果都是一样的：

``` perl
1 .. *
1 ... *
1,2 ... *
1,2,3 ... *
<1 2 3> ... *
```

同样地， 如果给定的值(s)不是数字， 就假定为 `.succ`, 所以这些结果是一样的：

``` perl
'a' .. *
'a' ... *
'a','b' ... *
'a','b','c' ... *
<a b c> ... *
```

如果序列操作符的左侧是 `()`, 那我们使用函数 ` {()}` 来生成一个无限的空序列。

如果给定了界限，那这个界限就必须被精确匹配。如果不能精确匹配，会产生无限列表。例如，因为"趋近"和“相等”不一样， 下面的两个序列都是无限列表，就像你把界限指定为了 * 而不是 0：

S03-sequence/basic.t lines 99–107  

```
1,1/2,1/4 ... 0    # like 1,1/2,1/4 ... *
1,-1/2,1/4 ... 0   # like 1,-1/2,1/4 ... *
```

同样地，这是所有的偶数：

```
my $end = 7;
0,2,4 ... $end
```

为了捕捉这样一种情况， 建议写一个不等式代替：

```
0,2,4 ...^ { $_ > $end }
```

当使用了显式的界限函数，他可能通过返回任意真值来终止它的列表。因为序列操作符是列表结合性的，内部函数后面可以跟着 ... ，然后另外一个函数来继续列表，等等。因此：

S03-sequence/misc.t lines 34–100  

``` perl
    1,   *+1   ... { $_ ==   9 },
    10,  *+10  ... { $_ ==  90 },
    100, *+100 ... { $_ == 900 }
```

产生：

``` perl
    1,2,3,4,5,6,7,8,9,
    10,20,30,40,50,60,70,80,90,
    100,200,300,400,500,600,700,800,900
```

考虑到没有闭包的普通匹配规则，我们可以把上面的序列更简单地写为：

``` perl
    1, 2, 3 ... 9,
    10, 20, 30 ... 90,
    100, 200, 300 ... 900
```

甚至仅仅是：

``` perl
    1, 2, 3 ...
    10, 20, 30 ...
    100, 200, 300 ... 900
```

因为一个精确的匹配界限会被作为序列的一部分返回，所以提供的那个精确值是一个合适类型的值， 而非一个闭包。

对于左侧只有一个值的函数推断，最后的值被用于决定是 *.succ 还是 *.pred 更合适。 使用 cmp 来比较那两个值来决定前进的方向。

因此, 序列操作符能自动反转, 而范围操作符不会自动反转.

``` perl
    'z' .. 'a'   # 表示一个空的范围
    'z' ... 'a'  # z y x ... a
```

你可以使用 `^...` 形式来排除第一个值:

``` perl
    'z' ^... 'a' # y x ... a
    5 ^... 1     # 4, 3, 2, 1
```

但是你要意识到, 如果列表的左侧很复杂, 特别是左侧是另一个序列时, 肯定会让你的读者困惑:

``` perl
    1, 2, 3 ^... *;                  # 2, 3 ...  !
    1, 2, 3 ... 10, 20, 30 ^... *;   # 2, 3 ...  !?!?
```

是的, 对于极端喜欢对称性的那些人来说, 还有另外一种形式: `^...^`

就像数字数值一样, 字符串匹配必须是精确的, 否则会产生无限序列.

注意下面这个序列:

``` perl
    1.0, *+0.2 ... 2.0
```

是使用 `Rat` 算术计算的, 而不是 `Num`, 所以 2.0 精确地匹配了并结束了序列.

注意：只有在期望为一个 term 的地方，`...` 才会被识别为 yada 操作符。序列操作符只用于期望中缀操作符出现的地方。

如果你在 `...` 前面放置了一个逗号，那么 `...`会被识别为 yada 列表操作符 - 表达当列表到达那点时会失败的要求。

S03-sequence/misc.t lines 30–33  

```
1..20, ... "I only know up to 20 so far mister"
> 1..20, fail "I only know up to 20 so far mister"  # I only know up to 20 so far mister
```

序列的末端是一个代表单个代码点的字符串时，会抛出一个特殊的异常， 因为典型地，用户会把这样一个字符串看作是字符而非字符串。如果你像这样说：

S03-sequence/nonnumeric.t lines 36–101  

``` perl
    'A' ... 'z'
    "\xff" ... "\0"
```

``` perl
>  'A' ... 'z' # A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \ ] ^ _ ` a b c d e f g h i j k l m n o p q r s t u v w x y z
```

它会假定你对按字母顺序范围不感兴趣， 所以，代替对于字符串使用普通的 `.succ/.pred`， 它会像这样使用单调函数来增加或减少底层的代码点数字：

``` perl
'A', { $^prev.ord.succ.chr } ... 'z';
"\xff", { $^prev.ord.pred.chr } ... "\0";
```

You will note that this alternate definition doesn't change the meaning of any sequence that falls within a conventional rangechar range:

``` perl
    'a'...'z'
    '9'...'0'
```

If the start and stop strings are the same length, this is applied at every position, with carry.

``` perl
    'aa' ... 'zz'   # same as 'a' .. 'z' X~ 'a' .. 'z'
```

Hence, to produce all octal numbers that fit in 16 bits, you can say:

``` perl
    '000000' ... '177777'
```

At need, you can override these numeric codepoint semantics by using an explicit successor function:

``` perl
    '⓪', *.succ ... '㊿'       # circled digits/numbers 0..50
```

(In fact, this is precisely what the translation from ranges does, in order to preserve the abstract ordering of rangechars that have non-contiguous codepoints. But it's easier just to use the range operator if that's the case.)

If the start string is shorter than the stop string, the strings are assumed to be right justified, and the leftmost start character is duplicated when there is a carry:

``` perl
    '0' ... '177777'    # same octal sequence, without leading 0's
```

Going the other way, digits are dropped when they go to the first existing digit until the current value is as short as the final value, then the digits are left there. Which is a fancy way of saying that

``` perl
    '177777' ... '000000'
```

and

``` perl
    '177777' ... '0'
```

both do exactly what the forward sequences do above, only in reverse.

As an extra special rule, that works in either direction: if the bottom character is a '0' and the top character is alphanumeric, it is assumed to be representing a number in some base up to base 36, where digits above ten are represented by letters. Hence the same sequences of 16-bit numbers, only in hexadecimal, may be produced with:

``` perl
    '0000' ... 'ffff'
    '0' ... 'ffff'
    'ffff' ... '0000'
    'ffff' ... '0'
```

And as a limiting case, this applies to single characters also:

``` perl
    '0' .. 'F'    # 0..9, 'A'..'F'
```

Note that case is intuited from the top character of the range.

There are many different possible semantics for string increment. If this isn't the semantics you want, you can always write your own successor function. Sometimes the stupid codepoint counting is what you want. For instance, you can get away with ranges of capital Greek letters:

``` perl
    'ΑΑΑ' ... 'ΩΩΩ'
```

However, if you try it with the lowercase letters, you'll get both forms of lowercase sigma, which you probably don't want. If there's only one or two letters you don't want, you can grep out those entries, but in the general case, you need an incrementer that knows what sequence you're interested in. Perhaps there can be a generic method,

``` perl
    'ααα', *.succ-in(@greek) ... 'ωωω'
```

that will take any given sequence and use it as the universe of incrementation for any matching characters in the string.

To preserve Perl 5 length limiting semantics of a range like 'A'..'zzz', you'd need something like:

``` perl
    'A', *.succ ... { last if .chars > 3; $_ eq 'zzz' }
```

(That's not an exact match to what Perl 5 does, since Str.succ is a bit fancier in Perl 6, but starting with 'A' it'll work the same. You can always supply your own increment function.)

Note that the last call above returns no argument, so even though the internal test calls last($x), this call to last bypasses that as if the sequence had been specified with ...^ instead. Going the other way, a ...^ maybe be forced to have a final value by passing an argument to an explicit last($my-last-value). In the same way, that will bypass the argumentless internal last.

In a similar way, the sequence may be terminated by calling last from the generator function:

``` perl
    10,9,8, { $_ - 1 || last } ... *   # same as 10 ... 1
```

For purposes of deciding when to terminate the eager part of a 'mostly eager' list, any sequence that terminates with an exact value (or that starts another sequence with exact values) is considered finite, as is any sequence that has an explicit ending closure. However, any sequence that ends * is considered to be of unknowable length. However, by the definition of "mostly eager" in S07, the implementation may be able to determine that such a sequence is finite by conjectural evaluation; such workahead cannot, of course, always prove that a sequence is infinite without running a Very Long Time. Note also that, by using the form that specifies both a closure and a final value, it is possible to write a sequence that appears to be finite but that never actually reaches its final value before resources are exhausted; such a sequence will be treated as finite, but eventually will come to grief:

``` perl
    @a = 1, *+0.00000000000000000000000000000000000001 ... 2;  # heat death
```

For any such sequence or list that the user knows to be infinite, but the computer can't easily know it, it is allowed to mark the end of the list with a *, which indicates that it is to be treated as an infinite list in contexts that care. Similarly, any list ending with an operator that interprets * as infinity may be taken the same way, such as $n xx *, or 1..*.

On the other hand, it's possible to write a sequence that appears to be infinite, but is terminated by a last from the iterator closure. An implementation is required to trap such a loop termination and change the status of the list from 'infinite' to 'finite, such that .elems reports the actual produced length, not Inf.

Many of these operators return a list of Parcels, which depending on context may or may not flatten them all out into one flat list. The default is to flatten, but see the contextualizers below.

List prefix precedence 列表前缀优先级

- infix:<=>, list assignment

``` perl
    @array = 1,2,3;
```

With compound targets, performs list assignment. The right side is looser than list infix. You might be wondering why we've classified this as a prefix operator when its token name is infix:<=>. That's because you can view the left side as a special syntax for a prefix listop, much as if you'd said:

``` perl
    @array.assign: 1,2,3
```

However, the tokener classifies it as infix because it sees it when it's expecting an infix operator. Assignments in general are treated more like retroactive macros, since their meanings depend greatly on what is on the left, especially if what is on the left is a declarator of some sort. We even call some of them pseudo-assignments, but they're all a bit pseudo insofar as we have to figure out whether the left side is a list or a scalar destination.

In any case, list assignment is defined to be arbitrarily lazy, insofar as it basically does the obvious copying as long as there are scalar destinations on the left or already-computed values on the right. However, many list lvalues end with an array destination (where assignment directly to an array can be considered a degenerate case). When copying into an array destination, the list assignment is "mostly eager"; it requests the list to evaluate its leading iterators (and values) to the extent that they are known to be finite, and then suspend, returning the known values. The assignment then copies the known values into the array. (These two steps might actually be interleaved depending on how the iterator API ends up being defined.) It then sets up the array to be self-extending by using the remainder of the list as the "specs" for the array's remaining values, to be reified on demand. Hence it is legal to say:

``` perl
    @natural = 0..*;
```

(Note that when we say that an iterator in list context suspends, it is not required to suspend immediately. When the scheduler is running an iterator, it may choose to precompute values in batches if it thinks that approach will increase throughput. This is likely to be the case on single-core architectures with heavy context switching, and may very well be the case even on manycore CPU architectures when there are more iterators than cores, such that cores may still have to do context switching. In any case, this is all more-or-less transparent to the user because in the abstract the list is all there, even if it hasn't been entirely computed yet.)

Though elements may be reified into an array on demand, they act like ordinary array elements both before and after reification, as far as the user is concerned. These elements may be written to if the underlying container type supports it:

``` perl
    @unnatural = 0..*;
    @unnatural[42] = "Life, the Universe, and Everything";
```

Note that, unlike assignment, binding replaces the container, so the following fails because a range object cannot be subscripted:

``` perl
    @natural := 0..*;     # bind a Range object
    @natural[42] = "Life, the Universe, and Everything";  # FAILS
```

but this succeeds:

``` perl
    @unnatural := [0..*]; # bind an Array object
    @unnatural[42] = "Life, the Universe, and Everything"; # ok
```

It is erroneous to make use of any side effects of reification, such as movement of a file pointer, since different implementations may have different batch semantics, and in any case the unreified part of the list already "belongs" to the array.

When a self-extending array is asked for its count of elements, it is allowed to return +Inf without blowing up if it can determine by inspection that its unreified parts contain any infinite lists. If it cannot determine this, it is allowed to use all your memory, and then some. :)

Assignment to a hash is not lazy (probably).

- infix:<:=>, run-time binding

``` perl
    $signature := $capture
```

A new form of assignment is present in Perl 6, called binding, used in place of typeglob assignment. It is performed with the := operator. Instead of replacing the value in a container like normal assignment, it replaces the container itself. For instance:

``` perl
    my $x = 'Just Another';
    my $y := $x;
    $y = 'Perl Hacker';
```

After this, both $x and $y contain the string "Perl Hacker", since they are really just two different names for the same variable.

There is also an identity test, =:=, which tests whether two names are bound to the same underlying variable. $x =:= $y would return true in the above example.

The binding fails if the type of the variable being bound is sufficiently inconsistent with the type of the current declaration. Strictly speaking, any variation on

``` perl
    my Any $x;
    $x := [1,2,3];
```

should fail because the type being bound is not consistent with Scalar of Any, but since the Any type is not a real instantiable type but a generic (non)constraint, and Scalar of Any is sort of a double non-constraint similar to Any, we treat this situation specially as the equivalent of binding to a typeless variable.

The binding operator parses as a list assignment, so it is reasonable to generate a list on the right without parens:

``` perl
    @list := 1 ... *;
```

- infix:<::=>, 绑定并使只读

``` perl
    $signature ::= $capture
```

This does the same as :=, then marks any destination parameters as readonly (unless the individual parameter overrides this with either the rw trait or the copy trait). It's particularly useful for establishing readonly dynamic variables for a dynamic scope:

``` perl
    {
        my $*OUT ::= open($file, :w) || die $!;
        doit();     # runs with redirected stdout
    }
    doit();     # runs with original stdout
```

If doit wants to change $*OUT, it must declare its own dynamic variable. It may not simply assign to $*OUT.

Note that the semantics of ::= are virtually identical to the normal binding of arguments to formal subroutine parameters (which also default to readonly).

This operator parses as a list assignment.

Normal listops

```
print push say join split substr open etc.
```

Listop forms of junctional operators

```
any all one none
```

Exception generators

```
fail "Division by zero"
die System::Error(ENOSPC,"Drive $d seems to be full");
warn "Can't open file: $!"
```

Stubby exception generators

```
...
!!! "fill this in later, Dave"
??? "oops in $?CLASS"
```

The ... operator is the "yada, yada, yada" list operator, which among other things is used as the body in function prototypes. It complains bitterly (by calling fail) if it is ever executed. Variant ??? calls warn, and !!! calls die. The argument is optional, but if provided, is passed onto the fail, warn, or die. Otherwise the system will make up a message for you based on the context, indicating that you tried to execute something that is stubbed out. (This message differs from what fail, warn, and die would say by default, since the latter operators typically point out bad data or programming rather than just an incomplete design.)



Reduce operators 运算操作符

```
[+] [*] [<] [\+] [\*] 等等.
```

Sigils as coercions to roles

```
Sigil       Alpha variant
-----       -------------
$           Scalar
@           Positional (or Iterable?)
%           Associative
&           Callable
```

Note that, since these are coercions to roles, they are allowed to return any actual type that does the role in question.

Unless applied directly to a scalar variable, as in @$a, these may only be applied with explicit parens around an argument that is processed as a bare Parcel object, not a flattening list:

```
 $(1,2 Z 3,4)      # Scalar((1,3),(2,4))
 @(1,2 Z 3,4)      # ((1,3),(2,4))
 %(1,2 Z 3,4)      # PairSeq(1 => 3, 2 => 4)
 $(1,2 X 3,4)      # Scalar((1,3),(1,4),(2,3),(2,4))
 @(1,2 X 3,4)      # ((1,3),(1,4),(2,3),(2,4))
```

(Note, internal parens indicate nested Parcel structure here, since there is no flattening.)

Since a Parcel with one argument is transparent, there can be no difference between the meaning of @($a) and @$a.

The item contextualizer

S03-operators/context.t lines 36–71  

```
item foo()
```

The new name for Perl 5's scalar contextualizer. Equivalent to $(...) (except that empty $() means $<? // Str($/)>, while empty item() yields Failure). We still call the values scalars, and talk about "scalar operators", but scalar operators are those that put their arguments into item context.

If given a list, this function makes a Seq object from it. The function is agnostic about any Parcel embedded in such a sequence, and any contextual decisions will be deferred until subsequent use of the contents.

Note that this parses as a list operator, not a unary prefix operator, since you'd generally want it for converting a list to a sequence object. (Single items don't need to be converted to items.) Note, however, that it does no flattening of its list items:

```
@x = lol(item (1,2),(3,4))  # @x eqv LoL( (1,2), (3,4) )
```

The list contextualizer

S03-operators/context.t lines 7–35  

```
list foo()
```

Forces the subsequent expression to be evaluated in list context. Any flattening happens lazily.

The flat contextualizer

```
flat foo()
```

Forces the subsequent expression to be evaluated in a flattening list context. The result will be recursively flattened, i.e., contain no embedded Parcel objects.

The lol contextualizer

```
lol foo()
```

Forces the subsequent expression to be evaluated in list-of-lists context. This is typically used to form a multidimensional slice. A parcel potentially containing subparcels will be transformed into a list of lists, specifically of type LoL.

The hash contextualizer

```
hash foo()
```

Forces the subsequent expression to be evaluated in hash context. The expression is evaluated in list context (flattening any Parcels), then a hash will be created from the list, taken as a list of Pairs. (Any element in the list that is not a Pair will pretend to be a key and grab the next value in the list as its value.) Equivalent to %(...) (except that empty %() means %($/), while empty hash() means an empty hash).

Loose and precedence

infix:<and>, short-circuit and

```
$a and $b and $c ...
```

Returns the first argument that evaluates to false, otherwise returns the result of the last argument. In list context forces a false return to mean (). See && above for high-precedence version.

infix:<andthen>, proceed on success

```
test1() andthen test2() andthen test3() ...
```

Returns the first argument whose evaluation indicates failure (that is, if the result is undefined). Otherwise it evaluates and returns the right argument.

If the right side is a block or pointy block, the result of the left side is bound to any arguments of the block. If the right side is not a block, a block scope is assumed around the right side, and the result of the left side is implicitly bound to $_ for the scope of the right side. That is,

```
test1() andthen test2()
```

等价于

```
test1() andthen -> $_ { test2() }
```

There is no corresponding high-precedence version.

Loose or precedence

infix:<or>, short-circuit inclusive or

S02-types/parsing-bool.t lines 7–17  

```
$a or $b or $c ...
```

Returns the first argument that evaluates to true, otherwise returns the result of the last argument. In list context forces a false return to mean (). See || above for high-precedence version.

infix:<xor>, exclusive or

```
$a xor $b xor $c ...
```

Returns the true argument if there is one (and only one). Returns the last argument if all arguments are false. Returns Bool::False otherwise (when more than one argument is true). In list context forces a false return to mean (). See ^^ above for high-precedence version.

infix:<orelse>, proceed on failure

```
test1() orelse test2() orelse test3() ...
```

Returns the first argument that evaluates successfully (that is, if the result is defined). Otherwise returns the result of the right argument.

If the right side is a block or pointy block, the result of the left side is bound to any arguments of the block. If the right side is not a block, a block scope is assumed around the right side, and the result of the left side is implicitly bound to $! for the scope of the right side. That is,

```
test1() orelse test2()
```

等价于

```
test1() orelse -> $! { test2() }
```

(The high-precedence // operator is similar, but does not set $! or treat blocks specially.)

Terminator precedence

As with terms, terminators are not really a precedence level, but looser than the loosest precedence level. They all have the effect of terminating any operator precedence parsing and returning a complete expression to the main parser. They don't care what state the operator precedence parser is in. If the parser is currently expecting a term and the final operator in the expression can't deal with a nullterm, then it's a syntax error. (Notably, the comma operator and many prefix list operators can handle a nullterm.)

Semicolon: ;

```
$x = 1; $y = 2;
```

The context determines how the expressions terminated by semicolon are interpreted. At statement level they are statements. Within a bracketing construct they are interpreted as lists of Parcels, which in lol context will be treated as the multiple dimensions of a multidimensional slice. (Other contexts may have other interpretations or disallow semicolons entirely.)

Feed operators: `<==`, `==>`, `<<==`, `==>>`

```
source() ==> filter() ==> sink()
```

The forms with the double angle append rather than clobber the sink's todo list. The ==>> form always looks ahead for an appropriate target to append to, either the final sink in the chain, or the next filter stage with an explicit @(*) or @(**) target. This means you can stack multiple feeds onto one filter command:

```
source1() ==>>
source2() ==>>
source3() ==>>
filter(@(*)) ==> sink()
```

Similar semantics apply to <<== except it looks backward for an appropriate target to append to.

Control block: <ws>{...}

When a block occurs after whitespace where an infix is expected, it is interpreted as a control block for a statement control construct. (If there is no whitespace, it is a subscript, and if it is where a term is expected, it's just a bare closure.) If there is no statement looking for such a block currently, it is a syntax error.

Statement modifiers: if, unless, while, until, for

Statement modifiers terminate one expression and start another.

Any unexpected ), ], } at this level.

Calls into the operator precedence parser may be parameterized to recognize additional terminators, but right brackets of any sort (except angles) are automatically included in the set of terminators as tokens of length one. (An infix of longer length could conceivably start with one of these characters, and would be recognized under the longest-token rule and continue the expression, but this practice is discouraged. It would be better to use Unicode for your weird operator.) Angle brackets are exempted so that they can form hyperoperators (see "Hyper operators").

A block-final } at the end of the line terminates the current expression. A block within an argument list terminates the argument list unless followed by the comma operator.

Changes to Perl 5 operators

S03-operators/scalar-assign.t lines 8–28  

Several operators have been given new names to increase clarity and better Huffman-code the language, while others have changed precedence.

Perl 5's ${...}, @{...}, %{...}, etc. dereferencing forms are now $(...), @(...), %(...), etc. instead. (Use of the Perl 5 curly forms will result in an error message pointing the user to the new forms.) As in Perl 5, the parens may be dropped when dereferencing a scalar variable.

S03-operators/context.t lines 72–111  

-> becomes ., like the rest of the world uses. There is a pseudo postfix:['->'] operator that produces a compile-time error reminding Perl 5 users to use dot instead. (The "pointy block" use of -> in Perl 6 requires preceding whitespace when the arrow could be confused with a postfix, that is, when an infix is expected. Preceding whitespace is not required in term position.)

-> 变成了 . , 就像世界其它地方使用的一样。

S12-methods/chaining.t lines 7–61  

S12-methods/chaining.t lines 62–79  

The string concatenation . becomes ~. Think of it as "stitching" the two ends of its arguments together. String append is likewise ~=.

S32-str/append.t lines 6–31  

The filetest operators are gone. We now use a Pair as a pattern that calls an object's method:

S16-filehandles/filetest.t lines 16–118  

```
if $filename.IO ~~ :e { say "exists" }
```

is the same as

```
if so $filename.IO.e { say "exists" }
```

Likewise

```
if $filename.IO ~~ :!e { say "doesn't exist" }
```

is the same as

```
if not $filename.IO.e { say "doesn't exist" }
```

The 1st form actually translates to the latter form, so the object's class decides how to dispatch methods. It just so happens that the IO role defaults to the expected filetest semantics, but $regex.i might tell you whether the regex is case insensitive, for instance. Likewise, you can test anything for definedness or undefinedness:

```
$obj ~~ :defined
$obj ~~ :!defined
```

Using the pattern form, multiple tests may be combined via junctions:

```
given $handle {
    when :r & :w & :x {...}
    when :!w | :!x    {...}
    when *            {...}
}
```

When adverbial pairs are stacked into one term, it is assumed they are ANDed together, so

```
when :r :w :x
```

等价于

either of:

```
when :r & :w & :x
when all(:r,:w,:x)
```

The pair forms are useful only for boolean tests because the method's value is evaluated as a Bool, so the method form must be used for any numeric-based tests:

```
if stat($filename).s > 1024 {...}
```

However, these still work:

```
given $fh {
    when :s  {...} # file has size > 0
    when :!s {...} # file size == 0
}
```

One advantage of the method form is that it can be used in places that require tighter precedence than ~~ provides:

```
sort { $^a.M <=> $^b.M }, @files».IO
```

though that's a silly example since you could just write:

```
sort { .M }, @files».IO
```

But that demonstrates the other advantage of the method form, which is that it allows the "unary dot" syntax to test the current topic.

Unlike in earlier versions of Perl 6, these filetest methods do not return stat buffers, but simple scalars of type Bool, Int, or Num.

In general, the user need not worry about caching the stat buffer when a filename is queried. The stat buffer will automatically be reused if the same object has recently been queried, where "recently" is defined as less than a second or so. If this is a concern, an explicit stat() or lstat() may be used to return an explicit IO object that will not be subject to timeout, and may be tested repeatedly just as a filename or handle can. An IO object has a .path method that can be queried for its path (if known).

(Inadvertent use of the Perl 5 forms will normally result in treatment as a negated postdeclared subroutine, which is likely to produce an error message at the end of compilation.)

All postfix operators that do not start with a dot also have an alternate form that does. (The converse does not hold--just because you can write x().foo doesn't mean you can write x()foo. Likewise the ability to say $x.'foo' does not imply that $x'foo' will work.)

The postfix interpretation of an operator may be overridden by use of a quoted method call, which calls the prefix form instead. So x().! is always the postfix operator, but x().'!' will always call !x(). In particular, you can say things like $array.'@'. This also includes any operator that would look like something with a special meaning if used after the method-calling dot. For example, if you defined a prefix:<=>, and you wanted to write it using the method-call syntax instead of =$object, the parser would take $object.= as the mutation syntax (see S12, "Mutating methods"). Writing $object.'=' will call your prefix operator.

Unary ~ now imposes a string (Stringy) context on its argument, and + imposes a numeric (Numeric) context (as opposed to being a no-op in Perl 5). Along the same lines, ? imposes a boolean (Bool) context, and the | unary operator imposes a function-arguments (Parcel or Capture) context on its argument. Unary sigils are allowed when followed by a $ sigil on a scalar variable; they impose the container context implied by their sigil. As with Perl 5, however, $$foo[bar] parses as ( $($foo) )[bar], so you need $($foo[bar]) to mean the other way. In other words, sigils are not really parsed as operators, and you must use the parenthetical form for anything complicated.

S03-operators/context-forcers.t lines 113–132  

S03-operators/context-forcers.t lines 134–161  

Bitwise operators get a data type prefix: +, ~, or ?. For example, Perl 5's | becomes either +| or ~| or ?|, depending on whether the operands are to be treated as numbers, strings, or boolean values. Perl 5's left shift << becomes +< , and correspondingly with right shift. Perl 5's unary ~ (one's complement) becomes either +^ or ~^ or ?^, since a bitwise NOT is like an exclusive-or against solid ones. Note that ?^ is functionally identical to !, but conceptually coerces to boolean first and then flips the bit. Please use ! instead. As explained in "Assignment operators", a bitwise operator can be turned into its corresponding assignment operator by following it with =. For example Perl 5's <<= becomes +<= .

S03-operators/bit.t lines 13–135  

?| is a logical OR but differs from || in that ?| always evaluates both sides and returns a standard boolean value. That is, it's equivalent to ?$a + ?$b != 0. Another difference is that it has the precedence of an additive operator.

?& is a logical AND but differs from && in that ?& always evaluates both sides and returns a standard boolean value. That is, it's equivalent to ?$a * ?$b != 0. Another difference is that it has the precedence of a multiplicative operator.

Bitwise string operators (those starting with ~) may only be applied to buf types or similar compact integer arrays, and treat the entire chunk of memory as a single huge integer. They differ from the + operators in that the + operators would try to convert the string to a number first on the assumption that the string was an ASCII representation of a number.

x splits into two operators: x (which concatenates repetitions of a string to produce a single string), and xx (which creates a list of repetitions of a list or item). "foo" xx * represents an arbitrary number of copies, useful for initializing lists. The left side of an xx is re-evaluated for each copy; use a temporary to force a single evaluation. (But note that this is not necessary when the optimizer will do constant folding.)

S03-operators/repeat.t lines 13–24  

S03-operators/repeat.t lines 25–104  

The ? : conditional operator becomes ?? !!. A pseudo operator, infix:<?>, catches migratory brainos at compile time.

S03-operators/ternary.t lines 8–77  

qw{ ... } gets a synonym: < ... >, and an interpolating variant, «...». For those still living without the blessings of Unicode, that can also be written: << ... >>.

Comma , now constructs a Parcel object from its operands. In item context this turns into a Seq object. You have to use a [*-1] subscript to get the last one. (Note the *. Negative subscripts no longer implicitly count from the end; in fact, the compiler may complain if you use [-1] on an object known at compile time not to have negative subscripts.)

The unary backslash operator is not really an operator, but a special noun form. It "captures" its argument or arguments, and returns an object representing those arguments. You can dereference this object in several ways to retrieve different parts of the arguments; see the definition of Capture in S02 for details. (No whitespace is allowed after the backslash because that would instead start an "unspace", that is, an escaped sequence of whitespace or comments. See S02 for details. However, oddly enough, because of that unspace rule, saying \\ $foo turns out to be equivalent to \$foo.)

The old .. flipflop operator is now done with ff operator. (.. now always produces a Range object even in item context.) The ff operator may take a caret on either end to exclude either the beginning or ending. There is also a corresponding fff operator with Perl 5's ... semantics.

S03-operators/flip-flop.t lines 7–143  

The two sides of a flipflop are evaluated as smartmatches against the current value of the topic stored in $_. For instance, you may say

```
/foo/ ff *
```

to match the first line containing 'foo', along with all following lines: since the * always smartmatches, it create a flipflop that never flops once flipped.

The state of a flipflop is kept in an anonymous state variable, so separate closure clones get their own states.

Note that unlike Perl 5's flipflop, numeric values are not automatically checked against the current line number. (If you wish to have those semantics for your smartmatches, you could mixin a numeric value to $_ to create a chimeric object that is both integer and string. Conjecture: lines() should have an option that does this.)

All comparison operators are unified at the same precedence level. See "Chained comparisons" below.

The list assignment operator now parses on the right like any other list operator, so you don't need parens on the right side of:

S03-operators/assign-is-not-binding.t lines 9–49  

S03-operators/assign.t lines 7–823  

```
@foo = 1, 2, 3;
```

You do still need them on the left for

```
($a, $b, $c) = 1, 2, 3;
```

since assignment operators are tighter than comma to their left.

"Don't care" positions may be indicated by assignment to the * token. A final * throws away the rest of the list:

```
($a, *, $c) = 1, 2, 3;      # throw away the 2
($a, $b, $c, *) = 1..42;    # throw away 4..42
```

(Within signature syntax, a bare $ can ignore a single argument as well, and a bare *@ can ignore the remaining arguments.)

List assignment offers the list on the right to each container on the left in turn, and each container may take one or more elements from the front of the list. If there are any elements left over, a warning is issued unless the list on the left ends with * or the final iterator on the right is defined in terms of *. Hence none of these warn:

```
($a, $b, $c, *) = 1..9999999;
($a, $b, $c) = 1..*;
($a, $b, $c) = 1 xx *;
($a, $b, $c) = 1, 2, *;
```

This, however, warns you of information loss:

```
($a, $b, $c) = 1, 2, 3, 4;
```

As in Perl 5, assignment to an array or hash slurps up all the remaining values, and can never produce such a warning. (It will, however, leave any subsequent lvalue containers with no elements, just as in Perl 5.)

The left side is evaluated completely for its sequence of containers before any assignment is done. Therefore this:

```
my $a = 0; my @b;
($a, @b[$a]) = 1, 2;
```

assigns 2 to @b[0], not @b[1].

The item assignment operator expects a single expression with precedence tighter than comma, so

```
loop ($a = 1, $b = 2; ; $a++, $b++) {...}
```

works as a C programmer would expect. The term on the right of the = is always evaluated in item context.

The syntactic distinction between item and list assignment is similar to the way Perl 5 defines it, but has to be a little different because we can no longer decide the nature of an inner subscript on the basis of the outer sigil. So instead, item assignment is restricted to lvalues that are simple scalar variables, and assignment to anything else is parsed as list assignment. The following forms are parsed as "simple lvalues", and imply item assignment to the scalar container:

```
$a = 1          # scalar variable
$foo::bar = 1   # scalar package variable
$(ANY) = 1      # scalar dereference (including $$a)
$::(ANY) = 1    # symbolic scalar dereference
$foo::(ANY) = 1 # symbolic scalar dereference
```

Such a scalar variable lvalue may be decorated with declarators, types, and traits, so these are also item assignments:

```
my $fido = 1
my Dog $fido = 1
my Dog $fido is trained is vicious = 1
```

However, anything more complicated than that (including parentheses and subscripted expressions) forces parsing as list assignment instead. Assignment to anything that is not a simple scalar container also forces parsing as list assignment. List assignment expects an expression that is looser than comma precedence. The right side is always evaluated in list context:

```
($x) = 1,2,3
$x[1] = 1,2,3
@$array = 1,2,3
my ($x, $y) = 1,2,3
our %hash = :a<1>, :b<2>
```

The rules of list assignment apply, so all the assignments involving $x above produce warnings for discarded values. A warning may be issued at compile time if it is detected that a run-time warning is inevitable.

The = in a default declaration within a signature is not really assignment, and is always parsed as item assignment. (That is, to assign a list as the default value you must use parentheses to hide any commas in the list value.)

To assign a list to a scalar value, you cannot say:

把列表赋值给标量, 你可以这样写:

``` perl
    $a = 1, 2, 3;
    ($a = 1), 2, 3; # 2 和 3 的上下文为空
```

Instead, you must do something to explicitly disable or subvert the item assignment interpretation:

显式的禁用或破坏 item 赋值解释:

``` perl
    $a = [1, 2, 3];             # 强制构建 (或许是最佳实践)
    $a = (1, 2, 3);             # force grouping as syntactic item
    $a = list 1, 2, 3;          # force grouping using listop precedence
    $a = @(1, 2, 3);            # same thing
    @$a = 1, 2, 3;              # 强制列表赋值
    $a[] = 1, 2, 3;             # same thing
```

If a function is contextually sensitive and you wish to return a scalar value, you must use item (or $ or + or ~) if you wish to force item context for either the subscript or the right side:

``` perl
    @a[foo()] = bar();           # foo() and bar() called in list context
    @a[item foo()] = item bar(); # foo() and bar() called in item context
    @a[$(foo())] = $(bar());     # same thing
    @a[+foo()] = +bar();         # foo() and bar() called in numeric context
    %a{~foo()} = ~bar();         # foo() and bar() called in string context
```

But note that the first form still works fine if foo() and bar() are item-returning functions that are not context sensitive.

In general, this will all just do what the user expects most of the time. The rest of the time item or list behavior can be forced with minimal syntax.

List operators are all parsed consistently. As in Perl 5, to the left a list operator looks like a term, while to the right it looks like an operator that is looser than comma. Unlike in Perl 5, the difference between the list operator form and the function form is consistently indicated via whitespace between the list operator and the first argument. If there is whitespace, it is always a list operator, and the next token will be taken as the first term of the list (or if there are no terms, as the expression terminator). Any infix operator occurring where a term is expected will be misinterpreted as a term:

```
say + 2;    # means say(+2);
```

If there is no whitespace, subsequent parsing depends on the syntactic category of the next item. Parentheses (with or without a dot) turn the list operator into a function call instead, and all the function's arguments must be passed inside the parentheses (except for postfix adverbs, which may follow the parentheses provided they would not attach to some other operator by the rules of precedence).

A postfix operator following a listop is parsed as working on the return value of the listop.

```
foo.[]      # same as foo()[]
foo.()      # same as foo()()
foo++       # legal (if foo() is rw)
```

If the next item after the list operator is an infix operator, a syntax error is reported.

Examples:

``` perl
    say foo + 1;                        say(foo(+1));
    say foo $x;                         say(foo($x));
    say foo$x;                          ILLEGAL, need space or parens
    say foo+1;                          ILLEGAL, need space or parens
    say foo($bar+1),$baz                say(foo($bar+1), $baz);
    say foo.($bar+1),$baz               say(foo().($bar+1), $baz);
    say foo ($bar+1),$baz               say(foo($bar+1, $baz));
    say foo .($bar+1),$baz              say(foo($_.($bar+1), $baz));
    say foo[$bar+1],$baz                say((foo()[$bar+1]), $baz);
    say foo.[$bar+1],$baz               say((foo()[$bar+1]), $baz);
    say foo [$bar+1],$baz               say(foo([$bar+1], $baz));
    say foo .[$bar+1],$baz              say(foo($_.[$bar+1], $baz));
    say foo{$bar+1},$baz                say((foo(){$bar+1}), $baz);
    say foo.{$bar+1},$baz               say((foo(){$bar+1}), $baz);
    say foo {$bar+1},$baz               say(foo({$bar+1}, $baz));
    say foo .{$bar+1},$baz              say(foo($_.{$bar+1}, $baz));
    say foo<$bar+1>,$baz                say(foo()<$bar+1>, $baz);
    say foo.<$bar+1>,$baz               say(foo()<$bar+1>, $baz);
    say foo <$bar+1>,$baz               say(foo(<$bar+1>, $baz));
    say foo .<$bar+1>,$baz              say(foo($_.<$bar+1>, $baz));
```

Note that Perl 6 is making a consistent three-way distinction between term vs postfix vs infix, and will interpret an overloaded character like < accordingly:

S03-operators/list-quote-junction.t lines 37–54  

```
any <a b c>                 any('a','b','c')        # term
any()<a b c>                (any).{'a','b','c'}     # postfix
any() < $x                  (any) < $x              # infix
any<a b c>                  ILLEGAL                 # stealth postfix
```

This will seem unfamiliar and "undwimmy" to Perl 5 programmers, who are used to a grammar that sloppily hardwires a few postfix operators at the price of extensibility. Perl 6 chooses instead to mandate a whitespace dependency in order to gain a completely extensible class of postfix operators.

A list operator's arguments are also terminated by a closure that is not followed by a comma or colon. (And a semicolon is implied if the closure is the final thing on a line. Use an "unspace" to suppress that.) This final closure may be followed by a postfix, in which case the postfix is applied to the result of the entire list operator.

A function predeclared with an empty signature is considered 0-ary at run time but is still parsed as a list prefix operator, and looks for a following argument list, which it may reject at run time.

```
my sub foo () {...};
foo;          # okay
foo();        # okay
foo (),(),(); # okay
foo 1;        # fails to dispatch
```

The compiler is allowed to complain about anything it knows cannot succeed at run time. Note that a multi may contain () as one of its signatures, however:

```
my multi foo () {...};
my multi foo ($x) {...};
foo;          # okay
foo();        # okay
foo (),(),(); # okay
foo 1;        # okay
```

To declare an item that is parsed as a simple term, you must use the form term:<foo>, or some other form of constant declaration such as an enum declaration. Such a term never looks for its arguments, is never considered a list prefix operator, and may not work with subsequent parentheses because it will be parsed as a function call instead of the intended term. (The function in question may or may not exist.) For example, rand is a simple term in Perl 6 and does not allow parens, because there is no rand() function (though there's a $n.rand method). Most constant values such as e and pi are in the same category. After parsing one of these the parser expects to see a postfix or an infix operator, not a term. Therefore any attempt to use a simple value as a list operator is destined to fail with an error indicating the parser saw two terms in a row.

For those values (such as types) that do respond to parentheses (that is, that do the Callable role), the parentheses (parsed as a postfix operator) are required in order to invoke the object:

```
my $i = Int.($x);   # okay
my $i = Int($x);    # okay
my $i = Int $x;     # ILLEGAL, two terms in a row
```

A non-multi sub predeclared with an arity of exactly 1 also still parses as a list prefix operator expecting multiple arguments. You must explicitly use the form prefix:<foo> to declare foo as a named unary in precedence; it must still take a single positional parameter (though any number of named parameters are allowed, which can be bound to adverbs). All other subs with arguments parse as list operators.

Junctive operators

S03-junctions/associative.t lines 16–39  

S03-junctions/boolean-context.t lines 5–158  

S03-junctions/misc.t lines 23–152  

S03-junctions/misc.t lines 153–158  

|, &, 和 ^ 不再是位操作符了，它们现在是 junction 构造器。junction 是单个值等价于多个值。它们穿透操作符， 返回另一个表示结果的 junction：

S03-operators/misc.t lines 68–92  

S03-junctions/misc.t lines 159–169  

S03-junctions/misc.t lines 234–434  

```
 (1|2|3) + 4;                            # 5|6|7
 (1|2) + (3&4);                          # (4|5) & (5|6)
```

As illustrated by the last example, when two junctions are applied through a single operator, the result is a junction representing the application of the operator to each possible combination of values.

Junctions 还有 `any`， `all`，`one`， `none` 的函数变体。

 这为像这样的构造打开了大门。

S03-junctions/misc.t lines 170–192  

```
 if $roll == none(1..6) { print "Invalid roll" }
 if $roll == 1|2|3      { print "Low roll"     }
```

Junctions work through subscripting:

S03-junctions/misc.t lines 193–208  

```
doit() if @foo[any(1,2,3)]
```

Junctions 是没有顺序的。 所以如果你这样写：

S03-junctions/misc.t lines 209–233  

```
foo() | bar() | baz() == 42
```

这向编译器表明 junctional 参数之间没有耦合（coupling）。它们可以以任意顺序求值或并行地求值。它们也可以是短路的, 只要它们中的任何一个返回 42, 并且其它的不会被运行。或者, 如果并行地运行, 第一个成功的线程会突然终止其它的线程。一般地, 在 junctions 中, 你可能需要避免带有副作用的代码。

Use of negative operators with junctions is potentially problematic if autothreaded naively. However, by defining != and ne in terms of the negation metaoperator, we automatically get the "not raising" that is expected by an English speaker. That is

S03-junctions/autothreading.t lines 292–350  

```
if $a != 1 | 2 | 3 {...}
```

really means

```
if $a ![==] 1 | 2 | 3 {...}
```

which the metaoperator rewrites to a higher-order function resembling something like:

```
negate((* == *), $a, (1|2|3));
```

which ends up being equivalent to:

```
if not $a == 1 | 2 | 3 {...}
```

which is the semantics an English speaker expects. However, it may well be better style to write the latter form yourself.

Junctive methods on arrays, lists, and sets work just like the corresponding list operators. However, junctive methods on a hash make a junction of only the hash's keys. Use the listop form (or an explicit .pairs) to make a junction of pairs.

The various operators for sets and bags (intersection, union, etc.) also have junctive precedence (except for those that return Bool, which are instead classified as chaining operators).

Comparison semantics

S03-operators/equality.t lines 11–54  

S03-operators/comparison.t lines 13–71  

S03-operators/comparison-simple.t lines 8–41  

Perl 5's comparison operators are basically unchanged, except that they can be chained because their precedence is unified.

Binary === tests immutable type and value correspondence: for two value types (that is, immutable types), tests whether they are the same value (eg. 1 === 1); for two mutable types (object types), checks whether they have the same identity value. (For most such types the identity is simply the reference itself.) It is not true that [1,2] === [1,2] because those are different Array objects, but it is true that @a === @a because those are the same Array object).

Any object type may pretend to be a value type by defining a .WHICH method which returns a value type that can be recursively compared using ===, or in cases where that is impractical, by overloading === such that the comparison treats values consistently with their "eternal" identity. (Strings are defined as values this way despite also being objects.)

Two values are never equivalent unless they are of exactly the same type. By contrast, eq always coerces to string, while == always coerces to numeric. In fact, $a eq $b really means "~$a === ~$b" and $a == $b means +$a === +$b.

Note also that, while string-keyed hashes use eq semantics by default, object-keyed hashes use === semantics, and general value-keyed hashes use eqv semantics.

Binary eqv tests equality much like === does, but does so with "snapshot" semantics rather than "eternal" semantics. For top-level components of your value that are of immutable types, eqv is identical in behavior to ===. For components of your value that are mutable, however, rather than comparing object identity using ===, the eqv operator tests whether the canonical representation of both subvalues would be identical if we took a snapshot of them right now and compared those (now-immutable) snapshots using ===.

S03-operators/eqv.t lines 6–170  

If that's not enough flexibility, there is also an eqv() function that can be passed additional information specifying how you want canonical values to be generated before comparison. This gives eqv() the same kind of expressive power as a sort signature. (And indeed, the cmp operator from Perl 5 also has a functional analog, cmp(), that takes additional instructions on how to do 3-way comparisons of the kind that a sorting algorithm wants.) In particular, a signature passed to eqv() will be bound to the two operands in question, and then the comparison will proceed on the formal parameters according to the information contained in the signature, so you can force numeric, string, natural, or other comparisons with proper declarations of the parameter's type and traits. If the signature doesn't match the operands, eqv() reverts to standard eqv comparison. (Likewise for cmp().)

Binary cmp is no longer the comparison operator that forces stringification. Use the leg operator for the old Perl 5 cmp semantics. The cmp is just like the eqv above except that instead of returning Bool::False or Bool::True values it always returns Order::Less, Order::Same, or Order::More (which numerify to -1, 0, or +1).

The leg operator (less than, equal to, or greater than) is defined in terms of cmp, so $a leg $b is now defined as ~$a cmp ~$b. The sort operator still defaults to cmp rather than leg. The <=> operator's semantics are unchanged except that it returns an Order value as described above. In other words, $a <=> $b is now equivalent to +$a cmp +$b.

S03-operators/spaceship-and-containers.t lines 6–20  

For boolean comparison operators with non-coercive cmp semantics, use the generic before and after infix operators. As ordinary infix operators these may be negated (!before and !after) as well as reduced ([before] and [after]).

Infix min and max may be used to select one or the other of their arguments. Reducing listop forms [min] and [max] are also available, as are the min= and max= assignment operators. By default min and max use cmp semantics. As with all cmp-based operators, this may be modified by an adverb specifying different semantics.

Note that, like most other operators, a comparison naturally returns failure if either of its arguments is undefined, and the general policy on unthrown exceptions is that the exception is thrown as soon as you try to use the exception as a real value. However, various parallelizable contexts such as hyper (or other "mass production" contexts such as sort) will pass through unthrown exceptions rather than throwing them.

Range and RangeIter semantics 范围和范围迭代器语法

`..` 范围操作符有各种在两端带有 `^`符号的变体以表明把那个端点排除在范围之外。 它总会产生一个 Range 对象。 Range 对象是不可变的， 主要用于匹配间隔。

1..2 是从1到2包含端点的间隔，  而 1^..^2 不包含端点但是匹配任何在它俩之间的实数。

S03-operators/range.t lines 38–232  

对于不同类型的数字参数， 范围会被强制为更宽的类型，所以：

``` perl
1 .. 1.5
```

被看作为：

``` perl
1.0 .. 1.5
```

这些强制由 multi 签名定义。（其它类型可能有不同的强制策略。）特别要说明的是， 使用 Range 作为末端是非法的：

``` perl
0 ..^ 10  # 0 .. 9
0 .. ^10  # ERROR
```

如果范围右侧是非数字类型， 那么右侧的参数被强转为数字， 然后按上面那样使用。

因此，第二个参数中的 Array 类型会被假定用作数字， 如果左侧的参数是数字的话：

``` perl
0 ..^ @x    # okay
0 ..^ +@x   # same thing
```

 对于字符串也类似：

``` perl
0 .. '1.5'  # okay
0 .. +'1.5' # same thing
```

Whatever 类型也支持代表 -Inf/+Inf。 如果端点之一是一个 WhateverCode, 那么范围会被引导为另一个 WhateverCode。

For other types, ranges may be composed for any two arguments of the same type, if the type itself supports it. That is, in general, infix:<..>:(::T Any $x, T $y) is defined such that, if type T defines generic comparison (that is, by defining infix:<cmp> or equivalent), a range is constructed in that type. If T also defines .succ, then the range may be iterated. (Otherwise the range may only be used as an interval, and will return failure if asked for a RangeIter.) Note that it is not necessary to define a range multimethod in type T, since the generic routine can usually auto-generate the range for you.



Range 对象支持代表它们的左侧和右侧参数的 .min 和 .max 方法。 .bounds 方法返回一个含有那两个值的列表以代表间隔。 Ranges 不会自动反转：

2..1 总是一个 null 范围。（然而， 序列操作符 .. 能够自动反转，看下面。）

在 Range 的每个端点处， Range 对象支持代表排除（有^）或包含（没有^）的 `.excludes_min` and `.excludes_max` 方法。

```
Range      | .min | .max | .excludes_min | .excludes_max
-----------+------+------+---------------+------------
1..10      | 1    | 10   | Bool::False   | Bool::False
2.7..^9.3  | 2.7  | 9.3  | Bool::False   | Bool::True
'a'^..'z'  | 'a'  | 'z'  | Bool::True    | Bool::False
1^..^10    | 1    | 10   | Bool::True    | Bool::True
```

如果用在列表上下文中， Range 对象返回一个迭代器， 它产生一个以最小值开头，以最大值结尾的序列。

任一端点可以使用 ^ 排除掉。因此 1..2 产生 (1,2) 但是 `1^..^2` 等价于 2..1 并不产生值， 就像 () 做的那样。要指定一个倒数的序列， 使用反转：

``` perl
reverse 1..2
reverse 'a'..'z'
```

作为选择， 对于数字序列， 你能使用序列操作符代替范围操作符：

``` perl
100,99,98 ... 0
100, *-1 ... 0      # same thing
```

换句话说，任何用作列表的 Range 会假定 .succ 语义， 绝对不会是 `.pred` 语义。 没有其它的增量被允许；如果你想通过某个不是 1 的增量数字来增加一个数字序列，

你必须使用 ... 序列操作符。（Range 操作符的 `:by` 副词因此被废弃了。）

```
0, *+0.1 ... 100    # 0, 0.1, 0.2, 0.3 ... 100
```

只有正念叨的类型支持 .succ 方法的 Range 才能被迭代。如果它不支持， 任何迭代尝试都会失败。

Smart matching against a Range object does comparisons (by coercion, if necessary) in the Real domain if either endpoint does Real. Otherwise comparison is in the Stringy domain if either argument does Stringy. Otherwise the min's type is used if it defines ordering, or if not, the max's type. If neither min nor max have an ordering, dispatch to .ACCEPTS fails. It may also fail if the ordering in question does not have any way to coerce the object being smartmatched into an appropriate type implied by the chosen domain of ordering.

In general, the domain of comparison should be a type that can represent all the values in question, if possible. Hence, since Int is not such a type, it is promoted to a Real, so fractional numbers are not truncated before comparison to integer ranges. Instead the integers are assumed to represent points on the real number line:

```
1.5 ~~ 1^..^2  # true, equivalent to 1 < 1.5 < 2
2.1 ~~ 1..2    # false, equivalent to 1 <= 2.1 <= 2
```

If a * (see the "Whatever" type in S02) occurs on the right side of a range, it is taken to mean "positive infinity" in whatever typespace the range is operating, as inferred from the left operand. A * on the left means "negative infinity" for types that support negative values, and the first value in the typespace otherwise as inferred from the right operand. (A star on both sides is not allowed.)

```
0..*        # 0 .. +Inf
'a'..*      # 'a' le $_
*..0        # -Inf .. 0
*..*        # Illegal
v1.2.3 .. * # Any version higher than 1.2.3.
May .. *    # May through December
```

An empty range cannot be iterated; it returns () instead. An empty range still has a defined .min and .max, but one of the following is true: 1. The .min is greater than the .max. 2. The .min is equal to the .max and at least one of .excludes_min or .excludes_max is true. 3. Both .excludes_min and .excludes_max are true and .min and .max are consecutive values in a discrete type that cannot create new values between those two consecutive values. For this purpose, interval representations in Real (including integers) are considered infinitely divisible even though there is a practical limit depending on the actual representation, so #3 does not apply. (Nor does it apply to strings, versions, instants, or durations. #3 does apply to enums, however, so Tue ^..^ Wed is considered empty because the enum in question does not define "Tuesday and a half".)

An empty range evaluates to False in boolean context; all other ranges evaluate to True.

Ranges that are iterated transmute into the corresponding sequence operator, using .succ semantics to find the next value, and the appropriate inequality semantics to determine an end to the sequence. For a non-discrete type with a discrete .succ (such as Real), it is possible to write a range that, when iterated, produces no values, but evaluates to true, because the .succ function skips over divisible intervals:

```
say +( 0 ^..^ 1 )   # 0 elements
say ?( 0 ^..^ 1 )   # True
say 0.5 ~~ 0 ^..^ 1 # True; range contains non-integer values
```

Unary ranges 一元区间

一元操作符 ^ 生成一个从 0 直到 其参数（不包括该参数）的区间。所以 ^4 等价于  0..^4.

```
for ^4 { say $_ } # 0, 1, 2, 3
```

Auto-priming of ranges

[This section is conjectural, and may be ignored for 6.0.]

Since use of Range objects in item context is usually non-sensical, a Range object used as an operand for scalar operators will generally attempt to distribute the operator to its endpoints and return another suitably modified Range instead, much like a junction of two items, only with proper interval semantics. (Notable exceptions to this autothreading include infix:<~~>, which does smart matching, and prefix:<+> which returns the length of the range.) Therefore if you wish to write a slice using a length instead of an endpoint, you can say

```
@foo[ start() + ^$len ]
```

which is short for:

```
@foo[ start() + (0..^$len) ]
```

which 等价于 something like:

```
@foo[ list do { my $tmp = start(); $tmp ..^ $tmp+$len } ]
```

In other words, operators of numeric and other ordered types are generally overloaded to do something sensible on Range objects.

Chained comparisons 链式比较

S03-operators/relational.t lines 96–176  

Perl 6 支持比较操作符的天然扩展, 允许多个操作数:

``` perl
 if 1 < $a < 100                        { say "Good, you picked a number *between* 1 and 100." }
 if 3 < $roll <= 6                      { print "High roll"  }
 if 1 <= $roll1 == $roll2 <= 6          { print "Doubles!"   }
```

A chain of comparisons short-circuits if the first comparison fails:

S03-operators/short-circuit.t lines 248–316  

```
1 > 2 > die("this is never reached");
```

Each argument in the chain will evaluate at most once:

S03-operators/short-circuit.t lines 238–247  

```
1 > $x++ > 2    # $x increments exactly once
```

Note: any operator beginning with < must have whitespace in front of it, or it will be interpreted as a hash subscript instead.

Smart matching

Here is the table of smart matches for standard Perl 6 (that is, the dialect of Perl in effect at the start of your compilation unit). Smart matching is generally done on the current "topic", that is, on $_. In the table below, $_ represents the left side of the ~~ operator, or the argument to a given, or to any other topicalizer. X represents the pattern to be matched against on the right side of ~~, or after a when. (And, in fact, the ~~ operator works as a small topicalizer; that is, it binds $_ to the value of the left side for the evaluation of the right side. Use the underlying .ACCEPTS form to avoid this topicalization.)

The first section contains privileged syntax; if a match can be done via one of those entries, it will be. These special syntaxes are dispatched by their form rather than their type. Otherwise the rest of the table is used, and the match will be dispatched according to the normal method dispatch rules. The optimizer is allowed to assume that no additional match operators are defined after compile time, so if the pattern types are evident at compile time, the jump table can be optimized. However, the syntax of this part of the table is still somewhat privileged, insofar as the ~~ operator is one of the few operators in Perl that does not use multiple dispatch. Instead, type-based smart matches singly dispatch to an underlying method belonging to the X pattern object.

In other words, smart matches are dispatched first on the basis of the pattern's form or type (the X below), and then that pattern itself decides whether and how to pay attention to the type of the topic ($_). So the second column below is really the primary column. The Any entries in the first column indicate a pattern that either doesn't care about the type of the topic, or that picks that entry as a default because the more specific types listed above it didn't match.

```
$_        X         Type of Match Implied   Match if (given $_)
======    =====     =====================   ===================
Any       True      ~~ True                 (parsewarn on literal token)
Any       False     ~~ False match          (parsewarn on literal token)
Any       Match     ~~ Successful match     (parsewarn on literal token)
Any       Nil       ~~ Benign failure       (parsewarn on literal token)
Any       Failure   Failure type check      (okay, matches against type)
Any       *         block signature match   block successfully binds to |$_
Any       Callable:($)  item sub truth          X($_)
```

S03-smartmatch/any-callable.t lines 5–14  

```
Any       Callable:()   simple closure truth    X() (ignoring $_)
```

S03-smartmatch/any-callable.t lines 15–26  

```
Any       Bool      simple truth            X (treats Bool value as success/failure)
```

S03-smartmatch/any-bool.t lines 5–27  

```
Any       Match     match success           X (treats Match value as success)
Any       Nil       benign failure          X (treats Nil value as failure)
Any       Failure   malign failure          X (passes Failure object through)
Any       Numeric   numeric equality        +$_ == X
Any       Stringy   string equality         ~$_ eq X
Any       Whatever  always matches          True
Hash      Pair      test hash mapping       $_{X.key} ~~ X.value
```

S03-smartmatch/any-hash-pair.t lines 5–19  

```
Any       Pair      test object attribute   ?."{X.key}" === ?X.value (e.g. filetests)
```

S03-smartmatch/any-pair.t lines 5–37  

```
Set       Set       identical sets          $_ === X
Hash      Set       hash keys same set      $_.keys === X
Any       Set       force set comparison    Set($_) === X
Array     Array     arrays are comparable   $_ «===» X (dwims * wildcards!)
```

S03-smartmatch/array-array.t lines 5–90  

```
Set       Array     array equiv to set      $_ === Set(X)
Any       Array     lists are comparable    @$_ «===» X
```

S03-smartmatch/any-array.t lines 5–30  

```
Hash      Hash      hash keys same set      $_.keys === X.keys
```

S03-smartmatch/hash-hash.t lines 7–27  

```
Set       Hash      hash keys same set      $_ === X.keys
Array     Hash      hash slice existence    X.{any @$_}:exists
```

S03-smartmatch/array-hash.t lines 5–24  

```
Regex     Hash      hash key grep           any(X.keys).match($_)
```

S03-smartmatch/regex-hash.t lines 5–16  

```
Cool      Hash      hash entry existence    X.{$_}:exists
```

S03-smartmatch/scalar-hash.t lines 5–15  

```
Any       Hash      hash slice existence    X.{any @$_}:exists
Str       Regex     string pattern match    .match(X)
Hash      Regex     hash key "boolean grep" .any.match(X)
Array     Regex     array "boolean grep"    .any.match(X)
Any       Regex     pattern match           .match(X)
Num       Range     in numeric range        X.min <= $_ <= X.max (mod ^'s)
```

S03-smartmatch/disorganized.t lines 31–152  

```
Str       Range     in string range         X.min le $_ le X.max (mod ^'s)
Range     Range     subset range            !$_ or .bounds.all ~~ X (mod ^'s)
```

S03-smartmatch/range-range.t lines 5–31  

```
Any       Range     in generic range        [!after] X.min,$_,X.max (etc.)
Any       Type      type membership         $_.does(X)
```

S03-smartmatch/any-type.t lines 5–45  

```
Signature Signature sig compatibility       $_ is a subset of X      ???
Callable  Signature sig compatibility       $_.sig is a subset of X  ???
Capture   Signature parameters bindable     $_ could bind to X (doesn't!)
Any       Signature parameters bindable     |$_ could bind to X (doesn't!)
Signature Capture   parameters bindable     X could bind to $_
Any       Any       scalars are identical   $_ === X
```

S03-smartmatch/any-any.t lines 5–34  

The final rule is applied only if no other pattern type claims X.

All smartmatch types are "itemized"; both ~~ and given/when provide item contexts to their arguments, and autothread any junctive matches so that the eventual dispatch to .ACCEPTS never sees anything "plural". So both $_ and X above are potentially container objects that are treated as scalars. (You may hyperize ~~ explicitly, though. In this case all smartmatching is done using the type-based dispatch to .ACCEPTS, not the form-based dispatch at the front of the table.)

The exact form of the underlying type-based method dispatch is:

```
X.ACCEPTS($_)
```

As a single dispatch call this pays attention only to the type of X initially. The ACCEPTS method interface is defined by the Pattern role. Any class composing the Pattern role may choose to provide a single ACCEPTS method to handle everything, which corresponds to those pattern types that have only one entry with an Any on the left above. Or the class may choose to provide multiple ACCEPTS multi-methods within the class, and these will then redispatch within the class based on the type of $_.

The smartmatch table is primarily intended to reflect forms and types that are recognized at compile time. To avoid an explosion of entries, the table assumes the following types will behave similarly:

```
Actual type                 Use entries for
===========                 ===============
Iterator Seq                Array
SetHash BagHash MixHash     Hash
named values created with
  Class, Enum, or Role,
  or generic type binding   Type
Char Cat                    Str
Int UInt etc.               Num
Byte                        Str or Int
Buf                         Str or Array of Int
```

(Note, however, that these mappings can be overridden by explicit definition of the appropriate ACCEPTS methods. If the redefinition occurs at compile time prior to analysis of the smart match then the information is also available to the optimizer.)

A Buf type containing any bytes or integers outside the ASCII range may silently promote to a Str type for pattern matching if and only if its relationship to Unicode is clearly declared or typed. This type information might come from an input filehandle, or the Buf role may be a parametric type that allows you to instantiate buffers with various known encodings. In the absence of such typing information, you may still do pattern matching against the buffer, but (apart from assuming the lowest 7 bits represent ASCII) any attempt to treat the buffer as other than a sequence of integers is erroneous, and warnings may be generously issued.

Matching against a Grammar treats the grammar as a typename, not as a grammar. You need to use the .parse or .parsefile methods to invoke a grammar.

Matching against a Signature does not actually bind any variables, but only tests to see if the signature could bind. To really bind to a signature, use the * pattern to delegate binding to the when statement's block instead. Matching against * is special in that it takes its truth from whether the subsequent block is bound against the topic, so you can do ordered signature matching:

```
given $capture {
    when * -> Int $a, Str $b { ... }
    when * -> Str $a, Int $b { ... }
    when * -> $a, $b         { ... }
    when *                   { ... }
}
```

This can be useful when the unordered semantics of multiple dispatch are insufficient for defining the "pecking order" of code. Note that you can bind to either a bare block or a pointy block. Binding to a bare block conveniently leaves the topic in $_, so the final form above 等价于 a default. (Placeholder parameters may also be used in the bare block form, though of course their types cannot be specified that way.)

There is no pattern matching defined for the Any pattern, so if you find yourself in the situation of wanting a reversed smartmatch test with an Any on the right, you can almost always get it by an explicit call to the underlying ACCEPTS method using $_ as the pattern. For example:

```
$_      X    Type of Match Wanted   What to use on the right
======  ===  ====================   ========================
Callable Any  item sub truth         .ACCEPTS(X) or .(X)
Range   Any  in range               .ACCEPTS(X)
Type    Any  type membership        .ACCEPTS(X) or .does(X)
Regex   Any  pattern match          .ACCEPTS(X)
etc.
```

Similar tricks will allow you to bend the default matching rules for composite objects as long as you start with a dotted method on $_:

```
given $somethingordered {
    when .values.'[<=]'     { say "increasing" }
    when .values.'[>=]'     { say "decreasing" }
}
```

In a pinch you can define a macro to do the "reversed when":

```
my macro statement_control:<ACCEPTS> () { "when .ACCEPTS: " }
given $pattern {
    ACCEPTS $a      { ... }
    ACCEPTS $b      { ... }
    ACCEPTS $c      { ... }
}
```

Various proposed-but-deprecated smartmatch behaviors may be easily (and we hope, more readably) emulated as follows:

```
$_      X      Type of Match Wanted   What to use on the right
======  ===    ====================   ========================
Array   Num    array element truth    .[X]
Array   Num    array contains number  *,X,*
Array   Str    array contains string  *,X,*
Array   Seq    array begins with seq  X,*
Array   Seq    array contains seq     *,X,*
Array   Seq    array ends with seq    *,X
Hash    Str    hash element truth     .{X}
Hash    Str    hash key existence     .{X}:exists
Hash    Num    hash element truth     .{X}
Hash    Num    hash key existence     .{X}:exists
Buf     Int    buffer contains int    .match(X)
Str     Char   string contains char   .match(X)
Str     Str    string contains string .match(X)
Array   Scalar array contains item    .any === X
Str     Array  array contains string  X.any
Num     Array  array contains number  X.any
Scalar  Array  array contains object  X.any
Hash    Array  hash slice exists      .{X.all}:exists .{X.any}:exists
Set     Set    subset relation        .{X.all}:exists
Set     Hash   subset relation        .{X.all}:exists
Any     Set    subset relation        .Set.{X.all}:exists
Any     Hash   subset relation        .Set.{X.all}:exists
Any     Set    superset relation      X.{.all}:exists
Any     Hash   superset relation      X.{.all}:exists
Any     Set    sets intersect         .{X.any}:exists
Set     Array  subset relation        X,*          # (conjectured)
Array   Regex  match array as string  .Cat.match(X)  cat(@$_).match(X)
```

(Note that the .cat method and the Cat type coercion both take a single object, unlike the cat function which, as a list operator, takes a syntactic list (or multilist) and flattens it. All of these return a Cat object, however.)

Boolean expressions are those known to return a boolean value, such as comparisons, or the unary ? operator. They may reference $_ explicitly or implicitly. If they don't reference $_ at all, that's okay too--in that case you're just using the switch structure as a more readable alternative to a string of elsifs. Note, however, that this means you can't write:

```
given $boolean {
    when True  {...}
    when False {...}
}
```

because it will always choose the True case. Instead use something like a conditional context uses internally:

```
given $boolean {
    when .Bool == 1 {...}
    when .Bool == 0 {...}
}
```

Better, just use an if statement. In any case, if you try to smartmatch with ~~ or when, it will recognize True or False syntactically and warn you that it won't do what you expect. The compiler is also allowed to warn about any other boolean construct that does not test $_, to the extent it can detect that.

In a similar vein, any function (such as grep) that takes a Matcher will not accept an argument of type Bool, since that almost always indicates a programming error. (One may always use * to match anything, if that's what you really want. Or use a closure that returns a constant boolean value.)

Note also that regex matching does not return a Bool, but merely a Match object (or a Nil) that can be used as a boolean value. Use an explicit ? or so to force a Bool value if desired. A Match object represents a successful match and is treated by smartmatching the same as a True, Similarly, a Nil represents a failure, and cannot be used directly on the right side of a smartmatch. Test for definedness instead, or use * === Nil.

The primary use of the ~~ operator is to return a boolean-ish value in a boolean context. However, for certain operands such as regular expressions, use of the operator within item or list context transfers the context to that operand, so that, for instance, a regular expression can return a list of matched substrings, as in Perl 5. This is done by returning an object that can return a list in list context, or that can return a boolean in a boolean context. In the case regex matching the Match object is a kind of Capture, which has these capabilities.

For the purpose of smartmatching, all Set, Bag, and Mix values are considered equivalent to the corresponding hash type, SetHash, BagHash, and MixHash, that is, Hash containers where the keys represent the unique objects and the values represent the replication count of those unique keys. (Obviously, a Set can have only 0 or 1 replication because of the guarantee of uniqueness). So all of these Mixy types only compare keys, not values. Use eqv instead to test the equivalence of both keys and values.

Despite the need for an implementation to examine the bounds of a range in order to perform smartmatching, the result of smartmatching two Range objects is not actually defined in terms of bounds, but rather as a subset relationship between two (potentially infinite) sets of values encompassed by the intervals involved, for any orderable type such as real numbers, strings, or versions. The result is defined as true if and only if all potential elements that would be matched by the left range are also matched by the right range. Hence it does not matter to what extent the bounds of a empty range are "overspecified". If the left range is empty, it always matches, because there exists no value to falsify it. If the right range is empty, it can match only if the left range is also empty.

The Cat type allows you to have an infinitely extensible string. You can match an array or iterator by feeding it to a Cat, which is essentially a Str interface over an iterator of some sort. Then a Regex can be used against it as if it were an ordinary string. The Regex engine can ask the string if it has more characters, and the string will extend itself if possible from its underlying iterator. (Note that such strings have an indefinite number of characters, so if you use .* in your pattern, or if you ask the string how many characters it has in it, or if you even print the whole string, it may be feel compelled to slurp in the rest of the string, which may or may not be expeditious.)

The cat operator takes a (potentially lazy) list and returns a Cat object. In string context this coerces each of its elements to strings lazily, and behaves as a string of indeterminate length. You can search a gather like this:

```
my $lazystr := cat gather for @foo { take .bar }
$lazystr ~~ /pattern/;
```

The Cat interface allows the regex to match element boundaries with the <,> assertion, and the StrPos objects returned by the match can be broken down into elements index and position within that list element. If the underlying data structure is a mutable array, changes to the array (such as by shift or pop) are tracked by the Cat so that the element numbers remain correct. Strings, arrays, lists, sequences, captures, and tree nodes can all be pattern matched by regexes or by signatures more or less interchangeably.

Invocant marker

An appended : marks the invocant when using the indirect-object syntax for Perl 6 method calls. The following two statements are equivalent:

```
$hacker.feed('Pizza and cola');
feed $hacker: 'Pizza and cola';
```

A colon may also be used on an ordinary method call to indicate that it should be parsed as a list operator:

```
$hacker.feed: 'Pizza and cola';
```

This colon is a separate token. A colon prefixing an adverb is not a separate token. Therefore, under the longest-token rule,

```
$hacker.feed:xxx('Pizza and cola');
```

is tokenized as an adverb applying to the method as its "toplevel preceding operator":

```
$hacker.feed :xxx('Pizza and cola');
```

not as an xxx sub in the argument list of .feed:

```
$hacker.feed: xxx('Pizza and cola');  # wrong
```

If you want both meanings of colon in order to supply both an adverb and some positional arguments, you have to put the colon twice:

```
$hacker.feed: :xxx('Pizza and cola'), 1,2,3;
```

(For similar reasons it's required to put whitespace after the colon of a label.)

Note in particular that because of adverbial precedence:

```
1 + $hacker.feed :xxx('Pizza and cola');
```

will apply the :xxx adverb to the + operator, not the method call. This is not likely to succeed.

S03-operators/adverbial-modifiers.t lines 7–205  

# 流操作符

S03-feeds/basic.t lines 6–163  

新的操作符 `==>` 和 `<==` 就像Unix里的管道一样，但是它作用于函数或语句，接受并返回列表.因为这些列表由不相关联的对象组成并不流动， 我们把它们叫做喂食（feed）操作符而非管道。例如：

``` perl
     @result = map { floor($^x / 2) },
              grep { /^ \d+ $/      },
              @data;
```

也能写成向右偏的流操作符：

``` perl
    @data ==> grep { /^ \d+ $/       }
          ==> map  { floor($^x / 2)  }
          ==> @result;
```

或者使用左方向的流操作符：

``` perl
    @result <== map { floor($^x / 2) }
            <== grep { /^ \d+ $/     }
            <== @data;
```

每一种形式更清晰地表明了数据的流动。查看 [S06](http://design.perl6.org/S06.html)  了解更多关于这两个操作符的信息。

# 元操作符

Perl 6 的操作符被极大地规范化了，例如，通过分别在数字、字符串和布尔操作符前前置 `+`、`~`、`?` 来表明按位操作是作用在数字、字符串还是单个位身上。但是那只是一种命名约定，

并且如果你想添加一个新的按位 `¬` 操作符， 你必须自己添加  `+¬`, `~¬`, 和 `?¬` 操作符。 类似地，  范围中排除末端的脱字符(`^`)在那里只是约定而已。



和它相比， Perl 6 有 8 个标准的元操作符用于把已有的操作符转换为更强大的相关操作符（或者至少不是一般的强大）。换句话说，这些元操作符正是高阶函数（以其它函数作为参数的函数）的便捷形式。

包含元操作符的结构被认为是 "metatokens"， 这意味着它们不受普通匹配规则的制约， 尽管它们的部件受制约。 然而，像普通的 tokens 那样， metatokens 不允许在它们的子部件之间有空格。

## 赋值操作符

S03-operators/autovivification.t lines 4–111  

C 和 Perl 程序员对于赋值操作符已经司空见惯了。（尽管 .= 操作符现在意味着在左边对象的身上调用一个可变方法， ~= 是字符串连结。）

大部分非关系中缀操作符能通过后缀 = 被转换为对应的赋值操作符。

```
A op= B;
```

S03-operators/inplace.t lines 5–53  

```
A = A op B;
```

Existing forms ending in = may not be modified with this metaoperator.

Regardless of the precedence of the base operator, the precedence of any assignment operator is forced to be the same as that of ordinary assignment. If the base operator is tighter than comma, the expression is parsed as item assignment. If the base operator is the same or looser than comma, the expression is parsed as a list assignment:

```
$a += 1, $b += 2    # two separate item assignments
@foo ,= 1,2,3       # same as push(@foo,1,2,3)
```

S03-operators/assign.t lines 824–987  

```
@foo Z= 1,2,3       # same as @foo = @foo Z 1,2,3
```

Note that metaassignment to a list does not automatically distribute the right argument over the assigned list unless the base operator does (as in the Z case above). Hence if you want to say:

```
($a,$b,$c) += 1;    # ILLEGAL
```

you must instead use a hyperoperator (see below):

```
($a,$b,$c) »+=» 1;  # add one to each of three variables
```

If you apply an assignment operator to a container containing a type object (which is undefined), it is assumed that you are implementing some kind of notional "reduction" to an accumulator variable. To that end, the operation is defined in terms of the corresponding reduction operator, where the type object autovivifies to the operator's identity value. So if you say:

S03-operators/autovivification.t lines 112–159  

```
$x -= 1;
```

it is more or less equivalent to:

```
$x = [-]() unless defined $x;  # 0 for [-]()
$x = $x - 1;
```

and $x ends up with -1 in it, as expected.

Hence you may correctly write:

```
my Num $prod;
for @factors -> $f {
    $prod *= $f;
}
```

While this may seem marginally useful in the scalar variable case, it's much more important for it to work this way when the modified location may have only just been created by autovivification. In other words, if you write:

```
%prod{$key} *= $f
```

you need not worry about whether the hash element exists yet. If it does not, it will simply be initialized with the value of $f.

## 否定关系操作符

S03-operators/equality.t lines 55–71  

任何能返回 Bool 值的中缀关系操作符都可以通过前置一个 `!` 将它转换为否定的关系操作符。有几个关系操作符还有传统的便捷写法：

``` perl
    Full form   Shortcut
    ---------   --------
    !==         !=
    !eq         ne
```

但是大部分关系操作符没有传统的便捷写法

``` perl
    !~~
    !<
    !>=
    !ge
    !===
    !eqv
    !=:=
```



为了避免 `!!` 操作符迷惑视线， 你不可以修改任何已经以`!` 开头的操作符。

否定操作符的优先级和基（base）操作符的优先级相同。

你只可以否定那些返回 Bool 值的操作符。 注意诸如 `||` 和 `^^` 的逻辑操作符不返回 Bool 值， 而是返回其中之一的操作数。



## 翻转操作符

在任意中缀操作符上前置一个 R，会翻转它的两个参数。例如，反向比较：

- Rcmp
- Rleg
- R<=>

任何翻转操作符的优先级和根操作符的优先级是一样的。结合性没有被翻转。

``` perl
    [R-] 1,2,3   # produces 2 from 3 - (2 - 1)
```

要得到另外一种效果，可以先翻转列表：

``` perl
    [-] reverse 1,2,3  # produces 0
```

## 超运算符

S03-metaops/hyper.t lines 13–673  

Unicode 字符  `»` (\x[BB]) 和 `«` (\x[AB]) 和它们的 ASCII连字 `>>` 和 `<<` 用于表示`列表操作`, 它作用于列表中的每个元素, 然后返回单个列表(或数组)作为结果. 换句话说,  超运算符在 item 上下文中计算它的参数, 但是随后将操作符分派到每个参数身上，结果作为列表返回。

S03-operators/misc.t lines 93–99  

当书写超运算符时， 里面不允许出现空格， 即， 两个 "hyper" 标记之间不能有空格， 并且该操作符是能修改参数的。 在外面空格策略和它的 base 操作符相同。 同样地， 超运算符的优先级和它的 base 操作符相同。 这意味着对于大部分操作符，你必须使用圆括号括起你使用逗号分割的列表。。

例如：

``` perl
     -« (1,2,3);                   # (-1, -2, -3)
     (1,1,2,3,5) »+« (1,2,3,5,8);  # (2,3,5,8,13)，尖括号都朝内时，两边列表元素的个数必须相同
```

（如果你发现你自己这样做了， 问问你自己是否真的在使用对象或列表； 在后一种情况中， 可能其它的诸如 Z 或 X 的元操作符更合适， 并且不需要括号）

一元超运算符（要么前缀，要么后缀）只有一个 hyper 标记， 位于它的参数那边， 而中缀操作符通常在参数的每一边以表明有两个参数。

### 一元超运算符

一元超运算符的意思取决于操作符是否是结构非关联的操作符。 大部分操作符不是结构的。

#### 非结构的一元超运算符

Non-structural unary hyper operators produce a hash or array of exactly the same shape as the single argument. The hyper will descend into nested lists and hashes to distribute over the lower-level values just as they distribute over the top-level values that are leaves in the tree. Non-structural unary hypers do not care whether the nesting is achieved by declaration in the case of shaped arrays, or by mere incorporation of sublists and subhashes dynamically. In any case the operator is applied only to the leaves of the structure.

#### Structural unary hyper operators

There are a few operators that are deemed to be structural, however, and will produce counterintuitive results if treated as ordinary operators. These include the dereferencing operators such as subscripts, as well as any method whose least-derived variant (or proto, in the case of a multi method) is declared or autogenerated in a class derived from Iterable. Additionally, structural methods include any method placed in class Any with the intent of treating items as lists of one item. So .elems is considered structural, but a prefix:<+> that happens to call .elems internally is not considered structural.

These operations are marked by declaring them with the is nodal property, which is available by inspection to the hyper controller when it examines the function it was passed. (Hypers are just one form of higher-order programming, after all, and functions are also objects with properties.) So this declaration is to be placed on the top-level declaration of the operator, a proto declaration when there are multiple candidates, or the candidate itself when there is only one candidate. If the is nodal trait is declared, the hyper controller will consider it to be structural.

[Conjecture: we can assume is nodal on methods declared in a class that is Iterable, to save having to mark every method as nodal. Or we provide a pragma within a lexical scope that assumes is nodal, so we can use it inside Any as well.]

[Conjecture: we might revise this be a does Nodal role instead of a trait, if the implementors decide that makes more sense.]

For structural hypers, we never implicitly follow references to substructures, since the operator itself wants to deal with the structure. So these operators distribute only over the top level of the structure.

For arrays or hashes declared with a shape (see S09), this top level may be multidimensional; unary hypers consider shaped arrays to really be one-dimensional (and indeed, for compactly stored multidimensional arrays, multidimensional subscripts can just be calculations into an underlying linear representation, which can be optimized to run on a GPU, so this makes implementational sense).

If the item is not declared with a shape, only the top dimension is mapped, equivalent to a normal .map method. (To map deeper dimensions than provided for by hypers, use the either .duckmap or .deepmap method, depending on whether you want to give the item mapping or the substructure first shot at each node.)

### 二元超运算符

In contrast to unary operators that allows for (a few) structural operators, infix operators are never considered structural, so the hyper infix controller will always consider the dynamic shape as potentially traversable in addition to any static shape. That is, it is allowed to follow references from any parent node to dynamically nested structures. (Whether it actually follows a particular reference depends on the relative shapes of the two arguments.)

When infix operators are presented with two lists or arrays of identical shape, a result of that same shape is produced. Otherwise the result depends on how you write the hyper markers.

For an infix operator, if either argument is insufficiently dimensioned, Perl "upgrades" it, but only if you point the "sharp" end of the hypermarker at it.

```
 (3,8,2,9,3,8) >>->> 1;          # (2,7,1,8,2,7)
 @array »+=» 42;                 # add 42 to each element
```

In fact, an upgraded scalar is the only thing that will work for an unordered type such as a Bag:

```
 Bag(3,8,2,9,3,8) >>->> 1;       # Bag(2,7,1,8,2,7) === Bag(1,2,2,7,7,8)
```

``` perl
>  Bag(3,8,2,9,3,8)  # Bag 的用法以改变
bag(9, 8(2), 3(2), 2)
```

In other words, pointing the small end at an argument tells the hyperoperator to "dwim" on that side. If you don't know whether one side or the other will be underdimensioned, you can dwim on both sides:

```
$left «*» $right
```

[Note: if you are worried about Perl getting confused by something like this:

```
func «*»
```

then you shouldn't worry about it, because unlike previous versions, Perl 6 never guesses whether the next thing is a term or operator. In this case it is always expecting a term unless func is predeclared to be a type or value name.]

The upgrade never happens on the "blunt" end of a hyper. If you write

```
$bigger «*« $smaller
$smaller »*» $bigger
```

an exception is thrown, and if you write

```
$foo »*« $bar
```

you are requiring the shapes to be identical, or an exception will be thrown.

For all hyper dwimminess, if a scalar is found where the other side expects a list, the scalar is considered to be a list of one element repeated * times.

Once we have two lists to process, we have to decide how to put the elements into correspondence. If both sides are dwimmy, the short list will have be repeated as many times as necessary to make the appropriate number of elements.

If only one side is dwimmy, then the list on that side only will be grown or truncated to fit the list on the non-dwimmy side.

Regardless of whether the dwim is forced or emergent from the shapes of the arrays, once the side to dwim on has been chosen, the dwim semantics on the dwimmy side are always:

```
(@dwimmyside xx *).batch(@otherside.elems)
```

This produces a list the same length as the corresponding dimension on the other side. The original operator is then recursively applied to each corresponding pair of elements, in case there are more dimensions to handle.

下面是一些例子:

``` perl
    (1,2,3,4) »+« (1,2)    # always error，尖括号都朝内时，两边元素必须个数相同
    (1,2,3,4) «+» (1,2)    # 2,4,4,6     rhs dwims to 1,2,1,2
    (1,2,3)   «+» (1,2)    # 2,4,4       rhs dwims to 1,2,1
    (1,2,3,4) «+« (1,2)    # 2,4         lhs dwims to 1,2
    (1,2,3,4) »+» (1,2)    # 2,4,4,6     rhs dwims to 1,2,1,2
    (1,2,3)   »+» (1,2)    # 2,4,4       rhs dwims to 1,2,1
    (1,2,3)   »+» 1        # 2,3,4       rhs dwims to 1,1,1
```

Another way to look at it is that the dwimmy list's elements are indexed modulo its number of elements so as to produce as many or as few elements as necessary.

Note that each element of a dwimmy list may in turn be expanded into another dimension if necessary, so you can, for instance, add one to all the elements of a matrix regardless of its dimensionality:

```
@fancy »+=» 1
```

On the non-dwimmy side, any scalar value that does not know how to do Iterable will be treated as a list of one element, and for infix operators must be matched by an equivalent one-element list on the other side. That is, a hyper operator is guaranteed to degenerate to the corresponding scalar operation when all its arguments are non-list arguments.

When using a unary operator, you always aim the blunt end at the single operand, because no replicative dwimmery ever happens:

当使用`一元`操作符时, 你总是把钝的那端对准单个运算对象, 因为没有出现重复的东西:

``` perl
     @negatives = -« @positives;
     @positions»++;            # Increment all positions
     @positions.»++;           # Same thing, dot form
     @positions».++;           # Same thing, dot form 报错
     @positions.».++;          # Same thing, dot form
     @positions\  .»\  .++;    # Same thing, unspace form
     @objects.».run();
     ("f","oo","bar").».chars; # (1,2,3)
```

注意方法调用实际上是后缀操作符, 而非中缀操作符, 所以,  你不能在点号后面放上一个 ` «`

超运算符在嵌套数组中是被递归地定义的， 所以：

``` perl
    -« [[1, 2], 3]              #    [-«[1, 2], -«3] 得到 -1 -2 -3
                                # == [[-1, -2], -3]
```

Likewise the dwimminess of dwimmy infixes propagates:

```
[[1, 2], 3] «+» [4, [5, 6]]  #    [[1,2] «+» 4, 3 «+» [5, 6]]，得到 5 6 8 9
                             # == [[5, 6], [8, 9]]
```

More generally, a dwimmy hyper operator works recursively for any object matching the Iterable role even if the object itself doesn't support the operator in question:

```
Bag(3,8,[2,Seq(9,3)],8) >>->> 1;         # Bag(2,7,[1,Seq(8,2)],7)
Seq(3,8,[2,Seq(9,3)],8) >>->> (1,1,2,1); # Seq(2,7,[0,Seq(7,1)],7)
```

In particular, tree node types with Iterable semantics enable visitation:

```
$node.».foo;
```

which means something like:

```
my $type = $node.WHAT;
$node.?foo // $type($node.map: { .».foo })
```

You are not allowed to define your own hyper operators, because they are supposed to have consistent semantics derivable entirely from the modified scalar operator. If you're looking for a mathematical vector product, this isn't where you'll find it. A hyperoperator is one of the ways that you can promise to the optimizer that your code is parallelizable. (The tree visitation above is allowed to have side effects, but it is erroneous for the meaning of those side effects to depend on the order of visitation in any way. Hyper tree visitation is not required to follow DAG semantics, at least by default.)

Even in the absence of hardware that can do parallel processing, hyperoperators may be faster than the corresponding scalar operators if they can factor out looping overhead to lower-level code, or can apply loop-unrolling optimizations, or can factor out some or all of the MMD dispatch overhead, based on the known types of the operands (and also based on the fact that hyper operators promise no interaction among the "iterations", whereas the corresponding scalar operator in a loop cannot make the same promise unless all the operations within the loop are known to be side-effect free.)

In particular, infix hyperops on two int or num arrays need only do a single MMD dispatch to find the correct function to call for all pairs, and can further bypass any type-checking or type-coercion entry points to such functions when there are known to be low-level entry points of the appropriate type. (And similarly for unary int or num ops.)

Application-wide analysis of finalizable object types may also enable such optimizations to be applied to Int, Num, and such. In the absence of that, run-time analysis of partial MMD dispatch may save some MMD searching overhead. Or particular object arrays might even keep track of their own run-time type purity and cache partial MMD dispatch tables when they know they're likely to be used in hyperops.

Beyond all that, "array of scalar" types are known at compile time not to need recursive hypers, so the operations can be vectorized aggressively.

Hypers may be applied to hashes as well as to lists. In this case "dwimminess" says whether to ignore keys that do not exist in the other hash, while "non-dwimminess" says to use all keys that are in either hash. That is,

超运算符也能作用于散列，就像作用于数组一样。

```
%foo «+» %bar;
```

得到两个键的交集（对应的键值相加）

``` perl
> my %foo = "Tom" => 98, "Larry" => 100, "Bob" => "49";
("Tom" => 98, "Larry" => 100, "Bob" => "49").hash
```

``` perl
> my %bar = "Tom" => 98, "Larry" => 100, "Vivo" => 86
("Tom" => 98, "Larry" => 100, "Vivo" => 86).hash
```

``` perl
> %foo «+» %bar
("Tom" => 196, "Larry" => 200).hash
```

而：

``` perl
>  %foo »+« %bar;
("Tom" => 196, "Larry" => 200, "Bob" => 49, "Vivo" => 86).hash
```

得到两个键的并集（键值相加）

 不对称的 hypers 也有用; 例如， 如果你说：

``` perl
    %outer »+» %inner;
```

只有在 %outer 中已经存在的 %inner 键才会出现在结果中.

``` perl
> my %inner = "a" => 11;
> my %outer = "a" => 9, "b" => 12;
> %outer »+» %inner # a => 20, b => 12
```

然而，

``` perl
%outer »+=« %inner;
```

假设你想让 %outer 拥有键的并集，累加键值

``` perl
> my %inner = "a" => 11;
> my %outer = "a" => 9, "b" => 12;
> %outer »+=« %inner;  # a => 20, b => 12
> say %outer           # a => 20, b => 12
> say %inner           # a => 11
```



Unary hash hypers and binary hypers that have only one hash operand will apply the hyper operator to just the values but return a new hash value with the same set of keys as the original hash.

For any kind of zip or dwimmy hyper operator, any list ending with * is assumed to be infinitely extensible by taking its final element and replicating it:

``` perl
@array, *
```

is short for something like:

``` perl
@array[0..^@array], @array[*-1] xx *
```

Note that hypers promise that you don't care in what order the processing happens, only that the resulting structure ends up in a form consistent with the inputs. There is no promise from the system that the operation will be parallelized. Effective parallelization requires some means of partitioning the work without doing more extra work than you save. This will differ from structure to structure. In particular, infinite structures cannot be completely processed, and the system is allowed to balance out the demands of laziness with parallel processing. For instance, an algorithm that wants to divide a list into two equal sublists will not work if you have to calculate the length in advance, since you can't always calculate the length. Various approaches can be taken:

 handing off batches to be processed in parallel on demand, or interleaving roundrobin with a set of N processors, or whatever. In the limit, a simple, non-parallel, item-by-item lazy implementation is within spec, but unlikely to use multiple cores efficiently. Outside of performance requirements, if the algorithm depends on which of these approaches is taken, it is erroneous.

注意， hypers 允诺你不必关心处理以怎样的顺序发生，只保证结果的结构和输入的形式保持一致。从系统角度也不能保证操作是并行化的。

高效的并行化要求某种程度的不带更多额外工作的工作分割，系统被允许平衡并行处理的惰性需求。

例如， 一个算法想把一个列表分成2个等长的子列表是不会起作用的， 如果你不得不提前计算好列表长度， 因为你不是总能计算出长度。可以采取各种方法：

按需切换要并行处理的群组， 或交错循环地使用一组 N 个核心的处理器，或任何东西。在该限制下， 一个简单、非并行、逐项的惰性实现就在 sepc 之中了，但是不太可能高效的使用多核。‘

不考虑性能要求，如果算法依赖于这些采用的方法， 那也是错误的。

Reduction operators 运算操作符

S06-multi/proto.t lines 32–154  

S03-metaops/reduce.t lines 15–198  

任何中缀操作符（除了 non-associating 操作符）都可以在 term 位置处被方括号围住， 以创建使用使用该操作符进行换算的列表操作符：

``` perl
    [+] 1, 2, 3;      # 1 + 2 + 3 = 6
    my @a = (5,6);
    [*] @a;           # 5 * 6 = 30
```

对于所有的元操作符来说,  在 `metatoken` 里面是不允许有空格的.

换算操作符和列表前缀的优先级相同。 实际上， 换算操作符就是一个列表前缀，被当作一个操作符来调用。因此， 你可以以两种方式的任何一种来实现换算操作符。要么你也能写一个显式的列表操作符：

``` perl
    multi prefix:<[+]> (*@args) is default {
        my $accum = 0;
        while (@args) {
            $accum += @args.shift();
        }
        return $accum;
    }
```

或者你能让系统根据对应的中缀操作符为你自动生成一个：

``` perl
    &prefix:<[*]>  ::= &reduce.assuming(&infix:<*>, 1);
    &prefix:<[**]> ::= &reducerev.assuming(&infix:<**>);
```

如果换算操作符和中缀操作符的定义是独立的， 那换算操作符和该操作符的结合性要相同：

``` perl
    [-] 4, 3, 2;      # 4-3-2 = (4-3)-2 = -1
    [**] 4, 3, 2;     # 4**3**2 = 4**(3**2) = 262144
```

对于  list-associative 操作符（优先级表中的 X），实现必须把参数的 listiness 考虑在内； 即，如果重复地应用一个二元版本的操作符会产生错误的结果，那么它就不会被那样实现。 例如：

``` perl
    [^^] $a, $b, $c;  # means ($a ^^ $b ^^ $c), NOT (($a ^^ $b) ^^ $c)
```

对于 chain-associative 操作符（像 <）， 所有的参数被一块儿接收， 就像你显式地写出：

```
[<] 1, 3, 5;      # 1 < 3 < 5
```



对于列表中缀操作符， 输入列表不会被展平， 以至于多个 parcels 可以以逗号分割形式的参数传递进来：  

``` perl
  [X~] (1,2), <a b>;  # 1,2 X~ <a b>
```

如果给定的参数少于 2 个， 仍然会用给定的参数尝试分派， 并根据那个分派的接受者来处理少于 2 个参数的情况。 注意，默认的列表操作符签名是最通用的， 所以， 你被允许根据类型去定义不同的方式处理单个参数的情况：

``` perl
    multi prefix:<[foo]> (Int $x) { 42 }
    multi prefix:<[foo]> (Str $x) { fail "Can't foo a single Str" }
```

然而， 0 参数的情况不能使用这种方式定义， 因为没有类型信息用于分派。操作符要想指定一个同一值应该通过指定一个接收 0 个参数的 multi 变体来实现这：

``` perl
    multi prefix:<[foo]> () { 0 }
```

在内建操作符中，举个例子，  `[+]()` 返回 0 ， `[*]()` 返回 1 。

S03-metaops/reduce.t lines 199–386  

默认地， 如果有一个参数， 内建的换算操作符就返回那个参数。 然而， 这种默认对于像 `<` 那样返回类型和接收参数不同的操作符没有效果，所以这种类型的操作符重载了单个参数的情况来返回更有意义的东西。为了和链式语义保持一致， 所有的比较操作符都对于 1 个或 0 个参数返回 Bool::True。

你也可以搞一个逗号操作符的换算操作符。 这正是 `circumfix:<[ ]>` 匿名数组构建器的列表操作符形式：

``` perl
    [1,2,3]     # make new Array: 1,2,3
    [,] 1,2,3   #  与上相同
```

内置换算操作符返回下面的同一值：

S03-operators/reduce-le1arg.t lines 7–71  

``` perl
    [**]()      # 1     (arguably nonsensical)
    [*]()       # 1
    [/]()       # fail  (换算没有意义)
    [%]()       # fail  (换算没有意义)
    [x]()       # fail  (换算没有意义)
    [xx]()      # fail  (换算没有意义)
    [+&]()      # -1    (from +^0, the 2's complement in arbitrary precision)
    [+<]()      # fail  (换算没有意义)
    [+>]()      # fail  (换算没有意义)
    [~&]()      # fail  (sensical but 1's length indeterminate)
    [~<]()      # fail  (换算没有意义)
    [~>]()      # fail  (换算没有意义)
    [+]()       # 0
    [-]()       # 0
    [~]()       # ''
    [+|]()      # 0
    [+^]()      # 0
    [~|]()      # ''    (length indeterminate but 0's default)
    [~^]()      # ''    (length indeterminate but 0's default)
    [&]()       # all()
    [|]()       # any()
    [^]()       # one()
    [!==]()     # Bool::True    (also for 1 arg)
    [==]()      # Bool::True    (also for 1 arg)
    [before]()  # Bool::True    (also for 1 arg)
    [after]()   # Bool::True    (also for 1 arg)
    [<]()       # Bool::True    (also for 1 arg)
    [<=]()      # Bool::True    (also for 1 arg)
    [>]()       # Bool::True    (also for 1 arg)
    [>=]()      # Bool::True    (also for 1 arg)
    [~~]()      # Bool::True    (also for 1 arg)
    [!~~]()     # Bool::True    (also for 1 arg)
    [eq]()      # Bool::True    (also for 1 arg)
    [!eq]()     # Bool::True    (also for 1 arg)
    [lt]()      # Bool::True    (also for 1 arg)
    [le]()      # Bool::True    (also for 1 arg)
    [gt]()      # Bool::True    (also for 1 arg)
    [ge]()      # Bool::True    (also for 1 arg)
    [=:=]()     # Bool::True    (also for 1 arg)
    [!=:=]()    # Bool::True    (also for 1 arg)
    [===]()     # Bool::True    (also for 1 arg)
    [!===]()    # Bool::True    (also for 1 arg)
    [eqv]()     # Bool::True    (also for 1 arg)
    [!eqv]()    # Bool::True    (also for 1 arg)
    [&&]()      # Bool::True
    [||]()      # Bool::False
    [^^]()      # Bool::False
    [//]()      # Any
    [min]()     # +Inf
    [max]()     # -Inf
    [=]()       # Nil    (same for all assignment operators)
    [,]()       # []
    [Z]()       # []

```

S03-operators/reduce-le1arg.t lines 8–71  

User-defined operators may define their own identity values, but there is no explicit identity property. The value is implicit in the behavior of the 0-arg reduce, so mathematical code wishing to find the identity value for an operation can call prefix:["[$opname]"]() to discover it.

To call some other non-infix function as a reduce operator, you may define an alias in infix form. The infix form will parse the right argument as an item even if the aliased function would have parsed it as a list:

```
&infix:<dehash> ::= &postcircumfix:<{ }>;
$x = [dehash] $a,'foo','bar';  # $a<foo><bar>, not $a<foo bar>
```

Alternately, just define your own prefix:<[dehash]> routine.

Note that, because a reduce is a list operator, the argument list is evaluated in list context. Therefore the following would be incorrect:

```
$x = [dehash] %a,'foo','bar';
```

You'd instead have to say one of:

```
$x = [dehash] \%a,'foo','bar';
$x = [dehash] %a<foo>,'bar';
```

On the plus side, this works without a star:

```
@args = (\%a,'foo','bar');
$x = [dehash] @args;
```

Likewise, from the fact that list context flattens inner arrays and lists, it follows that a reduced assignment does no special syntactic dwimmery, and hence only scalar assignments are supported. Therefore

```
[=] $x, @y, $z, 0
[+=] $x, @y, $z, 1
```

等价于：

```
$x = @y[0] = @y[1] = @y[2] ... @y[*-1] = $z = 0
$x += @y[0] += @y[1] += @y[2] ... @y[*-1] += $z += 1
```

而不是：

```
$x = @y = $z = 0;
$x += @y += $z += 1;
```

(And, in fact, the latter are already easy to express anyway, and more obviously nonsensical.)

Similarly, list-associative operators that have the thunk-izing characteristics of macros (such as short-circuit operators) lose those macro-like characteristics. You can say

```
[||] a(), b(), c(), d()
```

to return the first true result, but the evaluation of the list is controlled by the semantics of the list, not the semantics of ||. The operator still short-circuits, but only in the sense that it does not need to examine all the values returned by the list. This is still quite useful for performance, especially if the list could be infinite.

Most reduce operators return a simple scalar value, and hence do not care whether they are evaluated in item or list context. However, as with other list operators and functions, a reduce operator may return a list that will automatically be interpolated into list context, so you may use it on infix operators that operate over lists as well as scalars:

```
my ($min, $max) = [minmax] @minmaxpairs;
```

A variant of the reduction metaoperator is pretty much guaranteed to produce a list; to lazily generate all intermediate results along with the final result, you can backslash the operator:

```
say [\+] 1..*  #  (1, 3, 6, 10, 15, ...)
```

The visual picture of a triangle is not accidental. To produce a triangular list of lists, you can use a "triangular comma":

```
[\,] 1..5
[1],
[1,2],
[1,2,3],
[1,2,3,4],
[1,2,3,4,5]
```

If there is ambiguity between a triangular reduce and an infix operator beginning with backslash, the infix operator is chosen, and an extra backslash indicates the corresponding triangular reduce. As a consequence, defining an infix operator beginning with backslash, infix:<\x> say, will make it impossible to write certain triangular reduction operators, since [\x] would mean the normal reduction of infix:<\x> operator, not the triangular reduction of infix:<x>. This is deemed to be an insignificant problem.

Triangular reductions of chaining operators always consist of one or more True values followed by 0 or more False values.

Cross operators 交叉操作符

S03-metaops/cross.t lines 40–42  

The cross metaoperator, X, may be followed by any infix operator. It applies the modified operator across all groupings of its list arguments as returned by the ordinary infix:<X> operator. All generated cross operators are of list infix precedence, and are list associative.

The string concatenating form is:

S03-metaops/cross.t lines 43–50  

```
<a b> X~ 1,2           #  'a1', 'a2', 'b1', 'b2'
```

The X~ operator desugars to:

```
(<a b>; 1,2).crosswith(&[~])
```

which in turn means

```
(<a b>; 1,2).cross.lol.map { .reduce(&[~]) }
```

Note that

```
<a b> X~ 1,2 X+ 3,4
```

could mean something like

```
(<a b>; 1,2; 3,4).cross.lol.map { .reduce({$^a ~ $^b + $^c}) }
```

but it is currently illegal as a non-identical list associative operator, which is considered non-associative. You can, however, always use parens to be explicit:

```
<a b> X~ (1,2 X+ 3,4)
```

The list concatenating form, X,, when used like this:

S03-metaops/cross.t lines 51–68  

```
<a b> X, 1,2 X, <x y>
```

produces

```
('a', 1, 'x'),
('a', 1, 'y'),
('a', 2, 'x'),
('a', 2, 'y'),
('b', 1, 'x'),
('b', 1, 'y'),
('b', 2, 'x'),
('b', 2, 'y')
```

The X, operator is perhaps more clearly written as X[,]. However, this list form is common enough to have a shortcut, the ordinary infix X operator described earlier.

For the general form, any existing, non-mutating infix operator may be used.

S03-metaops/cross.t lines 69–73  

```
1,2 X* 3,4               # 3,4,6,8
```

(Note that <== and ==> are considered mutating, as well as all assignment operators.)

If the underlying operator is non-associating, so is the cross operator:

S03-metaops/cross.t lines 74–121  

```
@a Xcmp @b Xcmp @c       # ILLEGAL
@a Xeq @b Xeq @c         # ok
```

In fact, though the X operators are all list associative syntactically, the underlying operator is always applied with its own associativity, just as the corresponding reduce operator would do.

Note that only the first term of an X operator may reasonably be an infinite list.

All lists are assumed to be flat; multidimensional lists are handled by treating the first dimension as the only dimension.

Zip operators

The zip metaoperator, Z, may be followed by any infix operator. It applies the modified operator across all groupings of its list arguments as returned by the ordinary infix:<Z> operator. All generated zip operators are of list infix precedence, and are list associative.

The string concatenating form is:

```
<a b> Z~ 1,2           #  'a1', 'b2'
```

The Z~ operator desugars to:

```
(<a b>; 1,2).zipwith(&[~])
```

which in turn means

```
(<a b>; 1,2).zip.lol.map: { .reduce(&[~]) }
```

Note that

```
<a b> Z~ 1,2 Z+ 3,4
```

could mean something like

```
(<a b>; 1,2; 3,4).zip.lol.map: { .reduce({$^a ~ $^b + $^c}) }
```

but it is currently illegal as a non-identical list associative operator, which is considered non-associative. You can, however, always use parens to be explicit:

```
<a b> Z~ (1,2 Z+ 3,4)
```

[Conjecture: another approach would involve giving X and Z metaoperators a subprecedence within listop precedence corresponding to the original operator's precedence, so that Z~ and Z+ actually have different precedences within listop precedence. Then the above would parse as if you'd said <a b> Z~ ( 1,2 Z+ 3,4> ), but the lists would still parse at list infix precedence, with comma tighter than the zips. (This would actually be fairly trivial to implement, given how we represent our precedence as strings.) Also, though it's complicated to explain, subprecedence within Z might be exactly what the naive user expects.]

The list concatenating form, Z,, when used like this:

```
<a b> Z, 1,2 Z, <x y>
```

produces

```
('a', 1, 'x'),
('b', 2, 'y')
```

The Z, operator is perhaps more clearly written as Z[,]. However, this list form is common enough to have a shortcut, the ordinary infix Z operator described earlier.

For the general form, any existing, non-mutating infix operator may be used.

```
1,2 Z* 3,4               # 3,8
```

(Note that <== and ==> are considered mutating, as well as all assignment operators.)

If the underlying operator is non-associating, so is the cross operator:

```
@a Zcmp @b Zcmp @c       # ILLEGAL
@a Zeq @b Zeq @c         # ok
```

In fact, though the Z operators are all list associative syntactically, the underlying operator is always applied with its own associativity, just as the corresponding reduce operator would do.

The zip operation terminates when either of its lists terminates. (Do not use Zeq or Z== to compare two arrays, for instance, unless you want to know if one array is a prefix of the other. Use »eq« or »==« for that. Or better, just use eqv.)

Note that, unlike the X operator, all the terms of a Z operator may reasonably be infinite lists, since zipping is lazy.

All lists are assumed to be flat; multidimensional lists are handled by treating the first dimension as the only dimension.

Sequential operators

The sequence metaoperator, S, may be followed by any non-fiddly infix operator. It suppresses any explicit or implicit parallelism, and prevents the optimizer from reordering the operand evaluations. The 'S' can be thought of as standing for Sequential, Serial, Synchronous, Short-circuit, Single-thread, and Safe. Among other things. In particular, we can have:

```
a S& b S& c         short-circuited AND junction
a S| b S| c         short-circuited OR junction
a S^ b S^ c         short-circuited XOR junction
a S»op« b           single-threaded hyperop
a SX* b             single-threaded X*
a SX[*] b           single-threaded X*
a S[X*] b           single-threaded X*
a S+ b              suppress arg reordering by ignorant optimizer
```

This metaoperator has the same precedence and associativity as its base operator. The compiler is free to discard any S metaoperator that is provably redundant, such as the one in S||. The compiler is free to intuit an S on any operator involving known volatile operands where that does not otherwise change the semantics of the operator.

[Conjectural: since metaoperators are notionally applied from inside to outside, the semantics of serializing and reversing depends on the order of the metaoperators:

```
a SR/ b             evaluates b, then a, then does b/a
a RS/ b             evaluates a, then b, then does b/a
a RSR/ b            evaluates b, then a, then does a/b
```

...maybe. Can argue it all the other way too...]

Nesting of metaoperators 元操作符的嵌套

Anywhere you may use an ordinary infix operator, you may use the infix operator enclosed in square brackets with the same meaning. (No whitespace is allowed.) You may therefore use square brackets within a metatoken to disambiguate sequences that might otherwise be misinterpreted, or to force a particular order of application when there are multiple metaoperators in the metatoken:

```
@a [X+]= @b
@a X[+=] @b
```

Since metatokens may never be disambiguated with internal whitespace, use of brackets is especially useful when the operator and its associated metaoperator share characters that would be confusing to the reader, even if not to the compiler:

```
@a >>>>> $b        # huh?
@a >>[>]>> $b      # oh yeah
```

Turning an infix operator into a noun

Any infix function may be referred to as a noun either by the normal long form or a short form using square brackets directly after the & sigil:

```
&infix:<+>
&[+]
```

This is convenient for function application:

```
1, 1, &[+] ... *       # fibonacci sequence
sort &[Rleg], @list    # reverse sort as strings
```

The &[op] form always refers to a binary function of the operator, even if it is underlyingly defined as a variadic list-associative operator.

There is no corresponding form for unary operators, but those may usually be constructed by applying an operator to *:

```
sort -*, @list        # sort reversed numerically
```

Turning a binary function into an infix

By using the noun form of a binary function inside square brackets, it is possible to turn any function that accepts at least two arguments into an infix operator. For instance:

```
$y [&atan2] $x        # same as atan2($y, $x)
```

By itself this may seem relatively useless, but note that it allows composition of normal 2-arg functions with all the infix metaoperators. Since it is primarily intended for composition with metaoperators, this form always assumes a binary function, even if the function could accept more arguments; functions that accept more than 2 arguments do not thereby accept multiple arguments on the right side. You must use the normal functional form to pass three or more positional arguments.

This form of operator is parsed with a precedence of addition. The next character after & must be either alphabetic or a left parenthesis. Otherwise a normal infix operator starting with that character will be assumed. Hence [&&] parses as a form of the && operator.

Declarators

S03-operators/chained-declarators.t lines 4–31  

The list of variable declarators has expanded from my and our to include:

```
my $foo             # ordinary lexically scoped variable
our $foo            # lexically scoped alias to package variable
has $foo            # object attribute
state $foo          # persistent lexical (cloned with closures)
```

Variable declarators such as my now take a signature as their argument. (The syntax of function signatures is described more fully in S06.)

The parentheses around the signature may be omitted for a simple declaration that declares a single variable, along with its associated type, traits and the initializer:

```
my Dog $foo is woof = 123;    # okay: initializes $foo to 123
my (Dog $foo is woof = 123);  # same thing (with explicit parens)
my :(Dog $foo is woof = 123); # same thing (full Signature form)
```

The constant declarator can declare either variables or names as compile-time constants:

```
constant $foo = 1;      # compile-time constant variable
constant bar = 2;       # compile-time constant symbol
```

Because it can declare names in "type" space, the constant declarator may not declare using the signature, which would be ambiguous.

Each declarator can take an initializer following an equals sign (which should not be confused with a normal assignment, because the timing of the initialization depends on the natural lifetime of the container, which in turn depends on which declarator you use).

```
my $foo = 1;         # happens at execute time, like normal assignment
our $foo = 1;        # happens at INIT time
has $foo = 1;        # happens at BUILD time
state $foo = 1;      # happens at execute time, but only once
constant $foo = 1;   # happens at BEGIN time
```

(Note that the semantics of our are different from Perl 5, where the initialization happens at the same time as a my. To get the same effect in Perl 6 you'd have to say "(our $foo) = 1;" instead.)

If you do not initialize a container, it starts out undefined at the beginning of its natural lifetime. (In other words, you can't use the old Perl 5 trick of "my $foo if 0" to get a static variable, because a my variable starts out uninitialized every time through in Perl 6 rather than retaining its previous value.) Native integer containers that do not support the concept of undefined should be initialized to 0 instead. (Native floating-point containers are by default initialized to NaN.) Typed object containers start out containing an undefined type object of the correct type.

List-context pseudo-assignment is supported for simple declarations but not for signature defaults:

```
my @foo = 1,2,3;      # okay: initializes @foo to (1,2,3)
my (@foo = 1,2,3);    # wrong: 2 and 3 are not variable names
```

When parentheses are omitted, you may use any infix assignment operator instead of = as the initializer. In that case, the left hand side of the infix operator will be the variable's prototype object:

```
my Dog $fido .= new;      # okay: a Dog object
my Dog $fido = Dog.new;   # same thing
my Dog $fido = $fido.new; # wrong: invalid self-reference
my (Dog $fido .= new);    # wrong: cannot use .= inside signature
```

Note that very few mutating operators make sense on a type object, however, since type objects are a kind of undefined object. (Those operators with an identity value are an exception, as noted above.)

Parentheses must always be used when declaring multiple parameters:

```
my $a;                  # okay
my ($b, $c);            # okay
my ($b = 1, $c = 2);    # okay - "my" initializers assign at runtime
my $b, $c;              # wrong: "Use of undeclared variable: $c"
```

Types occurring between the declarator and the signature are distributed into each variable:

```
my Dog ($b, $c);
my (Dog $b, Dog $c);    # same thing
```

[XXX the following probably belongs in S06.] The syntax for constructing a Signature object when the parser isn't already expecting one is:

```
:(Dog $a, *@c)
```

This might be used like this:

```
my $sig = :(Dog $a, *@c);
```

Signatures are expected after declarators such as my, sub, method, rule, etc. In such declarators the colon may be omitted. But it's also legal to use it:

```
my :($b, $c);               # okay
sub foo :($a,$b) {...}      # okay
```

 `->` "pointy block" token 也引入签名, 但是这种情况你必须省略冒号和括号. 例如, 如果你在定义 loop block 的 "循环变量":

``` perl
    for @dogpound -> Dog $fido { ... }
```

If a signature is assigned to (whether declared or colon form), the signature is converted to a list of lvalue variables and the ordinary rules of assignment apply, except that the evaluation of the right side and the assignment happens at time determined by the declarator. (With my this is always when an ordinary assignment would happen.) If the signature is too complicated to convert to an assignment, a compile-time error occurs. Assignment to a signature makes the same item/list distinction as ordinary assignment, so

```
my $a = foo();      # foo in item context
my ($a) = foo();    # foo in list context
```

If a signature is bound to an argument list, then the binding of the arguments proceeds as if the signature were the formal parameters for a function, except that, unlike in a function call, the parameters are bound rw by default rather than readonly. See Binding above.

Note that temp and let are not variable declarators, because their effects only take place at runtime. Therefore, they take an ordinary lvalue object as their argument. See S04 for more details.

There are a number of other declarators that are not variable declarators. These include both type declarators:

```
package Foo
module Foo
class Foo
role Foo
subset Foo
enum Foo
constant Foo
```

and code declarators:

```
sub foo
method foo
submethod foo
multi foo
proto foo
macro foo
quote qX
regex foo
rule foo
token foo
```

These all have their uses and are explained in subsequent Synopses.

Note that since constant is parsed as a type declarator (essentially declaring a type with a single value), it can actually take a scope declarator in front:

```
my constant companion = 'Fido';
has constant $.pi = 22/7;
state constant $latch = snapshot(); # careful with this!
```

However, the constant declarator is intended to create values the compiler can inline, so it always evaluates its value at BEGIN time. Thus, while the extra scope declarator may say where the value is stored and when that storage is initialized, it cannot change the value of that from instance to instance. In general, if you want something that doesn't vary over the normal lifetime of a scope declarator, initialize it to a readonly value using ::= rather than declaring it as a constant. Then each time the scope declarator is used, it can initialize to a different readonly value:

```
state $latch ::= snapshot();  # each clone gets its own value of $latch
```

Argument List Interpolating 参数列表插值

Perl 5 forced interpolation of a function's argument list by use of the & prefix. That option is no longer available in Perl 6, so instead the | prefix operator serves as an interpolator, by casting its operand to a Capture object and inserting the capture's parts into the current argument list. This operator can be used to interpolate an Array or Hash into the current call, as positional and named arguments respectively.

S06-signature/slurpy-and-interpolation.t lines 7–45  

Note that the resulting arguments still must comply with the subroutine's signature, but the presence of | defers that test until run time for that argument (and for any subsequent arguments):

```
my $args = \(@foo, @bar);
push |$args;
```

等价于:

```
push @foo, @bar;
```

However,

```
my $args = \(@foo: @bar);
push |$args;
```

is instead equivalent to:

```
@foo.push(@bar);
```

| does not turn its argument into an Array, but instead directly converts its argument into a Capture:

```
my @args = \$x, 1, 2, 3;
say |@args;     # say(\$x, 1, 2, 3);
```

Because of this, |%args always produces named arguments, and |@args always produces positional arguments.

In list context, a Scalar holding an Array object does not flatten. Hence

```
$bar = @bar;
@foo.push($bar);
```

merely pushes a single Array object onto @foo. You can explicitly flatten it in one of these ways:

S02-types/capture.t lines 10–18  

S02-types/capture.t lines 19–27  

S02-types/capture.t lines 28–37  

S02-types/capture.t lines 38–47  

S02-types/capture.t lines 48–53  

```
@foo.push(@$bar);
@foo.push($bar[]);
@foo.push(|$bar);
```

Those three forms work because the slurpy array in push's signature flattens the Array object into a list argument.

Note that the first two forms also allow you to specify list context on assignment:

```
@$bar = 1,2,3;
$bar[] = 1,2,3;
```

For long expressions that need to be cast to an array lvalue, the second form can keep the "arrayness" of the lvalue close to the assignment operator:

```
$foo.bar.baz.bletch.whatever.attr[] = 1,2,3;
```

空的 [] 和 .[] 后缀操作符被解释为 0 维下标, 这返回整个数组, 不是作为一个一维的空切片, 返回空元素.  这同样适用于散列上的  {} 和 .{} , 还有  `<>`, `.<>`,` «»`, 和 `.«»` constant and interpolating slice subscripting forms.

The | operator interpolates lazily for Array and Range objects. To get an immediate interpolation like Perl 5 does, add the eager list operator:

```
func(|(1..Inf));       # works fine
func(|eager 1..Inf);   # never terminates (well, actually...)
```

To interpolate a function's return value, you can say:

```
push |func();
```

Within such an argument list, function return values are automatically exploded into their various parts, as if you'd said:

```
my $capture = \(func());
push $$capture: @$capture, %$capture;
```

or some such. The | then handles the various zones appropriately depending on the context. An invocant only makes sense as the first argument to the outer function call. An invocant inserted anywhere else just becomes a positional argument at the front of its list, as if its colon changed back to a comma.

If you already have a capture variable, you can interpolate all of its bits at once using the prefix:<|> operator:

```
my (|$capture) := func();
push |$capture;
```

并行遍历数组中的元素

S32-container/zip.t lines 11–75  

In order to support parallel iteration over multiple arrays, Perl 6 has a zip function that builds a list of Seq objects from the elements of two or more arrays. In ordinary list context this behaves as a list of Captures and automatically flattens.

```
for zip(@names; @codes) -> $name, $zip {
    print "Name: $name;   Zip code: $zip\n";
}
```

zip has an infix synonym, the Z operator.

In an explicitly multidimensional list context, however, the sequences turn into subarrays, and each element would then have to be unpacked by the signature:

```
for lol(zip(@names; @codes)) -> [$name, $zip] {
    print "Name: $name;   Zip code: $zip\n";
}
```

By default the zip function reads to the end of the shortest list, but a short list may always be extended arbitrarily by putting * after the final value, which replicates the final value as many times as necessary. If instead of supplying a default value for short lists, you just wish to skip missing entries, use roundrobin instead:

S03-operators/misc.t lines 100–109  

```
for roundrobin(@queue1; @queue2; @queue3) -> $next {
    ...
}
```

Minimal whitespace DWIMmery 最适量的空白

数组或散列下标或参数列表的开括号前面禁止有空格, 那就是:

S02-lexical-conventions/minimal-whitespace.t lines 7–32  



``` perl
    @deadbeef[$x]         # okay
    @a       [$b]         # WRONG
    %monsters{'cookie'}   # okay
    %people  {'john'}     # WRONG
    saymewant('cookie')   # okay
    mewant   ('cookie')   # WRONG
```

这个约束的几种有用的副作用之一就是, 条件控制结构的周围不再需要圆括号了:

``` perl
   if $value eq $target {
        print "Bullseye!";
    }
    while $i < 10 { $i++ }
```

然而, 通过显式的使用 `unspace` 语法, 对齐下标和其他后缀操作符成为可能:

``` perl
     %squirrels{'fluffy'} = Squirrel.new;
     %monsters.{'cookie'} = Monster.new;
     %beatles\.{'ringo'}  = Beatle.new;
     %people\ .{'john'}   = Person.new;
```

通常, 在关键词和不引入下标或函数参数的开括号之间是需要有空格的, 相反, 任何后面直接跟着圆括号的关键字都会被看作一个方法调用.

```
if $a == 1 { say "yes" }            # preferred syntax
if ($a == 1) { say "yes" }          # P5-ish if construct
if($a,$b,$c)                        # if function call
```

It is possible for `if()` 调用一个  macro call 也是可能的,  但是如果这样, 它就是一个 `prefix:<if>`  macro  而非一个 `statement_control:<if>` macro.

Sequence points

Certain operators are guaranteed to provide sequence points. Sequence points are guaranteed whenever some thunk (a lazy chunk of code) is conditionally evaluated based on the result of some other evaluation, so the short-circuit and conditional operators all provide sequence points.

Certain other operators guarantee the absence of sequence points, including junctional operators, hyperoperators, and feed operators. These operators promise the compiler that you consider the bits of code not to be dependent on each other so that they can operate in parallel if they like.

A large number of operators (such as +) are stuck in the middle, and may exhibit sequential behavior today, but might not tomorrow. A program that relies on either sequential or parallel behavior for one of these operators is erroneous. As we get more feedback from people writing parallelizing optimizers, we reserve the right to classify various of the unclassified operators into one of the two specified sets. (We need to give these three sets of operators good names.)
