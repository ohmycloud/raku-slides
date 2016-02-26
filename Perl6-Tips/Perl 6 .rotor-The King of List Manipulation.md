title:  Perl 6 rotor - The King of List Manipulation

date: 2016-01-31

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>别来无恙, 你在心上！</blockquote>

对于 Perl 6 程序员, `.rotor`是一个强大的列表操作工具。

#### 分段

最简单的, `.rotor`接收一个整数**$number**并把列表分成多个子列表, 每个子列表含有 **$number** 个元素:

``` perl6
say <a b c d e f  g h>.rotor: 3
# ((a b c) (d e f))
```

我们有一个含有 8 个元素的列表, 我们在该列表上调用接收参数 3 的 `.rotor`方法, 它返回 2 个列表, 每个列表中含有 3 个元素。不包括原列表中的最后 2 个元素, 因为它们没有组成一个完整的3个元素的列表。然而它们可以被包含进来, 使用 `:partial`具名参数设置为 **True**:

``` perl6
say <a b c  d e f  g h>.rotor: 3, :partial
# ((a b c) (d e f) (g h))

say <a b c  d e f  g h>.rotor: 3, :partial(True)
# ((a b c) (d e f) (g h))

say <a b c  d e f  g h>.rotor: 3, :partial(False)
# ((a b c) (d e f))

```

下面应用一下我们刚刚学到的。把字符串分成列宽相等的几段:

``` perl6
"foobarberboorboozebazmeow".comb.rotor(10, :partial)».join».say
# foobarberb
# oorboozeba
# zmeow
```

分行然后每行前面添加 4 个空格:

``` perl6
"foobarberboorboozebazmeow".comb.rotor(10, :partial)>>.join>>.indent(4)>>.say
#    foobarberb
#    oorboozeba
#    zmeow
```

但是这最好被写为:

``` perl6
"foobarberboorboozebazmeow".comb(10)».say
```



#### 注意缝隙

假设你正在接受输入: 你得到一个单词, 它的法语翻译和它的西班牙语翻译, 等一堆单词。你只想输出特定语言, 所以我们需要在我们的列表中跳过某些项。 `.rotor`来拯救来了!

指定一对儿(Pair)整数作为 rotor 的参数会让每个列表中含有 **$key** 个元素, 每个列表之间有 **$value** 个空隙。看例子更简单一些:

``` perl6
say ^10 .rotor: 3 => 1, :partial
>>>OUTPUT: ((0 1 2) (4 5 6) (8 9))
say ^10 .rotor: 2 => 2, :partial
>>>OUTPUT: ((0 1) (4 5) (8 9))
```

第一个例子我们把缝隙设置为 1, 第二个例子我们把缝隙增加为 2。

``` perl6
enum <English French Spanish>;
say join " ", <Good Bon Buenos morning matin días>[French..*].rotor: 1 => 2;
>>>OUTPUT: Bon matin
```

其中 `[French..*]`意思为 `[1..*]`, 例子中 French 被枚举化为整数 1。

#### 重叠

当我们让缝隙变为负数的时候, 分段的列表中就会有元素重叠:

``` perl6
say <a a b c c c d>.rotor: 2 => -1
>>>OUTPUT: ((a a) (a b) (b c) (c c) (c c) (c d))
say <a a b c c c d>.rotor(2 => -1).map: {$_[0] eq $_[1] ?? "same" !! "different"}
>>>OUTPUT: (same different different same same different)
```

#### 全力以赴

`.rotor`不单单只能接受单个 **Int** 值或 **Pair**, 你可以指定额外的 **Int** 或 **Pairs** 位置参数来把列表分成不同尺寸大小的子列表, 列表之间的缝隙也不同。下面以一个日志文件为例:

``` perl6
IP: 198.0.1.22
Login: suser
Time: 1454017107
Resource: /report/accounting/x23gs
Input: x=42,y=32
Output: success
===================================================
IP: 198.0.1.23
Login: nanom
Time: 1454027106
Resource: /report/systems/boot
Input: mode=standard
Output: success
```

每段之间有一行双划线。

我们想这样输出: **Header** 里包含 IP, Login, Time, Resource; **Operation** 里包含 Resource, Input, Output。

``` perl6
for 'report.txt'.IO.lines».indent(4).rotor( 4 => -1, 3 => 1 ) -> $head, $op {
    .say for "Header:",    |$head,
             "Operation:", |$op, '';
}

>>>OUTPUT:
    Header:
        IP: 198.0.1.22
        Login: suser
        Time: 1454017107
        Resource: /report/accounting/x23gs
    Operation:
        Resource: /report/accounting/x23gs
        Input: x=42,y=32
        Output: success

    Header:
        IP: 198.0.1.23
        Login: nanom
        Time: 1454027106
        Resource: /report/systems/boot
    Operation:
        Resource: /report/systems/boot
        Input: mode=standard
        Output: success
```

先是 4 个元素一块, 缝隙为 -1(有重叠), 然后是 3 个元素一块, 缝隙为 1。这就在每个分段的列表中包含了 Resource 字段。因为 `$op` 和 `$head`是列表, 我们使用管道符号 `|`来展平列表。

记住, 你提供给 `.rotor`方法的模式可以动态地生成! 这儿我们使用 sine 函数来生成:

``` perl6
say ^92 .rotor(
    (0.2, 0.4 ... 3).map: (10 * *.sin).Int # pattern we supply to .rotor
).join: "\n"'
>>>OUTPUT:
    0
    1 2 3
    4 5 6 7 8
    9 10 11 12 13 14 15
    16 17 18 19 20 21 22 23
    24 25 26 27 28 29 30 31 32
    33 34 35 36 37 38 39 40 41
    42 43 44 45 46 47 48 49 50
    51 52 53 54 55 56 57 58 59
    60 61 62 63 64 65 66 67 68
    69 70 71 72 73 74 75 76
    77 78 79 80 81 82
    83 84 85 86 87
    88 89 90
    91

```
