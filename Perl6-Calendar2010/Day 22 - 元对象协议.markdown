

2010 年 Perl6 圣诞月历(廿二)元对象协议

你有没有想过用你最爱的编程语言写一个类——但是不是按部就班的写类定义，而是通过几行代码？有些语言提供了 API 来完成这个功能。这些 API 的后面，就是元对象协议( Meta-Object Protocol )，简称 MOP 。

Perl6 就有 MOP ，你可以自己创建类、角色、语法，添加方法和属性，并且内省类。比如我们可以调用 MOP 查看 Rakudo 是如何实现 Rat 类型（有理数）的。调用 MOP ，只要把一般的 . 换成 .^ 就可以了。

$ perl6
> say join ', ', Rat.^attributes
$!numerator, $!denominator
> # 列出全部方法比较多，所以随机选几个
> say join ', ', Rat.^methods(:local).pick(5)
unpolar, ceiling, reals, Str, round
> say Rat.^methods(:local).grep('log').[0].signature.perl
:(Numeric $x: Numeric $base = { ... };; *%_)

显示出来的这几行信息相信都是不言自明了。Rat 有两个属性， $!numerator 和 $!denominator ；有很多方法，其中 log 方法可接受的第一个变量是数值型 invocant (译者注：不知道怎么翻译，反正就是对象本身的引用 $_[0] )，用冒号标记过；第二个变量参数是可选的，名字是 $base ，它设有一个默认值，不过 Rakudo 不打算告诉你……

Perl6 的数据库接口代码里有一个很不错的使用实例。它有一个选项用来记录对象的调用，但是只是记录一部分特定角色（比如和连接管理或者数据检索有关的）。下面是 dbi 里的代码：

sub log-calls($obj, Role $r) {
     my $wrapper = RoleHOW.new;
     for $r.^methods -> $m {
         $wrapper.^add_method($m.name, method (|$c) {
             # 打印日志信息，note() 函数输出到标准错误
             note ">> $m";
             nextsame;
         });
     }
     $wrapper.^compose();
     # does 操作符和 but 类似，不过只修改一个对象的拷贝
     $obj does $wrapper;
}
role Greet {
     method greet($x) {
         say "hello, $x";
     }
}
class SomeGreeter does Greet {
     method LOLGREET($x) {
         say "OH HAI "~ uc $x;
     }
}
my $o = log-calls(SomeGreeter.new, Greet);
# 记录日志啦，因为由 Greet 角色提供了
$o.greet('you');
# 没记录，因为没角色提供这个
$o.LOLGREET('u');

运行结果如下：

>> greet
hello, you
OH HAI U

所以说，有了 MOP ，除了指定的语法，你还可以像普通接口一样访问类、角色、语法和属性。这给了面向对象更大的灵活性，可以轻松的内省和修改对象了。

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2010/%E7%AC%AC%E5%BB%BF%E4%BA%8C%E5%A4%A9:%E5%85%83%E5%AF%B9%E8%B1%A1%E5%8D%8F%E8%AE%AE.markdown >  