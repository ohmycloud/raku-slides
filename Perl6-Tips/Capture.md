
[Capture](http://doc.perl6.org/type/Capture) 的定义:

``` perl
class Capture does Positional does Associative { }
```

Capture 是一个用于给 code 对象传递参数的容器。Captures 是签名的另一面 — Captures 在调用方定义实参, 而签名(Signatures) 在被调用方定义形式参数。

当你调用 `print $a, $b` 时, `$a, $b` 这部分就是一个 Capture。`$a, $b` 在这儿是实参。

Captures 包含一个 list-like 部分的位置参数和一个 hash-like 部分的具名参数。对于具名参数, Captures 使用一种略微不同的语法而不是普通的 List。有两种简单的方法生成一个具名参数：

- 使用一个未引起的键命名一个形参, 后面跟着 `=>`, 然后跟着参数
- 使用以形参命名的冒号对儿字面量

``` perl6
say unique 1, -2, 2, 3, as => { abs $_ }; # 1, -2, 3
# ... is the same thing as:
say unique 1, -2, 2, 3, :as({ abs $_ });  # 1, -2, 3
# Be careful not to quote the name of a named parameter:
say unique 1, -2, 2, 3, 'as' => { abs $_ }; # 1, -2, 2, 3, "as" => { ... }
```

单个独立的 Capture 也能被生成, 存储, 然后供之后使用。 在项(term)那儿前置一个反斜线 `\` 能生成一个字面的 Capture。通常, 这个 term 会是一个 terms 的列表, 在这个列表里面, 任何 Pair 字面值会被放在 Capture 的具名部分, 而其它 terms 会被放在Capture 的位置(positional) 部分。

``` perl6
my $c = \(42);               # 带有一个 positional 部分的 Capture        
$c = \(1, 2, a => 'b');      # 带有两个 positional 部分和一个具名部分的 Capture
```

要使用这样的 Capture, 在函数调用里你可以在这个 Capture 前面使用 `|` , 那么它看起来会像这个 Capture 中的所有值都被作为实参直接传递这个函数了 — 具名参数作为具名参数传递, 而位置参数会作为位置参数传递。 只要你愿意, 你可以重用这个 Capture 任意次, 甚至使用不同的函数。

``` perl6
my $c = \(4,2,3);
reverse(|$c).say; # 3 2 4
sort(5,|$c).say;  # 2 3 4 5
```

在签名( Signature) 里面, 可以在不含符号的形参那儿前置一个竖线 `|` 来创建一个 Capture。这会把余下的参数列表打包到那个形参中：

``` perl6
sub f($a, |c) {
    say c; 
}
f(1, 2, 3, a => 4, b => 5); # c  is  \(2, 3, a => 4, b => 5)
```

请注意，Capture 仍然是列表，因为它们可能包含容器，而不只是值:

``` perl6
my $b = 1;
my $c = \(4,2,$b,3);
sort(|$c).say;        # 1 2 3 4
$b = 6;
sort(|$c).say;        # 2 3 4 6
```

