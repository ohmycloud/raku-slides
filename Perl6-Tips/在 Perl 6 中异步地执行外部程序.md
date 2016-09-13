[Execute an external program with timeout in Perl6](http://ks0608.hatenablog.com/entry/2016/05/17/001826)

Proc::Async 允许我们异步地执行外部程序。

```perl6
my $proc = Proc::Async.new("curl", "-s", "-o", "index.html", "http://www.cpan.org");
my $res = await $proc.start;
```

我们可以在 Proc::Async 中使用超时吗? Proc::Async 没有正式支持该功能，但是我们可以很容易地实现它。看一下这个：

```perl6
class Proc::Async::Timeout is Proc::Async {
    has $.timeout is rw;
    method start($self: |) {
        return callsame unless $.timeout;
        my $killer = Promise.in($.timeout).then: { $self.kill };
        my $promise = callsame;
        Promise.anyof($promise, $killer).then: { $promise.result };
    }
}

my $proc = Proc::Async::Timeout.new("perl", "-E", "sleep 5; warn 'end'");
$proc.timeout = 1;
my $res = await $proc.start;
say "maybe timeout" if $res.signal;
```

你甚至可以这样做：

```perl6
my $start = Proc::Async.^methods.first(*.name eq "start");

$start.wrap: method ($self: :$timeout, |c) {
    return callwith($self, |c) unless $timeout;
    my $killer = Promise.in($timeout).then: { $self.kill };
    my $promise = callwith($self, |c);
    Promise.anyof($promise, $killer).then: { $promise.result };
};

say await Proc::Async.new("perl", "-E", 'sleep 3; say "end"').start(timeout => 2);
```

哇，哇！如果你发现了更酷的方法，请告诉我。