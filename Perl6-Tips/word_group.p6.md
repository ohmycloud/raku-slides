```perl6
#`(
给定一个输入的字符串和一个包含各种单词的字典，用空格将字符串分割成一系列字典中存在的单词。

example: 字典

WORDS = %w[
100 200 ARG Linux Note To UNIX a an and apple as
available between command commend contains delimited
dict dictionary each elect file generate input is
like line list newline numbers of on operating options
permutations random select sentence sentences sep
separate share shuf shuffle standard system the
treat usr with words
]

字符串:
sentenceselect
Toshufflethenumbersbetween100and200

那么我们应该得到:
["sentence", "select", "sentences", "elect"]
["To", "shuffle", "the", "numbers", "between", "100", "and", "200"]
)

use v6;
my $str = "Toshufflethenumbersbetween100and200";
$str ~~ m:ex/(\w+)/;

my @words = qw/100 200 ARG Linux Note To UNIX a an and apple as
available between command commend contains delimited
dict dictionary each elect file generate input is
like line list newline numbers of on operating options
permutations random select sentence sentences sep
separate share shuf shuffle standard system the
treat usr with words
/;

my @a = @($/);
my @b;
for @a -> $item {
  push @b, ~$item;
}

for @b.unique -> $item {
  say $item if $item ∈ @words;
}
```

