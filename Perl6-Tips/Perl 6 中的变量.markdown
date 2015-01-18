 Perl 6 Documentation
Search 

Perl 6 variables
Sigils
Twigils
*
!
?
.
<
^
:
=
~
Special Variables
Often-Used Variables
$_
$/
$!
Compile-time "constants"
Dynamic variables
Other variables

Variable names start with a special character called a sigil , followed optionally by a second special character named twigil , and then an identifier . Sigils

The sigil serves both as rough type constraint, and as an indicator as to whether the contents of the variable flatten in list context. See also the documentation in List . Sigil Type constraint Default type Flattens Assignment
 $ Mu (no type constraint) Any No item
 & Callable Callable No item
 @ Positional Array Yes list
 % Associative Hash Yes list


Examples:
my $square = 9 ** 2;
my @array  = 1, 2, 3;   # Array variable with three elements
my %hash   = London => 'UK', Berlin => 'Germany';

There are two types of assignment, item assignment and list assignment . Both use the equal sign = as operator. The distinction whether an = means item or list assignment is based on the syntax of the left-hand side. (TODO: explain in detail, or do that in operators ).

Item assignment places the value from the right-hand side into the variable (container) on the left.

List assignment leaves the choice of what to do to the variable on the left.

For example Array variables ( @ sigil) empty themselves on list assignment, and then put all the values from the right-hand side into themselves. Contrary to item assignment, it means that the type of the variable on the left always stays Array , regardless of the type of the right-hand side.

Note that the item assignment has tighter precedence than list assignment, and also tighter than the comma. See operators for more details. Twigils

Twigils影响变量的作用域。请记住 twigils 对基本的魔符插值没有影响，那就是，如果   $a  内插，  $^a , $*a , $=a , $?a , $.a , 等等也会内插. 它仅仅取决于 $. Twigil Scope
 * ! ? . < ^ : dynamic attribute (class member) compile-time "constant" method (not really a variable) index into match object (not really a variable) self-declared formal positional parameter self-declared formal named parameter
 ~ the sublanguage seen by the parser at this lexical spot
*

Dynamic variables are looked up through the caller, not through the outer scope. For example:
    my $lexical   = 1;
    my $*dynamic1 = 10;
    my $*dynamic2 = 100;

    sub say-all() {
        say "$lexical, $*dynamic1, $*dynamic2";
    }

    # prints 1, 10, 100
    say-all();

    {
        my $lexical   = 2;
        my $*dynamic1 = 11;
        $*dynamic2    = 101;

        # prints 1, 11, 101
        say-all();
    }

    # prints 1, 10, 101
    say-all();


The first time &say-all is called, it prints "1, 10, 100" just as one would expect. The second time though, it prints "1, 11, 101". This is because $lexical isn't looked up in the caller's scope but in the scope &say-all was defined in. The two dynamic variables are looked up in the callers scope and therefore have the values 11 and 101. The third time &say-all is called $*dynamic1 isn't 11 anymore, but $*dynamic2 is still 101. This stems from the fact that we declared a new dynamic variable $*dynamic1 in the block and did not assign to the old variable as we did with $*dynamic2 . !

Attributes are variables that exists per instance of a class. They may be directly accessed from within the class via ! :
    class Point {
        has $.x;
        has $.y;

        method Str() {
            "($!x, $!y)"
        }
    }


Note how the attributes are declared as $.x and $.y but are still accessed via $!x and $!y . This is because in Perl 6 all attributes are private and can be directly accessed within the class by using $!attribute-name . Perl 6 may automatically generate accessor methods for you though. For more details on objects, classes and their attributes see objects . ?

Compile-time "constants" may be addressed via the ? twigil. They are known to the compiler and may not be modified after being compiled in. A popular example for this is:
say "$?FILE: $?LINE"; # prints "hello.pl: 23" if this is the 23 line of a
                      # file named "hello.pl".

Although they may not be changed at runtime, the user is allowed to (re)define such constants.
constant $?TABSTOP = 4; # this causes leading tabs in a heredoc or in a POD
                        # block's virtual margin to be counted as 4 spaces.

For a list of those special variables see Compile-time "constants" . .

The . twigil isn't really for variables at all. In fact, something along the lines of
    class Point {
        has $.x;
        has $.y;

        method Str() {
            "($.x, $.y)" # note that we use the . instead of ! this time
        }
    }


just calls the methods x and y on self , which are automatically generated for you because you used the . twigil as you declared your attributes. Note, however, that subclasses may override those methods. If you don't want this to happen, use $!x and $!y instead.

The fact that the . twigil just does a method call also implies that the following is possible too.
    class SaySomething {
        method a() { say "a"; }
        method b() { $.a; }
    }

    SaySomething.a; # prints "a"


For more details on objects, classes and their attributes and methods see objects . <

The < twigil is just an alias for $/<...> where $/ is the match variable. For more information on the match variable see $/ . ^

The ^ twigil declares a formal positional parameter to blocks or subroutines. Variables of the form $^variable are a type of placeholder variables. They may be used in bare blocks to declare formal parameters to that block. So the block in the code
for ^4 {
    say "$^seconds follows $^first";
}

which prints
1 follows 0
3 follows 2

有两个形式参数，就是  $first 和 $second . Note that even though $^second appears before $^first in the code, $^first is still the first formal parameter to that block. This is because the placeholder variables are sorted in Unicode order. If you have self-declared a parameter using $^a once you may refer to it using only $a thereafter.

