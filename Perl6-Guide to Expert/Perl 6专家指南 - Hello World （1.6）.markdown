# Perl 6专家指南 -Hello World （1.6）
> 分类: Perl6

## Hello World

使用关键字 say打印出字符串，并在字符串结尾自动添加一个换行符。字符串被双引号包裹住。Perl 6 中语句以分号结束。
## examples/intro/hello_world.p6
```perl
#!/usr/bin/env perl6
use v6;
say "Hello Perl 6 World";
```
同样地， OOP 风格: examples/intro/hello_world_oop.p6

```perl
#!/usr/bin/env perl6
use v6;
"Hello again Perl 6 World".say;
```


你可以键入  perl6 hello_world.p6   或  perl6 hello_world_oop.p6 中的任意一个.

实际上你甚至不需要所有3行，下面这个例子同样有效，如果你这样写  perl6 hello_world_bare.p6 . examples/intro/hello_world_bare.p6
```perl
say "Hello Perl 6 World";
```
sh-bang 行- 只在Unix/Linux下使用

尽管不是必须的，我使用文件后缀p6来表明这是个Perl 6 脚本。有些人只是使用常规的pl后缀，而实际上在UNIX 系统中这没有什么不可。只是在有些编辑器是基于它们的文件后缀名来高亮语法时才显得必要。 use v6;

这一行告诉perl下面的代码需要Perl 6 或更高版本。如果你使用perl6来运行，这段代码也会正确运行。但在Perl5下运行会有迷惑。例如 perl hell_world_bare.p6   输出如下: examples/intro/hello_world_bare.err


> String found where operator expected at books/examples/intro/hello_world_bare.p6 line 1, near "say "Hello Perl 6 World""
        (Do you need to predeclare say?)
syntax error at books/examples/intro/hello_world_bare.p6 line 1, near "say "Hello Perl 6 World""
Execution of books/examples/intro/hello_world_bare.p6 aborted due to compilation errors.


如果代码中使用了use v6,但是使用perl 5 来运行的话，会发生什么？   
perl hello_world.p6   输出如下: examples/intro/hello_world.err


> Perl v6.0.0 required--this is only v5.14.2, stopped at books/examples/intro/hello_world.p6 line 2.
BEGIN failed--compilation aborted at books/examples/intro/hello_world.p6 line 2.


现在问题更清晰了 
Though it would be nice if the error message printed by perl 5 was something like:  This code requires Perl v6.0.0. You ran it using v5.14.2.