title:  :D 在 Perl 6中是什么意思

date: 2016-01-29

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>现在是00:46, 我听见窗外好像下雪了。</blockquote>

一个裸的 **:D**、**:U**、**:T** 或 **:_** 是限制默认类型为定义、未定义、类型对象或任何对象的类型约束。所以

  
  ```perl6
  
    class Con {
        method man(:U: :D $x)
    }
    
 ```
其签名等价于  `(Con:U: Any:D $x)`。

Con:U 是调用者, 在调用者后面加上一个冒号。要标记一个显式的调用者, 在它后面放上一个冒号就好了:

```perl6


method doit ($x: $a, $b, $c) { ... }
```




### Abstract vs Concrete types


对于任何有名字的类型, 某些其它子集类型可以自动地通过在类型的名字后面追加一个合适的状语来派生出来：

```
    Int:_       允许定义或未定的 Int 值
    Int:D       只允许有定义的(强制的)Int 值
    Int:U       只允许未定义值(抽象或失败)Int 值
    Int:T       允许Int只作为类型对象

```

即, 它们的意思有点像:

```

    Int:D       Int:_ where DEFINITE($_)
    Int:U       Int:_ where not(DEFINITE($_))
    Int:T       Int:U where none(Failure)

```

`where DEFINITE` 是一个布尔宏, 它说正处理的对象是否有一个合法的强制表示。(查看下面的自省) .


在 Perl 6 中, **Int** 通常假定意为 `Int:_`, 除了调用者, 其中默认为 `Int:D`。 （默认的 new 方法有一个原型, 它的调用者是 `:T`, 所以所有的 new 方法都默认允许类型对象。）

这些默认可以通过各种编译指令在词法作用域中更改。



```perl6

    use parameters :D;


```

会让非调用者的参数默认为 `:D`。

 
作为对比,


```perl6

   use variables :D;

```
   
会对用于变量声明中的类型做同样的事情。
在这样的词法作用域中, 你可以使用 `:_` 形式回到标准的行为。特别地, 因为调用者默认为定义的:


```perl6

    use invocant :_;

```

会让调用者允许任何类型的有定义的和未定义的调用者。
