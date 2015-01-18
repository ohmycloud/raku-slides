美丽的参数 (arguments and parameters)
分类: Perl6
日期: 2013-05-18 23:33
原文地址: http://blog.sina.com.cn/s/blog_6c9ce1650101cbah.html
美丽的参数 (arguments and parameters)
扶 凯 2011年12月22日 - 15:23 0
By carl
   
在第９天的 advent 中…我打开了　…这是有关 parameters 和 arguments
你也许了解或者不了解 Perl5 的 是怎么处理函数参数的.先让你看看,它通常象下面的这个例子这样：




sub sum {
    [+] @_
}
say sum 100, 20, 3; # 123
这个 [+] 是在 Perl 6 中的,但我们也可以写成 Perl 5 风格的 my $i = 0; $i _= $_ for @_; $i.
我们要想到上面这些区别,这些在 Perl 6 中非常重要,也就是为什么我们讲 Perl 6 比 Perl 5 好.当你调用函数时.你可以从 @_ 找到你的参数.你然后取出它们来做一些操作.
这是非常灵活的.因为它不会对参数做任何默认的处理,程序会全部传给你来进行处理.当然这也同样是令人厌烦因为样样都要自己处理,但很方便我们来进行扩展进行参数的检查,看下面这个虚构的例子.








sub grade_essay {
  my ($essay, $grade) = @_;
  die 'The first argument must be of type Essay'
    unless $essay ~~ Essay;
  die 'The second argument must be an integer between 0 and 5'
    unless $grade ~~ Int && $grade ~~ 0..5;
 
  %grades{$essay} = $grade;
}
(如果在 Perl 5 中,你需要使用 isa 来替换　~~　和使用 %grades 来替换成 $grades 才能正常工作.除了这些,都在 Perl6 中工作)


现在,这一刻,看看上面的内容,看到手册中的参数验证的实现,你是不是开始有点绝望吗？你感觉到了吧？好.
在 Perl 5 中的解决方法是使用优秀的 CPAN 模块,象 Sub::Signatures 和 MooseX::Declare,然后在你的程序中使用这些模块,并按照模块设置就行了.


在 Perl 6 的中的解决方法是,给你参数设置默认范围. 我在想看了下面这些时, “请确保键盘前的你不会流口水”.在 Perl 6 中,我会写这样来写子函数：




sub grade_essay(Essay $essay, Int $grade where 0..5) {
  %grades{$essay} = $grade;
}
现在我们见到,在这程序运行会对这个长版本的参数进行检查,没有必要在导入其它的 CPAN 的模块了.


有时,我们可以提供一些默认的值给参数：




sub entreat($message = 'Pretty please, with sugar on top!', $times = 1) {
    say $message for ^$times;
}
如果这些参数的默认的值是不固定的,可以使用老的方式来传参数.




sub xml_tag ($tag, $endtag = matching_tag($tag) ) {...}
如果您的参数是不确定的,对这种可选的参数可以加一个 ? 的标记.




sub deactivate(PowerPlant $plant, Str $comment?) {
  $plant.initiate_shutdown_sequence();
  say $comment if $comment;
}
有一个特性,我特别喜欢,我们可以在调用时通过参数名字来引用参数,这样你可以以喜欢的任何顺序传递命名参数.这样会永远记得在这个函数中参数本来的顺序：




sub draw_line($x1, $y1, $x2, $y2) { ... }
 
draw_line($x1, $y1, $x2, $y2); # phew. got it right this time.
draw_line($x1, $x2, $y1, $y2); # dang! :-/
这的方法是引用参数的名字,来使得这个问题被解决：






draw_line(:x1($x1), :y1($y1), 2($x2), :y2($y2)); # works
draw_line(:x1($x1), 2($x2), :y1($y1), :y2($y2)); # also works!
冒号的意思是 "这来自命名参数", 整个结构读作:name_of_parameter($variable_passed_in).这可以使用的参数和变量具有相同的名称,但有一个简短形式：






draw_line(:$x1, :$y1, :$x2, :$y2); # works
draw_line(:$x1, :$x2, :$y1, :$y2); # also works!
我喜欢短形式.我觉得它使我的代码更具可读性.


如果作为 API 的作者,要强迫别人使用命名参数 – 例如还是在 draw_line 的情况下 – 你只需要提供在子程序参数前的冒号.




