Day 12 – Smart matching
By Ttjjss
还记得http://perl6advent.wordpress.com/2010/12/04/the-sequence-operator/ 序列操作符吗?因为最后一个参数它接受的是一个上限，这让序列的生成停止了，例如：


    1, 2, 4 ... 32;         # 1 2 4 8 16 32
    1, 2, 4 ... * > 10 ;     # 1 2 4 8 16
    > 1,2,4 ... *>100
    1 2 4 8 16 32 64 128
    > 1,2,4 ...^ *>100
    1 2 4 8 16 32 64
你能看到，在第一种情况下，使用了数值相等。第二个更有意思： *>10 在内部被重写为一个闭包，像这样 -> $x { $x > 10 } (through currying).


序列操作符做了一些不可思议的比较，根据匹配者的类型。这种比较就叫做智能匹配，并且是在Perl6中重复出现的一个概念，例如：


    # after the 'when' keyword:
    given $age {
        when 100    { say "congratulations!"      }
        when * < 18 { say "You're not of age yet" }
    }
    # after 'where':
    subset Even of Int where * %% 2;
    # 显式地使用智能匹配操作符:
    if $input ~~ m/^\d+$/ {
        say "$input is an integer";
    }
    # arguments to grep(), first() etc.:
    my @even = @numbers.grep : Even ;
在智能操作符 ~~ 的右侧，并且在 when 和 where 的后面，要匹配的值被设置为 主题变量 $_. This allows us to use constructs that operate on $_, like regexes created with m/.../ and .method_call.


下面是一些智能操作符的用法：


    #它的类型是 Str吗?
    $foo ~~ Str
    #它等于 6 吗?
    $foo ~~ 6
    #或者它是 "bar" 吗?
    $foo ~~ "bar"
    # 它匹配某个模式吗?
    $foo ~~ / \w+ '-' \d+ /
    # 它的值在 15 和 25 之间吗?
    $foo ~~ (15..25)
    # 调用闭包
    $foo ~~ -> $x { say 'ok' if 5 < $x < 25 }
    # 含有6个元素的数组，是否其所有的奇数元素的值都为 1?
    $foo ~~ [1, *, 1, *, 1, *]
智能匹配的全部表现可以在这找到：
http://perlcabal.org/syn/S03.html#Smart_matching.


智能匹配没有特殊的操作符，而大部分智能匹配的情况会返回 Bool值，对正则进行匹配会返回一个Match 对象


你可能开始怀疑：一个正确的，内置的类型，我怎么将它用在我自己的类中？你需要为它写一个特别的 ACCEPTS方法。假如我们有一个叫Point 的类：




    class Point {
        has $.x;
        has $.y;
        method ACCEPTS (Positional $p2) {
            return $.x == $p2[0] and $.y == $p2[1]
        }
    }
一切都清楚了吗?让我们看看它是如何工作的:


    my $a = Point.new(x => 7, y => 9);
    say [3, 5] ~~ $a; # Bool::False
    say (7, 9) ~~ $a; # Bool::True
 现在能恰当地做到你想要的，甚至使用你自己的类。