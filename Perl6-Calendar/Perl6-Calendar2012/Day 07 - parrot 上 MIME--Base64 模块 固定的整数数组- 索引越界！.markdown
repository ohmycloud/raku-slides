parrot 上 MIME::Base64 模块 固定的整数数组: 索引越界！

Ronaldxs四个月前在parrot上创建了这个 ticket #813 ：

"我在用 p6 玩 MIME::Base64 和一些简单的 utf8 页面的适合偶然发现了这个。看起来 parrot 的MIME Base64 库不能处理某些 UTF-8 字符。如下所示"

.sub go :main
    load_bytecode 'MIME/Base64.pbc'
 
    .local pmc enc_sub
    enc_sub = get_global [ "MIME"; "Base64" ], 'encode_base64'
 
    .local string result_encode
    result_encode = enc_sub(utf8:"\x{203e}")
 
    say result_encode
.end
 
`FixedIntegerArray: index out of bounds!`
 
`current instr.: 'parrot;MIME;Base64;encode_base64'
 
pc 163 (runtime/parrot/library/MIME/Base64.pir:147)`
 
`called from Sub 'go' pc 11 (die_utf8_base64.pir:8)`

这件事情非常有趣。因为 parrot 字符串是把编码信息存在字符串里的。用户不需要和 perl5 里一样另外存储编码信息了， 也不用猜测编码集了。 parrot 原生支持 ascii, latin1, binary, utf-8, ucs-2, utf-16 和 ucs-4 字符编码。

所以我们想：他妈的parrot怎么可能没法处理简单的utf-8编码字符？

结果，设计来供给所有可以运行在 parrot 虚拟机上的语言共享的 MIME::Base64 模块的 parrot 实现，把每个字符的字符码值保存成了整数数组。在多字节编码集，比如 UTF-8 里，就会导致内存里的数据和编码成字节缓冲外加编码信息的多字节字符串数据不一样。 内部字符表示

举个例子，用 utf-8 字符 “\x{203e}” 来概述不同的内部字符表示：

perl5 字符串:
len=3, utf-8 flag, "\342\200\276" buf=[e2 80 be]

parrot s字符串:
len=1, bufused=3, encoding=utf-8, buf=[e2 80 be]

Unicode 表:
U+203E  ‾ e2 80 be    OVERLINE gdb 调试 perl5

让我们检验一下：

$ gdb --args perl -e'print "\x{203e}"'
(gdb) start
(gdb) b Perl_pp_print
(gdb) c
(gdb) n
 
_.. until if (!do_print(*MARK, fp))_
 
(gdb) p **MARK
$1 = {sv_any = 0x404280, sv_refcnt = 1, sv_flags = 671106052, sv_u = {
      svu_pv = **0x426dd0 "‾"**, svu_iv = 4353488, svu_uv = 4353488,
      svu_rv = 0x426dd0, svu_array = 0x426dd0, svu_hash = 0x426dd0,
      svu_gp = 0x426dd0, svu_fp = 0x426dd0}, ...}
 
(gdb) p Perl_sv_dump(*MARK)
ALLOCATED at -e:1 for stringify (parent 0x0); serial 301
SV = PV(0x404280) at 0x4239a8
  REFCNT = 1
  FLAGS = (POK,READONLY,pPOK,**UTF8**)
  PV = 0x426dd0 "\342\200\276" [UTF8 "\x{203e}"]
  CUR = **3**
  LEN = 16
$2 = void
 
(gdb) x/3x 0x426dd0
0x426dd0:   **0xe2  0x80    0xbe**

我们看到 perl5 存储了 utf-8 标识，但没存字符串长度，utf8 的长度是 1，但只存了缓冲的长度 3。

其他所有的多字节编码字符，比如 UCS-2 ，保存的都不一样。我们假设和 utf-8 一样。

我们继续在调试器里尝试其他的命令行参数：

