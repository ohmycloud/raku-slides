title:  token 和 rule 的区别

date: 2015-12-28

tags: Perl6

categories: Perl 6

------

<blockquote class='blockquote-center'> 从开始到现在, 爱一直还在。</blockquote>



在 grammar 中, 有两个 regex 的变体, `rule` 和 `token`。rule 默认不会回溯.  rule 与 token 的一个重要区别就是, `rule` 这样的正则采取了 `:sigspace` 修饰符。 `rule` 实际上是

``` 
    regex :ratchet :sigspace { ... }
```

的简写.  ratchet 这个单词的意思是: (防倒转的)棘齿, 意思它是不能回溯的!  而 `:sigspace` 表明正则中的空白是`有意义的`, 而 `token` 实际上是

``` 
    regex :ratchet { ... }
```

的简写。 所以在 token 中, 若不是显式的写上 `\s`、`\h`、`\n` 等空白符号, 其它情况下就好像空白隐身了一样, 虽然你写了, 但是编译器却视而不见。

``` perl
use v6;
use Grammar::Debugger;
grammar Token::Rule::Difference {
    # 下面三者等价
    # rule TOP { [\w+]+ % ' ' | [\d+]+ % ' '   }  等价于
    # rule TOP { | [\w+]+ % ' ' | [\d+]+ % ' ' }  等价于
    rule TOP { | [\w+]+ % ' '
               | [\d+]+ % ' '
             }
}

# $=finish.lines 中的每一行末尾都没有换行符
for $=finish.lines -> $line {
    print($line);
    say Token::Rule::Difference.parse($line)
}

=finish
token takes whitespace invisible unless with sigspace
rule is a token without sigspace
2015 12 25
2016 01 07
```

说明在 rule 中, `|` 左右两边的空格会被忽略, 这通常是为了使格式对齐, 看起来不乱。另外 rule 中, 开头和末尾的空白也会被忽略。

如果每一行都带有换行符呢？

``` perl
use v6;
use Grammar::Debugger;
grammar Token::Rule::Difference {

    # token TOP { ^ [<line>\n]+ $ }
    # token line {
    #     | [\w+]+ % ' '
    #     | [\d+]+ % ' '
    # }

# 等价于

    rule TOP { ^ <wrap>+ $}
    token wrap { <line> }
    rule line {
         [\w+]+ % ' ' | [\d+]+ % <[-\s:]>
    }
}

my $str = q:to/EOF/;
token takes whitespace invisible unless with sigspace
rule is a token without sigspace
2015-12-25 12:23
2016-01-07 13:45
EOF

my $parse = Token::Rule::Difference.parse($str);
say $parse;
```

## token vs. rule

> When we use rule in place of token, any whitespace after anatom is turned into a non-capturing call to ws									

这句话是说, 在 `rule` 中, 任何跟在原子(atom)后面的空白会变成非捕获的`ws`调用, 即 `<.ws>`, 

``` perl
rule entry { <key> '=' <value> }
```

等价于:

``` perl
token entry { <key> <.ws> '=' <.ws> <value> <.ws> } # .抑制了捕获
```

在 grammar 中, 我们继承了默认的 `ws`, 但是我们也可以提供自己的 ws:

``` perl
token ws { \h* } # 匹配水平空白, 不包括换行
```

rule 中空白的使用:

``` perl
my $str = "Swift          is hard    to  learn";
my token word { \w+ }
my rule  line { <word>+ % [',' ] }
$str ~~ m:g/ <line> /;
```

逗号附近的方括号保证了 `<.ws>` 调用产生的空白作为分割符的一部分。这利用了 `<.ws>` 的一个特点：

在两个 `\w` 之间解释为 `\s+`, 其它地方解释为 `\s*`。