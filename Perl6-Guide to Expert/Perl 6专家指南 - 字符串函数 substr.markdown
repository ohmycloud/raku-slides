Perl 6专家指南 - 字符串函数 - substr
分类: Perl6


字符串函数: substr
examples/scalars/string_functions_substr.p6
#!/usr/bin/env perl6
use v6;


my $s = "The black cat climbed the green tree";
my $z;
$z = substr $s, 4, 5;                     # $z = black
say $z;
$z = substr $s, 4, *-11;                 # $z = black cat climbed the   从索引4开始截取，不要最后的11个字符
say $z;
$z = substr $s, 14;                       # $z = climbed the green tree，从索引14开始知道结束
say $z;
$z = substr $s, *-4;                     # $z = tree
say $z;
$z = substr $s, *-4, 2;                   # $z = tr
say $z;

