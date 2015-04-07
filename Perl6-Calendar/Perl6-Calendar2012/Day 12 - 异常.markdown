

有时候事情会变得很糟糕，你唯一可以做的事情就是暂停运行。这时候就需要抛出一个异常。

当然故事不会这么快结束。调用者（或者调用者的调用者）必须通过一定手段来处理这个异常，为了做的更好，调用者自然就需要获取尽可能详细的信息。

在 Perl6 中，异常是从 Exception 类型中继承来的，按照惯例，他们会归属在 X:: 名字空间。

所以假如你写一个 HTTP 客户端库，然后你觉得当服务器返回 4 或者 5 开头的状态码的时候，你需要抛出一个异常，那你可以这么声明你的异常类：

class X::HTTP is Exception {
    has $.request-method;
    has $.url;
    has $.status;
    has $.error-string;
    method message() {
        "Error during $.request-method request"
        ~ " to $.url: $.status
        $.error-string";
    }
}

抛出异常的方法如下：

die X::HTTP.new(
    request-method => 'GET',
    url            => 'http://example.com/no-such-file',
    status         => 404,
    error-string   => 'Not found',
);

错误信息看起来如下：

Error during GET request to
http://example.com/no-such-file: 404 Not found

(照顾一下小窗口浏览器，我分了下行)

如果异常不被抓取，程序就此中断然后打印错误信息，就像回溯一样。

有两个办法来抓取异常。简单的神奇宝贝式风格就是“来把他们全抓住”，用 try 方法可以抓取所有类型的异常：

my $result = try do-operation-that-might-die();
if ($!) {
    note "There was an error: $!";
    note "But I'm going to go on anyway";
}

或者你可以选择性的只抓取部分异常类型并处理他们，其他的抛回给调用者：

my $result =  do-operation-that-might-die();
CATCH {
    when X::HTTP {
        note "Got an HTTP error for URL $_.url()";
        # 开始处理
    }
    # 非 X::HTTP 类型的异常则被抛回
    rethrown
}

注意 CATCH 块是和错误可能发生的地方处于同一个作用域下。所以默认情况下你可以访问该作用域下的各种变量，这样你可以生成更好的错误信息。

在 CATCH 块里，异常被赋值给 $_ ，然后逐一匹配所有的 when 块。

即便你不需要选择性的抓取异常，声明特定类依然是有意义的。因为这样很方便写检查错误报告的测试。你可以检查异常的类型和负载，而不用排序过滤来筛选海量错误信息（这办法太脆弱了）。

不过 Perl6 也是 Perl，它不会强制你一定要自己写单独的异常类型。只要你传递一个非 Exception 对象给 die() ，他就会自动包成一个 X::AdHoc 类型的对象（自然也是从 Exception 继承的），然后使用 payload 方法传递参数：

sub I-am-fatal() {
    die "Neat error message";
}
try I-am-fatal();
say $!;             # Neat error message;
say $!.perl;        # X::AdHoc.new(payload =>
                           "Neat error message")

To find out more about exception handling, you can read 想了解更多异常处理，可以阅读 异常类的文档 和 回溯类型 .

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2012/%E7%AC%AC%E5%8D%81%E4%BA%8C%E5%A4%A9:%E5%BC%82%E5%B8%B8.markdown >  