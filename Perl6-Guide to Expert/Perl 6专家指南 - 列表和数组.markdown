# Perl 6专家指南 -> 列表和数组
> 分类: Perl6

## List Literals, list ranges
括号()中用逗号分隔的东西叫做列表。实际上你甚至不需要括号。 列表就是一组有序的标量值。例子:

## examples/arrays/list_literals.p6
```perl
#!/usr/bin/env perl6
use v6;

(1, 5.2, "apple");          # 3 values

(1,2,3,4,5,6,7,8,9,10);     # 很好但是我们很懒，所以我们这样写：:
(1..10);                    # 与(1,2,3,4,5,6,7,8,9,10)一样
(1..Inf);                   # represents the list of all the numbers
(1..*);                     # this too

("apple", "banana", "peach", "blueberry");   # is the same as
<apple banana peach blueberry>;               # quote word

my ($x, $y, $z);            # 我们也能使用标量变量作为列表的元素
```
在大多数情况下，我们实际上甚至不需要括号.

列表赋值
```perl 
  my ($x, $y, $z);
  ($x, $y, $z) = f();   # 如果 f() 返回 (2, 3, 7) 则它几乎与$x=2; $y=3; $z=7;相同
  ($x, $y, $z) = f();   # 如果 f() 返回 (2, 3, 7, 9), 则忽略 9
  ($x, $y, $z) = f();   # 如果 f() 返回 (2, 3); 则 $z 是 undef
```
我们怎么交换两个变量的值，比如说 $x 和 $y?

## 交换两个值
### examples/arrays/lists.p6
```perl
#!/usr/bin/env perl6
use v6;

say "Type in two values:";
my $a = $*IN.get;
my $b = $*IN.get;

($a, $b) = ($b, $a);
say $a;
say $b;
```
用for循环遍历列表的元素
## examples/arrays/arrays.p6
```perl
#!/usr/bin/env perl6
use v6;

for "Foo", "Bar", "Baz" -> $name {
    say $name;
}

say "---";

for 1..5 -> $i {
    say $i;
}

say "---";

for 1..Inf -> $i {
    say $i;
    last if $i > 3;
}

say "---";

for 1..* -> $i {
    say $i;
    last if $i > 3;
}
```
创建数组, 遍历数组
 
你可以给一列值赋值给数组。
在双引号中数组不会进行插值。这与Perl 5 不一样。

就像你看见的，列表周围的括号是可选的。
## examples/arrays/list_colors_array.p6
```perl
#!/usr/bin/env perl6
use v6;

my @colors = "Blue", "Yellow", "Brown", "White";  # 列表周围的括号是可选的
say @colors;

say "--------------------------------";               # just for separation...
say "@colors";      # 没有被插值!

say "--------------------------------";               # just for separation...

say "{@colors}";

say "--------------------------------";               # just for separation...

say "@colors[]"; # 禅切

say "--------------------------------";               # just for separation...

for @colors -> $color {
    say $color;
}
```
Output:

```perl
  Blue Yellow Brown White
  --------------------------------
  Blue Yellow Brown White
  --------------------------------
  Blue
  Yellow
  Brown
  White
 ```
 ##  数组元素 (create menu)
### examples/arrays/color_menu.p6
```perl
#!/usr/bin/env perl6
use v6;

my @colors = <Blue Yellow Brown White>;
for 1..@colors.elems -> $i {
    say "$i) @colors[$i-1]";
}

my $input = prompt("Please select a number: ");
say "You selected @colors[$input-1]";
```
## 数组赋值
### examples/arrays/array_assignment.p6
```perl
#!/usr/bin/env perl6
use v6;

my $owner = "Moose";
my @tenants = "Foo", "Bar";
my @people = ($owner, 'Baz', @tenants);   # 数组被展开:
say "{@people}";                         # Moose Baz Foo Bar

my ($x, @y)     = (1, 2, 3, 4); 
say $x;                               # $x = 1
say "{@y}";                           # @y = (2, 3, 4)
```
## 命令行选项
@*ARGS 数组由语言维护，它存储着命令行的值。
### examples/arrays/color_menu_option.p6
```perl
#!/usr/bin/env perl6
use v6;

my $color = @*ARGS[0];
if not $color {
    my @colors = <Blue Yellow Brown White>;
	
    for 1 .. @colors.elems -> $i {
        say "$i) @colors[$i-1]";
    }

    my $input = prompt "Please select a number: ";
    $color = @colors[$input-1];
}
say "You selected $color";
```

