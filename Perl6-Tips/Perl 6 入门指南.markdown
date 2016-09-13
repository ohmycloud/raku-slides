# Perl 6 入门指南

## exit，warn，die
exit
```perl6
#!/usr/bin/env perl6
use v6;
say "hello";
exit;
say "world"; # 这句不会执行了
```

warn
```perl6
#!/usr/bin/env perl6
use v6;
warn "This is a warning"; # 打印警告，带行号
say "Hello World";
```

die

```perl6
#!/usr/bin/env perl6
use v6;

say "Before calling die";
die "This will kill the script";
say "This will not show up";
```

## Hello World
Hello World


使用关键字 say打印出字符串，并在字符串结尾自动添加一个换行符。字符串被双引号包裹住。Perl 6 中语句以分号结束。
examples/intro/hello_world.p6
```perl6
#!/usr/bin/env perl6
use v6;
say "Hello Perl 6 World";
```

同样地， OOP 风格:
examples/intro/hello_world_oop.p6
```perl6
#!/usr/bin/env perl6
use v6;
"Hello again Perl 6 World".say;
```
你可以键入  perl6 hello_world.p6   或  perl6 hello_world_oop.p6 中的任意一个.
实际上你甚至不需要所有3行，下面这个例子同样有效，如果你这样写  perl6 hello_world_bare.p6 .
examples/intro/hello_world_bare.p6
say "Hello Perl 6 World";
sh-bang 行- 只在Unix/Linux下使用


文件后缀

尽管不是必须的，我使用文件后缀p6来表明这是个Perl 6 脚本。有些人只是使用常规的pl后缀，而实际上在UNIX 系统中这没有什么不可。只是在有些编辑器是基于它们的文件后缀名来高亮语法时才显得必要。
`use v6;`

这一行告诉perl下面的代码需要Perl 6 或更高版本。如果你使用perl6来运行，这段代码也会正确运行。但在Perl5下运行会有迷惑。例如 perl hell_world_bare.p6   输出如下:

```perl6
examples/intro/hello_world_bare.err
String found where operator expected at books/examples/intro/hello_world_bare.p6 line 1, near "say "Hello Perl 6 World""
        (Do you need to predeclare say?)
syntax error at books/examples/intro/hello_world_bare.p6 line 1, near "say "Hello Perl 6 World""
Execution of books/examples/intro/hello_world_bare.p6 aborted due to compilation errors.
```

如果代码中使用了use v6,但是使用perl 5 来运行的话，会发生什么？    

perl hello_world.p6   输出如下:

```perl6
examples/intro/hello_world.err
Perl v6.0.0 required--this is only v5.14.2, stopped at books/examples/intro/hello_world.p6 line 2.
BEGIN failed--compilation aborted at books/examples/intro/hello_world.p6 line 2.
现在问题更清晰了 (Though it would be nice if the error message printed by perl 5 was something like:  This code requires Perl v6.0.0. You ran it using v5.14.2.
```

## given-when 结构 
```perl6
#!/usr/bin/env perl6
use v6;

my $a         = prompt "Number:";
my $operator  = prompt "Operator: [+-*/]:";
my $b         = prompt "Number:";

given $operator {
    when "+" { say $a + $b; }
    when "-" { say $a - $b; }
    when "*" { say $a * $b; }
    when "/" { say $a / $b; }
    default  { say "Invalid operator $operator"; }
}
```
## 标量变量

字符串可以存储在所谓的标量变量中。每个标量变量以符号 $ 开头，后面跟着字母数字、单词、下划线和破折号。在第一次使用这种标量之前，我们必须使用 my 关键字 声明它。
```perl6
  my $this_is_a_variable;
  my $ThisIsAnotherVariableBut WeDontLikeItSoMuch;
  my $this-is-a-variable;
```  
变量是大小写敏感的。
```perl6
  my $h;
  my $H;
``` 

```perl6
#!/usr/bin/env perl6
use v6;

my $greeting = "Hello World";
say $greeting;

my $Gábor-was-born-in = 'Hungary';
say $Gábor-was-born-in;
```
默认地，标量变量没有特定的类型，但是随后我们会看到，怎样限制一个标量让其能容纳一个数字或任何其它类型。

声明一个变量时也可不用初始化它的值:  `my $x;`
在这种情况下，该变量的值为`Any()`,也就是还没被定义。

## if 语句 

你可以使用if 语句和其中之一的比较操作符来比较两个值或标量变量。
```perl6
#!/usr/bin/env perl6
use v6;

my $age = 23;
if $age > 18 {
    say "You can vote in most countries.";
}
```
其他类型的 if 语句
```perl6
  if COND {
  }
 
  if COND {
  } else {
  }
 
 
  if COND {
  } elsif COND {
  } elsif COND {
  } else {
  }
```

## Perl 6 的散列 
散列（也叫做关联数组）是一列键值对，其中，键是唯一的字符串，键值可以是任意值。
散列以 % 符号开始。

```perl6
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
``` 
输出:
Foo
foo@bar.com 
Bar

从散列中取回数据
```perl6
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
``` 
输出

    email  foo@bar.com 
    fname  Foo
    lname  Bar

多维散列
```perl6
#!/usr/bin/env perl6
use v6;

my %xml;
%xml[0] = 'Foo';
%xml[1] = 'Bar';
say %xml.perl;
``` 
输出:
("person" => ["Foo", "Bar"]).hash

计算字数

```perl6
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
```
回顾

```perl6
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
```

输出:

the value of 'first' is defined
the value of 'second' is defined
the key 'first' exists in h2
third does not exist
1st
2nd
slurp

```perl6
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
```
输出：
Foo,123
Bar,78
Baz,12321
kv

```perl6
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
``` 
输出:
fname  Foo
lname  Bar
email  foo@bar.com


遍历散列键
使用 "keys" 函数也可以遍历散列键.
```perl6
#!/usr/bin/env perl6
use v6;
my %phone =
      "Foo" => 123,
      "Bar" => 456,
;
for keys %phone -> $name {
      say "$name %phone{$name}";
}
```
输出:
Bar 456
Foo 123

##  POD文档 
```perl6
#!/usr/bin/env perl6
use v6;
print "Hello";
=begin pod
=head1 Title
text
=end pod
say " World";
```
这会打印出Hello World

## slurp
读取整个文件内容到标量变量中 

Perl 6 有一个内建模式来一次性吸入文件内容, 那就是把整个文件内容读到一个标量变量中.
```perl6
#!/usr/bin/env perl6
use v6;

my $filename = $*PROGRAM_NAME;
my $data = slurp $filename;
say $data.bytes;
```

