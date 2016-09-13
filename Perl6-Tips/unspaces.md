## unspace


有些语言例如 `C` 允许你转义一个换行符使行联合起来. 其它语言(例如正则表达式)因为各种各样的原因, 允许你使用反斜线转义一个空白符. Perl 6 把这种记法推广到任何种类的空白上. 通过在空白处前置一个 `\`, 任何相邻的空白(包括注释)都会在解析器面前隐身. 这就是鼎鼎大名的空白隐身( “unspace”).

在 Perl 中, 一个 [unspace](https://design.perl6.org/S02.html) 能够抑制任意的几种空白附属物. 例如, 因为 Perl 要求名词和后缀操作符之间不能出现空白, 所以使用 unspace 让你可以把后缀操作符贴线对齐:

``` perl
%hash\  {$key}
@array\ [$ix]
$subref\($arg)
```

上面的最后一种形式作为一种退化了的 unspace,  即反斜线后面直接跟着后缀. 注意, 反斜线前面不允许有空白, 所以:

``` perl
 $subref \($arg)
```

是语法错误(two terms in a row). 而

``` perl
foo \($arg)
```

会被解析为带有 `Capture` 参数的列表操作:

``` perl
foo(\($arg))
```

然而, 其它形式的 unspace 可能被有效地放在空白之前.

其它后缀操作符也可能使用 unspace:

``` perl
$number\  ++;
$number\  --;
1+3\      i;
$object\  .say();
$object\#`{ your ad here }.say
```

另外一种 “你看不见这空白” 的正常用法是, 在下一行放上一个点语法形式的后缀:

``` perl
    $object\ # comment
    .say
     $object\#`[ comment
    ].say
     $object\
    .say
```

但是 unspace 主要是关于语言扩展的: 它让你在换行可能会使解析器困惑的地方, 让行在任何情况下都能继续, 不管你当前安装的是什么解析器.(除非, 当然, 你自己覆写了 unspace 规则...)



尽管我们说, unspace 让空白在解析器面前隐身了,  但是它并不能使空白在词法分析程序面前隐身. 结果就是, 在 token 中禁止了 unspace. 此外, 如果 unspace 包含一行或多行,  它们的行数仍然会被计算在内.
