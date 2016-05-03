# Perl 6 Coobook

## 第一章 字符串

## 第四章 数组

### 4.1 在你的程序中指定一个数组

你想在程序中包括进一个列表。

```perl6
my @a = ("quick", "brown", "fox");                   # 括号不是必须的
my @a = qw/Meddle not in the affairs of wizards./;   # qw 操作符

my @banner = ('Costs', 'only', '$4.95'); 
my @banner = qw(Costs only $4.95); # 和上面的等价
 
```

### 4.2 打印带有逗号的列表

你想打印一个包含未知个数元素的列表，在最后一个元素的前面放上一个 "and", 在每个元素之间放上逗号，如果元素多于 2 个的话。

```perl6
my @array = ("red", "yellow", "green");
```

你真正要得到的是 "I have red, yellow, and green marbles"。

```perl6
sub commify_series(@a) {               
  given @a.elems {
    when 0 { '' }
    when 1 { @a }
    when 2 { join(" and ", @a) }
    default { join(", ", @a[0 .. *-2]), "and @a[*-1]"}
  }
} 

my @lists = (
    [ 'just one thing',                                               ],
    [ 'Mutt', 'Jeff',                                                 ],
    [ qw/Peter Paul Mary/                                             ],
    [ 'To our parents', 'Mother Theresa', 'God'                       ],
    [ 'pastrami', 'ham and cheese', 'peanut butter and jelly', 'tuna' ], 
    [ 'recycle tired, old phrases', 'ponder big, happy thoughts'      ],
    [ 'recycle tired, old phrases','ponder big, happy thoughts','sleep and dream peacefully' ],);

for @lists -> $array {
    print "The list is: " ~ commify_series(@($array)) ~ ".\n";
}
# demo for single list
my @list = qw/one two three/;
print "The last list is: " ~ commify_series(@list) ~ ".\n";
```

或者使用 `?? ... !!` 语法：

```perl6
sub commify_series(@a) {
  (@a.elems == 0) ?? ''                                     !!
  (@a.elems == 1) ?? @a                                     !!
  (@a.elems == 2) ?? join(" and ", @a)                      !!
                     (join(", ", @a[0 .. *-2]), "and @a[*-1]");
                     

} 
```

### 4.3 改变数组的大小
你想缩短一个数组的大小：

```perl6
# 如果是有限列表
my $d = [0..9];
$d.=splice(0 ,5)

# 或使用副词
my $d = [0..9];
$d[5..*] :delete

# 如果是无限列表
my $d = [0..9];
$d = [$d[^5]]

# 使用 xx 操作符
my $d = [0..9];
$d.pop xx 4;  #-> (9 8 7 6)
say $d;       #-> [0 1 2 3 4 5]

$d = [0..9];
$d.shift xx 5 #-> (0 1 2 3 4)
say $d;       #-> [5 6 7 8 9)


# 查看性能
perl6 --profile -e 'my $d = [ 0 .. 9 ]; $d=[ $d[^5] ]'
perl6 --profile -e 'my $d = [ 0 .. 9 ]; $d.=splice(0, 5);'
```

### 4.4 实现一个稀疏数组

### 4.5 遍历数组

```perl6
my @a = 'Perl', 'Python', 'PHP';
for @a -> $lan {
  ...
}
```

### 4.6 通过引用遍历数组

### 4.7 从列表中提取唯一元素

```perl6
my @list = qw/Perl PDL Python Python PHP/;

# 摩登的 Perl 6 风格

@a.Bag.keys.say;

# 怀旧的 Perl5 风格

my %seen = ();
my @uniq = ();

for @list -> $item {
    unless (%seen{$item}) {
      %seen{$item} = 1;
      push(@uniq, $item);
    }
}

say @uniq;

# 更快的
my %seen = ();
for @list -> $item {
    push(@uniq, $item) unless %seen{$item}++;
}
```

### 4.8 找出在数组 A 中有而数组 B 中没有的元素

