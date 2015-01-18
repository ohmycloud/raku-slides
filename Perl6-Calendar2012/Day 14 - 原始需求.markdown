

人类的大脑天生就会查找模式，哪怕其实并不存在。所以，我们一点不奇怪当人类刚开始计数的时候，就开始寻找数字的模式。而拒绝人类大脑的模式匹配功能的一组数字，就被叫做"质数"。质数就是只能被 1 和它本身整数的数。

不过这些读者都知道了，那我为什么还要讲质数而不是 Perl6 呢？因为就人类的祖先一样，创造 Perl6 并且希望在未来 100 年甚至更长时间内持续改进它的人们发现质数是个很有意思的东西。有趣到了特意修改 Perl6 的规范加上一个例程来检查数字是否是质数。 Alpha 版

最开始，这个质数查找器的实现是纯 Perl6 的，并且还使用了 Perl6 的其他特性比如 Range 和 Junction。下面是示例：
    sub is-prime($n) { $n %% none 2..sqrt $n }

这个实现检查从 2 到 $n 的平方根都不能整除 $n 的话，这个数就是质数。

虽然上面这个实现结果是对的，不过运行比较慢，而且在检查的数字上有点冗余。比如，当你知道这个数字不被 2 整除的适合，没必要再检查 4 了。上面的算法没有考虑这些。 Beta 版

对算法的改进是只检查从2到均分此数字的数字的平方根。不过……不过这个跟定义一个数字本身是一样的。感谢 Perl6 中无处不在的延迟计算，让这个改进变成可能。下面是实现：

    my @primes := 2, 3, 5, -> $p { ($p+2, $p+4 ... &is-prime)[*-1] } ... *;
    sub is-prime($n) { $n %% none @primes ...^  * > sqrt $n }

数组 @primes 是一个无限的延迟计算的数字序列，以 2，3，5开头，下一个数字是由前面最后一个奇数开始，到下一个质数结束，而组成的新的奇数序列生成的。结束处的那个质数就是序列里的下一个数字。不过我们怎么知道他是不是质数呢？我们另外用 C 实现了最开始的那个一直检查到平方根的函数，然后以此检查这里的算法是否正确。

@primes 数组通过一种相互递归有效的缓存(译者注：memoizes，我觉得是 memories 的typo )了我们所能看到的全部质数。不过， @primes 数组跟着质数的量一起越来越大，问题也出来了。我们可以做的更好一点么？

事实上我们可以。 Gamma: 米勒-拉宾法

额， 或许 我们可以。这取决与你对"更好"的定义。 米勒-拉宾素性判定 在本质上是非确定性的。他不要求存储一个持续增长的质数数组缓存来测试他们是否可能是潜在的质数，但是有可能它会把实际不是质数的数字当成质数反馈给你。不过我们可以调整这个可能性让我们有理由相信这个数字就是质数。下面是实现（从 http://rosettacode.org/wiki/Miller-Rabin_primality_test#Perl_6 摘录）：

sub expmod(Int $a is copy, Int $b is copy, $n) {
    my $c = 1;
    repeat while $b div= 2 {
        ($c *= $a) %= $n if $b % 2;
        ($a *= $a) %= $n;
    }
    $c;
}
 
subset PrimeCandidate of Int where { $_ > 2 and $_ % 2 };
 
my Bool multi sub is-prime(Int $n, Int $k)            { return False; }
my Bool multi sub is-prime(2, Int $k)                 { return True; }
my Bool multi sub is-prime(PrimeCandidate $n, Int $k) {
    my Int $d = $n - 1;
    my Int $s = 0;
 
    while $d %% 2 {(PrimeCandidate $n, Int $k)
        $d div= 2;
        $s++;
    }
 
    for (2 ..^ $n).pick($k) -> $a {
        my $x = expmod($a, $d, $n);
 
        next if $x == 1 or $x == $n - 1;
 
        for 1 ..^ $s {
            $x = $x ** 2 mod $n;
            return False if $x == 1;
            last if $x == $n - 1;
        }
        return False if $x !== $n - 1;
    }
 
    return True;
}

带有 (PrimeCandidate $n, Int $k) 签名的那个 is-prime 的第三个变体就是魔法发生的地方。这个变体只会在质数候选( $n )是奇数的时候才触发。因为它定义了 PrimeCandidate 类型。

首先我们从 $n -1 求出 2 的幂因子。因为 $n 是个奇数， $n - 1 是偶数所以至少有一个 2 的因子。最终得到一个奇数和一些 $n - 1 的 2 的幂因子。然后我们用这些因子来检查一个比 $n 小的随机的 $k 是否全等于统一模 $n ( expmod 函数处理模的求幂)的平方根。对原始数字求的全部2的幂因子，我们都重复做这个检测。 费马小定理 说，如果我们找到任何一个数不一致的，这个数就不是质数。

这个方法会选出一个合成数作为质数的概率取决于我们选择了多少个小于 $n 的数作为样本。如果我们选择测试了 $k 个数，那么概率就是 4 ** -$k 。通过选择更多的测试个数，我们可以快速的把假质数的可能性降到微不足道的程度。 包装

不过……大多数人可能不会真的担心 is-prime 的实现细节。不单 is-prime 和 expmod 被加入了 Perl6 规范，而且（米勒-拉宾法的）实现也确实被加入了 Rakudo 和 Niecza 的 Perl6 编译器。所以，如果你想测试自己新的加密算法所以需要一些很大的质数，或者你在开发新的随机数生成器所以需要给模数准备一些候选，或者可能是在开发新的哈希算法，记住，Perl6 内置的 is-prime 可以帮助你。

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2012/%E7%AC%AC%E5%8D%81%E5%9B%9B%E5%A4%A9:%E5%8E%9F%E5%A7%8B%E9%9C%80%E6%B1%82.markdown >  