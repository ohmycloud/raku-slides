2010 年 Perl6 圣诞月历(三)文件操作

目录

不再用 opendir 和其他神马滴，Perl6 中有专门的 dir 函数，用来列出指定目录（默认是当前所在目录）下所有的文件。好了，直接贴代码：

#在 Rakudo 源码目录里
    > dir
    build parrot_install Makefile VERSION parrot docs Configure.pl
    README dynext t src tools CREDITS LICENSE Test.pm
    > dir 't'
    00-parrot 02-embed spec harness 01-sanity pmc spectest.data

dir 还有一个可选的命名参数 test，用来 grep 结果，这样：

   > dir 'src/core', test => any(/^C/, /^P/)
    Parcel.pm Cool.pm Parameter.pm Code.pm Complex.pm
    CallFrame.pm Positional.pm Capture.pm Pair.pm Cool-num.pm Callable.pm Cool-str.pm

创建目录，还是 mkdir 函数没错啦~

文件

最简单的读取文件的办法，是直接使用 slurp 函数，这个函数以标量形式返回文件的内容，这样：

> slurp 'VERSION'
    2010.11

当然原始的文件句柄方式还是有效的，这样：

   > my $fh = open 'CREDITS'
    IO()<0x1105a068>
    > $fh.getc #读取一个字符
    =
    > $fh.get #读取一行（译者注：这两看起来好有 C 语言的赶脚啊）
    pod
    > $fh.close; $fh = open 'new', :w #可写方式打开
    IO()<0x10f3e704>
    > $fh.print('foo')
    Bool::True
    > $fh.say('bar')
    Bool::True
    > $fh.close; say slurp('new')
    foobar

文件测试

如果要测试文件是否存在以及文件的具体类型，直接使用~~操作符就搞定了，还是用代码说话：

  > 'LICENSE'.IO ~~ :e #文件(广义的)是否存在
    Bool::True
    > 'LICENSE'.IO ~~ :d #那么他是目录么？
    Bool::False
    > 'LICENSE'.IO ~~ :f #那么是文件(狭义的)？
    Bool::True

容易吧~~

File::Find

如果这些个标准特性还不够，那模块就派上用场了。File::Tools 包里的 File::Find 模块可以递归你指定的目录找你要的东西然后列出来。这个模块应该是跟着 Rakudo Star 一起打包了，如果你只裸装了 Rakudo，那么用 neutro 命令安装也是挺方便的~~

额，还是要例子？好吧~很简单的一行 find(:dir, :type, :name(/foo/)) ，这就会在 t/dir1 目录下，寻找名字匹配 foo 的文件，然后以树的形式列出来~不过要注意的是：这命令的返回可不是文本标量，而是一个个包括他们的完整路径在内的对象，而且还提供文件本身以及文件所在目录的访问器！更多信息，直接看 文档 吧。

有用的示例

1、创建新文件
    open('new', :w).close

2、匿名文件句柄

    given open('foo', :w) {
        .say('Hello, world!');
        .close
    }

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2010/%E7%AC%AC%E4%B8%89%E5%A4%A9:%E6%96%87%E4%BB%B6%E6%93%8D%E4%BD%9C.markdown >  