




 V


 Perl 6
 Perl 6 Variable Tablet

 Contents
 Variable Types
 Scalar
 Scalar Methods

 Array
 Array Slices
 Array Methods

 Hash
 Hash Slices
 Hash Methods

 Callable

 Data Types
 Pair
 Enumeration
 Capture

 Properties and Traits
 Properties
 Traits

 Scoping
 Twigils

 Assignment and Binding
 Assignment
 Binding

 Special Variables





Allison Randal : The most basic building blocks of a programming language are its nouns, the chunks of data that get sucked in, pushed around, altered in various ways, and spat out to some new location. 变量类型

Perl 6 (as Perl 5) knows 3 basic types of variables: Scalars (single values), Arrays (ordered and indexed lists of several values) and Hashes (2 column table, with ID and associated value pairs). They can be easily distinguished, because in front of their name is a special character called sigil (latin for sign). Its the $ (similar to S) for Scalars, @ (like an a) for Arrays and a % (kv pair icon) for a Hash. They are now invariant (not changing), which means for instance, an array vaiable starts always with an @, even if you just want a slice of the content. $scalar
@array
@array[1] ####### $array[1] in Perl 5
@array[1,2]###### @array[1,2] in Perl 5
%hash
%hash{'ba'} ######### $hash{'ba'} in Perl 5
%hash{'ba','da','bim'} ### @hash{'ba','da','bim'} in Perl 5


The sigils mark also distinct namespaces, meaning: in one lexical scope you can have 3 different variables named $stuff, @stuff and %stuff. These sigils can also be used as an operator to enforce a context in which the following data will be seen.

The fourth namespace where you can store and retrieve something under specified names is the one of subroutines and alike , even if you don't might think of them as variables. It's sigil & has to be used only rarely.

Special namespaces of Perl 5 (often marked with special syntax) like tokens (__PACKAGE__), formats, file or dir handle and builtins are now regular (mostly scalar) variables or routines.

Because variables are (as anything in Perl 6) objects , they have methods. In fact, any operator , including these square or curly brackets you get specific array and hash values with, are just methods of a variable object with a fancy name.

The primary sigil can be followed by a secondary sigil, called twigil, which mostly indicate special scope of that variable. 标量

This type is known as a storage room for one value, but it's more like a reference that can point to anything: to values of any data type, to code , to objects or to a compound of values like a pair , junction , array , hash or capture . The scalar context is now called item context hence the scalar instruction from Perl 5 was renamed to item . $CHAPTER = 3; # first comment!
$bin = 0b11; # same value in binary format
$pi = 3.14159_26535_89793; # the underscores just ease reading
$float = 6.02e-23; # floating number in scientific notation
$text = 'Welcome all!'; # single quoted string
$text = " What is $pi? " ; # double quoted string , does eval $pi to its content
$text = q:to'EOT'; # heredoc string handy for multiline text
like HTML templates or email EOT
$handle = open $file_name; # file handle
$object = Class::Name.new(); # an object from a class with a nested namespace
$condition = 3|5|7; # a junction , a logical conjunction of values
$arrayref = [0,1,1,2,3,5,8,13,21]; # a reference to a list of values
$hashref = {'audreyt'=>'pugs', 'pm'=>'pct', 'damian'=>'larrys evil henchman'}; # reference to a hash
$coderef = sub { do_something_completely_diffenent(@_) }; # pointing to a callable


Unlike Perl 5, references are automatically dereferenced to a fitting context. So you could use these $arrayref and $hashref in same way as an array or hash, making $ the universal variable highlighter or prefix, pretty much like in PHP. Scalar Methods my $chapter = 3;
undefine $chapter;
defined $a; # false, returns 0
数组

is an ordered and indexed list of scalar variables . If not specified otherwise, they can be changed, prolonged and shorten anytime and used as a list, stack, queue and much more. As in Haskell, lists are processed lazily, which means: the compiler looks only at the part he currently needs. This way Perl 6 can handle infinite lists or do computation on lists that are still building up. The lazy command enforces and the eager command prevents that behaviour on any expression.

