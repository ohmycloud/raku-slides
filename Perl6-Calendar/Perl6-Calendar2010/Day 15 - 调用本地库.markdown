2010 年 Perl6 圣诞月历(十五)调用本地库

如果你已经用过一段时间的 perl5，你应该碰过一些结尾是 '::XS' 的模块了。或者你可能自己都写过一个？那你可以跳过这段…… XS 是 perl 中调用本地 C 库的方式。这种方式跑起来可是相当棒。不过写这样的模块，可需要付出点努力和汗水才行。毕竟你需要搞定 C 编译器和代码。如果你只是想简单的想把事情做出来而已，那写 XS 可不是啥有趣的事情了。

Perl6 已经做了一些工作减少这些力气活。你可以使用一些外部代码，开头可以这样：

#!/usr/bin/env perl6
use v6;
use NativeCall;

这就行了。NativeCall 来完成和 C 库交流的复杂工作~你不需要自己去编译什么了。在 Rakudo 里，你只需要安装 zavolaj 就可以了。

好了，现在让我们做点有趣的事情吧。我来示范下把 XMMS2 的 C 语言客户端说明的第一部分用 perl6 搞定。

首先，NativeCall 需要知道怎么跟 C 库打交道。目前他可以相互转换的有字符串、数值，和一个叫 OpaquePointer（不透明指针？）的东西。这个不透明指针是为数据库连接句柄这类东西准备的。

在这次的示例代码里，我们要处理的是一个比较奇怪的结构和套接字。让我们假设这些是不透明指针的子类，这没什么实质性后果，但是写起来简单很多：

class xmmsc_connection_t is OpaquePointer;
class xmmsc_result_t is OpaquePointer;
class xmmsv_t is OpaquePointer;

现在是我们要用的这些 C 函数，按照字母顺序排列。这里面有一个函数(译者注：即 xmmsv_get_error )和其他的不同——原版的 C 代码中预期一个 **char 传入，或者说，需要一个空间写入字符串。我们设定为 rw 的 Str 就好啦：

sub xmmsc_connect(xmmsc_connection_t, Str $path)
    returns Int
    is native('libxmmsclient') { ... }
&nbsp_place_holder;
sub xmmsc_get_last_error(xmmsc_connection_t)
    returns Str
    is native('libxmmsclient') { ... }
&nbsp_place_holder;
sub xmmsc_init(Str $clientname)
    returns xmmsc_connection_t
    is native('libxmmsclient') { ... }
&nbsp_place_holder;
sub xmmsc_playback_start(xmmsc_connection_t)
    returns xmmsc_result_t
    is native('libxmmsclient') { ... }
&nbsp_place_holder;
sub xmmsc_result_get_value(xmmsc_result_t)
    returns xmmsv_t
    is native('libxmmsclient') { ... }
&nbsp_place_holder;
sub xmmsc_result_unref(xmmsc_result_t)
    is native('libxmmsclient') { ... }
&nbsp_place_holder;
sub xmmsc_result_wait(xmmsc_result_t)
    is native('libxmmsclient') { ... }
&nbsp_place_holder;
sub xmmsc_unref(xmmsc_connection_t)
    is native('libxmmsclient') { ... }
&nbsp_place_holder;
sub xmmsv_get_error(xmmsv_t, Str $error is rw)
    returns Int
    is native('libxmmsclient') { ... }
&nbsp_place_holder;
sub xmmsv_is_error(xmmsv_t)
    returns Int
    is native('libxmmsclient') { ... }

为了避免写 C 代码，我们再做一个漂亮的封装对象：

class XMMS2::Client {
    has xmmsc_connection_t $!connection;
&nbsp_place_holder;
    method new($client_name = 'perl6', $path = %*ENV) {
        self.bless(*, :$client_name, :$path);
    }
&nbsp_place_holder;
    method play returns Bool {
        my $result = xmmsc_playback_start($!connection);
        xmmsc_result_wait($result);
        return True if self.check-result($result);
&nbsp_place_holder;
        warn "Playback start failed!";
        return False;
    }
&nbsp_place_holder;
    method !check-result(xmmsc_result_t $result) returns Bool {
        my $return_value = xmmsc_result_get_value($result);
        my Bool $failed = xmmsv_is_error($return_value);
&nbsp_place_holder;
        if $failed {
            xmmsv_get_error($return_value, my $error-str)
                and warn $error-str;
        }
&nbsp_place_holder;
        xmmsc_result_unref($result);
&nbsp_place_holder;
        return not $failed;
    }
&nbsp_place_holder;
    submethod BUILD($client_name, $path) {
        $!connection = xmmsc_init($client_name);
        xmmsc_connect($!connection, $path)
            or die "Connection failed with error: {xmmsc_get_last_error($!connection)}";
    }
&nbsp_place_holder;
    submethod DESTROY {
        xmmsc_unref($!connection);
    }
};

现在让魔法生效：
XMMS2::Client.new.play;

成功连接了！然后程序返回了一个空 PMC 的错误。看起来 NativeCall 在传递空指针方面还得继续改进，毕竟是一个发展中的项目嘛。

当然NativeCall已经是一个足以正式使用的模块了，比如你可以试试提供 MySQL 驱动的 MiniDBI 模块 。

（更新：前面的代码里我漏掉了 xmmsc_result_wait() ，虽然加上这个还是返回空 PMC 错误==!）

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2010/%E7%AC%AC%E5%8D%81%E4%BA%94%E5%A4%A9:%E8%B0%83%E7%94%A8%E6%9C%AC%E5%9C%B0%E5%BA%93.markdown >  