Subroutines may also make use of placeholder variables but only if they do not have an explicit parameter list. This is true for normal blocks too.
sub say-it    { say $^a; } # valid
sub say-it()  { say $^a; } # invalid
              { say $^a; } # valid
-> $x, $y, $x { say $^a; } # invalid

Placeholder variables syntactically cannot have any type constraints. Be also aware that one can not have placeholder variables with a single upper-case letter. This is disallowed in favor of being to able to catch some Perl 5-isms. :

The : twigil declares a formal named parameter to a block or subroutine. Variables declared using this form are a type of placeholder variables too. Therefore the same things that apply to variables declared using the ^ twigil apply also to them (with the exception that they are not positional and therefore not ordered using Unicode order, of course).

See ^ for more details about placeholder variables. =

The = twigil is used to access Pod variables. Every Pod block in the current file can be accessed via a Pod object, such as $=data , $=SYNOPSIS or =UserBlock . That is: a variable with the same name of the desired block and a = twigil.
=begin Foo
...
=end Foo

#after that, $=Foo gives you all Foo-Pod-blocks


You may access the Pod tree which contains all Pod structures as a hierarchical data structure through $=pod .

Note that all those $=someBlockName support the Positional and the Associative role. ~

The ~ twigil is for referring to sublanguages (叫做行话). The following are useful:
$~MAIN       the current main language (e.g. Perl statements)
$~Quote      the current root of quoting language
$~Quasi      the current root of quasiquoting language
$~Regex      the current root of regex language
$~Trans      the current root of transliteration language
$~P5Regex    the current root of the Perl 5 regex language

You may supersede or augment those languages in your current lexical scope by doing
augment slang Regex {  # derive from $~Regex and then modify $~Regex
    token backslash:std<\Y> { YY };
}

or
supersede slang Regex { # completely substitute $~Regex
    ...
} 特殊变量 经常使用的变量

# TODO: find a better heading

每个代码块中都有3个特别的变量: 变量 意义
 $_   特殊变量
 $/   正则匹配
 $!   异常
$_

$_  是特殊变量，在没有显式标识的代码块中，它是默认参数。所以诸如 for @array { ... }  和  given $var { ... }  之类的结构会将变量绑定给$_.
for <a b c> { say $_ }  # sets $_ to 'a', 'b' and 'c' in turn
say $_ for <a b c>;     # same, even though it's not a block
given 'a'   { say $_ }  # sets $_ to 'a'
say $_ given 'a';       # same, 尽管这不是一个块

CATCH  块将$_设置为捕获到的异常。 ~~ 智能匹配操作符The ~~ smart-match operator sets $_ on the right-hand side expression to the value of the left-hand side.

对$_调用一个方法可以省略特殊变量$_的名字，从而写的更短：
.say
;                   # 与 $_.say 相同

m/regex/  和  /regex/  正则匹配 和  s/regex/subst/  替换是作用于  $_ 上的 . $/

$/  是匹配变量。它存储着每次正则匹配的结果，通常包含 Match 类型的对象。
'abc 12' ~~ /\w+/;  # 设置 $/ 为一个Match 对象
say $/
.Str
;         # abc

The Grammar.parse method also sets the caller's $/ to the resulting Match object.

其他匹配变量是$/元素的别名：
$0          # same as $/[0]
$1          # same as $/[1]
$<named>    # same as $/<named> $!

$! is the error variable. If a try block or statement prefix catches an exception, that exception is stored in $! . If no exception was caught, $! is set to the Any type object.

Note that CATCH blocks do not set $! . Rather they set $_ inside the block to the caught exception. 编译时  "常量"
$?FILE      所在文件
$?LINE      所在行
&?ROUTINE   所在子例程
&?BLOCK     所在块
%?LANG      What is the current set of interwoven languages?

其它编译时常量：
$?KERNEL    Which kernel am I compiled for?
$?DISTRO    Which OS distribution am I compiling under
$?VM        Which virtual machine am I compiling under
$?XVM       Which virtual machine am I cross-compiling for
$?PERL      Which Perl am I compiled for?
$?SCOPE     Which lexical scope am I in?
$?PACKAGE   Which package am I in?
$?MODULE    Which module am I in?
$?CLASS     Which class am I in? (as variable)
$?ROLE      Which role am I in? (as variable)
$?GRAMMAR   Which grammar am I in?
$?TABSTOP   How many spaces is a tab in a heredoc or virtual margin?
$?USAGE     The usage message generated from the signatures of MAIN subs.
$?ENC       Default encoding of Str.encode/Buf.decode/various IO methods. 动态变量
$*ARGFILES  神奇的命令行输入句柄
@*ARGS      来自命令行的参数.
$*IN        标准输入文件句柄.
$*OUT       标准输出文件句柄.
$*ERR       标准错误文件句柄.
$*TZ        系统的本地时区.
$*CWD       当前工作目录. 其他变量
$*PROGRAM_NAME     Path to the current executable as it was typed in on the
                   command line, or C<-e> if perl was invoked with the -e flag.
$*PID              当前进程的进程ID
$*OS               在哪种操作系统下被编译(e.g. Linux).
$*OSVER            当前操作系统的版本.
$*EXECUTABLE_NAME  当前运行的可执行perl 的名字
