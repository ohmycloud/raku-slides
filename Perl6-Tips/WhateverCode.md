[Whatever Object](https://desgin.perl6.org/S02.html#The_Whatever_Object)

字符 `*` 作为一个单独的术语捕获了 「Whatever」的概念，它的意思可以由它所代表的参数懒惰地决定。可选地，对于那些不介意自己处理 `*` 字符的一元或二元操作符，它会在编译时被自动装填到接收一个或两个参数的闭包中。（查看下面。）

通常，当操作符自己处理 `*` 字符时，它总是可以被当做一个 「glob」，在那个参数位置上它能给你任何东西它能给你的东西。例如，这儿有一些选择去处理 `*` 字符并给它特殊意义的操作符：

```perl6
   if $x ~~ 1..* {...}                 # if 1 <= $x <= +Inf
   my ($a,$b,$c) = "foo" xx *;         # an arbitrary long list of "foo"
   if /foo/ ff * {...}                 # 一个封闭的 flipflop
   @slice = @x[*;0;*];                 # all indexes for 1st and 3rd dimensions
   @slice = %x{*;'foo'};               # all keys in domain of 1st dimension
   @array[*]                           # 所有值的列表, 不像 @array[]
   (*, *, $x) = (1, 2, 3);             # 跳过前两个元素
                                       # (和 Perl 5 中的左值 "undef" 相同)
```

「Whatever」是一个派生于 Any 的未定义的原型对象。作为类型它是抽象的，并且不可以被实例化为一个定义了的对象。

### 

Perl 6 有几种执行部分函数应用的方法。因为这是个难以处理的术语，我们决定叫它「装填」。(很多人叫它「柯里化」，但是那实际上真的不是该术语的正确技术上的用法。) 更一般地，装填通过调用它的 `.assuming` 方法来在 Callable 对象上执行，到处都有描述。这一节是关于它的便捷语法糖。

对于任何一元或二元操作符(特别地，任何前缀，后缀和中缀操作符)，如果那个操作符没有特别要求（通过签名匹配）去自己处理 `*` 字符，那么编译器会在编译时把 `*` 字符直接转换为合适的填装过的闭包。我们把这叫做自动装填。大部分的内置数值化操作符都归为此类。所以：

```perl6
* - 1
'.' x *
* + *
```

被填装成含有一个或两个参数的闭包：

```perl6
{ $^x - 1   }
{ '.' x $^y }
{ $^x + $^y }
```

这个重写发生在变量查询它们的词法作用域之后，并且在声明符安装任何变量到它们的词法作用域后，结果：

```perl6
* + (state $s = 0)
```

实际上被填充为：

```perl6
-> $x { $x + (state $OUTER::s = 0) }
```

而不是：

```perl6
-> $x { $x + (state $s = 0) }
```

换句话说， `*` 填装没有创建一个有用的词法作用域。（尽管在它运行时的确拥有一个动态作用域。）This prevents the semantics from changing drastically if the operator in question suddenly decides to handle Whatever itself.

作为一个后缀操作符，方法调用是那些会自动装填的操作符的其中之一。有点像：

```perl6
*.meth(1, 2, 3)
```

被重写为：

```perl6
{ $^x.meth(1,2,3) }
```






























