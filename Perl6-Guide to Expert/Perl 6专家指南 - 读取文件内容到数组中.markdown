Perl 6专家指南 -_gt_ 读取文件内容到数组中
分类: Perl6


Read lines into array
当我们把调用slurp() 的结果放进数组中时，数组中将只有一个元素，该元素的值就是要读取的文件中的所有内容。如果你想读取所有行到数组中不同的元素中，你需要使用 lines 函数。 
examples/files/read_file_into_array.p6
#!/usr/bin/env perl6
use v6;


my $filename = $*PROGRAM_NAME;


# reads all the content of the file in the first element of the array!
my @content = slurp $filename;
say @content.elems;


# reads all the content of the file, every line an element in the array
my @rows = lines $filename.IO;
say @rows.elems;