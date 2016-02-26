title:  Day 8 – Grammars generating grammars

date: 2016-02-02

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>冬天的太阳很温暖！</blockquote>

现在你可能已经习惯了 Perl 6 中到处出现的前缀"meta"。**Metaclasses**, **Metaobjects**, **Metaoperators**, 还有迷一般的 Meta-Object 协议。听起来一点也不可怕, 你都见过了不是吗？今天, 在 Perl 6 Advent Calendar 上, 我们将进行完全的 **meta** 化(full meta)。我们将拥有能解析 grammars 的 grammars, 然后生成将用于解析 grammars 的 grammars。



Grammars 无疑是 Perl 6 的杀手级功能。我们拥有了正则表达式曾经没有的东西: 可读性、可组合性当然还有解析 Perl 6 自身的能力。— 如果这不能展示它的强大, 那我不知道什么能够!



为预定义好的 grammars(例如以 [Bachus-Naur](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_Form) 形式)写解析器总是有点无趣, 几乎和复制粘贴一样。如果你曾经坐下来重头开始写一个解析器(或者期间温习一遍那本优秀的"让我们构建一个编译器"图书), 你可能会意识到模式是如此相似:从你的 grammar 中拿出单个 rule, 为它写一个子例程, 让它调用(可能是递归的)其它类似的为其它 grmmars rules 定义的子例程, 清洗, 重复。现在我们有了Perl 6 Grammars! 在这个新世界中, 我们不必为每个 token 写上子例程来完成工作了。 现在我们写 **grammar** 类, 里面放上 *tokens*、*rules*、*regexes* 标志。在标志里写正则表达式(或代码)并引用(可能是递归的) Perl 6 gramamr 中的其它标志。如果你曾经使用过这些东西, 你肯定会意识到 Perl 6 中的 gramamrs 是多么的方便。



但是假如我们已经有了一个 grammar, 例如之前提到过的 BNF? 我们所做的就是小心地把已经存在的 grammar(实际上在我们头脑中解析它)重新键入到一个新的 Perl 6  Grammar 中以代表同样的一个东西, 但是那确实有一个可作为可执行代码的优势。对大多数人来说, 那都不是事儿。我们不是普通人, 我们是程序员。我们拥有资源。它们会让这些 Grammars 变得有意义。



