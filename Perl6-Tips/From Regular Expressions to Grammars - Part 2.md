
省略啰嗦的一堆。

使用量词匹配前面的东西至少 min 次, 至多 max 次, **item** `**`  **min .. max**

``` perl6
my regex Date { \d ** 4 '-' \d ** 2 '-' \d ** 2 }
```

还能精确地匹配 N 次。

 /literal string here/ 匹配一个字母数字序列。任何不是字母数字(顺便说一下, 这里的字母数字不一定严格地限制为 USe ASCII, 任何带有 'Letter' 或 'Number'  Unicode 属性的字符都符合要求)的东西都需要用引号引起来或者以某种形式转义。

如果你想让某个东西是可选的, 使用 `?`：

``` perl6
"Skyfall" ~~ /Sky 'fall'?/;
```

这会匹配 'Sky' 或 'Skyfall'。

Perl 6 的正则表达式, 就像大多数  RE 引擎一样, 当它们找到了一个匹配后会停止匹配。从左到右, 以 'Skyfalling' 为例：

``` perl6
"Skyfalling" ~~ /Sky 'fall'?/ # Try 'Sky', succeed
"Skyfalling" ~~ /Sky 'fall'?/ # Try 'fall', succeed, report success
```
