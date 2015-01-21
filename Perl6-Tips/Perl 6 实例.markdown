# 生成8位数的随机密码： 
```perl
my @char_set = (0..9, 'a'..'z', 'A'..'Z','~','!','@','#','$','%','^','&','*');
say @char_set. pick (8). join ("") # 不重复的8位密码
say @char_set. roll (8).join("")  # 可以重复
```

# 打印前5个数字
```perl
.say for 1..10 [^5]
.say for 1,2,3,4 ... [^10]  # 这个会无限循环
```

# 排序
> my %hash='Perl'=>100,'Python'=>100,'Go'=>100,'CMD'=>20,"Php"=>80,"Java"=>85;
("Perl" => 100, "Python" => 100, "Go" => 100, "CMD" => 20, "Php" => 80, "Java" => 85).hash
> %hash.values
100 100 100 20 80 85
> %hash.values.sort
20 80 85 100 100 100
> %hash.values.sort(-*)
100 100 100 85 80 20


# 求 1! + 2! + 3! + 4! +5! + 6! +7! +8! +9! +10!
```perl
     > multi sub postfix:<!>(Int $x){ [*] 1..$x }
     > say [+] 1!,2!,3!,4!,5!,6!,7!,8!,9!,10!
4037913
```     
# 列出对象所有可用的方法 , Perl 6 就可以
对象名.^methods
```perl
> "SB".^methods
BUILD Int Num chomp chop substr pred succ match ords lines samecase samespace tr
im-leading trim-trailing trim words encode wordcase trans indent codes path WHIC
H Bool Str Stringy DUMP ACCEPTS Numeric gist perl comb subst split
```

# 匿名子例程
```perl
my $x = sub($a){ $a+2 };say $x($_) for 1..4
my $x = -> $a { $a+2 };say $x($_) for 1..4
my $x = * + 2;say $x($_) for 1..4
```
以后是不是不会写这种=*+2的都不好意思说自己会写Perl6

# 字符串翻转
```perl
> 1223.flip 
3221
> 'abcd'.flip
dcba
> 1234.comb
1 2 3 4
> 1234.comb(/./)
1 2 3 4
> 'abcd'.comb
a b c d
```
# 有这么一个四位数A，其个位数相加得到B，将B 乘以 B的反转数后得到 A，请求出这个数字。
举例， 1458 就符合这个条件，1+4+5+8 ＝ 18， 18 ＊ 81 ＝1458

请找出另一个符合上面条件的四位数。

```perl
> (^37).map: { my $r = $_ * .flip; 1000 < $r and $_ == [+] $r.comb and say $r }
```
解释下：
(^37) 产生一个范围  0 .. ^37 , 就是 0到36之前的数，在表达式中代表 B 

来个正常思维的：
```perl
> my $b;
> for 1000..^10000 -> $i {$b=[+] $i.comb;say $i if $b*$b.flip == $i;}
1458
1729
```