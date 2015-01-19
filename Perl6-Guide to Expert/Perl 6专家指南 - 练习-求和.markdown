# Perl 6专家指南 -> 练习 - 求和
> 分类: Perl6

```perl
numbers.txt:(另存为ansi编码)
3
8
19
-7
13 
```
```perl
#!/usr/bin/env perl6
use v6;

my $filename = 'numbers.txt';
my $total;
my $count;
my $min;
my $max;


if (my $fh = open $filename, :r) {
    for $fh.lines -> $line {
        if (not $count) {
            $min = $max = $line;
        }
        $total += $line;
        if ($min > $line) {
            $min = $line;
        }
        if ($max < $line) {
            $max = $line;
        }
        $count++;
    }
    my $average = $total / $count;
    say "Total: $total, Count: $count Average: $average Min: $min Max: $max";
} else {
    say "Could not open '$filename'";
}
# There is a minor issue in this solution, what if there are no values at all in the file?
```