Perl 6专家指南 - exit，warn，die
分类: Perl6


exit
#!/usr/bin/env perl6
use v6;


say "hello";


exit;


say "world"; # 这句不会执行了


warn
#!/usr/bin/env perl6
use v6;


warn "This is a warning"; # 打印警告，带行号


say "Hello World";


die
#!/usr/bin/env perl6
use v6;


say "Before calling die";


die "This will kill the script";


say "This will not show up";

