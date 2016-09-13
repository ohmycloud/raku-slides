[Sneaky methods](https://gfldex.wordpress.com/2016/07/20/sneaky-methods/)

就像你想的那样, 在类的定义中可以声明和定义方法。你期望不高的甚至文档中都很少提及是用 `my` 关键字声明的免费浮点方法。现在为什么你想要:

```perl6
my method foo(SomeClass:D:) { self }
```

明显的答案是[元对象协议](https://docs.perl6.org/language/mop)中的 [add_method](https://docs.perl6.org/type/Metamodel$COLON$COLONMethodContainer#method_add_method) 方法, 在 Rakudo 里你能找到它：

```perl6
src/core/Bool.pm
32:    Bool.^add_method('pred',  my method pred() { Bool::False });
33:    Bool.^add_method('succ',  my method succ() { Bool::True });
35:    Bool.^add_method('enums', my method enums() { self.^enum_values });
```
这种方法还有另外一种更诡异的用法。你可能很想知道在链式方法调用中究竟发生了什么。我们可以扯开最上面的那个表达式并插入一个短的变量, 输出我们的调试, 并且继续链式调用。好的名字很重要并且把它们浪费在一个短变量上没有必要。

```perl6
<a b c>.&(my method ::(List:D) { dd self; self } ).say;

# output
# ("a", "b", "c")
# (a b c)
```

没有显式调用我们就不能没有名字, 因为 Perl 6 不允许我们这样做, 所以我们使用了空的作用域 `::` 以使解析器高兴。使用一个合适的调用, 我们就不需要它了。还有, 那个匿名方法不是 List 中的一员。我们需要使用后缀 `.&` 来调用它。如果我们需要多次使用那个方法我们可以把它拉出来并给它一个名字。

```perl6
my multi method debug(List:D:) { dd self; self };
<a b c>.&debug.say;

# output
("a", "b", "c")
(a b c)
```

或者, 如果我们想允许回调的话, 我们可以把它作为默认参数赋值。

```perl6
sub f(@l, :&debug = my method (List:D:){self}) { @l.&debug.say };
f <a b c>, debug => my method ::(List:D){dd self; self};

# output
#("a", "b", "c")
# (a b c)
```

在 Perl 6 中基本上所有的东西都是类, 包括[方法](https://docs.perl6.org/type/Method)。 如果它是类它可以是一个对象并且我们能在我们喜欢的任何地方溜进去。



















































