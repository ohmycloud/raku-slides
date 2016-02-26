title:  使用 Perl 6 的 subsets 和 multiple 辨别年龄
date: 2015-07-14 00:31:39
tags: Perl6
categories: Perl 6
---
<blockquote class="blockquote-center">Perl 6 is Powerful</blockquote>

举个例子, 假设 person 有一个 age 属性. 我能写一个 `multimethod`, 让它接收一个 person 作为参数, 并返回这样的结果吗:

```perl
return "child"  if age < 16;
return "adult"  if 16 <= age < 66;
return "senior" if age >= 66;
```

```perl
class Person {
    has Int $.age;
    has Str $.name;
}
```
这仅仅定义了一个拥有两个属性, 叫做 Person 的类. age 必须是 Int 型, name 必须是 Str 型. `.` 语法会生成一个只读访问器, 以使我们能从类的外部访问 getter 方法.

现在我们来定义一个 `age-group` multi 来告诉一个 person 属于哪个 age-group:

```perl
multi age-group ($person where (*.age < 16)  ) { "child" }
multi age-group ($person where (*.age >= 66) ) { "senior"}
multi age-group ($person)                      { "adult" }
```

`where`从句给参数添加了一个`约束`, 这个约束告诉参数必须匹配这个参数右边的东西.这用于区别将要选取的 multi. `where`从句可以是一个 regex, 类型, 一个确切的值, 一个断言 block,或者一些其它东西.

`*.age < 16` 部分可能看起来更让人迷惑. 星号是什么? 星号是一个特殊的值, 叫做 Whatever. 它通常在给定情况下满足你的需求. 在智能匹配中, 它总是匹配, 所以你可以在 `given/when` block 中将它用作默认值. 但是 Whatever 最有用的地方之一是创建匿名 block. 对于大部分操作符, 如果你在 Whatever 上执行它们, 它会产生一个匿名 block 并使用它们的参数执行操作符. 如果一个表达式中有多个 Whatever, 则生成的匿名 block 会有多个参数对应于相应的 Whatever 位置.

例如, `* + 1` 产生一个 block,使参数的值加1. `* + *` 产生一个 block 使它的两个参数相加. 这个例子中, 我们调用 Whatever 的 `age`方法, 并询问它是否小于 16. 我们能用其它几种方式达到同样的效果, 但是更啰嗦:

```perl
sub ($person) { $person.age < 16 }
```

```perl
-> $person    { $person.age < 16 }
```

```perl
{ .age < 16 }
```
但是对于像这种简单的操作, Whatever 通常比其它方式更易读也更简洁. 不幸的是, 在参数列表的 where 从句中, 你需要使用括号括起很多复杂的表达式, 包括 Whatever block.

现在让我们在 Rakudo 的 REPL 中试试它吧:

```perl
> age-group Person.new(:name<timmy>, :age(10))
child
> age-group Person.new(:name<john>, :age(23))
adult
> age-group Person.new(:name<ezekiel>, :age(89))
senior
```

目前为止, 很好. 但是如果我们意外地传递了一个 age 而不是 Person 给 age-group 呢?

```perl
> age-group 15
Method 'age' not found for invocant of class 'Int'
```
我们能指定只有 Person 对于 age-group 是合法的:

```perl
multi age-group (Person $person where (*.age < 16)) { "child" }
multi age-group (Person $person where (*.age >= 66)) { "senior" }
multi age-group (Person $person) { "adult" } 
```

这正确地处理了 Person 问题. 调用带有 age 参数的 age-group 会怎样呢?

```perl
> age-group 15
No applicable candidates found to dispatch to for 'age-group'. Available candidates are:
:(Person $person where ({ ... }))
:(Person $person where ({ ... }))
:(Person $person)
```

看起来更好. 假如我们允许询问 age 所属的 age-group 呢?

我们能重写 age-group 的 Person 变体, 接收 Int 类型的 age, 并写一个单个的 Person 变体来调用 age-group:

```perl
multi age-group(Int $age where (* < 16)  ) { "child"  }
multi age-group(Int $age where (* >= 66) ) { "senior" }
multi age-group(Int $age)                  { "adult"  }
multi age-group(Person $person) { age-group $person.age }
```

这对于每个 Person 例子都有效, 还有它们的 ages.

现在,让我们使用 `age-group` 定义一个叫做 `print-name` 的 `multi` 来分发.
根据 `age-group` 分发最明显的方法是使用 where 从句.

```perl
multi print-name(Person $person where (age-group($person) eq "child")) { "Little {$person.name}" }
multi print-name(Person $person where (age-group($person) eq "adult")) { $person.name            }
multi print-name(Person $person where (age-group($person) eq "senior")){ "Old Man {$person.name}"}
```
双引号字符串中的 `{$person.name}` 将 block 的结果插值到字符串中.

让我们再试试:

```perl
> print-name Person.new(:name<timmy>, :age(10))
Little Timmy
> print-name Person.new(:name<john>, :age(23))
John
> print-name Person.new(:name<ezekiel>, :age(89))
Old Man Ezekiel
```

那很棒. 但是如果我们有更多的基于 person 的 `age-group` 的 multis 要分发呢? 难道我们真的每次都要写出 `(Person $person where (age-group($person) eq "child"))` 这样的代码吗? 不, 我们不需要, 感谢 subset 类型.

```perl
subset Child  of Person where *.age < 16;
subset Adult  of Person where -> $person { 16 <= $person.age < 66 };
subset Senior of Person where *.age >= 66;

multi print-name(Child $person)  { "Little {$person.name}"  }
multi print-name(Adult $person)  { $person.name             }
multi print-name(Senior $person) { "Old Man {$person.name}" }
```

由于 Rakudo 在处理含有组合的链式比较操作符的 Whatever 时有一个 bug, 我们不得不为 Adult 写一个显式的 block.

这个 bug 现已修复, 所以: 

```perl
subset Adult  of Person where -> $person { 16 <= $person.age < 66 };
```

等价于:

```perl
subset Adult  of Person where  16 <= *.age < 66;
```
这个新版本的 `print-name` 与之前旧版本产生同样的结果. 现在我们能从 `Child/Adult/Senior` 的角度重写 `age-group` :

```perl
multi age-group(Child)  { "child"  }
multi age-group(Adult)  { "adult"  }
multi age-group(Senior) { "senior" }
multi age-group(Int $age) { age-group Person.new(:$age) }
```

`:$age` 是 `:age($age)` 的简写方式.

又一次, 我们有了产生想要的结果的更清晰的代码, 多亏了 multiple 分发和 subset 类型.