## Twigils 和特殊变量

Perl 6 有很多特殊变量.为了更容易地跟普通变量区分开，它们用一种叫做twigil的第二个前缀来标记。
通常,用户自定义的变量有一个魔符($ @ 或%)在变量名前。

系统变量有额外的字符在魔符和变量名之间

Examples:
```perl6
$*PROGRAM_NAME 包含当前运行的Perl 6 脚本的路径.
$*CWD          是当前工作目录的路径。
$*IN           是标准输入(STDIN).你可以使用 $*IN.get 读入一行。
```
你可以阅读S28了解更多。


## 比较操作符 

有两种相关的比较操作符. 一种是比较数字，一种是比较字符串,基于 ASCII表。

```perl6

  3 == 4               # false
  '35' eq 35.0         # false
  '35' == 35.0         # true
  13 > 2               # true
  13 gt 2              # false !!!
  "hello" == "world"   # throws exception
  "hello" eq "world"   # false
  "hello" == ""        # throws exception
  "hello" eq ""        # false
```

```perl6
#!/usr/bin/env perl6
use v6;

say 4       == 4 ?? "TRUE" !! "FALSE";     # TRUE
say 3       == 4 ?? "TRUE" !! "FALSE";     # FALSE
say "3.0"   == 3 ?? "TRUE" !! "FALSE";     # TRUE
say "3.0"   eq 3 ?? "TRUE" !! "FALSE";     # FALSE
say 13     >   2 ?? "TRUE" !! "FALSE";     # TRUE
say 13     gt 2 ?? "TRUE" !! "FALSE";      # FALSE
say "foo"   == "" ?? "TRUE" !! "FALSE";    # TRUE
say "foo"   eq "" ?? "TRUE" !! "FALSE";    # FALSE
say "foo"   == "bar" ?? "TRUE" !! "FALSE"; # TRUE
say "foo"   eq "bar" ?? "TRUE" !! "FALSE"; # FALSE
```
  不能转换字符串为数字：十进制数字必须以合法数字或点开头
  
## 布尔表达式 

```perl6
布尔表达式 (逻辑操作符)
  if COND and COND {
  }
 
  if COND or COND {
  }
 
  if not COND {
  }
examples/scalars/logical_operators.p6
#!/usr/bin/env perl6
use v6;

say (2 and 1);   # 1
say (1 and 2);   # 2
say (1 and 0);   # 0
say (0 and 1);   # 0
say (0 and 0);   # 0
say "---";

say (1 or 0);   # 1
say (1 or 2);   # 1
say (0 or 1);   # 1
say (0 or 0);   # 0
say "---";

say (1 // 0);     # 1
say (0 // 1);     # 0
say (0 // 0);     # 0
say "---";

say (1 xor 0);     # 1
say (0 xor 1);     # 1
say (0 xor 0);     # 0
say (1 xor 1);     # Nil
say "---";

say (not 1);       # False
say (not 0);       # True
say "---";
```

## 超级or - 多选分支

```perl6
#!/usr/bin/env perl6
use v6;

say "Please select an option:";
say "1) one";
say "2) two";
say "3) three";
my $c = prompt('');

if $c == 1 or $c == 2 or $c == 3 {
    say "correct choice: $c";
} else {
    say "Incorrect choice: $c";
}

这种新颖的语法
if $c == 1|2|3 {
    say "correct choice: $c";
} else {
    say "Incorrect choice: $c";
}
```

## 从键盘读入
prompt读取用户输入内容知道用户按下 Enter键。但是它只传递第一个换行之前的内容

```perl6
#!/usr/bin/env perl6
use v6;
my $name = prompt("Please type in yourname: ");
say "Hello $name"; #还不能处理汉字，prompt是一个函数，其参数为提示信息
```
## 读取文件内容到数组中

当我们把调用slurp() 的结果放进数组中时，数组中将只有一个元素，该元素的值就是要读取的文件中的所有内容。如果你想读取所有行到数组中不同的元素中，你需要使用 `lines` 函数。 
```perl6
#!/usr/bin/env perl6
use v6;

my $filename = $*PROGRAM_NAME;

# reads all the content of the file in the first element of the array!
my @content = slurp $filename;
say @content.elems;

# reads all the content of the file, every line an element in the array
my @rows = lines $filename.IO;
say @rows.elems;
```

## 求和 
numbers.txt:(另存为ansi编码)
3
8
19
-7
13 
```perl6
#!/usr/bin/env perl6
use v6;

my $filename = 'numbers.txt';

my $total;
my $count;
my $min;
my $max;

if (my $fh = open $filename, :r) {
    for $fh.lines -> $line {
        if (not $count) {
            $min = $max = $line;
        }
        $total += $line;
        if ($min > $line) {
            $min = $line;
        }
        if ($max < $line) {
            $max = $line;
        }
        $count++;
    }
    my $average = $total / $count;
    say "Total: $total, Count: $count Average: $average Min: $min Max: $max";
} else {
    say "Could not open '$filename'";
}

# There is a minor issue in this solution, what if there are no values at all in the file?
```

## 列表和数组


括号()中用逗号分隔的东西叫做列表。实际上你甚至不需要括号。 列表就是一组有序的标量值。例子:

```perl6
#!/usr/bin/env perl6
use v6;

(1, 5.2, "apple");           # 3 values
(1,2,3,4,5,6,7,8,9,10);      # 很好但是我们很懒，所以我们这样写：:
(1..10);                     # 与(1,2,3,4,5,6,7,8,9,10)一样
(1..Inf);                    # represents the list of all the numbers
(1..*);                      # this too

("apple", "banana", "peach", "blueberry");    # is the same as
<apple banana peach blueberry>;               # quote word

my ($x, $y, $z);             # 我们也能使用标量变量作为列表的元素
```
在大多数情况下，我们实际上甚至不需要括号.

列表赋值
```perl6
  my ($x, $y, $z);
  ($x, $y, $z) = f();   # 如果 f() 返回 (2, 3, 7) 则它几乎与$x=2; $y=3; $z=7;相同
  ($x, $y, $z) = f();   # 如果 f() 返回 (2, 3, 7, 9), 则忽略 9
  ($x, $y, $z) = f();   # 如果 f() 返回 (2, 3); 则 $z 是 undef
我们怎么交换两个变量的值，比如说 $x 和 $y?
```
交换两个值

```perl6
#!/usr/bin/env perl6
use v6;

say "Type in two values:";
my $a = $*IN.get;
my $b = $*IN.get;

($a, $b) = ($b, $a);
say $a;
say $b;
```

