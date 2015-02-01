# Day 10 — Adverbly Adverby Adverbs By   Lueinc


两种创建Pair对象的方法：

    my %h = debug => True;

还有一种是冒号记法

    my %h = :debug(True);

今天，我会向你展示冒号记法是如何有用，Perl 6将它们用作主要的语言特性.

## 什么是副词

在自然语言中，副词没有动词与形容词的意思变化的明显。例如:

    The dog fetched the stick.  # 狗叼回了棒子

仅仅是狗所做的表现。通过加上副词，例如:

    The dog quickly fetched the stick.   # 狗很快地叼回了棒子

声明狗能在**很短**的时间完成这件事。副词能让变化很**激烈**，就像看到的：

    This batch of cookies was chewy.        # 饼干很难嚼
    This batch of cookies was oddly chewy.  # 饼干极其难嚼

第二个句子，使用副词 “oddly”，让你知道那饼干不是面包师的目标。Perl6中的副词表现的跟上面的任务很像，告诉**函数**和其它语言特性做它们想做的

## 副词基础

副词是使用**冒号+副词**的语法来表达的。通常，你将它们用作**开关**。

开启副词的方式就像这样：

    :adverb
	
它和这一样：

    :adverb(True)

关闭副词长这样：

    :!adverb

它就像这样：

    :adverb(False)

如果你传递的是字符串直接量，例如

    :greet('Hello')
    :person("$user")

你可以用下面的代替：

    :greet<Hello>
    :person«$user» or :person<<$user>>

只要字符串中没有空格（尖括号形式实际上创建一列项，用空格分隔）

你也可以缩写变量如果变量的名字和键的名字相同。

```perl
 :foo($foo)
 :$foo
```

如果你提供一个十进制数，有两种写法：

    :th(4)
    :4th


(The :4th form only works on quoting construct adverbs, like m// and q[], in Rakudo at the moment.)

Note that the negation form of adverb ( :!adv ) and the sigil forms ( :$foo, :@baz ) can’t be given a value, because you already gave it one. 函数调用中的副词

函数调用中的副词用法更像具名参数，但仍计为副词。

下面是例子：

    foo($z, :adverbly);
    foo($z, :bar, :baz);
    foo($z, :bar :baz);


每个副词都是一个具名参数，所以使用多个逗号分隔每个副词，就像分隔其它参数一样。注意你也可以像最后一个例子中一样，允许你叠加副词。 作用在操作符上的副词

Adverbs can be supplied to operators just as they can be to functions. They function at a precedence level tighter than item assignment and looser than conditional. ( See this part of the Synopses for details on precedence levels. )

例子：

    foo($z) :bar :baz  # 等价于 foo($z, :bar, :baz)
    1 / 3 :round       # applies to /
    $z & $y :adverb    # applies to &


When it comes to more complex cases, it’s helpful to remember that adverbs work similar to how an infix operator at that precedence level would (if it helps, think of the colon as a double bond in chemistry, binding both “sides” of the infix to the left-hand side). It operates on the loosest precedence operator no looser than adverbs.


    1 || 2 && 3 :adv   # applies to ||
    1 || (2 && 3 :adv) # applies to &&
    !$foo.bar() :adv   # applies to !
    !($foo.bar() :adv) # applies to .bar()
    @a[0..2] :kv       # applies to [ ]
    1 + 2 - 3 :adv     # applies to -
    1 ** 2 ** 3 :adv   # applies to the leftmost **


Notice that the behavior of adverbs on operators looser than adverbs is  currently  undefined.


    1 || 2 and 3 :adv  # error ('and' too loose, applies to 3)
    1 and 2 || 3 :adv  # applies to ||
作用在引号结构上的副词

Various quote-like constructs change behavior through adverbs as well.

(Note: this post will refrain from providing an exhaustive list of potential adverbs. S02 and S05 are good places to see them in more detail.)

For example, to have a quoting construct that functions like single quotes but also interpolates closures, then you would do something like:


    q:c 'Hello, $name. You have { +@msgs } messages.' # yes, a space between c and ' is required


Which comes out as
Hello, $name. You have 12 messages.

(This implies your  @msgs  array has 12 elements.)

If you instead just wanted a double-quote-like construct that didn’t interpolate scalars, you’d do


    qq:!s ' ... etc ...'


Regexes allow you to use adverbs within the regex in addition to outside. This allows you to access features brought by those adverbs in situations where you’d otherwise be unable to use them.


    $a ~~ m:i/HELLO/; # matches HELLO, hello, Hello ...
    $a ~~ /:i HELLO/; # same
    regex Greeting {
         :i HELLO
    }                 # same


One thing to keep in mind is that adverbs on a quoting construct must use parentheses to pass values. This is because  normally  any occurrence of brackets after an adverb is considered to be passing a value to that adverb, which conflicts with you being able to choose your own quoting brackets.要记住的是作用在引号结构上的副词必须使用圆括号来传递值。这是因为，通常出现在副词后面的括号会被作为值传递给副词，这与你可以选择自己的引号括号的权利冲突了。


    m:nth(5)// # OK
    m:nth[5]// # Not OK
    q:to(EOF)  # passing a value to :to, no delimiters found
    q:to (EOF) # string delimited by ()
使用你自己的副词

So you’ve decided you want to make your own adverbs for your function. If you’ll remember, adverbs and named arguments are almost the same thing. So to create an adverb for your function, you just have to declare named parameters:所以你决定给你的函数添加你自己定义的副词。如果你记得的话，副词和具名参数基本上是一样的东西。所以，为了给你的函数创建副词，你仅仅只需要声明具名参数就好了：

    sub root3($number, :$adverb1, :$adverb2) {
         # ... snip ...
    }


Giving adverbs a default value is the same as positional parameters, and making an adverb required just needs a  !  after the name:给副词一个默认值就和位置参数一样，并且让某个副词必须出现，只需在副词名后面添加一个感叹号就好了：


    sub root4($num, :$adv1 = 42, :$adv2, :$adv3!) {
         # default value of $adv1 is 42,
         # $adv2 is undefined (boolifies to False)
         # $adv3 must be supplied by the user
    }


If you want to catch all the adverbs somebody throws at you, you can use a slurpy hash:如果你想捕捉别人扔给你的所有副词，你可以使用 slurpy 散列：

    sub root3($num, *%advs) {
         # %advs 包含所有传递给该函数的副词 :adverbs
         # that were passed to the function.
    }


And if you define named parameters for the  MAIN  sub, they become commandline options! This is the one time where you should use Bool  on boolean named parameters, even if you don’t  normally , just to keep the option from accepting a value on the commandline.如果你在MAIN子例程定义了具名参数，它们会变成命令行选项！

It’s the same for operators, as operators are just functions with funny syntax.操作符也是一样，因为操作符就是特殊语法的函数！

Now that you learned how to apply the humble  Pair  to much more than just  Hash es, I hope you’ll  quickly  start using them in your code, and  joyously  read the rest of the advent!

来源： < http://perl6advent.wordpress.com/2013/12/10/day-10-adverbly-adverby-adverbs/ >  