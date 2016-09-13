
流行游戏辐射3: New Vegas 有一台计算机, 玩家必须正确地从同样长度的单词列表中猜出正确的密码。你的挑战是你自己实现这个游戏。

玩家有只 4 次机会, 每一次不正确的猜测计算机会提示有多少个字母位置是正确的。

例如, 如果密码是 **MIND** , 玩家猜测为 **MEND**, 游戏会提示4个位置中的3个是正确的(M_ND)。如果密码是 COMPUT, 玩家猜测为 PLAYFUL, 游戏会报告 0/7。虽然某些字符是匹配的, 但是位置不匹配。

询问玩家难度设置为几（非常简单, 简单, 中等, 困难, 非常困难）, 然后给玩家展示5到15的同样长度的单词。长度可以是 4到15个字符。

这儿有一个游戏例子:

``` perl
Difficulty (1-5)? 3
SCORPION
FLOGGING
CROPPERS
MIGRAINE
FOOTNOTE
REFINERY
VAULTING
VICARAGE
PROTRACT
DESCENTS
Guess (4 left)? migraine
0/8 correct
Guess (3 left)? protract
2/8 correct
Guess (2 left)? croppers
8/8 correct
You win!
```

你可以从我们的字典文件中获取单词：[enable1.txt](http://code.google.com/p/dotnetperls-controls/downloads/detail?name=enable1.txt) 。 你的程序应该在做位置检查时完全忽略大小写。

能增加游戏的难度, 或许甚至不能保证有解决方法, 根据你特别挑选的单词。例如, 你的程序能提供某些位置重叠的字符以至于暴露给玩家的信息越少越好。

#### Perl 6 - *difficulty levels based on letter overlaps*

Rather than simply choosing random words of a certain length, it also requires a minimum number of total letter overlaps between them。

``` perl6
sub get-words ($difficulty) {
    my %setting =
        1 => (4     , 7),
        2 => (5..6  , 5),
        3 => (7..8  , 3),
        4 => (9..11 , 1),
        5 => (12..15, 0),
    ;
    my ($length, $similarity) = %setting{$difficulty}».pick;

    my @dict = 'enable1.txt'.IO.lines.grep(*.chars == $length);

    my @words = @dict.pick($length + 1)
        until letter-overlaps(@words) >= $similarity;
    @words;
}

sub letter-overlaps (*@words) {
    [+] ([Z] @words».fc».comb).map({ .elems - .Set.elems })
}
```

I used a naive brute-force implementation - it simply keeps choosing random sets of words of the correct length, until it finds a set that fulfils the overlap condition.

Here's an example of a set with 6 total letter overlaps (indicated by asterisks) which was found for difficulty 2:

``` perl6
GLUGS -> GLUGS
LOCAL -> LOCAL
CASKY -> CASKY
NATTY -> N*TT*
SAULT -> S*ULT
SAITH -> **I*H
```

``` perl6
sub get-words ($difficulty) {
    my %lengths = 1 => 4..6,   2 => 7..8,  3 => 9..11,
                  4 => 12..13, 5 => 14..15;

    my $length = %lengths{$difficulty}.pick;

    'enable1.txt'.IO.lines.grep(*.chars == $length).pick($length + 1);
}

sub guess ($secret, $i) {
    my $word = prompt "Guess ({4 - $i} left)? ";
    ($secret.fc.comb Z $word.fc.comb).flat.grep(* eq *).elems;
}

sub play {
    my $difficulty = +prompt 'Difficulty (1-5)? ';
    my @words = get-words $difficulty;

    say .uc for @words;

    my $secret = @words.pick;
    my $l = $secret.chars;

    for ^4 {
        my $g = guess $secret, $_;
        if $g == $l { say 'You win !'; return }
        else        { say "$g/$l correct" }
    }

    say "You lose, the word was $secret"
}

play;
```

I should steal somebody's difficulty level determinations. Only thing of interest may be picking N random things from a stream in a single pass:

``` perl6
#!/usr/bin/env perl6
use v6;
constant $DEBUG = %*ENV<DEBUG> // 1;

# most favorite one pass random picker
class RandomAccumulator {
  has $.value;
  has $!count = 0;
  method accumulate($input) {
    $!value = $input if rand < 1 / ++$!count;
    self;
  }
}

# get count random words with some filtering
sub random-words(
  Int :$count = 1,
  Int :$length = 5,
  Regex :$match = rx/^<:Letter>+$/,
) {
  my @acc = RandomAccumulator.new xx $count;
  for "/usr/share/dict/words".IO.lines.grep($match)\
    .grep(*.chars == $length) -> $word {
    .accumulate($word) for @acc;
  }
  @acc.map: *.value;
}

sub count-matching-chars(Str $a, Str $b) {
  ($a.comb Zeq $b.comb).grep(?*).elems
}

sub MAIN {

  my $difficulty;

  repeat {
    $difficulty = prompt("Difficulty (1-5): ");
  } until 1 <= $difficulty <= 5;

  # first pass at difficulty levels, tweak as desired
  # maybe pick count/length as some function of $difficulty
  my %level =
    1 => [ count => 5, length => 4 ],
    2 => [ count => 5, length => 4 ],
    3 => [ count => 5, length => 4 ],
    4 => [ count => 5, length => 4 ],
    5 => [ count => 15, length => 15 ],
    ;

  my @words = random-words(|%level{$difficulty}.hash).map(*.fc);
  my $target = @words.pick;
  say "target: $target" if $DEBUG;

  @words.join("\n").say;

  my $won = False;
  for ^4 {
    my $guess = prompt("Guess ({4-$_} left): ").fc;
    if ($guess eq $target) { $won = True; last }
    say "You got &count-matching-chars($guess,$target) characters correct.";
  }

  if $won {
    say "You won!";
  }
  else {
    say "You loose!";
  }

}
```











