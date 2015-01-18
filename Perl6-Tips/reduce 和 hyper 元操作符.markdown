reduce 和 hyper 元操作符
分类: Perl6
日期: 2013-05-16 12:23
原文地址: http://blog.sina.com.cn/s/blog_6c9ce1650101c9cw.html


原文：扶凯 http://www.php-oa.com/2011/09/27/perl6-metaoperator-hyper-reduce.html

Hyper  亢奋的；精力旺盛的 Hyper[ˈhaɪpə(r)]

 

今天是第四天,在这个小盒子中,你会见到一些有意思的实现阶乘的函数

 1     
 2
 3
 sub fac( Int $n ) {
         [*] 1.. $n
 }


 

Okay, 它是怎么工作的？ 今天的 Advent 的盒子就是为了给你提供答案.

Perl 6 有一些不同的"元操作符"是用来修改现有的运算符完成更加强大的功能.
这个方括号中是一个有关“reduce metaoperator”的元操作符的例子,它是 中缀运算符 ,会变成列表操作,操作是在后面各个元素的中间来, 例如,表达式
 
  
  [+] 1, $a , 5, $b


  它相当于
 
  
   1 + $a + 5 + $b


这为我们提供了非常便利的机制“计算整个列表中的所有元素之和”：

  
 $sum = [+] @a ; # @a 中所有元素之和


      更多的中缀运算符(包含用户自己定义的),都能放到这个方括号来减少操作符;

 

  
  
  
  
  
  
  
 $prod = [*] @a ; # 相乘 @a 中所有的元素
    
 $mean = ([+] @a ) / @a ; # 计算 @a 的平均值
    
 $sorted = [<=] @a ; # 如果 @a 元素是数字排序就为 true
    
 $min = [min] @a , @b ; # find the smallest element of @a and @b combined


在那个阶乘的子函数中,表达示 [*] 1..$n 返回全部 1 到 $n 之间所有乘数的乘积.

另一个非常有用的元操作符是 "hyper" 操作符,放置 >>（与|或）<< 在操作符的二边(一边),使得那个操作 "hyper"（更亢奋）. 这个是用来操作列表中所有的成员 ,来进行这个包起来的运算符的操作.象下面的例子,我们来打算从 @a 和 @b 中 成对的取出数据 来进行运算后存入 @c.
 

  
 @c = @a >>+<< @b ;


如果是在 Perl 5 中,我们需要写成象才面这样才能完成.

     
  
  
 for ( $i = 0; $i < @a ; $i ++) {
         $c [ $i ] = $a [ $i ] + $b [ $i ];
 }


这只是有点长.

正如上面的方括号中, 我们可以使用Hyper在各种运算符上,包括用户定义操作符 ：

  注： 可以这样记忆 << 和 >> 操作符，它们就像是漏斗，<<  元素从右边漏入，>> 元素从左边漏入，然后进行运算。

     
  
  
  
  
 # 对 @xyz 中所有的元素进行 ++ 的操作
 @xyz >>++
    
 # 从@a 和 @b 中找出最小的元素放到 @x 中
 @x = @a   >>min<< @b ;


我们还可以翻转<<的角度,使标量的行为像一个数组：

  
  
  
  
  
  
  
  
  
  
  
  
 # @a 中每个成员都乘 3.5   (假设 @a=2,4,6)
 @b = @a   >>*>> 3.5;   （其实相当于 @b = @a   >>*<< (3.5,3.5,3.5）)较短的向量会被自动循环使用！模仿 R 语言的短向量自动循环。
 # 如果右边的向量没有左边的长，箭头就指向那个单个向量    
   # @x 中每个成员都乘以 $m 然后在加 $b
   @y = @x   >>*>> $m >>+>> $b ;
    
   # 颠倒 @x 中所有的成员
   @inv = 1  <</<< @x ;
    
 # concatenate @last, @first to produce @full
 @full = ( @last   >>~>> ', ' )  >>~<< @first ;
  
 > my @string=<I LOVE YOU>
 I LOVE YOU
 > @string >>~>>'-' >>~>> "szx"
 I-szx LOVE-szx YOU-szx
  
 >>~<< 两侧的元素个数必须相同！


当然,reductions 和 hyper 操作符也能联合表达式

  
   # 计算 @x 的平方和
   $sumsq = [+] ( @x   >>**>> 2);


还有很多其他元操作符,包括X（cross交叉）,R（reverse反向）,S（顺序sequential）.事实上,这只是在恰当的位置放个运算符,如+=,*=,?=,只是元形式的后缀等号运算,它相当于：

        
  
  
 $a += 5; # same as $a = $a + 5;
 $b = 7; # same as $b = $b 7;
 $c min= $d ; # same as $c = $c min $d;


本文为译文原作者 By pmichaud: http://perl6advent.wordpress.com/2009/12/05/day-5-metaoperator/