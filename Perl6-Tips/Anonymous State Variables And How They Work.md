title:  Anonymous State Variables And How They Work
date: 2016-02-24
tags: Perl6
categories: Perl 6

---

<blockquote class='blockquote-center'> 以苦为乐才是理所当然！</blockquote>

## Anonymous State Variables And How They Work

当调试代码的时候, 我经常添加一个计数变量以用于循环, 所以我能跟踪发生了什么, 或我能在代码片段中处理正迭代的部分数据集:

```perl6
my $event-no = 0;
for get_events() -> $event {
    $event-no++;
    process-event($event);
    last if $event-no >= 5;
}
```

如果你正在调试, 或者你正尝试在单行中节省空间, Perl  6 实际上有一个匿名状态变量(*anonymous state variables*)标记, 用不含名字的 `$`符号来标示(你还可以在很多可迭代对象身上使用 kv 方法来完成类似的东西, 但是匿名的 `$` 更普遍。)

```perl6
for get_events() -> $event {
    process-event($event);
    last if ++$ >= 5;
}
```

然而, 注意; 下面这样的用法是没有效果的:

```perl6
for get_events() -> $event {
    process-event($event);
    $++;
    last if $ >= 5;
}
```

好了, 为什么是那样的？

## Use the Source

好吧, 让我们来看看 Rakudo 源代码, 可以吗?

如你所想, 在 Perl 6 Grammar 中查找 `$` 是怎样被解析的将会是一个很困难的任务。所以我们让编译器自己来帮助我们! 我们会使用一个小例子:

```perl6
for ^10 { $++ }
```

并让 Rakudo 吐出它生成的 **AST**, 专门用于查找变量:

```perl
  $ perl6 --target=ast -e 'for ^10 { $++ }' | grep Var
      - QAST::Var(attribute $!do)
      - QAST::Var(attribute $!do)
    - QAST::Var(local __args__ :decl(param))
          - QAST::Var(lexical $¢ :decl(contvar))
          - QAST::Var(lexical $! :decl(contvar))
          - QAST::Var(lexical $/ :decl(contvar))
          - QAST::Var(lexical $_ :decl(contvar))
          - QAST::Var(lexical GLOBALish :decl(static))
          - QAST::Var(lexical EXPORT :decl(static))
          - QAST::Var(lexical $?PACKAGE :decl(static))
          - QAST::Var(lexical ::?PACKAGE :decl(static))
          - QAST::Var(lexical $=finish :decl(static))
                - QAST::Var(lexical $ANON_VAR__1 :decl(statevar))
                - QAST::Var(lexical $_ :decl(param))
                      - QAST::Var(lexical $ANON_VAR__1) :BY<EXPR/POSTFIX W> :nosink<?> :WANTED $
                        - QAST::Var(lexical $ANON_VAR__1) :BY<EXPR/POSTFIX W> :nosink<?> :WANTED $
          - QAST::Var(lexical $=pod :decl(static))
          - QAST::Var(lexical !UNIT_MARKER :decl(static))
            - QAST::Var(local ctxsave :decl(var))
            - QAST::Var(contextual $*CTXSAVE)
              - QAST::Var(local ctxsave)
                - QAST::Var(local ctxsave)
                - QAST::Var(local ctxsave)
```

