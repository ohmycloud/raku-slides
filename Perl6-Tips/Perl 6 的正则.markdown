# Perl 6 的正则
    分类: Perl6
    日期: 2013-06-26 21:42

## 正则操作符

在 Perl 6 中智能匹配** ~~ **操作符用于正则匹配。

对于相反的匹配，使用** !~~ **操作符。


## 基本用法

```perl
use v6;

my $str = 'abc123';
if $str ~~ m/a/ {
      say "Matching";
}

if $str !~~ m/z/ {
      say "No z in $str";
}
```
两个条件都是真的，所以两组字符串 "Matching" 和"No z in abc123"都会被打印。



## 特殊符号

Perl6中有一个重要改变，那就是 在Perl6 中，任何非字母数字字符需要被转义 。

在下个例子中，我们需要转义 - 符号:

```perl
use v6;

my $str = 'abc - 123';

if $str ~~ m/-/ {
      say "Matching";
}
```

生成:


===SORRY!===
Unrecognized regex metacharacter - (must be quoted to match literally) at line 6, near "/) {\n      s"

```perl
use v6;

my $str = 'abc - 123';

if $str ~~ m/ \- / {
      say "Matching";
}
```

有效，打印匹配。


## 新特殊字符

# 现在是一个特殊字符，代表注释,所以当我们真正需要一个#号时，需要转义：
```perl
use v6;

my $str = 'abc # 123';

if $str ~~ m/(#.)/ {
      say "match '$/'";
}
```

报错：


===SORRY!===
Unrecognized regex metacharacter ( (must be quoted to match literally) at line 6, near "#.)/ {\n    "


转义后正确：

```perl
use v6;

my $str = 'abc # 123';

if $str ~~ m/( \# .)/ {
      say "match '$/'";
}
```
 
Perl 6 的匹配变量

每次一有正则操作，一个叫做 $/ 的 本地化变量 被设置成 实际匹配到的值 。
```perl
use v6;

my $str = 'abc123';

if $str ~~ m/a/ {
      say "Matching    '$/' ";            # Matching  'a'
}

if $str !~~ m/z/ {
      say "No z in $str    '$/' ";    # No z in abc123  ''
}
```
 
Perl 6 正则中的空格

在Perl 6 中，正则默认 忽略空格 。
```perl
use v6;

my $str = 'The black cat climbed to the green tree.';

if $str ~~ m/black/ {
      say "Matching '$/'";        # Matching 'black'
}

if $str ~~ m/black cat/ {
      say "Matching '$/'";
} else {
      say "No match as whitespaces are disregarded";  # prints this
}
```

那怎样匹配空格呢？

```perl
use v6;

my $str = 'The black cat climbed to the green tree.';

if $str ~~ m/black \s cat/ {
      say "Matching '$/' - Perl 5 style white-space meta character works";
}

if $str ~~ m/black \s cat/ {
      say "Matching '$/' - Meta white-space matched, real space is disregarded";
}

if $str ~~ m/black  ' '   cat/ {
      print "Matching '$/' - ";
      say "the real Perl 6 style would be to use strings embedded in regexes";
}

if $str ~~ m/black cat/ {
      print "Matching '$/' - ";
      say "or maybe the Perl 6 style is using named character classes ";
}
```

任何情况下，我们可以这样写：
```perl
use v6;

my $str = 'The black cat climbed to the green tree.';

if $str ~~ m/  b l a c k c a t/ {
      say "Matching '$/' - a regex in Perl 6 is just a sequence of tokens";
}
```
 

你看，你可以 使用单引号在正则中嵌入字面字符串 ，也有新类型的字符类，使用尖括号。


匹配任何字符

点(.)匹配任何字符， 包括换行符 。

如果你想匹配除新行外的所有其他字符，你可以使用 \N 特殊字符类。

```perl
use v6;

my $str = 'The black cat climbed to the green tree.';

if $str ~~ m/c./ {
      say "Matching '$/'";          # 'ck'
}

my $text = "
The black cat
climbed the green tree";

if $text ~~ m/t./ {
      say "Matching '$/'";
}
```

第一个正则匹配并打印'ck',第二个打印：
't
'

使用 \N:

```perl
use v6;

my $text = "
The black cat
climbed the green tree";

if $text ~~ m/t\N/ {
      say "Matching '$/'";        # 'th'      of the word 'the'
}
```

在最后一个例子中你看到 \N 能匹配字母 h，而非新行。