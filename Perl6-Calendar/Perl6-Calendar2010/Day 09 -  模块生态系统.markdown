2010 年 Perl6 圣诞月历(九)模块生态圈

目前 Perl6 模块都存在 http://modules.perl6.org 上，而不是 CPAN。不过数量也足够一用，或者说至少要知道一下。目前也没有标准的像 cpan 那样的 perl6 模块安装工具，最常用的工具是 neutro 。用它可以很简单的从 模块的生态圈 上获取、安装模块，包括依赖性解决、测试等功能也都有了，基本没什么欠缺的。让我们看看怎么用他来安装一个 json 解析器模块 JSON::Tiny 吧。

首先，我们需要获取 neutro 工具。我们建议你使用 git 获取他。嗯，事实上所有的 perl6 模块目前也都在 git 上。

    git clone git://github.com/tadzik/neutro.git
    cd neutro
    PERL6LIB=tmplib bin/neutro .

这样就可以下载和引导安装 neutro 了。最终安装的是 neutro 自己、File::Tools 和 Module::Tools 两个模块。请务必保证 ~/perl6/bin 存在在你的 PATH 环境变量里。这样运行 neutro 的时候就不用指定全路径了。现在，你可以像使用 cpanm 一样用 neutro 了：

    neutro json
    neutro perl6-Term-ANSIColor
    neutro perl6-lwp-simple

你可能注意到格式不是像 perl5 那样子。因为这个名字其实就是 git 上的项目名字。想确定某个模块是否可以安装的话，通过更新列表来查询：

    neutro update #获取最新模块列表
    neutro list

模块会被自动安装到 ~/perl6/lib 目录下，这也是 Rakudo 的默认搜索路径。所以你就不用再自己预定义 PERL6LIB 了：
    perl6 -e 'use Term::ANSIColor; say colored("Hello blue world!", "blue")'

好了，你是不是已经迫不及待要开始写自己的第一个模块并分享给全世界的perlers了？现在还没有 cpan 给你放模块，所以暂行的办法是在 github.com 上创建项目，然后把他加入到 ecosystem 的 projects.list 里来（译者注：链接失效，似乎已经改成 META.list 了）。做这件事情很简单，不需要你有什么权限， PULL 一个 patch 到你 fork 出来的 ecosystem 项目，或者在 Freenode 的 Perl6 频道里喊一嗓子就好啦！

至于如何写 perl6 的模块？可以使用哪些工具？感兴趣的话可以看看这篇 指南 。

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2010/%E7%AC%AC%E4%B9%9D%E5%A4%A9:%E6%A8%A1%E5%9D%97%E7%94%9F%E6%80%81%E5%9C%88.markdown >  