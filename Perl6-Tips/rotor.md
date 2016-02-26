title: rotor
date: 2015-07-15 12:59:26
tags: Perl6
categories: Perl 6
---

<blockquote class="blockquote-center">左眼没有见过右眼一面。不懂安慰，只懂陪它落泪</blockquote>

```perl
method rotor(*@cycle, Bool() :$partial)
```

rotor 返回一个 list, 这个 list 的元素也是 list,  其中每个子列表由调用者中的元素组成.  在最简单的情况下, @cycle 只包含一个整数, 这时调用者列表被分割为多个子列表, 每个子列表中的元素尽可能多的为那个整数指定的个数. 如果 `:$partial` 为 True, 不够分的最后那部分也会被包括进去, 即使它不满足长度的要求:

```perl
say ('a'..'h').rotor(3).join('|');              # a b c|d e f
say ('a'..'h').rotor(3, :partial).join('|');    # a b c|d e f|g h
```

如果 @cycle 的元素是一个  /type/Pair, 则 pair 的键指定了所返回子列表的长度(即每个子列表中含有的元素数), pair 的键值指定两个列表之间的间隙; 负的间隙会产生重叠:

```perl
say ('a'..'h').rotor(2 =>  1).join('|');         # a b|d e|g h
say ('a'..'h').rotor(3 => -1).join('|');         # a b c|c d e|e f g

> my $pair  = 2 => 1;
> my $key   = $pair.key;
> my $value = $pair.value;
> say ('a'..'h').rotor($key => $value).join('|') # a b|d e|g h
```

如果 @cycle 的元素个数大于 1 时,  rotor 会按 @cycle 中的元素依次循环调用者列表, 得到每个子列表:

```perl
say ('a'..'h').rotor(2, 3).join('|');           # a b|c d e|f g
say ('a'..'h').rotor(1 => 1, 3).join('|');      # a|c d e|f
```

组合多个循环周期 和 :partial 也有效:

```perl
say ('a'..'h').rotor(1 => 1, 3 => -1, :partial).join('|');   # a|c d e|e|g h
```

注意, 从 rotor 函数返回的一列列表们赋值给一个变量时会展开为一个数组:

```perl
my @maybe_lol = ('a'..'h').rotor(2 => 1);
@maybe_lol.perl.say;   #  ["a", "b", "d", "e", "g", "h"]<>
```

这可能不是你想要的, 因为 rotor 之后的输出看起来是这样的:

```perl
say ('a'..'h').rotor(2 => 1).perl; # (("a", "b"), ("d", "e"), ("g", "h"))
```

要强制返回列表的列表, 使用绑定而非赋值:

```perl
my @really_lol := ('a'..'h').rotor(2 => 1);
@really_lol.perl.say;   # (("a", "b"), ("d", "e"), ("g", "h"))
```


例子:

[Sliding Window Maximum ](https://leetcode.com/problems/sliding-window-maximum/)

Given an array nums, there is a sliding window of size k which is moving from the very left of the array to the very right. You can only see the k numbers in the window. Each time the sliding window moves right by one position.

For example,
Given nums = [1,3,-1,-3,5,3,6,7], and k = 3.


```perl
Window position                Max
---------------               -----
[1  3  -1] -3  5  3  6  7       3
 1 [3  -1  -3] 5  3  6  7       3
 1  3 [-1  -3  5] 3  6  7       5
 1  3  -1 [-3  5  3] 6  7       5
 1  3  -1  -3 [5  3  6] 7       6
 1  3  -1  -3  5 [3  6  7]      7
```

Therefore, return the max sliding window as [3,3,5,5,6,7].

Note: 
You may assume k is always valid, ie: 1 ≤ k ≤ input array's size for non-empty array.

Solution:

Perl 6:
my @a = 1,3,-1,-3,5,3,6,7;
[max]($_).say for @a.rotor(3 => -2);