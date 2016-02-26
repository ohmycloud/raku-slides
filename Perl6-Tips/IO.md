title:  IO::Path

date: 2015-08-20T23:19:13Z

tags: Perl6

categories: Perl 6

------

<blockquote class="blockquote-center">谁说不能让我此生唯一自传 如同诗一般  — 五月天</blockquote>

### 批量插入文本

``` perl
use v6;

my @filenames = dir '.',  test => any(/\.md$/, /\.markdown/);

for @filenames -> $filePath {
    my $path = $filePath.path();
    $path ~~ s/.md//;
    $path ~~ s/.markdown//;

    my $date = DateTime.new(now);
    my $head = 
qq:heredoc 'EOT';
title:  $path.IO.basename()
date: $date
tags: Perl6
categories: Perl 6

---

<blockquote class="blockquote-center">我讨厌戴眼镜！</blockquote>

[TOC]

EOT

   my @content   = slurp $filePath;
   spurt($filePath.path, "$head\n@content[]");
}

```

在当前目录中查找所有以 `.md` (.markdown)结尾的文件（即markdown文件）, 并在文件最前面插入一段文本， 形如：

``` perl
title:  Perl6
date: 2015-08-20T23:19:13Z
tags: Perl6
categories: Perl 6

---

<blockquote class="blockquote-center">我讨厌戴眼镜！</blockquote>

```

类 `IO::Path` 提供了 `basename`, `path`, `parts`, 等方法供使用, 具体用法请看文档:

``` perl
p6doc IO::Path
```

一些例子：

``` perl
say IO::Path.new("/etc/passwd").basename;   # passwd
say IO::Path.new("docs/README.pod").extension;   # pod
say IO::Path.new("/etc/passwd").dirname;    # /etc
say IO::Path::Win32.new("C:\\Windows\\registry.ini").volume;    # C:
say IO::Path.new("/etc/passwd").parts.perl # ("dirname" => "/etc", "volume"  => "", "basename" => "passwd").hash
```

Examples:

``` perl


    # To iterate over the contents of the current directory: for dir() -> $file
    {
        say $file;
    }

    # As before, but include even '.' and '..' which are filtered out by # the
    default :test matcher: for dir(test => *) -> $file {
        say $file;
    }

    # To get the names of all .jpg and .jpeg files in ~/Downloads: my @jpegs =
    "%*ENV<HOME>/Downloads".IO.dir(test => /:i '.' jpe?g $/)».Str;


# An example program that lists all files and directories recursively:

    sub MAIN($dir = '.') {
        my @todo = $dir.IO; while @todo {
            for @todo.pop.dir -> $path {
                say $path.Str; @todo.push: $path if $path.d;
            }
        }
    }
```

### 文件测试操作符

``` perl
# If you have a string - a path to something in the filesystem:

    if "path/to/file".IO ~~ :e {
        say 'file exists';
    }

    my $file = "path/to/file"; if $file.IO ~~ :e {
        say 'file exists';
    }

# Instead of the colonpair syntax, you can use method calls too:

    if 'path/to/file'.IO.e {
        say 'file exists';
    }

# If you already have an IO object in $file, either by creating one yourself, or
# by getting it from another subroutine, such as dir, you can write this:

    my $file = "path/to/file".IO; if $file ~~ :e {
        say 'file exists';
    }
```

### 文件时间戳：

``` perl
say "path/to/file".IO.modified;                # e.g. Instant:1424089165
say DateTime.new("path/to/file".IO.modified);  # e.g. 2015-02-16T12:18:50Z

my $modification_instant = "path/to/file".IO.modified; 
my $modification_time    = DateTime.new($modification_instant); 
say $modification_time;  # e.g. 2015-02-16T12:18:50Z


say "path/to/file".IO.accessed;                # e.g. Instant:1424353577
say DateTime.new("path/to/file".IO.accessed);  # e.g. 2015-02-19T13:45:42Z

my $access_instant = "path/to/file".IO.accessed; 
my $access_time    =  DateTime.new($access_instant); 
say $access_time;  # e.g. 2015-02-19T13:45:42Z


say "path/to/file".IO.changed;                # e.g. Instant:1424089165
say DateTime.new("path/to/file".IO.changed);  # e.g. 2015-02-16T12:18:50Z

my $change_instant = "path/to/file".IO.changed; 
my $change_time    =  DateTime.new($chnge_instant); 
say $change_time;  # e.g. 2015-02-16T12:18:50Z
```