(gdb) run -e'use Encode; print encode("UCS-2", "\x{203e}")'
  The program being debugged has been started already.
  Start it from the beginning? (y or n) y
Breakpoint 2, Perl_pp_print () at pp_hot.c:712
712     dVAR; dSP; dMARK; dORIGMARK;
 
(gdb) p **MARK
 
$3 = {sv_any = 0x404b30, sv_refcnt = 1, sv_flags = 541700, sv_u = {
    svu_pv = **0x563a50 " >"**, svu_iv = 5651024, svu_uv = 5651024,
    svu_rv = 0x563a50, svu_array = 0x563a50, svu_hash = 0x563a50, svu_gp = 0x563a50,
    svu_fp = 0x563a50}, ...}
 
(gdb) p Perl_sv_dump(*MARK)
ALLOCATED at -e:1 by return (parent 0x0); serial 9579
SV = PV(0x404b30) at 0x556fb8
  REFCNT = 1
  FLAGS = (TEMP,POK,pPOK)
  PV = 0x563a50 " >"
  CUR = 2
  LEN = 16
$4 = void
 
(gdb) x/2x 0x563a50
0x563a50:   **0x20  0x3e**

但是我们没在 encode(“UCS-2″, “\x{203e}”) 看到 UTF8 标识，而是很简单的一个 ascii 字符 ">"，这是 [20 3e] 的 UCS-2 表示。

因为 ">" 是完全以非 utf8 的ASCII 字符表示的。

UCS-2 比 UTF-8 好太多太多。它有固定的大小，还是可读的。Windows 就用这个编码。但是它没法表示全部的 Unicode 字符。

Encode::Unicode 里有这么个表格：

**Quick Reference**
                Decodes from ord(N)           Encodes chr(N) to...
       octet/char BOM S.P d800-dfff  ord > 0xffff     \x{1abcd} ==
  ---------------+-----------------+------------------------------
  UCS-2BE       2   N   N  is bogus                  Not Available
  UCS-2LE       2   N   N     bogus                  Not Available
  UTF-16      2/4   Y   Y  is   S.P           S.P            BE/LE
  UTF-16BE    2/4   N   Y       S.P           S.P    0xd82a,0xdfcd
  UTF-16LE    2/4   N   Y       S.P           S.P    0x2ad8,0xcddf
  UTF-32        4   Y   -  is bogus         As is            BE/LE
  UTF-32BE      4   N   -     bogus         As is       0x0001abcd
  UTF-32LE      4   N   -     bogus         As is       0xcdab0100
  UTF-8       1-4   -   -     bogus   >= 4 octets   \xf0\x9a\af\8d
  ---------------+-----------------+------------------------------ gdb 调试 parrot

回到 parrot:

如果你用 gdb 调试 parrot ，你会看到很漂亮的 gdb 输出，自动显示了字符和编码信息。感谢 Nolan Lum 同学。

在 Perl5 里，你必须调用 Perl_sv_dump ，如果是线程的，还得带上 my_perl 作为第一个参数。在线程的 perl ，比如 windows 平台上，你必须调用 p Perl_sv_dump(my_perl, *MARK) 。

在 parrot 里你只需要查询值，然后格式全部由这个 gdb 的美化打印插件处理好了。

字符长度被叫做（编码字符的） strlen ，缓冲大小被叫做 bufused 。

甚至在回溯里，字符参数都被缩写显示成这样：

#3  0x00007ffff7c29fc4 in utf8_iter_get_and_advance (interp=0x412050, str="utf8:� [1/2]",
    i=0x7fffffffdd00) at src/string/encoding/utf8.c:551
#4  0x00007ffff7a440f6 in Parrot_str_escape_truncate (interp=0x412050, src="utf8:� [1/2]",
    limit=20) at src/string/api.c:2492
#5  0x00007ffff7b02fb3 in trace_op_dump (interp=0x412050, code_start=0x63a1c0, pc=0x63b688)
    at src/runcore/trace.c:450