用for循环遍历列表的元素
```perl6
#!/usr/bin/env perl6
use v6;
for "Foo", "Bar", "Baz" -> $name {
    say $name;
}

say "---";

for 1..5 -> $i {
    say $i;
}

say "---";

for 1..Inf -> $i {
    say $i;
    last if $i > 3;
}

say "---";

for 1..* -> $i {
    say $i;
    last if $i > 3;
}
```

创建数组, 遍历数组
 
你可以给一列值赋值给数组。
在双引号中数组不会进行插值。这与Perl 5 不一样。
就像你看见的，列表周围的括号是可选的。

```perl6
#!/usr/bin/env perl6
use v6;

my @colors = "Blue", "Yellow", "Brown", "White";  # 列表周围的括号是可选的
say @colors;

say "--------------------------------";               # just for separation...

say "@colors";                                                   # 没有插值!

say "--------------------------------";               # just for separation...

say "{@colors}";

say "--------------------------------";               # just for separation...

say "@colors[]";

say "--------------------------------";               # just for separation...

for @colors -> $color {
    say $color;
}
```
Output:
```perl6
  Blue Yellow Brown White
  --------------------------------
  Blue Yellow Brown White
  --------------------------------
  Blue
  Yellow
  Brown
  White
``` 
  数组元素 (create menu)
```perl6
#!/usr/bin/env perl6
use v6;
my @colors = <Blue Yellow Brown White>;

for 1..@colors.elems -> $i {
    say "$i) @colors[$i-1]";
}

my $input = prompt("Please select a number: ");
say "You selected @colors[$input-1]";
```
数组赋值
```perl6
#!/usr/bin/env perl6
use v6;

my $owner = "Moose";
my @tenants = "Foo", "Bar";
my @people = ($owner, 'Baz', @tenants);   # 数组被展开:
say "{@people}";                          # Moose Baz Foo Bar


my ($x, @y)     = (1, 2, 3, 4); 
say $x;                               # $x = 1
say "{@y}";                           # @y = (2, 3, 4)
```
命令行选项
@*ARGS 数组由语言维护，它存储着命令行的值。
```perl6
#!/usr/bin/env perl6
use v6;

my $color = @*ARGS[0];

if not $color {
    my @colors = <Blue Yellow Brown White>;

    for 1 .. @colors.elems -> $i {
        say "$i) @colors[$i-1]";
    }

    my $input = prompt "Please select a number: ";
    $color = @colors[$input-1];
}

say "You selected $color";
```
处理 CSV 文件
examples/arrays/sample_csv_file.csv
 
Foo,Bar,10,home
Orgo,Morgo,7,away
Big,Shrek,100,US
Small,Fiona,9,tower
 
examples/arrays/process_csv_file.p6
```perl6
#!/usr/bin/env perl6
use v6;

my $file = 'examples/arrays/sample_csv_file.csv';
if defined @*ARGS[0] {
    $file = @*ARGS[0];
}

my $sum = 0;
my $data = open $file;
for $data.lines -> $line {
    my @columns = split ",", $line;
    $sum += @columns[2];
}
say $sum;
```
join
examples/arrays/join.p6
```perl6
#!/usr/bin/env perl6
use v6;

my @fields = <Foo Bar foo@bar.com>;
my $line = join ";", @fields;
say $line;     # Foo;Bar;foo@bar.com
```

  uniq 函数
examples/arrays/unique.p6
```perl6
#!/usr/bin/env perl6
use v6;

my @duplicates = 1, 1, 2, 5, 1, 4, 3, 2, 1;
say @duplicates.perl;
# prints Array.new(1, 1, 2, 5, 1, 4, 3, 2, 1)


my @unique = uniq @duplicates;
say @unique.perl;

# prints Array.new(1, 2, 5, 4, 3)


my @chars = <b c a d b a a a b>;
say @chars.perl;

# prints Array.new("b", "c", "a", "d", "b", "a", "a", "a", "b")

my @singles = uniq @chars;
say @singles.perl;

# prints Array.new("b", "c", "a", "d")
```

```perl6
examples/arrays/loop_over_array.p6
#!/usr/bin/env perl6
use v6;

my @fellows = <Foo Bar Baz>;
for @fellows -> $name {
    say $name;
}
```

examples/arrays/looping_over_many_elements.p6

```perl6
#!/usr/bin/env perl6
use v6;

my @scores = <
    Valencia         1 1     Recreativo_Huelva
    Athletic_Bilbao  2 5     Real_Madrid
    Malaga           2 2     Sevilla_FC
    Sporting_Gijon   3 2     Deportivo_La_Coruna
    Valladolid       1 0     Getafe
    Real_Betis       0 0     Osasuna
    Racing_Santander 5 0     Numancia
    Espanyol         3 3     Mallorca
    Atletico_Madrid  3 2     Villarreal
    Almeria          0 2     Barcelona
>;

for @scores -> $home, $home_score, $guest_score, $guest {
    say "$home $guest $home_score : $guest_score";
}
```
缺失值


examples/arrays/missing_values.p6
```perl6
#!/usr/bin/env perl6
use v6;

for (1, 2, 3, 4, 5) -> $x, $y {
    say "$x $y";
}
say 'done';
```

examples/arrays/missing_values.p6.output
1 2
3 4
Not enough positional parameters passed; got 1 but expected 2
  in block <anon> at examples/arrays/missing_values.p6:4

examples/arrays/missing_values_fixed.p6

```perl
#!/usr/bin/env perl6
use v6;

for (1, 2, 3, 4, 5) -> $x, $y? {
    say "$x $y";
}
say 'done';
```
examples/arrays/missing_values_fixed.p6.output
1 2
3 4
use of uninitialized value of type Mu in string context
    in block <anon> at examples/arrays/missing_values_fixed.p6:5
5
done


examples/arrays/z.p6
```perl6
#!/usr/bin/env perl6
use v6;

my @chars   = <a b c>;
my @numbers = <1 2 3>;

for @chars Z @numbers -> $letter, $number {
    say "$letter $number";
}
```
Output:

examples/arrays/z.p6.out
a 1
b 2
c 3


examples/arrays/z_on_more.p6

```perl6
#!/usr/bin/env perl6
use v6;

my @operator   = <+ - *>;
my @left       = <1 2 3>;
my @right     = <7 8 9>;

for @left Z @operator Z @right -> $a, $o, $b {
    say "$a $o $b";
}
```
Output:

examples/arrays/z_on_more.p6.out
1 + 7
2 - 8
3 * 9

