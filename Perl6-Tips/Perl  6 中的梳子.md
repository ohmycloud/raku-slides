# Perl  6 中的梳子!

在 Perl 5 中, 我很感激有这样两个便利的结构:

```perl
my @things = $text =~ /thing/g;
my %things = $text =~ /(key)...(value)/g;
```

你拿出一小段可以预见的文本，并给它一个正则表达式，吼吼, 你得到了一个列表和散列，像变魔术一般！我们也可以在 Perl  6 中使用正则表达式，但是 **[comb](http://docs.perl6.org/routine/comb)** 更适合做这个工作。

![img](http://upload-images.jianshu.io/upload_images/326727-29a3966bbb8e437f.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## Plain 'Ol Characters

你可以把 *comb* 用作子例程或方法。在它的最基本的形式中， *comb* 会把字符串分解为字符:

```Perl6
'foobar moobar 駱駝道bar'.comb.join('|').say;
'foobar moobar 駱駝道bar'.comb(6).join('|').say;

# OUTPUT:
# f|o|o|b|a|r| |m|o|o|b|a|r| |駱|駝|道|b|a|r
# foobar| mooba|r 駱駝道b|ar
```

不适用任何参数的 *comb* 你会得到各个单独的字符。给 *comb* 提供一个整数 `$n`, 那么你会得到长度至多为 `$n` 个字符的一个列表，并且如果没有剩下的字符不够的话，这个列表会接收较短的这个字符串。这个方法比使用正则表快了 30 倍。

## Limits

你也可以为 *comb* 提供第二个整数参数，即 *limit*，来标示每个列表中最多含有 limit 个元素:

```Perl6
'foobar moobar 駱駝道bar'.comb(1, 5).join('|').say;
'foobar moobar 駱駝道bar'.comb(6, 2).join('|').say;

# OUTPUT:
# f|o|o|b|a
# foobar| mooba
```
这适用于使用 *comb* 方法/函数的所有形式，而不仅仅是上面展示的那样。

## 计数

*comb* 也接收普通的 [Str](http://docs.perl6.org/type/Str) 作为参数，返回一个包含那个字符串的匹配的列表。所以这在计算子字符串在字符串中出现的次数时很有用。

```Perl6
'The ?? ran after a ??, but the ?? ran away'.comb('??').Int.say;
'The ?? ran after a ??, but the ?? ran away'.comb('ran').Int.say;

# OUTPUT:
# 1
# 2
```

## 简单的匹配

*comb* 的参数也可以是一个正则表达式，整个匹配会作为一个标量被返回：

```Perl6
foobar moobar 駱駝道bar'.comb(/<[a..z]>+ 'bar'/).join('|').say;

# OUTPUT:
# foobar|moobar
```

## 限制所匹配的东西

你可以使用[环视断言](http://docs.perl6.org/language/regexes#Look-around_assertions)或者更简单的 `<(` 和 `)>` 正则表达式捕获记号:

```perl6
'moo=meow ping=pong'.comb(/\w+    '=' <( \w**4/).join('|').say; # values
'moo=meow ping=pong'.comb(/\w+ )> '='    \w**4/).join('|').say; # keys

# OUTPUT:
# meow|pong
# moo|ping
```

你可以使用  `<(` 和 `)>` 两者之一或两者都使用。 `<(` 从匹配中排除任何它之前的东西而 `)>` 会排序之后的任何东西。即 `/'foo' <('bar')> 'ber'/`  会匹配包含 *foobarber* 的东西，但是从 *comb* 中返回的东西只会有 *bar*。

## 多个捕获

怎么样得出 Perl 5 那样的 键/值对儿呢？

```Perl6
my %things = 'moo=meow ping=pong'.comb(/(\w+) '=' (\w+)/, :match)?.Slip?.Str;
say %things;

# OUTPUT:
# moo => meow, ping => pong
```

圆括号用于捕获。`:match` 参数使 *comb* 返回一个 **Match** 对象的列表，而非返回一个字符串列表。下一步，我们使用两个 hyper 运算符把 **Matches** 转换为 [Slips](http://docs.perl6.org/type/Slip)，这会给我们一个捕获的列表，但是它们仍旧是 **Match** 对象，这就是为什么我们还要把它们转换为 **Str** 的原因。

我们还可以使用具名捕获使代码更清晰：

```Perl6
my %things = 'moo=meow ping=pong'
    .comb(/$<key>=\w+ '=' $<value>=\w+/, :match)
    .map({ .<key> => .<value>.Str });
say %things;

# OUTPUT:
# moo => meow, ping => pong
```

你还可以把上面的代码写成这样：

```Perl6
my %things = ('moo=meow ping=pong' ~~ m:g/(\w+) '=' (\w+)/)?.Slip?.Str;
say %things;

# OUTPUT:
# moo => meow, ping => pong
```

## 结论

把 *comb* 和 *[rotor](http://blogs.perl.org/users/zoffix_znet/2016/01/perl-6-rotor-the-king-of-list-manipulation.html)* 结合起来用会很强大。


## 评论

代替使用带有 `:match` 参数的 `.comb` , 你最好就使用 `.match` 方法好了: 

```Perl6
'moo=meow ping=pong'.match(/(\w+) '=' (\w+)/, :g)
```