[1/2] 意味着 strlen=1 bufused=2。

每个非 ASCII 或者非 latin-1 编码的字符都会加上编码集前缀打印出来。

在内部，这个编码集当然是其所支持的编码集的表的索引或者指针。

你可以给 utf8_iter_get_and_advance 加个断点然后观察字符串：

(gdb) r t/library/mime_base64u.t
Breakpoint 1, utf8_iter_get_and_advance (interp=0x412050, str="utf8:\\x{00c7} [8/8]",
                i=0x7fffffffcd40) at src/string/encoding/utf8.c:544
(gdb) p str
$1 = "utf8:\\x{00c7} [8/8]"
(gdb) p str->bufused
$3 = 8
(gdb) p str->strlen
$4 = 8
(gdb) p str->strstart
$5 = 0x5102d7 "\\x{00c7}"

这里加上逃逸符了。现在让我们继续搞点更有趣的 utf8 字符来做这个测试，比如：until str=”utf8:Ā [1/2]“

你看到一个用 tab 键补全的结构体成员，比如在 p str-> 后面按

(gdb) p str->
**_buflen    _bufstart  bufused    encoding   flags      hashval    strlen     strstart**
(gdb) p str->strlen
$9 = 8
 
(gdb) dis 1
(gdb) b utf8_iter_get_and_advance if str->strlen == 1
(gdb) c
Breakpoint 2, utf8_iter_get_and_advance (interp=0x412050, str="utf8:Ā [1/2]",
                i=0x7fffffffcd10) at src/string/encoding/utf8.c:544
544     ASSERT_ARGS(utf8_iter_get_and_advance)
 
(gdb) p str->strlen
$10 = 1
(gdb) p str->strstart
$11 = 0x7ffff7faeb58 "Ā"
(gdb) x/2x str->strstart
0x7ffff7faeb58: **0xc4  0x80**
(gdb) p str->encoding
$12 = (const struct _str_vtable *) 0x7ffff7d882e0
(gdb) p *str->encoding
 
$13 = {num = 3, name = 0x7ffff7ce333f "utf8", name_str = "utf8", bytes_per_unit = 1,
  max_bytes_per_codepoint = 4, to_encoding = 0x7ffff7c292b0 <utf8_to_encoding>, chr =
  0x7ffff7c275c0 <unicode_chr>, equal = 0x7ffff7c252e0 <encoding_equal>, compare =
  0x7ffff7c254e0 <encoding_compare>, index = 0x7ffff7c25690 <encoding_index>, rindex
  = 0x7ffff7c257a0 <encoding_rindex>, hash = 0x7ffff7c25a20 <encoding_hash>, scan =
  0x7ffff7c29380 <utf8_scan>, partial_scan = 0x7ffff7c29460 <utf8_partial_scan>, ord
  = 0x7ffff7c297e0 <utf8_ord>, substr = 0x7ffff7c25de0 <encoding_substr>, is_cclass =
  0x7ffff7c26000 <encoding_is_cclass>, find_cclass =
  0x7ffff7c260e0 <encoding_find_cclass>, find_not_cclass =
  0x7ffff7c26220 <encoding_find_not_cclass>, get_graphemes =
  0x7ffff7c263d0 <encoding_get_graphemes>, compose =
  0x7ffff7c27680 <unicode_compose>, decompose = 0x7ffff7c26450 <encoding_decompose>,
  upcase = 0x7ffff7c27b20 <unicode_upcase>, downcase =
  0x7ffff7c27be0 <unicode_downcase>, titlecase = 0x7ffff7c27ca0 <unicode_titlecase>,
  upcase_first = 0x7ffff7c27d60 <unicode_upcase_first>, downcase_first =
  0x7ffff7c27dc0 <unicode_downcase_first>, titlecase_first =
  0x7ffff7c27e20 <unicode_titlecase_first>, iter_get =
  0x7ffff7c29c40 <utf8_iter_get>, iter_skip = 0x7ffff7c29d60 <utf8_iter_skip>,
  iter_get_and_advance = 0x7ffff7c29eb0 <utf8_iter_get_and_advance>,
  iter_set_and_advance = 0x7ffff7c29fd0 <utf8_iter_set_and_advance>} encode_base64(str)