The list context is forced with a @ operator or _list()_ command . That's not autoflattening like in Perl 5 (automatically convert a List of Lists into one List). If you still want that, say flat(). Or say lol() to explicitly prevent autoflattening.
@primes = (2,3,5,7,11,13,17,19,23); # an array gets filled like in Perl 5

@primes =  2,3,5,7,11,13,17,19,23 ; # same thing, since unlike P5 round braces just do group

@primes = <2 3 5 7 11 13 17 19 23>; # dito, <> is the new qw()

$arrayref = 2,3,5,7,11,13,17,19,23; # in scalar context you get automatically a reference

$arrayref = item @primes;           # same thing, more explicit

$arrayref = 13,;                    # comma is the new array generator

@primes = 2;                        # array with one element

@primes = [2,3,5,7,11,13,17,19,23]; # array with one element (arrayref)

@dev    = {'dan' => 'parrot'};      # array with one element (hashref)

@data   = [1..5],[6..10],[11..15];  # Array of Arrays (AoA)

@list   = lol @data;                # no change

@list   = flat @data;               # returns 1..15


数组切片
@primes                       # all values as list

@primes.values                # same thing   

@primes.keys                  # list of all indices

"@primes[]"                   # insert all values in a string, uses [] as distinction from mail adresses

$prime = @primes[0];          # get the first prime

$prime = @primes[*-1];        # get the last one

@some = @primes[2..5];        # get several

$cell = @data[1][2];          # get 8, third value of second value (list)

$cell = @data[1;2];           # same thing, shorten syntax

@numbers = @data[1];          # get a copy of the second subarray (6..10)

@copy = @data;                # copy the whole AoA, no more reference passing, use binding instead


数组方法

Some of the more important things you can do with lists. All the methods can also used like ops in "elems @rray;"
? @rray;              # boolean context, Bool::True if array has any value in it, even if its a 0

+ @rray;              # numeric context, number of elements (like in Perl 5 scalar @a)

~ @rray;              # string context, you get content of all cells, stringified and joined, same as "@primes[]"


@rray.elems;          # same as + @rray

@rray.end;            # number of the last element, equal to @rray.elems-1

@rray.cat;            # same ~ @rray

@rray.join('');       # also same result, you can put another string as parameter that gets between all values

@rray.unshift;        # prepend one value to the array

@rray.shift;          # remove the first value and return it

@rray.push;           # add one value on the end

@rray.pop;            # remove one value from the end and return it

@rray.splice($pos,$n);# remove on $pos $n values and replace them with values that follow that two parameter

@rray.delete(@ind);   # delete all cell with indecies of @ind

@rray.exists(@ind);   # Bool::True if all indecies of @ind have a value (can be 0 or '')

@rray.pick([$n]);     # return $n (default is 1) randomly selected values, without duplication

@rray.roll([$n]);     # return $n (default is 1) randomly selected values, duplication possible (like roll dice)

@rray.reverse;        # all elements in reversed order

@rray.rotate($n);     # returns a list where $n times first item is taken to last position if $n is positive, if negative the other way around

@rray.sort($coderef); # returns a sorted list by a userdefined criteria, default is alphanumerical sorting

@rray.min;            # numerical smallest value of that array

@rray.max;            # numerical largest value of that array

$a,$b= @rray.minmax;  # both at once, like in .sort . min or .max a sorting algorith can be provided


@rray.map($coderef);  # high oder map function, runs $coderef with every value as $_ and returns the list or results

@rray.classify($cr);  # kind of map, but creates a hash, where keys are the results of $cr and values are from @rray

@rray.categorize($cr);# kind of classify, but closure can have no (Nil) or several results, so a key can have a list of values

@rray.grep({$_>1});   # high order grep, returns only these elements that pass a condition ($cr returns something positive)

@rray.first($coder);  # kind of grep, return just the first matching value

@rray.zip;            # join arrays by picking first element left successively from here and then there




