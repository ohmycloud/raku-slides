
有一段结构化的文本, 写一个 Grammar 来解析它：

``` txt
name = Animal Facts
author = jnthn

[cat]
desc = The smartest and cutest
cuteness = 100000

[dugong]
desc = The cow of the sea
cuteness = -10

[magpie]
desc = crow; raven; rook; jackdaw; chough; magpie; jay
cuteness = 99
```

每一段都是一个章节, 有的章节没有`[cat]`这样的标题, 要求grammar生成一个散列, 散列的键是方括号中的单词, 如果没有就默认为 `_` , 散列的值是一个散列的数组, 数组里面的每个散列的键为等号左边的单词, 键值为等号右边的字符。Grammar 如下:



``` perl6
use v6;
#use Grammar::Debugger;
grammar INIFile::Grammar {
    token TOP {
        ^
        <entries>     # 条目
        <section>+    # 章节
        $
    }

    token section {
        '[' ~ ']' <key> \n
        <entries> # 每个章节含有多个条目 entry
    }

    token entries {
        [
        | <entry> \n
        | \n # entry 可以为空
        ]+
    }

    token entry   { <key> \h* '=' \h* <value> }
    token key     { \w+                       }
    token value   { \N+                       }
}

class INIFileActions {
    method entries($/) {
        my %entries;
        for $<entry> -> $e {
            %entries{$e<key>} := ~$e<value>;
        }
        make %entries;
    }

    method TOP($/) {
        my %result;
        %result<_> := $<entries>.ast;
        for $<section> -> $sec {
            %result{$sec<key>} := $sec<entries>.ast;
        }
        make %result;
    }
}

my $m := INIFile::Grammar.parse(Q{
name = Animal Facts
author = jnthn

[cat]
desc = The smartest and cutest
cuteness = 100000

[dugong]
desc = The cow of the sea
cuteness = -10

[magpie]
desc = crow; raven; rook; jackdaw; chough; magpie; jay
cuteness = 99
}, :actions(INIFileActions));

my %sections := $m.ast;

for %sections -> $sec {
    say("章节: {$sec.key}");
    for $sec.value -> $entry {
        say("    {$entry.key}: {$entry.value}");
    }
}

```

`make` 是一个函数, 接收单个参数, `make` 的作用是, 对于每一个 `method` 中对应的 `$_` , 存储生成的抽象语法树(AST)(片段)到 `$/` 中。 `.ast` 用于从已保存的 AST 抽象语法树中检索提取 AST (片段), `»` 相当于一个循环, 即检索每一个 `$<entry>` 之类的语法树。

``` perl6
use v6;

grammar INIFile::Grammar {
    token TOP {
        ^
        <section>+    # 章节
        $
    }

    token section {
        [ '[' ~ ']' <key> \n ]?   # [key] 这一行是可选的
        <entries>                 # 每个章节含有多个条目 entry
    }

    token entries {
        [
        | <entry> \n
        | \n # entry 可以为空
        ]+
    }

    token entry   { <key> \h* '=' \h* <value> }
    token key     { \w+                       }
    token value   { \N+                       }
}

class INIFileActions {
    method key    ($/)  { $/.make: ~$/                                 }
    method value  ($/)  { $/.make: ~$/                                 }
    method entry  ($/)  { $/.make: $<key>.ast => $<value>.ast          }
    method entries($/)  { $/.make: $<entry>».ast                       }
    method section($/)  { $/.make: $<key>.ast // '_' => $<entries>.ast } # 如果 key 不存在就默认为 `_`

    method TOP($/) {
        $/.make: $<section>».ast;  # 等价于 $/.make($<section>».ast);
        # '-' => $<entries>.ast    # '_' 没有 ast 方法 
    }
}

my $m = INIFile::Grammar.parse(Q{
name = Animal Facts
author = jnthn

[cat]
desc = The smartest and cutest
cuteness = 100000

[dugong]
desc = The cow of the sea
cuteness = -10

[magpie]
desc = crow; raven; rook; jackdaw; chough; magpie; jay
cuteness = 99
}, :actions(INIFileActions)).ast;

for @$m -> $sec {
    say("章节: {$sec.key}");

    for $sec.value -> $entry {
        say("    {$entry.key}: {$entry.value}");
    }
}
```

Grammar 的解析是从上至下的, 从 top-level (`TOP`) 开始, 到分支(branch)。 Actions 中的方法是随着解析而执行的, 但是抽象语法树(AST) 的存储和检索是自下而上的, 只有底部的存储完了, 其上层部分才可以使用`.ast` 或 `.made` 方法进行检索, 检索到之后各自进行处理后再次存储, 以供它的上层部分使用, 以此类推。



注意, 第一段代码中 `$m` 存储的死散列, 而第二段代码中, `$m` 存储的是数组! 这说明可以返回散列和数组两种形式。留待改天。

