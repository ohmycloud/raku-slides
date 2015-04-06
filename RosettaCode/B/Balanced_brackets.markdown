任务：
    以任意的顺序生成 含有 N 个开括号"["  和 N 个闭括号"]" 的字符串
    检查生成的字符串是否平衡
Example：
   (empty)   OK
   []        OK   ][        NOT OK
   [][]      OK   ][][      NOT OK
   [[][]]    OK   []][[]    NOT OK

```perl
# There's More Than One Way To Do It
# Depth counter

sub balanced($s) {
    my $l = 0;
    for $s.comb {
        when "]" {
            --$l;
            return False if $l < 0;
        }
        when "[" {
            ++$l;
        }
    }
    return $l == 0;
}
 
my $n = prompt "Number of brackets";
my $s = (<[ ]> xx $n).pick(*).join;
say "$s {balanced($s) ?? "is" !! "is not"} well-balanced"

# FP oriented
# Here's a more idiomatic solution using a hyperoperator to compare all the characters to a backslash (which is between the brackets in ASCII), a triangle reduction to return the running sum, a given to make that list the topic, and then a topicalized junction and a topicalized subscript to test the criteria for balance.

sub balanced($s) {
    .none < 0 and .[*-1] == 0
        given [\+] '\\' «leg« $s.comb;
}
 
my $n = prompt "Number of bracket pairs: ";
my $s = <[ ]>.roll($n*2).join;
say "$s { balanced($s) ?? "is" !! "is not" } well-balanced"

# String munging
# Of course, a Perl 5 programmer might just remove as many inner balanced pairs as possible and then see what's left.

sub balanced($_ is copy) {
    () while s:g/'[]'//;
    $_ eq '';
}
 
my $n = prompt "Number of bracket pairs: ";
my $s = <[ ]>.roll($n*2).join;
say "$s is", ' not' xx not balanced($s)), " well-balanced";

# Parsing with a grammar
grammar BalBrack { token TOP { '[' <TOP>* ']' } }
 
my $n = prompt "Number of bracket pairs: ";
my $s = ('[' xx $n, ']' xx $n).pick(*).join;
say "$s { BalBrack.parse($s) ?? "is" !! "is not" } well-balanced";
```
