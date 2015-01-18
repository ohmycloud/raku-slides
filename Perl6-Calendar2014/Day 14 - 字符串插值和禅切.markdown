# Day 13 – 字符串插值和禅切

by liztormato

那你知道了 Perl 6 中字符串插值的所有东西了?
好吧, 特别是来自 Perl 5 的人, 可能发现有些东西并不起作用.简单的例子都能工作,就像这样:
```perl
my $a = 42;
say 'value = $a'; # value = $a
say "value = $a"; # value = 42

my @a = ^10;
say 'value = @a'; # value = @a
say "value = @a"; # value = @a HUH??
```
在早期的 Perl 5 版本(或者 Perl 4?) 这会得出同样的结果. 数组同样在双引号中被插值.然而,这在含有 Email 地址的文本字符串中会引起一些问题: 你需要转义每一个 @
所以, 我们怎样让这在 Perl 6 中起作用呢?

## 禅切
禅切作用于对象上, 并返回对象. 就像你什么都不要,却得到了所有. 那他看起来像什么?

```perl
my @a = ^10;
say "value = @a[]"; # value = 0 1 2 3 4 5 6 7 8 9
```
You will have to make sure that you use the right indexers for the type of variable that you’re interpolating.
你必须确保你正在插值的变量类型使用了正确的索引.
```perl
my %h = a => 42, b => 666;
say "value = %h{}"; # value = a 42 b 666
```
Note that the Zen slice on a hash returns both keys and values, whereas the Zen slice on an array only returns the values. This seems inconsistent, until you realize that you can think of a hash as a list of Pairs.
注意作用于散列上的禅切返回了 
The Zen slice only really exists at compile time. So you will not get everything if your slice specification is an empty list at runtime:
禅切真正存在于编译时, 所以在运行时
my @a;
my %h = a => 42, b => 666;
# a slice, but not a Zen slice:
say "value = %h{@a}"; # value =

So the only way you can specify a Zen slice, is if there is nothing (but whitespace) between the slice delimiters.

The Whatever slice

The * ( Whatever ) slice is different. The Whatever will just fill in all keys that exist in the object, and thus only return the values of a hash.

my %h = a => 42, b => 666;
say "value = %h{*}"; # value = 42 666

For arrays, there isn’t really any difference at the moment (although that may change in the future when multi-dimensional arrays are fleshed out more).

Interpolating results from subs and methods

In double quoted strings, you can also interpolate subroutine calls, as long as they start with an ‘&‘ and have a set of parentheses (even if you don’t want to pass any arguments):

sub a { 42 }
say "value = &a()"; # value = 42

But it doesn’t stop at calling subs: you can also call a method on a variable as long as they have parentheses at the end:

my %h = a => 42, b => 666;
say "value = %h.keys()"; # value = b a

And it doesn’t stay limited to a single method call: you can have as many as you want, provided the last one has parentheses:

my %h = a => 42, b => 666;
say "value = %h.perl.EVAL.perl.EVAL.perl()"; # value = ("b" => 666, "a" => 42).hash

Interpolating expressions

If you want to interpolate an expression in a double quoted string, you can also do that by providing an executable block inside the string:

say "6 * 7 = { 6 * 7 }"; # 6 * 7 = 42

The result of the execution of the block, is what will be interpolated in the string. Well, what really is interpolated in a string, is the result of calling the .Str method on the value. This is different from just saying a value, in which case the .gist method is called. Suppose we have our own class with its own .gist and .Str methods:

class A {
    method Str { "foo" }
    method gist { "bar" }
}
say "value = { A }"; # value = foo
say "value = ", A;   # value = bar

Conclusion

String interpolation in Perl 6 is very powerful. As you can see, the Zen slice makes it easy to interpolate whole arrays and hashes in a string.

In this post I have only scratched the surface of string interpolation. Please check out Quoting on Steroids in a few days for more about quoting constructs.