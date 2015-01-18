Day 22 – Parsing an IPv4 address December 22, 2012


Guest post by Herbert Breunung (lichtkind).




Perl6 的正则现在是一种子语言了，很多语法没有变:
/\d+/

捕获数字：
/(\d+)/

现在 $0 存储着匹配到的数字，而不是 Perl 5 中的 $1. 所有的特殊变量 $0,$1,$2 在 Perl6 里就是 $/[0] ,  $/[1] ,  $/[2] . 在Perl 5 中，$0 是脚本或程序的文件名，但是这在 Perl6 中变成了 $*EXECUTABLE_NAME .

Should you be interested in getting all of the captured groups of a regex match, you can use  @() , which is syntactic sugar for  @($/) .

The object in the  $/  variable holds lots of useful information about the last match. For example,  $/.from  will give you the starting string position of the match.

But  $0  will get us far enough for this post. We use it to extract individual features from a string.

修饰符现在放在前面了:
$_ = '1 23 456 78.9';
say .Str for m:g/(\d+)/; # 1 23 456 78 9

匹配所有看起来像这样的东西很有用，以至于它有一个专门的 .comb 方法：
$str.comb(/\d+/);


如果你对  .split很熟悉，你可以想到 .comb 就是它的表哥，它匹配  .split丢弃的东西 。 

Perl 5 中匹配 IPv4地址的正则如下:
/(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/

这在 Perl6中是无效的。首先，{} 块在 Perl 6 的 正则中是真正的代码块；它们包含 Perl6 代码。第二，在 Perl 6 中请使用     ** N..M (或 ** N..*)  代替  {N,M}

在PERL

在 Perl 6 中匹配1到3位数字的正则如下:
/\d ** 1..3/

匹配 Ipv4地址：
/(\d**1..3) \. (\d**1..3) \. (\d**1..3) \. (\d**1..3)/

那仍有点笨拙。在Perl6的正则中，你可以使用 重复操作符 %  ，下面是重复 (\d ** 1..3) 这个正则 4次，并使用 . 点号 作为分隔符。
/ (\d ** 1..3) ** 4 % '.' /

% 操作符是一个量词修饰符，所以它只跟在一个像 * 或 + 或 ** 的量词后面。 上面的正则意思是 匹配 4 组数字，在每组数字间插入一个直接量 点号 .

你也可能注意到 \. 变成了 '.' ,它们是一样的。
$_ = "Go 127.0.0.1, I said! He went to 173.194.32.32.";
 
say .Str for m:g/ (\d ** 1..3) ** 4 % '.' /;
# output: 127.0.0.1 173.194.32.32

或者我们可以使用  .comb :
$_ = "Go 127.0.0.1, I said! He went to 173.194.32.32.";
my @ip4addrs = .comb(/ (\d ** 1..3) ** 4 % '.' /);   #  127.0.0.1 173.194.32.32

如果我们对单独的数字感兴趣：
$_ = "Go 127.0.0.1, I said! He went to 173.194.32.32.";
say .list>>.Str.perl for m:g/ (\d ** 1..3) ** 4 % '.' /;
# output: ("127", "0", "0", "1") ("173", "194", "32", "32")