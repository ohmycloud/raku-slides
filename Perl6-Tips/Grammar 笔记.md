
一个 Grammar 调了4个小时, 先分解下：

- 解析`[ ]` 里面的数据：

``` perl6
use v6;
use Grammar::Debugger;

grammar Lines {
    token TOP {
        ^ <line>+ $
    }

    token line {
        \[
        <student>+ % <semicolon>
        \]
        \n                   # 换行 \n 是最容易被忽略的地方, 坑了很多次了！
    }

    token student {
       <myname>+ % <comma>   # 分隔符也可以是一个 subrule
    }

    token myname {
        <[A..Za..z-]>+       # 字符类的写法 <[...]>
    }

    token comma {
        ',' \s+              # 逗号, 分号 不能裸露出现在 token 中
    }

    token semicolon {
        ';' \s+
    }

}

my $parse = Lines.parsefile('test.txt');
say $parse;
```

test.txt 的内容如下：

``` perl
[Lue, Fan]
[Lou, Man-Li]
[Tian, Mijie; Zhou, Lin; Zou, Xiao; Zheng, Qiaoji; Luo, Lingling; Jiang, Na; Lin, Dunmin]
```

下面的 Grammar 用于解析一个字符串, 由于 tokens 不能回溯, 所以当解析 `$str` 时使用了 Grammar 的继承, 重写了 university 这个 token:

```perl
use v6;
use Grammar::Debugger;

my $string = "[Wang, Zhiguo; Zhao, Zhiguo] Hangzhou Normal Univ, Ctr Cognit & Brain Disorders, Hangzhou, Zhejiang, Peoples R China; [Wang, Zhiguo; Theeuwes, Jan] Vrije Univ Amsterdam, Dept Cognit Psychol, Amsterdam, Netherlands";

grammar University::Grammar {
    token TOP             { ^ <university> $             }
    token university      { [ <bracket> <info> ]+ % '; ' }
    token bracket         { '[' <studentname>  '] '      }
    token studentname     { <stdname=.info>+ % '; '      }
    token info            { <field>+ % ', '              }
    token field           { <-[,\]\[;\n]>+               }
}

# grammar 像类一样可以继承, 里面的 token 可以被重写
grammar MyUniversity  is University::Grammar {
    token university      { <info>+ % '; ' }
}

my $str = "Zhejiang Univ, Coll Environm & Resources Sci, Dept Resource Sci, Hangzhou 310029, Peoples R China; La Trobe Univ, Dept Agr Sci, Bundoora, Vic 3083, Australia; Hangzhou Normal Coll, Fac Life Sci, Hangzhou, Peoples R China";

my $parsed = University::Grammar.parse($string);
# my $parsed = MyUniversity.parse($str);

for @($parsed<university><info>) -> $f {
    say $f<field>[0];
}

```


