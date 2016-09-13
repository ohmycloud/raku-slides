除了 q 和 qq 之外，现在还有一种基本形式的 Q，它不会进行插值，除非显式地修改它那样做。所以，q 实际上是 Q:q 的简称，qq 实际上是 Q:qq 的简称。实际上所有的 quote-like 形式都派生自带有副词的 Q 形式：


[S02-literals/quoting.t lines 95–116](https://github.com/perl6/roast/blob/master/S02-literals/quoting.t#L95-L116)
[S02-literals/quoting.t lines 132–139](https://github.com/perl6/roast/blob/master/S02-literals/quoting.t#L132-L139)

```perl6
q//         Q :q //
qq//        Q :qq //
rx//        Q :regex //
s///        Q :subst ///
tr///       Q :trans ///
```

诸如 `:regex` 的副词通过转换到不同的解析器改变了语言的解析。这能完全改变任何之后的副词还有所引起的东西自身的解释。

```perl6
q:s//       Q :q :scalar //
rx:s//      Q :regex :scalar //
```

就像 `q[...]` 拥有简写形式的 '...', 并且 `qq[...]` 拥有简写形式的 "..." 一样，完整的 `Q[...]` 引用也有一种使用半角括号 ?...? 的短形式。

## 引号上的副词


广义上的引号现在可以接收副词了：
[S02-literals/quoting.t lines 210–223](https://github.com/perl6/roast/blob/master/S02-literals/quoting.t#L210-L223)
  [S02-literals/quoting.t lines 55–69](https://github.com/perl6/roast/blob/master/S02-literals/quoting.t#L55-L69)
 [S02-literals/quoting.t lines 427–501](https://github.com/perl6/roast/blob/master/S02-literals/quoting.t#L427-L501)

```perl6
Short       Long            Meaning
=====       ====            =======
:x          :exec           作为命令执行并返回结果
:w          :words          按单词分割结果(没有引号保护)
                                     

:ww         :quotewords     按单词分割结果 (带有引号保护)
:v          :val            Evaluate word or words for value literals
:q          :single         插值 \\, \q 和 \' (or whatever)
                                    

:qq         :double         使用 :s, :a, :h, :f, :c, :b 进行插值
:s          :scalar         插值 $ vars
:a          :array          插值 @ vars
:h          :hash           插值 % vars

                        
:f          :function       插值 & 调用
:c          :closure        插值 {...} 表达式
:b          :backslash      插值 \n, \t, 等. (至少暗示了 :q )
:to         :heredoc        把结果解析为 heredoc 终止符
            :regex          解析为正则表达式
            :subst          解析为置换 (substitution)
            :trans          解析为转换 (transliteration)
            :code           Quasiquoting
:p          :path           返回一个 Path 对象 (查看 S16 获取更多选项)
```

通过在开头加入一个带有短形式的单个副词的 Q，q，或 qq，你可以省略掉第一个冒号，这产生了如下形式：

```perl6
qw /a b c/;                         # P5-esque qw// meaning q:w
Qc '...{$x}...';                    # Q:c//, interpolate only closures
qqx/$cmd @args[]/                   # equivalent to P5's qx//
```
(注意 qx// 不插值)

如果你想进一步缩写，那么定义一个宏：

```perl6
macro qx { 'qq:x ' }          # equivalent to P5's qx//
macro qTO { 'qq:x:w:to ' }    # qq:x:w:to//
macro quote:<? ?> ($text) { quasi { {{{$text}}}.quoteharder } }
```

所有大写的副词被保留用作用户定义的引号。所有在 Latin-1 上面的 Unicode 分隔符被保留用作用户定义的引号。
[S02-literals/quoting.t lines 352–426](https://github.com/perl6/roast/blob/master/S02-literals/quoting.t#L352-L426)

关于上面我们现在有了一个推论，我们现在能说：

```perl6
 %hash = qw:c/a b c d {@array} {%hash}/;
```
或

```perl6
%hash = qq:w/a b c d {@array} {%hash}/;
```

把东西(items)插值到 qw 中。默认地，数组和散列在插值时只带有空格分隔符，所以之后的按空格分割仍旧能工作。（但是内置的  ?...?  引号自动进行了等价于 `qq:ww:v/.../` 的插值）。 内置的 `<...>` 等价于 `q:w:v/.../`。