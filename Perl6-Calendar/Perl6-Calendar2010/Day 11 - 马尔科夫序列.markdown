2010 年 Perl6 圣诞月历(十一)马尔科夫序列

（译者注：完全不知道什么是马尔科夫链，所以翻译纯粹靠看代码……诚求数学科普）

第四天的时候，我开玩笑似的提到了有非数值型的序列。今天我就来介绍这么一个东东——基于一个对文本使用马尔科夫链的想法。我们在前两个元素的基础上，随机的定义下一个元素。下面的示例里包含了一个示例文本，以便让运行结果看起来更像一个语言模型~

use v6;
use List::Utils;
&nbsp_place_holder;
my $model-text = $*IN.slurp.lc;
$model-text .=subst(/<[_']>/, "", :global);
$model-text .=subst(/<-alpha>+/, " ", :global);
my %next-step;
for sliding-window($model-text.comb, 3) -> $a, $b, $c {
    %next-step{$a ~ $b}{$c}++;
}
my $first = $model-text.substr(0, 1);
my $second = $model-text.substr(1, 1);
my @chain := $first, $second, -> $a, $b { %next-step{$a ~ $b}.roll } ... *;
say @chain.munch(80);

在 use 语句下面，代码主要分为三部分：

第一段用来输入示例文本，并去除所有非字母的字符。首先用 slurp 读取标准输入( $*IN )到标量，然后用 lc 改写标量的内容成小写字母。接着第一个 subst 命令，把所有的下划线和单引号删除掉；第二个 subst 命令，把所有的非字母字符改成空格。

第二段用 List::Utils 模块中的 sliding-window 函数结合一点 Perl5 的哈希魔术： $modle-text.comb 分割内容成一个个独立的字符串； sliding-window() 函数遍历列表，并且返回从第一个被读取元素开始往后总共 N 个元素（本例中为 3 个），意思就是说：第一次获得第 1、2、3 个元素，第二次是 2、3、4，……

在循环中，我们构建一个哈希结构。这个哈希的外层键为每次的三个连续字母的前两个，内层键为第三个字母，值为该字母出现在前两个字母后面的次数。比如说，在我导入一篇 Aqualong 的歌词后，这个 %next-step{“qu”} 看起来就是这样子的了：
{"a" => 5, "e" => 2}

也就是说，文中有 q 和 u 的话，那么后面有 5次出现了 a（比如 Aqualong），2次出现了 e（比如 question、requests）。

第三段用我们已经说过的知识来构建序列。首先从示例文本里获取最开头的两个元素，然后用 ->$a,$b{%next-step{$a~$b}.roll} 生成第三个元素。这个 roll 的方法，就是通过哈希的值做权重，决定随即返回哪个（比如上例中，如果 roll 7 次，那么5 次返回 a，2 次返回 e ）。如果前面两个元素组成的键没有对应的值，就返回一个 undef，结束序列的构建。

最后，用 mutch 方法获取序列的前 80 个元素，即便序列过早结束，也不会出什么异常。

对 Aqualong 的歌词运行这个脚本最终得到如下序列：
t carealven thead you he sing i withe and upon a put saves pinsest to laboonfeet” and “t steall gets sill a creat ren ther he crokin whymn the gook sh an arlieves grac

（因为歌词文件的开头是一些 ASCII 码，被替换到最后就是一个 t 了~）

注意：这个脚本会自己猜测字符的编码，但凡是可以被 perl6 认作是字母的，它都处理。所以如果你用标准的 “Land derBerge” 文件做输入，得到的就是 'laß in ber bist brüften las schören zeites öst froher landder äckerzeichöne lan' （好吧，先祈祷你的浏览器支持这种文字~~）。

然后还有警告一声：在我写这篇文章的时候，Perl6 频道里正在反思 Hash.roll 方法到底应该用来做什么。目前在 Rakudo 中的部分实现是 KeyBag.roll 。等到全部搞定的时候，如果和规范上有差距，可能会替换掉 KeyBag。

而且，现在你也可以选择另一个运行方法。把 %next-step{$a ~ $b}{$c}++ 改成 %next-step.push($a ~ $b, $c) ， %next-step 会构建成数组的哈希。每个数组都列出所有跟在前两个元素后面的字母，一个字母出现过多少回，它在数组里就会重复多少次。这样在序列上用 roll 的时候，一样可以达到权重的目的。

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2010/%E7%AC%AC%E5%8D%81%E4%B8%80%E5%A4%A9:%E9%A9%AC%E5%B0%94%E7%A7%91%E5%A4%AB%E5%BA%8F%E5%88%97.markdown >  