求差集。关于集合符号可以在[输入 Unicode 字符](https://doc.perl6.org/language/unicode_entry)中找到。也可以使用 ASCII 化的差集符号 `(-)`:

```perl6
my @a = qw/red yellow green blue/
my @b = qw/green orange purple black yellow/

my $result = @a (-) @b;
.say for $result.keys;
```

### 4.9 计算列表的并集、交集和差集

```perl6
my @a = (1, 3, 5, 6, 7, 8); 
my @b = (2, 3, 5, 7, 9);

# 并集
my $union = @a ∪ @b; # 或使用 `(|)`
.say for $union.keys;

# 交集
my $isect = @a ∩ @b; # 或使用 `(&)`
.say for $isect.keys;

# 差集 ∖
my $diff = @a ∖ @b; # 或使用 `(-)`
.say for $diff.keys;
```

### 4.10 将一个数组添加到另一个数组中

```perl6
my @members = ("Time", "Flies");
my @initiates = ("An", "Arrow");
@members.append(@initiates);     # [Time Flies An Arrow]
```

### 4.11 翻转数组

```perl6
my @a = 1,2,3,4,5;
@a.reverse;
```

### 4.12 一次处理数组的多个元素

你想一次 `pop` 或 `shift` 多个数组元素。使用 splice 方法。

```perl6
my @a = 1,2,3,4,5;
my @result = @a.splice(0, 2); # shift 前 N 个元素
say @result; # [3,4,5]


## 删除后 N 个元素
my @result = @a[*-3 .. *];
```

### 4.13 找出列表中第一个通过测试的元素

```perl6
my @a = 1,4,7,2,5,8;
say @a.grep(*>4)[0];
```

### 4.14 找出数组中匹配某个标准的所有元素

使用 grep：

```perl6
my @a = 1..1000;
my @result = grep(111 <= * <= 222);
```

### 4.15  按数字顺序排序数组

```perl6
my @a = 1,4,7,2,5,8;
@a.sort();         # (1 2 4 5 7 8)
@a.sort(+*);       # (1 2 4 5 7 8)
@a.sort(-*);       # (8 7 5 4 2 1)
```


### 4.18 shuffle an Array

```perl6
my @a = 1,2,3,4,5,6,7;
my @shuffle = @a.pick(*);
```



## 第五章 散列

### 5.1 给散列添加元素

你需要给散列添加一个条目。

```perl6
%HASH{$KEY} = $VALUE;
```

### 5.2 测试散列中是否存在某个键

```perl6
if %HASH{$KEY} :exists {...}         # 使用副词
```

### 5.3 使用不可变的键或值创建散列

你想拥有一个散列，一旦它的键或值被设置后就不能被修改了。

```perl6
# Comming soon!
```

### 5.4 从散列中删除

```perl6
%HASH{$KEY} :delete;
```

### 5.5 遍历散列

```perl6
# 同时遍历键和键值
for %hash.kv -> $key, $value {
    say "$key    |    $value";
}

# 遍历键
for %hash.keys -> $key {
    say %hash{$key};
}

# 遍历键值
for %hash.values -> $value {say $value}
```

### 5.6 打印散列

```perl6
say %hash.fmt;
```


### 5.7 以插入到散列的顺序检索散列

你想按照插入到散列的顺序检索散列。

```perl6
# Comming Soon!
```

### 5.8 每个键对应多个值的散列

你想为每个键存储多个值：

```perl6

```

### 5.9 翻转散列

```perl6
%hash.invert;
```

### 5.10 给散列排序

```perl6
# order the keys alphabetically
my %food_color = Apple => "red", Banana => "yellow", Lemon => "yellow", Carrot => "orange";
%food_color.sort(*.keys)
```
### 5.11 合并散列

### 5.15 找出出现次数最多的元素
```perl6
my %count = ();
for @ARRAY -> $element {
    %count{$element}++;
}
```




## 第六章 

### 6.5 找出第 N 次出现的匹配


你想在字符串中找出第 N 个匹配，而不仅仅是第一个。例如，你想找出第三次出现的 "fish" 之前的单词:

One fish two fish red fish blue fish


```perl6
my $pond = 'One fish two fish red fish blue fish';
$pond ~~ m:2nd/(\w+) \s fish/;
say ~$/[0];
```