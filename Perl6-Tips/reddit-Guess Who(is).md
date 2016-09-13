
你是一个刚成立的小公司里的一名软件工程师, 有天晚上你收到了一封来自CEO 的电子邮件:

> 亲爱的工程师,
> 
> ​    好新闻！看起来我们的网站越来越受欢迎。我们要变的有钱了! 每秒钟有成千上万的人在同时访问我们的网站, 而且还在快速增长。
> 
> 我们必须立即识别出谁的通信量最大。幸运的是我的朋友给我发送了一份巨大的 IP 地址和名字的列表。很酷不是吗？你能写一段程序接收我们大量的访问者, 把它和地址/ 名字列表相比, 并创建一些统计吗？我的意思是, 生成一个国家的名字列表, 每个
> 
> 做好了的话我给你们开个披萨聚会。

邮件的附件文件包含了一个 IP 地址和名字的列表。写一个程序来统计下有多少 IP 访问了你的网站。

#### 输入描述

输入来自两部分。第一个是一个文本文件, 包含 IP 地址范围。每行一项,使用两个空格分割 IP 和名字。

第二个文件是一个 IP 地址的列表, 每行一个, 它们是必须被查询的IP。

#### IP 输入样本

输入是有包含两个 IP 地址和一个跟 IP 范围关联的名字的大量行组成。

``` perl
123.45.17.8 123.45.123.45 University of Vestige
123.50.1.1 123.50.10.1 National Center for Pointlessness
188.0.0.3 200.0.0.250 Mayo Tarkington
200.0.0.251 200.0.0.255 Daubs Haywire Committee
200.0.1.1 200.255.255.255 Geopolitical Encyclopedia
222.222.222.222 233.233.233.233 SAP Rostov
250.1.2.3 250.4.5.6 Shavian Refillable Committee
123.45.100.0 123.60.32.1 United Adverbs
190.0.0.1 201.1.1.1 Shavian Refillable Committee
238.0.0.1 254.1.2.3 National Center for Pointlessness
```

注意: 这些 IP 范围不能保证是 IPv4 "子网"。这意味着它们可能不能精确地由基于前缀的 CIDR 块来表示。

范围可以重叠。可能多余2层深。

可可有多个范围关联同一个名字。

#### 查询输入样本

``` perl
250.1.3.4
123.50.1.20
189.133.73.57
123.50.1.21
250.1.2.4
123.50.1.21
250.1.3.100
250.1.3.5
188.0.0.5
123.50.1.100
123.50.2.34
123.50.1.100
123.51.100.52
127.0.0.1
123.50.1.22
123.50.1.21
188.0.0.5
123.45.101.100
123.45.31.52
230.230.230.230
```

#### 输出格式化

倒序输出访问次数。

``` perl
8 - National Center for Pointlessness
4 - Shavian Refillable Committee
3 - Mayo Tarkington
2 - University of Vestige
1 - SAP Rostov
1 - United Adverbs
1 - <unknown>
```

#### 解释

这儿是一个输入 IP 和它的名字的映射:

``` perl
National Center for Pointlessness
123.50.1.20
123.50.1.21
123.50.1.22
123.50.1.21
123.50.1.21
123.50.1.100
123.50.1.100
123.50.2.34

Shavian Refillable Committee
250.1.2.4
250.1.3.4
250.1.3.5
250.1.3.100

Mayo Tarkington
188.0.0.5
188.0.0.5
189.133.73.57

University of Vestige
123.45.101.100
123.45.31.52

SAP Rostov
230.230.230.230

United Adverbs
123.51.100.52

<unknown>
127.0.0.1
```

smls的解决方法:

``` perl
sub ip-to-number ($ip) {
    do given $ip.split('.') {
        .[0] +< 24 +
        .[1] +< 16 +
        .[2] +<  8 +
        .[3] +<  0
    }
}
class IntervalTree {
    has $.min;
    has $.max;
    has $!center = ($!min + $!max) div 2;
    has @!intervals;
    has IntervalTree $!left;
    has IntervalTree $!right;
    method new ($min, $max) { self.bless(:$min, :$max) }
    method insert (|c ($start, $end, $name)) {
        if $end < $!center and $!min < $!center - 1 {
            ($!left //= self.new($!min, $!center)).insert(|c)
        }
        elsif $start > $!center and $!max > $!center {
            ($!right //= self.new($!center, $!max)).insert(|c)
        }
        else {
            @!intervals.push: [$start, $end, $name, $end-$start]
        }
    }
    method prepare {
        @!intervals.=sort(*[3]);
        $!left .prepare if $!left;
        $!right.prepare if $!right;
    }
    method lookup ($n) {
        my $best = ($n < $!center ?? ($!left .lookup($n) if $!left)
                                  !! ($!right.lookup($n) if $!right));
        $best ?? @!intervals.first({ return $best if .[3] > $best[3];
                                     .[0] <= $n <= .[1] }) // $best
              !! @!intervals.first({ .[0] <= $n <= .[1] })
    }
}
sub MAIN ($ip-file, $query-file) {
    my $index = IntervalTree.new(0, ip-to-number '255.255.255.255');
    for $ip-file.IO.lines {
        my ($start, $end, $name) = .split(' ', 3);
        $index.insert(ip-to-number($start), ip-to-number($end), $name);
    }
    $index.prepare;
    for $query-file.IO.lines -> $ip {
        my $name = $index.lookup(ip-to-number $ip)[2];
        say "$ip {$name // '<unknown>'}";
    }
}
```