你可能不会立即看到它, 但是那儿有一个可疑的声明: `$ANON_VAR__1`。现在我们有了一个搜索字符串并想得到更多相关的结果, 用 [ack](http://beyondgrep.com/) 这样的工具搜索源代码, 我们会找到 `src/Perl6/Actions.nqp`这个文件。让我们深入进去!

```perl
# taken from rakudo@85d20f3
sub declare_variable($/, $past, $sigil, $twigil, $desigilname, $trait_list, $shape?, :@post) {
    ...
    elsif $desigilname eq '' {
        if $twigil {
            $/.CURSOR.panic("Cannot have an anonymous variable with a twigil");
        }
        $name    := QAST::Node.unique($sigil ~ 'ANON_VAR_');
        $varname := $sigil;
    }
    ...
}
```

所以这部分代码(搜索 `ANON_VAR` 时唯一的结果)告诉我们当我们声明一个符号后面没有名字的变量时, 我们应该生成一个唯一的名字。

## How Did We Get Here?

那很好, 但是我们怎么从 grammar 中到达那里? 这种情况下我使用的小技巧就是抛出一个异常并查看回溯发生在哪?

```perl
sub declare_variable($/, $past, $sigil, $twigil, $desigilname, $trait_list, $shape?, :@post) {
    ...
    elsif $desigilname eq '' {
        if $twigil {
            $/.CURSOR.panic("Cannot have an anonymous variable with a twigil");
        }
+       if nqp::atkey(nqp::getenvhash(), 'ROB_DEBUG') {
+           $/.CURSOR.panic("here I am!");
+       }
        $name    := QAST::Node.unique($sigil ~ 'ANON_VAR_');
        $varname := $sigil;
    }
    ...
}
```

重新编译之后, 打开 `ROB_DEBUG` 环境变量并运行,  并使用 `--ll-exception`, 来确保内部构件被包含进了堆栈跟踪中:

```perl6
$ ROB_DEBUG=1 perl6 --ll-exception -e 'for ^10 { $++ }'
```

我不会临时包含这个堆栈跟踪, 但是你可以自己生成它如果你愿意追随的话。通过查看出现在提到 `Actions.nqp:3160`（我插入异常的地方） 后面提到 `Grammar.nqp` 的第一个堆栈跟踪项, 我们来到 `Grammar.nqp`中的 `token variable`:

```perl
# also taken from rakudo@85d20f3
token variable {
    :my $*IN_META := '';
    [
    | :dba('infix noun') '&[' ~ ']' <infixish('[]')>
    | <sigil> <twigil>? <desigilname>
      [ <?{ !$*IN_DECL && $*VARIABLE && $*VARIABLE eq $<sigil> ~ $<twigil> ~ $<desigilname> }>
        { self.typed_panic: 'X::Syntax::Variable::Initializer', name => $*VARIABLE } ]?
    | <special_variable>
    | <sigil> $<index>=[\d+]                              [<?{ $*IN_DECL }> <.typed_panic: "X::Syntax::Variable::Numeric">]?
    | <sigil> <?[<]> <postcircumfix>                      [<?{ $*IN_DECL }> <.typed_panic('X::Syntax::Variable::Match')>]?
    | <?before <sigil> <?[ ( [ { ]>> <!RESTRICTED> <?{ !$*IN_DECL }> <contextualizer>
    | $<sigil>=['$'] $<desigilname>=[<[/_!¢]>]
    | {} <sigil> <!{ $*QSIGIL }> <?MARKER('baresigil')>   # try last, to allow sublanguages to redefine sigils (like & in regex)
    ]
    [ <?{ $<twigil> && $<twigil> eq '.' }>
        [ <.unsp> | '\\' | <?> ] <?[(]> <!RESTRICTED> <arglist=.postcircumfix>
    ]?
    { $*LEFTSIGIL := nqp::substr(self.orig(), self.from, 1) unless $*LEFTSIGIL }
}
```

这段代码对你没有什么意义如果你初学 Perl 6的话, 更不用说 Rakudo 源代码了。我认为这一句是最重要的:

```perl6
| {} <sigil> <!{ $*QSIGIL }> <?MARKER('baresigil')> # try last, to allow sublanguages to redefine sigils (like & in regex)
```

这个分支接受由符号唯一组成的变量。所以 `token variable` 匹配源代码中的每个裸的 `$` 实例, 并且每次发生都会调用 `Actions::declare_variable`, 生成不同的变量, 我用这个片段来说没明:

```perl6
for ^3 {
    say ++$;
    say ++$;
}
=output
1
1
2
2
3
3
```

所以, 对于匿名状态变量你只能执行非常简单的操作。记住你也可以使用匿名数组或匿名散列变量来处理东西:

```perl
for ^10 {
    say((@).push($_));
}
```

但是在正式代码中不建议这么用。