$ perl -MMIME::Base64 -lE'$x="20e3";$s="\x{20e3}";
  printf "0x%s\t%s=> %s",$x,$s,encode_base64($s)'
Wide character in subroutine entry at -e line 1.

哎呀，我是个 unicode perl5 的菜鸟。这是我的终端不支持 utf-8 么？

$ echo $TERM
xterm

不对，它支持啊，那只能是 encode_base64 没搞清楚 unicode 了。

perldoc MIME::Base64

“The base64 encoding is only defined for single-byte characters. Use the Encode module to select the byte encoding you want.”

我晕！不过这只是 perl5 的问题。perl5 工作在字节缓冲而不是字符上。

perl5 的字符串可以是 utf8 也可以是 非 utf8 的。一个 utf8 编码的字符却不被允许反而允许的是未知编码集的字节缓冲，为什么地球上会出现这种怪事实在超乎我的想象之外，不过你能怎么办呢。你什么也干不了。base64 是一个二进制协议，基于字节缓冲的。所以我们可以把它解码成字节缓冲。Encode的解码 API 叫做 _encode 。

$ perl -MMIME::Base64 -MEncode -lE'$x="20e3";$s="\x{20e3}";
  printf "0x%s\t%s=> %s",$x,$s,encode_base64(encode('utf8',$s))'
Wide character in printf at -e line 1.
0x20e3  => 4oOj

现在终端警告是这样的了。我们需要用 -C 参数：

$ **perldoc perluniintro**
 
$ perl -C -MMIME::Base64 -MEncode -lE'$x="20e3";$s="\x{20e3}";
  printf "0x%s\t%s=> %s",$x,$s,encode_base64(encode('utf8',$s))'
0x20e3  => 4oOj

回到 rakudo/perl6 和 parrot：

$ cat >m.pir << EOP
.sub main :main
    load_bytecode 'MIME/Base64.pbc'
    $P1 = get_global [ "MIME"; "Base64" ], 'encode_base64'
    $S1 = utf8:"\x{203e}"
    $S2 = $P1(s1)
    say $S1
    say $S2
.end
EOP
 
$ parrot m.pir
FixedIntegerArray: index out of bounds!
current instr.: 'parrot;MIME;Base64;encode_base64'
                pc 163 (runtime/parrot/library/MIME/Base64.pir:147)

Perl6 测试，使用 parrot 库，地址： https://github.com/ronaldxs/perl6-Enc-MIME-Base64/

$ git clone git://github.com/ronaldxs/perl6-Enc-MIME-Base64.git
Cloning into 'perl6-Enc-MIME-Base64'...
 
$ PERL6LIB=perl6-Enc-MIME-Base64/lib perl6 <<EOP
use Enc::MIME::Base64;
say encode_base64_str("\x203e");
EOP
 
> use Enc::MIME::Base64;
Nil
> say encode_base64_str("\x203e");
FixedIntegerArray: index out of bounds!
...

纯 Perl6 实现的方案：

$ PERL6LIB=perl6-Enc-MIME-Base64/lib perl6 <<EOP
use PP::Enc::MIME::Base64;
say encode_base64_str("\x203e");
EOP
 
> use PP::Enc::MIME::Base64;
Nil
> say encode_base64_str("\x203e");
4oC+

等等！Perl6 给出了和 Perl5 不一样的编码？

那用 coreutils base64 命令呢？