绝妙的是 Perl 6 gramamrs 和语言的其它元素没什么两样。Grammars 就像类那样也是头等公民, 可以内省, 扩展。实际上, 你可以查看编译器源代码自身, 你会注意到**[Grammars 就是一种特定种类的类](https://github.com/rakudo/rakudo/blob/nom/src/Perl6/Metamodel/GrammarHOW.nqp)**。它们遵守和类一样的规则, 允许我们就地创建 gramamrs, 就地给 gramamrs 添加 tokens, 最终完结这个 gramamr 以拥有一个合适的能实例化的类对象。现在既然我们能解析 BNF gramamrs(因为它们就是普通的文本)并从代码中创建 Perl 6 grammars, 让我们把这些片段放在一起并写点能手动把 BNF gramamr 转化为 Perl 6 grammar 的东西。



#### 解析 BNF grammar 的 grammar

``` perl6

grammar Grammar::BNF {
    token TOP { \s* <rule>+ \s* }

    token rule {
        <opt-ws> '<' <rule-name> '>' <opt-ws> '::=' <opt-ws> <expression> <line-end>
    }

    token expression {
        <list-of-terms> +% [\s* '|' <opt-ws>]
    }

    token term {
        <literal> | '<' <rule-name> '>'
    }

    token list-of-terms { <term> +% <opt-ws>                }
    token rule-name     { <-[>]>+                           }
    token opt-ws        { \h*                               }
    token line-end      { [ <opt-ws> \n ]+                  }
    token literal       { '"' <-["]>* '"' | "'" <-[']>* "'" }

    ...
}

```



最上层的 3 个 tokens 发生了有意思的事情。*rule* 是 BNF grammar 的核心构造块: 一个 `<symbol> ::=  <expression>` 块儿, 后面跟着一个换行符。整个 grammar 就是一列 rules。每个表达式是一列项、或可能的和它们的备选分支。每个项要么是一个字面值, 或一个由尖括号包围的标志名。足够了! 那涵盖了解析部分。让我们看一下生成自身。我们的确有一种"为 grammar 中的每个 token 做某事"的机制, 以 **Actions**的形式, 让我们继续并使用它:

``` perl6

my class Actions {
    has $.name = 'BNFGrammar';
    method TOP($/) {
        my $grmr := Metamodel::GrammarHOW.new_type(:$.name);
        $grmr.^add_method('TOP',
            EVAL 'token { <' ~ $<rule>[0].ast.key ~ '> }');
        for $<rule>.map(*.ast) -> $rule {
            $grmr.^add_method($rule.key, $rule.value);
        }
        $grmr.^compose;
        make $grmr;
    }

    method expression($/) {
        make EVAL 'token { ' ~ ~$/ ~ ' }';
    }

    method rule($/) {
        make ~$<rule-name> => $<expression>.ast;
    }
}

```



**TOP**方法毫无疑问是最魔幻和最恐怖的, 所以擒贼先擒王, 其它小喽啰就无关紧要了。基本上, *TOP*那儿发生了三件事:

1、我们创建了一个新的 grammar, 作为一个新的 Perl 6 类型

2、我们使用 `^add_method`方法为 grammar 添加 tokens

3、我们使用 `^compose`方法定型该 grammar



虽然 Perl 6 指定名为 **TOP** 的 token 是解析开始的地方, 在 BNF 中第一个 rule 总是开始点。为了彼此适应,  我们精巧地制作了一个假的 **TOP** token, 它正是调用了 BNF grammar 中指定的第一个 rule。不可避免地, 恐怖又令人失望的 **EVAL** 引起了我们的注意, 就像它说了"这儿发生了可怕的事情" 一样。它那样说并不是完全错误的, 但是因为我们没有其它程序化构建单独正则的方法, 我们不得不接受这点不适。



**TOP**之后我们继续为我们的 grammar 添加 BNF rules 的剩余部分, 这一次保留它们原来的名字, 然后 `^compose`整个东西, 最后让它(make)成为解析的结果: 一个做好的解析类。



在 *expression* 方法中我们把解析过的 BNF 元素粘贴到一块以产生合法的 Perl 6 代码。这变得特别容易, 因为那俩个单独的标志带有空格, 使用管道符号来轮试备选分支, 并使用尖括号包围标志名。目前为止, 一个 rule 看起来像这样:

``` perl6

<foo> ::= 'bar' | <baz>

```

我们求值(EVAL)的 Perl 6 代码变为:

``` perl6

token { 'bar' | <baz> }

```



因为我们已经在我们代码的 grammar 部分检测我们解析的 BNF 是正确的, 没有什么能够阻止我们传递解析整个表达式字面值到我们的代码中并使用一个 `token  { }`来包裹它, 所以让我们继续。



最后, 对于我们解析的每一个 BNF rule, 我们产生了一个很不错的 *Pair*, 所以我们的 **TOP** 方法很愉快地处理它们中的每个。



看起来我们好像在这儿结束了, 但是仅仅是为了方便使用者, 让我们写一个更好的方法, 接收一个 BNF grammar, 并为我们生成一个准备好使用的类型对象。我们记得, grammars 就是类, 所以我们没有什么能阻止我们直接为我们的 gramamr 添加它:

``` perl6

grammar Grammar::BNF {
    ...

    method generate($source, :$name = 'BNFGrammar') {
        my $actions = Actions.new(:$name);
        my $ret = self.new.parse($source, :$actions).ast;
        return $ret.WHAT;
    }
}

```



这儿看起来很不错! 在你开始往你自己的项目中复制粘贴所有这些之前, 记得  [Grammar::BNF](https://github.com/tadzik/Grammar-BNF/) 是一个可在  [Perl 6 Module Ecosystem](http://modules.perl6.org/)获得的 Perl 6 模块, 使用你喜欢的模块管理器安装。



假设你确实花费时间查看了开头的 post, 你可能会记得我许诺过我们将有 grammars(第一条)来解析 grammars(第二条), 然后生成 grammars(第三条), 使用生成的 grammars 来解析 grammars(第四条)。目前为止， 我们已经看到过 BNF::Grammar  grammar(那是第一条), 并解析一个 BNF grammar(那是第二条), 以类对象的形式来生成 Perl 6 grammar(第三条)。 就这些。我们仍旧缺乏最后一部分, 使用整个东西来解析 grammars。 我们只完成了 75% 的 meta化, 今天足够了。为什么现在停止? 为什么不拿一个 BNF grammar , 使用 Perl 6 grammar 来解析 grammar, 使用 Perl 6 BNF grammar 的结果来解析我们原来的 BNF Grammar? 那不是很好吗？ 是的, 那很好, 我们只是留了一个练习给你。
