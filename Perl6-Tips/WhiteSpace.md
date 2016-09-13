
## 空格最少化

在数组或散列的开括号(即下标左边的那个括号)之前不允许有空格, 参数列表的圆开括号前面也是不能有空格的. 即:

```perl
@deadbeef[$x]         # okay
%monsters{'cookie'}   # okay
saymewant('cookie')   # okay

@a       [$b]         # WRONG
%people  {'john'}     # WRONG
mewant   ('cookie')   # WRONG
```


这种限制的的几个副作用之一就是条件控制结构的周围不再需要圆括号了:

```perl
if $value eq $target {
        print "Bullseye!";
    }
while $i < 10 { $i++ }
```

然而, 显式的使用 `unspace` 语法仍然能够让你对齐下标和后缀操作符:

```perl
%squirrels{'fluffy'} = Squirrel.new;
%monsters.{'cookie'} = Monster.new;
%beatles\.{'ringo'}  = Beatle.new;
%people\ .{'john'}   = Person.new;
```

