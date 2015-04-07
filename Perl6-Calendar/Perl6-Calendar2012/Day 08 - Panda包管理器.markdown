

Perl6 不单单是个语言。没有模块的时候它可以比 Perl5 做的更多，但模块可以让生活更容易。大概两年前，在 博客上有个关于 neutro 的讨论 。不过我不会讨论这个了，因为这个已经被废弃了。

现在，安装模块的标准办法是用 panda 工具。如果你用的是 Rakudo Star ，里面已经包含进去了（试试在终端里输入 panda 命令）。运行后等一下，就可以看到 panda 工具的帮助了。

$ panda
Usage:
  panda [--notests] [--nodeps] install [<modules> ...] -- Install the specified modules
  panda [--installed] [--verbose] list -- List all available modules
  panda update -- Update the module database
  panda info [<modules> ...] -- Display information about specified modules
  panda search <pattern> -- Search the name/description

正如你看到的，没有太多的选项（和 RubyGems 或者 cpanminus 一样简单）。你可以在 Perl6 模块页面上看到当前模块的列表。假设你想解析一个 INI 文件。首先你可以用搜索命令查找模块。

$ panda search INI
JSON::Tiny               *          A minimal JSON (de)serializer
Config::INI              *          .ini file parser and writer module for
                                    Perl 6
MiniDBI                  *          a subset of Perl 5 DBI ported to Perl 6
                                    to use while experts build the Real Deal
Class::Utils             0.1.0      Small utilities to help with defining
                                    classes

Config::INI 就是你要的模块。出现其他模块是因为搜索词不够明确，所以在其他单词里出现了 "ini" （m**ini**mal, M**ini**DBI and def**ini**ng）。Config::INI 模块不是 Rakudo Star 里的，所以你需要自己安装它。

如果你对安装路径有写权限，Panda 就把模块安装到全局路径，否则就在本地路径下。所以哪怕全局的 Perl6 没有像 Perl5 里的 local::lib 这样的模块，你也可以用 panda。

$ panda install Config::INI
==> Fetching Config::INI
==> Building Config::INI
Compiling lib/Config/INI.pm
Compiling lib/Config/INI/Writer.pm
==> Testing Config::INI
t/00-load.t .... ok
t/01-parser.t .. ok
t/02-writer.t .. ok
All tests successful.
Files=3, Tests=55, 3 wallclock secs ( 0.04 usr 0.00 sys + 2.38 cusr 0.14 csys = 2.56 CPU)
Result: PASS
==> Installing Config::INI
==> Succesfully installed Config::INI

After the module has been installed, you can update it as easily – by 模块安装完成后，你再运行安装命令，就是升级。目前版本的 panda 还不能自动升级模块，不过如果一个模块更新了（你可以点击 GitHub 项目上的 watch 关注来收取邮件通知 -- 所有的模块都在 GitHub 上），你可以很容易的通过重安装的方式升级它。

模块安装好了以后，你可以尝试 use 模块来检查是否正常工作。下马是一个简单的脚本，用来转译 INI 文件成一个 Perl6 数据结构。

#!/usr/bin/env perl6
use Config::INI;
multi sub MAIN($file) {
    say '# your INI file as seen by Perl 6';
    say Config::INI::parse_file($file).perl;
}

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2012/%E7%AC%AC%E5%85%AB%E5%A4%A9:Panda%E5%8C%85%E7%AE%A1%E7%90%86%E5%99%A8.markdown >  