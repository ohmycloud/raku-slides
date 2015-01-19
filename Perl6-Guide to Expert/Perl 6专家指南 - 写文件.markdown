# Perl 6专家指南 -> 写文件
> 分类: Perl6


## 写文件
 
为了写入内容到文件我们首先要开启 :w 模式.如果成功，我们得到一个文件句柄，在该文件句柄上我们可以使用普通的诸如print()、say()、或printf()等输出方法。
examples/files/write_file.p6
```perl
#!/usr/bin/env perl6
use v6;

my $filename = "temp.txt";
my $fh = open $filename, :w;
$fh.say("hello world");
$fh.close;
```