$ echo -n "‾" > m.raw
$ od -x m.raw
0000000 80e2 00be
0000003
$ ls -al m.raw
-rw-r--r-- 1 rurban rurban 3 Dec  6 10:23 m.raw
$ base64 m.raw
4oC+

[80e2 00be] 是 [e2 80 be] 的低位优先版本, 把三个字节翻转过来得到的。

好了，至少 base64 和 perl6 是一致的。那肯定是我在 perl5 里犯错了。

回去调试我们的 parrot 问题：

parrot 还没有 perl6 那样的调试器。所以我们只能用 gdb ，我们需要知道错误是在哪个函数里发生的。我们用 parrot 的 -t 跟踪标识，这跟调试 perl5 用的 -Dt 标识很类似，不过 parrot 的这个是一直开启的，哪怕在优化过的发行版里。

$ parrot --help
...
    -t --trace [flags]
    --help-debug
...
$ parrot --help-debug
...
--trace -t [Flags] ...
    0001    opcodes
    0002    find_method
    0004    function calls
 
$ parrot -t7 m.pir
...
009f band I9, I2, 63         I9=0 I2=0
00a3 set I10, P0[I5]         I10=0 P0=**FixedIntegerArray**=PMC(0xff7638) I5=[**2063**]
016c get_results PC2 (1), P2 PC2=FixedIntegerArray=PMC(0xedd178) P2=PMCNULL
016f finalize P2             P2=Exception=PMC(0x16ed498)
0171 pop_eh
_lots of error handling_
...
0248 callmethodcc P0, "print" P0=FileHandle=PMC(0xedcca0)
FixedIntegerArray: index out of bounds!

最后我们看到问题了，这里匹配上了最开始说的那个运行时错误。
00a3 **set I10, P0[I5]**         I10=0 P0=**FixedIntegerArray**=PMC(0xff7638) I5=[**2063**]

我们希望把 I10 的值赋给 固定整数数组 P0 里的 I5=2063 这个元素，但是数组不够大。

经过几个小时的分析工作，我得到的结论是：parrot 的 MIME::Base64 库对字符串里的每个字符使用 ord 是不正确的。它应该使用 bytebuffer 才对。

这个问题已经在 commit 3a48e6 里修复。ord可以范围大于 255 的int形，但 base64 只能处理小于 255 的char型。

修复后的 parrot 库现在是正确的了：

$ parrot m.pir
‾
4oC+

但是随后测试却失败了。我花了好几周时间试图理解为什么 parrot 的测试集会在 mime_base64 测试中出错，测试数据来自 perl5 。我想出了各种符合测试集的不同实现，但是最后还是咬着牙修改了测试以匹配我的实现。

And I had to special case the tests for big-endian, as base64 is endian agnostic. You cannot decode a base64 encoded powerpc file on an intel machine, when you use multi-byte characters. And utf-8 is even more multi-byte than ucs-2. I had to accept the fact the big-endian will return a different encoding. Before the results were the same. The tests were written to return the same encoding on little and big-endian. 然后我单独做了高位优先的测试用例。因为 base64 是不知道高位还是低位优先的。如果是多字节字符的花，你可没法在一台 intel 的机器上解码一个在 powerpc 上用 base64 编码的文件。而 utf-8 比 ucs-2 更加的多字节。我只能接受高位优先会返回不同编码的事实。在结果之前的都一样，测试现在写成了返回高位低位优先都相同的编码。 综述

我写这篇博客的第一个原因是展示一下如何调试这类令人崩溃的问题。如果你对核心实现、库、规范或者测试是否正确抱有怀疑，调试一下吧。比方这里，库和测试就是错的。

你已经看到用 gdb 调试这类问题是多么的轻松，只要你找到断点就完成了。

内部字符表现看起来就像这样：

MIME::Base64 内部:
len=1, encoding=utf-8, buf=[3e20]

而 parrot 的 imcc 编译器内部：
len=8, buf="utf-8:\"\x{203e}\""

