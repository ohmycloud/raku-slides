comb - 操作字符串的利器

## comb 子例程

comb 子例程的定义为：

```perl6
multi sub    comb(Regex $matcher, Str(Cool) $input, $limit = *) returns List:D
multi method comb(Regex $matcher,                   $limit = *) returns List:D
```

用法：

```perl6
comb /PATTERN/, STRING, LIMIT?  # 子例程形式
STRING.comb(/PATTERN/, LIMIT?)  # 方法形式
```

返回调用者（方法形式）的所有（或者至多 $limit 个，如果提供了的话）匹配，或者返回第二个参数（sub 形式）与 Regex 相匹配的字符串列表。

```perl6
say "6 or 12".comb(/\d+/).join(", "); # 6, 12
```

## Str 类中的 comb

```perl6
multi sub    comb(Str:D   $matcher, Str:D $input, $limit = Inf)
multi sub    comb(Regex:D $matcher, Str:D $input, $limit = Inf, Bool :$match)
multi sub    comb(Int:D $size, Str:D $input, $limit = Inf)

multi method comb(Str:D $input:)
multi method comb(Str:D $input: Str:D   $matcher, $limit = Inf)
multi method comb(Str:D $input: Regex:D $matcher, $limit = Inf, Bool :$match)
multi method comb(Str:D $input: Int:D $size, $limit = Inf)
```

在 `$input` 中搜索 `$matcher` 并返回所有匹配（默认是 Str，或者是 Match 对象，如果 `$match` 为真的话）的一个列表。`$limit` 表示至多返回 `$limit` 个匹配。

如果没有提供 `$matcher`(匹配器)， 那么会返回字符串中的所有字符的列表。等价于使用了 `$matcher = rx/./`。

例子：

```perl6
comb(/\w/, "a;b;c").perl;        # ("a", "b", "c").list
comb(/\N/, "a;b;c").perl;        # ("a", ";", "b", ";", "c").list
comb(/\w/, "a;b;c", 2).perl;     # ("a", "b").list
comb(/\w\;\w/, "a;b;c", 2).perl; # ("a;b",).list

"123abc456def".comb(3)           # (123 abc 456 def)
"123abc456def".comb(3,2);        # (123 abc)
```

如果匹配器（matcher）是一个整数值，那么它被认为和 `/. ** matcher/` 类似，但是这个快了 30 倍。