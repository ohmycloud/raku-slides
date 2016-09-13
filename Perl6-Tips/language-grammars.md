## Actions in Grammar


[原文在这]([http://doc.perl6.org/language/grammars)](http://doc.perl6.org/language/grammars))

Grammars - 一组具名 regexes 组成正式的 grammar

Grammars 是一个很强大的工具用于析构文本并通常返回数据结构。

例如, Perl 6 是使用 Perl 6 风格 grammar 解析并执行的。

对普通 Perl 6 使用者更实用的一个例子是 [JSON::Tiny](https://github.com/moritz/json)模块, 它能反序列化任何合法的 JSON 文件, 而反序列代码只有不到 100 行, 还能扩展。

Grammars 允许你把 regexes 组织到一块儿, 就像类(class) 中组织方法那样。

## 具名正则 (Named Regexes)

grammars 的主要组成部分是 [regexes](http://doc.perl6.org/language/regexes)。 而 Perl 6 的 [regexes](http://doc.perl6.org/language/regexes)语法不在该文档的讨论范围, 具名正则(named regexes) 有它自己的特殊语法, 这跟子例程(subroutine) 的定义很像:

``` perl
my regex number { \d+ [ \. \d+ ]?   }   # 普通 regex 中空格被忽略, [] 是非捕获组
```

上面的代码使用 `my` 关键字指定了本地作用域的 regex, 因为具名正则(named regexes) 通常用在 grammars 里面。

正则有名字了就方便我们在任何地方重用那个正则了:

``` perl
say "32.51" ~~ &number;
say "15 + 4.5" ~~ / <number> \s* '+' \s* <number> /
&number           # my regex number { \d+ [ \. \d+ ]?   }  
```

为什么用 `&number`, 对比具名子例程你就知道了:

``` perl
> sub number { say "i am a subroutine" }  # 具名子例程
> &number                                 # sub number () { #`(Sub|140651249646256) ... }
```

`&number` 就是直接引用了具名的 regex 或 子例程。而在`/ /` 或 grammars 里面, 引用一个具名正则的语法也很特殊, 就是给名字包裹上 `< >`。`<>` 就像引号那样, 当用它引起某个具名正则后, 引用这个 `<named_regex>` 就会把该具名正则插入(带入)到整个正则之中, 就像字符串插值那样：

``` perl
use v6;

# 具名正则的声明
my regex number { \d+ [ \. \d+]? }  
my token ident  { \w+            }
my rule  alpha  { <[A..Za..z]>   }

# 1.0 通过 & 来引用
say so "12.34" ~~ &number; # true

# 2.0 在正则构造 // 里使用
say so "12.88 + 0.12" ~~ / <number> \s* '+' \s* <number> /; # true
# say so "12.88 + 0.12" ~~ / <left=.number> \s* '+' \s* <right=.number> /;
# wrong, method 'number' not found for invocant of class 'Cursor'

# 3.0 在 grammar 里面使用
grammar EquationParse {
    # 这里也不能给 number 起别名, 除非 number 是在 grammar 内部声明的
     token TOP { <number> \s* '+' \s* <number> \s* '=' \s* <number> }
}

# 等式解析
my $expr = EquationParse.parse("12.88 + 0.12 = 13.00");
say $expr;

```

声明具名正则不是只有一个 `regex` 声明符, 实际上 , regex 声明符用的最少, 大多数时候, 都是使用 `token` 或 `rule` 声明符。token 和 rule 这两个都是 `ratcheing` (棘轮)的, 这意味着如果匹配失败, 那么匹配引擎就不会回并尝试匹配了。这通常会是你想要的, 但不适用于所有情况:

> 棘轮用于单向驱动, 防止逆转。

``` perl
my regex works-but-slow { .+ q } # 可能会回溯
my token fails-but-fast { .+ q } # 不回溯
my $s = 'Tokens and rules won\'t backtrack, which makes them fail quicker!';
say so $s ~~ &works-but-slow; # True
say so $s ~~ &fails-but-fast; # False, .+ 得到了整个字符串但不回溯
```

 `token` 和 `rule` 的唯一区别就是 `rule` 声明符会让正则中的 `:sigspace` 修饰符起效:

``` perl
my token non-space-y { 'once' 'upon' 'a' 'time' }
my rule space-y { 'once' 'upon' 'a' 'time' }
say 'onceuponatime'    ~~ &non-space-y;
say 'once upon a time' ~~ &space-y;
```

## 创建 Grammar

当使用 grammar 关键字而非 class 关键字声明来声明一个类时, 会自动得到以 `Grammar` 的父类。Grammars 应该只用于解析文本; 如果你想提取复杂的数据, 推荐 [action object](http://doc.perl6.org/language/grammars#Action_Objects)和 grammar 一块使用。

## Action Object

一个成功的 grammar 匹配会给你一棵匹配对象(Match objects)的解析树, 匹配树(match tree)到达的越深, 则 grammar 中的分支越多, 那么在匹配树中航行以获取你真正感兴趣的东西就变的越来越困难。

为了避免你在匹配树(match tree)中迷失, 你可以提供一个 action object。grammar 中每次解析成功一个具名规则(named rule)之后, 它就会尝试调用一个和该 grammar rule 同名的方法, 并传递给这个方法一个`Match` 对象作为位置参数。如果不存在这样的同名方法, 就跳过。

这儿有一个例子来说明 grammar 和 action：

``` perl
use v6;

grammar TestGrammar {
    token TOP { ^ \d+ $ }
}

class TestActions {
    method TOP($/) {
        $/.make(2 + $/);  # 等价于 $/.make: 2 + $/
    }
}
my $actions = TestActions.new; # 创建 Action 实例
my $match   = TestGrammar.parse('40', :$actions);
say $match;       # ｢40｣
say $match.made;  # 42
```

`TestActions` 的一个实例变量作为具名参数 `actions` 被传递给 `parse` 调用, 然后当 token `TOP` 匹配成功之后, 就会自动调用方法 `TOP`, 并传递匹配对象(match object) 作为方法的参数。

为了让参数是匹配对象更清楚, 上面的例子使用 `$/` 作为 action 方法的参数名, 尽管那仅仅是一个方便的约定, 跟内在无关。 `$match` 也可以。(尽管使用 `$/`可以提供把 `$<captute>`作为`$/<capture>`的缩写的优势。)

下面是一个更有说服力的例子:

``` perl
use v6;

grammar KeyValuePairs {
    token TOP {
        [<pair> \n+]*
    }
    token ws { \h* } # 重写了关于"空白"的定义
    rule pair {
        <key=.identifier> '=' <value=.identifier>
    }
    token identifier {
        \w+
    }
}

class KeyValuePairsActions {
    method identifier($/)  { $/.make: ~$/                          }
    method pair      ($/)  { $/.make: $<key>.made => $<value>.made }
    method TOP       ($/)  { $/.make: $<pair>».made                }
}

my $res = KeyValuePairs.parse(q:to/EOI/, :actions(KeyValuePairsActions)).made;
    second=b
    hits=42
    perl=6
    EOI
for @$res -> $p {
    say "Key: $p.key()\tValue: $p.value()";
}
```

这会输出:

``` perl
Key: second     Value: b
Key: hits       Value: 42
Key: perl       Value: 6
```

`pair` 这个 rule, 解析一对由等号分割的 pair, 并且给 `identifier` 这个 token 各自起了别名。对应的 action 方法构建了一个 `Pair` 对象, 并使用子匹配对象(sub match objects)的 `.made` 属性。这也暴露了一个事实: submatches 的 action 方法在那些调用正则/外部正则之前就被调用。所以 action 方法是按后序调用的。

名为 `TOP` 的 action 方法仅仅把由 `pair` 这个 rule 的多重匹配组成的所有对象收集到一块, 然后以一个列表的方式返回。

注意 `KeyValuePairsActions` 是作为一个类型对象(type object)传递给方法 `parse`的, 这是因为 action 方法中没有一个使用属性(属性只能通过实例来访问)。

其它情况下, action 方法可能会在属性中保存状态。 那么这当然需要你传递一个实例给 `parse` 方法。

注意, `token ws` 有点特殊: 当 `:sigspace` 开启的时候(就是我们使用 `rule`的时候), 我们覆写的 `ws` 会替换某些空白序列。这就是为什么 `rule pair` 中等号两边的空格解析没有问题并且闭合 `}` 之前的空白不会狼吞虎咽地吃下换行符, 因为换行符在 `TOP` token 已经占位置了, 并且 token 不会回溯。

``` perl
# ws 的内置定义
/ <.ws> /                # match "whitespace":
                         #   \s+ if it's between two \w characters,
                         #   \s* otherwise

> my token ws { \h* } # 重写 ws 这个内置的 token
> say so "\n" ~~ &ws # True
```

所以 `<.ws>` 内置的定义是：如果空白在两个 `\w` 单词字符之间, 则意思为 `\s+`, 否则为 `\s*`。 我们可以重写 `ws` 关于空白的定义, 重新定义我们需要的空白。比如把 `ws` 定义为 `{ \h* }` 就是所有水平空白符, 甚至可以将`ws` 定义为非空白字符。例如: `token ws { 'x' }`

为了说明 rule 中 `ws`的定义, 我们修改一下上面的代码:

``` perl
use v6;

grammar KeyValuePairs {
    token TOP {
        [<pair>]*
    }
    # 不重写 ws, 使用内置的 ws 语法, 则在等号两边的空白就是 `\s*`
    # 注意!!!  由于闭合 } 括号之前换行了, 所以pair 中实际隐含了换行符!
    # 这很隐秘, 所以建议重写 ws
    rule pair {
        <key=.identifier> '=' <value=.identifier>
    }

    # 上面的 rule 在没有重写 ws 的情况下, 等价于:
    # 注意最后的 \s* 不要用 \v*(能匹配换行), 更不要错误的使用 \h(不匹配换行, 只匹配水平空白)
    # token pair {
    #     <key=.identifier>  \s* '=' \s*  <value=.identifier> \s*
    # }

    token identifier {
        \w+
    }
}

class KeyValuePairsActions {
    method identifier($/)  { $/.make: ~$/                          }
    method pair      ($/)  { $/.make: $<key>.made => $<value>.made }
    method TOP       ($/)  { $/.make: $<pair>».made                }
}

my $res = KeyValuePairs.parse(q:to/EOI/, :actions(KeyValuePairsActions)).made;
    second =b
    hits= 42
    perl = 6
    smeil=7
    EOI
for @$res -> $p {
    say "Key: $p.key()\tValue: $p.value()";
}
```

我们发现在 rule 中空白还是很灵活的, 而 `\h*` 只匹配水平空白(不包括换行), `\v*`能匹配换行。 `\s*` 等价于 `\h*` + `\v*`, 所以行末尾的空白我们一般使用 `\s*` 进行匹配。好了, token 和 rule 里面的空白就是这么点儿事, 下面 Actions

Actions就是一组方法, 当匹配成功就会调用同名的 actions 方法, 然后
