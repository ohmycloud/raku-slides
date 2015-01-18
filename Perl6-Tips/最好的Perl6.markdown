










Best Of Perl 6 Tablet

 Contents
 Command Line
 File IO
 Automatic multithreading
 Comparison
 Case construct
 Powerful for loops
 Named parameters in subroutines
 Objects with auto generated new and getters and setters





This is a small tour, showing the best features and improvements of Perl 6 in short examples, compared to similar working Perl 5 examples. Command Line 命令行

Making output will become simpler and easier for newbies.
          
     Perl 5                                     Perl 6 

 print "bananas are good\n";                     say "bananas are good";

 print "and I said: $quotes{\"me\"}\n";          say "and I said: %quotes{"me"}.";

 print "and I said: $quotes{\"me\"}\n";          say "and I said: %quotes<me>.";

 print "What is ... ";                           $result = prompt "What is ... ";

 chomp($result = <>);


File IO

File::Slurp is in the Perl 6 core language and file reading is simpler then ever (and autochomp included).
             
  Perl 5                                     Perl 6 

 $content = do { local $/;                       $content = 
slurp 
"poetry.txt";

    open my $FH, "poetry.txt"; <$FH>

 };


chomp(@content = do {                            @content =
 lines
 "poetry.txt";

    open my $FH, "poetry.txt"; <$FH>

});


Automatic multithreading

Applying operations to junctions and arrays is now syntactically compact and readable. Perl 6 will create threads where appropriate to use multiple processors, cores or hyperthreading for high level language SIMD concurrent processing.
           
    Perl 5                                     Perl 6 

 my $sum;                                        my $sum = [+] @numbers;

 $sum += $_ for @numbers;

 for (0 .. $#factor1) {                          @product = @factor1 >>*<< @factor2;

   $product[$] = $factor1[$] * $factor2[$_];

 }




The Perl 5 code is a simplification, of course Perl6 "does the right thing" when the arrays have different lengths. Comparison 比较

Here are junctions, then chained comparison operators.
            
   Perl 5                                     Perl 6 

 if ($a == 3 or $a == 4 or $a == 7) {...}        if $a = 3 | 4 | 7 {...}

 if (4 < $a and $a < 12) {...}                   if 4 < $a < 12 {...} 

 if (4 < $a and $a <= 12) {...}                  if $a ~~ 4^..12 {...}

 $a = defined $b ? $b : $c;                      $a = $b // $c;




The defined-OR operator eases lot of cases where Perl 5 newbies could fall into traps. Case 结构
           
    Perl 5                                      Perl 6 

                                                     
given
 $a {

 if ($a == 2 or $a == 5) {...} }}                      when 2 | 5 {...}

 elsif ($a == 6 or $a == 7 or $a == 8 or $a == 9) {}   when 6 .. 9 {...} 

 elsif ($a =~ /g/) {...}                               when 'g' {...}

 else {...}                                            default {...}

                                                     }




That new construct (backported to 5.10) is clear to read, very versatile and when used in combination with junctions, becomes even clearer. 强大的循环

List iteration via for is now much more versatile.
            
   Perl 5                                     Perl 6 

 for my $i (0..15) {...}                         for 
^
16 -> $i {...}

 for (my $i=15; $i>1; $i-2) {...}                for 15,
*
-2...1 -> $i {...}   # 15 13 11 9 7 5 3 1 

 for my $key (keys %hash) {                      for %hash.kv -> $key, $value {

   print "$key => $hash{$key}\n"; ...              say "$key => $value"; ...

 for my $i (0..$#a) {                            for zip(@a
;
 @b
;
 @c) 
->
 $a
,
 $b
,
 $c {...}

   my $a = @a[$i];

   my $b = @b[$i];

   my $c = @c[$i]; ... 


子例程中的具名参数
           
    Perl 5                                     Perl 6 

 sub routine {                                   sub routine ($a, $b, *@rest) {...}

   my $a = shift;

   my $b = shift;

   my @rest = @_;

 }


Objects with auto generated new and getters and setters

Simple Object creation is now as easy as it gets.
            
   Perl 5                                     Perl 6 

 package Heart::Gold;                            class Heart::Gold {

                                                   has $.speed;

 sub new {                                         method stop { $.speed = 0 }      

   bless {speed => 0 }, shift;                   }  

 }                                               

                                                 my Heart::Gold $hg1 .= new;

 sub speed {                                     $hg1.speed = 100;

   my $self = shift;                             my $hg2 = $hg1.clone;

   my $speed = shift;

   if (defined $speed) { $self->{speed} = $speed }

   else { $self->{speed} }

 }


 sub stop {

   my $self = shift; 

   $self->{speed} = 0;

 }



The new, getter, setter and clone methods are auto generated. Methods now are called "method".




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