There is even a whole class of metaoperators that work upon lists. 散列

is in Perl 6 an unordered list of Pairs. A Pair is a single key => value association and appears in many places of the language syntax.
%dev =  'pugs'=>'audreyt', 'pct'=>'pm', "STD"=>'larry';

%dev = :rakudo('jnthn'), :testsuite('moritz');            # adverb (pair) syntax works as well

%dev = ('audreyt', 'pugs', 'pm', 'pct', 'larry', "STD");  # lists get autoconverted in hash context

%compiler = Parrot => {Rakudo => 'jnthn'}, SMOP => {Mildew => 'ruoso'};       # hash of hashes (HoH)


散列切片
$value = %dev{'key'};      # just give me the value related to that key, like in P5

$value = %dev<pm>;         # <> autoquotes like qw() in P5

$value = %dev<<$name>>;    # same thing, just with eval

@values = %dev{'key1', 'key2'};

@values = %dev<key1 key2>;

@values = %dev<<key1 key2 $key3>>;

%compiler<Parrot><Rakudo>; # value in a HoH, returns 'jnthn'

%compiler<SMOP>;           # returns the Pair: Mildew => 'ruoso'


%dev   {'audrey'};         # error, spaces between varname and braces (postcircumfix operator) are no longer allowed

%dev\  {'allison'};        # works, quote the space

%dev   .<dukeleto>;        # error

%dev\ .{'patrick'};        # works too, "long dot style", because its its an object in truth 


散列方法
 ? %dev                    # bool context, true if hash has any pairs

 + %dev                    # numeric context, returns number of pairs(keys)

 ~ %dev                    # string context, nicely formatted 2 column table using \t and \n


$table = %dev;             # same as ~ %dev

%dev.say;                  # stringified, but only $key and $value are separated by \t

@pairs = %dev;             # list of all containing pairs

%dev.pairs                 # same thing in all context

%dev.elems                 # same as + %dev or + %dev.pairs

%dev.keys                  # returns the list with all keys

%dev.values                # list of all values

%dev.kv                    # flat list with key1, value1, key 2 ...

%dev.invert                # reverse all key => value relations

%dev.push (@pairs)         # inserts a list of pairs, if a key is already present in %dev, both values gets added to an array


Callable

Internally subroutines , methods and alike are variables with the sigil & and stored in a fourth namespace. They are no more builtins with an own namespace, that can't be overwritten or augmented with your programming. Of course scalars can also point to routines.
&function = sub { ... };         # store subroutine in callable namespace

function();                      # call/run it


$coderef = sub { ... };          # store it in a scalar

$coderef($several, $parameter);  # run that code


数据类型

In contrast to variable types (container types) every value has a type too. These are also organized internally as classes or roles and can be categorized into 3 piles: the undefined, immutable and the mutable types.

You can explicitly assign one of these types to you scalar, array or hash variable. my Int $a;
my Array of Int @a;
Pair

are very new and their syntax is used nearly everywhere in the language, where you have associations between a name and a value.
$pair = 'jakub' => 'helena';  # "=>" is the pair constructor

$pair = :jakub('helena');     # same in adverbial notation

$pair = :jakub<helena>;       # same using <>, the new qw()

$pair.key                     # returns 'jakub'

$pair.value                   # returns 'helena'

$pair.isa(Pair)               # Bool::True


Enumeration
enum


Capture

also a new type, that can hold all or a part of the parameters a routine gets. Because Perl knows now positional as well as named parameters, it es some mixture of a list and array.
$cap = \(@a,$s,%h);           # creating a capture, "\" was free since there are no references anymore

| $cap                        # flatten into argument list (hash like context)

|| $cap                       # flatten into semicolon list (array like context)




One important difference between a compound structure of lists and hashes and a capture: while assignments with = the complete content of the named variables will be copied. But not so in the case of a capture. When I change $s in the last example, the content of $cap changes too, because when parameters to a routine are variables, they are also interpolated in the moment the routine is called, not when its defined. Properties and Traits Properties Traits 作用域

