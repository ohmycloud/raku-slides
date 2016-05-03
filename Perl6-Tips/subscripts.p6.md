关于为自定义的类添加下标这个问题， stackoverflow 上的回答是不需要在 handles 后面所跟的方法中添加 `self`。 他的解释如下:

## [为自定义的类添加下标(subscripts)](http://stackoverflow.com/questions/36773986/how-to-add-subscripts-to-my-custom-class-in-perl-6)

在自定义类上实现关联式下标(associative subscripting)。

### 通过代理实现

Perl 6 通过在实现了集合类型的对象身上调用良定义的方法来实现关联式下标和位置下标（对于内置类型）。通过在 `%!fields` 属性后面添加 `handles` 特性(trait)， 你就把这些方法调用传递给了 `%!fields` -- 它作为一个散列，会知道怎么来处理那些方法。

### 灵活的键

> However, HTTP header field names are supposed to be case-insensitive (and preferred in camel-case). We can accommodate this by taking the *-KEY and push methods out of the handles list, and implementing them separately...


把所有的键处理方法代理给内部的散列意味着你的键得到了散列那样的插值 -- 意味着它们将是大小写无关的因为散列的键是大小写无关的。为了避免那，你把所有跟键有关的方法从 *handles* 子句中拿出并自己实现那些方法。在例子中，键在被索引到 `%!fields` 让键变成大小写无关之前先进行了键的「标准化」。

### 灵活的值

例子中的最后一部分展示了当值存入到散列那样的容器中时你如何控制值的插值。到目前为止，通过赋值给这个自定义容器的实例提供的值要么是一个字符串，要么是一个字符串的数组。额外的控制是通过移除定义在灵活的键中的  **AT-KEY** 方法来达成的并提供一个 **[Proxy](https://doc.perl6.org/type/Proxy)** 对象来代替它。如果你给容器赋值，那么代理人对象的 **STORE** 方法会被调用并且那个方法会扫描所提供的字符串值中的 `", "`（注意空格是必要的）。如果找到会接收那个字符串值作为几个字符串值的说明书。






```perl6
use v6;

class HTTPHeader { ... }

class HTTPHeader does Associative  {
    
    has %!fields  handles <list kv keys values>;
    method Str { say self.hash.fmt; }
    
    
    multi method EXISTS-KEY ($key)       { %!fields{normalize-key $key}:exists }
    multi method DELETE-KEY ($key)       { %!fields{normalize-key $key}:delete }
    multi method push (*@_)              { %!fields.push: @_                   }

    sub normalize-key ($key) { $key.subst(/\w+/, *.tc, :g) }

    method AT-KEY (::?CLASS:D: $key) is rw {
        my $element := %!fields{normalize-key $key};
        
        Proxy.new(
            FETCH => method () { $element },
            
            STORE => method ($value) {
                $element = do given $value».split(/',' \s+/).flat {
                    when 1  { .[0] }    # a single value is stored as a string
                    default { .Array }  # multiple values are stored as an array
                }
            }
        );
    }
}


my $header = HTTPHeader.new;
say $header.WHAT;  #-> (HTTPHeader)
"".say;

$header<Accept> = "text/plain";
$header{'Accept-' X~ <Charset Encoding Language>} = <utf-8 gzip en>;
$header.push('Accept-Language' => "fr");  # like .push on a Hash

say $header.hash.fmt;
"".say;
# say $header.Str; # 同上

say $header<Accept-Language>.values; 
say $header<Accept-Charset>;
```

输出：

```
(HTTPHeader)

Accept	text/plain
Accept-Charset	utf-8
Accept-Encoding	gzip
Accept-Language	en fr

(en fr)
utf-8
```

同样，你也可以使用数组下标，只要你重写相应地方法。