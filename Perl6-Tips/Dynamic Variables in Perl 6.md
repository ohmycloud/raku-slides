title:  Dynamic Variables in Perl 6

date: 2016-01-23

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>如果时间, 忘记了转, 忘了带走什么。</blockquote>

Perl 6 中的[动态变量](http://qiita.com/B73W56H84/items/18053bf37de8bb2bb808#err)

## $*ARGFILES

> $*ARGFILES Magic command-line input handle.

**`argfiles.pl6`**

``` perl
use v6;

$*ARGFILES.perl.say; #=> IO::Handle.new(:path(Any),:chomp)

# 按行读取
for $*ARGFILES.lines -> $line {
    say "$line";
}

# 一次性读取
# say $*ARGFILES.slurp;
```

**`USAGE`**

``` perl
$ perl6 argfiles.pl6 file1 file2 file3 ...
```

- [class IO::Handle - Perl 6 Documentation](http://doc.perl6.org/type/IO::Handle)
- [Input/Output - Perl 6 Documentation](http://doc.perl6.org/language/io)
- [Perl6文件操作 - Qiita](http://qiita.com/syohex/items/0a7782920968ab105ba0)

## @*ARGS

> @*ARGS - Arguments from the command line. 命令行中的参数。

**`agrs.pl6`**

``` perl
use v6;

say @*ARGS.WAHT;    #=> (Array)
say @*ARGS;         #=> [a b c d e]

say @*ARGS.perl;    #=> ["a", "b", "c", "d", "e"]
```

**`USAGE`**

``` perl
$ perl6 args.pl6 a b c d e
```

- [class Array - Perl 6 Documentation](http://doc.perl6.org/type/Array)

## $*IN

> $*IN - 标准输入文件句柄, 等同于 stdin

**`in.pl6`**

``` perl
use v6;

say $*IN.perl;   #=> IO::Handle.new(:path(IO::Special.new(what => "<STDIN>")),:chomp)
say $*IN.path;   #=> IO::Special.new(what => "<STDIN>")
say $*IN.chomp;  #=> True

for $*IN.lines -> $line {
 say "$line";
}
```

**`USAGE`**

``` perl
$ perl6 in.pl6
人力
...

$ cat somefile.txt | perl6 in.pl6
```

## $*OUT

> $*OUT - 标准输出文件句柄, 等同于 stdout

**`out.pl6`**

``` perl
use v6;

say $*OUT.perl;   #=> IO::Handle.new(:path(IO::Special.new(what => "<STDOUT>")),:chomp)
say $*OUT.path;   #=> IO::Special.new(what => "<STDOUT>")
say $*OUT.chomp;  #=> True

$*OUT.say( q:to/新年快乐/ );
    祝你新年快乐
    2016.01.23
    让我再说一次
新年快乐

# 通常我们会在打印时省略 $*OUT
# say "哈利路亚";
```

最后一段代码中 `//` 中间的字符是分割符。这打印出:

``` txt
祝你新年快乐
2016.01.23
让我再说一次
```

**`USAGE`**

``` perl
$ perl6 out.pl6
$ perl6 out.pl6 > result.txt
```

- [role IO - Perl 6 Documentation](http://doc.perl6.org/type/IO)

## $*ERR

> $*ERR - 标准错误文件句柄, 等同于 stderr

**`err.pl6`**

``` perl
use v6;

say $*ERR.perl;   #=> IO::Handle.new(:path(IO::Special.new(what => "<STDERR>")),:chomp)
say $*ERR.path;   #=> IO::Special.new(what => "<STDERR>")
say $*ERR.chomp;  #=> True

$*ERR.say("我错了");

# 平时可以使用 note
# note "前方高能预警";
```

**`USAGE`**

``` shell
$ perl6 err.pl6 > /dev/null
我错了
```

## $*REPO

> $*REPO A variable holding information about modules installed/loaded

**`repo.pl6`**

``` 
use v6;

say $*REPO;
say $*REPO.perl;
say $*REPO.id;
say $*REPO.path-spec;
say $*REPO.loaded;
say $*REPO.repo-chain;

```

## $*TZ

> $*TZ The system's local timezone.

**`tz.pl6`**

``` 
use v6;

say $*TZ;      #=> 32400
say $*TZ.perl; #=> 32400

say $*TZ.WHAT; #=> (Int)

```

## $*CWD

> $*CWD The Current Working Directory.

**`cwd.pl6`**

``` 
use v6;

say $*CWD;       #=> "/Users/kujira".IO
say $*CWD.path;  #=> /Users/kujira
say $*CWD.perl;  #=> "/Users/kujira".IO(:SPEC(IO::Spec::Unix),:CWD("/Users/kujira"))

```

## $*KERNEL

> $*KERNEL Which kernel am I compiled for?

**`kernel.pl6`**

``` 
use v6;

say $*KERNEL;            #=> darwin (15.2.0)
say $*KERNEL.release;    #=> Darwin Kernel Version 15.2.0: Fri Nov 13 19:56:56 PST 2015; root:xnu-3248.20.55~2/RELEASE_X86_64
say $*KERNEL.name;       #=> darwin
say $*KERNEL.auth;       #=> unknown
say $*KERNEL.version;    #=> v15.2.0
say $*KERNEL.signature;  #=> (Blob)
say $*KERNEL.desc;       #=> (Str)

say $*KERNEL.perl;        #=> Kernel.new(release => Str, name => "darwin", auth => "unknown", version => Version.new('15.2.0'), signature => Blob, desc => Str)
say $*KERNEL.WHAT;        #=> (Kernel)

```

## $*DISTRO

> $*DISTRO Which OS distribution am I compiling under?

**`distro.pl6`**

``` 
use v6;

say $*DISTRO;           #=> macosx (10.11.2)

say $*DISTRO.name;      #=> macosx
say $*DISTRO.is-win;    #=> False
say $*DISTRO.version;   #=> v10.11.2

say $*DISTRO.path-sep;  #=> :
say $*DISTRO.auth;      #=> Apple Computer, Inc.
say $*DISTRO.desc;      #=> 2016-01-17T01:48:03.261407+09:00
say $*DISTRO.release;   #=> 15C50
say $*DISTRO.signature; #=> (Blob)

say $*DISTRO.gist;      #=> macosx (10.11.2)
say $*DISTRO.Str;       #=> macosx
say $*DISTRO.perl;      #=> Distro.new(release => "15C50", is-win => Bool::False, path-sep => ":", name => "macosx", auth => "Apple Computer, Inc.", version => Version.new('10.11.2'), signature => Blob, desc => "2016-01-17T01:48:47.273804+09:00")

```

- [Perl6 で windows かどうか判定したい - tokuhirom's blog](http://blog.64p.org/entry/2015/09/05/225701)
- [DISTRO.t](https://github.com/perl6/roast/blob/master/S02-magicals/DISTRO.t)

## $*VM

> $*VM Which virtual machine am I compiling under?

**`vm.pl6`**

``` 
use v6;

say $*VM;         #=> moar (2015.12)

say $*VM.config;
say $*VM.perl;

```

## $*PERL

> $*PERL Which Perl am I compiled for?

**`perl.pl6`**

``` 
use v6;

say $*PERL;          #=> Perl 6 (6.c)
say $*PERL.compiler; #=> rakudo (2015.12)

say $*PERL.perl;     #=> Perl.new(compiler => Compiler.new(id => "AEB5E66886F036F5AF7448E587F49EB233F6F7F5.1451295526.86961", release => "", codename => "", name => "rakudo", auth => "The Perl Foundation", version => Version.new('2015.12'), signature => Blob, desc => Str), name => "Perl 6", auth => "The Perl Foundation", version => Version.new('6.c'), signature => Blob, desc => Str)

```

## $*PID

> $*PID Process ID of the current process.

**`pid.pl6`**

``` 
use v6;

say $*PID;      #=> 35480
say $*PID.perl; #=> 35480
say $*PID.WHAT; #=> (Int)

```

## $*PROGRAM-NAME

> $*PROGRAM-NAME Path to the current executable as it was entered on the command line, or C<-e> if perl was invoked with the -e flag.

**`program-name.pl6`**

``` 
use v6;

say $*PROGRAM-NAME;
say $*PROGRAM-NAME.perl;
say $*PROGRAM-NAME.IO.basename;

```

## $*PROGRAM

> $*PROGRAM Location (in the form of an C[IO::Path](undefined) object) of the Perl program being executed.

**`program.pl6`**

``` 
use v6;

say $*PROGRAM;        #=> "/Users/kujira/program.pl6".IO
say $*PROGRAM.Str;    #=> program.pl6

say $*PROGRAM.perl;   #=> "program.pl6".IO(:SPEC(IO::Spec::Unix),:CWD("/Users/kujira"))

say $*PROGRAM.SPEC;   #=> (Unix)
say $*PROGRAM.CWD;    #=> /Users/kujira

say $*PROGRAM.WHAT;   #=> (Path)

```

## $*EXECUTABLE

> $*EXECUTABLE Absolute path of the perl executable that is currently running.

**`executable.pl6`**

``` 
use v6;

say $*EXECUTABLE;           #=> "/usr/local/bin/perl6".IO
say $*EXECUTABLE.Str;       #=> /usr/local/bin/perl6
say $*EXECUTABLE.basename;  #=> perl6

say $*EXECUTABLE.WHAT;      #=> (Path)

say $*EXECUTABLE.perl;      #=> "/usr/local/bin/perl6".IO(:SPEC(IO::Spec::Unix))
say $*EXECUTABLE.SPEC;      #=> (Unix)

```

## $*EXECUTABLE-NAME

> $*EXECUTABLE-NAME The name of the perl executable that is currently running. (e.g. perl6-p, perl6-m, Niecza.exe) Favor $*EXECUTABLE because it is not guaranteed that the perl executable is in PATH.

**`executable-name.pl6`**

``` 
use v6;

say $*EXECUTABLE-NAME;       #=> perl6
say $*EXECUTABLE-NAME.WHAT;  #=> (Str)

```

## $*USER

> $*USER The user that is running the program. It is an object that evaluates to "username (uid)". It will evaluate to the username only if treated as a string and the numeric user id if treated as a number.

**`user.pl6`**

``` 
use v6;

say $*USER;      #=> kujira (801)

say +$*USER;     #=> 801
say ~$*USER;     #=> kujira

say $*USER.perl; #=> IdName.new

```

## $*GROUP

> $*GROUP The primary group of the user who is running the program. It is an object that evaluates to "groupname (gid)". It will evaluate to the groupname only if treated as a string and the numeric group id if treated as a number.

**`group.pl6`**

``` 
use v6;

say $*GROUP;       #=> whale (0)

say ~$*GROUP;      #=> whale
say +$*GROUP;      #=> 0

say $*GROUP.perl;  #=> IdName.new

```

## $*HOME

> $*HOME An L[IO::Path](undefined) object representing the "home directory" of the user that is running the program. If the "home directory" cannot be determined it will be L

**`home.pl6`**

``` 
use v6;

say $*HOME;       #=> "/Users/kujira".IO

say $*HOME.CWD;   #=> /Users/kujira
say $*HOME.SPEC;  #=> (Unix)
say $*HOME.WHAT;  #=> (Path)

say $*HOME.perl;  #=> "/Users/kujira".IO(:SPEC(IO::Spec::Unix),:CWD("/Users/kujira"))

```

- [class IO::Path - Perl 6 Documentation](http://doc.perl6.org/type/IO::Path)

## $*SPEC

> $*SPEC The appropriate L[IO::Spec](undefined) sub-class for the platform that the program is running on.

**`spec.pl6`**

``` 
use v6;

say $*SPEC;          #=> (Unix)
say $*SPEC.perl;     #=> IO::Spec::Unix
say $*SPEC.path;     #=> (/usr/local/Cellar/rakudo-star/2015.12/share/perl6/site/bin /usr/local/sbin /usr/local/bin /usr/bin /bin /usr/sbin /sbin)
say $*SPEC.tmpdir;   #=> "/var/folders/9v/wr31l2zj78x1nw58jgljq_9w0000gn/T".IO
say $*SPEC.dir-sep;  #=> /
say $*SPEC.curdir;   #=> .
say $*SPEC.updir;    #=> ..
say $*SPEC.curupdir; #=> none(., ..)
say $*SPEC.rootdir;  #=> /
say $*SPEC.devnull;  #=> /dev/null

```

- [class IO::Spec - Perl 6 Documentation](http://doc.perl6.org/type/IO::Spec)
- [class IO::Spec::QNX - Perl 6 Documentation](http://doc.perl6.org/type/IO::Spec::QNX)
- [class IO::Spec::Unix - Perl 6 Documentation](http://doc.perl6.org/type/IO::Spec::Unix)
- [class IO::Spec::Win32 - Perl 6 Documentation](http://doc.perl6.org/type/IO::Spec::Win32)
- [class IO::Spec::Cygwin - Perl 6 Documentation](http://doc.perl6.org/type/IO::Spec::Cygwin)

## [](http://qiita.com/B73W56H84/items/18053bf37de8bb2bb808#%E5%8F%82%E8%80%83%E3%81%A8%E6%B3%A8%E9%87%88)

