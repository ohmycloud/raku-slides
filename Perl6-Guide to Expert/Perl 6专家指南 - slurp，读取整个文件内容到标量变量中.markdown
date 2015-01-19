# Perl 6专家指南 -> slurp，读取整个文件内容到标量变量中
> 分类: Perl6


## slurp
Perl 6 有一个内建模式来一次性吸入文件内容, 那就是把整个文件内容读到一个标量变量中.
## examples/files/slurp_file.p6
```perl
#!/usr/bin/env perl6
use v6;
my $filename = $*PROGRAM_NAME;
my $data = slurp $filename;
say $data.bytes;
```