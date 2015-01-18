Perl 6 -文件
分类: Perl6
日期: 2013-06-26 22:10
原文地址: http://blog.sina.com.cn/s/blog_6c9ce1650101d4au.html


使用 slurp 函数读入文件所有的行到一个单个标量中：   
  use v6;

  my $content = slurp "text.txt";
  say $content.chars;

 

使用 slurp 函数读取文件所有的行到数组的首元素中：

  use v6;

  my @ content = slurp "text.txt";
  say @content.elems;
  say @content[0].chars;


使用 lines 函数读取文件的所有行到一个数组中，每行占据单个的数组元素:

  use v6;

  my @content = lines "text.txt";
  say @content.elems;
  say @content[0].chars;


一行一行地遍历所有的行。lines 函数同等优雅:

  use v6;

  for lines "text.txt" -> $line {
      say $line.chars;
  }


使用 open函数打开一个文件。使用 get 方法读取一行。使用 lines 函数遍历文件剩下的所有行：

  use v6;
  my $fh = open "text.txt";

  my $first_line = $fh .get ;
  say $first_line;

  for $fh .lines -> $line {
      say $line.chars;
  }

  打开一个文件等待写入，使用 say 方法打印一个字符串进去，然后关闭该文件，然后输出所有缓冲.

  use v6;

  my $fh = open "out.txt", :w;
  $fh.say("text 4");
  $fh.close;

  say slurp "out.txt";

 

 