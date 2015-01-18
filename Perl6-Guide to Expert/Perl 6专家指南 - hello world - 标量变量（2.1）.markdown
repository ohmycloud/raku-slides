Perl 6专家指南 - hello world - 标量变量（2.1）
分类: Perl6


Hello World - 标量变量
字符串可以存储在所谓的标量变量中。每个标量变量以符号 $ 开头，后面跟着字母数字、单词、下划线和破折号。在第一次使用这种标量之前，我们必须使用 my 关键字 声明它。


  my $this_is_a_variable;
  my $ThisIsAnotherVariableBut WeDontLikeItSoMuch;
  my $this-is-a-variable;
变量是大小写敏感的。


  my $h;
  my $H;
 
examples/scalars/hello_world_variable.p6
#!/usr/bin/env perl6
use v6;


my $greeting = "Hello World";
say $greeting;


my $Gábor-was-born-in = 'Hungary';
say $Gábor-was-born-in;
默认地，标量变量没有特定的类型，但是随后我们会看到，怎样限制一个标量让其能容纳一个数字或任何其它类型。


声明一个变量时也可不用初始化它的值:


  my $x;
在这种情况下，该变量的值为Any(),也就是还没被定义。