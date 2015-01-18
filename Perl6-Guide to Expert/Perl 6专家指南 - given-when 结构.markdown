Perl 6专家指南 - given-when 结构
分类: Perl6
日期: 2013-05-17 11:30
原文地址: http://blog.sina.com.cn/s/blog_6c9ce1650101ca3n.html


examples/scalars/calculator_given.p6
#!/usr/bin/env perl6
use v6;


my $a         = prompt "Number:";
my $operator = prompt "Operator: [+-*/]:";
my $b         = prompt "Number:";


given $operator {
    when "+" { say $a + $b; }
    when "-" { say $a - $b; }
    when "*" { say $a * $b; }
    when "/" { say $a / $b; }
    default   { say "Invalid operator $operator"; }
}