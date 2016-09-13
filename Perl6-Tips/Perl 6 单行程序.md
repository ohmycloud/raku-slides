# [Perl 6 单行程序](https://github.com/dnmfarrell/Perl6-One-Liners)

这本书在进行之中。我希望你能觉得它有趣，甚至可能有用！如果你想贡献反馈的话，那么很欢迎提问题还有新的或有提升的正则表达式。

## 作者

戴维法瑞尔 [PerlTricks.com](PerlTricks.com)

## 版本

版本 0.01

## 许可

FreeBSD

## 贡献者

- Alexander Moquin
- Bruce Gray
- Carl Mäsak
- David H. Adler
- FROGGS
- Helmut Wollmersdorfer
- japhb
- Larry Wall
- Matt Oates
- Moritz Lenz
- Mouq
- Salve J Nilsen
- Sam S
- Skids
- timotimo

## 致谢

启发于 Peteris Krumins 的 Perl 5 example [文件](http://www.catonmat.net/download/perl1line.txt)。他逐字逐句地写了一本关于 Perl 5 单行 的[书](http://www.nostarch.com/perloneliners)。

[irc](http://webchat.freenode.net/?channels=perl6&nick=)上有很好地 folks。

## 内容

1. 介绍
2. 教程
3. 文件间距
4. 行号
5. 计算
6. 创建字符串和创建数组
7. 文本转换和替换
8. 文本分析
9. 选择性的行打印
10. 使用管道转换数据(进行中)
11. WWW(进行中)
12. 转换到 Windows

### 介绍

把 Perl 和其它语言区别开的一件事情是在单行代码中写小程序的能力，即人们所熟知的"单行"。在终端里直接键入一个程序比写一个废弃的脚本往往更快。并且单行程序也很强大；它们是羽翼丰满的程序，能够加载外部库，但是也能集成到终端中。你可以在单行程序中输入或输出数据。

像 Perl 5 一样， Perl 6支持单行程序。还有就像 Perl 6 到处清理着 Perl 5 的毒瘤一样，Perl 6 的单行语法也更好了。它拥有更少的特殊变量和选项因此更容易记忆。这本书提供了很多有用的 Perl 6 单行例子，从找出文件中得重复行到运行一个 web 服务器，它几乎能做所有事情。尽管 Perl 6 拥有更少的特殊变量，但是由于它高级的面向对象的语法，Perl 6 中的大部分单行程序比等价的 Perl 5 单行程序更短。

这本书可以以多种方式阅读。如果你是单行程序的新手，从教程开始。它带领你掌握单行程序的核心概念；不要担心，一旦你理解了它会很容易。如果你精通 Perl，Bash，或 Sed/Awk，你可以立马开始工作。随意跳过和浏览你所感兴趣的东西。如果有些代码你不理解，那么在终端中试试！这个仓库中包含的无处不在的文件是 example.txt，它会在很多单行程序中用到。

使用单行编程仅仅是 Perl 6 擅长的一个范例。这样的代码小而美，但是同时你正学习的是一种生产力技能，记住你正在学的是一种新的编程语言。检查 [perl6.org](perl6.org)网站获取官方文档。

### 教程

要开始单行程序，所有你要掌握的是 **-e** 选项。这告诉 Perl 把它后面所跟的东西作为一个程序去执行。例如：

```perl6
perl6 -e 'say "Hello, World!"'
```

我们来一步步剖析这段代码。 `perl6` 引用了 Perl 6 程序， `-e` 告诉 Perl 6 去执行，而 `'say "Hello, World!"'`是要执行的程序。每个程序都必须被包围在单引号中（除了在 Windows 上，查看 [转换到 Windows](https://github.com/dnmfarrell/Perl6-One-Liners#converting-for-windows)）。要运行单行程序，就把它键入到终端中好了：

```Bash
> perl6 -e 'say "Hello, World!"'
Hello, World!
```

如果你想加载一个文件，就把文件路径添加到程序代码的后面：

```Bash
perl6 -e 'for (lines) {say $_}' /path/to/file.txt
```

这个程序打印出了 `path/to/file.txt` 的每一行。你可能知道 `$_` 是默认变量，它在这儿是指正被循环的当前行。`lines` 是一个列表，当你传递一个文件路径给单行程序的时候会自动为你创建这个列表。现在我们来重写那个单行程序，一步一步。它们都是等价的：

```Bash
perl6 -e 'for (lines) { say $_ }' /path/to/file.txt
perl6 -e 'for (lines) { $_.say }' /path/to/file.txt
perl6 -e 'for (lines) { .say }' /path/to/file.txt
perl6 -e '.say for (lines)' /path/to/file.txt
perl6 -e '.say for lines' /path/to/file.txt
```

就像 `$_` 是默认变量一样，在默认变量身上调用的方法可以省略掉变量引用。它们变成了默认方法。所以 `$_.say` 变成 `.say`。回报给写单行程序的人的东西是 - 更少的键入！

`-n` 选项改变了程序的行为：它为文件中的每一行执行一次代码。所以，大写并打印 `path/to/file.txt` 的每一行你会键入：

```Bash
perl6 -ne '.uc.say' /path/to/file.txt
``` 

`-p` 选项就像 `-n`, 除了它会自动打印 `$_` 之外。所以大写文件中的所有行的另外一种方法是：

```Bash
perl6 -pe '$_ = .uc' /path/to/file.txt
```

或者两个做同样事情的更短的版本：

```Bash
perl6 -pe '.=uc' /path/to/file.txt
perl6 -pe .=uc   /path/to/file.txt
```

在第二个例子中，我们可以完全移除周围的单引号。这种场景很少遇到，但是如果你的单行程序中没有空格并且没有符号或引号，那么你通常可以移除外部的引号。

`-n` 和 `-p` 选项真的很有用。本书中也有很多使用它们的单行例子。

最后一件你要知道的事情是怎么加载模块。 `-M` 开关代表着加载模块：

```Bash
perl6 -M URI::Encode -e 'say encode_uri("example.com/10 ways to crush it with Perl 6")'
```

`-M URI::Encode` 加载了 `URI::Encode` 模块，它导入了 *encode_uri* 子例程。 你可以多次使用 `-M` 来加载多个模块：

```Bash
perl6 -M URI::Encode -M URI -e '<your code here>'
```

如果你有一个还没有安装的本地模块呢？ 简单， 仅仅传递一个 `-I` 开关来包含那个目录好了：

```Bash
perl6 -I lib -M URI::Encode -e '<your code here>'
```

现在 Perl 6 会在 `lib` 目录中搜索 `URI::Encode` 模块，和标准的安装位置一样。

要查看 Perl 6 命令行开关有哪些， 使用 `-h` 选项查看帮助：

```Bash
perl6 -h
```

这打印可获得的不错的统计。

### 文件间距

Double space a file

```Bash
perl6 -pe '$_ ~= "\n"' example.txt
```

N-space a file (例如. 4倍空白)

```Bash
perl6 -pe '$_ ~= "\n" x 4' example.txt
```

在每一行前面添加一个空行：

```Bash
perl6 -pe 'say ""' example.txt
```

移除所有空行：

```perl6
perl6 -ne '.say if /\S/'   example.txt
perl6 -ne '.say if .chars' example.txt
```

移除所有的连续空白行，只保留一行：

```Bash
perl6 -e '$*ARGFILES.slurp.subst(/\n+/, "\n\n", :g).say' example.txt
```

### 行号

给文件中的所有行编号：

```Bash
perl6 -ne 'say "{++$} $_"' example.txt
perl6 -ne 'say $*ARGFILES.ins ~ " $_ "' example.txt
```

只给文件中得非空行编号：

```Bash
perl6 -pe '$_ = "{++$} $_" if /\S/' example.txt
```

给所有行编号但是只打印非空行：

```Bash
perl6 -pe '$_ = $*ARGFILES.ins ~ " $_ " if /\S/' example.txt
```

打印文件中行数的总数：

```Bash
perl6 -e 'say lines.elems' example.txt
perl6 -e 'say lines.Int'   example.txt
perl6 -e 'lines.Int.say'   example.txt
```
打印出文件中非空行的总数：

```Bash
perl6 -e 'lines.grep(/\S/.elems.say)' example.txt
```

打印文件中空行的数量：

```Bash
perl6 -e 'lines.grep(/^\s*$/).elems.say' example.txt
```

### 计算

检查一个数是否是质数：

```Bash
perl6 -e 'say "7 is prime" if 7.is-prime'
```

打印一行中所有字段的和：

```Bash
perl6 -ne 'say [+] .split("\t")'
```

打印所有行的所有字段的和：

```Bash
perl6 -e 'say [+] lines.split("\t")'
```

打乱行中的所有字段：

```Bash
perl6 -ne '.split("\t").pick(*).join("\t").say'
```

找出一行中最小的元素：

```Bash
perl6 -ne '.split("\t").min.say'
```

找出所有行的最小的元素：

```Bash
perl6 -e 'lines.split("\t").min.say'
```

找出一行中最大的元素：

```Bash
perl6 -ne '.split("\t").max.say'
```

找出所有行的最大的元素：

```Bash
perl6 -e 'lines.split("\t").max.say'
```


找出一行中得数值化最小元素：

```Bash
perl6 -ne '.split("\t")».Numeric.min.say'
```

找出一行中得数值化最大元素：

```Bash
perl6 -ne '.split("\t")».Numeric.max.say'
```

使用字段的绝对值替换每个字段：

```Bash
perl6 -ne '.split("\t").map(*.abs).join("\t")'
```

找出每行中字符的总数：

```Bash
perl6 -ne '.chars.say' example.txt
```

找出每行中单词的总数：

```Bash
perl6 -ne '.words.elems.say' example.txt
```

找出每行中由逗号分隔的元素的总数：

```Bash
perl6 -ne '.split(",").elems.say' example.txt
```

找出所有行的字段（单词）的总数：

```Bash
perl6 -e 'say lines.split("\t").elems' example.txt  # fields
perl6 -e 'say lines.words.elems' example.txt        # words
```

打印匹配某个模式的字段的总数：

```Bash
perl6 -e 'say lines.split("\t").comb(/pattern/).elems' example.txt # fields
perl6 -e 'say lines.words.comb(/pattern/).elems' example.txt       # words
```

打印匹配某个模式的行的总数：

```Bash
perl6 -e 'say lines.grep(/in/.elems)' example.txt
```

打印数字 PI 到 n 位小数点(例如. 10位)：

```Bash
perl6 -e 'say pi.fmt("%.10f");'
```

打印数字 PI 到 15 位小数点：

```Bash
perl6 -e 'say π'
```

打印数字 E 到 n 位小数点(例如. 10位)：

```Bash
perl6 -e 'say e.fmt("%.10f");'
```

打印数字 E 到 15 位小数点：

```Bash
perl6 -e 'say e'
```

打印 UNIX 时间 (seconds since Jan 1, 1970, 00:00:00 UTC)

```Bash
perl6 -e 'say time'
```

打印 GMT (格林威治标准时间)和地方计算机时间：

```Bash
perl6 -MDateTime::TimeZone -e 'say to-timezone("GMT",DateTime.now)'
perl6 -e 'say DateTime.now'
```

以 H:M:S 格式打印当地计算机时间：

```Bash
perl6 -e 'say DateTime.now.map({$_.hour, $_.minute, $_.second.round}).join(":")'
```

打印昨天的日期：

```Bash
perl6 -e 'say DateTime.now.earlier(:1day)'
```

打印日期： 14 个月, 9 天，和 7 秒之前

```Bash
perl6 -e 'say DateTime.now.earlier(:14months).earlier(:9days).earlier(:7seconds)'
```


在标准输出前加上时间戳（GMT，地方时间）：

```Bash
tail -f logfile | perl6 -MDateTime::TimeZone -ne 'say to-timezone("GMT",DateTime.now) ~ "\t$_"'
tail -f logfile | perl6 -ne 'say DateTime.now ~ "\t$_"'
```

计算 5 的阶乘：

```Bash
perl6 -e 'say [*] 1..5'
```

计算最大公约数：

```Bash
perl6 -e 'say [gcd] @list_of_numbers'
```


使用欧几里得算法计算数字 20 和 35 的最大公约数：

```Bash
perl6 -e 'say (20, 35, *%* ... 0)[*-2]'
```


计算 20 和 35 的最小公倍数：

```Bash
perl6 -e 'say 20 lcm 35'
```


使用欧几里得算法: n*m/gcd(n,m) 计算数字 20 和 35 的最小公倍数：

```Bash
perl6 -e 'say 20 * 35 / (20 gcd 35)'
```

生成 10 个 5 到 15（不包括 15）之间的随机数：

```Bash
perl6 -e '.say for (5..^15).roll(10)'
```

找出并打印列表的全排列：

```Bash
perl6 -e 'say .join for [1..5].permutations'
```

生成幂集

```Bash
perl6 -e '.say for <1 2 3>.combinations'
```


把 IP 地址转换为无符号整数：

```Bash
perl6 -e 'say :256["127.0.0.1".comb(/\d+/)]'
perl6 -e 'say +":256[{q/127.0.0.1/.subst(:g,/\./,q/,/)}]"'
perl6 -e 'say Buf.new(+«"127.0.0.1".split(".")).unpack("N")'
```

把无符号整数转换为 IP 地址：

```Bash
perl6 -e 'say join ".", @(pack "N", 2130706433)'
perl6 -e 'say join ".", map { ((2130706433+>(8*$_))+&0xFF) }, (3...0)'
```

### 创建字符串和创建数组


生成并打印字母表：

```Bash
perl6 -e '.say for "a".."z"'
```

生成并打印所有从 "a" 到 "zz" 的字符串：

```Bash
perl6 -e '.say for "a".."zz"'
```


把整数转换为十六进制：

```Bash
perl6 -e 'say 255.base(16)'
perl6 -e 'say sprintf("%x", 255)'
```

把整数打印为十六进制转换表：

```Bash
perl6 -e 'say sprintf("%3i => %2x", $_, $_) for 0..255'
```


把整数编码为百分数：

```Bash
perl6 -e 'say sprintf("%%%x", 255)'
```

生成一个随机的 10 个 a-z 字符长度的字符串：

```Bash
perl6 -e 'print roll 10, "a".."z"'
perl6 -e 'print roll "a".."z": 10'
```

生成一个随机的 15 个 ASCII 字符长度的密码：

```Bash
perl6 -e 'print roll 15, "0".."z"'
perl6 -e 'print roll "0".."z": 15'
```

创建一个指定长度的字符串：

```Bash
perl6 -e 'print "a" x 50'
```

生成并打印从 1 到 100 数字为偶数的数组：

```Bash
perl6 -e '(1..100).grep(* %% 2).say'
```


找出字符串的长度：

```Bash
perl6 -e '"storm in a teacup".chars.say'
```


找出数组的元素个数：

```Bash
perl6 -e 'my @letters = "a".."z"; @letters.Int.say'
```

### 文本转换和替换

对文件进行 ROT 13 加密：

```Bash
perl6 -pe 'tr/A..Za..z/N..ZA..Mn..za..m/' example.txt
```

对字符串进行 Base64 编码：

```Bash
perl6 -MMIME::Base64 -ne 'print MIME::Base64.encode-str($_)' example.txt
```

对字符串进行 Base64 解码：

```Bash
perl6 -MMIME::Base64 -ne 'print MIME::Base64.decode-str($_)' base64.txt
```

对字符串进行 URL 转义：

```Bash
perl6 -MURI::Encode -le 'say uri_encode($string)'
```

URL-unescape a string

```Bash
perl6 -MURI::Encode -le 'say uri_decode($string)'
```

HTML-encode a string

```Bash
perl6 -MHTML::Entity -e 'print encode-entities($string)'
```
HTML-decode a string

```Bash
perl6 -MHTML::Entity -e 'print decode-entities($string)'
```

把所有文本转换为大写：

```Bash
perl6 -pe '.=uc'    example.txt
perl6 -ne 'say .uc' example.txt
```

把所有文本转换为小写：

```Bash
perl6 -pe '.=lc'    example.txt
perl6 -ne 'say .lc' example.txt
```

只把每行的第一个单词转换为大写：

```Bash
perl6 -ne 'say s/(\w+){}/{$0.uc}/' example.txt
```

颠倒字母的大小写：

```Bash
perl6 -pe 'tr/a..zA..Z/A..Za..z/'           example.txt
perl6 -ne 'say tr/a..zA..Z/A..Za..z/.after' example.txt
```

对每行进行驼峰式大小写：

```Bash
perl6 -ne 'say .wordcase' example.txt
```

在每行的开头去掉前置空白（空格、tabs）：

```Bash
perl6 -ne 'say .trim-leading' example.txt
```

从每行的末尾去掉结尾的空白（空格、tabs）：

```Bash
perl6 -ne 'say .trim-trailing' example.txt
```

从每行中去除行首和行尾的空白：

```Bash
perl6 -ne 'say .trim' example.txt
```

把 UNIX 换行符转换为 DOS/Windows 换行符：

```Bash
perl6 -ne 'print .subst(/\n/, "\r\n")' example.txt
```

把 DOS/Windows  换行符转换为 UNIX 换行符：

```Bash
perl6 -ne 'print .subst(/\r\n/, "\n")' example.txt
```

把每行中所有的 "ut" 实体用 "foo" 替换掉：

```Bash
perl6 -pe 's:g/ut/foo/' example.txt
```

把包含 "lorem" 的每行中所有的 "ut" 实体用 "foo" 替换掉：

```Bash
perl6 -pe 's:g/ut/foo/ if /Lorem/' example.txt
```

把文件转换为 JSON 格式：

```Bash
perl6 -M JSON::Tiny -e 'say to-json(lines)' example.txt
```

从文件的每一行中随机挑选 5 个单词：

```Bash
perl6 -ne 'say .words.pick(5)' example.txt
```

### 文本分析

Print n-grams of a string

```Bash
perl6 -e 'my $n=2; say "banana".comb.rotor($n,$n-1).map({[~] @$_})'

打印唯一的 n-grams

```Bash
perl6 -e 'my $n=2; say "banana".comb.rotor($n,$n-1).map({[~] @$_}).Set.sort'
```

打印 n-grams 的出现次数：

```Bash
perl6 -e 'my $n=2; say "banana".comb.rotor($n,$n-1).map({[~] @$_}).Bag.sort.join("\n")'
```

打印单词的出现次数(1-grams)：

```Bash
perl6 -e 'say lines[0].words.map({[~] @$_}).Bag.sort.join("\n")' example.txt
```

基于一组 1-grams 打印 Dice 相似系数：

```Bash
perl6 -e 'my $a="banana".comb;my $b="anna".comb;say ($a (&) $b)/($a.Set + $b.Set)'
```

基于 1-grams 打印卡得杰相似系数：

```Bash
perl6 -e 'my $a="banana".comb;my $b="anna".comb;say ($a (&) $b) / ($a (|) $b)'
```

基于 1-grams 打印重叠系数：

```Bash
perl6 -e 'my $a="banana".comb;my $b="anna".comb;say ($a (&) $b)/($a.Set.elems,$b.Set.elems).min'
```

基于 1-grams 打印类似的余弦：


```Bash
perl6 -e 'my $a="banana".comb;my $b="anna".comb;say ($a (&) $b)/($a.Set.elems.sqrt*$b.Set.elems.sqrt)'

# 上面的命令提示 Seq 已经被消费
perl6 -e 'my $a="banana".comb;my $b="anna".comb;say ($a.cache (&) $b.cache)/($a.cache.Set.elems.sqrt*$b.cache.Set.elems.sqrt)'
```


创建字符串中字符的索引并打印出来：

```Bash
perl6 -e 'say {}.push: %("banana".comb.pairs).invert'
```

创建一行中单词的所以并打印出来：

```Bash
perl6 -e '({}.push: %(lines[0].words.pairs).invert).sort.join("\n").say' example.txt
```

### 选择性的行打印


打印文件的第一行（模仿 head -1）：

```Bash
perl6 -ne '.say;exit'      example.txt
perl6 -e 'lines[0].say'    example.txt
perl6 -e 'lines.shift.say' example.txt
```

打印文件的前 10 行（模仿 head -10）

```Bash
perl6 -pe 'exit if ++$ > 10' example.txt
perl6 -ne '.say if ++$ < 11' example.txt
```

打印文件的最后一行（模仿 tail -1）：

```Bash
perl6 -e 'lines.pop.say' example.txt
```

打印文件的最后 5 行（模仿 tail -5）：

```Bash
perl6 -e '.say for lines[*-5..*]' example.txt
```

只打印包含元音的行：

```Bash
perl6 -ne '/<[aeiou]>/ && .print' example.txt
```

打印包含所有元音的行：

```Bash
perl6 -ne '.say if .comb (>=) <a e i o u>' example.txt
perl6 -ne '.say if .comb ⊇ <a e i o u>'    example.txt
```

打印字符数大于或等于 80 的行：

```Bash
perl6 -ne '.print if .chars >= 80' example.txt
perl6 -ne '.chars >= 80 && .print' example.txt
```

只打印第二行：


```Bash
perl6 -ne '.print if ++$ == 2' example.txt
```

打印除了第二行的所有行：

```Bash
perl6 -pe 'next if ++$ == 2' example.txt
```

打印第一行到第三行之间的所有行：

```Bash
perl6 -ne '.print if (1..3).any == ++$' example.txt
```

打印两个正则表达式之间（包含匹配那个正则表达式的行）的所有行：

```Bash
perl6 -ne '.print if /^Lorem/../laborum\.$/' example.txt
```

打印最长的行的长度：

```Bash
perl6 -e 'say lines.max.chars' example.txt
perl6 -ne 'state $l=0; $l = .chars if .chars > $l;END { $l.say }' example.txt
```

打印长度最长的行：

```Bash
perl6 -e 'say lines.max' example.txt
perl6 -e 'my $l=""; for (lines) {$l = $_ if .chars > $l.chars};END { $l.say }' example.txt
```

打印包含数字的所有行：

```Bash
perl6 -ne '.say if /\d/'             example.txt
perl6 -e '.say for lines.grep(/\d/)' example.txt
perl6 -ne '/\d/ && .say'             example.txt
perl6 -pe 'next if ! $_.match(/\d/)' example.txt
```

打印只包含数字的所有行：

```Bash
perl6 -ne '.say if /^\d+$/'             example.txt
perl6 -e '.say for lines.grep(/^\d+$/)' example.txt
perl6 -ne '/^\d+$/ && .say'             example.txt
perl6 -pe 'next if ! $_.match(/^\d+$/)' example.txt
```

打印每个奇数行：

```Bash
perl6 -ne '.say if ++$ % 2' example.txt
```

打印每个偶数行：

```Bash
perl6 -ne '.say if ! (++$ % 2)' example.txt
```

打印所有重复的行：

```Bash
perl6 -ne 'state %l;.say if ++%l{$_}==2' example.txt
```


打印唯一的行：

```Bash
perl6 -ne 'state %l;.say if ++%l{$_}==1' example.txt
```

打印每一行中的第一个字段（单词）（模仿 cut -f 1 -d ' '）

```Bash
perl6 -ne '.words[0].say' example.txt
```

### 使用管道转换数据


Perl 6程序直接集成到了命令行中。你可以使用 | 管道符号从单行程序中输出数据和输入数据到单行程序中。为了 从管道中输入数据， Perl 6 自动地把 STDIN 设置为 `$*IN`。就像对文件那样，从管道输入的数据在单行中也能使用 `-n` 来进行循环迭代。从单行程序中输出数据就使用 print 或 say 好了。

在当前目录中对所有文件进行 JSON 编码：

```Bash
ls | perl6 -M JSON::Tiny -e 'say to-json(lines)'
```

打印文件中的大约 5% 的随机样本行：

```Bash
perl6 -ne '.say if 1.rand <= 0.05' /usr/share/dict/words
```

颜色转换， 从 HTML 到 RGB

```Bash
echo "#ffff00" | perl6 -ne '.comb(/\w\w/).map({:16($_)}).say'
```

颜色转换， 从 RGB 到 HTML

```Bash
echo "#ffff00" | perl6 -ne '.comb(/\w\w/).map({:16($_)}).say'
```

### WWW

下载一个页面：

```Bash
perl6 -M HTTP::UserAgent -e 'say HTTP::UserAgent.new.get("google.com").content'
```

下载一个页面并剥离 HTML：

```Bash
wget -O - "http://perl6.org" | perl6 -ne 's:g/\<.+?\>//.say'
```


下载一个页面并剥离并解码 HTML：

```Bash
wget -O - "http://perl6.org" | perl6 -MHTML::Strip -ne 'strip_html($_).say'
```


开启一个简单地 web 服务器：

```Bash
perl6 -M HTTP::Server::Simple -e 'HTTP::Server::Simple.new.run'
```

### 转换到 Windows

一旦你知道了里面的门道之后那么在 Windows 上运行单行程序就是小草一碟。单行程序既可以在 cmd.exe 中运行，又可以在 Powershell 中运行。主要的规则是：用双引号替换掉外部的单引号，在单行程序的内部使用插值引用操作符 `qq//` 来把字符串括起来。对于非插值的引起，你可以使用单引号。我们来看几个例子。

这儿有一个打印时间的单行程序：

```Bash
perl6 -e 'say DateTime.now'
```
要在 Windows 上运行，我们仅仅用双引号替换掉单引号好了：

```Bash
perl6 -e "say DateTime.now"
```

这个单行程序给文件中每一行添加了一个换行符，使用了插值字符串：

```Bash
perl6 -pe '$_ ~= "\n"' example.txt
```

在 Windows 上这应该写为：

```Bash
perl6 -pe "$_ ~= qq/\n/" example.txt
```

这种情况下，我们想对换行符进行插值，并且不为该行字面地添加反斜线和字符"n"，所以我们必须使用 qq。但是你通常也可以像这样在单行程序中使用单引号：

```Bash
perl6 -e 'say "Hello, World!"'
```

在 Windows 上这应该写为：

```Bash
perl6 -e "say 'hello, World!'"
```

简单地输出重定向工作起来像基于 Unix 系统那样。 这个单行程序使用 `>` 把 ASCII 字符索引表打印到一个文件中：

```Bash
perl6 -e "say .chr ~ ' ' ~ $_ for 0..255" > ascii_codes.txt
```
在使用 `>` 的时候，如果文件不存在就会创建一个。如果文件确实存在，它会被重写。你可能更想追加到文件，使用 `>>` 代替。
