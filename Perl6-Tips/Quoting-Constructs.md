title: Quoting Constructs
date: 2015-07-16 13:42:14
tags: Perl6
categories: Perl 6
---

<blockquote class="blockquote-center">我宁愿 留在你方圆几里 我的心 要不回就送你 因为我爱你 和你没关系
— 方圆几里·薛之谦
</blockquote>

## The Q Lang

在 Perl 6 中, 字符串通常使用一些引号结构来表示. 这些引号结构中,最简单的就是 `Q`, 通过便捷方式 `｢…｣` 或 `Q` 后跟着由任意一对儿分隔符包围着的文本. 大多数时候, 你需要的只是 `'…'` 或 `"…"`.

### Literal strings: Q

```perl
Q[A literal string]
｢More plainly.｣
Q ^Almost any non-word character can be a delimiter!^
```

分隔符能够嵌套, 但是在普通的 Q 形式中, 反斜线转义是不允许的. 换种说法就是, Q 字符串尽可能被作为字面量.

```perl
Q<Make sure you <match> opening and closing delimiters>
Q{This is still a closing brace → \}
```

这些例子产生:

```perl
A literal string
More plainly.
Almost any non-word character can be a delimiter!
Make sure you <match> opening and closing delimiters
This is still a closing brace → \
```


### Escaping: q

```perl
'Very plain'
q[This back\slash stays]
q[This back\\slash stays] # Identical output
q{This is not a closing brace → \}, but this is → }
Q :q $There are no backslashes here, only lots of \$\$\$!$
'(Just kidding. There\'s no money in that string)'
'No $interpolation {here}!'
Q:q#Just a literal "\n" here#
```

`q` 形式的引号结构允许使用反斜线转义可能会结束字符串的字符. 反斜线自身也能被转义, 就像上面的第三个例子那样. 通常的形式是 `'...'` 或 `q` 后跟着分隔符, 但是它也能作为 Q 上的副词使用, 就像上面的第五个和最后一个例子那样.

这些例子产生:

```perl
Very plain
This back\slash stays
This back\slash stays
This is not a closing brace → } but this is →
There are no backslashes here, only lots of $$$!
(Just kidding. There's no money in that string)
No $interpolation {here}!
Just a literal "\n" here
```

### Interpolation: qq

```perl
my $color = 'blue';
say "My favorite color is $color!" # My favorite color is blue!
```

`qq` 形式 -- 通常使用双引号写成 -- 允许变量的插值, 例如字符串中能写入变量, 以使变量的内容能插入到字符串中. 在 `qq` 引起字符串中, 也能转义变量.

```perl
say "The \$color variable contains the value '$color'";
# The $color variable contatins the value 'blue'
```

`qq` 的另外一种功能是使用花括号在字符串中插值 Perl 6 代码:

```perl
my ($x, $y, $z) = 4, 3.5, 3;
say "This room is $x m by $y m by $z m."
say "Therefore its volume should be { $x * $y * $z } m³!"
```

输出:

```perl
This room is 4 m by 3.5 m by 3 m.
Therefore its volume should be 42 m³!
```

默认情况下, 只有带有 '$' 符号的变量才能正常插值. 这时, `"documentation@perl6.org"` 不会插值  `@perl6` 变量. 如果呢确实想那么做, 在变量名后面添加一个 `[]`:

```perl
my @neighbors = "Felix", "Danielle", "Lucinda";
say "@neighbors[] and I try our best to coexist peacefully."
```

输出:

```perl
Felix Danielle Lucinda and I try our best to coexist peacefully.
```

通常使用一个方法调用会更合适. 只有在 qq 引号中, 方法调用后面有圆括号, 就能进行插值:

```perl
say "@neighbors.join(', ') and I try our best to coexist peacefully."
```

输出:

```perl
Felix, Danielle, Lucinda and I try our best to coexist peacefully.
```

而 `"@example.com"` 产生 `@example.com`.

### Word quoting: qw

```perl
<a b c> eqv ('a', 'b', 'c')
qw|! @ # $ % ^ & * \| < > | eqv '! @ # $ % ^ & | < >'.words
Q:w { [ ] \{ \} } eqv ('[', ']', '{', '}')
```

`:w` 通常写作 `<...>` 或 `qw`, 把字符串分割为"words" (单词). 在这种情景下, 单词被定义为由空格分割的一串非空白字符. `q:w` 和 `qw` 继承了 `q` 的插值和转义语法, 还有单引号字符串分割符, 而 `Qw` 和 `Q:w` 继承了 `Q` 的非转义语法.


```perl
my @directions = 'left', 'right,', 'up', 'down';
```

这样读和写都更容易:

```perl
my @directions = <left right up down>;
```

### Word quoting with interpolation: qqw

`qw` 形式的 word quoting 不会进行变量插值:

```perl
my $a = 42; say qw{$a b c};  # $a b c
```

因此, 如果你想在引号字符串中进行变量插值, 你需要使用 `qqw` 变体:

```perl
my $a = 42;
my @list = qqw{$a b c};
say @list;                # 42 b c
```

或者同样的:

```perl
my $a = 42;
my @list = «$a b c»;
say @list;                # 42 b c
```

### Shell quoting: qx

把一个字符串作为一个外部程序运行,  在 Perl 6 中反引号不再用于 shell quoting, 并且 qx 不再插值 Perl 变量, 因此:

```perl
my $world = "there";
say qx{echo "hello $world"}
```

仅仅打印 hello. 然而, 如果你在调用 perl6 之前声明了一个环境变量, 这在 qx 里是可用的, 例如:

```perl
WORLD="there" perl6
> say qx{echo "hello $WORLD"}
```

现在会打印 hello there.

调用 `qx` 会返回结果, 所以这个结果能被赋值给一个变量以便后来使用: 

```perl
my $output = qx{echo "hello!"};
say $output;    # hello!
```

### Shell quoting with interpolation: qqx

带插值的 Shell quoting:

```perl
my $world = "there";
say qqx{echo "hello $world"};  # hello there
```

再一次, 外部命令的输出结果可以保存在一个变量中:

```perl
my $word = "cool";
my $option = "-i";
my $file = "/usr/share/dict/words";
my $output = qqx{grep $option $word $file};
# runs the command: grep -i cool /usr/share/dict/words
say $output;      # Cooley␤Cooley's␤Coolidge␤Coolidge's␤cool␤ ...
```

### Heredocs: :to

`heredocs` 是多行字符串字面量的便捷方式, 你能选择自己的分隔符:

```perl
say q:to/END/;
Here is
some multi-line
string
END
```

 heredoc 的内容从下一行开始.

```perl
my $escaped = my-escaping-function(q:to/TERMINATOR/, language => 'html');
Here are the contents of the heredoc.
Potentially multiple lines.
TERMINATOR
```

如果终止分隔符缩进了, 同等数量的缩进会从字符串字面量上移除. 因此下面这个 heredoc

```perl
say q:to/END/;
    Here is
    some multi line
        string
    END
```

输出:

```perl
Here is
some multi line
    string
```


