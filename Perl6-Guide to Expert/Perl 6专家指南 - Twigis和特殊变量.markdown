# Perl 6专家指南 -Twigils 和特殊变量
> 分类: Perl6
日期: 2013-05-17 13:54
原文地址: http://blog.sina.com.cn/s/blog_6c9ce1650101ca7e.html

## Twigils 和特殊变量
Perl 6 有很多特殊变量.为了更容易地跟普通变量区分开，它们用一种叫做twigil的第二个前缀来标记。

通常,用户自定义的变量有一个魔符($ @ 或%)在变量名前。

系统变量有额外的字符在魔符和变量名之间

## Examples:

```perl
$*PROGRAM_NAME 包含当前运行的Perl 6 脚本的路径.
$*CWD 是当前工作目录的路径。
$*IN 是标准输入(STDIN).你可以使用 $*IN.get 读入一行。
```
你可以阅读S28了解更多。