xx - string multiplicator
examples/arrays/xx.p6
```perl6
#!/usr/bin/env perl6
use v6;

my @moose = "moose" xx 3;
say "{@moose}";
```
sort values
examples/arrays/sort.p6

```perl6
#!/usr/bin/env perl6
use v6;

my @names = <foo bar moose bu>;
my @sorted_names = sort @names;
say @sorted_names.perl;   # ["bar", "bu", "foo", "moose"]


my @numbers = 23, 17, 4;
my @sorted_numbers = sort @numbers;
say @sorted_numbers.perl;   # [4, 17, 23]


my @sort_names_by_length = sort { $^a.bytes <=> $^b.bytes }, @names;
say @sort_names_by_length.perl;   # ["bu", "bar", "foo", "moose"]

# the same result with one sub (Schwartizian transformation)
my @sort_1 = sort { $_.bytes }, @names;
say @sort_1.perl;     # ["bu", "bar", "foo", "moose"]

my @sort_2 = @names.sort({ $_.bytes });
say @sort_2.perl;     # ["bu", "bar", "foo", "moose"]

my @sort_3 = @names.sort: { $_.bytes };
say @sort_3.perl;     # ["bu", "bar", "foo", "moose"]


my @words = <moo foo bar moose bu>;
say @words.sort({ $^a.bytes <=> $^b.bytes}).perl; # ["bu", "moo", "foo", "bar", "moose"];

say @words.sort({ $^a.bytes <=> $^b.bytes or $^a cmp $^b}).perl; # ["bu", "bar", "foo", "moo", "moose"];

# TODO: should be also:
# say @words.sort({ $^a.bytes <=> $^b.bytes }, {$^a cmp $^b}).perl; # ["bu", "bar", "foo", "moo", "moose"];
# say @words.sort({ $_.bytes },   {$^a cmp $^b}).perl; # ["bu", "bar", "foo", "moo", "moose"];
```


创建数组, Data::Dumper, 调试打印

 
在Perl6 中创建数组跟在Perl5 中一样，对于调试打印我们会使用Perl6 的`.perl`方法来代替Perl5中的`Data::Dumper`.
```perl6
use v6;

my @numbers = ("one", "two", "three");
say @numbers.perl;   # Array.new("one", "two", "three")
```
在Perl6中，列表周围的`圆括号不再需要了`：
```perl6
use v6;

my @digits = 1, 3, 6;
say @digits.perl;  # Array.new(1, 3, 6)
```
qw() 不再使用

Perl 5 中的 `qw()` 操作符被`尖括号`取代：
```perl6
use v6;

my @names = <foo bar baz> ;
say @names.perl;  # Array.new("foo", "bar", "baz")
```
字符串中的数组插值

 
在双引号字符串中，数组不再插值：
```perl6
use v6;

my @names = "red","yellow","green";
say "@names";  # @names
```
你可以放心地写下这样的句子而不转义 @ 符号:
```perl6
use v6;

my @names = <Tom Cat>;
say "joe@names.org";    # joe@names.org
```
如果你确实要内插数组的值，你必须将数组放在一对 `花括号` 中：
```perl6
use v6;

my @names = < foo bar baz > ;
say "names: {@names}"; # names: foo bar baz
``` 
取数组元素, 魔符不变

 
当在Perl 6 中访问数组的元素时，元素前的符号不会改变！这对Perl 5 程序员来说会很奇怪，但是长期看来它有优势。
```perl6
use v6;

my @names = < foo bar baz > ;
say @names[0];    # foo
```
内插一个数组元素

  作为一个特殊情况，一个数组元素能被内插在双引号字符串中而不使用花括号。术语 `post-circumfix` 对于`方括号`或`花括号`来说是一个一般称谓. 一般地,带有前置符号的变量可以被内插.
```perl6
use v6;

my @names = < foo bar baz >;
say "name:@names[0]";   # name: foo
```

数组中元素的个数

在  Perl 6 中,推荐使用`elems()`方法和相关的函数来得到数组的元素个数。实际上，我认为面向对象的写法更美观:
```perl6
use v6;

my @names = < foo bar baz >;
say elems @names;    # 3
say @names.elems;    # 3
```
范围

 
范围在Perl 6 中跟Perl 5 很像：
```perl6
use v6;

my @d = 1..11;
say @d.perl;    # Array.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
```
The same works with scalar variables on either side:
```perl6
use v6;

my $start = 1;
my $end = 11;

my @d = $start .. $end;
say @d.perl;  # Array.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
```
ranges一个很有意思的方面可能是，你能对单个或两个范围的终点使用`^`符号告诉它们排除终点：
```perl6
use v6;

my $start = 1;
my $end = 11;

my @d = $start ^..^ $end; # 1的终点是1，,11的终点是11，排除这两个值
say @d.perl;  # Array.new(2, 3, 4, 5, 6, 7, 8, 9, 10)
```
范围操作符同样对`字符`有效：
```perl6
use v6;

my @chars = ('a' .. 'd');
say @chars.perl;    # Array.new("a", "b", "c", "d")
```
for  和 foreach 循环

 
  Perl 5 中C风格的for 循环现在叫做loop，但是我不会在这儿展示它。
```perl6
use v6;
for 1..3 -> $i {
    say $i; 
}
```
输出为
1
2
3
这同样对数组有效:
```perl6
use v6;

my @names = < foo bar baz >;
for @names -> $n {
    say $n;
}
```
输出:
foo
bar
baz

顺便提一下,这是你`不用使用my声明一个变量`的情况之一。循环变量自动被声明好了，并且作用到for循环块中。

遍历数组的索引

如果你想遍历数组的索引，你可以使用范围，从0一直到最大的索引值。最大索引值比数组元素的个数少1.你可以用 `@names.elems -1` 作为最优的范围 ,或者你可以使用 `^`  符号告诉范围排除最后一个值：
```perl6
use v6;

my @names = < foo bar baz >;
for 0 ..^@names.elems -> $i {
    say "$i {@names[$i]}";
}
```
输出:
0 foo
1 bar
2 baz

或者这样： 
```perl6
use v6;

my @names = < foo bar baz >;
for @names.keys -> $i {
    say "$i {@names[$i]}";
}
```
从散列中借来的`keys()`方法会返回数组所有的索引。即使你的数组含有‘空’值，即带有`undef`的元素，`keys()`仍旧会包含这样的元素的索引。


split

split() 表现的就像Perl 5 中split的`副本`一样，但是默认行为不再应用，无论如何，你应该查看文档：

