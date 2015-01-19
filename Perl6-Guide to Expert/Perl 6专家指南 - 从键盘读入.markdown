# Perl 6专家指南 -_gt_ 从键盘读入 (2.2)
> 分类: Perl6

## 从键盘读取

prompt读取用户输入内容知道用户按下 Enter键。但是它只传递第一个换行之前的内容

```perl
#!/usr/bin/env perl6
use v6;
my $name = prompt("Please type in yourname: ");
say "Hello $name";
```
还不能处理汉字，prompt是一个函数，其参数为提示信息