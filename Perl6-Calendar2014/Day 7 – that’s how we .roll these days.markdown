# Day 7 – that’s how we .roll these days

    .pick    就像把鹅卵石从罐子中拿走, 不再放回去.
    .roll    就像掷筛子

就给一个具体的例子吧:
```perl
> say <Rock Paper Scissor>.roll
Rock                    # good ol' Rock
```
.roll 等价于 .roll(1).  当我们仅对一个元素感兴趣时, .roll 和 .pick 的效果相同, 因为这时还没有出现替换. 使用哪个看个人喜好了.

我想展示2个关于 .roll 的戏法. 其中一个就是你可以在 Bag 上使用 .roll:

```perl
> my $bag = (white-ball => 9, black-ball => 1).Bag;
bag(white-ball(9), black-ball)
> say $bag.roll         # 90% chance I'll get white-ball...
white-ball              # ...told ya
```
随机重量的需求是完全够用了

另外一个戏法就是你可以在 枚举上使用 .roll:
```perl
> enum Dwarfs <Dipsy Grumpy Happy Sleepy Snoopy Sneezy Dopey>
> Dwarfs.roll
Happy                   # me too!
> enum Die <1 2 3 4 5>
> Die.roll
2
> Die.roll(2)
2 4                     # snake eyes!
> Die.roll(5).sort
2 3 3 4 1
```
用的最多的就是使用 Bool.roll 随机投掷硬币:
```perl
if Bool.roll {
    # heads, I win
}
else {
    # tails, you lose
}
```
Bool 是特殊的枚举类型

```perl
> say Die.HOW
Perl6::Metamodel::EnumHOW.new()
> say Bool.HOW
Perl6::Metamodel::ClassHOW.new()    # audience goes "awwww!"
```