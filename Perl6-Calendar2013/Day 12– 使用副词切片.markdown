Day 12 – Slicing with adverbs, the only way! By   Liztormato


在散列切片和数组切片中你能使用哪些 副词 呢？ 名称 描述
 :exists 元素是否存在
 :delete 移除元素，返回真，如果有元素被移除的话
 :kv 将键和值作为Parcel返回
 :p return  key(s) and value(s)  as Parcel of Pairs
 :k  只返回键
 :v  只返回值
:exists

这个副词代替 .exists方法。 副词为散列和数组提供了统一的接口，可以一次检查多个元素。 .exists方法只允许一次检查单个键。

例子更有说服力。检查单个键是否存在：
$ perl6 -e 'my %h = a=>1, b=>2; say %h<a>:exists’
True

如果我们将这扩展到切片上，我们会得到一堆布尔值
$ perl6 -e 'my %h = a=>1, b=>2; say %h<a b c>:exists'
True True False
返回结果是 （Parcel）

注意，如果我们仅仅请求一个键，我们取回的是一个布尔值，不是一个只含一个布尔值的Parcel.
$ perl6 -e 'my %h = a=>1, b=>2; say (%h<a>:exists).WHAT’
(Bool)

如果很清楚地知道我们是在处理多个键，或者在编译时不清楚我们仅仅处理单个键，我们得到 一个 Parcel：
$ perl6 -e 'my %h = a=>1, b=>2; say (%h<a b c>:exists).WHAT’
(Parcel)
$ perl6 -e 'my @a="a"; my %h = a=>1, b=>2; say (%h{@a}:exists).WHAT'
(Parcel)

有时，知道某些东西不存在更方便。你可以很方便的在副词前面前置一个 叹号 ! 来反转副词 ，无论如何，它们其实真的很像具名参数
$ perl6 -e 'my %h = a=>1, b=>2; say %h<c>:!exists'
True :delete

只有这个副词能改变散列或数组，它代替的是 .delete方法
$ perl6 -e 'my %h = a=>1, b=>2; say %h<a>:delete; say %h.perl'
1
("b" => 2).hash

当然，你也可以删除切片
$ perl6 -e 'my %h = a=>1, b=>2; say %h<a b c>:delete; say %h.perl'
1 2 (Any)
().hash

注意对于一个不存在的值会返回 (Any)，如果你碰巧给定散列一个默认的值，它会长这样：
$ perl6 -e 'my %h is default (42) = a=>1, b=>2; say %h<a b c>:delete; say %h.perl'
1 2 42
().hash

像:exists 一样，你可以反转 :delete副词，但是没有太多意义。因为副词本质上是具名参数，你可以让:delete属性带条件参数。
$ perl6 -e 'my $really = True; my %h = a=>1, b=>2; say %h<a b c>:delete($really); say %h.perl'
1 2 (Any)
().hash

因为传递给副词的值是真的，删除才真正发生。然而，如果你传递一个假值：
$ perl6 -e ‘my $really; my %h = a=>1, b=>2; say %h<a b c>:delete($really); say %h.perl'
1 2 (Any)
("a" => 1, "b" => 2).hash

它没有删除。注意返回值没有变化。删除操作就没有执行。如果你使用子例程或方法处理一些常规的切片，这会很方便，并且，你想用一个可选参数表明切片是否也被删除：仅仅将参数传递为副词的参数！ :kv, :p, :k, :v

kv 属性返回键值对，  :p属性返回一对Parcel， :k 和 :v属性只返回键和值
$ perl6
> my %h = a => 1, b => 2;
("a” => 1, "b” => 2).hash
> %h<a> :kv
a 1
> %h<a> :p  # 注意:p 返回的是 Parcel
"a" => 1
> %h<a> :k
a
> %h<a> :v
1

注意下面返回值的不同
> %h<a b c>
1 2 (Any)
> %h<a b c> :v
1 2

因为 :v 属性起着 过滤 的作用，过滤掉 Any. 但是，有时候你不需要这种行为。反转那个属性就可以达到目的：
> %h<a b c>:k
a b
> %h<a b c>: !k
a b c 将副词组合在一块

你也可以将几个副词 结合 在一块作用到 散列或切片上。最有用的组合是用 :exist 和:delete中的一个或两个，结合   :kv, :p, :k, :v中的其中之一。一些例子，例如将散列中的切片放到另外一个散列中：

$ perl6 -e 'my %h = a=>1, b=>2; my %i = (%h<a c>:delete :p ) .list ; say %h.perl; say %i.perl'  # delete返回删除的东西
("b” => 2).hash
("a” => 1).hash

下面返回的是删除掉的键：
$ perl6 -e 'my %h = a=>1, b=>2; say %h<a b c>:delete:k’
a b 数组不是散列

在数组中，元素的键是数组的索引，所以，显示数组中定义有值的元素的索引，我们可以使用 :k属性
$ perl6 -e 'my @a; @a[3] = 1; say @a[]:k'
3

或使用数组中的所有元素创建一个 Parcel：
$ perl6 -e 'my @a; @a[3] = 1; say @a[]:!k’
0 1 2 3

然而，从数组中删除一个元素，和把 Nil 赋值给它类似，所以它会返回它默认的值（通常是 (Any))



> my @a=^10;

0 1 2 3 4 5 6 7 8 9
$ perl6 -e 'my @a = ^10; @a[3]:delete; say @a[2,3,4]; say @a[2,3,4]:exists'
2 (Any) 4
True False True

如果我们给数组指定了默认值，结果会稍有不同：
$ perl6 -e 'my @a is default (42) = ^10; @a[3]:delete; say @a[2,3,4]; say @a[2,3,4]:exists'
2 42 4
True False True

所以，即使元素不存在了，它也能返回一个定义好的值 总结

要习惯副词切片。

来源： < http://perl6advent.wordpress.com/2013/12/12/day-12-slicing-with-adverbs-the-only-way/ >  