```perl6
use v6;

say "a,b,c".split(',').perl;  # ("a", "b", "c").list
```

## 三元操作符 

```perl6
use v6;

my $age = 42;

if $age > 18 {
    say "Above 18";
} else {
    say "Below 18";
}

say $age > 18 ?? "Above 18" !! "Below 18";
```
语法：   COND ?? VALUE_IF_TRUE !! VALUE_IF_FALSE

## 数字运算符


数字运算符可以用在标量值上面。

examples/scalars/numerical_operators.p6
```perl6
#!/usr/bin/env perl6
use v6;

my $x = 3;
my $y = 11;

my $z = $x + $y;
say $z;             # 14

$z = $x * $y;
say $z;             # 33
say $y / $x;        # 3.66666666666667

$z = $y % $x;       # (模)
say $z;             # 2

$z += 14;           # is the same as   $z = $z + 14;
say $z;             # 16

$z++;               # is the same as   $z = $z + 1;
$z--;               # is the same as   $z = $z - 1;

$z = 23 ** 2;       # 幂
say $z;             # 529
```
## 文件读取

从文件中读取行
打开文件时的模式：

    :r   - read
    :w   - write
    :a   - append
   
open函数的两个参数：文件名和模式.为了打开一个文件读取，模式需为 :r . 此函数要么返回一个存在标量变量中的文件句柄，要么失败时返回 undef 。
```perl6
$fh = open $filename, :r
```
一旦我们打开了一个文件句柄，我们可以使用 get 方法 ($fh.get) 从给定的文件中读取一行。

你也可以连续调用 get 方法 读取多行，但还有更好的方法。

examples/files/read_one_line.p6
```perl6
#!/usr/bin/env perl6
use v6;

my $filename = $*PROGRAM_NAME;

my $fh = open $filename;
my $line = $fh.get;
say $line;
```
读取所有行
```perl6
#!/usr/bin/env perl6
use v6;

my $filename = $*PROGRAM_NAME;

my $fh = open $filename;
while (defined my $line = $fh.get) {
    say $line;
}
```

逐行读取文件

```perl6
#!/usr/bin/env perl6
use v6;

my $filename = $*PROGRAM_NAME;

my $fh = open $filename;
for $fh.lines -> $line {
    say $line;
}
```
lines 方法返回文件的所有行或部分行


在Perl 6中对存在的数据结构进行操作是有趣的，但是如果没有输入与输出的话，就会限制在真实世界中的用途。
因此，读取文件内容是一个明智的操作.
 
`open`
`get`
`read`
`IO`
`lines`

一行行读取（Read line-by-line）
  open   函数会打开一个文件，默认情况下，你可以显示地传递一个 :r 作为open函数的第二个参数。 Open会返回一个文件句柄，即一个IO类的实例。
  get    方法会从文件读取并返回一行，末尾的新行会自动被移除。 (Perl 5  开发者也可以认为 get 方法自动调用了chomp操作.)
```perl
my $fh = open $filename;
my $line = $fh.get;
```
你也可以在一个while循环中读取文件的所有行。  与 Perl 5相反, 在这个while循环中，对是否定义没有隐式地检测.你必须在条件语句中显示地添加单词defined.否则，读取操作将在第一个空行处停止。
`my $fh = open $filename;` 

    while (defined my $line = $fh.get)
      { 
        say $line;
      }
在for循环中使用    `lines `  方法可能更具有Perl-6风格。     lines   方法会依次读取文件的每一行，然后将读取到行赋值给变量 `$line` ,然后执行代码块。 
```perl6
my $fh = open $filename;
for $fh.lines -> $line {
      say $line;
} 
```
## 写文件 

为了写入内容到文件我们首先要开启 :w 模式.如果成功，我们得到一个文件句柄，在该文件句柄上我们可以使用普通的诸如print()、say()、或printf()等输出方法。
examples/files/write_file.p6
```perl6
#!/usr/bin/env perl6
use v6;

my $filename = "temp.txt";

my $fh = open $filename, :w;
$fh.say("hello world");
$fh.close;
```

## 元操作符 

元操作符
examples/arrays/assignment_shortcut.p6
```perl6
#!/usr/bin/env perl6
use v6;

my $num = 23;
say $num + 19;             # 42
say $num;                  # 23
$num += 19;
say $num;                  # 42
```
赋值时的方法调用
在Perl 6 中它扩展了点操作符的功能，允许在对象上进行方法调用。想想下面的例子。subst方法能够用一个字符串替换另外一个，但是并不改变原来的字符串。默认地，它返回改变了的字符串.
如果你想改变原字符串，你可以写为 `$str = $str.subst('B', 'X');` 或者你可以写成它的 shortcut version.
examples/arrays/assignment_operators.p6

```perl6
#!/usr/bin/env perl6
use v6;
my $str = 'ABBA';
say $str.subst('B', 'X');      # AXBA
say $str;                      # ABBA

say $str .= subst('B', 'X');   # AXBA
say $str;                      # AXBA
```
赋值时调用函数
这也同样可以用于函数中，就如 `$lower = min($lower, $new_value);` 你可以写为 `$lower min= $new_value;`

examples/arrays/assignment_function_shortcuts.p6

```perl6
#!/usr/bin/env perl6
use v6;

my $lower = 2;
$lower min= 3;
say $lower;                # 2
$lower min= 1;
say $lower;                # 1
```
这甚至可以有效地使用逗号操作符向数组中压入更多值。
```perl6
  my @a = (1, 2, 3);
  @a ,= 4;
  @a.say;
```  
  反转关系操作符
等号(==)操作符在Perl6 中用于比较数字，eq用于比较字符串。 The negated version are the same just with an exclamation mark ( ! ) in front of them. 所以它们看起来就是 !== 和 !eq.
幸运的是，那些都有它们的快捷写法，可以写为!=和ne。
其他操作符也有相应的反转版本，所以你可以写 !>= ，它的意思是不大于 (对于数字) 并且你可以写!gt ，对于字符串来说是一样的. 我没有全部摊出我们为什么需要这个。
一个我能明白的优点是如果你创建了一个叫做I的操作符，然后你会自动得到一个看起来像!I 的操作符，那是它的反转。
examples/arrays/negated_operators.p6

