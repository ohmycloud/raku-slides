我想以AGCT4种字母为基础生成字符串。

比如希望长度为1，输出A,G,C,T。
如果长度为2，输出AA,AG,AC,AT,GA,GG,GC,GT,CA,CG,CC,CT,TA,TG,TC,TT。这样的结果。

@a X~ ""   # 长度为1

(@a X~ @a) # 长度为2 

(@a X~ @a) X~ @a  # 长度为3

@a X~ @a X~ @a X~ @a # 长度为4

    > my @a=<A G C T>
    A G C T
    > my $x=@a
    A G C T
    > $x xx 2
    A G C T A G C T
    > $x xx 3
    A G C T A G C T A G C T
    > ($x xx 3).WHAT
    (List)
    > $x.WHAT
    (Array)
    
    
    > ([X~] $x xx 2).join(',')
    AA,AG,AC,AT,GA,GG,GC,GT,CA,CG,CC,CT,TA,TG,TC,TT
    
    
    惰性操作符：
    my @a=<A G C T>;
    my $x=@a;  # 或者使用 $x =@('A','G','C','T')
    for 1 ...^ * -> $a {(([X~] $x xx $a)).join(',').say;last if $a==4;};

	sub arry_rep($array,$a){
	    $array xx $a
	}
