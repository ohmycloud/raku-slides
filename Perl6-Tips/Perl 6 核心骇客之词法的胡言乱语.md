[Perl 6 核心骇客: 词法的胡言乱语](http://perl6.party/post/Perl-6-Core-Hacking-Grammatical-Babble)

喜欢修复 Perl 6 编译器中的 bug? 这儿有一个[great grammar bugglet](https://rt.perl.org/Ticket/Display.html?id=128304): 当 `„”` 引号用在引起的用空白分割的单词列表构造器中时看起来好像不能工作:

```perl6
say „hello world”;
.say for qww<„hello world”>;
.say for qww<"hello world">;

# OUTPUT:
# hello world
# „hello
# world”
# hello world
```

`”` 引号不应该出现在输出中并且在输出中我们应该只有 3 行输出; 这 3 行输出都是 `hello world`。看起来像是一个待修复的有趣的 bug! 我们进去看看。

## 你怎样拼写它?

事实上这段代码没能正确解析表明这是一个 grammar bug。大部分的 grammar 住在 [src/Perl6/Grammar.nqp](https://github.com/rakudo/rakudo/blob/83b8b1a/src/Perl6/Grammar.nqp)中, 但是在我们的手变脏之前, 让我们来解决我们应该查看什么。

二进制 `perl6` 有一个 `--target` 命令行参数来接收其中之一的编译步骤并且会导致那个步骤的输出被产生出来。那儿有哪些步骤? 根据你正使用的后端它们也会有所不同, 但是你可以仅仅运行 `perl6 --stagestats -e ''` 把它们都打印出来:

```
zoffix@leliana:~$ perl6 --stagestats -e ''
Stage start      :   0.000
Stage parse      :   0.077
Stage syntaxcheck:   0.000
Stage ast        :   0.000
Stage optimize   :   0.001
Stage mast       :   0.004
Stage mbc        :   0.000
Stage moar       :   0.000
```

Grammars 是关于解析的, 所以我们会查询 `parse` 目标(target)。至于要执行的代码, 我们会仅仅给它有问题的那块; 即 `qww<>`:

```
zoffix@leliana:~$ perl6 --target=parse -e 'qww<„hello world”>'
- statementlist: qww<„hello world”>
  - statement: 1 matches
    - EXPR: qww<„hello world”>
      - value: qww<„hello world”>
        - quote: qww<„hello world”>
          - quibble: <„hello world”>
            - babble:
              - B:
            - nibble: „hello world”
          - quote_mod: ww
            - sym: ww
```

那很棒! 每一行前面都有能在 grammar 中找到的 token 的名字, 所以现在我们知道了在哪里查找问题。

我们还知道基本的引号能正确地工作, 所以我们也倾倒出它们的解析步骤, 来看看这两个输出之间是否有什么不同:

```
zoffix@leliana:~$ perl6 --target=parse -e 'qww<"hello world">'
- statementlist: qww<"hello world">
  - statement: 1 matches
    - EXPR: qww<"hello world">
      - value: qww<"hello world">
        - quote: qww<"hello world">
          - quibble: <"hello world">
            - babble:
              - B:
            - nibble: "hello world"
          - quote_mod: ww
            - sym: ww
```

那么... 好吧, 除了引号不同, 解析数完全一样。所以它看起来好像所有涉及的 tokens 都是相同的, 但是那些 tokens 所做的事情不同。

我们不必检查输出中我们看到的每个 tokens。`statementlist` 和 `statement` 是匹配普通语句的 tokens, `EXPR` 是占位符解析器, `value` 是它正操作的值中的一个。我们会忽略上面那些, 留给我们的是下面这样一个可疑的列表:

```
- quote: qww<„hello world”>
  - quibble: <„hello world”>
    - babble:
      - B:
    - nibble: „hello world”
  - quote_mod: ww
    - sym: ww
```  

让我们开始质问它们。

## 到兔子洞里去...

你自己搞一份本地的 [Rakudo 仓库](https://github.com/rakudo/rakudo/), 如果你已经有了一份,那么打开 [src/Perl6/Grammar.nqp](https://github.com/rakudo/rakudo/blob/83b8b1a/src/Perl6/Grammar.nqp), 然后放松点。

我们会从树的顶部到底部跟随我们的 tokens, 所以我们首先需要找到的是 `token quote`, `rule quote`, `regex quote` 或 `method quote`; 以那个顺序搜索, 因为第一项很可能就是正确的东西。

这种情况下, 它是一个 [token quote](https://github.com/rakudo/rakudo/blob/83b8b1a/src/Perl6/Grammar.nqp#L3555), 它是一个 [proto regex](https://docs.perl6.org/language/grammars#Protoregexes)。我们的代码使用了它的 `q` 版本并且你还可以认出靠近它的 `qq` 和 `Q` 版本:

```perl6
token quote:sym<q> {
    :my $qm;
    'q'
    [
    | <quote_mod> {} <.qok($/)> { $qm := $<quote_mod>.Str }
        <quibble(%*LANG<Quote>, 'q', $qm)>
    | {} <.qok($/)> <quibble(%*LANG<Quote>, 'q')>
    ]
}
token quote:sym<qq> {
    :my $qm;
    'qq'
    [
    | <quote_mod> { $qm := $<quote_mod>.Str } <.qok($/)>
        <quibble(%*LANG<Quote>, 'qq', $qm)>
    | {} <.qok($/)> <quibble(%*LANG<Quote>, 'qq')>
    ]
}
token quote:sym<Q> {
    :my $qm;
    'Q'
    [
    | <quote_mod> { $qm := $<quote_mod>.Str } <.qok($/)>
        <quibble(%*LANG<Quote>, $qm)>
    | {} <.qok($/)> <quibble(%*LANG<Quote>)>
    ]
}
```

可以看到 `qq` 和 `Q` 的主体看起来像 `q`, 我们也来看看它们是否有我们要找的那个 bug:

```
zoffix@leliana:~$ perl6 -e '.say for qqww<„hello world”>'
„hello
world”
zoffix@leliana:~$ perl6 -e '.say for Qww<„hello world”>'
„hello
world
```

是的, 它们也存在, 所以 `token quote` 不可能是那个问题。我们来分解下  `token quote:sym<q>` 是做什么的, 来算出怎么进行到下一步; 它的备选之一没有被用在我们当前的代码中, 所以我会省略它:

```perl6
token quote:sym<q> {
    :my $qm;
    'q'
    [
    | <quote_mod> {} <.qok($/)> { $qm := $<quote_mod>.Str }
        <quibble(%*LANG<Quote>, 'q', $qm)>
    | # (this branch omited)
    ]
}
```

在第二行中, 我们创建了一个变量, 然后匹配字面值 `q` 然后是 `quote_mod` token。那个是我们的 `--target=parse` 输出中的一部分并且如果你像我们找出 `quote` token 那样找出它, 你会注意到它是一个 proto regex, 即, 在那种情况下, 匹配我们代码的 `ww` 块。后面跟着的空 `{}` 块我们可以忽略(那是一个 bug 的替代方法可能在你读到这儿时已经被修复了)。目前为止, 我们已经匹配了我们代码的 `qww` 块。


再往前走, 我们遇见了对 `qok` token 的调用, 当前的 [Match](https://docs.perl6.org/type/Match) 对象作为其参数。`<.qok>` 中的点号表明这是一个非捕获 token 匹配, 这就是它为什么它没有在我们的 `--target=parse` 输出中出现的原因。我们定位到那个 token 并看看它是关于什么的:

```perl6
token qok($x) {
    » <![(]>
    [
        <?[:]> || <!{
            my $n := ~$x; $*W.is_name([$n]) || $*W.is_name(['&' ~ $n])
        }>
    ]
    [ \s* '#' <.panic: "# not allowed as delimiter"> ]?
    <.ws>
}
```

我的天呐! 这么多符号, 但是这个家伙很容易了: `»` 是一个[右单词边界](https://docs.perl6.org/language/regexes#%3C%3C_and_%3E%3E_,_left_and_right_word_boundary)后面不能跟着一个开圆括号(`<![(]>`), 再跟着一个备选分支(`[]`), 再跟着一个检查, 即我们不想尝试使用 `#` 号作为分割符(`[...]?`), 最后跟着一个 [<.ws>](https://docs.perl6.org/language/grammars#ws) token 吞噬各种各样的空白。

在备选分支中, 我们使用了首个token匹配的 `||` 备选分支(和最长token匹配 `|` 相反), 并且首个 token 向前查看一个冒号 `<?[:]>`。 如果失败了, 我们就字符串化那个给定的参数(`~$x`)并且之后在 [World对象](https://github.com/rakudo/rakudo/blob/83b8b1a/src/Perl6/World.nqp) 身上调用 `is_name` 方法, 原样地传递带有前置 `&` 符号的字符串化的参数。传递的 `~$x` 是目前为止我们的 `token quote:sym<q>` token 所匹配到的东西(并且那是字符串 `qww`)。`is_name` 方法仅仅检查那个给定的符号是否被定义还有根据那个返回值检查我们的 token 匹配会通过还是会失败。如果那个求值代码返回一个真值那么我们正在使用的  `<!{ ... }>` 结构就会失败。


总而言之, 这个 token 所做的所有事情就是检查我们没有使用 `#` 作为分隔符并且没有尝试去调用一个方法或sub。房间的这个角落没有 bug 迹象。 让我们回到我们的 `token quote:sym<q>` 来查看下一步做什么:

```perl6
token quote:sym<q> {
    :my $qm;
    'q'
    [
    | <quote_mod> {} <.qok($/)> { $qm := $<quote_mod>.Str }
        <quibble(%*LANG<Quote>, 'q', $qm)>
    | # (this branch omited)
    ]
}
```

我们已经完成了 `<.qok>` 的检查, 所以下一步是 `{ $qm := $<quote_mod>.Str }`, 那仅仅把匹配到 `quote_mod` token 的字符串值存到 `$qm` 变量中。在我们的例子中, 那个值就是字符串 `ww`。

下面跟着的是另外一个 token, 它在我们的 `--target=parse` s输出中出现过:

```perl6
<quibble(%*LANG<Quote>, 'q', $qm)>
```

这里, 我们使用三个位置参数引用了那个 token: [Quote language braid](https://github.com/rakudo/rakudo/blob/04af57c3b3d32353e36614de53396d2b4a08b7be/src/Perl6/Grammar.nqp#L424), 字符串 `q` 和 我们保存在变量 `$qm` 中的字符串 `ww`。我想知道它是做什么的。那是我们的下一站。全力以赴!

## Nibble Quibble Babbling Nibbler

这里是完整的 `token quibble` 并且你马上可以发现我们不得不从开始往更深处挖掘, 因为第 5 行是另外一个 token 匹配:

```perl6
token quibble($l, *@base_tweaks) {
    :my $lang;
    :my $start;
    :my $stop;
    <babble($l, @base_tweaks)>
    {
        my $B  := $<babble><B>.ast;
        $lang  := $B[0];
        $start := $B[1];
        $stop  := $B[2];
    }

    $start <nibble($lang)>
    [
        $stop
        || {
            $/.CURSOR.typed_panic(
                'X::Comp::AdHoc',
                payload => "Couldn't find terminator $stop (corresponding $start was at line {
                    HLL::Compiler.lineof(
                        $<babble><B>.orig(), $<babble><B>.from()
                    )
                })",
                expected => [$stop],
            )
        }
    ]

    {
        nqp::can($lang, 'herelang')
        && self.queue_heredoc(
            $*W.nibble_to_str(
                $/,
                $<nibble>.ast[1], -> {
                    "Stopper '" ~ $<nibble> ~ "' too complex for heredoc"
                }
            ),
            $lang.herelang,
        )
    }
}
```

我们定义了 3 个变量然后引用了 `babble` token, 这个 babble 引用了和 `quibble` token 所引用的同样的参数。我们来以和查找所有之前的 tokens 同样的方式查找它并窥探它的内核。为了简洁, 我移除了大约一半[代码](https://github.com/rakudo/rakudo/blob/bc35922/src/Perl6/Grammar.nqp#L111-L125):那部分是处理副词的, 目前我们不能在我们的代码中使用它。

```perl6
token babble($l, @base_tweaks?) {
    :my @extra_tweaks;

    # <irrelevant portion redacted>

    $<B>=[<?before .>]
    {
        # Work out the delimeters.
        my $c := $/.CURSOR;
        my @delims := $c.peek_delimiters($c.target, $c.pos);
        my $start := @delims[0];
        my $stop  := @delims[1];

        # Get the language.
        my $lang := self.quote_lang($l, $start, $stop, @base_tweaks, @extra_tweaks);
        $<B>.'!make'([$lang, $start, $stop]);
    }
}
```

我们通过把向前查看捕获到 `$<B>` 捕获中开始, 它用作更新当前的 Cursor 位置, 然后进入以执行那个代码块。我们把当前的 Cursor 存储在 `$c` 中, 然后在它身上调用 `.peek_delimiters` 方法。如果我们为了它在内置的 rakudo 目录中进行 `grep`, 我们会看到它被定义在 [NQP](https://github.com/perl6/nqp/blob/4fd4b48afb45c8b25ccf7cfc5e39cb4bd658901d/src/HLL/Grammar.nqp#L200)中, 在 [nqp/src/HLL/Grammar.nqp](https://github.com/perl6/nqp/blob/4fd4b48afb45c8b25ccf7cfc5e39cb4bd658901d/src/HLL/Grammar.nqp#L200)中, 但是在我们冲出去阅读它的代码之前, 注意它是怎样返回两个分隔符的。我们仅仅把它们打印出来好了?

`src/Perl6/Grammar.nqp` 的 `.nqp` 后缀名表明我们正处在 NQP 的地盘儿, 所以我们不要使用 [NQP ops](https://github.com/perl6/nqp/blob/master/docs/ops.markdown)仅仅并且不是完全的 Perl 6 代码。通过把下面这一行代码添加到 `@delim` 被赋值给 `$start` 和 `$stop` 的地方, 我们能找出 `.peek_delimiters` 给我们的东西:

```perl6
nqp::say("$sart $stop");
```

编译!

```
$ perl Configure.pl --gen-moar --gen-nqp --backends=moar &&
  make &&
  make test &&
  make install
```

即使在编译期间, 通过吐出额外的东西, 我们的调试行已经给了我们所有那些分隔符是关于什么的启发。再次运行我们的有问题的代码:

```
$ ./perl6 -e '.say for qww<„hello world”>;'
< >
hello world
```

打印出的分隔符是 `qww` 里的尖括号分隔符。我们对那些不感兴趣, 所以我们可以忽略 `.peek_delimiters` 并继续。再往上是 `.quote_lang` 方法。 它的名字里有一个"引号"而我们有一个关于引号的问题.. 听起来我们离真相越来越近了。我们来看看我们正传递给它的是什么参数:

- `$1` — [Quote language braid](https://github.com/rakudo/rakudo/blob/04af57c3b3d32353e36614de53396d2b4a08b7be/src/Perl6/Grammar.nqp#L4752)
- `$start` / `$stop` — 尖括号分隔符
- `@base_tweaks` — 包含一个元素: 字符串 `ww`
- `@extra_tweaks` — 额外的副词, 这里我们没有, 所以这个数组是空的

定位到 `method quote_lang`; 它仍然在 [src/Perl6/Grammar.nqp](https://github.com/rakudo/rakudo/blob/04af57c3b3d32353e36614de53396d2b4a08b7be/src/Perl6/Grammar.nqp#L65)文件中:

```perl6
method quote_lang($l, $start, $stop, @base_tweaks?, @extra_tweaks?) {
    sub lang_key() {
        # <body redacted>
    }
    sub con_lang() {
        # <body redacted>
    }

    # Get language from cache or derive it.
    my $key := lang_key();
    nqp::existskey(%quote_lang_cache, $key) && $key ne 'NOCACHE'
        ?? %quote_lang_cache{$key}
        !! (%quote_lang_cache{$key} := con_lang());
}
```

我们有两个词法子例程 `lang_key` 和 `con_lang`, 在它们下面我们把 `lang_key` 的输出存储到 `$key` 中, 在 `%quote_lang_cache` 中这个 `$key` 被用在整个缓存 dance 中, 所以我们可以忽略掉 `lang_key` sub 并直接进入 `con_lang`, 它被调用以生成我们的 `quote_lang` 方法的返回值:

```perl6
sub con_lang() {
    my $lang := $l.'!cursor_init'(self.orig(), :p(self.pos()), :shared(self.'!shared'()));
    for @base_tweaks {
        $lang := $lang."tweak_$_"(1);
    }

    for @extra_tweaks {
        my $t := $_[0];
        if nqp::can($lang, "tweak_$t") {
            $lang := $lang."tweak_$t"($_[1]);
        }
        else {
            self.sorry("Unrecognized adverb: :$t");
        }
    }
    nqp::istype($stop,VMArray) ||
    $start ne $stop ?? $lang.balanced($start, $stop)
                    !! $lang.unbalanced($stop);
}
``` 

在初始化 Cursor 位置之后, `$lang` 继续包含我们的 Quote 语言编织然后我们落进一个 `for` 循环来迭代 `@base_tweaks`, 对于里面的每一个元素, 我们都调用方法 `tweak_$_`, 给它传递一个真值 `1`。因为我们仅仅只有一个 base tweak, 这意味着我们正在Quote braid上调用方法 `tweak_ww`。我们来看看那个方法是关于什么的。

因为 Quote braid 被定义在同一个文件中, 仅仅搜索 `method tweak_ww` 好了:


```perl6
method tweak_ww($v) {
    $v ?? self.add-postproc("quotewords").apply_tweak(ww)
       !! self
}
``` 

很好。我们给它的 `$v` 为真, 所以我们调用了 `.add-postproc` 然后调用 `.apply_tweak(ww)`。看一下那个方法的上面和下面, 我们看到 `.add-postproc` 也用在其它不含 bug 的引号中, 所以我们忽略它并直接跳到 `.apply_tweak`:

```perl6
method apply_tweak($role) {
    my $target := nqp::can(self, 'herelang') ?? self.herelang !! self;
    $target.HOW.mixin($target, $role);
    self
}
```

啊哈! 它的参数是一个 role 并且它把该 role 混进来我们的 Quote braid 中。我们来看看那个 role 是关于什么的(再一次, 仅仅在文件中搜索 [role ww](https://github.com/rakudo/rakudo/blob/94b09ab9280d39438f84cb467d4b3d3042b8f672/src/Perl6/Grammar.nqp#L4846), 或者仅仅向上滚动一点):

```perl6
role ww {
    token escape:sym<' '> {
        <?[']> <quote=.LANG('MAIN','quote')>
    }
    token escape:sym<‘ ’> {
        <?[‘]> <quote=.LANG('MAIN','quote')>
    }
    token escape:sym<" "> {
        <?["]> <quote=.LANG('MAIN','quote')>
    }
    token escape:sym<“ ”> {
        <?[“]> <quote=.LANG('MAIN','quote')>
    }
    token escape:sym<colonpair> {
        <?[:]> <!RESTRICTED> <colonpair=.LANG('MAIN','colonpair')>
    }
    token escape:sym<#> {
        <?[#]> <.LANG('MAIN', 'comment')>
    }
}
```

奥, 我的天呐!引号! 如果这个地方不是我们修复 bug 的地方, 那么我就是一个芭蕾舞女演员。 我们找到它了!

我们定位到的 role 把进了某些 tokens 混合进了我们正使用的 Quote braid 中来解析 `qww` 的内容。我们带有 bug 的 `„”` 引号组合明显不在那个列表中。我们来把它添加进去!

```perl6
token escape:sym<„ ”> {
    <?[„]> <quote=.LANG('MAIN','quote')>
}
```

编译! 运行我们带有 bug 的代码:

```perl6
$ ./perl6 -e '.say for qww<foo „hello world” bar>'
foo
bar
```

悲催! 好吧, 我们确实为引号处理找到了正确的地方, 但是我们让问题变得更加糟糕了。发生了什么?

## Quotastic Inaction

我们新的 token 肯定解析了那个引号, 但是我们绝对没有给它添加 Actions 动作... 好吧, 对它起作用。 Action 类和 Grammars 相邻, 在 `src/Perl6/Actions.nqp` 中。打开它并定位到匹配的方法那里; 比如 [method escape:sym<“ ”>](https://github.com/rakudo/rakudo/blob/94b09ab9280d39438f84cb467d4b3d3042b8f672/src/Perl6/Actions.nqp#L9243)。

```perl6
method escape:sym<' '>($/) { make mark_ww_atom($<quote>.ast); }
method escape:sym<" ">($/) { make mark_ww_atom($<quote>.ast); }
method escape:sym<‘ ’>($/) { make mark_ww_atom($<quote>.ast); }
method escape:sym<“ ”>($/) { make mark_ww_atom($<quote>.ast); }
```

并在列表中添加我们自己的版本:

```perl6
method escape:sym<„ ”>($/) { make mark_ww_atom($<quote>.ast); }
```


编译! 运行我们带有 bug 的代码:

```
$ ./perl6 -e '.say for qww<foo „hello world” bar>'
foo
hello world
bar
```

呼! 成功了! 不再有 bug 了。我们修复了那个 bug! 

但是, 等一下...

## 遗漏了, 但是没有忘记

看一下[所有可能的奢华的引号的列表](https://docs.perl6.org/language/unicode_texas#Other_acceptable_single_codepoints)。尽管我们的 bug 报告中仅仅提到了 `„”` 引号对儿, 但是 `‚‘` 和 `「」` 都不在我们的 `role ww` tokens 中。远远不止的是, 某些左/右引号, 当它们交换位置后, 在引起字符串的时候也刚好能工作, 所以它们也应该在 `qww` 中起效。然而, 添加一整串额外的 tokens 和一整串其它的 actions 方法是相当不精彩的。有没有更好的方法?

我们仔细看看我们的 tokens:

```perl6
token escape:sym<“ ”> {
    <?[“]> <quote=.LANG('MAIN','quote')>
}
```

`sym<“ ”>` 我们可以把它省略了 — 这里它的功能仅仅是作为一个名字。我们留下的是一个向前查看的 `“` 引号还有 `<quote=.LANG('MAIN','quote')>`。所以我们可以向前查看所有的我们关心的开口引号并让 MAIN braid 接管所有的细节。

所以, 让我们用这个单个 token 替换掉所有的引号处理 tokens:

```perl6
token escape:sym<'> {
    <?[ ' " ‘ ‚ ’ “ „ ” 「 ]> <quote=.LANG('MAIN','quote')>
}
```

并且使用下面这个单个 action 替换掉所有的匹配 actions 方法:

```perl6
method escape:sym<'>($/) { make mark_ww_atom($<quote>.ast); }
```

编译! 运行我们的带有某些引号变体的代码:

```
$ ./perl6 -e '.say for qww<„looks like” ‚we fixed‘ ｢this thing｣>'
looks like
we fixed
this thing
```

精彩! 我们不仅让所有的引号都能正常工作, 还设法清理的存在的 tokens 和 actions 方法。现在所有我们需要做的就是对我们的修复做测试并且我们已经准备提交了。

## 享用 bug 烤肉

[Perl 6 官方测试套件 Roast](https://github.com/perl6/roast) 是在 Rakudo 内建目录中的 `t/spec` 中，如果它不存在, 仅仅运行 `make spectest` 就好了并且在它把 roast 仓库克隆到 `t/spec` 中后就中止它。我们需要找到在哪里插入我们的测试而 `grep` 是干那件事的好朋友:

```
zoffix@VirtualBox:~/CPANPRC/rakudo/t/spec$ grep -R 'qww' .
Binary file ./.git/objects/pack/pack-5bdee39f28283fef4b500859f5b288ea4eec20d7.pack matches
./S02-literals/allomorphic.t:    my @wordlist = qqww[1 2/3 4.5 6e7 8+9i] Z (IntStr, RatStr, RatStr, NumStr, ComplexStr);
./S02-literals/allomorphic.t:        isa-ok $val, Str, "'$val' from qqww[] is a Str";
./S02-literals/allomorphic.t:        nok $val.isa($wrong-type), "'$val' from qqww[] is not a $wrong-type.perl()";
./S02-literals/allomorphic.t:    my @wordlist  = qqww:v[1 2/3 4.5 6e7 8+9i];
./S02-literals/allomorphic.t:    my @written = qqww:v[1 2/3 $num 6e7 8+9i ten];
./S02-literals/allomorphic.t:    is-deeply @angled, @written, "«...» is equivalent to qqww:v[...]";
./S02-literals/quoting.t:    is(qqww[$alpha $beta], <foo bar>, 'qqww');
./S02-literals/quoting.t:    for (<<$a b c>>, qqww{$a b c}, qqw{$a b c}).kv -> $i, $_ {
./S02-literals/quoting.t:    is-deeply qww<a a ‘b b’ ‚b b’ ’b b‘ ’b b‘ ’b b’ ‚b b‘ ‚b b’ “b b” „b b”
./S02-literals/quoting.t:    'fancy quotes in qww work just like regular quotes';
./integration/advent2014-day16.t:    for flat qww/ foo bar 'first second' / Z @a -> $string, $result {
```

看起来 `S02-literals/quoting.t` 是它的一个好地方。打开那个文件, 在它的顶部, 通过我们添加的测试的数量来增加 `plan` 的数量 — 在这个例子中仅仅增加一条就好了。然后滚动到底部并创建一个 block 块, 前面添加一个注释, 并为我们正修复的 [bug 报告](https://rt.perl.org/Ticket/Display.html?id=128304)引用那个 RT 标签数字。

在文件里面, 我们使用 [is-deeply](https://docs.perl6.org/language/testing#index-entry-is-deeply-is-deeply%28%24value%2C_%24expected%2C_%24description%3F%29) 测试函数, 它使用 [eqv 操作符](https://docs.perl6.org/routine/eqv)语义来做测试。我们会给它一个带有完整引号串的 `qww<>` 行并告诉它我们所期望返回的项目列表。还要写下测试描述:

```perl6
# RT #128304
{
    is-deeply qww<a a ‘b b’ ‚b b’ ’b b‘ ’b b‘ ’b b’ ‚b b‘ ‚b b’ “b b” „b b”
            ”b b“ ”b b“ ”b b” „b b“ „b b” ｢b b｣ ｢b b｣>,
        ('a', 'a', |('b b' xx 16)),
    'fancy quotes in qww work just like regular quotes';
}
```

返回到 Rakudo checkout, 运行修改后的测试并保证它通过:

```
$ make t/spec/S02-literals/quoting.t
# <lots of output>
All tests successful.
Files=1, Tests=185,  3 wallclock secs ( 0.03 usr  0.01 sys +  2.76 cusr  0.11 csys =  2.91 CPU)
Result: PASS
```

漂亮。 提交测试 bug 修复好了并且把它们送走! 我们做到了!

## 结论

当我们在修复 Perl 6 中的解析 bugs 的时候, 把程序减少到能重新产生那个 bug 的最小部分然后使用 `--target=parse` 命令行参数, 得到解析树的输出, 找到所匹配的那个 tokens。`statementlist`



然后, 在 [src/Perl6/Grammar.nqp](https://github.com/rakudo/rakudo/blob/04af57c3b3d32353e36614de53396d2b4a08b7be/src/Perl6/Grammar.nqp) 中跟随这些 tokens, 它也继承自 [NQP 的 src/HLL/Grammar.nqp](https://github.com/perl6/nqp/blob/4fd4b48afb45c8b25ccf7cfc5e39cb4bd658901d/src/HLL/Grammar.nqp) 。 与位于 [src/Perl6/Actions.nqp](https://github.com/rakudo/rakudo/blob/04af57c3b3d32353e36614de53396d2b4a08b7be/src/Perl6/Actions.nqp) 中的 actions 类协作, 跟随着代码找出正在做什么并期望找出问题出现在什么位置。

修复它。测试它。ship 它。

充满了乐趣。














