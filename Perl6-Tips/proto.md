title:  proto

date: 2015-12-17

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'> 我们之间都没有错, 只是走到了分叉路口。</blockquote>

## proto

proto 意思为原型。proto 从形式上声明了 `multi` 候选者之间的`共性`。 proto 充当作能检查但不会修改参数的包裹。看看这个基本的例子:



``` perl
proto congratulate(Str $reason, Str $name, |) {*}
multi congratulate($reason, $name) {
   say "Hooray for your $reason, $name";
}
multi congratulate($reason, $name, Int $rank) {
   say "Hooray for your $reason, $name -- you got rank $rank!";
}

congratulate('being a cool number', 'Fred');     # OK
congratulate('being a cool number', 'Fred', 42); # OK
congratulate('being a cool number', 42);         # Proto match error
```

所有的 `multi congratulate` 会遵守基本的签名, 这个签名中有两个字符串参数, 后面跟着可选的更多的参数。 `|` 是一个未命名的 `Capture` 形参, 这允许 `multi` 接收额外的参数。第三个 congratulate 调用在编译时失败, 因为第一行的 proto 的签名变成了所有三个 multi congratulate 的共同签名, 而 42 不匹配 `Str`。

``` perl
say &congratulate.signature #-> (Str $reason, Str $name, | is raw)
```

你可以给 `proto` 一个函数体, 并且在你想执行 dispatch 的地方放上一个 `{*}`。

``` perl
# attempts to notify someone -- returns False if unsuccessful
proto notify(Str $user,Str $msg) {
   my \hour = DateTime.now.hour;
   if hour > 8 or hour < 22 {
      return {*};
   } else {
      # we can't notify someone when they might be sleeping
      return False;
   }
}
```

`{*}` 总是分派给带有参数的候选者。默认参数和类型强制转换会起作用单不会传递。

``` perl
proto mistake-proto(Str() $str, Int $number = 42) {*}
multi mistake-proto($str,$number) { say $str.WHAT }
mistake-proto(7,42);   #-> (Int) -- coercions not passed on
mistake-proto('test'); #!> fails -- defaults not passed on
```

