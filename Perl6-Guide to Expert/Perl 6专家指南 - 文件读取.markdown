# Perl 6专家指南 - 文件读取
> 分类: Perl6

## 从文件中读取行
打开文件时的模式：
```perl
  :r   - read
  :w   - write
  :a   - append
```
open函数的两个参数：文件名和模式.为了打开一个文件读取，模式需为 :r . 此函数要么返回一个存在标量变量中的文件句柄，要么失败时返回 undef 。
$fh = open $filename, :r
一旦我们打开了一个文件句柄，我们可以使用 get 方法 ($fh.get) 从给定的文件中读取一行。
你也可以连续调用 get 方法 读取多行，但还有更好的方法。
examples/files/read_one_line.p6
```perl
#!/usr/bin/env perl6
use v6;

my $filename = $*PROGRAM_NAME;
my $fh = open $filename;
my $line = $fh.get;
say $line;
```
## 读取所有行
```perl
#!/usr/bin/env perl6
use v6;

my $filename = $*PROGRAM_NAME;
my $fh = open $filename;
while (defined my $line = $fh.get) {
    say $line;
}
```
## 逐行读取文件
```perl
#!/usr/bin/env perl6
use v6;

my $filename = $*PROGRAM_NAME;
my $fh = open $filename;
for $fh.lines -> $line {
    say $line;
}
```
lines 方法返回文件的所有行或部分行