scope declarator , scopes my $var;
state
temp
let
our $var;
$*var;
Twigils 赋值和绑定 赋值

As rightfully expected, assignments are done with the equal sign. But unlike Perl 5 you always get a copy of the right side data assigned to the left, no matter how nested the data structure was (lists of lists eg). You never get in Perl 6 a reference with =. As the only exception may be seen captures . my @original = [1,2],[3,4];
my $copy = @original[0]; # $copy points to [1,2]
@original[0][0] = 'fresh stuff'; # $copy[0] holds still 1
绑定

Since Perl 6 doesn't know of any references, programmer have to use binding to get 2 variables that point to the same memory location.
$original = 5;

$original := $mirror;       # normal binding, done on runtime

$original ::= $mirror;      # same thing, but done during compile time

$original = 3;

say $mirror;                # prints 3

$original =:= $mirror       # true, because their bound together

$original === $mirror       # alsotrue, because content and type are equal


特殊变量

are listed their table . To understand their secondary sigil go to the twigil chapter of this tablet .



Settings - Login - Register - Help
Home
 Search



 

 Save

 Preview

 Cancel
Simple Advanced Edit Tips
 

 Editing:  Perl 6 Variable Tablet
 Insert... Inter-workspace link Link to a Section Attached Image Attachment Link Table of Contents Page Include Section Marker What's New Tag Link Tag List Weblog Link Weblog List Inline RSS Inline Atom Search Results Google Search Technorati Search AIM Link Yahoo! IM Link Skype Link User Name Date in Local Time Unformatted Convoq Link New Form Page

 Upload files


 Add tags









Upload Files

Click "Browse" to find the file you want to upload. When you click "Upload file" your file will be uploaded and added to the list of attachments for this page.

Maximum file size: 50MB


 
 
Add a link to the attachment at the top of the page? Images will appear in the page.
Expand zip archive and attach individual files to the page

 Done


 

 File Name Author Date Uploaded Size


 Close


 Delete Selected Files



Save Page As

Enter a meaningful and distinctive title for your page.

Page Title:

Tip: You'll be able to find this page later by using the title you choose.

 Cancel

 Save



Page Already Exists

There is already a page named XXX . Would you like to:

Save with a different name:

Save the page with the name " XXX "

Append your text to the bottom of the existing page named: " XXX "

 Cancel

 Ok



Upload Files

Click "Browse" to find the file you want to upload. When you click "Add file," this file will be added to the list of attachments for this page, and uploaded when you save the page.


 
 
Add a link to this attachment at the top of the page? Images will appear in the page.
Expand zip archive and attach individual files to the page?

 Done


 Add file

 
<span class="st-attachmentsqueue-listlabel">${ loc('Files To upload:') } </span> {var lastIndex = queue.length-1} {for file in queue} <span class="st-attachmentsqueue-filelist-name">${file}  <a href="#" onclick="javascript:window.EditQueue.remove_index(${file_index}); return false" title="${ loc('Remove [_1] from the queue', file) }" class="st-attachmentsqueue-filelist-delete">[x]</a> {if file_index != lastIndex}, {/if} {/for}

Add Tags

Enter a tag and click "Add tag". The tag will be saved when you save the page.


Tag: 
 
Suggestions:

 Done


 Add tag

 
Tags to apply: {var lastIndex = queue.length-1} {for tag in queue} <span class="st-tagqueue-taglist-name">${tag} <a href="#" onclick="javascript:window.TagQueue.remove_index(${tag_index}); return false" title="Remove ${tag} from the queue" class="st-tagqueue-taglist-delete">[x]</a>{if tag_index != lastIndex}, {/if} {/for} {var lastIndex = matches.length-1} {for t in matches} <a href="#" onclick="TagQueue.queue_tag('${t.name|escapespecial|quoter}'); return false" title="Add ${t.name} to page" class="st-tags-suggestion" >${t.name}</a>{if t_index != lastIndex}, {/if} {/for}