```perl6
#!/usr/bin/env perl6
use v6;
# 相等
say 1 ==  1       ?? 'y' !! 'n'; # y
say 1 !== 1       ?? 'y' !! 'n'; # n
say 1 !=  1       ?? 'y' !! 'n'; # n
say 'ac' eq  'dc' ?? 'y' !! 'n'; # n
say 'ac' !eq 'dc' ?? 'y' !! 'n'; # y
say 1 <  2        ?? 'y' !! 'n'; # y
####say 1 !< 2    ?? 'y' !! 'n'; # n
say 1 <=  2       ?? 'y' !! 'n'; # y
####say 1 !<= 2   ?? 'y' !! 'n'; # n
say 1 >=  2       ?? 'y' !! 'n'; # n
####say 1 !>= 2   ?? 'y' !! 'n'; # y
```
反转操作符
反转操作符会反转两个操作数的意思. 所以就像交换 `$b cmp $a` 中参数的值，你可以写为 `$a Rcmp $b`.


examples/arrays/reversed_operators.p6
```perl6
#!/usr/bin/env perl6
use v6;
# 宇宙飞船操作符
say 1 <=> 2;   # -1
say 2 <=> 1;   # 1
say 1 R<=> 2;  # 1
say 2 R<=> 1;  # -1
```
输出：
examples/arrays/reversed_operators.p6.out
Increase
Decrease
Decrease
Increase

Hyper 操作符

examples/arrays/hyper.p6

```perl6
#!/usr/bin/env perl6
use v6;
my @x = (1, 2) >>+<< (3, 4);
say @x.perl;  # [4, 6]
#my @d = (1, 2) >>+<< (3);
#say @d.perl;  # [4, 6]
# Non-dwimmy hyperoperator cannot be used  on arrays of different sizes or dimensions.
my @z = (1, 2, 3, 4) >>+>> (1, 2);
say @z.perl;          # [2, 4, 5, 6]

@z = (1, 2, 3, 4) <<+>> (1, 2);
say @z.perl;          # [2, 4, 5, 6]
@z = (4) <<+>> (1, 2);
say @z.perl;          # [5, 6]

my @y = (1, 2) >>+>> 1;
say @y.perl;          # [2, 3]
```
examples/arrays/hyper.p6.out
Array.new(4, 6)
Array.new(2, 4, 4, 6)
Array.new(2, 4, 4, 6)
Array.new(5, 6)
Array.new(2, 3)


Reduction 操作符
examples/arrays/reduction_operators.p6

```perl6
#!/usr/bin/env perl6
use v6;
say [+] 1, 2;    # 3
say [+] 1..10;   # 55
# 阶乘
say [*] 1..5;    # 120
say [**] 2,2,2;  # 16      == 2**2**2
my @numbers = (2, 4, 3);
# 检查数字是否是递增顺序
say [<] @numbers;          # False   
say [<] sort @numbers;     # True
```
输出
examples/arrays/reduction_operators.p6.out
3
55
120
16
False
True

Reduction Triangle operators
The ~ in front of the operator is only needed for the stringification of the list to inject spaces between the values when printed.
examples/arrays/triangle_operators.p6

```perl6
#!/usr/bin/env perl6
use v6;
say ~[\+] 1..5;  # 1 3 6 10 15 (1 1+2 1+2+3 ... 1+2+3+4+5)
say ~[\*] 1..5;  # 1 2 6 24 120
```
输出：
examples/arrays/triangle_operators.p6.out
1 3 6 10 15
1 2 6 24 120

交叉操作符 Cross operators
examples/arrays/cross_operators.p6

```perl6
#!/usr/bin/env perl6
use v6;
my @x = (1, 2) X+ (4, 7);
say @x.perl;                # [5, 8, 6, 9] 1+4,1+7,2+4,2+7

my @y = 1, 2 X+ 4, 7;
say @y.perl;                # [5, 8, 6, 9]

my @str = 1, 2 X~ 4, 7;
say @str.perl;              # ["14", "17", "24", "27"]
# without any special operator  (is the same with X, should be)
my @z = 1, 2 X 4, 7;
say @z.perl;                # [1, 4, 1, 7, 2, 4, 2, 7]
```
输出：
examples/arrays/cross_operators.p6.out
Array.new(5, 8, 6, 9)
Array.new(5, 8, 6, 9)
Array.new("14", "17", "24", "27")
Array.new(1, 4, 1, 7, 2, 4, 2, 7)

 积的交叉
```perl6
my @y = 1, 2 X* 4, 7;
```
输出 4 7 8 14

## 字符串操作

自动将字符串转换为数字

examples/scalars/add.p6
```perl6
#!/usr/bin/env perl6
use v6;

my $a = prompt "First number:";
my $b = prompt "Second number:";

my $c = $a + $b;

say "\nResult: $c";
```

字符串操作
examples/scalars/string_operators.p6

```perl6
#!/usr/bin/env perl6
use v6;

my $x = "Hello";
my $y = "World";

# ~ 是连接操作符,连接字符串
my $z = $x ~ " " ~ $y;   # the same as "$x $y"
say $z;                  # Hello World
```

```perl6
my $w = "Take " ~ (2 + 3);
say $w;                         # Take 5
say "Take 2 + 3";               # Take 2 + 3
say "Take {2 + 3}";             # Take 5
```

```perl6
$z ~= "! ";             #   the same as   $z = $z ~ "! ";
say "'$z'";             # 'Hello World! '
```
  ~ 连接2个字符串.
就像上面见到的那样，任何操作符都能使用花括号语法插入到字符串中。.

字符串连接
examples/scalars/concat.p6
```perl6
#!/usr/bin/env perl6
use v6;

my $a = prompt "First string:";
my $b = prompt "Second string:";

my $c = $a ~ $b;

say "\nResult: $c";
```
字符串重复操作
examples/scalars/string_repetition.p6
```perl6
#!/usr/bin/env perl6
use v6;

my $z = "Hello World! ";

# x is the string repetition operator
my $q = $z x 3;
say " ' $q ' ";         # 'Hello World! Hello World! Hello World! '
```

##  字符串函数 - index

```perl6
#!/usr/bin/env perl6
use v6;

my $s = "The black cat jumped from the green tree";

say index $s, "e";                          # 2
say index $s, "e", 3;                       # 18

say rindex $s, "e";                         # 39
say rindex $s, "e", 38;                     # 38
say rindex $s, "e", 37;                     # 33
```

## 字符串函数 - substr 

字符串函数: substr
examples/scalars/string_functions_substr.p6


```perl6
#!/usr/bin/env perl6
use v6;

my $s = "The black cat climbed the green tree";
my $z;
$z = substr $s, 4, 5;                     # $z = black
say $z;
$z = substr $s, 4, *-11;                  # $z = black cat climbed the   从索引4开始截取，不要最后的11个字符
say $z;
$z = substr $s, 14;                       # $z = climbed the green tree，从索引14开始知道结束
say $z;
$z = substr $s, *-4;                      # $z = tree
say $z;
$z = substr $s, *-4, 2;                   # $z = tr
say $z;
```

