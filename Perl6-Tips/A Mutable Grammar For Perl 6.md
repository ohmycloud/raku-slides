
## A Mutable Grammar For Perl 6

###  Rules

`Rules` 就像 perl5的 `regexes`，并且更好。它们像子例程和方法那样申明，并且还能调用其它 rules

下面是一个解析 Perl 6 基本变量名的例子：

``` perl
grammar Perl6 {   
# among other stuff:

    # token alpha 是一个预定义好的 rule
    token identifier {           
       <alpha> \w+     
    }    
    
   # 匹配一个全限定名标识符
    # [ ... ]  是非捕获组
    token name {        
        <identifier>         
        [ '::' <identifier> ] *     
    } 
     # .. | .. 是分支. 最长匹配胜出.
    token sigil {        
       '$' | '@' | '&' | '%' | '::'    
    }    
    # <rule> 调用命名 rule, 隐式地锚定在当前位置
    token variable {       
        <sigil> <name>  
    }

} 
```

### Grammars

`Grammar` 跟类很像，含有 `rules` 而不是 methods。 grammars 是 `rules` 的集合并支持`继承`。

如果要求 Perl 6 中变量的名字必须大写：

``` perl
# 我们继承原来那个 grammar
grammar PERL6 is Perl6 {    
    # ... 重写我们想改变的解析规则
    token identifier {        
   # Perl 6 中的字符类现在写作 <[ ... ]>         
       <[A..Z]> <[A..Z0..9_]>*   }
}
```

现在我们只需告诉编译器使用 `PERL6` 这个 grammar 而非默认 grammar 。还记得类中的方法调用顺序吗？ 先从本类开始， 沿着继承树从下而上到父类... 。 grammar 与之类似。

然而有一个缺陷。假设你想更改一个符号， 例如把 `$` 更改 为 `¢`（因为你没有足够的 `$$$` 来买下所有的变量，不是吗？）看起来很简单：

``` perl
grammar LowBudgetPerl6 is Perl6 {
    # token 就像类中的方法一样, 继承后可以修改
    token sigil { '¢' | '@' | '&' | '%' | '::' }
}
```

新的 grammar 解析工作的很好， 但是那之后的所有东西肯定会失败。当编译器在解析树里看见 `sigil` 匹配时，它得找出到底是哪一个 - 这意味着它必须要检查匹配文本的字面值， 而它并不知道怎么处理 `¢`

所以，我们需要更多的技能...

## Proto Regexes

 `proto regex` 是一套有着相同名字的 regexes/rules，当前的 [Perl 6 grammar](http://svn.pugscode.org/pugs/src/perl6/STD.pm) 使用这个结构：

``` perl
proto token sigil {*}
# ...
token sigil:sym<$>  { <sym> }
token sigil:sym<@>  { <sym> }
token sigil:sym<%>  { <sym> }
token sigil:sym<&>  { <sym> }
token sigil:sym<::> { <sym> }

```

这创建了一个叫做 `sigil` 的组(`proto`)，组里面有使用 `sym` 标识符参数化的5 个规则(rules)（它们属于这个组因为它们跟组的名字相同）。 第一个把 `sym` 设置为 `$` 然后匹配这个符号(使用`<sym>`). 第二个匹配 `@`等等。现在如果调用规则 `<sigil>` ,你会得到一个含有上述所有 5 个规则的列表，列表元素之间是`或`的关系。所以它依然跟正则 `'$' | '@' | '%' | '&' | '::'` 匹配相同的东西， 但是更容易扩展。

如果你想添加一个新的符号，  grammar 中唯一要修改的就是添加另外一个 `sigil`规则： 

``` perl
grammar SigilRichP6 is Perl6 {
    token sigil:sym<ħ> { <sym> } # 物理学家会很爱你
}
```

回到原来那个例子， 你可以重写已存在的规则：

``` perl
grammar LowBudgetPerl6 is Perl6 {
    token sigil:sym<$> { '¢' }
}

```

现在这个 grammar 为标量使用了一个不同的符号， 但是它和原来的 grammar 有着相同的规则和相同的参数(`sigil:sym<$>`) ， 编译器仍然知道怎么处理它。

