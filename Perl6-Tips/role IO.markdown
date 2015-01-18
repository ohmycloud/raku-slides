 Perl 6 Documentation
Search 

role IO
Operators
prompt
dir
role IO { }

The IO role provides no functionality itself, and moreso just marks if a particular object relates to input/output. Operators prompt
sub prompt($msg)

Prints $msg to the standard output and waits for the user to type in something and finish with an ENTER. Returns the string typed in without the trailing newline.
my $name = prompt("Hi, what's your name? "); dir
sub dir(Cool $path = '.', Mu :$test = none('.', '..'))

Returns a list of IO::File and IO::Path objects for the files and directories found in the $path. If $path is not given assumes the current directory.

A second optional parameter can be given that will be matched against the strings to filter out certain entries. By default it filters out the '.' and '..' entries.

Examples:
for dir() -> $file {
   say $file;
}
dir('path/to/directory');

To include all the entries (including . and ..) write:
dir(test => all())

To include only entries with a .pl extension write:
dir(test => /.pl$/)

TODO: more IO Ops Full-size type graph image as SVG


Generated on 2014-03-22T13:18:49-0400 from the sources at perl6/doc on github . This is a work in progress to document Perl 6, and known to be incomplete. Your contribution is appreciated.

The Camelia image is copyright 2009 by Larry Wall.
