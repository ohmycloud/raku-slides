Perl6的一些特性
分类: Perl6
日期: 2013-05-16 15:21
原文地址: http://blog.sina.com.cn/s/blog_6c9ce1650101c9ii.html
> my $foo = "bar";
bar
> if $foo eq "foo" | "bar" | "baz" { say "ok" }
ok
> my $num = 10;
10
> if 5 < $num < 15 { say "ok" }
ok
> say 1, 2, 4 ... 1024
1 2 4 8 16 32 64 128 256 512 1024
> my @fib = 1, 1, *+* ... *;
1 1 2 3 ...
> say @fib[0..9]
1 1 2 3 5 8 13 21 34 55
> say @fib[^10]
1 1 2 3 5 8 13 21 34 55
> say [+] 1..100
5050
> say 1..6 Z~ 'A'..'F'
1A 2B 3C 4D 5E 6F
> say 1..3 X~ 'A'..'D'
1A 1B 1C 1D 2A 2B 2C 2D 3A 3B 3C 3D