## 值在给定的列表中吗

怎样找出一个给定的值是否在一些值的中间？这跟SQL中的IN操作符相似。

在 Perl 6  中，有一个 any() 函数，其功能与SQL 中的IN 关键字相似。让我们看看它如何工作:
它是一个weekday吗?

```perl6
use v6;

my @weekdays = <Monday Sunday Tuesday Wednesday Thursday Friday  Saturday >;

my $day = "Tuesday";
say $day eq any(@weekdays)
 ??
 "$day is a weekday"
 !!
 "$day is NOT a weekday";
```
上面的代码将打印出：
Tuesday is a weekday

perl会尝试使用 eq 让@weekdays中的每一个元素都与$day标量的内容相比较，如果它们中的任意一个为真，表达式即为真。

Perl 6 中的三元操作符

旁注:  ?? !! 对Perl 6 的三元操作符。它语法如下：
```perl6
CONDITION   
?? 
   VALUE_IF_TRUE
    
!!
    VALUE_IF_FALSE
;
```
 

它仍然是weekday吗?

更完整的例子让我们来看当所有这些值都不匹配时会发生什么:
```perl6
use v6;

my @weekdays = <Monday Sunday Tuesday Wednesday Thursday Friday  Saturday >;

my $other = "Holiday";
say $other eq any(@weekdays)
    
?? 
"$other is a weekday"
!!
 "$other is NOT a weekday";
```
代码相同但是不会打印匹配值:
Holiday is  NOT  a weekday

使用小于号比较数字

下个例子我们将会看到any函数能用于其它诸如小于号操作符的比较运算符上:
```perl6
use v6;

my @numbers = (6, -12, 20);
say any(@numbers)< 0 
    ?? "There is a negative number"
    !! "No negative number here";
```

结果为:
There is a negative number

你也可以使用其它操作符.
假使没有负数它也有效:

```perl6
use v6;

my @positive_numbers = (6, 12, 20);
say any(@positive_numbers) < 0
    ?? "There is a negative number"
    !! "No negative number here";
```
输出:
No negative number here

其它关键字: `none`, `all`, `one`

还有其它函数, 不仅仅是 *any* 函数: (all, one and none)
```perl6
use v6;

my @positive_numbers = (6, 12, 20);
say none(@positive_numbers) < 0
    ?? "No negative number here"
    !! "There is a negative number";
```
会打印:
No negative number here

```perl6
use v6;

my @positive_numbers = (6, 12, 20);
say all(@positive_numbers) > 0
    ?? "All are positive numbers"
    !! "There is a NOT positive number";
```
会打印:
All are positive numbers

使用最合适的那个函数。 
更短的写法

有时候你有一个值，你需要检测它是否等于一个所列值中的任意一个：
```perl6
use v6;

my $n = 12;
say ($n == 23 or $n == 42) ?? "ok" !! "not ok";  # not ok
```

使用 any 函数你可以这样写:
```perl6
use v6;

my $n = 12;
say $n == any(23, 42)
 ?? "ok" 
 !! "not ok";  # not ok
```
any 函数也有一个单管道线的中缀操作符版本，所以你也能这样写:
```perl6
use v6;

my  $n = 12;
say $n == 23|42
 ?? "ok" 
 !! "not ok";  # not ok
```
交叉

这些关键词和相关操作所做的实际上是创建了一种叫做`Junction`的数据类型。它是一个标量，以一种无序的方式存储着多个值。跟集合类似。
第一个例子也可以这样写:
```perl6
use v6;
my $weekdays = any <Monday Sunday Tuesday Wednesday Thursday Friday  Saturday >;

my $day = "Tuesday";

say $day eq $weekdays
    ?? "$day is a weekday"
    !! "$day is NOT a weekday";
```
这里我们创建了一个junction而非数组，然后使用该junction进行比较。
Other operations on Junctions

In addition to the comparison operations we saw earlier, we can do other operations on junctions. The operation will be executed on each one of the values in the junction and the result will be a new junction with the changed values:
```perl6
use v6;

my $numbers = any(23, 42);
$numbers.perl.say;

$numbers++;
$numbers.perl.say;
```
这会打印该 junction的perl表现:
any(23, 42)
any(24, 43)
Functions on Junctions

你也可以将 junctions 作为参数传递给函数。 The function will be executed on each value separately in an undefined order, and the result will be another junction. For example if we would like to create the 3 character version of the months we can use the following code:

```perl6
use v6;
my $months = any ;

my $short_names = substr($months, 0, 3);
$short_names.perl.say;
```
Which should print
any("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug",  "Sep", "Oct", "Nov", "Dec");

## Perl 6 的正则 

正则操作符
在 Perl 6 中智能匹配 ~~ 操作符用于正则匹配。
对于相反的匹配，使用 !~~ 操作符。
 
基本用法
```perl6
use v6;
my $str = 'abc123';
if $str ~~ m/a/ {
      say "Matching";
}
if $str !~~ m/z/ {
      say "No z in $str";
}
```
两个条件都是真的，所以两组字符串 "Matching" 和"No z in abc123"都会被打印。
特殊符号
Perl6中有一个重要改变，那就是在Perl6 中，任何`非字母数字字符`需要被转义。
在下个例子中，我们需要转义 `-` 符号:
```perl6
use v6;
my $str = 'abc - 123';
if $str ~~ m/-/ {
      say "Matching";
}
```
生成:

===SORRY!===
Unrecognized regex metacharacter - (must be quoted to match literally) at line 6, near "/) {\n      s"
```perl6 
use v6;
my $str = 'abc - 123';
if $str ~~ m/\-/ {
      say "Matching";
}
```
有效，打印匹配。
 
新特殊字符
`#`现在是一个特殊字符，代表注释,所以当我们真正需要一个`#`号时，需要转义：
```perl6
use v6;
my $str = 'abc # 123';
if $str ~~ m/(#.)/ {
      say "match '$/'";
}
```
报错：

