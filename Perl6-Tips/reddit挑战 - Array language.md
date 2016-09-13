
[[2015-12-09\] Challenge #244 [Easy]er - Array language (part 3) - J Forks](https://www.reddit.com/r/dailyprogrammer/comments/3wdm0w/20151209_challenge_244_easyer_array_language_part/)

### Forks

**fork* 是一个接收三个函数作为参数的函数

给三个函数 `f(y, x = defalut):`, `g(y, x = default):`, `h(y, x = default):`, 其中函数 **g** 是含有两个参数的真实的函数。

然后调用 `Fork(f, g, h)`执行函数合成:

``` perl6
g(f(y, x), h(y, x)) (data1, data2)
```

#### 1. 从字符串输入执行函数调用来产生字符串

``` perl6
sum divide count
```

(上面的输入是 Fork 函数的三个函数名)

#### 2. 根据你喜欢的原生语言, 从上面的字符串输入中创建一个执行函数

#### 3. 或创建一个接收三个函数作为输入的函数并返回一个函数

``` perl6
Fork(sum, divide, count) (array data)
```

应该返回数组的平均数。

#### 4. 扩展上面的函数使函数参数接收基数

对于 5 个参数, Fork(a, b, c, d, e) 是:

``` perl6
b(a, Fork(c,d,e))   NB. should expand this if producing strings. 
```

smls 给出的答案:

``` perl6
use v6;

sub sum    ($y, $x = 0) { $y.sum + $x   }
sub count  ($y, $x = 0) { $y.elems + $x }
sub divide ($y, $x = 1) { $y / $x       }

multi Fork (&f, &g, &h) {
    sub (|args) { g f(|args), h(|args) }
}

multi Fork (&f, &g, *@rest where * !%% 2) {
    sub (|args) { g f(|args), Fork(|@rest)(|args) }
}

say Fork(&sum, &divide, &count)([1, 2, 3, 4, 5]); # 3
say Fork(&sum, &divide, &sum, &divide, &count)([1, 2, 3, 4, 5]); # 5


```

