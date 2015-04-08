use Term::ProgressBar;
use v6;

my $count = 1000;
my $bar   = Term::ProgressBar.new( count => $count, width => 15, :p, :name<Uploading...>);

for 1..$count {
    shell("clear");
    $bar.update($_);
    $bar.message("$_") if $_ % 100 == 0;
}

my $ba = Term::ProgressBar.new(count => $count, :left<->, :right<->, :style<|>, width => 20, :p);
for 1..1000 {
    $ba.update($_);
    $ba.message("$_") if $_ % 100 == 0;
}
