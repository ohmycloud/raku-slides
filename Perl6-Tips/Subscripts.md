
# TITLE

下标

# SUBTITLE

通过索引或键访问数据结构中的元素。

通常，人们需要引用集合或数据结构中的一个特定的元素（或特定的元素切片）。从数学标记法中偷学到的，向量 `v` 的组成部分用 *v₁, v₂, v₃* 来引用，在 Perl 6 中这个概念叫做 “下标” （或“索引”）。

# Basics

Perl 6 提供了两个通用的下标接口：

``` perl
	   elements are identified by     interface name    supported by
[ ]	 zero-based indices	              Positional        Array, List, Buf, Match, ...
{ }	 string or object keys            Associative       Hash, Bag, Mix, Match, ...
```

- **Positional** 下标 (通过 [`postcircumfix [ ]`](http://doc.perl6.org/language/operators#postcircumfix_[_]) 通过元素在有序集合中的位置来寻址元素。索引 0 引用第一个元素， 索引 1 引用第二个元素， 以此类推：

  ``` perl
  my @chores = "buy groceries", "feed dog", "wash car";
  say @chores[0];  #-> buy groceries
  say @chores[1];  #-> feed dog
  say @chores[2];  #-> wash car
  ```

- **Associative** 下标 (通过 [`postcircumfix { }`](http://doc.perl6.org/language/operators#postcircumfix_{_}), 不要求集合以任何特定的顺序保存元素 - 相反，它使用一个唯一的键来寻址每个值。键的种类取决于使用的集合： 举个例子， 一个标准的[散列](http://doc.perl6.org/type/Hash) 使用字符串作为键， 而一个 [Mix](http://doc.perl6.org/type/Mix) 能使用任意的对象作为键， 等等:

  ``` perl
  my %grade = Zoe => "C", Ben => "B+";
  say %grade{"Zoe"};  #-> C
  say %grade{"Ben"};  #-> B+

  my $stats = ( Date.today => 4.18, Date.new(2015,  4,  5) => 17.253 ).Mix;
  say $stats{ Date.new(2015, 4, 5) };  #-> 17.253
  ```

  相对于传递单个-单词字符串键给 `{ }` , 你也可以使用[以尖括号引起单词的结构](http://doc.perl6.org/language/quoting#Word_quoting:_qw) ，就像它们是后缀操作符一样：

  ``` perl
  say %grade<Zoe>;    #-> C
  say %grade<Ben>;    #-> B+
  ```

  这实际上仅仅是在编译时被转换为对应 `{ }` 形式的语法糖：

  ```
  %hash<foo bar>;     # same as %hash{ <foo bar> }
  %hash«foo $var»;    # same as %hash{ «foo $var» }
  %hash<<foo $var>>;  # same as %hash{ <<foo $var>> }
  ```

下标能应用到能返回可下标化对象的任何表达式上， 而不仅仅应用到变量上：

```
say "__Hello__".match(/__(.*)__/)[0];   #-> ｢Hello｣
say "__Hello__".match(/__(.*)__/).[0];  # same, in method notation
```

Positional 和 associative  下标并不互相排斥 - 举个例子， `Match` 对象两个都支持（每个访问不同的数据集）。还有， 为了让列表处理更方便， 类 `Any` 为`位置下标`提供了备用的实现，这会把调用者看作含有`一个`元素的列表。(但是对于关系下标，没有这样的备用实现， 所以会抛出一个异常，当下标被应用到没有实现支持的对象上时。)

```
say 42[0];    #-> 42
say 42<foo>;  # ERROR: postcircumfix { } not defined for type Int
```

#

当通过下标寻址一个不存在的元素所发生的事情取决于正在使用的集合类型。标准的 Array 和 Hash 集合返回它们的[value type constraint](http://doc.perl6.org/routine/of)  的类型对象（这默认是 `Any`）。

```
my @array1;     say @array1[10];  #-> (Any)
my Int @array2; say @array2[10];  #-> (Int)

my %hash1;      say %hash1<foo>;  #-> (Any)
my Int %hash2;  say %hash2<foo>;  #-> (Int)
```

然而， 其它类型的集合可能在寻址不存在的元素的下标时反应也不用：

```
say (0, 10, 20)[3];       #-> Nil
say bag(<a a b b b>)<c>;  #-> 0
```

为了在下标操作中默默地跳过不存在的元素， 查看 [#Truncating slices](http://doc.perl6.org/language/subscripts#Truncating_slices)  和 [`#:v`](http://doc.perl6.org/language/subscripts#%3Av) 副词。

# From the end

Positional  索引是从集合的开头计数的， 但是也有一种标记法用于，通过相对于末尾的位置来寻址元素：`*-1` 引用最后一个元素， `*-2` 引用倒数第二个元素， 以此类推。

```
my @alphabet = 'A' .. 'Z';
say @alphabet[*-1];  #-> Z
say @alphabet[*-2];  #-> Y
say @alphabet[*-3];  #-> X
```

注意：星号很重要。在 Perl 6中，如果像在很多其它编程语言中那样传递一个裸的负整数（例如 `@alphabet[-1]`）， 会抛出错误。

这里实际发生的是， `*-1` 那样的表达式通过 [Whatever](http://doc.perl6.org/type/Whatever) 柯里化声明了一个代码对象 - `[ ]`会把代码对象作为索引， 通过集合的长度作为参数来调用它并使用结果值作为实际的索引。 换句话说，`@alphabet[*-1]` 变成了 `@alphabet[@alphabet.elems - 1]`。

这意味着你可以使用任何依赖于集合尺寸的表达式：

``` perl
say @array[* div 2];  # 选择最中间的那个元素
say @array[$i % *];   # wrap around a given index ("模运算")
say @array[ -> $size { $i % $size } ];  # same as previous
```

# Slices



当需要访问集合中的多个元素时，有一个快捷方式用于处理多个单独的下标操作：仅仅在下标中指定一个`索引/键`的列表，来取回一个元素的列表 - 也被叫做”切片” - 以相同的顺序。

对于 positional  切片， 你可以混合普通切片和  [from-the-end](http://doc.perl6.org/language/subscripts#From_the_end) 切片：

```
my @alphabet = 'a' .. 'z';
dd @alphabet[15, 4, *-9, 11];  #-> ("p", "e", "r", "l")
```

对于 associative  切片，尖括号形式的切片通常会很方便：

```
my %color = kiwi => "green", banana => "yellow", cherry => "red";
dd %color{"cherry", "kiwi"};  #-> ("red", "green")
dd %color<cherry kiwi>;       #-> ("red", "green")
dd %color{*};                 #-> ("green", "red", "yellow")
```

要知道切片是由传入 ([one dimension of](http://doc.perl6.org/language/subscripts#Multiple_dimensions))下标的类型控制的，而非它的长度：

``` perl
subscript	                               result
any Positional object not covered below	   normal slice
a Range or infinite sequence	           truncating slice (only for positional subscripts)
* (Whatever-star)	                       full slice (as if all keys/indices were specified)
any other object	                       single-element access rather than a slice
empty	                                   Zen slice
```

所以，即使一个单个元素的列表也会返回一个切片， 而一个裸的标量值不会：

```
dd @alphabet[2,];  #-> ("c",)
dd @alphabet[2];   #-> "c"
```

(尖括号形式的 associative 下标也没有问题，因为 [word quoting](http://doc.perl6.org/language/quoting#Word_quoting:_qw)  在单个单词的情况下很方便的返回一个 Str, 但是在多个单词的情况下返回一个 [Parcel](http://doc.perl6.org/type/Parcel))。

对于普通的切片，下标的内容 ([the current dimension of](http://doc.perl6.org/language/subscripts#Multiple_dimensions)) 在它的元素被解释为 `索引/键` 之前会被展平(flattened)：

```
dd @alphabet[0, (1..2, (3,)))];  #-> ("a", "b", "c", "d")
```

## Truncating slices

通常, 在切片下标中引用不存在的元素会让输出列表包含未定义的值。然而， 如果传递给位置下标的对象是一个 Range 或使用序列操作符构建的无限序列， 它会被自动截断到集合的实际尺寸：

```
my @letters = <a b c d e f>;
dd @letters[3, 4, 5, 6, 7];  #-> ("d", "e", "f", Any, Any)
dd @letters[3 .. 7];         #-> ("d", "e", "f")
```

[From-the-end](http://doc.perl6.org/language/subscripts#From_the_end)  索引被允许作为范围的端点，代表无限的范围和序列：

```
say @array[*-3 .. *];       # select the last three elements
say @array[0, 2, 4 ... *];  # select all elements with even indices
```

如果你不想把你的切片指定为 `range/sequence` 但仍旧想默默地跳过不存在的元素， 你可以使用 [#:v](http://doc.perl6.org/language/subscripts#%3Av) 副词。

## Zen slices

如果你写的下标没有指定任何 `索引/键` ，那它就会返回被脚注的对象自身。因为它是空的但是返回了全部东西， 这就是所谓的 "Zen slice"。

这和传递一个  Whatever-star （这，像普通的切片， 总是返回一个元素的 Parcel，不管原对象的类型）还有传递一个空的列表都不同（它返回一个空的切片）：

```
my %bag := ("orange" => 1, "apple" => 3).Bag;
dd %bag<>;    #-> ("orange"=>1,"apple"=>3).Bag
dd %bag{};    #-> ("orange"=>1,"apple"=>3).Bag
dd %bag{*};   #-> (1, 3)
dd %bag{()};  #-> ()
```

这通常被用于把整个 `数组/散列` 插值到字符串中：

```
my @words = "cruel", "world";
say "Hello, @words[]!"  #-> Hello, cruel world!
```

# Multiple dimensions

尚未实现！等到 9 月份？

# Modifying elements

# Autovivification

下标参与 "autovivification”（自动复活），i.e. 这是一种数组和散列在需要时会自动存在的处理， 以至于你没有必要在每一层级预声明集合的类型来构建嵌套的数据结构：

```
my $beatles;
$beatles{"White Album"}[0] = "Back in the U.S.S.R.";  # autovivification!
say $beatles.perl;  #-> {"White Album" => ["Back in the U.S.S.R."]}
```

`$beatles`  从未定义开始， 但是它变成了一个 Hash 对象， 因为它在赋值时用 `{ }` 标注了。 类似地，  `$beatles{"White Album”}` 变成一个 Array 对象， 因为它在赋值时用 `[ ]` 标注了。

注意下标本身不会引起 autovivification（自动复活）：它只发生在下标链的结果被赋值时（或变化时）。



# Binding

下标表达式也可以用在绑定语句的左侧。如果被标注的集合的类型支持， 这会使用指定的容器替换集合里的插槽的值：（给跪了！）

内置的 Array 和 Hash 类型支持这种绑定， 为了允许构建复杂的联动的数据结构：

```
my @a = 10, 11, 12, 13;
my $x = 1;

@a[2] := $x;  # binding! (@a[2] and $x refer to the same container now.)

$x++; @a[2]++;

dd @a;  #-> [10, 11, 3, 13]<>
dd $x;  #-> 3
```

查看 [#method BIND-POS](http://doc.perl6.org/language/subscripts#method_BIND-POS) 和 [#method BIND-KEY](http://doc.perl6.org/language/subscripts#method_BIND-KEY) 了解底层机制.

# Adverbs

下标操作的返回值和可能存在的副作用能够使用副词来控制。

要知道副词操作符的优先级相对宽松，这可能需要你在合成表达式中添加括号：

```
if $foo || %hash<key>:exists { ... }    # WRONG, tries to adverb the || op
if $foo || (%hash<key>:exists) { ... }  # correct
```

支持的副词有:

## :exists

返回请求的元素是否存在，而不是返回元素实际的值。这能够用于区别未定义值的元素和一点儿也不属于集合部分的元素：

``` perl
my @foo = Any, 10;
dd @foo[0].defined;    #-> False
dd @foo[0]:exists;     #-> True
dd @foo[2]:exists;     #-> False
dd @foo[0, 2]:exists;  #-> (True, False)

my %fruit = apple => Any, orange => 10;
dd %fruit<apple>.defined;       #-> False
dd %fruit<apple>:exists;        #-> True
dd %fruit<banana>:exists;       #-> False
dd %fruit<apple banana>:exists; #-> (True, False)
```

也可以对副词取反来测试不存在：

``` perl
dd %fruit<apple banana>:!exists; #-> (False, True)
```

要检查切片的所有元素是否存在， 使用 [all](http://doc.perl6.org/routine/all) junction:

``` perl
if all %fruit<apple orange banana>:exists { ... }
```

`:exists`  可以和  [:delete](http://doc.perl6.org/language/subscripts#%3Adelete) 还有 `:p/:kv` 副词组合 - 这时表达式的行为就由那些副词决定，除了使用表明元素存在的对应 Bool 值替换返回的元素值之外。

查看 [method EXISTS-POS](http://doc.perl6.org/language/subscripts#method_EXISTS-POS)  和 [method EXISTS-KEY](http://doc.perl6.org/language/subscripts#method_EXISTS-KEY) 了解底层机制.

## :delete

从集合中删除元素， 除了返回它们的值以外。

```
my @tens = 0, 10, 20, 30;
dd @tens[3]:delete;     #-> 30
dd @tens;               #-> [0, 10, 20]<>

my %fruit = apple => 5, orange => 10, banana => 4, peach => 17;
dd %fruit<apple>:delete;         #-> 5
dd %fruit<peach orange>:delete;  #-> (17, 10)
dd %fruit;                       #-> {banana => 4}<>
```

使用否定形式的副词，元素实际上不会被删除。这意味着你可以传递一个标记，让它变成有条件的删除：

```
dd %fruit<apple> :delete($flag);  # deletes the element only if $flag is
                                  # true, but always returns the value.
```

能和 `:exists` 还有 `:p/:kv/:k/:v` 副词组合 - 这时返回值由那些副词决定， 但是同时元素也会被删除。

查看 [method DELETE-POS](http://doc.perl6.org/language/subscripts#method_DELETE-POS) and [method DELETE-KEY](http://doc.perl6.org/language/subscripts#method_DELETE-KEY) 了解底层机制.

## :p

以 Pair 的形式，返回元素的`索引/键` 和元素值， 并默默跳过不存在的元素：

```
my @tens = 0, 10, 20, 30;
dd @tens[1]:p;        #-> 1 => 10
dd @tens[0, 4, 2]:p;  #-> (0 => 0, 2 => 20)

my %month = Jan => 1, Feb => 2, Mar => 3;
dd %month<Feb>:p;          #-> "Feb" => 2
dd %month<Jan Foo Mar>:p;  #-> ("Jan" => 1, "Mar" => 3)
```

如果你不想跳过不存在的元素， 使用否定形式:

```
dd %month<Jan Foo Mar>:!p;  #-> ("Jan" => 1, "Foo" => Any, "Mar" => 3)
```

能和 `:exists` 还有 `:delete` 组合。

也可以查看  [pairs](http://doc.perl6.org/routine/pairs) 子例程.

## :kv

以列表的形式返回元素的`索引/键`和`值` , 并默默地跳过不存在的元素。 当作用在切片上时，返回值是一个展平的键和值交叉着的单个列表：

```
my @tens = 0, 10, 20, 30;
dd @tens[1]:kv;        #-> (1, 10)
dd @tens[0, 4, 2]:kv;  #-> (0, 0, 2, 20)

my %month = Jan => 1, Feb => 2, Mar => 3;
dd %month<Feb>:kv;          #-> ("Feb", 2)
dd %month<Jan Foo Mar>:kv;  #-> ("Jan", 1, "Mar", 3)
```

如果你不想跳过不存在的元素， 使用否定形式:

```
dd %month<Jan Foo Mar>:!kv;  #-> ("Jan", 1, "Foo", Any, "Mar", 3)
```

这个副词一般用于遍历切片：

```
for %month<Feb Mar>:kv -> $month, $i {
    say "$month had {Date.new(2015, $i, 1).days-in-month} days in 2015"
}
```

能和 `:exists` 还有 `:delete` 组合。

也可以查看  [kv](http://doc.perl6.org/routine/kv) 子例程.

## :k

只返回元素的`索引/键` , 而不是它们的值, 并默默地跳过不存在的元素：

```
my @tens = 0, 10, 20, 30;
dd @tens[1]:k;        #-> 1
dd @tens[0, 4, 2]:k;  #-> (0, 2)

my %month = Jan => 1, Feb => 2, Mar => 3;
dd %month<Feb>:k;          #-> "Feb"
dd %month<Jan Foo Mar>:k;  #-> ("Jan", "Mar")
```

如果你不想跳过不存在的元素， 使用否定形式:

```
dd %month<Jan Foo Mar>:!k;  #-> ("Jan", "Foo", "Mar")
```

还可以查看  [keys](http://doc.perl6.org/routine/keys) 子例程.

## :v

返回元素的裸值（不是有可能返回一个可变值容器），并默默跳过不存在的元素：

```
my @tens = 0, 10, 20, 30;
dd @tens[1]:v;        #-> 10
dd @tens[0, 4, 2]:v;  #-> (0, 20)
@tens[3] = 31;        # OK
@tens[3]:v = 31;      # ERROR, cannot assign to immutable integer value

my %month = Jan => 1, Feb => 2, Mar => 3;
dd %month<Feb>:v;          #-> 2
dd %month<Jan Foo Mar>:v;  #-> (1, 3)
```

如果你不想跳过不存在的元素， 使用否定形式:

```
dd %month<Jan Foo Mar>:!v;  #-> (1, Any, 3)
```

还可以查看  [values](http://doc.perl6.org/routine/values) 子例程.


# Custom types

这页描述的下标接口并不意味着和 Perl 6 的内置集合类型相排斥 - 你可以（并且应该）为任何想通过索引或键提供数据访问的自定义类型重用它们。

你不必手动重载  [postcircumfix [ ]](http://doc.perl6.org/routine/[%20]#postcircumfix_[_]) 和  [postcircumfix { }](http://doc.perl6.org/)  操作符并重新实现它们所有的戏法， 为了实现它， 相反，你可以依赖这个事实， 在幕后，它们的标准实现分派给了一个定义良好的低级方法集。例如：


``` perl
when you write:	    this gets called behind the scenes:
%foo<aa>	        %foo.AT-KEY("aa")
%foo<aa>:delete	    %foo.DELETE-KEY("aa")
@foo[3,4,5]	        @foo.AT-POS(3), @foo.AT-POS(4), @foo.AT-POS(5)
@foo[*-1]	        @foo.AT-POS(@foo.elems - 1)
```



So in order to make subscripting work, you only have to implement or delegate those low-level methods ([detailed below](detailed below)) for your custom type.

所以， 为了让你的下标工作， 你只需要为你的自定义类型实现或委托那些低级的方法（[下面描述详情](http://doc.perl6.org/language/subscripts#Methods_to_implement_for_positional_subscripting)）。

如果你这样做了， 你还应该让你的类型各自构成 [Positional](http://doc.perl6.org/type/Positional) or [Associative](http://doc.perl6.org/type/Associative) role



## Custom type example

设想一下 HTTP::Header 类型，它尽管作为一个有特定行为的自定义类，却能像散列那样索引：

``` perl
my $request = HTTP::Request.new(GET => "perl6.org");
say $request.header.WHAT;  #-> (HTTP::Header)

$request.header<Accept> = "text/plain";
$request.header{'Accept-' X~ <Charset Encoding Language>} = <utf-8 gzip en>;
$request.header.push('Accept-Language' => "fr");  # like .push on a Hash

say $request.header<Accept-Language>.perl;  #-> ["en", "fr"]

my $rawheader = $request.header.Str;  # stringify according to HTTP spec
```

实现这个类的最简单的方法是，给它一个 Hash 类型的属性，并把所有的下标和迭代相关功能性委托给那个属性。（使用一个自定义类型约束来确保使用者不会在里面插入任何不合法的值）：

``` perl
class HTTP::Header does Associative is Iterable {
    subset StrOrArrayOfStr where Str | ( Array & {.all ~~ Str} );

    has %!fields of StrOrArrayOfStr
                 handles <AT-KEY EXISTS-KEY DELETE-KEY push
                          iterator list kv keys values>;

    method Str { #`[not shown, for brevity] }
}
```

然而， HTTP header 字段名被认为是大小写无关的（更偏好驼峰法）。我们可以通过把 `*-key` 和 `push` 方法拿到 `handles` 列表的外面来容纳它， 并像这样各自实现它们：

``` perl
method AT-KEY     ($key) is rw { %!fields{normalize-key $key}        }
method EXISTS-KEY ($key)       { %!fields{normalize-key $key}:exists }
method DELETE-KEY ($key)       { %!fields{normalize-key $key}:delete }
method push (*@_) { #`[not shown, for brevity] }

sub normalize-key ($key) { $key.subst(/\w+/, *.tc, :g) }
```

注意下标  `%!fields` 返回一个适当的 rw 容器， 而我们的 `AT-KEY` 能够简单地传递。

然而， 我们可能倾向于少一点对用户输入的限制， 相反我们自己关心字段值的消毒。那种情况下，我们可以移除 `%!fields` 上的 `StrOrArrayOfStr`  类型约束， 并在赋值时使用返回自定义的关心消毒值的 Proxy 容器来替换我们的 `AT-KEY` 实现：

```
multi method AT-KEY (::?CLASS:D: $key) is rw {
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
```

注意把方法声明为 `multi` 并把它限制为 `:D` (defined invocants) 确保未定义情况被传递给由 Any（这在自动复活中被调用） 提供的默认实现。（我去，翻译不来哦！）

## Methods to implement for positional subscripting

为了通过  [`postcircumfix [ ]`](`http://doc.perl6.org/routine/[%20]#postcircumfix_[_]`)  让基于索引的下标在你的自定义类型中工作，你应该至少实现下面的  `elems`, `AT-POS` 和 `EXISTS-POS-` 还有其它可选项。

### method elems

```
multi method elems (::?CLASS:D:)
```

预期返回一个数字，用于表明对象中有多少个可标注的元素。 可能被用户直接调用， 并且当从末尾索引元素的时候， 还会被  `postcircumfix [ ]` 调用， 就像 `@foo[*-1]` 中那样。

如果没有实现这个方法， 你的类型会从 Any 继承默认的实现， 对定义过的调用者这总是返回 1 - 这最不可能是你想要的。 所以， 如果不能从你的位置类型知晓元素的个数， 那就添加一个 fails 或 dies 实现， 以避免沉默地做了错事。






### method AT-POS



```
multi method AT-POS (::?CLASS:D: $index)
```

Expected to return the element at position `$index`. This is what [`postcircumfix [ ]`](`postcircumfix [ ]`) normally calls.

If you want an element to be mutable (like they are for the built-in [Array](Array) type), you'll have to make sure to return it in the form of an item container that evaluates to the element's value when read, and updates it when assigned to. (Remember to use `return-rw` or the `is rw` routine trait to make that work; see the [example](example).)

期望返回 `$index` 位置处的元素。这就是 `postcircumfix [ ]` 通常调用的方法。

### method EXISTS-POS



```
multi method EXISTS-POS (::?CLASS:D: $index)
```

Expected to return a Bool indicating whether or not there is an element at position `$index`. This is what [`postcircumfix [ ]`](`postcircumfix [ ]`) calls when invoked like `@foo[42]:exists`.

What "existence" of an element means, is up to your type.

If you don't implement this, your type will inherit the default implementation from `Any`, which returns True for 0 and False for any other index - which is probably not what you want. So if checking for element existence cannot be done for your type, add an implementation that [fail](fail)s or [die](die)s, to avoid silently doing the wrong thing.

### method DELETE-POS



```
multi method DELETE-POS (::?CLASS:D: $index)
```

Expected to delete the element at position `$index`, and return the value it had. This is what [`postcircumfix [ ]`](`postcircumfix [ ]`) calls when invoked like `@foo[42]:delete`.

What "deleting" an element means, is up to your type.

Implementing this method is optional; if you don't, users trying to delete elements from an object of this type will get an appropriate error message.

### method ASSIGN-POS



```
multi method ASSIGN-POS (::?CLASS:D: $index, $new)
```

Expected to set the element at position `$index` to the value `$new`. Implementing this is entirely optional; if you don't, `self.AT-POS($index) = $new` is used instead, and if you do, you should make sure it has the same effect.

This is meant as an opt-in performance optimization, so that simple assignments like `@numbers[5] = "five"` can operate without having to call `AT-POS` (which would have to create and return a potentially expensive container object).

Note that implementing `ASSIGN-POS` does *not* relieve you from making `AT-POS` an `rw` method though, because less trivial assignments/modifications such as `@numbers[5]++` will still use `AT-POS`.

### method BIND-POS



```
multi method BIND-POS (::?CLASS:D: $index, \new)
```

Expected to bind the value or container `new` to the slot at position `$index`, replacing any container that would be naturally found there. This is what is called when you write:

```
my $x = 10;
@numbers[5] := $x;
```

The generic [Array](Array) class supports this in order to allow building complex linked data structures, but for more domain-specific types it may not make sense, so don't feel compelled to implement it. If you don't, users will get an appropriate error message when they try to bind to a positional slot of an object of this type.

## Methods to implement for associative subscripting

In order to make key-based subscripting via [`postcircumfix { }`](`postcircumfix { }`) work for your custom type, you should implement at least `AT-KEY` and `EXISTS-KEY` - and optionally others as detailed below.

### method AT-KEY



```
multi method AT-KEY (::?CLASS:D: $key)
```

Expected to return the element associated with `$key`. This is what [`postcircumfix { }`](`postcircumfix { }`) normally calls.

If you want an element to be mutable (like they are for the built-in [Hash](Hash) type), you'll have to make sure to return it in the form of an item container that evaluates to the element's value when read, and updates it when assigned to. (Remember to use `return-rw` or the `is rw` routine trait to make that work; see the [example](example).)

On the other hand if you want your collection to be read-only, feel free to return non-container values directly.

### method EXISTS-KEY



```
multi method EXISTS-KEY (::?CLASS:D: $key)
```

Expected to return a Bool indicating whether or not there is an element associated with `$key`. This is what [`postcircumfix { }`](`postcircumfix { }`) calls when invoked like `%foo<aa>:exists`.

What "existence" of an element means, is up to your type.

If you don't implement this, your type will inherit the default implementation from `Any`, which always returns False - which is probably not what you want. So if checking for element existence cannot be done for your type, add an implementation that [fail](fail)s or [die](die)s, to avoid silently doing the wrong thing.

### method DELETE-KEY



```
multi method DELETE-KEY (::?CLASS:D: $key)
```

Expected to delete the element associated with `$key`, and return the value it had. This is what [`postcircumfix { }`](`postcircumfix { }`) calls when invoked like `%foo<aa>:delete`.

What "deleting" an element means, is up to your type - though it should usually cause `EXISTS-KEY` to become `False` for that key.

Implementing this method is optional; if you don't, users trying to delete elements from an object of this type will get an appropriate error message.

### method ASSIGN-KEY



```
multi method ASSIGN-KEY (::?CLASS:D: $key, $new)
```

Expected to set the element associated with `$key` to the value `$new`. Implementing this is entirely optional; if you don't, `self.AT-KEY($key) = $new` is used instead, and if you do, you should make sure it has the same effect.

This is meant as an opt-in performance optimization, so that simple assignments `%age<Claire> = 29` can operate without having to call `AT-KEY` (which would have to create and return a potentially expensive container object).

Note that implementing `ASSIGN-KEY` does *not* relieve you from making `AT-KEY` an `rw` method though, because less trivial assignments/modifications such as `%age<Claire>++` will still use `AT-KEY`.

### method BIND-KEY



```
multi method BIND-KEY (::?CLASS:D: $key, \new)
```

Expected to bind the value or container `new` to the slot associated with `$key`, replacing any container that would be naturally found there. This is what is called when you write:

```
my $x = 10;
%age<Claire> := $x;
```

The generic [Hash](Hash) class supports this in order to allow building complex linked data structures, but for more domain-specific types it may not make sense, so don't feel compelled to implement it. If you don't, users will get an appropriate error message when they try to bind to an associative slot of an object of this type.


