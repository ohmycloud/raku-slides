Day 21 – transliteration and beyond By   Carl


转换听起来像拉丁词根,意味着字母的变化。这就是 Str.trans 方法所做的。
say "GATTACA".trans( "TCAG" => "0123" );  # prints "3200212\n"

使用过Perl5 的人马上意识到这就是 tr/tcag/0123/ .

 下面是一个例子，使用 ROT-13算法加密文本：
sub rot13($text) { $text.trans( "A..Za..z" => "N..ZA..Mn..za..m" ) }

当 .trans  方法看到那些  ..  区间时，它会在内部将那些字母展开 (所以  "n..z"  意思是  "nopqrstuvwxyz" ).  因此,rot13子例程的最终效果是将ASCII字母表的特定部分映射到其他部分。

在 Perl5 中，两个点跟一个破折号相同，但是在Perl6 中我们让那两个点 .. 代表 范围的概念，在主程序中，在正则中，还有在这里，转换。

要注意的是， .trans 方法是不会改变原来的字符串； 它不会噶边 $text ,而是返回一个新的值。这在Perl6中也是一个通用的旋律。要改变原值，请使用   .= trans
$kabbala.=trans("A..Ia..i" => "1..91..9");

(并且，它不仅仅适用于 .trans 方法，它对所有方法都适用。)

当Perl 6 就是 Perl 6，.trans 方法包含了一个秘密武器：

假如我们想转义一些HTML，即，根据下面这个表来替换东西：
    & => &amp;
    < => &lt;
    > => &gt;

但是我们不想关心替换还要按顺序进行：
    foo         => bar
    foolishness => folly

在上面的例子中，如果前面的替换先发生，就不回有后面的替换出现了---这可能不是你想要的。通常，我们想在短的子串之前，尝试并匹配最长的子串。

所以，这看起来我们需要一个最长记号的替换匹配，以避免因为偶然的重复替换而产生的无限循环。

那就是 Perl 6 的 .trans 方法所提供的。这就是它的秘密武器：嵌入两个数组而非字符串. 对于HTML转义，我们所需要的就是：
my $escaped = $html .trans (
    [ '&',     '<',    '>'    ] =>
    [ '&amp;', '&lt;', '&gt;' ]
);

替换的顺序问题和避免循环就不用我们关心了。

来源： < http://perl6advent.wordpress.com/2010/12/21/day-21-transliteration-and-beyond/ >  