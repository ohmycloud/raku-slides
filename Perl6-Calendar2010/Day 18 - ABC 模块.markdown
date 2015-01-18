2010 年 Perl6 圣诞月历(十八) ABC 模块

今天不再和大家专注于 Perl6 的某个特性，而是带大家一起浏览一下 ABC 模块。我觉得这是一个很好的体现 Perl6 优势的例子。

ABC 标记 是一个非常简单的文本文件格式，用来支持乐谱记录。它广泛运用在传统舞蹈音乐的世界，因为它轻便而强大，甚至支持吉格舞和圆旋舞。下面是一个例子：

X:1
T:While Shepherds Watched Their Flocks
M:5/4
L:1/4
O:Green's Harbour, Newfoundland
K:A major
E|:[M:5/4] A A/B/ B2 A|B c/B/ A2 A/B/|
[M:6/4]c d/c/ B2 B2|[M:4/4] A3 E|AB AG|
FE FE|AB AG|F2 F2|E2 G2|A/G/ F/E/ DF|
[1 [M:6/4] E C/B,/ A,3 E:|[2 [M:5/4] E C/B,/ A,3|]

细节部分我就不说了——感兴趣的看 指南 吧——但是文本本身格式非常简单。第一行是曲调的信息，余下的就是曲调本身。这个例子比较复杂，因为里面内嵌的时间签名都被更改了。比如[M:6/4]。

我一直很惊讶为什么 CPAN 上没有处理 ABC 标记的模块，甚至有时候还想过自己写一个。不过 处理ABC标记 真的是一个比较复杂的过程，没多大进展就碰到问题后我放弃了。

而使用 Perl6 的 语法 ，大概只需要 60 行简单的正则 ，我就可以解析所有我感兴趣的乐谱（ABC 格式里几个更复杂的特性，比如歌词和多人音乐还没实现）了。摘一段如下：

regex basenote { <[a..g]+[A..G]> }
regex octave { "'"+ | ","+ }
regex accidental { '^' | '^^' | '_' | '__' | '=' }
regex pitch { ?  ? }

对比一下 BNF grammar for ABC ：

basenote ::= %x43 / %x44 / %x45 / %x46 / %x47 / %x41 / %x42 / %x63 / %x64 / %x65 / %x66 / %x67 / %x61 / %x62 ; CDEFGABcdefgab
octave ::= 1*"'" / 1*","
accidental ::= "^" / "^^" / "_" / "__" / "="
pitch ::= [accidental] basenote [octave]

显然，这是一个非常简单的翻译过程。

默认情况下，Perl6 语法的解析功能只提供给你一个基本的 Match 对象。但是你可以添加一个指定操作的对象，用它来处理信息，就好像是通过语法解析的一样。比如下面的例子：

method rest($/) {
    make ABC::Rest.new(~$<rest_type>,
                       $<note_length>.ast);
}

不管 rest 方法成不成，它都返回一个 ABC::Rest 对象。这个对象的构造器通过 rest_type 表达式检查字符串。然后还有一个 ABC::Duration 对象，经过 note_length 的动作后创建出来。

说到 duration （持续时间），Perl6 的一个特性让这块变得很容易。duration 是一个精确的有理数类型。如果没有这个特性的话，我们就得自己手敲上一堆代码来实现类似的东西，以处理这些无法用浮点数表达的时间了。

目前，还只有一个签名应用使用了这个工具 —— ABC 模块里带的 abc2ly.pl 脚本。这个脚本可以转换 ABC 格式为 Lilypond 格式。Lilypond 是一个开源的强大的音乐记谱系统，可以输出非常漂亮的谱子。这样就可以从 ABC 格式输出美观的乐谱了。（ Lilypond 源码包附带有一个 abc2ly ，但是好像不能用。我的 abc2ly.pl 也已经足够好用了，2011年我用它输出了一整本书）结束前，真的很高兴给大家带来上面 那首乐谱的 pdf ，它就是用 Rakudo 和 Lilypond 工具处理生成的。

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2010/%E7%AC%AC%E5%8D%81%E5%85%AB%E5%A4%A9:ABC%E6%A8%A1%E5%9D%97.markdown >  