sub draw_line(:$x1, :$y1, :$x2, :$y2 ) { ... } # optional nameds
但要小心注意,命名参数默认是可选的.换句话说,上述内容相当于：




sub draw_line(:$x1?, :$y1?, :$x2?, :$y2?) { ... } # optional nameds
如果你想明确地指出必需的参数,可以追加！对下面的这些参数：




sub draw_line(:$x1!, :$y1!, :$x2!, :$y2!) { ... } # required nameds
现在调用这个,就像他们是普通的顺序位置参数传递进来.


关于可变参数呢？假如你想传递的参数是不确认多少个数量,比如参数是数组,可以在它前面带有“*”：




sub sum(*@terms) {
  [+] @terms
}
say sum 100, 20, 3;   # 123
我使用同样的例子来提出一个观点：当你不提供任何符号到您的子程序时,你最终是得到的符号其实是是 *@_ .这是模拟 Perl 5 中的行为.


但数组前面的 * 号是仅用来捕获的位置参数(positional arguments).如果你想捕捉命名参数(named arguments),你要使用 “slurpy hash”：




sub detect_nonfoos(:$foo!, *%nonfoos) {
  say "Besides 'foo', you passed in ", %nonfoos.keys.fmt("'%s'", ', ');
}
 
detect_nonfoos(:foo(1), :bar(2), :baz(3));
# Besides 'foo', you passed in 'bar', 'baz'
哦,这可能是一个很好的通过以命名的参数传递哈希的方法,像这样：






detect_nonfoos(foo => 1, bar => 2, baz => 3);
# Besides 'foo', you passed in 'bar', 'baz'
这里的 Perl 5 中的一个重要区别：默认参数是只读的：




sub increase_by_one($n) {
  ++$n
}
 
my $value = 5;
increase_by_one($value); # boom
在这让参数只读,主要有两个原因,其一为了效率.当变量只读时可以使其最佳化,其二要鼓励程序员写程序时有个正确的习惯,只会有一点点不习惯.
所以这个功能不仅是为优化好,更是为了让你有个更好的灵魂.


下面是你需要做的工作：




sub increase_by_one($n is rw) {
    ++$n
}
 
my $value = 5;
say increase_by_one($value); # 6
有时可能你想让你的这个参数可以读写(RW),但是有时你可能更想修改传进来的参数复本.当你想使用这个 copy 时:






sub format_name($first, $middle is copy, $last) {
    $middle .= substr(0, 1);
    "$first $middle. $last"
}
原内容将保持不变.


在 Perl 6 中,当传递一个数组或哈希时,默认情况下它并不会给数组和哈希拉平成几个参数.相反,当你想让参数扁平化时可以使用"|".




sub list_names($x, $y, $z) {
    "$x, $y and $z"
}
 
my @ducklings = ;
try {
    list_names(@ducklings);
}
say $!; # 'Not enough positional parameters passed;
# got 1 but expected 3'
say list_names(|@ducklings); # 'huey, dewey and louie'
同样,如果扁平化一个哈希,其参数内容将作为命名的参数(named arguments)发送到函数.


正如您传送数组和哈希一样,你也可以传送代码块：












sub traverse_inorder(TreeNode $n, &action) {
    traverse_inorder($n.left, &action) if $n.left;
    action($n);
    traverse_inorder($n.right, &action) if $n.right;
}
下面前三个印记符号(@ % & )其实是类型约束：


@ Array (actually, Positional)
% Hash (actually, Associative)
& Code (actually, Callable)


$ 的印记是工作在不受约束的版本.


当心！常出的简单的小陷阱是人们常常落入指定类型约束两次,还都是同一个类型：








sub f(Array @a) { ... } # WRONG, unless you mean Array of Array
sub f( @a) { ... } # probably what you meant
sub f(Int @a) { ... } # Array of Int
你学到这,你应得的另一个 Perl6 单行…




$ perl6 -e '.fmt("%b").trans("01" => " #").say for <734043054508967647390469 416144647854399310>.comb(/.**7/)'
###           ##   ###
# #   ##   # ##   #   #    
### #   # ##     #   ####
#   #### #     #   #   #
#   #     #     #   #   #
#     ##   #     ##   ###H