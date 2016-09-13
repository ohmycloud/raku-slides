

# 字符串处理

> 将每行从第二列到最后一列数值为0的且数目多于6个的行删除

数据：

``` perl
OG004240:    1       3     1       1       9     0       4       5       1     1       6    1     2
OG004241:    1       2     1       4       7     2       1       3       1     2       9    1     1
OG004242:    1       2     1       2       4     1       3       9       2     2       4    2     2
OG004243:    0       4     1       2       9     2       4       5       1     2       3    1     1
OG004244:    0       2     1       3       8     3       3       2       2     3       4    2     2
OG004245:    0       3     1       2       7     3       3       0       3     2       7    2     2
OG004246:    0       0     2       0       1     15      0       15      0     0       1    0     1
```

``` perl
use v6;

my @lines = "a.txt".IO.lines;
for @lines -> $line {
    my @words = $line.split(/\s+/);
    say $line unless @words[1..*].grep(* eq 0).elems > 6;
}
```

使用 `p6doc -f Str.split` 查看 split 的帮助文档。

合并相同行：



文件一：

``` perl
1###ENSMMUP00000017866###-###27582-27683
1###ENSMMUP00000017866###-###27508-27576
1###ENSMMUP00000017866###-###27290-27503
1###ENSMMUP00000040736###-###199515-200498
1###ENSMMUP00000040736###-###198582-198818
1###ENSMMUP00000030409###+###395728-395934
1###ENSMMUP00000030409###+###403004-403148

想合并相同的，生成文件格式如下：

1###ENSMMUP00000017866###-###27582-27683  27508-27576  27290-27503  
1###ENSMMUP00000040736###-###199515-200498  198582-198818
1###ENSMMUP00000030409###+###395728-395934  403004-403148
```

一种方法如下：

``` perl
use v6;

my @lines = "a.txt".IO.lines;
my %hash;
for @lines -> $line {
    $line.match(/^(.*?)(\d+'-'\d+)/);
    %hash{$0} ~= $1 ~ " ";
}

for %hash.kv -> $key, $value {
    say $key, $value;
}
```

如下数据，想去掉第3列重复的行且保留的行要使第四列最小, 原始数据：

``` perl
326        0.00        0.00        ( 0 )
63        0.00        2.43        ( 0.0082 )
64        0.00        2.43        ( 0.0082 )
120        0.00        2.43        ( 0 )
340        0.00        4.03        ( 0 )
99        0.00        9.14        ( 0.0229 )
441        0.00        9.14        ( 0.0232 )
142        0.00        10.77        ( 0.0569 )
292        0.00        10.77        ( 0.0393 )
266        0.00        10.77        ( 0.0233 )
```

想要的结果：

``` perl
326        0.00        0.00        ( 0 )
120        0.00        2.43        ( 0 )
340        0.00        4.03        ( 0 )
99        0.00        9.14        ( 0.0229 )
266        0.00        10.77        ( 0.0233 )
```

一种方法如下：

``` perl
use v6;

my @lines = "a.txt".IO.lines;
my %hash;
for @lines -> $line {
    $line.match(/(\d+\.\d+)\s+\(\s+(\S+)/);
    %hash{$0} ~= $1 ~ " ";
}

for @lines -> $line {
    $line.match(/(\d+\.\d+)\s+\(\s+(\S+)/);

    for %hash.kv -> $key, $value {
        say $line if $0 ~~ $key && $1 ~~ $value.words.min;
    }
}
```

有 gene.txt 和 in.txt 两个文件, 文件内容如下:

gene.txt:（2000多行)

``` perl
chr1        ABCA4        94458582        94586799
chr1        ACADM        76190031        76229363
chr16        BBS2        56518258        56554008
chr17        G6PC        41052813        41066450
chr17        GAA        78078244        78093271
```

in.txt:(5万多行)

``` perl
1        94505603        rs368951547        C        T        NA        NA
1        94505604        rs61750126         A        C        0.02066    NA
1        94505611        rs137853898        G        A        NA        not-provided
1        94505620        rs370967816        T        A        NA        NA
1        94505621        rs149503495        T        C        NA        NA
1        94505627        rs374610040        A        G        NA        NA
22        18901263        rs377148163       C        A        NA        NA
22        18901290        rs381848          G        A        0.07989   NA
22        18901322        rs62232347        C        A        NA        NA
22        18901326        rs201353896       TCC      T        0.05005   NA
22        18901327        rs10537001        CCT      C        0.0528    NA
16        18901326        rs201353896       TCC      T        0.05005   NA
17        18901327        rs10537001        CCT      C        0.0528    NA
```

gene.txt 和 in.txt 的第一列的数字部分相同，并且 In 的第二列在gene 的三四列范围之间，就输出in.txt 中的那一行。

解决方法：

``` perl
use v6;

my @lines   = "a.txt".IO.lines;
my @inlines = "in.txt".IO.lines;
my %hash;
for @lines -> $line {
    $line.match(/^chr(\d+)\s+(\w+)\s+(\d+)\s+(\d+)/);
    %hash{$0~$1~$2~$3} = $0 ~ " " ~ $2 ~ " " ~ $3;
}

for @inlines -> $line {
    $line.match(/^(\d+)\s+(\d+)/);

    for %hash.values -> $value {
        say $line
        if $0 ~~ $value.words[0]
        && $1 <= $value.words[1].Num
        && $1 <= $value.words[2].Num;
    }
}
```

例如我现在数组中的值是 `@project = ('NX11','NX12','NX13’)`

另外一个数组是 `@get = ('ss','ssfd','NX12','sed','NX11’)`

现在把第一个数组中出现过的值，如果第二个数组中也有的话删除掉，然后保留第二个数组剩下的值。

使用差集：

``` perl
@get (-) @project
```



有如下数据：

``` perl
PL -0.00 5.50
PL -0.25 3.50
PL -0.50 0.00
PL -0.75 4.50
-0.25 -0.00 1.00
-0.25 -0.25 4.50
-0.25 -0.50 1.00
-0.75 -0.75 1.00
-0.75 -1.00 0.00
-1.00 -0.25 3.50
-1.00 -0.50 0.00
-1.00 -1.25 3.40
-1.00 -1.75 4.00
```

将第一列值相同的行合并， 分使合并第二列和第三列：

结果如下：

``` perl
PL -0.00 -0.25 -0.50 -0.75
PL 5.50 3.50 0.00 4.50
...
```



## 面向对象

Fluent interface (流接口)

在软件工程中，一个流接口（fluent Interface）是指实现一种实现面向对象的能提高代码可读性的API的方法。
在 Perl 6 中有很多种方法, 但是最简单的一种是声明属性为可读写并使用 given 关键字。类型注释是可选的。

``` perl
class Employee {
    subset Salary         of Real where * > 0;
    subset NonEmptyString of Str  where * ~~ /\S/; # 至少一个非空白符号

    has NonEmptyString $.name    is rw;
    has NonEmptyString $.surname is rw;
    has Salary         $.salary  is rw;

    method gist {
        return qq:to[END];
        Name:    $.name
        Surname: $.surname
        Salary:  $.salary
        END
    }
}
my $employee = Employee.new();

given $employee {
    .name    = 'Sally';
    .surname = 'Ride';
    .salary  = 200;
}

say $employee;

# Output:
# Name:    Sally
# Surname: Ride
# Salary:  200
```
