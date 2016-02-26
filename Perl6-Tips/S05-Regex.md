title: S05-Regex
date: 2015-08-01 18:59:10
tags: Perl6
categories: Perl 6
---
<blockquote class="blockquote-center">这特么谁翻译的, 简直是屎, 简直不忍卒读</blockquote>



# 标题


Synopsis 5: Regexes and Rules


# 版本



```
    Created: 24 Jun 2002

    Last Modified: 12 May 2015
    Version: 180
```

不论何时, 在 `grammar` 中引用递归模式时, 通常更偏好使用 `token` 和 `rule`, 而不是 `regex`.


# 概览


作为常规表达式记法的扩展, Perl 6 原生地实现了 `Parsing Expression Grammars`(PEGs). PEGs 要求你为有歧义的那部分提供一个 `主从秩序`.  Perl 6 的 `主从秩序` 由一个多级的平局择优法测试决定:



```
    1) Most-derived only/proto hides less-derived of the same name
    2) 最长 token 匹配: food\s+ beats foo by 2 or more positions
    3) 最长字面值前缀: food\w* beats foo\w* by 1 position
    4) 对于一个给定的 proto, multis from a more-derived grammar win
    5) 在一个给定的编译单元中, 出现较早的备选分支或 multi 胜出.
```

`#3` 会把任何初始的字面序列当作最长字面值前缀. 如果在最长 token 匹配中有一个嵌入的备选分支, 那些备选分支会扩展字面值前缀,   把备选分支也作为字面值的一部分. 如果所有的备选分支都是字面值的, 那么字面值也能延伸到备选分支的末尾, 当它们重新聚合时.  否则,  备选分支的末尾会终止所有的最长字面值前缀, 即使分支全部是字面值的.  例如:

```
    / a [ 1 | 2 ] b /   # 最长字面值是 'a1b' 和 'a2b'
    / a [ 1 | 2\w ] b / # 最长文字是'a1 和 'a2', \w 不是字面值
    / a <[ 1 2 ]> b /   # 最长字面值是 'a'
```



注意, 这种情况下, 字符类和备选分支被不同地对待. 在字符类中包含一个最长的字面字符串太普遍了.

就像最长 token 匹配一样, 最长字面值前缀贯穿于 subrules 中. 如果 subrule 是一个 protoregex, 它会被看作带有 `|` 的备选分支, 后面跟着扩展或终止最长字面值前缀的同一个 rules.

除了这个主从秩序以外, 如果任何 rule 选择于主从秩序回溯之下, 那么选择下一个最好的 rule.  即, 主从秩序决定了候选者列表; 正是因为选择一个候选者并不意味着放弃其它候选者. 然而,  能通过一个恰当的回溯控制显式地放弃其它候选者(有时叫它 `cut` 操作符, 但是  Perl 6 有多个 cut , 取决于你想切掉多少)

还有, 任何在 `#1` 下被选中执行的 rule  可以选择委托给它的祖先来执行; PEG 不对此回溯.



# 新的匹配结果和捕获变量


附属的匹配对象现在可通过 `$/` 变量获取, 它隐式是词法作用域的. 通过这个变量来访问最近一次的匹配.  单独的捕获变量(例如 `$0`, `$1`等) 正是 `$/` 中的元素.

顺便说一下, 不像 Perl 5, Perl 6 中的捕获变量现在从 `$0` 开始编号而不是 `$1`. 查看下面.

为了检测 Perl 5的不相关的 `$/` 变量的意外使用, Perl 6的 `$/` 变量不能被直接赋值.

``` perl

    $/ = $x;   # 不支持使用  $/ 变量作为输入记录分隔符 (input record separator)
    $/ := $x;  # OK, 绑定
    $/ RR= $x; # OK, 元操作符
    ($/) = $x; # OK, 列表赋值
```



# 没变的语法特性

下面的正则特性语法和 Perl 5 是一样的:



- 捕获: `(…)`

[`S05-mass/rx.t lines 100–247`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L100-L247)

- 重复量词: `*`, `+`, 和  `?`


- 备选分支: `|`


- 反斜线转义: `\`


- 最少匹配后缀: `??`, `*?`, `+?`



虽然 `|` 的语法没有变, 但是默认的语义稍微改变了一点.  我们试图混合一个令人满意的描述性的和程序上的匹配, 以至于我们能拥有其中两者. 简言之, 你不用给 grammar 写你自己的 `tokener`了, 因为 Perl 会帮你写好. 查看下面的 `Longest-token` 匹配.

[`S05-metasyntax/longest-alternative.t lines 6–52`](https://github.com/perl6/roast/blob/master/S05-metasyntax/longest-alternative.t#L6-L52)


```
use v6;
use Test;

plan 53;

#L<S05/Unchanged syntactic features/"While the syntax of | does not change">

my $str = 'a' x 7;

{
    ok $str ~~ m:c(0)/a|aa|aaaa/, 'basic sanity with |';
    is ~$/, 'aaaa', 'Longest alternative wins 1';

    ok $str ~~ m:c(4)/a|aa|aaaa/, 'Second match still works';
    is ~$/, 'aa',   'Longest alternative wins 2';

    ok $str ~~ m:c(6)/a|aa|aaaa/, 'Third match still works';
    is ~$/, 'a',    'Only one alternative left';

    ok $str !~~ m:c(7)/a|aa|aaaa/, 'No fourth match';
}

# now test with different order in the regex - it shouldn't matter at all

#?niecza skip 'Regex modifier g not yet implemented'
{
    ok $str ~~ m:c/aa|a|aaaa/, 'basic sanity with |, different order';
    is ~$/, 'aaaa', 'Longest alternative wins 1, different order';

    ok $str ~~ m:c/aa|a|aaaa/, 'Second match still works, different order'; # c -> 从上次匹配结束的位置匹配继续匹配
    is ~$/, 'aa',   'Longest alternative wins 2, different order';

    ok $str ~~ m:c/aa|a|aaaa/, 'Third match still works, different order';
    is ~$/, 'a',    'Only one alternative left, different order';

    ok $str !~~ m:c/aa|a|aaaa/, 'No fourth match, different order';
}

{
    my @list = <a aa aaaa>;
    ok $str ~~ m/ @list /, 'basic sanity with interpolated arrays';
    is ~$/, 'aaaa', 'Longest alternative wins 1';

    ok $str ~~ m:c(4)/ @list /, 'Second match still works';
    is ~$/, 'aa',   'Longest alternative wins 2';

    ok $str ~~ m:c(6)/ @list /, 'Third match still works';
    is ~$/, 'a',    'Only one alternative left';

    ok $str !~~ m:c(7)/ @list /, 'No fourth match';
}
```

# 简化的模式词法解析


不像传统的正则表达式那样, Perl 6 不要求你记住数量众多的元字符.  相反, Perl 6 通过一个简单的 `rule` 将字符进行了分类. 在正则表达式中, 所有根字符为下划线(`_`)或拥有一个以 `L`(例如, 字母) 或 `N`(例如, 数字)开头的Unicode 类别的字形(字素) 总是字面的.(例如, 自己和自己匹配的).  它们必须使用 `\` 转义以使它们变成元语法的(这时单个字母数字字符本身是元语法的, 但是任何在字母数字后面紧紧跟随的字符不是).

所有其它的字形 — 包括空白符 — 正好与此相反:它们总是被认为是元语法的.(例如, 自身和自身不匹配),  必须被转义或引用以使它们变为字面值. 按照传统, 它们可以使用 `\` 单独转义, 但是在 Perl 6中,  它们也能像下面这样被括起来.

把一个或多个任意类型的字形序列放在单引号中能使它们变为字面值.(如果使用和当前语言相同的插值语义, 双引号也是允许的 )  引号创建了一个能量化的原子,  所以,

[`S05-metasyntax/single-quotes.t lines 16–27`](https://github.com/perl6/roast/blob/master/S05-metasyntax/single-quotes.t#L16-L27)

```
    moose*
```

量词只作用在字母 `e` 上, 并匹配 `mooseee`, 而

```
    'moose'*
```

量词作用在整个字符串上并匹配  `moosemoose`.

下面有个表格总结了这些区别:

```
                 字母数字的           非字母数字的                 混合的

 Literal glyphs   a    1    _        \*  \$  \.   \\   \'       K\-9\!
 Metasyntax      \a   \1   \_         *   $   .    \    '      \K-\9!
 Quoted glyphs   'a'  '1'  '_'       '*' '$' '.' '\\' '\''     'K-9!'
