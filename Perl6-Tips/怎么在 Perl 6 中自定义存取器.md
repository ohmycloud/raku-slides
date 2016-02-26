title:  怎么在 Perl 6 中自定义存取器?

date: 2016-01-13

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'>后来, 终于在眼泪中明白, 有些人, 一旦错过就不在！</blockquote>

## How does one write custom accessor methods in Perl6?

我有一个类:

``` perl
class Wizard {
    has Int $.mana is rw;
}
```

我可以这样做:

``` perl
my Wizard $gandalf .= new;
$gandalf.mana = 150;
```

我想在不放弃使用`$gandalf.mana = 150;` 的情况下, 在  `setter`里面做一些检查。换句话说, 我不想这样写: `$gandalf.setMana(150)`。 如果程序尝试设置一个负值的话, 就退出。

``` perl
class Wizard {
    has Int $!mana;

    method mana() is rw {
        return Proxy.new:
            FETCH => sub ($) { return $!mana },
            STORE => sub ($, $mana) {
                die "It's over 9000!" if ($mana // 0) > 9000;
                $!mana = $mana;
            }
    }
    }

my Wizard $gandalf .= new;
say $gandalf.mana;
$gandalf.mana = 150;
say $gandalf.mana;
```

`Pxoxy`是一种拦截对存储进行读写调用, 并做一些非默认行为的方式。在解析像 `$gandalf.mana = $gandalf.mana + 5` 这种表达式的时候, Perl 6 会自动调用 `FETCH` 和 `STORE` 方法。

``` perl
class Baby {
  has Int $.mana; # use . instead of ! for better `.perl` representation

  # overwrite the method the attribute declaration added
  method mana () is rw {
    Proxy.new(
      FETCH => -> $ { $!mana },
      STORE => -> $, Int $new {
        die 'invalid mana' unless $new >= 0; # placeholder for a better error
        $!mana = $new
      })
  }
}

my Baby $baby .= new;
$baby.mana = 9;
say $baby.mana;
$baby.mana = -9;
```