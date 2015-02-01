# 在Perl 6中读取文件
    分类: Perl6
    日期: 2013-05-16 20:53
    原文： http://perl6maven.com/reading-from-a-file-in-perl6 

 

在Perl 6中对存在的数据结构进行操作是有趣的，但是如果没有输入与输出的话，就会限制在真实世界中的用途。

因此，读取文件内容是一个明智的操作.

 
    open
    get
    read
    IO
    lines                                    


## 一行行读取（Read line-by-line）

    open   函数会打开一个文件，默认情况下，你可以显示地传递一个 :r 作为open函数的 第二个参数 。 Open会返回一个文件句柄，即一个IO类的实例。

    get    方法会从文件读取并 返回一行 ， 末尾的新行会自动被移除 。 (Perl 5  开发者也可以认为 get 方法自动调用了chomp操作.)
  
```perl  
my $fh = open $filename;
my $line = $fh.get;
```

你也可以在一个while循环中读取文件的所有行。  与 Perl 5相反, 在这个while循环中，对是否定义没有隐式地检测.你必须在条件语句中显示地添加单词defined.否则，读取操作将在第一个空行处停止。
```perl
my $fh = open $filename; 
    while (defined my $line = $fh.get)
      { 
        say $line;
      }
```
在for循环中使用lines方法可能更具有Perl-6风格。
 
lines 方法会依次读取文件的每一行，然后将读取到行赋值给变量 $line ,然后执行代码块。
```perl
my $fh = open $filename;
for $fh.lines -> $line {
      say $line;
}
```