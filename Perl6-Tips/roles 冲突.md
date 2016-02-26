title:  roles 冲突

date: 2016-01-29

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'> See you again！</blockquote>

学会了怎么创建类, 我们继续用它来构建我们的中心内容:

``` perl6

class Hammer {
    method hammer($stuff) {
        say "You hammer on $stuff. BAM BAM BAM!";
    }
}

class Gavel {
    method hammer($stuff) {
        say "You hammer on $stuff. BAM BAM BAM!";
    }
}

class Mallet {
    method hammer($stuff) {
        say "You hammer on $stuff. BAM BAM BAM!";
    }
}

```

但是注意到了吗？ 这三个方法包含了同样的方法, 在类中重复了。我们必须那样做如果我们想让每个 **Hammar**、**Gavel** 和 **Mallet** 有能力击打的话。（并且那是合理的）。 但是遗憾的是我们不得不把那个方法一式三份。

为什么遗憾？ 因为一方面在真实世界中, 方法并不是很彼此相似, 有一天你决定在 **hammer**  方法中更改某些东西, 并没有意识到这个方法在三个不同的地方... 这导致了一堆痛苦和难受。



所以我们的新玩具, 类, 展现出了一个问题。我们想在每个类中重用 hammer 方法。一个新的概念, **role** 来拯救我们来了:



``` perl6

role Hammering {
    method hammer($stuff) {
        say "You hammer on $stuff. BAM BAM BAM!";
    }
}

```



虽然类经常以一个合适的名词命名, 但是 roles 经常以一个分词命名, 例如 **Hammering**。这不是一个必须遵守的规则, 但是它是一个好的经验法则。现在类的定义变的简单了:

``` perl6

class Hammer does Hammering { }
class Gavel  does Hammering { }
class Mallet does Hammering { }

```



是的, 我们喜欢那样。

这发生了什么？ 我们在类上使用 **does** 是干什么用的？ role 定义中的所有方法都被拷贝到类定义中。因为它是一个拷贝操作, 所以我们可以使用尽可能多的类。

所以, 我们做的是: 当我们想重用方法的时候把方法放进 roles 里面。

但是好处不止这一点儿。至少有两个好处:



``` perl6

my $hammer = Hammer.new;    # create a new hammer object
say $hammer ~~ Hammer;      # "Bool::True" -- yes, this we know
say $hammer ~~ Hammering;   # "Bool::True" -- ooh!

```



所以 `$hammer` 知道它遵守了(does)**Hammering**, 我们现在不仅知道了对象属于哪个类, 还知道了对象并入了什么 role。这很有用如果我们不确定我们处理的是什么类型的对象:

``` perl6

if $unkown_object ~~ Hammering {
    $unknown_object.hammer("砸在钉子上");     # will always work
}

```

一个类能一次接收几个 roles 吗？ 是的, 它可以:

``` perl6

role Flying {
    method fly {
        say "Whooosh!";
    }
}

class FlyingHammer does Hammering does Flying { }

```



让一个类像那样遵守几个 roles 引入了一个有意思的可能: 冲突, 当来自两个不同 roles 的两个同名方法尝试占领同一个类时。这时会发生什么？ 好吧, 至少有 3 种可能:

- 1. 第一个 role 赢了。 它的方法住进了类中
- 1. 最后一个 role 赢了。 它覆盖了之前的方法
- 1. 编译失败。冲突必须被解决。



这种情况下选项 3  应该是正确答案。原因和之前相同: 因为类和工程越来越庞大, 程序员可能意识不到两个 role 之间在哪儿发生冲突。所以我们标记了它。

``` perl6

role Sleeping {
    method lie {
        say "水平躺下";
    }
}

role Lying {
    method lie {
        say "说谎...";
    }
}

class SleepingLiar does Sleeping does Lying { }    # 冲突!

```

下一个问题, 那么: 当在类中有  role 冲突时, 我们怎么修复它？ 简单: 在类中自己定义一个同名的方法:

``` perl6

class SleepingLiar does Sleeping does Lying {
    method lie {
        say "Lying in my sleep....";
    }
}

```



如果你想从一个贴别的 role 中调用一个方法, 语法是这样的:

``` perl6

class SleepingLiar does Sleeping does Lying {
    method lie {
        self.Sleeping::lie;
    }
}

```

﻿

这就是 roles。它们把可重用的行为混合进类中。
