Perl 6专家指南 -_gt_ Perl 6 的散列
分类: Perl6
日期: 2013-05-23 23:59
原文地址: http://blog.sina.com.cn/s/blog_6c9ce1650101cf9z.html


散列 (关联数组)

A hash (also called associative array) is a set of key,value pairs where the keys are unique strings and the values can have any, err value.

Hashes always start with a % (percentage) sign.
examples/hash/create_hash.p6
#!/usr/bin/env perl6
use v6;

my %user_a = "fname", "Foo", "lname", "Bar";

my %user_b =
      "fname" => "Foo",
      "lname" => "Bar",
;

say %user_a{"fname"};
%user_a{"email"} = " foo@bar.com ";
say %user_a{"email"};

say %user_b;

 

输出:
examples/hash/create_hash.p6.out
Foo
foo@bar.com
Bar

从散列中取回数据
examples/hash/print_hash.p6
#!/usr/bin/env perl6
use v6;

my %user =
      "fname" => "Foo",
      "lname" => "Bar",
      "email" => " foo@bar.com ",
;

for %user.keys.sort -> $key {
      say "$key  %user{$key}";
}

 

输出
examples/hash/print_hash.p6.out
email  foo@bar.com
fname  Foo
lname  Bar

多维散列
examples/hash/multi.p6
#!/usr/bin/env perl6
use v6;

my %xml;

%xml[0] = 'Foo';
%xml[1] = 'Bar';

say %xml.perl;

 

输出:
examples/hash/multi.p6.out
("person" => ["Foo", "Bar"]).hash

计算字数
examples/hash/count_words.p6
#!/usr/bin/env perl6
use v6;

my $filename = 'examples/words.txt';

my %counter;

my $fh = open $filename;
for $fh.lines -> $line {
      my @words = split /\s+/, $line;
      for @words -> $word {
              %counter{$word}++;
      }
}

for %counter.keys.sort -> $word {
      say "$word {%counter{$word}}";
}

回顾
examples/hash/hash.p6
#!/usr/bin/env perl6
use v6;

# 创建散列
my %h1 = first => '1st', second => '2nd';

if %h1{'first'}.defined {
      say "the value of 'first' is defined";
}
if %h1.defined {
      say "the value of 'second' is defined";
}

if %h1.exists('first') {
      say "the key 'first' exists in h2";
}

say %h1.exists('third') ?? "third exists" !! "third does not exist";

say %h1;
say %h1;

# TODO hash with fixed keys not implemented yet
#my %h2{'a', 'b'} = ('A', 'B');
#say %h2.delete('a');
#say %h2.delete('a');


输出:
examples/hash/hash.p6.out
the value of 'first' is defined
the value of 'second' is defined
the key 'first' exists in h2
third does not exist
1st
2nd

slurp
examples/files/slurp_csv_file.p6
#!/usr/bin/env perl6
use v6;

my $filename = 'examples/phonebook.txt';

my @lines = lines $filename.IO;
for @lines -> $line {
      say "L: $line";
}

#my %phonebook = map {split ",", $_}, @lines;
#my %phonebook = map {$_.comb(/\w+/)}, @lines;

my %phonebook = slurp($filename).comb(/\w+/);

my $name = prompt "Name:";
say %phonebook{$name};


examples/phonebook.txt
Foo,123
Bar,78
Baz,12321

kv
examples/hash/print_hash_kv.p6
#!/usr/bin/env perl6
use v6;

my %user =
      "fname" => "Foo",
      "lname" => "Bar",
      "email" => " foo@bar.com ",
;

for %user.kv -> $key, $value {
      say "$key  $value";
}

 

输出:
examples/hash/print_hash_kv.p6.out
fname  Foo
lname  Bar
email  foo@bar.com

遍历散列键

使用 "keys" 函数也可以遍历散列键.

The declaration of hashes in Perl 6 is similar to that in Perl 5 but when access individual elements in the hash it now keeps the % prefix. Thus the value of the key "Foo" will be %phone{"Foo"}. Similarly if $name contains "Foo" we can use the %phone{$name} expression to get back the relevant value.

As mentioned earlier the string interpolation of hashes requires curly braces around the statement.
examples/hash/loop_over_hash.p6
#!/usr/bin/env perl6
use v6;

my %phone =
      "Foo" => 123,
      "Bar" => 456,
;

for keys %phone -> $name {
      say "$name %phone{$name}";
}


输出:
examples/hash/loop_over_hash.p6.out
Bar 456
Foo 123

 