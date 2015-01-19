# Perl 6专家指南 ->　超级or - 多选分支
> 分类: Perl6


## 超级or (分支)
## examples/scalars/junctions.p6
```perl
#!/usr/bin/env perl6
use v6;

say "Please select an option:";
say "1) one";
say "2) two";
say "3) three";
my $c = prompt('');

if $c == 1 or $c == 2 or $c == 3 {
    say "correct choice: $c";
} else {
    say "Incorrect choice: $c";
}
```

这种新颖的语法
```perl
if $c == 1|2|3 {
    say "correct choice: $c";
} else {
    say "Incorrect choice: $c";
}
```