```



In other words, identifier glyphs are literal (or metasyntactic when escaped), non-identifier glyphs are metasyntactic (or literal when escaped), and single quotes make everything inside them literal.



Note, however, that not all non-identifier glyphs are currently meaningful as metasyntax in Perl 6 regexes (e.g. \1 \_- !). It is more accurate to say that all unescaped non-identifier glyphs are *potential* metasyntax, and reserved for future use. If you use such a sequence, a helpful compile-time error is issued indicating that you either need to quote the sequence or define a new operator to recognize it.

[`S05-metasyntax/unknown.t lines 6–48`](https://github.com/perl6/roast/blob/master/S05-metasyntax/unknown.t#L6-L48)



The semicolon character is specifically reserved as a non-meaningful metacharacter; if an unquoted semicolon is seen, the compiler will complain that the regex is missing its terminator.

[`S05-metasyntax/regex.t lines 73–129`](https://github.com/perl6/roast/blob/master/S05-metasyntax/regex.t#L73-L129)



# 修饰符


- `/x` 语法扩展不在需要了.. 在 Perl 6 中 `/x` 是默认的了.(事实上, 这是强制的 -- 唯一能用回旧语法的方式是使用 `:Perl5/:P5修饰符)

  [`S05-modifier/perl5_4.t lines 7–119`](https://github.com/perl6/roast/blob/master/S05-modifier/perl5_4.t#L7-L119)
  [`S05-modifier/perl5_2.t lines 7–119`](https://github.com/perl6/roast/blob/master/S05-modifier/perl5_2.t#L7-L119)
  [`S05-modifier/perl5_9.t lines 7–112`](https://github.com/perl6/roast/blob/master/S05-modifier/perl5_9.t#L7-L112)
  [`S05-modifier/perl5_1.t lines 7–119`](https://github.com/perl6/roast/blob/master/S05-modifier/perl5_1.t#L7-L119)
  [`S05-modifier/perl5_8.t lines 7–128`](https://github.com/perl6/roast/blob/master/S05-modifier/perl5_8.t#L7-L128)
  [`S05-modifier/perl5_5.t lines 7–126`](https://github.com/perl6/roast/blob/master/S05-modifier/perl5_5.t#L7-L126)
  [`S05-modifier/perl5_7.t lines 7–119`](https://github.com/perl6/roast/blob/master/S05-modifier/perl5_7.t#L7-L119)
  [`S05-modifier/perl5_6.t lines 7–130`](https://github.com/perl6/roast/blob/master/S05-modifier/perl5_6.t#L7-L130)
  [`S05-modifier/perl5_3.t lines 7–119`](https://github.com/perl6/roast/blob/master/S05-modifier/perl5_3.t#L7-L119)
  [`S05-modifier/perl5_0.t lines 9–113`](https://github.com/perl6/roast/blob/master/S05-modifier/perl5_0.t#L9-L113)

  ​

- 没有 `/s` 或 `/m` 修饰符了(变成了元字符来替代它们-看下面.)

- 没有 `/e`求值修饰符用于替换了, 相反, 使用:

  ```
       s/pattern/{ doit() }/
  ```

  或:

  ```
       s[pattern] = doit()
  ```

  代替 `/ee` 的是:

  ```
       s/pattern/{ EVAL doit() }/
  ```

  或:

  ```
       s[pattern] = doit().EVAL

  ```

  ​

- 修饰符现在作为副词放在匹配或替换的开头:

  ```
       m:g:i/\s* (\w*) \s* ,?/;

  ```

  ​

  每个修饰符必须以自己的冒号开始. 必须使用空格把模式分隔符和最后一个修饰符隔开, 如果它会被看作为前面那个修饰符的参数.(只有当下一个字符是左圆括号时才为真).

  ​

- 单字符修饰符也有更长的版本:

  ```
       :i        :ignorecase   忽略大小写
       :m        :ignoremark   忽略记号
       :g        :global       全局
       :r        :ratchet      回溯
  ```


- `:i` (或 `:ignorecase`) 修饰符在词法作用域但不是它的动态作用域中忽略大小写. 即, subrules 总是使用它们自己的大小写设置. 大小写转换的次数取决于当前上下文. 在字节和代码点模式中, 要求级别为1 的大小写转换. 在字形模式下, 需要级别为 2 的大小写转换.

  [`S05-modifier/ignorecase.t lines 24–87`](https://github.com/perl6/roast/blob/master/S05-modifier/ignorecase.t#L24-L87)


- The `:ii` (or `:samecase`) variant may be used on a substitution to change the substituted string to the same case pattern as the matched string. It implies the same pattern semantics as `:i` above, so it is not necessary to put both `:i` and `:ii`.

  [`S05-modifier/ii.t lines 8–30`](https://github.com/perl6/roast/blob/master/S05-modifier/ii.t#L8-L30)

- If the pattern is matched without the `:sigspace` modifier, case info is carried across on a character by character basis. If the right string is longer than the left one, the case of the final character is replicated. Titlecase is carried across if possible regardless of whether the resulting letter is at the beginning of a word or not; if there is no titlecase character available, the corresponding uppercase character is used. (This policy can be modified within a lexical scope by a language-dependent Unicode declaration to substitute titlecase according to the orthographic rules of the specified language.) Characters that carry no case information leave their corresponding replacement character unchanged.

- If the pattern is matched with `:sigspace`, then a slightly smarter algorithm is used which attempts to determine if there is a uniform capitalization policy over each matched word, and applies the same policy to each replacement word. If there doesn't seem to be a uniform policy on the left, the policy for each word is carried over word by word, with the last pattern word replicated if necessary. If a word does not appear to have a recognizable policy, the replacement word is translated character for character as in the non-sigspace case. Recognized policies include:

    [`S05-modifier/ii.t lines 31–75`](https://github.com/perl6/roast/blob/master/S05-modifier/ii.t#L31-L75)

  ​

```
  lc()
  uc()
  tc()
  tclc()
  tcuc()
```



In any case, only the officially matched string part of the pattern match counts, so any sort of lookahead or contextual matching is not included in the analysis.

  ​

- The `:m` (or `:ignoremark`) modifier scopes exactly like `:ignorecase` except that it ignores marks (accents and such) instead of case. It is 等价于 taking each grapheme (in both target and pattern), converting both to NFD (maximally decomposed) and then comparing the two base characters (Unicode non-mark characters) while ignoring any trailing mark characters. The mark characters are ignored only for the purpose of determining the truth of the assertion; the actual text matched includes all ignored characters, including any that follow the final base character.
  [`S05-modifier/ignoremark.t lines 14–39`](https://github.com/perl6/roast/blob/master/S05-modifier/ignoremark.t#L14-L39)

  [`S05-modifier/ignorecase-and-ignoremark.t lines 15–35`](https://github.com/perl6/roast/blob/master/S05-modifier/ignorecase-and-ignoremark.t#L15-L35)

  ​

- The `:mm` (or `:samemark`) variant may be used on a substitution to change the substituted string to the same mark/accent pattern as the matched string. It implies the same pattern semantics as `:m` above, so it is not necessary to put both `:m` and `:mm`.
  [`S05-modifier/samemark.t lines 9–39`](https://github.com/perl6/roast/blob/master/S05-modifier/samemark.t#L9-L39)

  ​

- Mark info is carried across on a character by character basis. If the right string is longer than the left one, the remaining characters are substituted without any modification. (Note that NFD/NFC distinctions are usually immaterial, since Perl encapsulates that in grapheme mode.) Under `:sigspace` the preceding rules are applied word by word.

  ​

- `:c` (或 `:continue`) 修饰符让 `pattern` 从字符串中指定的位置继续扫描  (默认为 `$/ ?? $/.to !! 0`):
  [`S05-modifier/continue.t lines 6–50`](https://github.com/perl6/roast/blob/master/S05-modifier/continue.t#L6-L50)

  ​

  ``` perl
  m:c($p)/ pattern /     # 从位置 $p 开始扫描, $p 是字符串中的位置,而非模式中的位置
  ```



``` perl
  use v6;


  #L<S05/Modifiers/"The :c">

  my regex simple { . a };
  my $string = "1a2a3a";

  {
      $string ~~ m:c/<&simple>/;               # 1a
      $string ~~ m:c/<&simple>/;               # 2a
      $string ~~ m:c/<&simple>/;               # 3a
      $string ~~ m:c/<&simple>/;               # no more 'a's to match

  }

  {
      my $m = $string.match(/.a/);             # 1a
      $m = $string.match(/.a/, :c(2));         # 2a
      $m = $string.match(/.a/, :c(4));         # 3a

  }

  # this batch not starting on the exact point, and out of order
  {
      my $m = $string.match(/.a/, :c(0));      # 1a
      $m = $string.match(/.a/, :c(3));         # 3a
      $m = $string.match(/.a/, :c(1));         # 2a

  }

  {
      my $m = $string.match(/.a/);             # 1a
      $m = $string.match(/.a/, :continue(2));  # 2a
      $m = $string.match(/.a/, :continue(4));  # 3a

  }

```

  ​

注意, 这不会自动把 `pattern` 锚定到开始位置. (使用 :p 可以). 提供给 `split` 的 pattern 默认有一个隐式的 `:c` 修饰符.



- `:p` (或 `:pos`) 修饰符让 `pattern` 只在字符串中指定的位置尝试匹配:
  [`S05-modifier/pos.t lines 13–111`](https://github.com/perl6/roast/blob/master/S05-modifier/pos.t#L13-L111)

``` perl6
m:pos($p)/ pattern /  # match at position $p
```

如果参数被省略，它就默认为 `($/ ?? $/.to !! 0)`. (Unlike in Perl 5, the string itself has no clue where its last match ended.) All subrule matches are implicitly passed their starting position. Likewise, the pattern you supply to a Perl macro's `is parsed` trait has an implicit `:p` modifier.

注意

``` perl
 m:c($p)/pattern/
```

正等价于

``` perl
m:p($p)/.*? <( pattern )> /
```

所有的 `:g`, `:ov`, `:nth`, `:x` 跟 `:p` 是不兼容的, 并且会失败， 推荐使用 `:c` 代替. 允许使用 `:ex` 修饰符， 但是只会在那个位置产生匹配.



- 新的 `:s` (`:sigspace`) 修饰符让空白序列起作用，这些空白被匹配规则 `<.ws>` 代替. 只有紧跟在匹配结构(原子, 量词化原子)之后的空白序列是合适的。因此, 出现在任何 regex 开头的空白都会被忽略, 为了让能够参与最长 token 匹配的备选分支更容易书写。即： Only whitespace sequences immediately following a matching construct (atom, quantified atom, or assertion) are eligible. Hence, initial whitespace is ignored at the front of any regex, to make it easy to write rules that can participate in longest-token-matching alternations. That is,

  [`S05-grammar/ws.t lines 5–34`](https://github.com/perl6/roast/blob/master/S05-grammar/ws.t#L5-L34)

  ```
       m:s/ next cmd '='   <condition>/
  ```

  等价于:

  ```
       m/ next <.ws> cmd <.ws> '=' <.ws> <condition>/
  ```

  同样等价于:

  ```
       m/ next \s+ cmd \s* '=' \s* <condition>/
  ```

  但是在这种情况:

  ```
       m:s{(a|\*) (b|\+)}
  ```

  或等价的:

  ```
       m { (a|\*) <.ws> (b|\+) }
  ```

  ​

  `<.ws>` 直到看见数据才能决定要做什么. 它仍旧能做对事情. 不过不能, 定义你自己的 `ws`, 而 `:sigspace` 会使用它.`
   仅仅当 rule 可能参与最长 token 匹配时,  rule 前面的空白才会被忽略, 但是在任何显式备选分支的前面这同样适用, 因为同样的原因。如果你想在一组备选分支前面匹配有意义的空格(sigspace), 把你的空白格放在含有备选分支的括号外面。
  ​

  Whitespace is ignored not just at the front of any rule that might participate in longest-token matching, but in the front of any alternative within an explicit alternation as well, for the same reason. If you want to match sigspace before a set of alternatives, place your whitespace outside of the brackets containing the alternation.

  ​
当你这样写:


  ```
      rule TOP { ^ <stuff> $ }
  ```

  这等价于

  ```
      token TOP { ^ <.ws> <stuff> <.ws> $ <.ws> }
  ```

  但是注意最后一个 `<.ws>`  总是匹配空字符串，因为  `$` 锚定字符串的末尾. 如果你的 `TOP` rule 没有使用 `^` 锚定, 它不会匹配开头的空白. 

  ​

  特别地， 下面的构造会把后面跟着的空白转换为 `sigspace`:

  ```
      any atom or quantified atom
      $foo @bar
      'a' "$b"
      ^ $ ^^ $$
      (...) [...] <...> as a whole atoms
      (...)* [...]* <...>* as quantified atoms
      <( and )>
      « and » (but don't use « that way!)
  ```

  然而这些并不会:

  ```
      opening ( or [
      | or ||
      & or &&
      ** % or %%
      :foo declarations, including :my and :sigspace itself
      {...}
  ```

当我们说 sigspace 能跟在原子或量词化的原子后面, 我们是说 sigspace 能出现在原子和它的量词之间:
  ​
  ```
      ms/ <atom> * /      # 意味着 / [<atom><.ws>]* /
  ```

  (如果每个原子匹配空白, 那么就没有必要匹配后面的量词了。If each atom matches whitespace, then it doesn't need to match after the quantifier.)

一般地, 你不需要在 grammars 中使用 `:sigspace`, 因为解析规则会为你自动处理空白策略。在该上下文中, 空白常会包含注释, 根据 grammar 如何去定义它的空白规则。尽管默认的 `<.ws>` subrule 识别不了注释结构, 任何 grammar 能随意重写 `<.ws>` 规则。`<.ws>` rule 并不意味着在哪儿都是一样。

  In general you don't need to use `:sigspace` within grammars because the parser rules automatically handle whitespace policy for you. In this context, whitespace often includes comments, depending on how the grammar chooses to define its whitespace rule. Although the default `<.ws>` subrule recognizes no comment construct, any grammar is free to override the rule. The `<.ws>` rule is not intended to mean the same thing everywhere.

  [`S05-grammar/ws.t lines 6–34`](https://github.com/perl6/roast/blob/master/S05-grammar/ws.t#L6-L34)

  ​

  It's also possible to pass an argument to `:sigspace` specifying a completely different subrule to apply. This can be any rule, it doesn't have to match whitespace. When discussing this modifier, it is important to distinguish the significant whitespace in the pattern from the "whitespace" being matched, so we'll call the pattern's whitespace *sigspace*, and generally reserve *whitespace* to indicate whatever `<.ws>` matches in the current grammar. The correspondence between sigspace and whitespace is primarily metaphorical, which is why the correspondence is both useful and (potentially) confusing.

  ​

  The `:ss` (or `:samespace`) variant may be used on substitutions to do smart space mapping in addition to smart space matching. (That is, `:ss` implies `:s`.) For each sigspace-induced call to `` on the left, the matched whitespace is copied over to the corresponding slot on the right, as represented by a single whitespace character in the replacement string wherever space replacement is desired. If there are more whitespace slots on the right than the left, those righthand characters remain themselves. If there are not enough whitespace slots on the right to map all the available whitespace slots from the match, the algorithm tries to minimize information loss by randomly splicing "common" whitespace characters out of the list of whitespace. From least valuable to most, the pecking order is:

  ​

  ```
      spaces
      tabs
      all other horizontal whitespace, including Unicode
      newlines (including crlf as a unit)
      all other vertical whitespace, including Unicode
  ```

  ​

  The primary intent of these rules is to minimize format disruption when substitution happens across line boundaries and such. There is, of course, no guarantee that the result will be exactly what a human would do.

  ​

  The `:s` modifier is considered sufficiently important that match variants are defined for them:
  [`S05-modifier/sigspace.t lines 27–48`](https://github.com/perl6/roast/blob/master/S05-modifier/sigspace.t#L27-L48)
  [`S05-substitution/subst.t lines 212–222`](https://github.com/perl6/roast/blob/master/S05-substitution/subst.t#L212-L222)

  ​

  ```
      ms/match some words/                        # same as m:sigspace
      ss/match some words/replace those words/    # same as s:samespace
  ```

  ​

  Note that `ss///` is defined in terms of `:ss`, so:

  ​

  ```
      $_ = "a b\nc\td";
      ss/b c d/x y z/;
  ```

  ​

  ends up with a value of `a x\ny\tz`.

  ​

- 新修饰符可指定Unicode 级别:

  ```
       m:bytes  / .**2 /       # match two bytes
       m:codes  / .**2 /       # match two codepoints
       m:graphs / .**2 /       # match two language-independent graphemes
       m:chars  / .**2 /       # match two characters at current max level
  ```

  ​

  There are corresponding pragmas to default to these levels. Note that the `:chars` modifier is always redundant because dot always matches characters at the highest level allowed in scope. This highest level may be identical to one of the other three levels, or it may be more specific than `:graphs` when a particular language's character rules are in use. Note that you may not specify language-dependent character processing without specifying *which* language you're depending on. [Conjecture: the `:chars` modifier could take an argument specifying which language's rules to use for this match.]

  ​

- 新的 `:Perl5`/`:P5` 修饰符允许使用Perl 5 正则语法 (现在不允许你把修饰符放在后面). 例如,

```
m:P5/(?mi)^(?:[a-z]|\d){1,2}(?=\s)/
```

等价于 Perl 6 语法:

```
m/ :i ^^ [ <[a..z]> || \d ] ** 1..2 <?before \s> /

```



- 任何一个整数修饰符指定一个计数. 数字后面的字符决定了计数的种类:

- 如果后面跟着一个 `x`, 则意味着重复. 一般使用 `:x(4)` 这种形式:

  [`S05-modifier/repetition-exhaustive.t lines 16–30`](https://github.com/perl6/roast/blob/master/S05-modifier/repetition-exhaustive.t#L16-L30)
  [`S05-modifier/repetition.t lines 6–29`](https://github.com/perl6/roast/blob/master/S05-modifier/repetition.t#L6-L29)

  ```
  s:4x [ (<.ident>) '=' (\N+) $$] = "$0 => $1";
  ```

  等同于:

  ```
       s:x(4) [ (<.ident>) '=' (\N+) $$] = "$0 => $1";
  ```

  这几乎等同于:

  ```
  s:c[ (<.ident>) '=' (\N+) $$] = "$0 => $1" for 1..4;
  ```

  except that the string is unchanged unless all four matches are found. However, ranges are allowed, so you can say `:x(1..4)` to change anywhere from one to four matches.

  ​

- 如果数字后面跟着 `st`, `nd`, `rd`, 或 `th`, 它意味着查找第`*N*th` 次出现.  一般使用 `:nth(3)` 这种形式, 所以
  [`S05-modifier/counted.t lines 13–252`](https://github.com/perl6/roast/blob/master/S05-modifier/counted.t#L13-L252)

  ```
       s:3rd/(\d+)/@data[$0]/;
  ```

  等同于

  ```
       s:nth(3)/(\d+)/@data[$0]/;
  ```

  它等价于

  ```
       m/(\d+)/ && m:c/(\d+)/ && s:c/(\d+)/@data[$0]/;
  ```

  ​

  The argument to `:nth` is allowed to be a list of integers, but such a list should be monotonically increasing. (Values which are less than or equal to any previous value will be ignored.) So:

  ​

  ```
      :nth(2,4,6...*)    # return only even matches
      :nth(1,1,*+*...*)  # match only at 1,2,3,5,8,13...
  ```

  ​

  This option is no longer required to support smartmatching. You can grep a list of integers if you really need that capability:

  ```
      :nth(grep *.oracle, 1..*)
  ```

  ​

  If both `:nth` and `:x` are present, the matching routine looks for submatches that match with `:nth`. If the number of post-nth matches is compatible with the constraint in `:x`, the whole match succeeds with the highest possible number of submatches. The combination of `:nth` and `:x` typically only makes sense if `:nth` is not a single scalar.

  ​

- With the new `:ov` (`:overlap`) modifier, the current regex will match at all possible character positions (including overlapping) and return all matches in list context, or a disjunction of matches in item context. The first match at any position is returned. The matches are guaranteed to be returned in left-to-right order with respect to the starting positions.
  [`S05-modifier/overlapping.t lines 16–67`](https://github.com/perl6/roast/blob/master/S05-modifier/overlapping.t#L16-L67)

  ​

  ```

     $str = "abracadabra";
     if $str ~~ m:overlap/ a (.*) a / {
           @substrings = slice @();    # bracadabr cadabr dabr br
       }
  ```

  ​

- 使用新的 `:ex` (`:exhaustive`) 修饰符, 当前正则会匹配所有可能的路径(包括重叠)并返回所有 `matches`的一个列表.
  [`S05-modifier/exhaustive.t lines 10–147`](https://github.com/perl6/roast/blob/master/S05-modifier/exhaustive.t#L10-L147)
  [`S05-modifier/repetition-exhaustive.t lines 17–30`](https://github.com/perl6/roast/blob/master/S05-modifier/repetition-exhaustive.t#L17-L30)

  ​

  The matches are guaranteed to be returned in left-to-right order with respect to the starting positions. The order within each starting position is not guaranteed and may depend on the nature of both the pattern and the matching engine. (Conjecture: or we could enforce backtracking engine semantics. Or we could guarantee no order at all unless the pattern starts with "::" or some such to suppress DFAish solutions.)

  ​

  ```
     $str = "abracadabra";

     if $str ~~ m:exhaustive/ a (.*?) a / {
         say "@()";    # br brac bracad bracadabr c cad cadabr d dabr br
     }
  ```

  ​

  Note that the `~~` above can return as soon as the first match is found, and the rest of the matches may be performed lazily by `@()`.

  ​

- The new `:rw` modifier causes this regex to *claim* the current string for modification rather than assuming copy-on-write semantics. All the captures in `$/` become lvalues into the string, such that if you modify, say, `$1`, the original string is modified in that location, and the positions of all the other fields modified accordingly (whatever that means). In the absence of this modifier (especially if it isn't implemented yet, or is never implemented), all pieces of `$/` are considered copy-on-write, if not read-only.

  [Conjecture: this should really associate a pattern with a string variable, not a (presumably immutable) string value.]

  ​

- 新的 `:r` 或 `:ratchet` 修饰符让这个 regex 默认不回溯。 (通常你不直接使用这个修饰符, 因为在 `token` 和 `rule` 声明符中已经隐式地包含了这个修饰符, 也就是说 **token** 和 **rule** 默认也是不回溯的。) 这个修饰符的作用是在每个原子(atom)后面暗指一个 `:`, 包括但不限于  `*`, `+`, 和 `?` 量词, 还有备选分支。量词化原子上的显式回溯修饰符, 例如 `**`, 会重写这个修饰符。 (Note: for portions of patterns subject to longest-token analysis, a `:` is ignored in any case, since there will be no backtracking necessary.)
  [`S05-modifier/ratchet.t lines 5–27`](https://github.com/perl6/roast/blob/master/S05-modifier/ratchet.t#L5-L27)
  [`S05-mass/rx.t lines 92–99`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L92-L99)

  ​

- `:i`, `:m`, `:r`, `:s`, `:dba`, `:Perl5`, 和  Unicode 级别的修饰符能被放在 regex 里面  (并且是词法作用域的):
  [`S05-modifier/ignorecase.t lines 18–23`](https://github.com/perl6/roast/blob/master/S05-modifier/ignorecase.t#L18-L23)

  ​

  ```
       m/:s alignment '=' [:i left|right|cent[er|re]] /
  ```

  ​

  As with modifiers outside, only parentheses are recognized as valid brackets for args to the adverb. In particular:就像外面的修饰符一样,  只有圆括号能够作为副词的参数被识别为合法的括号. 特别地:

  ​

  ```
      m/:foo[xxx]/        Parses as :foo [xxx]
      m/:foo{xxx}/        Parses as :foo {xxx}
      m/:foo<xxx>/        Parses as :foo <xxx>
  ```

  ​

- 用户自定义修饰符成为可能:

  ```
           m:fuzzy/pattern/;
  ```

  ​

- 用户自定义修饰符也能接收参数, 但是只能在圆括号中:

  ```
           m:fuzzy('bare')/pattern/;
  ```

  ​

- 要使用括号作为你的分隔符你必须隔开:

  ```
           m:fuzzy (pattern);
  ```

  或者把 pattern 放在最后:

  ```
           m:fuzzy(fuzzyargs); pattern ;
  ```

  ​

- 任何 grammar regex 实际上是一种`方法`, 并且你可以在这样一个子例程中使用一个冒号跟着任何作用域声明符来声明一个变量, 这些声明符包括 `my`, `our`, `state` 和 `constant` (作为类似的声明符, temp 和 let 也能被识别). 单个语句(直到结尾的分号或行末尾的闭括号为止) 被解析为普通的 Perl 6 代码:

  [`S05-modifier/my.t lines 5–87`](https://github.com/perl6/roast/blob/master/S05-modifier/my.t#L5-L87)

  ```
      token prove-nondeterministic-parsing {
          :my $threshold = rand;
          'maybe' \s+ <it($threshold)>
      }

  ```

  ​

  这种作用域声明符不会终止最长 token 匹配, 所以无效的声明符可以作为作为一个挂钩来挂起副作用而不改变随后的模式匹配:

  ​

  ```
      rule breaker {
          :state $ = say "got here at least once";
          ...
      }

  ```

  ​



# 允许的修饰符

有些修饰符能在所有允许的地方出现, 但并非所有的都这样.

通常,  影响 regex 编译的修饰符( 像 `:i` ) 一定要在编译时被知道. 只影响行为而非 regex本身的修饰符(eg. `:pos`, `:overlap`, `:x(4)`) 可能只出现在引用某个调用的结构上(例如 `m//` 和`s///`),  并且不会出现在 `rx//` 上.  最后, 重叠在替换结构中是不被允许的, 而影响修改的副词只允许出现在替中.

这些准则导致了下面的 rules:



- `:ignorecase`, `:ignoremark`, `:sigspace`, `:ratchet`  和 ` :Perl5`  修饰符和它们的便捷形式允许出现在 regex 中的任何地方, 还有 `m//`, `rx//` 和`s///`  结构中. 一个 regex实现可能要求它们的值在编译时是被知晓的, 而如果不是这种情况则给出编译时错误信息.

  ```
      rx:i/ hello /           # OK
      rx:i(1) /hello/         # OK
      my $i = 1;
      rx:i($i) /hello/        # may error out at compile time
  ```

  ​

- `:samecase`, `:samespace` 和 `:same mark`  修饰符(还有它们的便捷形式) 只允许出现在替换结构上 (`s///` 和 `s[] = ...`).

- `:overlap` 和 `:exhaustive`修饰符(还有它们的便捷形式) 只允许出现匹配结构上(i.e. `m//`), 不会出现在替换或 regex qoutes 结构上.

-  `:pos`, `:continue`, `:x` 和 `:nth`  修饰符和它们的别名只允许作用在引用即时调用的结构上. (eg. `m//` 和`s///` (but not on `rx//`).

-  `:dba` 副词只在  regex 内部被允许.



# 改变了的元字符
  [`S05-metasyntax/changed.t lines 6–38`](https://github.com/perl6/roast/blob/master/S05-metasyntax/changed.t#L6-L38)

- `.` 现在匹配任意字符,包括换行符. (`/s` 修饰符被废弃了).

- `^` 和 `$` 现在总是匹配字符串的开始/末尾, 就像旧的  `\A` 和  `\z`. (`/m` 修饰符被废弃了.)  On the right side of an embedded在内含的  `~~`或 `!~~`  操作符的右侧, `^` 和 `$`  总是匹配指定 submatch  的开头/结尾, 因为那个 submatch  在逻辑上被看作为单独的字符串.

- `$`不再匹配一个可选的前置 `\n`, 所以你还是想要的话, 使用 `\n?$` 代替.

- `\n` 现在匹配一个逻辑(跟平台有关)换行符, 不仅仅是 `\x0a`.
  [`S05-metachars/newline.t lines 13–37`](https://github.com/perl6/roast/blob/master/S05-metachars/newline.t#L13-L37)

  ​

- `\A`, `\Z`, 和 `\z` 元字符被废弃了.



# 新的元字符

- 因为 `/x` 是默认的:
  - 不加引号的 `#` 现在总是引入一个注释.  如果它后面跟着一个反引号和一个开放的括号字符, 它会引入一个以闭括号终止的嵌入式注释. 否则, 注释会以换行终止.
  - 空白现在总是元语法，即只用于布局，不会再被照字面意义被匹配。（参看上面的描述的`:sigspace`修饰符）


- `^^` 和 `$$` 匹配行的开头和结尾. (`/m` 修饰符不存在了.) 它俩都是零宽断言.  `$$` 匹配任何 `\n` (逻辑换行) 之前的位置, 如果最后一个字符不是 `\n` , 那它也匹配字符串的末尾.  `^^` 总是匹配字符串的开头,  还匹配字符串中任何不是最后一个字符的 `\n` 的后面

  [`S05-metachars/line-anchors.t lines 15–43`](https://github.com/perl6/roast/blob/master/S05-metachars/line-anchors.t#L15-L43)

  ​

- `.`   匹配任何东西, 而 `\N` 任何除 `\n` 之外的东西 (`/s` 修饰符不存在了.) 特别地, `\N`  既不匹配回车, 也不匹配换行.

  - 新的  `&` 元字符分割连结项.   模式两边必须以同一个开始点和结束点匹配. 注意, 如果你不想两个项以同一个点结尾, 那么你真正需要的是使用向前查看代替.

     就像`或`有 `|` 和 `||` 一样, `与`也有 `&` 和 `&&` 两种形式.  `&` 形式的与被认为是描述性的而不是程序性的; 它允许编译器 和/或 运行时系统决定首先计算哪一部分, 一贯的任何顺序都可能发生的假设是错误的. `&&` 保证了从左到右的顺序, 并且回溯使右侧的参数比左侧的参数变化得更快. 换句话说,  `&&` 和 `||` 建立了一连串的点. 左侧可以在回溯允许的时候作为整体回溯到结构中.

    [`S05-metasyntax/sequential-alternation.t lines 5–21`](https://github.com/perl6/roast/blob/master/S05-metasyntax/sequential-alternation.t#L5-L21)

    ​`&&`and `||`. `&` 像 `|` 那样是列表结合性的, 但是有高一点的优先级. 同样地, `&&` 的优先级比 `||` 的优先级高一点. 就像普通的连接和短路操作符一样, `&` 和 `|` 的结合性比 `&&` 和 `||` 更紧.

    ​

- The `~~` and `!~~` operators cause a submatch to be performed on whatever was matched by the variable or atom on the left. String anchors consider that submatch to be the entire string. So, for instance, you can ask to match any identifier that does not contain the word "moose":

  ```
      <ident> !~~ 'moose'
  ```

  In contrast

  ```
      <ident> !~~ ^ 'moose' $
  ```

  ​

  would allow any identifier (including any identifier containing "moose" as a substring) as long as the identifier as a whole is not equal to "moose". (Note the anchors, which attach the submatch to the beginning and end of the identifier as if that were the entire match.) When used as part of a longer match, for clarity it might be good to use extra brackets:

  ```
      [ <ident> !~~ ^ 'moose' $ ]
  ```

  The precedence of `~~` and `!~~` fits in between the junctional and sequential versions of the logical operators just as it does in normal Perl expressions (see S03). Hence

  ```
      <ident> !~~ 'moose' | 'squirrel'
  ```

  解析为

  ```
      <ident> !~~ [ 'moose' | 'squirrel' ]
  ```

  而

  ```
      <ident> !~~ 'moose' || 'squirrel'
  ```

  解析为

  ```
      [ <ident> !~~ 'moose' ] || 'squirrel'
  ```

  ​

-  `~` 操作符是一个用于匹配嵌套的带有特定终止符作为目标的 subrules 的助手。 它被设计为放置在开括号和闭括号之间, 就像这样:
  [`S05-metachars/tilde.t lines 6–81`](https://github.com/perl6/roast/blob/master/S05-metachars/tilde.t#L6-L81)

  ```
      '(' ~ ')' <expression>
  ```

  ​

  However, it mostly ignores the left argument, and operates on the next two atoms (which may be quantified). Its operation on those next two atoms is to "twiddle" them so that they are actually matched in reverse order. Hence the expression above, at first blush, is merely shorthand for:

  ```
      '(' <expression> ')'
  ```

  But beyond that, when it rewrites the atoms it also inserts the apparatus that will set up the inner expression to recognize the terminator, and to produce an appropriate error message if the inner expression does not terminate on the required closing atom. So it really does pay attention to the left bracket as well, and it actually rewrites our example to something more like:

  ```
      $<OPEN> = '(' <SETGOAL: ')'> <expression> [ $GOAL || <FAILGOAL> ]
  ```

  Note that you can use this construct to set up expectations for a closing construct even when there's no opening bracket:

  ```
      <?> ~ ')' \d+
  ```

  Here <?> returns true on the first null string.

  ​

  By default the error message uses the name of the current rule as an indicator of the abstract goal of the parser at that point. However, often this is not terribly informative, especially when rules are named according to an internal scheme that will not make sense to the user. The `:dba("doing business as")` adverb may be used to set up a more informative name for what the following code is trying to parse:

  ```
      token postfix:sym<[ ]> {
          :dba('array subscript')
          '[' ~ ']' <expression>
      }
  ```

  ​

  Then instead of getting a message like:

  ```
      Unable to parse expression in postfix:sym<[ ]>; couldn't find final ']'
  ```

  you'll get a message like:

  ```
      Unable to parse expression in array subscript; couldn't find final ']'
  ```

  ​

  (The `:dba` adverb may also be used to give names to alternations and alternatives, which helps the lexer give better error messages.)

  ​



# 括号合理化


- `(...)` 仍然界定一个捕获组. 然而, 这些捕获组的顺序是分等级的, 而不是线性的. 查看 "Nested subpattern captures".

- `[...]` 不再表示字符类. 它现在界定一个`非捕获组`.

  [`S05-match/non-capturing.t lines 11–39`](https://github.com/perl6/roast/blob/master/S05-match/non-capturing.t#L11-L39)

  ​

  字符类现在使用 `<[...]>` 指定. 查看 "Extensible metasyntax (<...>)".

  ​

- `{...}` 不再是重复量词. 它现在界定一个嵌入的`闭包`. 它总是被认为是过程式的而非声明性的;  它在之前和之后之间建立了一系列的点. (为了避免这个, 使用 `<?{…}>` 断言语法代替. ). regex 中的闭包建立了它自己的词法作用域 
  [`S05-metachars/closure.t lines 15–53`](https://github.com/perl6/roast/blob/master/S05-metachars/closure.t#L15-L53)

```
{
    my $x = 3;
    my $y = 2;
    'a' ~~ /. { $y = $x; 0 }/;  # can match and execute a closure'
    say $y;                     # 3, 'could access and update outer lexicals';
}
```

测试中的 `#?rakudo skip 'assignment to match variables (dubious) RT #124946'` 表示跳过该测试, 功能尚未实现。

```
my $caught = "oops!";
"abc" ~~ m/a(bc){$caught = $0}/;  # Outer match
say $caught;                      # bc, Outer caught
```
  ​

- 你可以使用闭包调用 Perl 代码作为正则表达式匹配的一部分. 嵌入的代码不经常影响匹配 -- 它只用作副作用(比如保存捕获的值):

  ```
       / (\S+) { print "string not blank\n"; $text = $0; }
          \s+  { print "but does contain whitespace\n"   }
       /
  ```

  ​
  在匹配过程中使用 `{...}` 闭包的一个例子就是 `make` 函数。
  一个使用 make 函数的显式换算生成了这个匹配(match)的抽象语法树(简写成抽象对象或 ast):

  [`S05-grammar/action-stubs.t lines 37–182`](https://github.com/perl6/roast/blob/master/S05-grammar/action-stubs.t#L37-L182)
  [`S05-match/make.t lines 7–8`](https://github.com/perl6/roast/blob/master/S05-match/make.t#L7-L8)

  ```
          / (\d) { make $0.sqrt } Remainder /;
  ```

  ​
这捕获了数字化字符串的平方根, 而不是字符串的平方根。   如果前面的 `\d` 匹配成功, 那么 `Remainder`(剩余的) 部分继续被匹配并作为 `Match` 对象的一部分返回, 但是没有作为`抽象对象`的一部分返回。因为抽象对象通常代表抽象语法树的顶层节点, 所以抽象对象可以通过使用 `.made` 方法从 `Match` 对象中提取出来。

  This has the effect of capturing the square root of the numified string, instead of the string. The `Remainder`part is matched and returned as part of the `Match` object but is not returned as part of the abstract object. Since the abstract object usually represents the top node of an abstract syntax tree, the abstract object may be extracted from the `Match` object by use of the `.made` method.

  ​
`make` 的二次调用会重写之前的 `make` 调用。 每个匹配对象上都可以有 `make`方法。

  A second call to `make` overrides any previous call to `make`. `make` is also available as a method on each match object.

  ​
在闭包里面, 搜索的实时位置是由  `$¢.pos` 方法指示的。就像所有的字符串位置一样, 你不能把它当作一个数字除非你很清楚你正处理的单元是哪一个。
  Within a closure, the instantaneous position within the search is denoted by the `$¢.pos` method. As with all string positions, you must not treat it as a number unless you are very careful about which units you are dealing with.

`Cursor`  对象也能返回我们匹配的原始项; 这能从 `.orig` 方法中得到。
  ​

  The `Cursor` object can also return the original item that we are matching against; this is available from the `.orig` method.

  ​
到目前为止闭包也保证了开启一个 `$/` Match 对象代表了匹配到的东西。 然而, 如果闭包自身内部做了匹配, 那么它的 `$/` 变量会被绑定到那个匹配的结果上直到嵌入闭包的结束。在闭包的后面, 匹配实际会使用 `$¢` 的当前值继续。 在你的闭包中 `$/` 和 `$¢` 是一样的。

  The closure is also guaranteed to start with a `$/` `Match` object representing the match so far. However, if the closure does its own internal matching, its `$/` variable will be rebound to the result of *that* match until the end of the embedded closure. (The match will actually continue with the current value of the `$¢` object after the closure. `$/` and `$¢` just start out the same in your closure.)

  ​

- 闭包能影响匹配如果它调用了 `fail`:

  ```
       / (\d+) { $0 < 256 or fail } /
  ```

因为闭包建立了一个序列点,  它们保证会在规定的时间被调用即使优化器能证明它们后面的某些东西不能匹配。(任何之前的都是公平游戏。 特别地, 闭包常常用作最长 token 模式的终结者。)​

  Since closures establish a sequence point, they are guaranteed to be called at the canonical time even if the optimizer could prove that something after them can't match. (Anything before is fair game, however. In particular, a closure often serves as the terminator of a longest-token pattern.)

  ​

- 普通的重复分类符现在是 `**`, 用于贪婪匹配,  使用对应的 `**?` 用于非贪婪匹配.(所有这样的量词修饰符现在直接跟在 `**` 后面).整个量词的两边都允许有空格, 但是只有 `**` 前面的空格在 `:sigspace` 下和重复之间的匹配被认为是有意义的.

 Space is allowed on either side of the complete quantifier, but only the space before the `**` will be considered significant under `:sigspace` and match between repetitions. (Sigspace after the entire construct matches once after the all repetitions are found.)
  [`S05-metasyntax/repeat.t lines 19–88`](https://github.com/perl6/roast/blob/master/S05-metasyntax/repeat.t#L19-L88)

  下一个 token 限制了左边的 pattern 必须被匹配多少次。 如果下一个东西是整数, 那么它会被解析为一个精确的计数或一个范围:

  ```
      . ** 42                  # match exactly 42 times
      <item> ** 3..*           # match 3 or more times

  ```

这种形式被认为是陈述性的。
  This form is considered declarational.

  如果你提供一个闭包, 它应该返回一个 Int 或 Range 对象.

  ```
      'x' ** {$m}              # 从闭包中返回精确计数
      <foo> ** {$m..$n}        # 从闭包中返回范围
       / value was (\d **? {1..6}) with ([ <alpha>\w* ]**{$m..$n}) /
  ```

  从闭包返回一个列表是非法的, 所以这种简单的错误会导致失败:

  ```
      / [foo] ** {1,3} /
  ```

  这种形式的闭包总被看作是​过程式的, 所以它所修饰的项绝不会被当作是最长 token 的一部分。

  The closure form is always considered procedural, so the item it is modifying is never considered part of the longest token.

  ​
为了和之前的 Perl 6 版本保持向后兼容, 如果一个 token 后面跟着的既不是闭包也不是整数字面值, 那么它会被解释为 +%, 并带有一个警告：

  ```
     / x ** y /                # same as / x+ % y /
     / x ** $y /               # same as / x [$y x]* /
  ```

这并不会检查 $y 是否包含一个整数或范围值。这个兼容功能也不能保证会永远存在。
  ​

- 负数范围值也是允许的, 但是只有当模式是可逆的时候(例如 after 能匹配的). 例如, 搜索元素周围 200 个定义为点的字符, 可以写为:

  ```
      / . ** -100..100 <element> /
  ```

  类似地, 你可以后退 50 个字符:

  ```
      / . ** -50 <element> /
  ```

  [Conjecture: A negative quantifier forces the construct to be considered procedural rather than declarational.]

  ​

- 任何量词化的原子都能通过添加一个额外的约束, 来指定重复左侧的两个原子之间的分隔符.  在量词和分割符之间添加一个 `%`号. 只要两个 item 之间有分隔符就重复初始的 item:

  ```
      <alt>+    % '|'            # repetition controlled by presence of character
      <addend>+ % <addop>        # repetition controlled by presence of subrule
      <item>+   % [ \!?'==' ]    # repetition controlled by presence of operator
      <file>+   % \h+            # repetition controlled by presence of whitespace
  ```

  ​

  任何量词都可以这样修改:

  ```
      <a>* % ','              # 0 or more comma-separated elements
      <a>+ % ','              # 1 or more
      <a>? % ','              # 0 or 1 (but ',' never used!?!)
      <a> ** 2..* % ','       # 2 or more
  ```

  `%` 修饰符只能用在量词上;  把 `%` 用在裸 item 上的任何尝试都会导致解析失败.

  ```
      / <ident>+ % ',' /
  ```

  能匹配

  ```
      foo
      foo,bar
      foo,bar,baz
  ```

  但是不会匹配

  ```
      foo,
      foo,bar,
  ```

  ``` perl
      '' ~~ / <ident>* % ',' /  # matches because of the *
  ```

  使用 `%%` 能匹配末尾的分隔符. 因此

  ```
      / <ident>+ %% ',' /
  ```

  能匹配

  ```
      foo
      foo,
      foo,bar
      foo,bar,
      foo,bar,baz
      foo,bar,baz,
  ```

  If you wish to quantify each match on the left individually, you must place it in brackets:

  ```
      [<a>*]+ % ','
  ```

零宽的分隔符也是合法的, 只要左侧的模式每次能够重复:
  It is legal for the separator to be zero-width as long as the pattern on the left progresses on each iteration:

  ```
      .+ % <?same>   # 匹配同一字符的序列
  ```

  The separator never matches independently of the next item; if the separator matches but the next item fails, it backtracks all the way back through the separator. Likewise, this matching of the separator does not count as "progress" under `:ratchet` semantics unless the next item succeeds.

  ​

  When significant space is used under `:sigspace`, each matching element enables the immediately following whitespace to be considered significant. Space after the `%` does nothing. 当在 `:sigspace` 下使用了有意义的空格, 每个匹配元素使后面跟着的空格变得有意义. % 后面的空格什么也不做. 如果你这样写:

  ```
      ms/ <element> +  %  ',' /
        #1        #2 #3 #4  #5
  ```

  它会忽略 `#1` 和 `#4` 位置的空白, 并把剩下的重写为:

  ```
      / [ <element> <.ws> ]+ % [ ',' <.ws> ] <.ws> /
                      #2               #5      #3
  ```

因为 `#3` 对于 `#2` 来说是多余的(因为 `+` 要求一个元素), `#2` 或 `#3` 都可以满足:

  ```
      ms/ <element>+ % ',' /    # ws after comma and at end
      ms/ <element> +% ',' /    # ws after comma and any element
  ```

  所以第一个

  ```
      ms/ <element>+ % ',' /    # ws after comma and at end
  ```

  就像

  ```
      / <element>[','<.ws><element>]*<.ws> /
  ```

  而第二个

  ```
      ms/ <element> +% ',' /    # ws after comma and any element
  ```

  就像

  ```
      / <element><.ws>[','<.ws><element><.ws>]* /
  ```

  并且

  ```
      ms/ <element>+% ','/
  ```

  排除了所有有意义的空格,就像这样:

  ```
      / <element>[','<element>]* /
  ```

  ​
注意, 使用 `*` 而非 `+`, 空格 `#3` 对于 `#2` 来说并不是多余的, 因为如果匹配了 0 个元素, 那么跟它有关的(#2) 空格就不会匹配。 那种情况下, 在 `*` 两边都放上空格是有意义的:

  Note that with a `*` instead of a `+`, space #3 would not be redundant with #2, since if 0 elements are matched, the space associated with it (#2) is not matched. In that case it makes sense to put space on both sides of the `*`:

  ```
      ms/ <element> * % ',' /
  ```

  ​

- `<...>` 现在是可扩展的元语法分隔符或*断言*(例如, 它们代替 Perl‘5 的`(?...)` 语法)。



# 变量(non-)插值


[`S05-interpolation/regex-in-variable.t lines 13–81`](https://github.com/perl6/roast/blob/master/S05-interpolation/regex-in-variable.t#L13-L81)

- 在 Perl 6 的 regexes 中, 变量不会进行插值. 

- 相反, 它们被原原本本地传递给正则引擎, 然后正则引擎决定怎样处理它们.

- 在正则引擎中处理字符串标量的默认方式是把它作为 `"..."` 字面量匹配 (i.e. 它不会把插值字符串作为 subpattern). 换句话说, 一个 Perl 6 的:
  [`S05-metasyntax/litvar.t lines 17–39`](https://github.com/perl6/roast/blob/master/S05-metasyntax/litvar.t#L17-L39)

  ```
       / $var /
  ```

  就像 Perl 5 的:

  ```
       / \Q$var\E /
  ```

  为了插值一个 Regex 对象, 使用  `<$var>` 代替. 如果 `$var` 未定义, 会出现一个警告并匹配失败.` 

  [`S05-interpolation/regex-in-variable.t lines 85–119`](https://github.com/perl6/roast/blob/master/S05-interpolation/regex-in-variable.t#L85-L119)

  当匹配一个不是 Str 类型的字符串化的类型时, 那个变量必须被作为那个字符串化类型的值被插值(或者是能强制转换成那个类型的相关类型) 例如: 当 regex 匹配一个 Buf 类型时, 变量将会在 Buf 类型的语义下被匹配, 而非 Str 语义.

  [猜想: 当我们允许匹配非字符串类型时, 在当前节点上做类型匹配会要求一个内含的签名的语法,  不仅仅是一个裸的变量, 所以没有必要对包含一个类型对象的变量作出解释, 它明显是未定义的, 因此对上面的 rule 会匹配失败]

  然而,  一个在等号左边用作别名的变量或 submatch 操作符是不用于匹配的:

  ```
      $x = <.ident>
      $0 ~~ <.ident>
  ```

如果你想再次匹配 `$0` 然后把它用作 submatch, 你可以强制这个匹配使用双引号:

  ```
      "$0" ~~ <.ident>
  ```

  另一方面,  如果别名不是一个变量的话就没有意义:

  ```
      "$0" = <.ident>     # ERROR
      $0 = <.ident>       # okay
      $x = <.ident>       # okay, 临时捕获
      $<x> = <.ident>     # okay, 持久捕获
      <x=.ident>          # 同上
  ```

  ​

  Variables declared in capture aliases are lexically scoped to the rest of the regex. You should not confuse this use of `=` with either ordinary assignment or ordinary binding. You should read the `=` more like the pseudoassignment of a declarator than like normal assignment. It's more like the ordinary `:=` operator, since at the level regexes work, strings are immutable, so captures are really just precomputed substr values. Nevertheless, when you eventually use the values independently, the substr may be copied, and then it's more like it was an assignment originally.

  在捕获别名中声明的变量的作用域是词法作用域,一直到 regex 的剩余部分. 你不能把这种 = 号的用法和普通赋值或普通绑定操作混淆。 你更应该把这种 = 号读作声明符的伪赋值, 而非普通赋值。 它更像普通的 `:=` 操作符, 因为在 regexes 的工作级别, 字符串是不可变的, 所以捕获正是预先计算好的 substr 值.  尽管如此, 当你最终独立地使用这些值时, 那个 substr 就会被复制, 然后它就更像原来的赋值操作.

  ​

  Capture variables of the form `$` may persist beyond the lexical scope; if the match succeeds they are remembered in the `Match` object's hash, with a key corresponding to the variable name's identifier. Likewise bound numeric variables persist as `$0`, etc.

  `$<ident>` 形式的捕获变量能在词法作用域之外持久; 如果匹配成功的话, 它们会被记忆在 Match 对象的散列中, 散列的键对应于变量名的标识符. 同样地, 绑定的数字变量保存在 `$0` 那样的变量中, 等等.

   你可以把捕获保存到已经存在的词法变量中; 这样的变量可能已经能从外部的作用域中可见, 或者可能在 regex 中通过一个 `:my` 声明符来声明。

  ```
      my $x; / $x = [...] /            # capture to outer lexical $x
      / :my $x; $x = [...] /           # capture to our own lexical $x
  ```

  ​

- 一个插值的数组:
  [`S05-metasyntax/litvar.t lines 40–102`](https://github.com/perl6/roast/blob/master/S05-metasyntax/litvar.t#L40-L102)
  [`S05-metasyntax/sequential-alternation.t lines 22–39`](https://github.com/perl6/roast/blob/master/S05-metasyntax/sequential-alternation.t#L22-L39)

  ```
       / @cmds /
  ```

  被匹配为好像它是它的字面元素的一个备选分支. 通常地, 它使用 junctive 语义来匹配:

  ```
       / [ $(@cmds[0]) | $(@cmds[1]) | $(@cmds[2]) | ... ] /
  ```

  However, if it is a direct member of a `||` list, it uses sequential matching semantics, even it's the only member of the list. Conveniently, you can put `||` before the first member of an alternation, hence

  然而, 如果它是 `||` 列表中的一个直接成员, 它会使用相继的匹配语义, 即使它是列表中的唯一成员. 方便地, 你可以把 `||` 放在备选分支的第一个成员之前, 因此

  ```
       / || @cmds /
  ```

  等价于

  ```
       / [ $(@cmds[0]) || $(@cmds[1]) || $(@cmds[2]) || ... ] /
  ```

  当然, 你也可以:

  ```
       / | @cmds /
  ```

  需要明确的是, 你想要 junctive 语义.

  注意, ` $(...)` 的用法是为了阻止下标被解析为 regex 语法而非真正的下标.

  因为 `$x` 被插值为好像你说了 `"$x"` 一样, 如果 $x 包含了一个列表, 它会先被字符串化. 为了获取备选分支, 你必须使用 `@$x` 或  `@($x)` 形式来标示你想要把那个标量变量当作一个列表。

  ​

  An interpolated array using junctive semantics is declarative (participates in external longest token matching) only if it's known to be constant at the time the regex is compiled.

  只有当它在regex被编译时为常量所熟知, 一个使用 junctive 语义的插值数组才是陈述性的(参与外部的最长token匹配)。

  ​

  As with a scalar variable, each element is matched as a literal. All such values pay attention to the current `:ignorecase` and `:ignoremark` settings.

  像标量变量那样, 每个元素被作为字面量匹配. 所有这样的值负责当前的 `:ignorecase` 和 `:ignoremark` 设置.

  当你写烦了:

  ```
      token sigil { '$' | '@' | '%' | '&' | '::' }
  ```

  你可以这样写:

  ```
      token sigil { < $ @ % & :: > }
  ```

  ​

  as long as you're careful to put a space after the initial angle so that it won't be interpreted as a subrule. With the space it is parsed like angle quotes in ordinary Perl 6 and treated as a literal array value.

  只要你细心地在起始的尖括号后面放上一个空格, 以至于它不会被解释为 subrule. 有了空格, 它会像普通 Perl 6 中的尖括号引号那样被解析, 并被当作一个字面数组值。

  ​

- 要不, 如果你预先声明一个 proto regex, 你可以给同一个类别写多个正则表达式, 区别仅仅在于它们所匹配的符号. 符号被指定为"长名字" 的一部分. 也可以在 rule 中使用 `<sym>` 进行匹配, 就像这样:
  [`S05-grammar/protos.t lines 7–31`](https://github.com/perl6/roast/blob/master/S05-grammar/protos.t#L7-L31)

  ```
      proto token sigil {*}
      multi token sigil:sym<$>  { <sym> }
      multi token sigil:sym<@>  { <sym> }
      multi token sigil:sym<%>  { <sym> }
      multi token sigil:sym<&>  { <sym> }
      multi token sigil:sym<::> { <sym> }
  ```

  (multi 是可选的, 并且通常在 grammar 中被省略)

  这可以被看作多重分发的一种形式, 除了它是基于最长 token 匹配而非签名匹配之外。 这种写法的好处就是在一个派生的 grammar 中, 给同一个类别添加额外的 rules 很容易.  当你尝试匹配 `/<sigil>/` 时, 它们中的所有 rules 都会被并行地匹配.

  ​
如果 multi regex 方法中有形参, 仍然首先通过最长 token 继续匹配。如果那导致了绑定, 使用剩下的变体的参数来产生一个普通的多重分发, 假设它们能通过类型进行区分的话。

  If there are formal parameters on multi regex methods, matching still proceeds via longest-token rules first. If that results in a tie, a normal multiple dispatch is made using the arguments to the remaining variants, assuming they can be differentiated by type.

  ​

  The `proto` calls into the subdispatcher when it sees a `*` that cannot be a quantifier and is the only thing in its block. Therefore you can put items before and after the subdispatch by putting the `*` into curlies:

当 `proto` 看见一个不为量词的 `*` 并且在包含 * 号的 block 中只有这个`*` 时, `proto` 就会进入 subdispatcher 调用。因此, 通过把这个 `*` 号放进花括号中, 你就能在这个 subdispatcher 的前面和后面放上 items 了:

  ```
      proto token foo { <prestuff> {*} <poststuff> }
  ```

  ​
这只在 proto 中有效。查看 [S06](http://design.perl6.org/S06.html) 关于 `{*}` 语法的讨论。(不像 proto sub 那样, proto regex 会自动记忆从 `{*}` 中返回的值, 因为它们伴随着匹配光标)。

  This works only in a proto. See [S06](http://design.perl6.org/S06.html) for a discussion of the semantics of `{*}`. (Unlike a proto sub, a proto regex automatically remembers the return values from `{*}` because they are carried along with the match cursor.)

  ​

- 模式中散列变量的用法被保留了.

  [`S05-interpolation/regex-in-variable.t lines 82–84`](https://github.com/perl6/roast/blob/master/S05-interpolation/regex-in-variable.t#L82-L84)

  ​

- Variable matches are considered declarative if and only if the variable is known to represent a constant, Otherwise they are procedural. Note that role parameters (if readonly) are considered constant declarations for this purpose despite the absence of an explicit `constant` declarator, since roles themselves are immutable, and will presumably be replacing the parameter with a constant value when composed (if the value passed is a constant). Macros instantiated with constants would also make those constants eligible for declarative treatment.

- 只有当变量代表一个常量时, 变量的匹配才被认为是声明性的，否则它们是程序性的。注意，role 参数（如果ReadOnly）被认为是用于此目的的常量声明,尽管没有显式的 `constant` 声明符 , 因为 roles 本身是不变的，当组合的时候,可能会使用一个常量值来替换那个参数（如果传递的值是一个常量）。使用常量的宏也会使那些常量在声明时更适合。

# 可扩展的 `<...>` 元语法

[`S05-metasyntax/angle-brackets.t lines 16–139`](https://github.com/perl6/roast/blob/master/S05-metasyntax/angle-brackets.t#L16-L139)
[`S05-mass/recursive.t lines 14–48`](https://github.com/perl6/roast/blob/master/S05-mass/recursive.t#L14-L48)



`<` 和 `>` 都是元字符, 并且经常(但不总是) 用于 matched pairs. (有些元字符函数组合成独立的 tokens, 并且这些可能包含尖括号). 对于 matched pairs, `<` 后面的**第一个字符**决定了断言的性质:

- 如果 `<` 后面的第一个字符是`空格`, 尖括号会被看作普通的引号单词数组字面量

  ```
      < adam & eve >   # 等价于 [ 'adam' | '&' | 'eve' ]
  ```

  注意末尾的 `>` 之前的空格是可选的, 因此, `< adam & eve>` 也可以。

  ```perl
      "even" ~~ /< odd & eve >/
      "even" ~~ /< adam & eve> {say ~$/}/ # eve

  ```

  ​

- `<` 后面的第一个字符如果是字母, 那么它就是一个符合语法规范的捕获断言(例如: subrule 或 字符类 - 看下面):

  ```
       / <sign>? <mantissa> <exponent>? /
  ```

  标识符(例如下面的 foo)后面的第一个字符决定了闭合尖括号之前剩余文本的处理。它的底层语义是函数或方法调用, 所以, 如果标识符后面的第一个字符是左圆括号, 那么它要么是方法调用, 要么是函数调用:

  ```
      <foo('bar')>
  ```

  如果标识符后面的第一个字符是 `=`, 那么该标识符就是等号后面跟着的另一个标识符的别名. 特别地,

  ```
      <foo=bar>
  ```

  是下面这种形式的简写:

  ```
      $<foo> = <bar>
  ```

  注意这种别名不会修改原来的 `<bar>` 捕获. 要重命名一个继承而来的方法而不使用它原来的名字,  就在你想要抑制的捕获名前面加上一个点, 即

  ```
      <foo=.bar>
  ```

  等价于

  ```
      $<foo> = <.bar>
  ```

  同样地, 要显式的重命名一个本地作用域的 regex, 就在 `=` 号后面的标识符前面添加一个 `&`,

  ```
      <foo=&bar>
  ```

  等价于

  ```
      $<foo> = <&bar>
  ```

  多个别名也是允许的, 所以:

  ```
      <foo=pub=bar>
  ```

  是下面这种形式的简写

  ```
      $<foo> = $<pub> = <bar>
  ```

  ​

  类似地, 你也能给其它断言起别名, 例如:

  ```
      <foo=[abc]>    # 字符类, 等同于      $<foo>=<[abc]>
      <foo=:Letter>  # unicode 属性,等同于 $<foo>=:Letter>
      <foo=:!Letter> # a negated unicode property lookup
  ```

  如果标识符后面的第一个字符是空格, 则随后的文本(跟着任意空格)被解析为 regex, 所以:

  ```
      <foo bar>
  ```

  或多或少,等价于

  ```
      <foo(/bar/)>
  ```

要传递一个带有前置空格的 regex, 你必须使用加上括弧的形式。

如果标识符后面的第一个字符是一个`冒号后再跟着空格`, 那么闭合尖括号之前的剩余文本会被当作方法的参数列表, 就像普通 Perl 语法中的那样。所以这些意味着相同的东西:  ​

  [`S05-grammar/signatures.t lines 7–24`](https://github.com/perl6/roast/blob/master/S05-grammar/signatures.t#L7-L24)

  ```
      <foo('foo', $bar, 42)>
      <foo: 'foo', $bar, 42>
  ```

起始标识符的后面不再允许有其它字符。

  Subrule matches are considered declarative to the extent that the front of the subrule is itself considered declarative. If a subrule contains a sequence point, then so does the subrule match. Longest-token matching does not proceed past such a subrule, for instance.

  ​

  This form always gives preference to a lexically scoped regex declaration, dispatching directly to it as if it were function. If there is no such lexical regex (or lexical method) in scope, the call is dispatched to the current grammar, assuming there is one. 即, 如果从当前本地作用域有一个可见的 `my regex foo` 声明, 那么:

  ```
      <foo(1,2,3)>
  ```

等价于:

  ```
      <foo=&foo(1,2,3)>
  ```

  However, if there is no such lexically scoped regex (and note that within a grammar, regexes are installed as methods which have no lexical alias by default), then the call is dispatched as a normal method on the current `Cursor` (which will fail if you're not currently within a grammar). So in that case:

  ```
      <foo(1,2,3)>
  ```

等价于:

  ```
      <foo=.foo(1,2,3)>
  ```

  ​

  A call to `<foo>` will fail if there is neither any lexically scoped routine of that name it can call, nor any method of that name that be reached via method dispatch. (The decision of which dispatcher to use is made at compile time, not at run time; the method call is not a fallback mechanism.)

  ​

- 一个前置的 `.` 显式地把方法作为 subrule 调用; 实际上如果初始的字符不是字母数字会引起该具名断言不捕获它匹配到的东西。(查看 "Subrule captures") 例如:

  [`S05-metasyntax/angle-brackets.t lines 140–242`](https://github.com/perl6/roast/blob/master/S05-metasyntax/angle-brackets.t#L140-L242)

  ​

  ```
       / <ident>  <ws>  /      # $/<ident> 和 $/<ws> 都被捕获了
       / <.ident> <ws>  /      # 只有 $/<ws> 被捕获了
       / <.ident> <.ws> /      # 什么也没有捕获
  ```

  ​

  The assertion is otherwise parsed identically to an assertion beginning with an identifier, provided the next thing after the dot is an identifier. As with the identifier form, any extra arguments pertaining to the matching engine are automatically supplied to the argument list via the implicit `Cursor` invocant. If there is no current class/grammar, or the current class is not derived from `Cursor`, the call is likely to fail.

  ​

  If the dot is not followed by an identifier, it is parsed as a "dotty" postfix of some type, such as an indirect method call:

  ```
      <.$indirect(@args)>
  ```

  As with all regex matching, the current match state (some derivative of `Cursor`) is passed as the first argument, which in this case is simply the method's invocant. The method is expected to return a lazy list of new match state objects, or `Nil` if the match fails entirely. Ratcheted routines will typically return a list containing only one match.

  ​

- Whereas a leading `.` unambiguously calls a method, a leading `&` unambiguously calls a routine instead. Such a regex routine must be declared (or imported) with `my` or `our` scoping to make its name visible to the lexical scope, since by default a regex name is installed only into the current class's metaobject instance, just as with an ordinary method. The routine serves as a kind of private submethod, and is called without any consideration of inheritance. It must still take a `Cursor` as its first argument (which it can think of as an invocant if it likes), and must return the new match state as a cursor object. Hence,

  [`S05-metasyntax/interpolating-closure.t lines 17–39`](https://github.com/perl6/roast/blob/master/S05-metasyntax/interpolating-closure.t#L17-L39)

  ```
       <&foo(1,2,3)>
  ```

  is sugar for something like:

  ```
       <.gather { take foo($¢,1,2,3) }>
  ```

  where `$¢` represents the current incoming match state, and the routine must return `Nil` for failure, or a lazy list of one or more match states (`Cursor`-derived objects) for successful matches.

  As with the `.` form, an explicit `&` suppresses capture.

  Note that all normal `Regex` objects are really such routines in disguise. When you say:

  ```
      rx/stuff/
  ```

  you're really declaring an anonymous method, something like:

  ```
      my $internal = anon regex :: ($¢: ) { stuff }
  ```

  and then passing that object off to someone else who will call it indirectly. In this case, the method is installed neither into a class nor into a lexical scope, but as long as the value stays live somehow, it can still be called indirectly (see below).

  ​

- A leading `$` indicates an indirect subrule call. The variable must contain either a `Regex` object (really an anonymous method--see above), or a string to be compiled as the regex. The string is never matched literally.

  If the compilation of the string form fails, the error message is converted to a warning and the assertion fails.

  ​

  The indirect subrule assertion is not captured. (No assertion with leading punctuation is captured by default.) You may always capture it explicitly, of course:

  ```
      / <name=$rx> /
  ```

  An indirect subrule is always considered procedural, and may not participate in longest-token matching.

  ​

- A leading `::` indicates a symbolic indirect subrule:

  ```
       / <::($somename)> /
  ```

  ​

  The variable must contain the name of a subrule. By the rules of single method dispatch this is first searched for in the current grammar and its ancestors. If this search fails an attempt is made to dispatch via MMD, in which case it can find subrules defined as multis rather than methods. This form is not captured by default. It is always considered procedural, not declarative.

  ​

- A leading `@` matches like a bare array except that each element is treated as a subrule (string or `Regex` object) rather than as a literal. That is, a string is forced to be compiled as a subrule instead of being matched literally. (There is no difference for a `Regex` object.)

  This assertion is not automatically captured.

  ​

- The use of a hash as an assertion is reserved.

- A leading `{` indicates code that produces a regex to be interpolated into the pattern at that point as a subrule:

  ```
       / (<.ident>)  <{ %cache{$0} //= get_body_for($0) }> /
  ```

  ​

  The closure is guaranteed to be run at the canonical time; it declares a sequence point, and is considered to be procedural.

  ​

- In any case of regex interpolation, if the value already happens to be a `Regex` object, it is not recompiled. If it is a string, the compiled form is cached with the string so that it is not recompiled next time you use it unless the string changes. (Any external lexical variable names must be rebound each time though.) Subrules may not be interpolated with unbalanced bracketing. An interpolated subrule keeps its own inner match results as a single item, so its parentheses never count toward the outer regexes groupings. (In other words, parenthesis numbering is always lexically scoped.)

- 在 `<...>` 中, 一个前置的 `?{` 或 `!{` 标示着代码断言:
  [`S05-metasyntax/assertions.t lines 7–25`](https://github.com/perl6/roast/blob/master/S05-metasyntax/assertions.t#L7-L25)

  ```
       / (\d**1..3) <?{ $0 < 256 }> /
       / (\d**1..3) <!{ $0 < 256 }> /
  ```

  类似于:

  ```
       / (\d**1..3) { $0 < 256 or fail } /
       / (\d**1..3) { $0 < 256 and fail } /
  ```

  ​

  Unlike closures, code assertions are considered declarative; they are not guaranteed to be run at the canonical time if the optimizer can prove something later can't match. So you can sneak in a call to a non-canonical closure that way: 不像闭包那样, 代码断言被认为是陈述性质的; 

  ​

  ```
     my $str = "foo123bar";
     $str  ~~ token { foo .* <?{ do { say "Got here!" } or 1 }> .* bar } # Got here!

  ```

  `do` block 不太可能运行,除非字符串以 "bar" 结尾.

- 一个前置的 `[` 标示着可枚举的字符类. 在枚举字符类中, 范围是由 `..` 而非 `-` 来标示的.
  [`S05-metasyntax/charset.t lines 18–22`](https://github.com/perl6/roast/blob/master/S05-metasyntax/charset.t#L18-L22)
  [`S05-mass/rx.t lines 248–262`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L248-L262)
  [`S05-mass/rx.t lines 283–428`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L283-L428)

  ​

  ```
       / <[a..z_]>* /
  ```

  方括号内的`空白`被忽略:

  ```
       / <[ a .. z _ ]>* /
       / <[ . _ ]>* /
  ```

  ​

  反转的范围是非法的. 在直接编译的代码中会报错如果你写成这样:

  ```
      / <[ z .. a ]> /  # 反转的范围是不允许的
  ```

  在间接编译的代码中, 出现类似的问题并使断言失败:

  ```
      $rx = '<[ z .. a ]>';
      / <$rx> /;  # warns and never matches
  ```

  ​

-  前置的 `-` 标示互补字符类:
  [`S05-metasyntax/charset.t lines 23–27`](https://github.com/perl6/roast/blob/master/S05-metasyntax/charset.t#L23-L27)
  [`S05-mass/rx.t lines 263–282`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L263-L282)

  ```
       / <-[a..z_]> <-alpha> /
       / <- [a..z_]> <- alpha> /  #  - 后面允许有空格
  ```

  这在本质上与使用 `否定向前查看` 和 `点` 是相同的.

  ```
      / <![a..z_]> . <!alpha> . / # `!`标示前面不是什么
  ```

  初始的 `-` 之后的空白被忽略.

  ​

- 一个前置的 `+` 也能标示后面的字符类会以肯定的意义匹配:
  [`S05-mass/rx.t lines 511–2140`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L511-L2140)

  ```
       / <+[a..z_]>* /
       / <+[ a..z _ ]>* /
       / <+ [ a .. z _ ] >* /      # whitespace allowed after +
  ```

  ​

- 在单个尖括号集中, 字符类可以组合(相加或相减). 空白被忽略. 例如:
  [`S05-metasyntax/charset.t lines 28–96`](https://github.com/perl6/roast/blob/master/S05-metasyntax/charset.t#L28-L96)

  ```
       / <[a..z] - [aeiou] + xdigit> /      # 辅音或十六进制数
  ```

  ​

  一个具名的字符类可以使用它自己:

  ```
      <alpha>
  ```

  然而, 为了组合字符类, 必须在`具名`字符类前面前置一个 `+` 或 `-`。在任何 `-` 可能会被误解析为一个标识符扩展器的前面需要有空格。

- 使用 pair 记法代替一个正常的 rule 的名字来标记 Unicode 属性:

  [`S05-metasyntax/unicode-property-pair.t lines 6–21`](https://github.com/perl6/roast/blob/master/S05-metasyntax/unicode-property-pair.t#L6-L21)

  ​

  ```
      <:Letter>   # a letter
      <:!Letter>  # a non-letter
  ```

  ​

  带参数的属性作为参数传递给 pair:

  ```
      <:East_Asian_Width<Narrow>>
      <:!Blk<ASCII>>
  ```

  ​

  The pair value is smartmatched against the value in the Unicode database.

  ```
      <:Nv(0 ^..^ 1)>     # Nv 代表数值, 该正则匹配特有分数值的字符

      'flubber¼½worms' ~~ /<:NumericValue(0 ^..^ 1)>+/;  # ~$/ => ¼½
  ```

  ​
  作为智能匹配的一种特殊情况, TR18 的第 2.6 章节也允许使用模式作为参数:

  ```
      <:name(/^LATIN LETTER.*P$/)>

      'FooBar' ~~ /<:name(/:s LATIN SMALL LETTER/)>+/;     #  'oo', 'match character names';
      'FooBar' ~~ /<:Name(/:s LATIN CAPITAL LETTER/)>+/;   #  'F',  'match character names';
  ```

  ​

- 多个这样的 terms 可以使用加号和减号组合到一块儿:

  ```
      <+ :HexDigit - :Upper >
  ```

  ​

  Terms may also be combined using `&` for set intersection, `|` for set union, and `^` for symmetric set difference. Parens may be used for grouping. (Square brackets always quote literal characters (including backslashed literal forms), and may not be nested, unlike the suggested notation in TR18 section 1.3.) The precedence of the operators is the same as the correspondingly named operators in ["Operator precedence" in S03](http://design.perl6.org/S03.html#Operator_precedence), even though they have somewhat different semantics.

  ​

- 额外的长字符可以通过引用来键入并通过交叉来包含。合适的时候,任何引起的字符都会被当作"最长 tokens"。 这儿 'll' 会在 'l' 之前被识别:

  ```
      / <[ a..z ] | 'ñ' | 'ch' | 'll' | 'rr'>
  ```

  ​

  Note that a negated character class containing "long characters" always advances by a single character.

  ​

- When any character constructor such as `\c`, `\x`, or `\o` contains multiple values separated by commas, these are treated as "long characters". So you could add a `\c[13,10]` to the list above to match CRLF as a long character.

  A consequence of this is that the negated form advances by a single position (matching as `.` does) when the long character doesn't match as a whole. Hence, this matches:

  ​

  ```
      "\c[13,13,10,10]" ~~ /\C[13,10]* \c[13,10] \C[13,10]/;
  ```

  ​

  If you want it to mean \C13\C10 instead, then you can just write it that way.

  ​

- 一个前置的 `!` 标示否定的意思(总是一个零宽断言):

  [`S05-metasyntax/angle-brackets.t lines 243–321`](https://github.com/perl6/roast/blob/master/S05-metasyntax/angle-brackets.t#L243-L321)
  [`S05-mass/rx.t lines 2141–2377`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L2141-L2377)

  ​

  ```
       / <!before _ > /    # 我们不在 _ 前面
  ```

  ​

  注意 `<!alpha>` 和 `<-alpha>` 是不同的.  `/<-alpha>/` 是一个互补字符类 , 它等价于 `/<!before <alpha>> ./`,  而 `<!alpha>` 是一个零宽断言, 它等价于  `/<!before <alpha>>/` .

  还要注意作为一个元字符, `!`不改变它后面所跟的任何东西的解析规则(这点与 + 或 - 不同)

- 一个前置的 `?` 标示正向的零宽断言, 并且像 `!` 只是重新递归解析剩下的断言, 就像 `?` 不存在那一样. 此外, 要强制零宽断言, 它也能抑制任何具名捕获:
  [`S05-mass/rx.t lines 429–451`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L429-L451)

  ```
      <alpha>     # 匹配一个字母,并捕获到 `$alpha` (最终是捕获到 $<alpha>)
      <.alpha>    # 匹配一个字母,不捕获
      <?alpha>    # match null before a letter, 不捕获
  ```

  特殊的具名断言包括:
  [`S05-metasyntax/lookaround.t lines 13–27`](https://github.com/perl6/roast/blob/master/S05-metasyntax/lookaround.t#L13-L27)
  [`S05-mass/rx.t lines 452–510`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L452-L510)
  [`S05-mass/charsets.t lines 5–59`](https://github.com/perl6/roast/blob/master/S05-mass/charsets.t#L5-L59)
  [`S05-mass/stdrules.t lines 15–309`](https://github.com/perl6/roast/blob/master/S05-mass/stdrules.t#L15-L309)

  ​

  ```
       / <?before pattern> /    # lookahead  向前查看
       / <?after pattern> /     # lookbehind 向后查看
  ```

  ```
       / <?same> /              # true between two identical characters
  ```

  ```
       / <.ws> /                # match "whitespace":
                                #   \s+ if it's between two \w characters,
                                #   \s* otherwise
  ```

  ```
       / <?at($pos)> /          # 只在特定位置匹配
                                # 是 <?{ .pos === $pos }> 的简写形式
                                # (considered declarative until $pos changes)
  ```

  ​通过省略前面的标点符号把这些断言作为具名捕获使用是合法的。然而, 捕获需要一些内存和计算消耗, 所以你一般会抑制捕获不感兴趣的数据。

 `after` 断言通过反转语法树并以与左相反的顺序查找东西来实现向后查看。在不能反转的模式上做向后查看是违反规则的。  ​

  Note: the effect of a forward-scanning lookbehind at the top level can be achieved with:

  ```
      / .*? prestuff <( mainpat )> /
  ```

- 一个前置的 `*` 标示后面的模式允许部分匹配. 匹配尽可能多的字符之后,它总是能成功. (它不是零宽的除非它匹配了0个字符). 例如, 要匹配一些缩写词, 你可以写下面任意一个:

  ```
      s/ ^ G<*n|enesis>     $ /gen/  or
      s/ ^ Ex<*odus>        $ /ex/   or
      s/ ^ L<*v|eviticus>   $ /lev/  or
      s/ ^ N<*m|umbers>     $ /num/  or
      s/ ^ D<*t|euteronomy> $ /deut/ or
      ...
  ```

  ```
      / (<* < foo bar baz > >) /
  ```

  ```
      / <short=*@abbrev> / and return %long{$<short>} || $<short>;
  ```

  ​

  The pattern is restricted to declarative forms that can be rewritten as nested optional character matches. Sequence information may not be discarded while making all following characters optional. That is, it is not sufficient to rewrite:

  ​

  ```
      <*xyz>
  ```

  as:

  ```
      x? y? z?            # bad, would allow xz
  ```

  Instead, it must be implemented as:

  ```
      [x [y z?]?]?        # allow only x, xy, xyz (and '')
  ```

  Explicit quantifiers are allowed on single characters, so this:

  ```
      <* a b+ c | ax*>
  ```

  is rewritten as something like:

  ```
      [a [b+ c?]?]? | [a x*]?
  ```

  In the latter example we're assuming the DFA token matcher is going to give us the longest match regardless. It's also possible that quantified multi-character sequences can be recursively remapped:

  ​

  ```
      <* 'ab'+>     # match a, ab, ababa, etc. (but not aab!)
      ==> [ 'ab'* <*ab> ]
      ==> [ 'ab'* [a b?]? ]
  ```

  ​

  [Conjecture: depending on how fancy we get, we might (or might not) be able to autodetect ambiguities in `<*@abbrev>` and refuse to generate ambiguous abbreviations (although exact match of a shorter abbrev should always be allowed even if it's the prefix of a longer abbreviation). If it is not possible, then the user will have to check for ambiguities after the match. Note also that the array form is assuming the array doesn't change often. If it does, the longest-token matcher has to be recalculated, which could get expensive.]

  ​

- A leading `~~` indicates a recursive call back into some or all of the current rule. An optional argument indicates which subpattern to re-use, and if provided must resolve to a single subpattern. If omitted, the entire pattern is called recursively:

  ```
      <~~>       # call myself recursively
      <~~0>      # match according to $0's pattern
      <~~foo>    # match according to $<foo>'s pattern
  ```

  ​

  Note that this rematches the pattern associated with the name, not the string matched. So

  ```
      $_ = "foodbard"
  ```

  ```
      / ( foo | bar ) d $0 /      # fails; doesn't match "foo" literally
      / ( foo | bar ) d <$0> /    # fails; doesn't match /foo/ as subrule
      / ( foo | bar ) d <~~0> /   # matches using rule associated with $0
  ```

最后那个等价于

  ```
      / ( foo | bar ) d ( foo | bar ) /
  ```

  Note that the "self" call of

  ```
      / <term> <operator> <~~> /
  ```

  calls back into this anonymous rule as a subrule, and is implicitly anchored to the end of the operator as any other subrule would be. Despite the fact that the outer rule scans the string, the inner call to it does not.

  ​

  Note that a consequence of the previous section is that you also get

  ```
      <!~~>
  ```

  ​

  for free, which fails if the current rule would match again at this location.

  ​

- 一个前置的 `|` 标示某种零宽边界. 使用这个语法你可以引用反引号序列; `<|h>` 会在 \h 和  \H 之间匹配, 例如. 一些例子:

  ```
      <|w> 单词边界
      <|g> 字素边界 (总是在字素模式下匹配)
      <|c> 代码点边界 (总是在 `字素/代码点` 模式下匹配)
  ```

  ​

The following tokens include angles but are not required to balance:
下面的 tokens 包含尖号但平衡不是必须的:


- `<(` token 标示匹配的全部捕获的开头, 而对应的 `)>` token 标示它的终点。当匹配后, 这些表现像断言的总为真, 但是有设置匹配对象的 `.from` 和 `.to` 属性的副作用。即：
indicates the start of the match's overall capture, while the corresponding `)>` token indicates its endpoint. When matched, these behave as assertions that are always true, but have the side effect of setting the `.from` and `.to` attributes of the match object. That is:

  ```
      / foo <( \d+ )> bar /
  ```

  等价于:

  ```
      / <?after foo> \d+ <?before bar> /
  ```

  ​

  except that the scan for "`foo`" can be done in the forward direction, while a lookbehind assertion would presumably scan for `\d+` and then match "`foo`" backwards. The use of `<(...)>` affects only the positions of the beginning and ending of the match, and anything calculated based on those positions. For instance, after the match above, `$()` contains only the digits matched, and `$/.to` is pointing to after the digits. Other captures (named or numbered) are unaffected and may be accessed through `$/`.

  ​

  When used directly within quantifiers (that is, within quantified square brackets), there is only one `Match` object to set `.from`/`.to` on, so the `<(` token always sets `.from` to the leftmost matching position, while `)>` always sets `.to` to the rightmost position. However, the situation is different for capturing parentheses. When used within parentheses (whether or not the parens are quantified), the `Match` being generated by each dynamic capture serves as the target, so each such capturing group sets its own `.from`/`.to`. Hence, if the group is quantified, each capture sets its own boundaries independently.

  ​

  These tokens are considered declarative.
  这些令牌被认为是声明性的。

  ​

- `«` 或 `<<` token 标示左单词边界。 `»` 或 `>>` token 标示右单词边界。(作为单独的 tokens, 这些 tokens 不需要保持平衡)。Perl 5'的 `\b` 被 `<|w>` "单词边界" 断言代替, 而 `\B` 变为 ``. (None of these are dependent on the definition of `<.ws>`, but only on the `\w` definition of "word" characters. Non-space mark characters are ignored in calculating word properties of the preceding character. See TR18 1.4.)



# 预定义 Subrules


下面这些是为任意 grammar 或 regex 预定义好的 `subrules`:



- ident 

  匹配一个标识符.

- upper 

  匹配单个大写字符.

- lower 

  匹配单个小写字符.

- alpha 

  匹配单个字母字符, 或者是一个下划线.

  要匹配不带下划线的 Unicode 字母字符, 使用 `<:alpha>`.

- digit 

  匹配单个数字.

- xdigit 

  匹配单个十六进制数字.

- print 

  匹配单个可打印字符.

- graph 

  匹配单个图形字符.

- cntrl 

  匹配单个控制字符. (等价于 <:Cc> 属性). 控制字符通常不产生输出, 相反, 它们以某种方式控制末端:例如换行符和退格符都是控制字符. 所有使用 `ord()` 之后小于 32 的字符通常归类为控制字符. 就像 ord() 的值为 127 的字符是控制字符(DEL) 一样, 128 到 159 之间的也是控制字符.

- punct 

  匹配单个标点符号字符(即, 任何来自于 Unicode General Category "Punctuation" 的字符).

- alnum 

  匹配单个字母数字字符. 那等价于 `<+alpha +digit>` .

- wb 

  在单词边界匹配成功并返回一个零宽匹配.  一个单词边界是这样一个点, 它的一边是一个 `\w`, 另一边是一个 `\W`. (以任一顺序),  字符串的开头和结尾被看作为匹配 `\W`.

- ww 

  在两个单词字符之间匹配(零宽匹配).

- ws 

  在两个单词字符之间匹配要求的空白, 否则匹配可选的空白. 这等价于 ` \s*` (`ws` 不要求使用 `ww` subrule).

- space 

  匹配单个空白字符character (和 `\s 相同 `).

- blank 

  匹配单个 "blank" 字符 -- 在大部分区域, 这相当于 `space` 和 `tab`.

- before `pattern`

  执行向前查看-- 例如, 检查我们是否在某个能匹配的位置. 如果匹配成功返回一个零宽 Match 对象.

- after `pattern`

  执行向后查看 --例如,检查当前位置之前的字符串是否匹配 `<pattern>`(在结尾锚定). 如果匹配成功就返回一个零宽 Match 对象. 

- <?> 

  匹配一个 null 字符串,即, 总是返回真. 

- <!> 

  `<?>` 的反转, 总是返回假
  [`S05-mass/stdrules.t lines 310–326`](https://github.com/perl6/roast/blob/master/S05-mass/stdrules.t#L310-L326)

  ​



# 反斜线改良


- 很多 `\p` 和 `\P` 属性变成诸如 `<alpha>` 和 `<-alpha>` 等内在的 grammar rules. 它们可以使用上面提到的字符类标记法进行组合.`<[-]+alpha+digit>`. 不管高层级字符类的名字, 所有的低层级 Unicode 属性总是可以使用一个前置冒号访问, 即, 在尖括号中使用 pair 标记法.因此 `<+:Lu+:Lt>` 等价于 `<+upper+title>`.

-  `\L...\E`, `\U...\E`, 和 `\Q...\E` 序列被废弃了. 单个字符的大小写修饰符 `\l` 和 `\u` 也被废弃了. 在极少需要使用它们的地方, 你可以使用 `<{ lc $regex }>`, `<{tc $word}>`, 等.

- 就像上面提到的, `\b` 和 `\B` 单词边界断言被废弃了, 并且被 `<|w>` (或 `<wb>`) 和 `<!|w>` (或 `<!wb>`) 零宽断言代替.

- `\G`  序列也没有了. 使用 `:p` 代替. (注意, 虽然, 在模式内使用 `:p` 没有影响, 因为每个内部模式都被隐式的锚定到当前位置) 查看下面的 at 断言.

- 向后引用 (例如. `\1`, `\2`, 等.) 都没有了; 可以使用 `$0`, `$1`, 等代替. 因为正则中变量不再进行插值.
  [`S05-capture/dot.t lines 56–61`](https://github.com/perl6/roast/blob/master/S05-capture/dot.t#L56-L61)

  ​

  数字变量被假定是每次都会改变的, 因此被看作是程序化的, 不像普通变量那样.

  ​

-  新的反斜线序列, `\h` 和 `\v`, 分别匹配水平空白和垂直空白, 包括 Unicode. 水平空白被定义为任何匹配 `\s` 并且不匹配 `\v` 的东西. 垂直空白被定义为下面的任一方式:

  ```
      U+000A  LINE FEED (LF)
      U+000B  LINE TABULATION
      U+000C  FORM FEED (FF)
      U+000D  CARRIAGE RETURN (CR)
      U+0085  NEXT LINE (NEL)
      U+2028  LINE SEPARATOR
      U+2029  PARAGRAPH SEPARATOR
  ```

  ​

  注意 `U+000D` (CARRIAGE RETURN) 被认为是垂直空白.

  ​

- `\s` 现在匹配任何 Unicode 空白字符.

- 新的反斜线序列和 `\N` 匹配除逻辑换行符之外的任何字符, 它是 `\n` 的否定.

- 其它新的大写的反斜线序列也都是它们小写身份的反义:

  - `\H` 匹配任何非水平空白字符.
  - `\V` 匹配任何非垂直空白字符.
  - `\T` 匹配任何非 tab 字符.
  - `\R` 匹配任何非 return 字符.
  - `\F` 匹配任何非格式字符.
  - `\E` 匹配任何非转义字符.
  - `\X...` 匹配任何非指定的(指定为十六进制)字符.
  - 在普通字符串中反斜线转义字面字符串在 regexes 中是允许的(\a, \x 等等). 然而, 这个规则的例外是 `\b`., 它被禁用了,为了避免跟之前作为单词边界断言冲突. 要匹配字面反斜线, 使用 `\c8`, `\x8`或双引号引起的 `\b`.



# 便捷的字符类

因为历史原因和使用方便, 下面的字符类可以作为反斜线序列使用:



```
   \d      <digit>    A digit
   \D      <-digit>   A nondigit
   \w      <alnum>    A word character
   \W      <-alnum>   A non-word character
   \s      <sp>       A whitespace character
   \S      <-sp>      A non-whitespace character
   \h                 A horizontal whitespace
   \H                 A non-horizontal whitespace
   \v                 A vertical whitespace
   \V                 A non-vertical whitespace
```



# Regexes构成一等语言

而不仅仅是字符串.

- Perl 5 的 `qr/pattern/` 正则构造器滚蛋了.

- Perl 6 中的正则构造:

  ```
       regex { pattern }    # 总是把 {...} 作为模式分隔符
       rx    / pattern /    # 几乎能使用任何字符作为模式分割符
  ```
  [`S05-metasyntax/delimiters.t lines 6–20`](https://github.com/perl6/roast/blob/master/S05-metasyntax/delimiters.t#L6-L20)

  ​

  你不能使用空格或字母数字作为分隔符.你可以使用圆括号作为你的 rx 分隔符, 但是这只有当你插入空格时才行(标识符后面直接跟着圆括号会被认为是函数调用):

  ​

  ```
       rx ( pattern )      # okay
       rx( 1,2,3 )         # tries to call rx function
  ```

  ​

  (在 Perl 6 中 这对所有类似 quotelike 的结构都适用.)

  ​

 `//` 匹配能使用的地方 `rx` 这种形式也能直接作为模式使用. `regex` 这种形式实际上是一个方法定义, 必须用于 grammar 类中.



- 如果 `regex` 或 `rx` 需要修饰符, 就把修饰符直接放在开放分隔符前面:

  ```
       $regex = regex :s:i { my name is (.*) };
       $regex = rx:s:i     / my name is (.*) /;    # same thing

  ```

  ​

  如果使用任何括号字符作为分隔符, 那么最后的修饰符之后是需要空格的. ( 否则, 它会被看作修饰符的参数)

  ​

- 不能使用冒号作为分隔符. 修饰符之间可以有空格:

  ```
       $regex = rx :s :i / my name is (.*) /;
  ```

  ​

- 正则构建器的名字是从 qr 修改而来, 因为它不再是一个能插值的 quote-like 操作符. `rx` 是 `regex` 的简写形式.(不要对regular expressions 感到困惑, 除了它们是的时候 )

- 像语法指示的那样, 它现在跟 `sub { ... }` 构建器很像. 实际上, 这种类似物深深根植于 Perl 6 中.

- 就像一个原始的 `{...}`现在总是一个闭包 (它仍然能在特定上下文中被立即执行并在其它上下文中作为对象传递), 所以原始的 `/.../` 总是一个 `Regex` 对象(它可能仍然在特定上下文中被立即匹配并在其它上下文中作为对象传递.)

- 特别地, 在 value 上下文(`sink`, `Boolean`, `string` 或 `numeric`),或它是 `~~` 的显式参数时, `/.../`会立即匹配. 否则, 它就是一个跟显式的 regex 形式同一的`Regex` 构建器, 所以这个:

  ```
       $var = /pattern/;
  ```

  ​

  不再进行匹配并把结果设置为 `$var`. 相反, 它把一个 `Regex` 对象赋值给 `$var`.

  ​

- 这种情况总是可以使用 `m{...}` 或 `rx{...}`进行区分:

  ```
       $match = m{pattern};    # 立刻匹配 regex, 然后把匹配结果赋值给变量
       $regex = rx{pattern};   # Assign regex expression itself
  ```

  ​

- 注意前面有个像这样魔法般的用法:

  ```
       @list = split /pattern/, $str;
  ```

  ​

  现在来看就是理所当然的了.

  ​

- 就是现在, 建立一个像 grep 那样的用户自定义子例程也成为可能:

  ```
       sub my_grep($selector, *@list) {
           given $selector {
               when Regex { ... }
               when Code  { ... }
               when Hash  { ... }
               # etc.
           }
       }
  ```

  ​

  当你调用 `my_grep` 时, 第一个参数被绑定到 item 上下文, 所以传递 `{...}` 或 `/.../` 产生 `Code` 或 `Regex` 对象,  switch 语句随后选中它作为条件.(正常的 grep 只是让智能匹配操作符做了所有的工作)

  ​

- 就像 `rx` 拥有变体一样, `regex` 声明符也有. 特别地, regex 有两个用在 grammars 中的变体: `token` 和 `rule`.

  token声明长这样:

  ​

  ```
      token ident { [ <alpha> | \- ] \w* }
  ```

  ​

  默认**从不回溯**. 即, 它倾向于保留任何目前位置扫描到的东西.所以,上面的代码等价于:

  ​

  ```
      regex ident { [ <alpha>: | \-: ]: \w*: }
  ```

  ​

  但是相当易读. 在 token 中裸的 `*`, `+` 和 `?` 量词绝不回溯. 在普通的 regexes 中, 使用 `*:`, `+:`, 或 `?:` 阻止量词的回溯. 如果你确实要回溯, 在量词后面添加 `?` 或 `!`.  `?` 像平常一样进行非懒惰匹配, 而 `!` 强制进行贪婪匹配. `token` 声明符就是

```
    regex :ratchet { ... }
```

的简写.

另外一个是 `rule` 声明符, 像 token 一样, 它默认也不会回溯. 此外, 一个 `rule` 这样的正则表达式也采取了 `:sigspace` 修饰符. `rule` 实际上是



```
    regex :ratchet :sigspace { ... }
```

的简写.  ratchet 这个单词的意思是: (防倒转的)棘齿, 意思它是不能回溯的!


-  Perl 5 的 `?...?` 语法(成功一次)极少使用, 并且现在能使用 `state` 变量以更清晰的方式模拟:

  ```
      $result = do { state $x ||= m/ pattern /; }    # 只在第一次匹配
  ```

  要重置模式, 仅仅让 `$x = 0` 尽管你想要 `$x` 可见, 你还是必须避免使用 block:

  ```
      $result = state $x ||= m/ pattern /;
      ...
      $x = 0;
  ```

  ​



# 回溯控制

在这些被认为是程序的而非陈述性的模式的部分中, 你可以控制回溯行为.



- 默认的, 在 `rx`,`m`, `s` 中的回溯是贪婪的. 在普通的 regex 声明中它们也是贪婪的. 在 rule 和 token 声明中, 回溯必须是显式的.

- 为了强制前面的原子执行节俭回溯(有时也是所谓的"急切的匹配" 或 "最少化的匹配"), 要在原子后面追加一个 `:?` 或 `?`. 如果前面的 token 是一个量词, `:` 就可以被省略, 所以 `*?` 就像在 Perl 5 中那样起作用.

- 为了强制前面的原子执行贪婪回溯, 在原子后面追加一个 `:!`.  如果前面的 token 是一个量词, `:` 可以被省略. (Perl 5 没有对应的结构, 因为在 Perl 5 中回溯默认是贪婪的.)

- 为了强制前面的原子不执行回溯, 使用不带 `?` 或 `!` 的单个 `:`.  单个冒号让正则引擎不再重试前面的原子:
  [`S05-mass/rx.t lines 8–32`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L8-L32)

  ```
       ms/ \( <expr> [ , <expr> ]*: \) /
  ```

  (i.e. there's no point trying fewer `` matches, if there's no closing parenthesis on the horizon)

  当修饰一个量词的时候,  可以使用 `+` 代替 `:`, 这种情况下, 量词常常是所谓的占有量词.

  ```
       ms/ \( <expr> [ , <expr> ]*+ \) /  # same thing
  ```

  为了强制表达式中所有的原子默认不去回溯, 要使用 `:ratchet` 或 `rule` 或 `token`.

  ​

- Evaluating a double colon throws away all saved choice points in the current LTM alternation.
  [`S05-mass/rx.t lines 33–51`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L33-L51)

  ​

  ```
       ms/ [ if :: <expr> <block>
           | for :: <list> <block>
           | loop :: <loop_controls>? <block>
           ]
       /
  ```

  ​
(`::`) 还没有实现。
  (i.e. there's no point trying to match a different keyword if one was already found but failed).

  ​

  The `::` also has the effect of hiding any declarative match on the right from "longest token" processing by `|`. Only the left side is evaluated for determinacy.

  ​

  `::` does nothing if there is no current LTM alternation. "Current" is defined dynamically, not lexically. A `::` in a subrule will affect the enclosing alternation.

  ​

- Evaluating a `::>` throws away all saved choice points in the current innermost temporal alternation. It thus acts as a "then".

  ```
      ms/ [
          || <?{ $a == 1 }> ::> <foo>
          || <?{ $a == 2 }> ::> <bar>
          || <?{ $a == 3 }> ::> <baz>
          ]
      /
  ```

  ​

  Note that you can still back into the "then" part of such an alternation, so you may also need to put `:` after it if you also want to disable that. If an explicit or implicit `:ratchet` has disabled backtracking by supplying an implicit `:`, you need to put an explicit `!` after the alternation to enable backing into, say, the `` rule above.

  ​

  `::>` does nothing if there is no current temporal alternation. "Current" is defined dynamically, not lexically. A `::>` in a subrule will affect the enclosing alternation.

  ​

- Evaluating a triple colon throws away all saved choice points since the current regex was entered. Backtracking to (or past) this point will fail the rule outright (no matter where in the regex it occurs):
  [`S05-mass/rx.t lines 52–91`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L52-L91)

  ​

  ```
       regex ident {
             ( [<alpha>|\-] \w* ) ::: { fail if %reserved{$0} }
           || " [<alpha>|\-] \w* "
       }
      ms/ get <ident>? /
  ```

  ​
`:::` 还未在 rakudo 中实现。
  (i.e. using an unquoted reserved word as an identifier is not permitted)

  ​

- Evaluating a `commit` assertion throws away all saved choice points since the start of the entire match. Backtracking to (or past) this point will fail the entire match, no matter how many subrules down it happens:

  ```
       regex subname {
           ([<alpha>|\-] \w*) <commit> { fail if %reserved{$0} }
       }
       ms/ sub <subname>? <block> /
  ```

  ​

  (i.e. using a reserved word as a subroutine name is instantly fatal to the *surrounding* match as well)

  ​

  If commit is given an argument, it's the name of a calling rule that should be committed:

  ​

  ```
      <commit('infix')>
  ```

  ​

- `cut` 断言总是匹配成功, 它的副作用是在逻辑上删除已经匹配到的字符串部分。Whether this actually frees up the memory immediately may depend on various interactions among your backreferences, the string implementation, and the garbage collector. In any case, the string will report that it has been chopped off on the front. It's illegal to use ` on a string that you do not have write access to.

  Attempting to backtrack past a `cut` causes the complete match to fail (like backtracking past a `commit`). This is because there's now no preceding text to backtrack into. This is useful for throwing away successfully processed input when matching from an input stream or an iterator of arbitrary length.

  ​



# Regex 子例程, 具名和匿名

- `sub` 和 `regex` 之间的类推更为相似.

- 就像你可以有匿名子例程和具名子例程...

- 所以你也可以有匿名正则和具名正则(还有 tokens 和 rules)

  ```
       token ident { [<alpha>|\-] \w* }
       # 然后...
       @ids = grep /<ident>/, @strings;
  ```

  ​

- 就像上面的例子标示的那样, 引用具名正则也是可以的, 例如:

  ```
       regex serial_number { <[A..Z]> \d**8 }
       token type { alpha | beta | production | deprecated | legacy }
  ```

  在其它作为具名断言的正则表达式中:

  ```
       rule identification { [soft|hard]ware <type> <serial_number> }
  ```

  ​

  这些使用关键字声明的 regexes 官方类型为 `method`, 是从 `Routine` 派生出来的.

  ​

  通常, 任何 subrule 的锚定是由它的调用上下文控制的. 当 regex, token, 或 rule 方法被作为 subrule 调用时, 前面被锚定到当前位置(与 `:p` 一样), 而后面没有被锚定, 因为调用上下文可能会继续解析. 然而, 当这样一个方法被直接智能匹配, 它会自动的锚定两端到字符串的开始和结尾. 因此, 你可以使用一个匿名的 regex 子例程作为单独的模式来直接模式匹配:

  ​

  ```
      $string ~~ regex { \d+ }
      $string ~~ token { \d+ }
      $string ~~ rule  { \d+ }
  ```

  ​

  它们等价于

  ​

  ```
      $string ~~ m/^ \d+ $/;
      $string ~~ m/^ \d+: $/;
      $string ~~ m/^ <.ws> \d+: <.ws> $/;
  ```

  ​

  基本经验就是关键字定义的方法绝对不会做 `.*?` 那样的扫描, 而如引号那种形式的 `m//`和`s///` 在缺少显式锚定的时候会做这样的扫描.

  ​

  `rx//` 和`//` 这两种形式, 怎么扫描都可以: 当被直接用在智能匹配或布尔上下文中时, 但是当它被作为一个 subrule 间接被调用时,就不会扫描. 即, 当直接使用时, `rx//` 返回的对象表现的像 ` m//`, 但是用作 subrule 时, 表现的就像 `regex {}`:

  ​

  ```
      $pattern = rx/foo/;
      $string ~~ $pattern;                  # 等价于 m/foo/;
      $string ~~ /'[' <$pattern> ']'/       # 等价于 /'[foo]'/
  ```

  ​



# 空模式是非法的
  [`S05-mass/rx.t lines 2378–2392`](https://github.com/perl6/roast/blob/master/S05-mass/rx.t#L2378-L2392)
[`S05-metasyntax/null.t lines 17–25`](https://github.com/perl6/roast/blob/master/S05-metasyntax/null.t#L17-L25)

在 Perl 6 中, `Null regex` 是非法的：

``` perl
//
```

要匹配一个零宽字符, 需要显式地表示 null 匹配：

```
 / '' /;
 / <?> /;
```

例如：

```
split /''/, $string
```

 分割字符串。所以这样也行：

```
 split '', $string
```

同样地，匹配一个空的分支，使用这个：

```
 /a|b|c|<?>/
 /a|b|c|''/
```

更容易捕获错误：

```
/a|b|c|/
```

 作为一种特殊情况, 匹配中的第一个 null 分支会被忽略：

```
ms/ [
         | if :: <expr> <block>
         | for :: <list> <block>
         | loop :: <loop_controls>? <block>
    ]
  /
```

这在格式化 regex 时会有用。

但是注意, 只有`第一个分支`是特殊的, 如果你这样写：

```
ms/ [
             if :: <expr> <block>              |
             for :: <list> <block>             |
             loop :: <loop_controls>? <block>  |
    ]
  /
```

 就是错的。因为最后一个分支是 null 。
 然而, non-null句法结构有一种退化的情况能匹配 null 字符串:

```
     $something = "";
     /a|b|c|$something/;
```



特别地,  `<?>` 总是成功地匹配 null 字符串,  并且 `<!>` 总是让任何匹配都会失败.



# 最长 token 匹配


[`S05-metasyntax/longest-alternative.t lines 53–460`](https://github.com/perl6/roast/blob/master/S05-metasyntax/longest-alternative.t#L53-L460)

```perl
use v6;
use Test;

plan 55;

#L<S05/Unchanged syntactic features/"While the syntax of | does not change">

my $str = 'a' x 7;

{
    ok $str ~~ m:c(0)/a|aa|aaaa/, 'basic sanity with |';
    is ~$/, 'aaaa', 'Longest alternative wins 1';

    ok $str ~~ m:c(4)/a|aa|aaaa/, 'Second match still works';
    is ~$/, 'aa',   'Longest alternative wins 2';

    ok $str ~~ m:c(6)/a|aa|aaaa/, 'Third match still works';
    is ~$/, 'a',    'Only one alternative left';

    ok $str !~~ m:c(7)/a|aa|aaaa/, 'No fourth match';
}

# now test with different order in the regex - it shouldn't matter at all

#?niecza skip 'Regex modifier g not yet implemented'
{
    ok $str ~~ m:c/aa|a|aaaa/, 'basic sanity with |, different order';
    is ~$/, 'aaaa', 'Longest alternative wins 1, different order';

    ok $str ~~ m:c/aa|a|aaaa/, 'Second match still works, different order';
    is ~$/, 'aa',   'Longest alternative wins 2, different order';

    ok $str ~~ m:c/aa|a|aaaa/, 'Third match still works, different order';
    is ~$/, 'a',    'Only one alternative left, different order';

    ok $str !~~ m:c/aa|a|aaaa/, 'No fourth match, different order';
}

{
    my @list = <a aa aaaa>;
    ok $str ~~ m/ @list /, 'basic sanity with interpolated arrays';
    is ~$/, 'aaaa', 'Longest alternative wins 1';

    ok $str ~~ m:c(4)/ @list /, 'Second match still works';
    is ~$/, 'aa',   'Longest alternative wins 2';

    ok $str ~~ m:c(6)/ @list /, 'Third match still works';
    is ~$/, 'a',    'Only one alternative left';

    ok $str !~~ m:c(7)/ @list /, 'No fourth match';
}

# L<S05/Longest-token matching/>

{
    my token ab           { 'ab'     };
    my token abb          { 'abb'    };
    my token a_word       { a \w*    };
    my token word         { \w+      };
    my token indirect_abb { <ab> 'b' }

    # 'LTM - literals in tokens'
    ok ('abb' ~~ /<ab> | <abb> /) && ~$/ eq 'abb',
       'LTM - literals in tokens';

    # 'LTM - literals in nested tokens'
    ok ('abb' ~~ /<ab> | <indirect_abb> /) && $/ eq 'abb',
       'LTM - literals in nested torkens';

    ok ('abb' ~~ /'ab' | \w+ / && $/) eq 'abb',
       'LTM - longer quantified charclass wins against shorter literal';

    #?niecza todo 'LTM - longer quantified atom wins against shorter literal (subrules)'
    ok ('abb' ~~ /<ab> | <a_word> /) && $/ eq 'abb',
       'LTM - longer quantified atom wins against shorter literal (subrules)';

    #?niecza todo 'LTM - literal wins tie against \w*'
    ok ('abb' ~~ / <word> | <abb> /) && $<abb>,
       'LTM - literal wins tie against \w*';
}

#?rakudo skip ':: RT #124526'
{
    # with LTM stoppers
    my token foo1 {
        a+
        :: # a LTM stopper
        .+
    }
    my token foo2 { \w+ }

    #?niecza todo 'LTM only participated up to the LTM stopper ::'
    ok ('aaab---' ~~ /<foo1> | <foo2> /) && $<foo2>,
       'LTM only participated up to the LTM stopper ::';
}

# LTM stopper by implicit <.ws>
#?niecza todo 'implicit <.ws> stops LTM'
{
    my rule  ltm_ws1 {\w+ '-'+}
    my token ltm_ws2 {\w+ '-'}
    ok ('abc---' ~~ /<ltm_ws1> | <ltm_ws2>/) && $<ltm_ws2>,
       'implicit <.ws> stops LTM';
}

{
    # check that the execution of action methods doesn't stop LTM
    grammar LTM::T1 {
        token TOP { <a> | <b> }
        token a { \w+ '-' }
        token b { a+ <c>+ }
        token c { '-' }
    }

    class LTM::T1::Action {
        has $.matched_TOP;
        has $.matched_a;
        has $.matched_b;
        has $.matched_c;
        method TOP($/) { $!matched_TOP = 1 };
        method a($/)   { $!matched_a   = 1 };
        method b($/)   { $!matched_b   = 1 };
        method c($/)   { $!matched_c   = 1 };
    }
    my $o = LTM::T1::Action.new();
    ok LTM::T1.parse('aaa---', :actions($o)), 'LTM grammar - matched';
    is ~$/, 'aaa---', 'LTM grammar - matched full string';
    # TODO: find out if $.matched_a is allowed to be set
    ok $o.matched_TOP && $o.matched_b && $o.matched_c,
       'was in the appropriate action methods';
}

# various discovered longlit failure modes

{
    my $m = 'abc' ~~ / abc | 'def' 'ine' /;
    ok $m, "longer non-matcher parses";
    is $m.Str, "abc", "longer non-matching literal doesn't falsify shorter";
}

{
    grammar Galt {
        token TOP { <foo> | <bar> }
        token foo { \w\w }
        token bar { aa | <foo> }
    }
    my $m = Galt.subparse('bb');
    ok $m, "Galt parses";
    is $m<foo>.Str, 'bb', "literal from non-matching alternating subrule doesn't interfere";
}

{
    grammar Gproto {
        proto token TOP {*}
        multi token TOP:sym<foo> { <foo> }
        multi token TOP:sym<bar> { <bar> }

        token foo { \w\w }

        proto token bar {*}
        multi token bar:sym<foo> { <foo> }
        multi token bar:sym<aa>  { aa }
    }

    my $m = Gproto.subparse('bb');
    ok $m, "Gproto parses";
    is $m<foo>.Str, 'bb', "literal from non-matching proto subrule doesn't interfere";
}

{
    my $m = 'abcbarxyz' ~~ / abcbarx | abc [ foo | bar ] xyz /;
    ok $m, "subrule alternation with recombo matches";
    is $m.Str, 'abcbarxyz', "subrule alternation recombination doesn't confuse fates";
}

{
    grammar IETF::RFC_Grammar::IPv6 {
        token IPv6address       {
                                                    [ <.h16> ':' ] ** 6 <.ls32> |
                                               '::' [ <.h16> ':' ] ** 5 <.ls32> |
            [                        <.h16> ]? '::' [ <.h16> ':' ] ** 4 <.ls32> |
            [ [ <.sep_h16> ]?        <.h16> ]? '::' [ <.h16> ':' ] ** 3 <.ls32> |
            [ [ <.sep_h16> ] ** 0..2 <.h16> ]? '::' [ <.h16> ':' ] ** 2 <.ls32> |        
            [ [ <.sep_h16> ] ** 0..3 <.h16> ]? '::' <.h16> ':'          <.ls32> |
            [ [ <.sep_h16> ] ** 0..4 <.h16> ]? '::'                     <.ls32> |
            [ [ <.sep_h16> ] ** 0..5 <.h16> ]? '::'                     <.h16>  |
            [ [ <.sep_h16> ] ** 0..6 <.h16> ]? '::'                                      
        };

        # token avoiding backtracking happiness    
        token sep_h16           { [ <.h16> ':' <!before ':'>] }

        token ls32              { [<.h16> ':' <.h16>] | <.IPv4address> };
        token h16               { <.xdigit> ** 1..4 };

        token IPv4address       {
            <.dec_octet> '.' <.dec_octet> '.' <.dec_octet> '.' <.dec_octet>
        };

        token dec_octet         {
            '25' <[0..5]>           |   # 250 - 255
            '2' <[0..4]> <.digit>   |   # 200 - 249
            '1' <.digit> ** 2       |   # 100 - 199
            <[1..9]> <.digit>       |   # 10 - 99
            <.digit>                    # 0 - 9
        }
    }

    grammar IETF::RFC_Grammar::URI is IETF::RFC_Grammar::IPv6 {
        token TOP               { <URI_reference> };
        token TOP_non_empty     { <URI> | <relative_ref_non_empty> };
        token TOP_validating    { ^ <URI_reference> $ };
        token URI_reference     { <URI> | <relative_ref> };

        token absolute_URI      { <scheme> ':' <.hier_part> [ '?' query ]? };

        token relative_ref      {
            <relative_part> [ '?' <query> ]? [ '#' <fragment> ]?
        };
        token relative_part     {
            '//' <authority> <path_abempty>     |
            <path_absolute>                     |
            <path_noscheme>                     |
            <path_empty>
        };

        token relative_ref_non_empty      {
            <relative_part_non_empty> [ '?' <query> ]? [ '#' <fragment> ]?
        };
        token relative_part_non_empty     {
            '//' <authority> <path_abempty>     |
            <path_absolute>                     |
            <path_noscheme>                     
        };

        token URI               {
            <scheme> ':' <hier_part> ['?' <query> ]?  [ '#' <fragment> ]?
        };

        token hier_part     {
            '//' <authority> <path_abempty>     |
            <path_absolute>                     |
            <path_rootless>                     |
            <path_empty>
        };

        token scheme            { <.uri_alpha> <[\-+.] +uri_alpha +digit>* };

        token authority         { [ <userinfo> '@' ]? <host> [ ':' <port> ]? };
        token userinfo          {
            [ ':' | <likely_userinfo_component> ]*
        };
        # the rfc refers to username:password as deprecated
        token likely_userinfo_component {
            <+unreserved +sub_delims>+ | <.pct_encoded>+
        };
        token host              { <IPv4address> | <IP_literal> | <reg_name> };
        token port              { <.digit>* };

        token IP_literal        { '[' [ <IPv6address> | <IPvFuture> ] ']' };
        token IPvFuture         {
            'v' <.xdigit>+ '.' <[:] +unreserved +sub_delims>+
        };
        token reg_name          { [ <+unreserved +sub_delims> | <.pct_encoded> ]* };

        token path_abempty      { [ '/' <segment> ]* };
        token path_absolute     { '/' [ <segment_nz> [ '/' <segment> ]* ]? };
        token path_noscheme     { <segment_nz_nc> [ '/' <segment> ]* };
        token path_rootless     { <segment_nz> [ '/' <segment> ]* };
        token path_empty        { <.pchar> ** 0 }; # yes - zero characters

        token   segment         { <.pchar>* };
        token   segment_nz      { <.pchar>+ };
        token   segment_nz_nc   { [ <+unenc_pchar - [:]> | <.pct_encoded> ] + };

        token query             { <.fragment> };
        token fragment          { [ <[/?] +unenc_pchar> | <.pct_encoded> ]* };

        token pchar             { <.unenc_pchar> | <.pct_encoded> };
        token unenc_pchar       { <[:@] +unreserved +sub_delims> };

        token pct_encoded       { '%' <.xdigit> <.xdigit> };

        token unreserved        { <[\-._~] +uri_alphanum> };

        token reserved          { <+gen_delims +sub_delims> };

        token gen_delims        { <[:/?\#\[\]@]> };
        token sub_delims        { <[;!$&'()*+,=]> };

        token uri_alphanum      { <+uri_alpha +digit> };   
        token uri_alpha         { <[A..Za..z]> };
    }

    my $m = IETF::RFC_Grammar::URI.subparse('http://example.com:80/about/us?foo#bar');
    ok $m, "IETF::RFC_Grammar::URI matches";
    is $m.gist, q:to/END/.subst("\r\n", "\n", :g).chop, "IETF::RFC_Grammar::URI gets ltm and longlit right";
        ｢http://example.com:80/about/us?foo#bar｣
         URI_reference => ｢http://example.com:80/about/us?foo#bar｣
          URI => ｢http://example.com:80/about/us?foo#bar｣
           scheme => ｢http｣
           hier_part => ｢//example.com:80/about/us｣
            authority => ｢example.com:80｣
             host => ｢example.com｣
              reg_name => ｢example.com｣
             port => ｢80｣
            path_abempty => ｢/about/us｣
             segment => ｢about｣
             segment => ｢us｣
           query => ｢foo｣
           fragment => ｢bar｣
        END
    }

# RT #124333
# This exposed a dynamic optimizer bug, due to the huge number of basic blocks
# a token with a load of alternations produces.
{
    my grammar WithHugeToken {
        token TOP {
            <huge>+
        }
        token huge {
              <[\x[0041]..\x[005A]]>
            | <[\x[0061]..\x[007A]]>
            | <[\x[0388]..\x[038A]]>
            | <[\x[038E]..\x[03A1]]>
            | <[\x[03A3]..\x[03CE]]>
            | <[\x[03D0]..\x[03D7]]>
            | <[\x[03DA]..\x[03F3]]>
            | <[\x[0400]..\x[0481]]>
            | <[\x[048C]..\x[04C4]]>
            | <[\x[04C7]..\x[04C8]]>
            | <[\x[04CB]..\x[04CC]]>
            | <[\x[04D0]..\x[04F5]]>
            | <[\x[04F8]..\x[04F9]]>
            | <[\x[0531]..\x[0556]]>
            | <[\x[06E5]..\x[06E6]]>
            | <[\x[06FA]..\x[06FC]]>
            | <[\x[1312]..\x[1315]]>
            | <[\x[1318]..\x[131E]]>
            | <[\x[1320]..\x[1346]]>
            | <[\x[1348]..\x[135A]]>
            | <[\x[13A0]..\x[13B0]]>
            | <[\x[13B1]..\x[13F4]]>
            | <[\x[1401]..\x[1676]]>
            | <[\x[1681]..\x[169A]]>
            | <[\x[16A0]..\x[16EA]]>
            | <[\x[1780]..\x[17B3]]>
            | <[\x[1820]..\x[1877]]>
            | <[\x[1880]..\x[18A8]]>
            | <[\x[1E00]..\x[1E9B]]>
            | <[\x[1EA0]..\x[1EE0]]>
            | <[\x[1EE1]..\x[1EF9]]>
            | <[\x[1F00]..\x[1F15]]>
            | <[\x[1F18]..\x[1F1D]]>
            | <[\x[1F20]..\x[1F39]]>
            | <[\x[1F3A]..\x[1F45]]>
            | <[\x[1F48]..\x[1F4D]]>
            | <[\x[1F50]..\x[1F57]]>
            | <[\x[210A]..\x[2113]]>
            | <[\x[2119]..\x[211D]]>
            | <[\x[212A]..\x[212D]]>
            | <[\x[212F]..\x[2131]]>
            | <[\x[2133]..\x[2139]]>
            | <[\x[2160]..\x[2183]]>
            | <[\x[3005]..\x[3007]]>
            | <[\x[3021]..\x[3029]]>
            | <[\x[3031]..\x[3035]]>
            | <[\x[3038]..\x[303A]]>
            | <[\x[3041]..\x[3094]]>
            | <[\x[309D]..\x[309E]]>
            | <[\x[30A1]..\x[30FA]]>
            | <[\x[30FC]..\x[30FE]]>
            | <[\x[3105]..\x[312C]]>
            | <[\x[3131]..\x[318E]]>
            | <[\x[31A0]..\x[31B7]]>
            | <[\x[A000]..\x[A48C]]>
            | <[\x[F900]..\x[FA2D]]>
            | <[\x[FB00]..\x[FB06]]>
            | <[\x[FB13]..\x[FB17]]>
            | <[\x[FB1F]..\x[FB28]]>
            | <[\x[FB2A]..\x[FB36]]>
            | <[\x[FB38]..\x[FB3C]]>
            | <[\x[FB40]..\x[FB41]]>
            | <[\x[FB43]..\x[FB44]]>
            | <[\x[FB46]..\x[FBB1]]>
            | <[\x[FBD3]..\x[FD3D]]>
            | <[\x[FD50]..\x[FD8F]]>
            | <[\x[FD92]..\x[FDC7]]>
            | <[\x[FDF0]..\x[FDFB]]>
            | <[\x[FE70]..\x[FE72]]>
            | <[\x[FE76]..\x[FEFC]]>
            | <[\x[FF21]..\x[FF3A]]>
            | <[\x[FF41]..\x[FF5A]]>
            | <[\x[FF66]..\x[FFBE]]>
            | <[\x[FFC2]..\x[FFC7]]>
            | <[\x[FFCA]..\x[FFCF]]>
            | <[\x[FFD2]..\x[FFD7]]>
            | <[\x[FFDA]..\x[FFDC]]>
            | \x[038C]
            | \x[0559]
            | \x[06D5]
            | \x[0710]
            | \x[1310]
            | \x[2115]
            | \x[2124]
            | \x[2126]
            | \x[2128]
            | \x[3400]
            | \x[4DB5]
            | \x[4E00]
            | \x[9FA5]
            | \x[AC00]
            | \x[D7A3]
            | \x[FB1D]
            | \x[FB3E]
            | \x[FE74]
        }
    }

    lives-ok { WithHugeToken.parse('a' x 10000) },
        'token with huge number of alternations does not explode when used many times';
}

# LTM and ignorecase/ignoremark
{
    my $str = 'äaÄAÁbbBB';
    ok $str ~~ m:i/b+|bb/, 'alternation with :i matches';
    is ~$/, 'bbBB', 'got longest alternative with :i';

    #?rakudo.jvm 4 skip ':ignoremark needs NFG RT #124500'
    ok $str ~~ m:m/ä|bb|a+/, 'alternation with :m matches';
    is ~$/, 'äa', 'got longest alternative with :m';

    ok $str ~~ m:i:m/b+|bb|a+|äa/, 'alternation with :i:m matches';
    is ~$/, 'äaÄAÁ', 'got longest alternative with :i:m';
}

# RT #113884
{
    constant $x = 'ab';
    is ~('ab' ~~ / a | b | $x /), 'ab', 'got longest alternative with constant';

    my $y = 'ab';
    is ~('ab' ~~ / a | b | $y /), 'a', "non constants don't count toward LTM";
}

# RT #125608
{
    is ~('food' ~~ / 'foo' | ('food' || 'doof')/), 'food',
        'sequential alternation first branch involved in longest alternative (1)';
    dies-ok { 'food' ~~ / 'foo' | ('food' <!> || { die "Should die here" })/ },
        'sequential alternation first branch involved in longest alternative (2)';
    is ~('food' ~~ / 'foo' | ('food' <!> || 'doof')/), 'foo',
        'sequential alternation first branch failure after LTM tries next best option';
}

# RT #126573
ok "\r\n" ~~ /[";"|"\r\n"]/, '\r\n grapheme in an alternation matches correctly';

# RT #122951
#?rakudo todo 'negative lookahead does not LTM properly, RT #122951'
is "abcde" ~~ / ab <![e]> cde | ab.. /, "abcde", 'negative lookahead does LTM properly';

```

因为 "longest-token matching" 是一个很长的短语, 我们会经常将这个概念叫做 `LTM`.  这个基本的概念就是人们在头脑中倾向于怎么去解析文本, 所以计算机应该像人一样尝试做同样的事情. 而使用 `LTM` 解析文本就是关于计算机怎样决定匹配一组备选分支中的哪一个备选分支的.

在 Perl 6 中, `|` 代表使用声明性的 longest-token 语义的逻辑备选分支.(你现在能使用 `||` 来标示旧的暂存的备选分支. 就是, `|` 和 `||` 现在在正则语法内的运作方式和在正则语法外的运作方式很像,  在正则语法外部, `|` 和 `||` 代表 junctional 和 短路的 `OR`. 这也包括事实上 `|` 的优先级比 `||` 的优先级高.)

在过去, Perl 中正则表达式是通过一个能回溯的 NFA 算法来处理的. 这很强大, 但是很多解析器通过并行地处理 rules , 而不是一个接着一个地处理, 工作起来更高效, 至少达到某种程度. 如果你看一下像 yacc grammar 这样的东西, 你会发现很多 pattern/action 声明, 其中的 patterns 被认为是并行的,  并且最终由 grammar 决定触发哪个 action. 虽然默认的Perl 解析角度是从上至下的(或许使用一个中间层的从下至上角度来处理操作符优先级), 这对用户理解 token 处理进行确定性很有用。所以, 为了 regex 匹配的意图, 我们把 tokens 模式定义为那些不含潜在副作用或自引用的能被匹配的模式。(因为空格在行转换时经常有副作用, 所以通常被这样的模式排除, 给予或采取一点向前查看。) 基本上, Perl 自动地从 grammar 中派生出一个词法分析程序, 而不需要你自己写一个。



it is extremely useful for user understanding if at least the token processing proceeds deterministically. So for regex matching purposes we define token patterns as those patterns that can be matched without potential side effects or self-reference. (Since whitespace often has side effects at line transitions, it is usually excluded from such patterns, give or take a little lookahead.) Basically, Perl automatically derives a lexer from the grammar without you having to write one yourself.

为此, Perl 6 中的每个 regex 被要求能把它的纯模式和它的 actions 区分开, 并返回它的初始 token 模式的列表(包含由regex 的纯部分调用的 subrule 的 token 模式, 但是不包含多于一次的 subrule, 因为那可能会引起自引用, 这在传统正则表达式中是不被允许的。) 一个使用`|`的逻辑备选分支接收两个或多个这种列表并分发给匹配最长 token 前缀的备选分支。出现在第一位的可能是也可能不是那个备选分支。



To that end, every regex in Perl 6 is required to be able to distinguish its "pure" patterns from its actions, and return its list of initial token patterns (transitively including the token patterns of any subrule called by the "pure" part of that regex, but not including any subrule more than once, since that would involve self reference, which is not allowed in traditional regular expressions). A logical alternation using `|` then takes two or more of these lists and dispatches to the alternative that matches the longest token prefix. This may or may not be the alternative that comes first lexically.


However, if two alternatives match at the same length, the tie is broken first by specificity. The alternative that starts with the longest fixed string wins; that is, an exact match counts as closer than a match made using character classes. If that doesn't work, the tie is broken by one of two methods. If the alternatives are in different grammars, standard MRO (method resolution order) determines which one to try first. If the alternatives are in the same grammar file, the textually earlier alternative takes precedence. (If a grammar's rules are defined in more than one file, the order is undefined, and an explicit assertion must be used to force failure if the wrong one is tried first.)

然而, 如果两个备选分支以同样的长度匹配, 绑定首先由特异性打破。 以最长的固定字符串开头的备选分支胜出; 即一个精确的匹配被看作是比使用字符类更接近. 如果它不起作用, 绑定会由两个方法中的一个破坏. 如果备选分支在不同的 grammars 中, 那么标准的 MRO(方法解析顺序)决定首先尝试哪一个. 如果备选分支在同一个 grammar 文件中, 本文出现的更早的备选分支取得优先权. (如果一个 grammar 的 rules 被定义在不止一个文件中, 那么顺序是未定义的, 则必须使用一个显式的断言用于强制失败, 如果首先尝试错误的那个的话)


这个长的标记前缀大致相当于“令牌”在其他分析系统使用一个词法分析器的概念，但对于Perl这很大程度上是自动从语法定义一个偶然现象。然而，尽管是自动计算的，这一套标记可以由用户修改；各种内构造正则表达式的语法来告诉引擎，这是完成图案的部分开始的副作用，所以将这种构建用户控件被认为是象征性的，什么是不。被视为终止一个令牌声明并启动“行动”部分的结构的结构包括：
这种最长 token 前缀大致相当于在其它解析系统中使用词法解析程序的 "token" 标记, 但对于 Perl 这很大程度上是从 grammar 定义中派生的附带现象。然而，尽管是自动计算的, 这套 tokens 可以由用户修改; regex 中的各种结构声明性的告诉 grammar 引擎, 模式部分结束, 并开始进入副作用, 所以通过插入这样的结构, 用户控制什么是 token, 什么不是。终止 token 声明并开始模式的 "action" 部分的结构包括:

This longest token prefix corresponds roughly to the notion of "token" in other parsing systems that use a lexer, but in the case of Perl this is largely an epiphenomenon derived automatically from the grammar definition. However, despite being automatically calculated, the set of tokens can be modified by the user; various constructs within a regex declaratively tell the grammar engine that it is finished with the pattern part and starting in on the side effects, so by inserting such constructs the user controls what is considered a token and what is not. The constructs deemed to terminate a token declaration and start the "action" part of the pattern include:



- 任何 :: 或 ::: 回溯控制 (but not the : possessive modifier).
- 任何带有节俭匹配(使用 `?`修饰符)量词化的原子。Any atom that is quantified with a frugal match (using the `?` modifier).
- 任何 `{...}` action, 但不是含有闭包的断言。(空的闭包 `{}` 通常用于显式地终止模式的 pure 部分。) 一般的 `**{...}` 量词形式的闭包也会终止最长 token, 但是无闭包形式的量词不会。

  but not an assertion containing a closure. (The empty closure `{}` is customarily used to explicitly terminate the pure part of the pattern.) The closure form of the general `**{...}` quantifier also terminates the longest token, but the closureless forms of quantifier do not.

- 任何诸如 `||` 或 `&&` 按次序的控制流操作符.
- As a consequence of the previous point, and because the standard grammar's rule defines whitespace using `||`, the longest token is also terminated by any part of the regex or rule that *might* match whitespace using that rule, including whitespace implicitly matched via `:sigspace`. (However, token declarations are specifically allowed to recognize whitespace within a token by using such lower-level primitives as `\h+` or other character classes.)

- 作为前一点的结果，因为标准的 grammar 规则使用 `||` 定义空格, 最长的token 也由那 *可能* 使用那个规则匹配空格的 regex 或 rule 的任意部分终止, 包括通过 `:sigspace`隐式匹配的空格。（然而，token 声明明确允许通过在 token 中使用诸如 `\h+` 或其它字符类这种低级原语来识别空格）

Subpatterns (captures) specifically do not terminate the token pattern, but may require a reparse of the token to find the location of the subpatterns. Likewise assertions may need to be checked out after the longest token is determined. (Alternately, if DFA semantics are simulated in any of various ways, such as by Thompson NFA, it may be possible to know when to fire off the assertions without backchecks.)

Subpatterns（捕获）不终止token模式，但可能需要重新解析 token以找到Subpatterns的位置。同样地，在确定最长token之后断言可能需要被检查。（或者, 如果以任何一种方式模仿了 DFA 语义, 例如, 使用汤普森的NFA，可能可以知道什么时候触发断言而不使用backchecks。）


Greedy quantifiers and character classes do not terminate a token pattern. Zero-width assertions such as word boundaries are also okay.
贪婪量词和字符类不会终止 token 模式。 诸如单词边界的零宽断言也不会。


Because such assertions can be part of the token, the lexer engine must be able to recover from the failure of such an assertion and backtrack to the next best token candidate, which might be the same length or shorter, but can never be longer than the current candidate.
因为这种断言可以是 token 的一部分, 词法分析程序引擎必须能从这种断言的失败中恢复, 并回溯到下一个最佳 token 候选者, 它可能等长或更短, 但是绝对不会当前候选者更长。


For a pattern that contains a positive lookahead assertion such as ` or `, the assertion is assumed to be more specific than the subsequent pattern, so the lookahead's pattern is counted as the final part of the longest token; the longest-token matcher will be smart enough to treat the extra bit as 0-width, that is, to rematch any text traversed by the lookahead when (and if) it continues the match. (Indeed, if the entire lookahead is pure enough to participate in LTM, the rematcher may simply optimize away the rematching, since the lookahead already matched in the LTM engine.)

对于含有诸如 `<?foo>` 或 `<?before \s>` 这样的正向向前查看的模式, 这种断言会被认为比随后的模式更特殊, 所以向前查看的模式被当作最长 token 的最后一部分; 最长 token 匹配器会足够智能地把额外的 bit 当作是零宽的, 即, 重新匹配任何由向前查看遍历到的文本,当它(如果)继续匹配的时候。(实际上, 如果整个向前查看足够纯粹地参与 LTM, 再匹配可能仅仅优化掉 rematching, 因为向前查看已经在 LTM 引擎中匹配过了)

However, for a pattern that contains a negative lookahead assertion such as ` or `, just the opposite is true: the subsequent pattern is assumed to be more specific than the assertion's. So LTM completely ignores negative lookaheads, and continues to look for pure patterns in whatever follows the negative lookahead. You might say that positive lookaheads are opaque to LTM, but negative lookaheads are transparent to LTM. As a consequence, if you wish to write a positive lookahead that is transparent to LTM, you may indicate this with a double negation: ``. (The optimizer is free to remove the double negation, but not the transparency.)

然而, 对于包含诸如 `<!foo>` 或 `<!before \s>` 这种否定向前查看断言的模式, 反面的才是真: 随后的模式被认为比该断言更特殊。所以 LTM 完全忽略了否定向前查看, 并继续从跟在否定向前查看后面的任何东西中查找纯粹模式。你可能会说, 正向向前查看对 LTM 是不透明的, 否地向前查看对 LTM 是透明的。 结论是,如果你想写一个对 LTM 是透明的正向向前查看, 你可以使用两个感叹号的否定: `<!!foo>` 来标示它。(优化器能自由地移除双否定, 但是不是透明性)。

奇怪的是，这 `令牌` 关键词具体不确定一个令牌的范围，除了一个令牌模式通常不匹配的空白，而空白是终止令牌的典型方式。
Oddly enough, the `token` keyword specifically does not determine the scope of a token, except insofar as a token pattern usually doesn't do much matching of whitespace, and whitespace is the prototypical way of terminating tokens.
很奇怪, `token` 关键字不确定 token 的作用域, 除了作为一个 token 模式通常不做很多的空格匹配情况之外, 空格是终止 tokens 的原型方式。


The initial token matcher must take into account case sensitivity (or any other canonicalization primitives) and do the right thing even when propagated up to rules that don't have the same canonicalization. That is, they must continue to represent the set of matches that the lower rule would match.

初始token匹配器必须把区分大小写考虑在内（或任何其他规范化原语）并做正确的事, 即使传播到不具有相同的规范化的 rules 时。也就是说，它们必须继续代表较低规则能匹配的一组匹配。

`||` 形式有旧的短路语义，而不会试图匹配其右侧, 除非它的左侧耗尽了所有的可能性（包括所有 `|` 可能性）。regex 中的第一个 `||` 让它左侧的 token 模式能从外部的最长 token 匹配器中访问,  但从最长 token 匹配隐藏的任何后续的测试。每一个 `||`建立了一个新的最长 token匹配器。那就是, 如果你在 `||` 右侧使用 `|`，那么右侧为最长 token 处理这子表达式和任何被调用的 subrules建立了一个新的顶级作用域处理这个子表达式和任何所谓的规则。右边的最长 token 自动机是对于左侧的 `||` 或外部的含有 `||` 的 regex是不可见的。

The `||` form has the old short-circuit semantics, and will not attempt to match its right side unless all possibilities (including all `|` possibilities) are exhausted on its left. The first `||` in a regex makes the token patterns on its left available to the outer longest-token matcher, but hides any subsequent tests from longest-token matching. Every `||`establishes a new longest-token matcher. That is, if you use `|` on the right side of `||`, that right side establishes a new top level scope for longest-token processing for this subexpression and any called subrules. The right side's longest-token automaton is invisible to the left of the `||` or outside the regex containing the `||`.

翻译的狗屎一样！


# 从匹配中返回值

# Match 对象

- 成功的匹配总是返回一个 `Match` 对象, 这个对象通常也被放进 `$/` 中, (具名 `regex`, `token`, 或 `rule` 是一个子例程, 因此会声明它们自己的本地 `$/` 变量, 它通常指 rule 中最近一次的 submatch, 如果有的话)。当前的匹配状态被保存到 regex 的 `$¢` 变量中, 当匹配结束时它最终会被绑定到用户的 `$/`变量中

  不成功的匹配会返回 Nil (并把 `$/` 设置为 Nil, 如果匹配已经设置了 `$/`的话)

  ​

- 名义上, Match 对象包含一个布尔的成功值, 一个`有序的`子匹配对象(submatch objects)`数组`, 一个`具名的`子匹配对象(submatch objects)`散列`.(它也可选地包含一个用于创建抽象语法树(AST)的**抽象对象**) 为了提供访问这些各种各样值的便捷方法, Match 对象在不同上下文中求值也不同:

- 在布尔上下文中 Match 对象被求值为真或假

    ```perl
         if /pattern/ {...}
         # 或:
         /pattern/; if $/ {...}
    ```

    如果模式使用 `:global` 或 `:overlap` 或 `:exhaustive` 修饰符, 会在`第一个匹配处`返回布尔真值.  如果在列表上下文中求值, `Match` 对象会根据需要(lazily)产生剩下的结果.

    ​

  - 在字符串上下文中, Match 对象会被求值为匹配(match)的字符串化的值,  这通常是整个匹配的字符串.

    ```
         print %hash{ "{$text ~~ /<.ident>/}" };
         # 或等价的:
         $text ~~ /<.ident>/  &&  print %hash{~$/};
    ```

    ​
    但是通常你应该写成 `~$/`, 如果你想要字符串化匹配对象的话.

  - 在数字上下文中, Match 对象会被计算成它的匹配的数字值, 这通常是整个匹配的字符串:

    ```
         $sum += /\d+/;
         # 或等价的:
         /\d+/; $sum = $sum + $/;

    ```

    ​

  - 在标量上下文中, Match 对象求值结果为自身.

    然而, 有时你想要一个备用标量值伴随着匹配. Match 对象自身描述了一个具体的解析树, 这个额外的值叫做抽象对象;它作为 Match 对象的一个属性伴随着匹配. `.made` 方法默认返回一个未定义值. `$()` 是 `$($/.made // ~$/)` 的简写形式.

    ​

    因此, `$()` 通常就是整个匹配的字符串, 但是你能在 regex 内部调用 `make` 来重写它:

    ```
        my $moose = $(m[
            <antler> <body>
            { make Moose.new( body => $<body>.attach($<antler>) ) }
            # 匹配成功 -- 忽略该 regex 的剩余部分
        ]);
    ```

     这把新的抽象节点放进 `$/.made`中. 抽象节点(AST)可以是任何类型. 使用 `make` / `.made` 构造, 创建任意节点类型的抽象语法树就很方便了.

    ​

    然而, `make` 函数不限于仅仅用作存储 AST 节点并创建抽象语法树。  这就是特殊的 Perl 6 泛函性的内部使用.  `make`函数也不会把任何 item 或 列表上下文强加到它们的参数上, 所以, 你写了某些含糊不清的 listy, 像这样:

    ​

    ```
        make ()
        make @array
        make foo()
    ```

    ​

    那么从 `.made` 返回的值会被插值到列表中。 要抑制这, 使用下面这些:

    ```perl
        make ().item
        make []
        make $@array
        make [@array]
        make foo().item
        make $(foo())
    ```

    或者在接收终端上使用 `.made.item` 或 `$`变量

    `.ast` 方法就是 `.made` 的同义词, 它俩没什么不同. 它的存在一方面是因为历史原因, 另一方面也是为了给阅读你的代码的人标示一个更像 AST 用法的 `made/.make` 

    ​

  - 你也能使用 ` <(...)>` 构造捕获匹配的一个子集(subset):

    ```perl
        "foo123bar" ~~ / foo <( \d+ )> bar /
        say $();    # says 123
    ```

    ​

    这时, 当做字符串匹配时, `$()` 总是一个字符串, 当做列表匹配时, `$()`总是一个或多个元素的列表.这个构造没有设置 `.made` 属性.

    ​

  - 当用作数组时, Match 对象伪装成一个数组, 数组里是 Match 对象的所有位置捕获.因此,

    ```perl
         ($key, $val) = ms/ (\S+) '=>' (\S+)/;
    ```

    也能被写作:

    ```perl
         $result = ms/ (\S+) '=>' (\S+)/;
         ($key, $val) = @$result;
    ```

    要把单个捕获放到字符串中, 使用下标:

    ```perl
         $mystring = "{ ms/ (\S+) '=>' (\S+)/[0] }";
    ```

    要把所有捕获都放到字符串中, 使用一个禅切:

    ```perl
         $mystring = "{ ms/ (\S+) '=>' (\S+)/[] }";
    ```

    或把它扔到数组里:

    ```perl
         $mystring = "@( ms/ (\S+) '=>' (\S+)/ )";
    ```

    ​

    注意, 作为一个标量, `$/` 在列表上下文中不会自动展平(flatten). 在列表上下文中使用 `@()`作为 `@($/)` 的简写形式来展平位置捕获. 注意, Match 对象能在列表上下文中按需计算它的匹配.使用 `@()` 来强制进行迫切( eager)匹配.

    ​

  - 当作为散列时, Match 对象伪装成一个含有具名捕获的散列. 散列的键不包括任何符号, 所以如果你把变量捕获到变量 `@<foo>`, 它的真实名字为 `$/{'foo'}` 或 `$/<foo>`.然而, 在`$/` 可见的任何地方, 你仍旧能把它作为 `@<foo>` 引用. (但是, 对于两个不同的捕获数据类型,使用同一个名字是错误的.)
  [`S05-capture/subrule.t lines 17–119`](https://github.com/perl6/roast/blob/master/S05-capture/subrule.t#L17-L119)

    [`S05-match/capturing-contexts.t lines 35–164`](https://github.com/perl6/roast/blob/master/S05-match/capturing-contexts.t#L35-L164)

    ​

    注意, 作为一个标量, `$/` 在列表上下文中不会自动展平(flatten). 在列表上下文中使用 `%()`作为 ` %($/)` 的简写形式来作为一个散列来展平, 或把它绑定到一个合适类型的变量上. 就像 `@()`, `%()`能在列表上下文中按需产生它的 pair 对儿. 

    ​

  - 编号过的捕获能被当作命名捕获那样, 所以 `$<0 1 2>`  等价于 `$/[0,1,2]`.  这允许你混写命名捕获和编号捕获.

  - `.keys`, `.values` 和 `.kv` 方法对列表和散列都起作用, 列表部分首当其冲.` 

    ```perl
        'abcd' ~~ /(.)(.)**2 <alpha>/;
        say ~$/.keys;           # 0 1 alpha
    ```

    ​

  - 在普通代码中, 变量 `$0`,`$1`等等就是 `$/[0]` ,`$/[1]` 的别名, 等等, 因此, 如果最后的匹配失败, 它们都会变为未定义的. (除非它们被显式地绑定到一个闭包中, 而不使用 let 关键字)
  [`S32-scalar/undef.t lines 220–280`](https://github.com/perl6/roast/blob/master/S32-scalar/undef.t#L220-L280)

    ​
- Match 对象有一些方法提供了关于匹配的额外信息, 例如:

  ```perl
       if m/ def <ident> <codeblock> / {
           say "Found sub def from index $/.from.bytes ",
               "to index $/.to.bytes";
       }
  ```

  当前定义过的方法有

  ​

  ```perl
      $/.from      # 初始匹配位置
      $/.to        # 最终匹配位置
      $/.chars     # $/.to - $/.from
      $/.orig      # 原匹配字符串
      $/.Str       # substr($/.orig, $/.from, $/.chars)
      $/.made      # 关于该节点(来自于 make)的抽象结果
      $/.ast       # 和 $/.made 相同
      $/.caps      # 相继的捕获
  ```
  [`S05-capture/caps.t lines 5–94`](https://github.com/perl6/roast/blob/master/S05-capture/caps.t#L5-L94)

  ```perl
      $/.chunks    # sequential tokenization
      $/.prematch  # $/.orig.substr(0, $/.from)
      $/.postmatch # $/.orig.substr($/.to)
  ```

  ​

  在 regex 内部, 当前匹配状态 `$¢` 也提供了这个:

  ```perl
      .pos        # 当前匹配位置
  ```

  最后那个值根据匹配是向前处理还是向后处理对应于 `$¢.from` 或 `$¢.to`.( 后一种情况出现在 `<?after ...>` 断言内部 ).

  ​

- 就像上面描述的那样, 在列表上下文中, Match 对象返回它的位置捕获. 然而, 有时你更想以它们出现在文本中的顺序, 得到一个展平的 tokens 列表. `.caps` 方法按顺序返回一个所有捕获的列表, 而不管它是如何被绑定命名捕获或带编号捕获上的. (除了顺序, 这儿没有新的信息; 列表中的所有元素都是同样的 Match 对象,并被任意绑定.) 绑定实际上是作为 键/键值对儿返回, 而 键是名字或编号, 而值是 Match 对象自身.

   除了返回那些捕获的 Match 对象外, `.chunks` 方法也在两个捕获之间返回交错的噪音. 就像 `.caps` , 列表元素的顺序跟它们原来在文本中的顺序相同.交错的部分也返回一个 pairs, 而键是 `~`, 值为一个简单的只包含字符串的 Match 对象, 即使未绑定的诸如 `.ws` 的子规则首先遍历文本. 在这样一个 Match对象上调用 `.made` 方法总是返回 一个 `Str`.

  ​

  如果 `.caps` 或 `.chunks` 发现它们有重叠绑定, 会出现一个警告. 没有这样的重叠, `.chunks` 保证将它匹配到的每一部分字符串映射为它返回的所有匹配的精确的一个元素, 所以, 覆盖范围是完整的.

  ​

  [Conjecture: we could also have `.deepcaps` and `.deepchunks` that recursively expand any capture containing submatches. Presumably the keys of such returned chunks would indicate the "pedigree" of bindings in the parse tree.]

  ​

- 所有与任何 regex, subrule, or subpattern 匹配的尝试, 成功与否, 会返回一个能被求值为布尔值的对象.(这个对象要么是一个 Match, 要么是 Nil.)即:

  ```perl
       $match_obj = $str ~~ /pattern/;
       say "Matched" if $match_obj;
  ```

  ​

- 不管成功与否,这个返回的对象也被自动的绑定到当前环境的词法变量 `$/` 上:

  ```perl
       $str ~~ /pattern/;
       say "Matched" if $/;
  ```

  ​

- 在 regex 里面, 变量 `$¢` 保存着当前 regex 的未完成的 Match 对象, 这就是所谓的匹配状态(类型为 Cursor).通常, 这不应该被被修改, 除非你知道怎么创建并传递匹配状态.所有的 regexes 实际上返回匹配状态即使当你认为它们会返回其它东西时, 因为匹配状态为你追踪模式的成功和失败.

  幸运的是, 伴随着默认的具体的 Match 对象, 当你只想返回一个不同的抽象结果时, 你可以使用 `make` 函数把当前匹配状态和返回值关联起来, 这跟 return 有点像, 但是不会 clobber 匹配状态:
  [`S05-match/make.t lines 9–24`](https://github.com/perl6/roast/blob/master/S05-match/make.t#L9-L24)

  ​

  ```perl
      $str ~~ / foo                 # Match 'foo'
                 { make 'bar' }     # But pretend we matched 'bar'
               /;
      say $();                      # says 'bar'
  ```

  ​

   通过 `.made` 方法能访问到任何 Match 对象的值(例如一个抽象对象). 因此, 这些抽象对象能被独立的管理.

  ​

  The current cursor object must always be derived from `Cursor`, or the match will not work. However, within that constraint, the actual type of the current cursor defines which language you are currently parsing. When you enter the top of a grammar, this cursor generally starts out as an object whose type is the name of the grammar you are in, but the current language can be modified by various methods as they mutate the current language by returning cursor objects blessed into a different type, which may or may not be derived from the current grammar. 当前指针对象总是由 Cursor 派生而来, 否则匹配不会起作用. 然而, 在那个约束之下, 当前指针的实际类型定义可当前正在解析的是哪一种语言. 当你进入一个 grammar 的顶部时, 这个指针通常开始于一个对象, 该对象的类型是你所在的 grammar 的名字, 但是当前语言可以通过各种方法修改, 当它们通过返回 blessed 为不同类型的指针对象来修改当前语言, 这可能也或许不是从当前 grammar 中派生出来的.

  ​



# 子模式捕获

- regex 中任何闭合在`捕获圆括号`中的那部分就是所谓的 `subpattern`, 例如:

  ```perl
          #               subpattern
          #  _________________/\___________________
          # |                                      |
          # |       subpattern  subpattern         |
          # |          __/\__    __/\__            |
          # |         |      |  |      |           |
        ms/ (I am the (walrus), ( khoo )**2  kachoo) /;
  ```

  ​

- 如果匹配成功,  regex 中的每个 subpattern 都会产生一个 Match 对象

- 每个 subpattern 要么显式地赋值给一个具名目标,要么隐式地被添加到含有很多匹配的`数组`中去.

  对于每一个没有显式地给定名字的 subpattern, 该 subpattern 的 Match 对象被推入到外部的属于周围作用域的 `Match` 对象里面的数组中(即它的父 Match 对象). 周围作用域要么是最内部的周围作用域(如果 subpattern 是嵌套的) 要么是整个 regex 自身.

  ​


- 像捕获一样, 这些对数组的赋值是假设的, 如果  subpattern 回溯, 这些赋值会被撤销.


- 举个例子, 如果下面这个模式匹配成功:

  ```perl
          #                subpat-A
          #  _________________/\__________________
          # |                                     |
          # |         subpat-B  subpat-C          |
          # |          __/\__    __/\__           |
          # |         |      |  |      |          |
        ms/ (I am the (walrus), ( khoo )**2 kachoo) /;
  ```

  ​

  则由 *subpat-B*  和 *subpat-C* 产生的 Match 对象会被成功地推入到 *subpat- A*  的 Match 对象里面的数组中.  然后 *subpat-A*  的  `Match` 对象自身会被推入到整个 regex 的 Match 对象里面的数组中.

```perl
my $str = "I am the walrus, khoo khoo kachoo";
$str ~~ ms/ (I am the (walrus)\, ( khoo )**2 kachoo) /;
say ~$/[0];       # I am the walrus, khoo khoo kachoo
say ~$/[0][0];    # walrus
say ~$/[0][1];    # khoo  khoo
say ~$/[0][1][0]; # khoo
say ~$/[0][1][1]; # khoo
```
可以看出, subpat-A 的 Match 对象是 `$/`数组的一个元素, subpat-A 和 subpat-B 的 Match 对象在同一个数组 `$/[0]` 中。
  ​

- 因为这些语义, Perl 6 中的捕获括号是分等级的, 而非线性的. (see "Nested subpattern captures”)



# 访问捕获的子模式


- `Match` 对象的`数组元素`要么使用标准的数组访问记法(例如  `$/[0]`, `$/[1]`, `$/[2]` 等.) 要么通过对应的词法作用域`数字别名`(例如: `$0`, `$1`, `$2`), 所以:

  [`S05-match/capturing-contexts.t lines 25–34`](https://github.com/perl6/roast/blob/master/S05-match/capturing-contexts.t#L25-L34)

  ```perl
       say "$/[1] was found between $/[0] and $/[2]";
  ```

  和下面这个相同:

  ```perl
       say "$1 was found between $0 and $2";
  ```

  ​

- 注意, 在 Perl 6 中, 数字捕获变量从 `$0`开始, 而非 `$1`, 使用 `$/` 中对应元素的索引中的数字.

- regex 的 Match 对象(例如 $/)中的`数组元素`分别存储着单独的 Match 对象, 这些 Match 对象就是匹配到的`子字符串`, 并被第一个, 第二个,第三个,直到最外面的 subpattern 捕获(非嵌套). 所以这些元素能被看成完全合格的匹配结果. 例如:
  [S05-capture/dot.t lines 13–55](https://github.com/perl6/roast/blob/master/S05-capture/dot.t#L13-L55)

  ```
       if m/ (\d\d\d\d)-(\d\d)-(\d\d) (BCE?|AD|CE)?/ {
             ($yr, $mon, $day) = $/[0..2];
             $era = "$3" if $3;                    # stringify/boolify
             @datepos = ( $0.from() .. $2.to() );  # Call Match methods
       }

  ```

  ​



# 嵌套的子模式捕获
  [`S05-capture/named.t lines 16–25`](https://github.com/perl6/roast/blob/master/S05-capture/named.t#L16-L25)

- 通过嵌套的 subpattern 匹配到的子字符串被赋值给嵌套的 subpattern 的 `父 Match 对象`里面的`数组`中, 而不是 $/ 的数组中.

- 这种行为和 Perl 5 的语义完全不同:

  ```
        # Perl 5...
        #
        # $1---------------------  $4---------  $5------------------
        # |   $2---------------  | |          | | $6----  $7------  |
        # |   |         $3--   | | |          | | |     | |       | |
        # |   |         |   |  | | |          | | |     | |       | |
       m/ ( A (guy|gal|g(\S+)  ) ) (sees|calls) ( (the|a) (gal|guy) ) /x;
  ```

  ​

- 在 Perl 6中, 嵌套的圆括号产生可能的嵌套的捕获

  ```
        # Perl 6...
        #
        # $0---------------------  $1---------  $2------------------
        # |   $0[0]------------  | |          | | $2[0]-  $2[1]---  |
        # |   |       $0[0][0] | | |          | | |     | |       | |
        # |   |         |   |  | | |          | | |     | |       | |
       m/ ( A (guy|gal|g(\S+)  ) ) (sees|calls) ( (the|a) (gal|guy) ) /;
  ```
如上, 在匹配嵌套的 subpattern 时, `$0`, `$1`, `$2` 是平级的, 它们都是父 Match 对象 `$/` 数组中的子元素, 即 `$/[0]`、`$/[1]`、`$/[2]`。而 `$0` 和 `$2` 中有嵌套的 subpattern, 所以 `$0` 和 `$2` 也成为父 subpattern, 依次类推。
  ​



# 量词化的子模式捕获

  - 如果 subpattern 后面直接使用 `?`量词, 它要么产生单个 Match 对象, 要么产生 Nil.(?表示匹配0次或1次。) 如果 subpattern 后直接使用任何其它量词, 它绝不会产生单个 Match 对象. 相反, 它产生一个 Match 对象的列表, 列表中的元素对应于由重复的 subpattern 产生的各自匹配的序列. 如果想区分这两种类别, `?` 是一个 item 量词, 而 `*`, `+` 和 `**` 叫做列表量词.

  如果匹配到 0 个值, 则捕获到的值取决于用的是哪个量词. 如果量词是 `?`, 并且匹配次数为 0, 则捕获到 Nil. 如果量词是 `*`, 则是`空列表`, 即 `()`. (如果匹配次数为 0, +量词什么也不会捕获, 因为它会引发回溯, 但是 如果在一个不成功的匹配之后, 又尝试使用它, 则捕获变量会返回 Nil ) . 如果它的最小范围是 0,  `**` 量词会像`*`那样返回 `()`, 否则就会回溯.

  注意,  不像 ?,  `** 0..1` 总是被认为是一个列表量词.

  把 `?` 看作 item 量词的理由是为了使它符合 `$object.?meth` 定义的方式, 并减少不必要的 `.[0]`下标, 这会使大部分人惊讶.既然 Nil 被认为是未定义的而非`()`的同义词, 使用 `$0 // "default"` 或诸如此类的来安全地解引用捕获就很容易了.

  ​

- 因为列表量词化的 subpattern 返回一个 Match 对象的列表, 对应的量词化的捕获数组元素会存储一个(嵌套的)数组而不是单个 Match 对象.例如:

  ```perl
       if m/ (\w+) \: (\w+ \s+)* / {
           say "Key:    $0";         # Unquantified --> single Match
           say "Values: @($1)";      # Quantified   --> array of Match
       }
  ```

  ​



# 间接量词化的子模式捕获

- subpattern 有时会嵌套在一个量词化的非捕获结构中:

  ```perl
        #       non-capturing       quantifier
        #  __________/\____________  __/\__
        # |                        ||      |
        # |   $0         $1        ||      |
        # |  _^_      ___^___      ||      |
        # | |   |    |       |     ||      |
       m/ [ (\w+) \: (\w+ \h*)* \n ] ** 2..* /
  ```

  非捕获括号不会创建单独的嵌套词法作用域, 所以那两个 subpattern 实际上仍然在 regex 的顶层作用域中, 因此, 它们的顶层名字是 `$0` 和 `$1`.

- 然而, 因为那两个 subpattern 在量词化结构里面, `$0` 和 `$1` 每个都会包含一个数组.  每次迭代非捕获分组, 数组的元素会是对应 subpattern 返回的 submatch.例如:

  ```perl
       my $text = "foo:food fool\nbar:bard barb";
  ```

  ​

  ```perl
                 #   $0--     $1------
                 #   |   |    |       |
       $text ~~ m/ [ (\w+) \: (\w+ \h*)* \n? ] ** 2..* /;
  ```

  ​

  ```
       # 因为它们在一个量词化的非捕获 block 中...
       # say $/[0].perl;
       # $0 包含着下面的等同物:
       #
       #       [ Match.new(str=>'foo'), Match.new(str=>'bar') ]
       #
       # 并且 $1 包含下面的等同物:
       #
       #       [ Match.new(str=>'food '),
       #         Match.new(str=>'fool' ),
       #         Match.new(str=>'bard '),
       #         Match.new(str=>'barb' ),
       #       ]
  ```

  ​

- 与此相反, 如果外部的量词化结构是一个*捕获*结构(i.e. 一个 subpattern), 那么它会引入一个嵌套的词法作用域. 外部的量词化结构会返回一个 Match 对象的数组, 代表对每个迭代的内部括号的捕获。即:

  ```perl
       my $text = "foo:food fool\nbar:bard barb";
  ```

  ​

  ```perl
                 # $0-----------------------
                 # |                        |
                 # | $0[0]    $0[1]---      |
                 # | |   |    |       |     |
       $text ~~ m/ ( (\w+) \: (\w+ \h*)* \n ) ** 2..* /;
  ```

  ​

  ```perl
       # 因为它是一个量词化的捕获 block,
       # $0 包含如下等价物:
       #
       #       [ Match.new( str=>"foo:food fool\n",
       #                    arr=>[ Match.new(str=>'foo'),
       #                           [
       #                               Match.new(str=>'food '),
       #                               Match.new(str=>'fool'),
       #                           ]
       #                         ],
       #                  ),
       #         Match.new( str=>'bar:bard barb',
       #                    arr=>[ Match.new(str=>'bar'),
       #                           [
       #                               Match.new(str=>'bard '),
       #                               Match.new(str=>'barb'),
       #                           ]
       #                         ],
       #                  ),
       #       ]
       #
       # 并且没有 $1
  ```

  ​

- 换句话说, 量词化的非捕获括号把它们的组件聚集到就近展平的列表中, 而量词化的捕获括号把它们的部件聚集到就近的分等级的结构中.

  此外,  sublist 彼此间是被同步保存的,作为每个空匹配, 在我们例子中的 `$0[1]`情形下, 如果冒号后面跟着一个换行符, 那么将会在给定的列表中有一个对应的 Nil值。

  ​



# 子模式编号

- The index of a given subpattern can always be statically determined, but is not necessarily unique nor always monotonic. The numbering of subpatterns restarts in each lexical scope (either a regex, a subpattern, or the branch of an alternation).给定 subpattern 的索引总是能被静态地决定, 但不是唯一也不是无变化的. subpattern 的编号从每个词法作用域重新开始.( regex, subpattern, 或备选分支中的任意一个)

- In particular, the index of capturing parentheses restarts after each `|` or `||` (but not after each `&` or `&&`). Hence:特别地, 在每个 `|` 或 `||` 之后, 捕获括号的索引重新开始.(但是不是在每个 & 或 && 之后)

  ```
                    # $0      $1    $2   $3    $4           $5
       $tune_up = rx/ ("don't") (ray) (me) (for) (solar tea), ("d'oh!")
                    # $0      $1      $2    $3        $4
                    | (every) (green) (BEM) (devours) (faces)
                    /;
  ```

  ​

  这意味着, 如果第二个备选分支匹配, 匹配的列表中将会包含 `('every', 'green', 'BEM', 'devours', 'faces')` 而非 Perl 5 的 `(undef, undef, undef, undef, undef, undef, 'every', 'green', 'BEM', 'devours', 'faces')`.

  ​

- Note that it is still possible to mimic the monotonic Perl 5 capture indexing semantics. See "Numbered scalar aliasing") below for details.注意, 仍旧能模仿无变化的 Perl 5 捕获索引语义.查看下面的 "Numbered scalar aliasing"



# Subrule 捕获
  [`S05-capture/named.t lines 36–74`](https://github.com/perl6/roast/blob/master/S05-capture/named.t#L36-L74)

-  在模式中调用任何一个命名的 `<regex>` 被称为 `subrule`, 不管那个正则表达式实际上被定义为一个 `regex`, 或者 `token`, 或者甚至普通的方法或 `multi`.

- 任何别名为具名变量的括号结构也是一个 `subrule`

- 例如, 下面这个正则表达式包含 3 个 subrules:

  ```
        # subrule       subrule     subrule
        #  __^__    _______^_____    __^__
        # |     |  |             |  |     |
       m/ <ident>  $<spaces>=(\s*)  <digit>+ /
  ```

  ​

- Just like subpatterns, each successfully matched subrule within a regex produces a `Match` object. But, unlike subpatterns, that `Match` object is not assigned to the array inside its parent `Match` object. Instead, it is assigned to an entry of the hash inside its parent `Match` object. For example:就像 subpatterns 那样, 在正则表达式中每个成功匹配的 subrule 都产生一个 Match 对象. 但是, 跟 subpatterns 不同的是, 那个 Match 对象没有赋值给它的父 Match 对象里面的数组. 相反, 它被赋值给它的父 Match 对象里面的散列中的一个条目(键值对儿). 例如:

  ```
        #  .... $/ .....................................
        # :                                             :
        # :              .... $/[0] ..................  :
        # :             :                             : :
        # : $/<ident>   :        $/[0]<ident>         : :
        # :   __^__     :           __^__             : :
        # :  |     |    :          |     |            : :
        ms/  <ident> \: ( known as <ident> previously ) /
  ```

  ​



# 访问捕获的 subrules 

-  Match 对象的散列条目可以使用任何一个标准的散列访问记法(`$/{'foo'}`, `$/`, `$/«baz»`, 等等.) 查阅, 或通过对应的词法作用域别名 (`$`, `$«bar»`, `$`, 等等.)访问. 所以前面的例子也意味着:
  [`S05-capture/dot.t lines 62–87`](https://github.com/perl6/roast/blob/master/S05-capture/dot.t#L62-L87)

  ​

  ```
        #    $<ident>             $0<ident>
        #     __^__                 __^__
        #    |     |               |     |
        ms/  <ident> \: ( known as <ident> previously ) /
  ```

  ​

- 注意, subrule 是使用尖括号(`) 或者使用内部别名(`)还是使用外部别名(`$=(<.alpha>\w*)`)是没有分别的.



# 同一个 subrule 的重复捕获

- If a subrule appears two (or more) times in any branch of a lexical scope (i.e. twice within the same subpattern and alternation), or if the subrule is list-quantified anywhere within a given scope (that is, by any quantifier other than `?`), then its corresponding hash entry is always assigned an array of `Match` objects rather than a single `Match` object.如果在词法作用域的任何一个分支中出现 2次(或更多) subrules (例如,在同一个 subpattern 和备选中出现2次), 或者, 如果 在给定作用域的任何地方, subrule 是列表量词化的(那就是, 使用除了?之外的任何其它量词), 那么, 它的对应散列条目总是被赋值给 Match 对象的数组中, 而不是赋值给单个 Match 对象.

- Successive matches of the same subrule (whether from separate calls, or from a single quantified repetition) append their individual `Match` objects to this array. For example:同一个 subrule 的成功匹配( 无论是来自于单独的调用还是来自于单个量词化重复)把单独的 Match 对象追加到这个数组中, 例如:

  ```
       if ms/ mv <file> <file> / {
           $from = $<file>[0];
           $to   = $<file>[1];
       }
  ```

  ​

  (Note, for clarity we are ignoring whitespace subtleties here--the normal sigspace rules would require space only between alphanumeric characters, which is wrong. Assume that our file subrule deals with whitespace on its own.)(注意, 为了代码清晰, 我们这里忽略了空白的细微之处 -- 普通的 sigspace rules 只会在字母数字字符之间要求有空白, 这是错误的. 假设我们的 `<file>` subrule 自己处理空白.)

  ​

  同样地, 使用量词化的 subrule:

  ​

  ```
       if ms/ mv <file> ** 2 / {
           $from = $<file>[0];
           $to   = $<file>[1];
       }
  ```

  ​

  还有使用它们两者的混合:

  ​

  ```
       if ms/ mv <file>+ <file> / {
           $to   = pop @($<file>);
           @from = @($<file>);
       }
  ```

  ​

- 为了避免名字冲突, 可以使用一个前置的点来抑制原来的名字, 然后使用别名给捕获一个不同的名字:

  ```
       if ms/ mv <file> <dir=.file> / {
           $from = $<file>;  # 只有一个 subrule 叫做 <file>, 所以是标量
           $to   = $<dir>;   # 这个捕获之前叫做 <file>
       }
  ```

  ​

  同样地, 下面的结构都不会让 `<file>` 产生一个 Match 对象的数组, 因为在同一个词法作用域中, 它们都没有两个或更多的 `<file>` subrules.

  ​

  ```
       if ms/ (keep) <file> | (toss) <file> / {
           # 每个 <file> 都是单独的备选分支,
           # 因此 <file> 在任何一个作用域中都没有被重复, 因此, $<file> 不是数组对象.
           $action = $0;
           $target = $<file>;
       }
  ```

  ​

  ```
       if ms/ <file> \: (<file>|none) / {
           # 第二个 <file> 嵌套在不同作用域中的 subpattern 中
           $actual  = $/<file>;
           $virtual = $/[0]<file> if $/[0]<file>;
       }
  ```

  ​

- 另一方面, 未别名化的方括号没有被授予单独的作用域(因为它们没有关联的 Match 对象).所以:

  ```
       if ms/ <file> \: [<file>|none] / { # 这两个 <file> 在同一个作用域中
           $actual  = $/<file>[0];
           $virtual = $/<file>[1] if $/<file>[1];
       }
  ```

  ​



# 别名

别名可以被命名或编号. 它们可以是 scalar-, array-, 或 hash-like. 并且它们能被应用到捕获或非捕获结构中.  下面的章节会突出那些组合语义的特殊功能.



# 让具名标量成为subpatterns的别名
  [`S05-capture/named.t lines 26–35`](https://github.com/perl6/roast/blob/master/S05-capture/named.t#L26-L35)

- If a named scalar alias is applied to a set of *capturing* parens:
  [`S05-capture/alias.t lines 17–26`](https://github.com/perl6/roast/blob/master/S05-capture/alias.t#L17-L26)

  ​

  ```
          #         _____/capturing parens\_____
          #        |                            |
          #        |                            |
        ms/ $<key>=( (<[A..E]>) (\d**3..6) (X?) ) /;
  ```

  ​

  then the outer capturing parens no longer capture into the array of `$/` as unaliased parens would. Instead the aliased parens capture into the hash of `$/`; specifically into the hash element whose key is the alias name.

  ​

- So, in the above example, a successful match sets `$` (i.e. `$/`), but *not* `$0` (i.e. not `$/[0]`).

- More specifically:

  - `$/` will contain the `Match` object that would previously have been placed in `$/[0]`.
  - `$/[0]` will contain the A-E letter,
  - `$/[1]` will contain the digits,
  - `$/[2]` will contain the optional X.


- Another way to think about this behavior is that aliased parens create a kind of lexically scoped named subrule; that the contents of the parentheses are treated as if they were part of a separate subrule whose name is the alias.



# 让具名标量成为非捕获分组的别名

- 如果一个具名标量别名被应用到一组非捕获括号:
  [`S05-capture/alias.t lines 33–68`](https://github.com/perl6/roast/blob/master/S05-capture/alias.t#L33-L68)

  ​

  ```
          #         __/non-capturing brackets\__
          #        |                            |
          #        |                            |
        ms/ $<key>=[ (<[A..E]>) (\d**3..6) (X?) ] /;
  ```

  ​

  则对应的 `$/` `Match` 对象只会包含非捕获括号匹配到的字符串.

  ​

- 特别地,  `$/` 数组中的条目是空的. 那是因为方括号不会创建嵌套的词法作用域. 所以 subpatterns 是非嵌套的, 并且因此对应于`$0`, `$1`, 和 `$2`, 而不是对应于  `$/[0]`, `$/[1]`, 和 `$/[2]`.

- 换句话说:

  - `$/` 会包含方括号匹配到的整个子字符串  (in a `Match` object, as described above),
  - `$0` 会包含字母 `A-E`,
  - `$1` 会包含数字,
  - `$2 `会包含可选的 X.



# 让具名标量成为 subrules 的别名


- 如果 subrule 被设置了别名, 它会把它的 Match 对象设置为散列的条目, 散列的键是别名的名字, 它和 subrule 原来的名字一样.

  ```
       if m/ ID\: <id=ident> / {
           say "Identified as $/<id> and $/<ident>";    # both names defined
       }
  ```

  要抑制原来的名字, 使用带点形式的名字:
  ​

  ```
       if m/ ID\: <id=.ident> / {
           say "Identified as $/<id>";    # $/<ident> is undefined
       }
  ```

- 因此, 给一个带点的 subrule 起别名改变了 subrule 的 Match 对象的目标.在同一个作用域内, 这对于区分对同一个 subrule 的两次或多次调用.例如:

  ```
       if ms/ mv <file>+ <dir=.file> / {
           @from = @($<file>);
           $to   = $<dir>;
       }
  ```

  ​



# 给标量别名编号


- 如果使用编号别名而非使用具名别名:

  ```
       m/ $1=(<-[:]>*) \:  $0=<ident> /   # captures $<ident> too
       m/ $1=(<-[:]>*) \:  $0=<.ident> /  # doesn't capture $<ident>
  ```

  ​

  编号别名的行为就和具名别名的一样(i.e. 上面描述过的各种情况), 除了结果 Match 对象被赋值给对应的合适数组元素, 而非散列元素.

  ​

- 如果使用了编号别名, 后续同一作用域中未起别名的 subpatterns 的编号会从那个别名编号开始自动增长(跟枚举数值从最后一个显式值开始增长很像). 即:
  [`S05-capture/alias.t lines 27–32`](https://github.com/perl6/roast/blob/master/S05-capture/alias.t#L27-L32)

  ​

  ```
        #  --$1---    -$2-    --$6---    -$7-
        # |       |  |    |  |       |  |    |
       m/ $1=(food)  (bard)  $6=(bazd)  (quxd) /;
  ```

  ​

- 这种后续的行为对于在备选分支中重新建立 Perl5语义中的连续 subpattern 编号特别有用:

  ```
       $tune_up = rx/ ("don't") (ray) (me) (for) (solar tea), ("d'oh!")
                    | $6 = (every) (green) (BEM) (devours) (faces)
                    #              $7      $8    $9        $10
                    /;
  ```

  ​

- 这也在 Perl 6 中提供了一种简单的方式来重建嵌套的 Perl 5 subpatterns 的非嵌套编号语义:

  ```
        # Perl 5...
        #               $1
        #  _____________/\___________
        # |    $2        $3      $4  |
        # |  __/\___   __/\___   /\  |
        # | |       | |       | |  | |
       m/ ( ( [A-E] ) (\d{3,6}) (X?) ) /x;
  ```

  ​

  ```
        # Perl 6...
        #                $0
        #  ______________/\______________
        # |   $0[0]       $0[1]    $0[2] |
        # |  ___/\___   ____/\____   /\  |
        # | |        | |          | |  | |
       m/ ( (<[A..E]>) (\d ** 3..6) (X?) ) /;
  ```

  ​

  ```
        # Perl 6 simulating Perl 5...
        #                 $1
        #  _______________/\________________
        # |        $2          $3       $4  |
        # |     ___/\___   ____/\____   /\  |
        # |    |        | |          | |  | |
       m/ $1=[ (<[A..E]>) (\d ** 3..6) (X?) ] /;
  ```

  ​

  非捕获括号没有引入作用域, 所以非捕获括号中的 subpatterns 处于 regex 作用域, 并因此在括号顶层开始编号. 给方括号起别名为 `$1`意味着同一级别的下一个 subpattern(例如 `(<[A..E]>)`)的编号继续(i.e. `$2`). 等等.

  ​



# 给量词化结构应用标量别名

- 上面所有的语义可以同等地应用到绑定了量词化结构的别名身上.

- 唯一不同的是, 如果别名化的结构是一个 subrule 或 subpattern, 那么量词化的 subrule 或 subpattern 必然会返回一个 Match 对象的列表. (像 "Quantified subpattern captures") 和 "Repeated captures of the same subrule") 中描述的那样). 所以, 别名所对应的数组元素或散列条目会包含一个数组, 而不是单个 Match 对象.

- 换句话说, 别名和量化是完全正交的,例如:

  ```
       if ms/ mv $0=<.file>+ / {
           # <file>+ returns a list of Match objects,
           # so $0 contains an array of Match objects,
           # one for each successful call to <file>
           # $/<file> does not exist (it's suppressed by the dot)
       }

       if m/ mv \s+ $<from>=(\S+ \s+)* / {
           # Quantified subpattern returns a list of Match objects,
           # so $/<from> contains an array of Match  objects,
           # one for each successful match of the subpattern
           # $0 does not exist (it's pre-empted by the alias)
       }
  ```

  ​

  ​

- 注意, 一组量词化的非捕获括号总是返回单个 Match 对象,  该 Match 对象只包含通过全组重复括号匹配到的整个子字符串.(就像 "Named scalar aliases applied to non-capturing brackets") 中描述的那样). 例如:

  ```
       "coffee fifo fumble" ~~ m/ $<effs>=[f <-[f]> ** 1..2 \s*]+ /;
        say $<effs>;    # prints "fee fifo fum"
  ```

  ​



# 数组别名

- 别名也能使用一个数组而非标量作为别名.例如:

  [`S05-capture/array-alias.t lines 13–92`](https://github.com/perl6/roast/blob/master/S05-capture/array-alias.t#L13-L92)

  ```
       m/ mv \s+ @<from>=[(\S+) \s+]* <dir> /;

       "    a b\tc" ~~ m/@<chars>=( \s+ \S+)+/;
       join("|", @<chars>) #     a| b|	c
  ```

- 使用 `@alias=` 记法而非` $alias=`  迫使对应散列条目或数组元素总是接收一个 Match 对象的数组, 即使正被起别名的结构通常返回的是单个 Match 对象. 这对于根据结构不同的备选分支创建一致的捕获语义很有用.(通过在所有分支中强制数组捕获):

  ```
       ms/ Mr?s? @<names>=<ident> W\. @<names>=<ident>
          | Mr?s? @<names>=<ident>
          /;
       # Aliasing to @names means $/<names> is always an Array object, so...
       say @($/<names>);
  ```

  ​

  ​

- 为了方便和一致性,  `@` 也能用在 regex 外面. 作为`@( $/ )` 的简写形式. 即:

  ```
       ms/ Mr?s? @<names>=<ident> W\. @<names>=<ident>
          | Mr?s? @<names>=<ident>
          /;
       say @<names>;
  ```

  ​

- 如果把数组别名应用到量词化的非捕获括号上, 它会捕获由每次括号的重复匹配到的子字符串, 捕获到对应数组的单独的元素中.即:

  ```
       ms/ mv $<files>=[ f.. \s* ]* /; # $/<files> assigned a single
                                       # Match object containing the
                                       # complete substring matched by
                                       # the full set of repetitions
                                       # of the non-capturing brackets
  ```

  ​

  ```
       ms/ mv @<files>=[ f.. \s* ]* /; # $/<files> assigned an array,
                                       # each element of which is a
                                       # Match object containing
                                       # the substring matched by Nth
                                       # repetition of the non-
                                       # capturing bracket match
  ```

  ​

- If an array alias is applied to a quantified pair of capturing parens (i.e. to a subpattern), then the corresponding hash or array element is assigned a list constructed by concatenating the array values of each `Match` object returned by one repetition of the subpattern. That is, an array alias on a subpattern flattens and collects all nested subpattern captures within the aliased subpattern. For example:

  ```
       if ms/ $<pairs>=( (\w+) \: (\N+) )+ / {
           # Scalar alias, so $/<pairs> is assigned an array
           # of Match objects, each of which has its own array
           # of two subcaptures...
           for @($<pairs>) -> $pair {
               say "Key: $pair[0]";
               say "Val: $pair[1]";
           }
       }
  ```

  ​

  ```
       if ms/ @<pairs>=( (\w+) \: (\N+) )+ / {
           # Array alias, so $/<pairs> is assigned an array
           # of Match objects, each of which is flattened out of
           # the two subcaptures within the subpattern

           for @($<pairs>) -> $key, $val {
               say "Key: $key";
               say "Val: $val";
           }
       }
  ```

  ​

- Likewise, if an array alias is applied to a quantified subrule, then the hash or array element corresponding to the alias is assigned a list containing the array values of each `Match` object returned by each repetition of the subrule, all flattened into a single array:

  ```
       rule pair { (\w+) \: (\N+) \n }

       if ms/ $<pairs>=<pair>+ / {
           # Scalar alias, so $/<pairs> contains an array of
           # Match objects, each of which is the result of the
           # <pair> subrule call...

        for @($<pairs>) -> $pair {
               say "Key: $pair[0]";
               say "Val: $pair[1]";
           }
       }
  ```

  ​

  ​

  ```
       if ms/ mv @<pairs>=<pair>+ / {
           # Array alias, so $/<pairs> contains an array of
           # Match objects, all flattened down from the
           # nested arrays inside the Match objects returned
           # by each match of the <pair> subrule...

          for @($<pairs>) -> $key, $val {
               say "Key: $key";
               say "Val: $val";
           }
       }
  ```

  ​

- In other words, an array alias is useful to flatten into a single array any nested captures that might occur within a quantified subpattern or subrule. Whereas a scalar alias is useful to preserve within a top-level array the internal structure of each repetition.

- It is also possible to use a numbered variable as an array alias. The semantics are exactly as described above, with the sole difference being that the resulting array of `Match` objects is assigned into the appropriate element of the regex's match array rather than to a key of its match hash. For example:

  ```
       if m/ mv  \s+  @0=((\w+) \s+)+  $1=((\W+) (\s*))* / {
           #          |                |
           #          |                |
           #          |                 \_ Scalar alias, so $1 gets an
           #          |                    array, with each element
           #          |                    a Match object containing
           #          |                    the two nested captures
           #          |
           #           \___ Array alias, so $0 gets a flattened array of
           #                just the (\w+) captures from each repetition

           @from     = @($0);      # Flattened list
           $to_str   = $1[0][0];   # Nested elems of
           $to_gap   = $1[0][1];   #    unflattened list
       }
  ```

  ​

- 再次注意, 在 regex 外面, `@0` 就是 `@($0)` 的简写形式, 所以上面代码中的第一次赋值也能写作这样:

  ```
       @from = @0;
  ```

  ​



# 散列别名

- An alias can also be specified using a hash as the alias variable, instead of a scalar or an array. For example:
  [`S05-capture/hash.t lines 13–159`](https://github.com/perl6/roast/blob/master/S05-capture/hash.t#L13-L159)

  ```
       m/ mv %<location>=( (<ident>) \: (\N+) )+ /;
  ```

  ​

- A hash alias causes the corresponding hash or array element in the current scope's `Match` object to be assigned a (nested) Hash object (rather than an `Array` object or a single `Match` object).

- If a hash alias is applied to a subrule or subpattern then the first nested numeric capture becomes the key of each hash entry and any remaining numeric captures become the values (in an array if there is more than one).

- As with array aliases it is also possible to use a numbered variable as a hash alias. Once again, the only difference is where the resulting `Match` object is stored:

  ​

  ``` perl
  rule one_to_many {  (\w+) \: (\S+) (\S+) (\S+) }

     if ms/ %0=<one_to_many>+ / {
       # $/[0] contains a hash, in which each key is provided by
       # the first subcapture within C<one_to_many>, and each
       # value is an array containing the
       # subrule's second, third, fourth, etc. subcaptures...

       for %($/[0]) -> $pair {
             say "One:  $pair.key()";
             say "Many: { @($pair.value) }";
         }
     }
  ```

  ​

  - 在 regex 外部, `%0` 是  `%($0)`的简写:

```
       for %0 -> $pair {
           say "One:  $pair.key()";
           say "Many: @($pair.value)";
       }
```



# 外部别名

[`S05-capture/external-aliasing.t lines 6–38`](https://github.com/perl6/roast/blob/master/S05-capture/external-aliasing.t#L6-L38)

- 代替像这样在内部使用别名:



```
   m/ mv  @<files>=<ident>+  $<dir>=<ident> /
```

 普通变量名能用作外部别名, 像这样:

```
   m/ mv  @OUTER::files=<ident>+  $OUTER::dir=<ident> /
```



- In this case, the behavior of each alias is exactly as described in the previous sections, except that any resulting capture is bound directly (but still hypothetically) to the variable of the specified name that must already exist in the scope in which the regex is declared.



# 从重复匹配中捕获


- When an entire regex is successfully matched with repetitions (specified via the `:x` or `:g` flag) or overlaps (specified via the `:ov` or `:ex` flag), it will usually produce a sequence of distinct matches.

- A successful match under any of these flags still returns a single `Match` object in `$/`. However, this object may represent a partial evaluation of the regex. Moreover, the values of this match object are slightly different from those provided by a non-repeated match:

  For example:



``` perl
   if $text ~~ ms:g/ (\S+:) <rocks> / {
       say "Full match context is: [$/]";
   }
```



  ​

  But the list of individual match objects corresponding to each separate match is also available:

  ​



``` perl
   if $text ~~ ms:g/ (\S+:) <rocks> / {
       say "Matched { +lol() } times";    # Note: forced eager here by +

       for lol() -> $m {
           say "Match between $m.from() and $m.to()";
           say 'Right on, dude!' if $m[0] eq 'Perl';
           say "Rocks like $m<rocks>";
       }
   }
```

  ​

  - The boolean value of `$/` after such matches is true or false, depending on whether the pattern matched.
  - The string value is the substring from the start of the first match to the end of the last match (*including*any intervening parts of the string that the regex skipped over in order to find later matches).
  - Subcaptures are returned as a multidimensional list, which the user can choose to process in either of two ways. If you refer to `@().flat` (or just use `@()` in a flat list context), the multidimensionality is ignored and all the matches are returned flattened (but still lazily). If you refer to `lol()`, you can get each individual sublist as a `Parcel` object. As with any multidimensional list, each sublist can be lazy separately.



# Grammars

- 你私有的  `ident` rule 不能重写其它人的 `ident` rule. 所以需要某种机制将 rules 限制到一个名称空间中.
- 如果 subs 是 rules 的模型, 那么 `modules/classes` 明显就是用于凝聚它们的模型. 这种 rules 的集合就是所谓的 *grammars*​
- 就像一个类能把具名的 actions 收集在一起,  grammar 也能把一组具名的 `rules` 收集在一起:



```
   class Identity {
       method name { "Name = $!name" }
       method age  { "Age  = $!age"  }
       method addr { "Addr = $!addr" }

       method desc {
           print &.name(), "\n",
                 &.age(),  "\n",
                 &.addr(), "\n";
       }
       # etc.
   }
```

```
   grammar Identity {
       rule name { Name '=' (\N+) }
       rule age  { Age  '=' (\d+) }
       rule addr { Addr '=' (\N+) }
       rule desc {
           <name> \n
           <age>  \n
           <addr> \n
       }

       # etc.
   }
```



- 像类那样, grammars 也能继承:
  [`S05-grammar/inheritance.t lines 6–80`](https://github.com/perl6/roast/blob/master/S05-grammar/inheritance.t#L6-L80)



```
   grammar Letter {
       rule text     { <greet> $<body>=<line>+? <close> }
       rule greet    { [Hi|Hey|Yo] $<to>=\S+? ','       }
       rule close    { Later dude ',' $<from>=.+        }
       token line    { \N* \n                           }
   }

   grammar FormalLetter is Letter {
       rule greet { Dear $<to>=\S+? ','            }
       rule greet { Dear $<to>=\S+? ','            }
       rule close { Yours sincerely ',' $<from>=.+ }
   }
```



- 就像类中的方法,  grammar 中 rule 定义也是继承的(并且是多态的!). 所以没有必要重新指定文本, 行等等.
  [`S05-capture/dot.t lines 88–122`](https://github.com/perl6/roast/blob/master/S05-capture/dot.t#L88-L122)

  ​

- Perl 6 会携带至少一个预定义好的 grammar:



```
   grammar STD {    # Perl's own standard grammar

        rule prog { <statement>* }

        rule statement {
                 | <decl>
                 | <loop>
                 | <label> [<cond>|<sideff>|';']
       }

       rule decl { <sub> | <class> | <use> }

       # etc. etc. etc.
   }
```



- 因此:

```
   $parsetree = STD.parse($source_code)
```

- 你可以使用 `:lang` 副词在 regex 的中间切换到不同的 grammar. 例如, 要匹配一个嵌在花括号中来自于 `$funnylang` 的表达式  `<expr>`, 要说:

```
  token funnylang { '{' [ :lang($funnylang.unbalanced('}')) <expr> ] '}' }
```

- 通过在 grammar 身上调用  `.parse` 或 `.parsefile` 方法, 字符串就能与 grammar 匹配, 并且可以传递一个可选的 actions 对象给 grammar:

  [`S05-grammar/action-stubs.t lines 7–36`](https://github.com/perl6/roast/blob/master/S05-grammar/action-stubs.t#L7-L36)



```
  MyGrammar.parse($string, :actions($action-object))
  MyGrammar.parsefile($filename, :actions($action-object))
```



  ​这创建了一个  `Grammar` 对象,  它的类型指示了当前被解析的语言, 还有派生自哪个用于扩展语言的 grammars. 所有的 grammars 对象派生自 `Cursor`, 所以每个 grammar 对象的值包含了当前匹配的当前状态.  这个新的 grammar 对象然后被作为 `MyGrammar` 的`TOP` 方法(`regex`, `token`, 或 `rule` )的调用者传递. 这个调用的默认 rule 的名字可以使用 `parse` 方法的  `:rule`  具名参数进行重写.  这对于  grammar rules 的单元测试很有用.  作为参数, rules 可以拥有参数, 所以如果必要的话, `:args` 具名参数可以用于传递这样的参数作为 parcel.

  ​

Grammar 对象是不可变的, 所以每个匹配返回不同的匹配状态, 并且多个匹配状态可同时存在.  每个这样的匹配状态被认为是 模式怎样会最终匹配的假设. 在模式匹配中, 一个能回溯的选择能在 Perl 6中作为一个匹配状态指针的惰性列表被轻易描绘. 回溯由只抛弃列表前面的值并继续匹配下一个值组成. 因此, 这些匹配指针的管理控制着回溯是怎样工作的, 并且从惰性列表的词形变化表中自然地往下落

  ​

  `.parse` 和 `.parsefile` 方法锚定到文本的开头和结尾,  并且如果没有到达文本的结尾会失败.(`TOP` rule 能自己检查 `$`, 如果它想产生它自己的错误信息.)

  ​

  如果你想解析一部分文本, 那么使用 `subparse` 代替. 你可能传递一个 `:pos` 参数从某个不是 0 的位置开始解析. 你可能传递一个 `:rule` 参数来指定你想调用哪个 `subrule`. 通过检查返回的 Match 对象决定最终的位置.

  ​

# Action 对象

Action 对象(由 `Grammar.parse` 中的 `:actions` 具名参数提供)的方法对应于 grammar 中的 rules. 当 grammar 中的 rule 匹配时, action 对象中与 grammar 中的同名方法( 如果有的话) 就会用于 grammar 正在构建的 Match 的 AST 中.  

 Action 方法只有一个参数(为了方法, $/), 它包含了 rule 的 Match 对象. 只要对应的 rule 成功匹配, Action 方法就会被调用, 不管匹配是一个零宽匹配还是一个最终失败的回溯分支, 所以 要通过 AST 来跟踪状态, 并且副作用可能导致意想不到的行为.



Action 方法是在 rule 的调用帧中被调用的, rule 中的动态变量设置被传递给了 action 方法.



# 句法分类

[`S05-syntactic-categories/new-symbols.t lines 7–33`](https://github.com/perl6/roast/blob/master/S05-syntactic-categories/new-symbols.t#L7-L33)

要写你自己的反引号和断言 subrules,  你可以使用下面的句法分类来扩展(你的拷贝) Regex sublanguage:



``` perl
    augment slang Regex {
        token backslash:sym<y> { ... }   # define your own \y and \Y
        token assertion:sym<> { ... }   # define your own <stuff>
        token metachar:sym<,>  { ... }   # define a new metacharacter
        multi method tweak (:$x) {...}   # define your own :x modifier
    }
```



# 编译指令

各种编译指令能用于控制 regex 编译的各个方面和未提供的用法. 这些被捆绑到特殊声明符 ? 上:



``` perl
 use s :foo;         # control s defaults
 use m :foo;         # control m defaults
 use rx :foo;        # control rx defaults
 use regex :foo;     # control regex defaults
 use token :foo;     # control token defaults
 use rule :foo;      # control rule defaults
```



# 转换
  [`S05-transliteration/trans.t lines 11–270`](https://github.com/perl6/roast/blob/master/S05-transliteration/trans.t#L11-L270)

-  `tr///` quote-like 操作符现在有一个叫做 `trans()`的方法. 它的参数是一个 pairs 的列表. 你可以使用任何能产生 pair 列表的东西:

```
   $str.trans( %mapping.pairs );
```

  使用 `.=` 形式做就地转换:

``` perl
   $str.=trans( %mapping.pairs );
```

(Perl 6 不支持 `y///` 形式, 这种形式只存在于 sed 中, 因为它们用光了单个字母.)



- pair 的两边可以像 `tr///` 那样解释字符串:

```
   $str.=trans( 'A..C' => 'a..c', 'XYZ' => 'xyz' );
```

  作为一种退化了的情况, pair 的每一边都可以是单个字符:

```
   $str.=trans( 'A'=>'a', 'B'=>'b', 'C'=>'c' );
```

空白字符作为字面字符, 作为转换的来源或目标.  `..` 范围序列是在字符串中唯一能被识别的元语法, 尽管你可以理所当然的在双引号中使用反斜线插值. 如果右侧的字符太短,   最后的字符会被重复直到和左侧字符的长度相等. 如果没有最后的字符, 是因为右侧的字符是一个空字符, 代替的是, 匹配的结果被删除.



- pair 的一边或两边也可以是一个数组对象:

``` perl
   $str.=trans( ['A'..'C'] => ['a'..'c'], <X Y Z> => <x y z> );
```

  数组版本是基础原始的形式: 字符串形式的语义正等价于这种形式, 首先展开 `..`, 然后再把字符串分割为单个字符, 然后将它们用作数组.

  ​

- 数组版本的转换能将一个或多个字符映射为一个或多个字符:

``` perl
   $str.=trans( [' ',      '<',    '>',    '&'    ] =>
                ['&nbsp;', '&lt;', '&gt;', '&amp;' ]);
```

  在多于一个输入字符序列匹配的情况下, 最长的那个匹配胜出.在两个相同序列匹配的情况下, 排在第一的那个匹配胜出. 

  与字符串形式一样, 缺失的右侧元素重复最后的那个元素,  而一个空的数组会导致删除.

  ​

- 字符串和数组形式的识别是基础的. 要实现更强大的功能, 左侧的识别元素可以通过构建字符类, 向前查看等 regex 来指定.

```
  $str.=trans( [/ \h /,   '<',    '>',    '&'    ] =>
               ['&nbsp;', '&lt;', '&gt;', '&amp;' ]);
```

```
  $str.=trans( / \s+ / => ' ' );      # 将所有空白挤压为单个空格
  $str.=trans( / <-alpha> / => '' );  # 删除所有的非字母字符
```

  ​​

- 如果箭头右侧是一个闭包, 它会被计算为要替换的值. 如果箭头左侧被一个 regex 匹配, 则在闭包中可以访问到结果匹配对象.

  [`S05-transliteration/with-closure.t lines 5–63`](https://github.com/perl6/roast/blob/master/S05-transliteration/with-closure.t#L5-L63)

  ​

# 替换
  [`S05-substitution/subst.t lines 7–211`](https://github.com/perl6/roast/blob/master/S05-substitution/subst.t#L7-L211)
[`S05-substitution/match.t lines 7–33`](https://github.com/perl6/roast/blob/master/S05-substitution/match.t#L7-L33)

也有 `m//` 和 `s///`形式的方法:

``` perl
$str.match(/pat/);
$str.subst(/pat/, "replacement");
$str.subst(/pat/, {"replacement"});
$str.=subst(/pat/, "replacement");
$str.=subst(/pat/, {"replacement"});
```

 `.match` 和 `.subst` 方法支持 `m//` 和 `s///` 的副词作为具名参数, 所以你可以写成:

``` perl
$str.match(/pat/, :g)
```

这等价于

``` perl
$str.comb(/pat/, :match)
```

这儿没有语法糖, 所以为了获得 replacement 延时计算, 你必须把它放到一个闭包中. 只有在 quotelike 形式才提供有语法糖. 首先, 有一个标准的 "triple quote" 形式:

``` perl
s/pattern/replacement/
```

只有非括号字符才能被用于"triple quote"中.  右侧总是被当作在双引号中求值, 不管所选的引号是什么.

就像 Perl 5, 也支持括号形式, 但是不像 Perl 5, Perl 6 只在模式周围使用括号. replacement 被指定为就像普通的 item 赋值一样, 使用普通的引号 rules.  要在右侧选择你自己的引号, 只使用其中的一种 q 形式就好.  上面的替换等价于:
  [`S05-substitution/subst.t lines 223–323`](https://github.com/perl6/roast/blob/master/S05-substitution/subst.t#L223-L323)

``` perl
s[pattern] = "replacement"
```

或

``` perl
s[pattern] = qq[replacement]
```

这不是普通的赋值, 因为每次替换一匹配,右侧就会被求值一次. 这因此被称为形式转换. 它会被作为一段创建了动态作用域而非词法作用域的代码被调用. (你也可以把 thunk 看作一个使用当前词法作用域的闭包).实际上, 使用下面这个也没有影响:

``` perl
s[pattern] = { doit }
```

因为那会把闭包替换成字符串.

任何标量赋值操作符都能被使用; 那个替换宏知道怎么转换
  [`S05-substitution/subst.t lines 324–480`](https://github.com/perl6/roast/blob/master/S05-substitution/subst.t#L324-L480)

``` perl
$target ~~ s:g[pattern] op= expr
```

为如下这样:

``` perl
$target.=subst(rx[pattern], { $() op expr }, :g)
```

`s///` 的实际实现必须返回一个 Match 对象以使智能匹配能正确工作.  上面的重写只返回了改变了的字符串.

所以, 举个例子, 你可以把每个美元符号的数量乘以 2:

``` perl
s:g[$ <( \d+ )>] *= 2
```

(当然, 优化比实际调用要快)



你会注意到上面一个例子, 由于匹配的结果, 替换只发生在”正式的”字符串上, 即,  `$/.from` 和 `$/.to` 位置之间的那部分字符串.( 这里我们使用   `<(…)>` pair  显式地设置了那些, 否则,我们可能必须使用向前查看来匹配 `$`)

请注意,  `:ii`/`:samecase` 和 `:mm`/`:samemark`  开关实际上是一根绳子上的两个蚂蚱, 当编译器给 quote-like 形式的开关脱去语法糖时, 它会把语义分配给模式和替换部分.  即, 作用于替换上的 `:ii`  隐含了模式上的  `:i`,    `:mm` 隐含了 `:m`.

``` perl
    s:ii/foo/bar/
    s:mm/boo/far/
```

 不是:

``` perl
.subst(/foo/, 'bar', :ii)   # WRONG
.subst(/boo/, 'far', :mm)   # WRONG
```

而是:

``` perl

```



它专门不要求实现把正则表达式作为关于大小写和标记的通用实现。追溯重新编译是有害的。如果一个实现确实执行懒惰的一般的大小写和标记语义，它对于依赖于它的程序来说是错误的和不可移植的。 (天了噜, 这究竟怎么翻译?!)



`s///` 和 `.subst` 形式的不同之处在于, `.subst` 返回修改过的字符串(因此不能用作智能匹配器), `s///` 形式要么返回一个  `Match` 对象, 来标示智能匹配成功了, 要么返回一个 `Nil` 值标示没有成功.  



同样地, 对于 `m:g` 匹配和 `s:g` 替换, 可能会找到多个匹配. 这些结构必须在智能匹配时仍旧能继续工作然后返回一个匹配列表. 幸运的是, `List` 是一个知名的类型, 匹配器能返回这个类型来标示匹配成功或失败. 所以这些结只是返回一个成功匹配的列表, 如果没有出现匹配则它会是一个空的列表(因此匹配失败).



# 位置匹配, 固定宽度类型

- 在通常情况下, 要锚定到一个特定的位置你可以使用  `<at($pos)>` 断言, 来说当前位置和你提供的位置对象是相同的. 你可以通过 `:c` 和 `:p` 修饰符设置当前的匹配位置.

  ​

  然而, 请记住在 Perl 6 中, 字符串位置通常不是整数, 而是指向字符串中特定位置的对象, 不管你使用字节或代码点还是字形来计数. 如果使用的是整数, `at` 断言就会假设你意指当前词法作用域的 Unicode 级别, 假设这个整数是以某种方式在同一个这样的词法作用域中生成的. 如果这在当前字符串允许的 Unicode 抽象级别之外,会抛出异常. 查看 `$02` 获取字符串位置的更多讨论.

  ​

-  `Buf` 类型基于固定宽度的单元格, 因此处理整数位置刚刚好, 并把它们当作数组切片. 特别地, `buf8` (也是熟知的 `buf`) 就是老式的字节字符串. 在没有显式修饰符询问数组的值将被看作某种诸如 UTF-32的特殊编码时,  匹配 `Buf` 类型被约束为 ASCII 语义.(这对于那些跟 `Buf` 同构的紧致数组也适用). `Buf` 类型中的位置总是整数, 基本数组的的每个单元格计数 1. 注意 `from` 和 `to` 位置是在元素之间的. 如果匹配一个紧致的数组 `@foo`, 最后的位置 42 标示 `@foo[42]` 是未被包含的首个元素. (*翻译的真辛苦, 还不知所云, 坚持把!*)





# 匹配非字符串
  [`S05-nonstrings/basic.t lines 7–46`](https://github.com/perl6/roast/blob/master/S05-nonstrings/basic.t#L7-L46)

- 任何可以绑到字符串上的东西都可以用  regex 匹配. 这个特性对输入流特别有用:

``` perl
my $stream := cat $fh.lines;       # tie scalar to filehandle
# and later...
$stream ~~ m/pattern/;             # match from stream
```

  ​

- 任何混合了字符串或对象的非紧致数组能匹配一个 regex, 只要你使用 `Str` 接口把它们呈现为对象, 这不妨碍其它对象含有诸如 `Array` 之类的其它接口. 正常地, 你会使用 `cat` 来生成这样的对象:

```
  @array.cat ~~ / foo <,> bar <elem>* /;
```

  ​

  那个特殊的 `<,>` subrule 匹配元素之间的边界.   `<elem>` 断言匹配任何单独的数组元素.  整个 `<elem>` 元素就是点元字符的等价物.

  ​

如果数组元素是字符串, 事实上它们被连接成单个逻辑字符串. 如果数组元素是  tokens 或 其它这样的对象, 那么对象必须为这样的 subrules 提供合适的方法来匹配. 将字符串匹配断言和未提供字符串化查看的对象进行匹配会导致断言失败. 然而, 纯对象列表可以被解析, 只要匹配(包括任何 subrules)把自身约束为这样的断言:

```
   <.isa(Dog)>
   <.does(Bark)>
   <.can('scratch')>
```



  ​把对象和字符混合在数组中也是可以的, 只要它们在不同的元素中. 然而你不能在字符串中嵌入对象. 当然, 任何对象都可以假装它是一个字符串元素, 所以, `Cat` 对象可以用作子字符串, 使用与主字符串中同样的约束.

请注意,匹配数组时,  `.from` 和 `.to` 都会返回不透明对象的警告, 在一个特殊的位置, 这个位置既反映在数组中的位置, 又在数组的字符串中的位置. 不要期望使用这样的值来做匹配,  你也不要期望能跨越元素边界来提取子字符串[猜测:难道不是吗?] :PS  简直无法翻译!



- 要匹配数组中的每一个元素, 使用 hyper 操作符:

```
   @array».match($regex);
```

- 要匹配数组中的任意元素, 使用普通的智能匹配就足够了:

```
  @array ~~ $regex;
```



#  `$/` 在什么时候是有效的


为了提供实施自由, `$/` 变量并不能保证被定义, 直到模式到达需要它的序列点.(例如, 完成了匹配, 或者调用了嵌入的闭包, 或者计算一个 Perl 表达式作为它的参数的 submatch.)  在 regex 代码里面,  `$/` 未被正式定义, 引用 `$0` 或其它变量可能被编译产生当前值, 而不用引用 `$/`.  同样地,  引用 `$<foo>` 并不意味着 regex 中就有 `$/<foo>` . 在执行匹配期间, 当前匹配状态实际上存储在词法作用域到匹配部分的 `$¢` 变量中, 但是它不保证和 `$/` 对象的表现一样, 因为 `$/` 是 `Match` 类型, 而匹配状态的类型是从 `Cursor` 派生出来的.



在任何情况下, 这对于用户的简单匹配都是透明的; 在 regex 代码之外(还有 regex 的闭包中) `$/` 变量保证代表那个点的匹配状态. 即,  一般的 Perl 代码总是依靠 `$<foo>` 表示 `$/<foo>`,  依靠 `$0` 表示 `$/[0]` , 不论代码是嵌入在 regex 的闭包中还是在 regex 的外面, 在整匹配之后.



# 作者



```
    Damian Conway <damian@conway.org>
    Allison Randal <al@shadowed.net>
    Patrick Michaud <pmichaud@pobox.com>
    Larry Wall <larry@wall.org>
    Moritz Lenz <moritz@faui2k3.org>
    Tobias Leich <email@froggs.de>
```
