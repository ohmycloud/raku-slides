

检查 module 的名字是否 遵循 Perl 6 的命名规范。模块的名字可以是使用 2 个冒号分割的标识符, 例如  `File::Compare` 。标识符必须以字母字符 (a-z) 或下划线开头， 后面跟着 0 个 或多个字母数字字符。但是并没有那么简单, 有些模块的名字只有一个标识符而没有冒号，例如  Bailador ， 而其它模块可能有多个标识符和 `::` 组成。这看起来正符合 grammar 的胃口！

## 定义 grammar

   Perl 6 Grammars 是由 regexes 构建的。 我需要 2 个 regexes： 一个用于匹配标识符, 一个用于匹配双冒号分隔符。对于标识符 regex， 我使用：

``` perl
<[A..Za..z_]>            # begins with letter or underscore
<[A..Za..z0..9]> ** 0..* # zero or more alpanumeric
```

   Perl 6 中，字符类是使用  `<[ ... ]>` 来定义的， 范围是使用 范围操作符 `..` 代替了短划线 `-`.  量词使用 `** 0..*` 代替了 `{0,}`

``` perl
\:\: # colon pairs
```

   使用 `grammar` 关键字定义 Grammars, 关键字后跟着 grammar 的名字. 我把这个 grammar 叫做 `Legal-Module-Name`

``` perl
grammar Legal-Module-Name{
  ...
}
```

 现在我能把 regexes 作为 tokens 添加到 grammar 中了：

``` perl
grammar Legal-Module-Name{
  token identifier  {
    # leading alpha or _ only
    <[A..Za..z_]>
    <[A..Za..z0..9]> ** 0..*
  } 
  token separator  {
    \:\: # colon pairs
  }}
```

每一个 Grammar 中都要有一个 叫做 `TOP` 的 token，它是这个 grammar 的起始点：

``` perl
grammar Legal-Module-Name{
  token TOP  { # identifier followed by zero or more separator identifier pairs
    ^ <identifier> [<separator><identifier>] ** 0..* $  
  }
  token identifier  {
    # leading alpha or _ only
    <[A..Za..z_]>
    <[A..Za..z0..9]> ** 0..*
  } 
  token separator  {
    \:\: # colon pairs
  }
}
```

`TOP` 定义了一个合法的模块名，它以一个标识符 token 开始，然后是 0 个或多个 分隔符和标识符对儿。 这很好写并且很容易维护。假设我现在想要修改分隔符规则来包含短划线 ('-')，我只需更新分隔符 token 的 regex， 不需要更新 `TOP` 了。

## 使用 grammar

Grammar 的 `parse` 方法对一个字符串应用定义的 grammar， 如果解析成功就返回一个 match 对象。这段代码解析了 `$proposed_module_name` 字符串, 结果要么打印出 match 对象，要么打印错误信息如果模块名不合法的话。

``` perl
my $proposed_module_name = 'Super::New::Module';
my $match_obj = Legal-Module-Name.parse($proposed_module_name);

if $match_obj{
    say $match_obj;
}else{
    say 'Invalid module name!';
}
```

这段代码打印:

``` perl
｢Super::New::Module｣
 identifier => ｢Super｣
 separator => ｢::｣
 identifier => ｢New｣
 separator => ｢::｣
 identifier => ｢Module｣
```

## 从 match object 中提取内容

我们能从 match 对象中提取匹配的 tokens。这里会使用 Perl 6 中到处可见的 quoting 语法（例如 命名正则和散列键）

``` perl
say $match_obj<identifier>[0].Str; # Super
say $match_obj<identifier>[1].Str; # New
say $match_obj<identifier>[2].Str; # Module
say $match_obj<identifier>;        # all 3 captures
```

## Action 类

Perl 6 允许你添加一个 action 类来为匹配到的 tokens 定义额外的行为。我想在模块名有太多的标识符时给出一个警告，换句话说，它是一个合法的名字，但是用户可能想要缩短简化它。 首先我定义了 action 类：

``` perl
class Module::Name::Actions{
  method TOP($/)
  {
    if $<identifier>.elems > 5
    {
      warn 'Module name has a lot of identifiers, consider simplifying the name';
    }
  }
}
```

这就是一个 Perl 6 的类的定义。 我添加了一个叫做 `TOP` 的方法，它匹配 grammar 中的第一个 token。 我使用 命名指正则语法来计算所有的标识符匹配，如果多于 5 个就发出警告。 这不会让代码停止运行， 但是会引起使用者重新考虑他们选择的模块名字。

然后我初始化了一个 action 对象，并且把它作为参数传递给了Grammar 的 `parse` 方法:

``` perl
my $actions = Module::Name::Actions.new; 
my $match_obj = Legal-Module-Name.parse($proposed_module_name, :actions($actions));
```

解析期间， 每当 这个 token (TOP) 出现时，都会调用一次匹配 action 类中的 TOP 方法。