## 处理 CSV 文件
### examples/arrays/sample_csv_file.csv
'''perl 
Foo,Bar,10,home
Orgo,Morgo,7,away
Big,Shrek,100,US
Small,Fiona,9,tower
``` 
### examples/arrays/process_csv_file.p6
```perl
#!/usr/bin/env perl6
use v6;

my $file = 'examples/arrays/sample_csv_file.csv';
if defined @*ARGS[0] {
    $file = @*ARGS[0];
}

my $sum = 0;
my $data = open $file;
for $data.lines -> $line {
    my @columns = split ",", $line;
    $sum += @columns[2];
}
say $sum;
```
## join
### examples/arrays/join.p6
```perl
#!/usr/bin/env perl6
use v6;

my @fields = <Foo Bar foo@bar.com>;
my $line = join ";", @fields;
say $line;     # Foo;Bar;foo@bar.com
```
##  uniq 函数
### examples/arrays/unique.p6
```perl
#!/usr/bin/env perl6
use v6;

my @duplicates = 1, 1, 2, 5, 1, 4, 3, 2, 1;
say @duplicates.perl;
# prints Array.new(1, 1, 2, 5, 1, 4, 3, 2, 1)

my @unique = uniq @duplicates;
say @unique.perl;
# prints Array.new(1, 2, 5, 4, 3)

my @chars = <b c a d b a a a b>;
say @chars.perl;
# prints Array.new("b", "c", "a", "d", "b", "a", "a", "a", "b")

my @singles = uniq @chars;
say @singles.perl;
# prints Array.new("b", "c", "a", "d")
```
Looping over a list of values one at a time, two at a time and more
In Perl 6 the standard way to iterate over the elements of a list or an array is by using the "for" statement. A simple version of it looks like this: This will print out the three values one under the other. As an explanation syntax: @fellows is an array with 3 elements in it. The loop variable ($name) in the above case is automatically declared in the loop so one does not need to declare it using "my" and it is still not global. It is scoped to the block of the loop.
### examples/arrays/loop_over_array.p6
```perl
#!/usr/bin/env perl6
use v6;

my @fellows = <Foo Bar Baz>;
for @fellows -> $name {
    say $name;
}
```

## Looping over any number of elements
You can also iterate over any number of elements: Let's say we just extracted the results of the Spanish Liga football games from the soccer website http://soccernet.espn.go.com/ . Those come in groups of 4 values: home team, score of home team score of guest team guest team We can loop over the values using a for statement with 4 scalar variables:
### examples/arrays/looping_over_many_elements.p6
```perl
#!/usr/bin/env perl6
use v6;

my @scores = <
    Valencia   1 1 Recreativo_Huelva
    Athletic_Bilbao 2 5 Real_Madrid
    Malaga       2   2       Sevilla_FC
    Sporting_Gijon   3 2 Deportivo_La_Coruna
    Valladolid     1   0     Getafe
    Real_Betis     0   0     Osasuna
    Racing_Santander     5   0     Numancia
    Espanyol     3   3     Mallorca
    Atletico_Madrid     3   2     Villarreal
    Almeria     0   2     Barcelona
>;

for @scores -> $home, $home_score, $guest_score, $guest {
    say "$home $guest $home_score : $guest_score";
}
```
### 缺失值
One should ask the question what happens if the list runs out of values in the middle, of a multi-value iteration? That is, what happens to the follow loop?
### examples/arrays/missing_values.p6
```perl
#!/usr/bin/env perl6
use v6;

for (1, 2, 3, 4, 5) -> $x, $y {
    say "$x $y";
}
say 'done';
```
In this case Rakudo throws an exception when it finds out it does not have enough values for the last iteration. It will look like this, (with a bunch of trace information afterwards).

### examples/arrays/missing_values.p6.output
```perl
1 2
3 4
```
Not enough positional parameters passed; got 1 but expected 2
  in block <anon> at examples/arrays/missing_values.p6:4
In order to avoid the exception we could tell the loop that the second and subsequent values are optional by adding a question mark after the variable


### examples/arrays/missing_values_fixed.p6
```perl
#!/usr/bin/env perl6
use v6;

for (1, 2, 3, 4, 5) -> $x, $y? {
    say "$x $y";
}
say 'done';
```
This will work but generate the following output:

### examples/arrays/missing_values_fixed.p6.output
```perl
1 2
3 4
```
use of uninitialized value of type Mu in string context
    in block <anon> at examples/arrays/missing_values_fixed.p6:5
5
done


Iterating over more than one array in parallel
In the next example I'd like to show a totally different case. What if you have two (or more) array you'd like to combine somehow? How can you go over the elements of two arrays in parallel?


### examples/arrays/z.p6
```perl
#!/usr/bin/env perl6
use v6;

my @chars   = <a b c>;
my @numbers = <1 2 3>;

for @chars Z @numbers -> $letter, $number {
    say "$letter $number";
}
```
Output:
```perl
examples/arrays/z.p6.out
a 1
b 2
c 3
```

## Z as in zip
The Z infix operator version of the zip function allows the parallel use of two lists.

Or that of more:

### examples/arrays/z_on_more.p6
```perl
#!usr/bin/env perl6
use v6;

my @operator   = <+ - *>;
my @left       = <1 2 3>;
my @right     = <7 8 9>;

for @left Z @operator Z @right -> $a, $o, $b {
    say "$a $o $b";
}
```
Output:
```perl
examples/arrays/z_on_more.p6.out
1 + 7
2 - 8
3 * 9
```
## xx - string multiplicator
### examples/arrays/xx.p6
```perl
#!/usr/bin/env perl6
use v6;

my @moose = "moose" xx 3;
say "{@moose}";
```
## sort values
### examples/arrays/sort.p6
```perl
#!/usr/bin/env perl6
use v6;

my @names = <foo bar moose bu>;
my @sorted_names = sort @names;
say @sorted_names.perl;   # ["bar", "bu", "foo", "moose"]
my @numbers = 23, 17, 4;
my @sorted_numbers = sort @numbers;
say @sorted_numbers.perl;   # [4, 17, 23]

my @sort_names_by_length = sort { $^a.bytes <=> $^b.bytes }, @names;
say @sort_names_by_length.perl;   # ["bu", "bar", "foo", "moose"]

# the same result with one sub (Schwartizian transformation)
my @sort_1 = sort { $_.bytes }, @names;
say @sort_1.perl;     # ["bu", "bar", "foo", "moose"]

my @sort_2 = @names.sort({ $_.bytes });
say @sort_2.perl;     # ["bu", "bar", "foo", "moose"]

my @sort_3 = @names.sort: { $_.bytes };
say @sort_3.perl;     # ["bu", "bar", "foo", "moose"]

my @words = <moo foo bar moose bu>;
say @words.sort({ $^a.bytes <=> $^b.bytes}).perl; # ["bu", "moo", "foo", "bar", "moose"];

say @words.sort({ $^a.bytes <=> $^b.bytes or $^a cmp $^b}).perl; # ["bu", "bar", "foo", "moo", "moose"];

# TODO: should be also:
# say @words.sort({ $^a.bytes <=> $^b.bytes }, {$^a cmp $^b}).perl; # ["bu", "bar", "foo", "moo", "moose"];
# say @words.sort({ $_.bytes },   {$^a cmp $^b}).perl; # ["bu", "bar", "foo", "moo", "moose"];
```