===SORRY!===
Unrecognized regex metacharacter ( (must be quoted to match literally) at line 6, near "#.)/ {\n    "

转义后正确：
```perl6
use v6;
my $str = 'abc # 123';
if $str ~~ m/(\#.)/ {
      say "match '$/'";
}
```  
Perl 6 的匹配变量
每次一有正则操作，一个叫做 `$/` 的本地化变量被设置成实际匹配到的值。
```perl6
use v6;
my $str = 'abc123';
if $str ~~ m/a/ {
      say "Matching    '$/'";        # Matching  'a'
}
if $str !~~ m/z/ {
      say "No z in $str '$/'";       # No z in abc123  ''
}
``` 
 
Perl 6 正则中的空格
在Perl 6 中，正则默认忽略空格。
```perl6
use v6;
my $str = 'The black cat climbed to the green tree.';
if $str ~~ m/black/ {
      say "Matching '$/'";        # Matching 'black'
}
if $str ~~ m/black cat/ {
      say "Matching '$/'";
} else {
      say "No match as whitespaces are disregarded";  # prints this
}
```
那怎样匹配空格呢？
```perl6
use v6;
my $str = 'The black cat climbed to the green tree.';
if $str ~~ m/black\scat/ {
      say "Matching '$/' - Perl 5 style white-space meta character works";
}
if $str ~~ m/black \s cat/ {
      say "Matching '$/' - Meta white-space matched, real space is disregarded";
}
if $str ~~ m/black  ' '  cat/ {
      print "Matching '$/' - ";
      say "the real Perl 6 style would be to use strings embedded in regexes";
}
if $str ~~ m/black cat/ {
      print "Matching '$/' - ";
      say "or maybe the Perl 6 style is using named character classes ";
}
```
任何情况下，我们可以这样写：
```perl6
use v6;
my $str = 'The black cat climbed to the green tree.';
if $str ~~ m/  b l a c k c a t/ {
      say "Matching '$/' - a regex in Perl 6 is just a sequence of tokens";
}
``` 
你看，你可以使用`单引号`在正则中嵌入字面字符串，也有新类型的字符类，使用尖括号。

匹配任何字符
点(.)匹配任何字符，包括`换行符`。
如果你想匹配除新行外的所有其他字符，你可以使用 `\N` 特殊字符类。
```perl6
use v6;
my $str = 'The black cat climbed to the green tree.';
if $str ~~ m/c./ {
      say "Matching '$/'";          # 'ck'
}
my $text = "
The black cat
climbed the green tree";
if $text ~~ m/t./ {
      say "Matching '$/'";
}
```
第一个正则匹配并打印'ck',第二个打印：
't
'

使用 `\N`:
```perl6
use v6;
my $text = "
The black cat
climbed the green tree";
if $text ~~ m/t\N/ {
      say "Matching '$/'";        # 'th'      of the word 'the'
}
```
在最后一个例子中你看到 `\N` 能匹配字母 h，而非新行。

## Perl6的一些特性 
```perl6
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
```
## Perl 6 中一系列整数的操作 

Perl 6 中一系列整数的操作
```perl6
my $x = 23;
my $z = 27;
for $x .. $z -> $i {
      say $i;
}
```
会打印出期望的数字 23, 24, 25, 26, 27 .
 
C风格的循环
C风格, 有3部分的for循环在Perl 6 中也是可行的但不推荐。
```perl6
my $x = 23;
my $z = 27;
loop (my $i = $x; $i <= $z; $i++) {
      say $i;
}
```

序列

在Perl 6 中用 for 循环每隔2个数遍历也是可以的，我们使用3个 . 而非2个 . 这里我们谈论的是序列而非范围。
我们设置序列的前两个元素和序列的上限.
```perl6
my $x = 23;
my $z = 27;
for $x, $x+2 ... $z  -> $i {
  say $i;
}
```
这会打印 23, 25, 27
你必须保证上限的准确:
```perl6
for 1, 3 ... 7  -> $i {
  say $i;
}
```
这会打印 1, 3, 5, 7
另一方面，这样：
```perl6
for 1, 3 ... 8  -> $i {
  say $i;
}
```
会报错。(现在已修正， 打印 1，3，5，7)

## Perl 6 中的标量、数组、散列如何插值

标量、数组和散列插值

将标量放在双引号中会进行插值，就跟Perl 5 中一样：
```perl6
use v6;

my $name = "Foo";
say "Hello $name, how are you?";
```
这会打印:
Hello Foo, how are you?

数组和散列不是这样进行插值的，在字符串中，任何放进`花括号`中的东西都会被插值，所以如果你有一个数组，您能这样写：
```perl6
use v6;

my @names = <Foo Bar Moo>;
say "Hello {@names}, how are you?";
```
to get this output:
Hello Foo Bar Moo, how are you?

这里的问题是基于输出结果你不知道数组是有3个元素还是2个：
"Foo Bar" 和 "Moo", 或仅仅一个元素: "Foo Bar Moo".
 
内插表达式

上面的就不是个问题！ 在用双引号引起来的字符串中，你可以将任何表达式放在`花括号`中。表达式会被计算，其结果会被插值：
你可以这样写:
```perl6
use v6;

my @names = <Foo Bar Moo>;
say "Hello { join(', ', @names) } how are you?";
```
输出如下:
Hello Foo, Bar, Moo how are you?

然而这依然没有准确地显示有几个值，这显得稍微复杂了。
作为旁注，万一你更喜欢面向对象的代码，你也可以像下面这样写:
`say "Hello { @names.join(', ') } how are you?";`
结果一样.
 
调试打印

 
对于基本的调试目的，做好使用数组的 `.perl` 方法：
```perl6 
say "Names: { @names.perl }";
```
那会打印：

     Names: Array.new("Foo", "Bar", "Moo")
假使你想同时看到变量名呢？那你可以依赖数组在双引号字符串中不插值这点这样写：
```perl6 
say " @names = { @names.perl }";
```
那会打印：

    @names = Array.new("Foo", "Bar", "Moo")
仅仅是表达式
```perl6
use v6;
say "Take 1+4";
```
会打印：

    Take 1+4
就像我所写的，你可以将任何表达式放进花括号中，你也可以这样写：
```perl6 
use v6;

say "Take {1+4}";
```
那会打印：

    Take 5


插值散列
```perl6
use v6;

my %phone = (
      foo => 1,
      bar => 2,
);

say "%phone = { %phone } ";
```
会打印：

    %phone = foo    1 bar  2
这分不清哪些是键，哪些是值. 对于调试目的，你最好用 `.perl` 方法：
```perl6
 say "%phone = { %phone.perl } ";
```
会打印:

    %phone = ("foo" => 1, "bar" => 2).hash

插值多维数组

```perl6  
use v6;

my @matrix = (
    [1, 2],
    [3, 4],
);

say "@matrix = { @matrix.perl }";
```
输出:

    @matrix = Array.new([1, 2], [3, 4])
