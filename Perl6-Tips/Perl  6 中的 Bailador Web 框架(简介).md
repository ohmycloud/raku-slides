# 开始 Bailador

[Bailador](https://github.com/tadzik/Bailador/) 是对 [Perl Dancer](http://perldancer.org/) Web 开发框架的模仿。
安装方法：

```perl6
panda install Bailador
# or
zef install Bailador
```

我们来创建一个脚本 **first.pl**，打印 "hello world":

```perl6
use v6;
use Bailador;

get '/' => sub {
    "hello world"
}

baile;
```

运行：perl6 first.pl 它会启动一个小型的 Web 服务器，你可以在3000端口上访问它：

```
$ perl6 first.pl
Entering the development dance floor: http://0.0.0.0:3000
[2016-05-05T12:57:31Z] Started HTTP server.
```

在 Bailador 中，我们需要把 **HTTP** 请求方法和服务器上的路径映射给一个匿名子例程, 这个子例程会返回它里面的内容。在这个例子中，我们把我们告诉它的网站根路径的 **get** HTTP 请求映射为返回字符串 **hello world**。如果你启动这个程序并用浏览器打开 [http://0.0.0.0:3000/](http://0.0.0.0:3000/) 你就会看到这个文本。

我们还可以映射其它路径(path-es):

```perl6
get '/about' => sub {
    "关于我"
}
```

这会把 [ http://0.0.0.0:3000/about]( http://0.0.0.0:3000/about) url 映射为返回 「关于我」。


## 路径中的占位符

路径中的一部分可以是以冒号开头的占位符:

```perl6
get '/hello/:name' => sub ($name) {
    "Hello $name!"
};
```

**:name** 部分能匹配除了斜线 **/** 之外的任何字符串，并且它所匹配到的值会被赋值给匿名子例程中的 **$name** 变量。

这样的占位符你可以拥有多个，并且占位符的实际名字是什么无关紧要。占位符所捕获到的值会按照它们出现在 url 中的顺序赋值给函数的参数。

```perl6
get '/hello/:first/:family' => sub ($fname, $lname) {
    "Hello $fname! And hi $lname"
};
```

在这个例子中，无论 **:first** 占位符捕获到的是什么，它都会被赋值给 **$fname** 参数，无论 **:family** 捕获到的是什么，它都会被赋值给 **:$lname**。例如 url [http://0.0.0.0:3000/hello/Foo/Bar](http://0.0.0.0:3000/hello/Foo/Bar) 会生成如下响应:

```
Hello Foo! And hi Bar!
```

当然，让占位符的名字和参数的名字相同可能会让代码更易读。这是第二个脚本的完整版本:

```perl6
use v6;
use Bailador;

get '/' => sub {
    "hello world"
}

get '/hello/:first/:family' => sub ($fname, $lname) {
    "Hello $fname! And hi $lname"
};


baile;
```

# 使用 Bailador 回显文本

我们来看看怎么从用户那儿接收输入并把输入回显给用户。

## 使用 POST 回显

对于这，我们必须创建两个路由(routes)因为现在 Bailador 还不能处理 GET 参数。

```perl6
# echo_post.p6

use v6;
use Bailador;

get '/' => sub {
	'<form method="POST" action="/echo"><input name="text"><input type="submit"></form>';
}

post '/echo' => sub {
  my $text = request.params<text> // '';
	my $html = 'You said (in a POST request) ';
	$html ~= $text;
	return $html;
}

baile;
```

![img](http://upload-images.jianshu.io/upload_images/326727-569a4158b27cc4d0.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们能看到怎么创建一个路由来处理 POST 请求。

第一个路由 **get '/' => {** 会发送一个 **GET** 请求并且它会返回一个包含在这个脚本中的 HTML 片段。(我知道，我们很快就会使用模板了) 那个 HTML 片段包含了一个带有单个文本框的表单和一个提交按钮。这个表单有一个通向 **/echo** URL 的 **action**，并且表单拥有 **method="POST"**。这意味着，当用户点击提交按钮时，浏览器会发送回 POST 请求。

第二个路由 **post '/echo' => sub {** 会处理 **/echo** 路径的 POST 请求。
  
Bailador 提供的 **request** 函数以 [Bailador::Request](https://github.com/tadzik/Bailador/blob/master/lib/Bailador/Request.pm)的形式返回代表当前请求的对象。

**request** 函数有几个方法，其中一个是 **params** 方法，它返回一个散列，其中散列的键是参数的名字（在我们这个例子中是 **text**），值是提交的值。

我们把那个值保存在 **$text** 变量中，并且我们使用 '//' defined-or 操作符来设置变量的值为空，在用户没有提供任何值的情况下。然后我们连接用户提供的值组成 "html" 字符串。最后发送回那个字符串，我们这个小小的回显服务器就能工作啦。

![img](http://upload-images.jianshu.io/upload_images/326727-d07297442a570b93.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 使用 GET 回显

```perl6
use v6;
use Bailador;

get '/' => sub {
	'<form method="GET"  action="/echo"><input name="text"><input type="submit"></form>';
}

get '/echo' => sub {
    return 'You said (in a GET request) ' ~ (request.params<text> // '');
}

baile;
```

![img](http://upload-images.jianshu.io/upload_images/326727-399effeb8572bf83.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


在这个例子中，我省略了临时变量 **$text** 和 **$html**，在之前的例子中它们也不是必要的。当我们使用 **GET** 方法请求后，提交后回在浏览器的 URL 地址栏中拼接上我们的 text 字段和字段的值。

# Bailador Application in a module

## 模板

在下面这个模板中，它把数据接收到变量 `$h` 中，之后使用这个变量来展示版本号和当前时间 - 从纪元开始的秒数。
*bailador/code_in_module/views/index.tt*

```perl6
% my ($h) = @_;
<!DOCTYPE html>
<html>
  <head>
    <title>Bailador App</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
  </head>
  <body>
    <h1>Bailador App</h1>
    <div>
      Version <%= $h<version> %> Current time: <%= $h<date> %>
    </div>
  </body>
</html>
```


## 模块

这个文件把所有代码包含在类中:

```perl6
unit class Demo;
```

为了拥有特定领域语言(DSL)，它加载了 Bailador 以让我们定义路由更容易。

```perl6
use Bailador;
```
最重要的是它包含了路由。

```perl6
unit class Demo;
use Bailador;
 
my $version = '0.01';

get '/' => sub {
    template 'index.tt', { version => $version, date => time }
}
```

## 启动应用程序的脚本

```perl6
use Bailador;
Bailador::import();
use lib callframe(0).file.IO.dirname ~ '/lib';
use Demo;

baile;
```

最有意思的应该是这段代码:

```perl6
use lib callframe(0).file.IO.dirname ~ '/lib';
```

它计算这个工程的根目录 - 假设 `app.pl` 文件在根目录中 - 然后把 `/lib` 子目录添加到 perl 将要查找额外模块的地方。这会在 `lib` 子目录下加载 `Demo.pm` 文件。


![img](http://upload-images.jianshu.io/upload_images/326727-317746ed1c73c978.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)