parrot 是基于注册的运行时。而 SREG 是注册值的字符表现。不幸的是 SREG 还无法处理编码信息，所以我们把编码加在了字符前面，然后用双引号包含。当然这不是 parrot 依然比 perl5 虚拟机慢的原因。我 测试过 这点。parrot 在内部使用了过多的 sprintf ，编码双引号的耗时只占 sprintf 的第四位。

而且 parrot 的函数调用非常缓慢，亟需优化。

第二个原因是打算解释新的 decode\_base64 接口。这是只有 parrot - 当然也就包括所有基于parrot的语言比如rakudo - 才有的。 decode_base64(str, ?:encoding)

_"通过调用 decode_base64() 函数来解码一个 base64 字符。

这个函数要以待解码的字符位第一个参数，可选参数是针对解码出来的数据的编码字符。 它会返回解码后的数据。 所有非 65个字符的 base64 子集的字符都默默的被禁用了。 字符串后出现 "=" 字符的不会被解码"_

所以 decode_base64 还有第二个可选的编码参数。encode_base64的源字符串可以被任意编码而且自动解码成字节缓冲。你可以很容易的编码一个图片或者 unicode 字符串，而且你可以定义需要的编码给解码器。结果会被编码成 binary 或者 utf-8 或者其他任何编码。你肯定更喜欢不需要任何附加解码的结果。默认解码后的字符的编码是 ascii，latin-1或者latin-8。parrot 会自动升级编码。

你可以比较 pir 新的例子和 perl5 的版本:

parrot:

.sub main :main
    load_bytecode 'MIME/Base64.pbc'
 
    .local pmc enc_sub
    enc_sub = get_global [ "MIME"; "Base64" ], 'encode_base64'
 
    .local string result_encode
    # GH 814
    result_encode = enc_sub(utf8:"\x{a2}")
    say   "encode:   utf8:\"\\x{a2}\""
    say   "expected: wqI="
    print "result:   "
    say result_encode
 
    # GH 813
    result_encode = enc_sub(utf8:"\x{203e}")
    say   "encode:   utf8:\"\\x{203e}\""
    say   "expected: 4oC+"
    print "result:   "
    say result_encode
 
.end

perl5:

use MIME::Base64 qw(encode_base64 decode_base64);
use Encode qw(encode);
 
my $encoded = encode_base64(encode("UTF-8", "\x{a2}"));
print  "encode:   utf-8:\"\\x{a2}\"  - ", encode("UTF-8", "\x{a2}"), "\n";
print  "expected: wqI=\n";
print  "result:   $encoded\n";
print  "decode:   ",decode_base64("wqI="),"\n\n"; # 302 242
 
my $encoded = encode_base64(encode("UTF-8", "\x{203e}"));
print  "encode:   utf-8:\"\\x{203e}\"  -> ",encode("UTF-8", "\x{203e}"),"\n";
print  "expected: 4oC+\n";
print  "result:   $encoded\n"; # 342 200 276
print  "decode:   ",decode_base64("4oC+"),"\n";
 
for ([qq(a2)],[qq(c2a2)],[qw(203e)],[qw(3e 20)],[qw(1000)],[qw(00c7)],[qw(00ff 0000)]){
    $s = pack "H*",@{$_};
    printf "0x%s\t=> %s", join("",@{$_}), encode_base64($s);
}

perl6:

use Enc::MIME::Base64;
say encode_base64_str("\xa2");
say encode_base64_str("\x203e");

来源： < https://github.com/sxw2k/perl6advent_cn/blob/master/chinese/2012/%E7%AC%AC%E4%B8%83%E5%A4%A9:%E5%9C%A8%E7%BC%96%E7%A0%81%E7%9A%84%E5%AD%97%E7%AC%A6%E4%B8%B2%E4%B8%8A%E7%94%A8MIME::Base64%E6%A8%A1%E5%9D%97.markdown >  