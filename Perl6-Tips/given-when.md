title:  given-when

date: 2016-02-02

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'> 梦想天空分外蓝！</blockquote>

given-when 有两个小的改变, 并且这俩改变都是开启新行为的, 而不是限制已存在的行为。

第一个小的改变: when 的开关行为不仅仅是用于 given 块儿中的, 而是可以用在任何"主题化"的块儿中的, 例如 for 循环中或接收 `$_`作为参数的子例程中。

``` perl6
given $answer {
    when "Atlantis" { say "那是对的" }
    default { say "BZZZZZZZZZZZZZ!" }
}

for 1..100 {
    when * %% 15 { say "Fizzbuzz" }
    when * %% 3  { say "Fizz"     }
    when * %% 5  { say "Buzz"     }
    default      { say $_         }
}

sub expand($_) {
    when "R" { say "红警" }
    when "G" { say "绿警" }
    when "B" { say "蓝警" }
    default  { say $_     }
}
```

但是甚至不接受 `$_`作为参数的子例程也得到了它们自己的词法变量 `$_`供修改。所以规则就是"现在, 在 $_ 中有某些我能启动的好东西吗"。如果我们想要, 我们甚至能自己设置 `$_`。

``` perl6
sub seek-the-answer() {
    $_ = (^100).pick;
    when 42 { say "The answer" }
    default { say "A number"   }
}
```

换句话说, 我们已经知道了 **when** 和 **given** 是单独的。Switch 语句逻辑都在 when 语句中。

第二个小改变: 你可以嵌套 *when* 语句!

我很确信你没有在野外见过这种用法。但它有时候特别有用:

``` perl6
when * > 2 {
    when 4  { say 'Four!' }
    default { say 'huge'  }
}
default {
    say 'little'
}
```

你可能记得, 在 when 块儿中有一个隐式的 *succeed* 语句在末尾, 这让周围的主题化块退出。(意思是你不必记着手动退出 switch 语句)。 如果你想重写 succeed 语句并继续通过 when block, 那么你在 *when* block 的末尾写上一个显式的 *proceed* 即可。

``` perl6
given $verse-number {
    when * >= 12 { say "Twelve drummers drumming"; proceed }
    when * >= 11 { say "Eleven pipers piping"; proceed }
    # ...
    when * >= 5 { say "FIIIIIIVE GOLDEN RINGS!"; proceed }
    when * >= 4 { say "Four calling birds"; proceed }
    when * >= 3 { say "Three French hens"; proceed }
    when * >= 2 {
        say "Two turtle doves";
        say "and a partridge in a pear tree";
    }
    say "a partridge in a pear tree";
}
```

