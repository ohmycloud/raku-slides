 Settings - Login - Register - Help
 Home
 Search


Quick jump:  What's new - Weblogs


 

Print
Tools
Export as HTML
Export to PDF
Export to Word


 

 V


 Perl 6
 Perl 6 Operator Tablet


 Contents
 Comparison
 Smartmatch
 Equality
 Traversing Sequence
 Generic Comparison
 Numerical Comparison
 String Comparison
 joined comparison
 Junctions
 Ranges
 logical selection
 ternary
 flipflop
 file test
 yadda

 context forcing scalar ops
 bool context
 numeric context
 numerical selection

 String context

 Ops for arrays/lists
 List generation
 Sequence Operator

 Zip
 Combinators
 Hyperops
 Reduce
 Triangle
 Feed Ops

 Assignment ops
 self assigning ops

 precedence table
 intentionally not existing ops
 making own operators





Perl folklore: Perl is an operator based language.

Perl 6 has a huge amount of operators, because they support 2 of the main design goals: they offer dense and readable code. 2 + 3 is certainly shorter and easier to understand then add(2,3) , since pictograms can be picked up faster than words. (Fortran made his whole carrier on that). But because they are so many, they had to be sorted by a rule named huffman coding , which was applied here more than in any other part of the syntax.

To understand an operator you have to know his arity (how many parameters he takes - usually one (!) or two (+) ).

The precedence tells which operator to prefer in case of conflict, when no braces are used (round braces are only used for grouping and managing precedence). It allows 2 + 3 * 5 to return 17, not 25, which would upset your math teacher.

Behind that link is a table which also tells you also the associativity of every operator. This tells you after which rule to resolve precedence if one operator is used several times like in 2 * 3 * 7 . Comparison Smartmatch

This is the most mighty (much more mighty than its backported Perl 5 twin) of all Perl 6 operators. It can be called the "compare-this-with-that-operator" . If the left side of that infix op matches somehow the content of the right side, it returns Bool::True, otherwise Bool::False. The negated form !~ naturally works the other way around. The exact comparison operation depends on the data types of the values on both sides. Just look into that large table to check your specific case.

Smartmatching was originally invented to make matching with regex semantically sane. ~~ !~
Equality eqv eq == ===
!= !==
Traversing Sequence ++ -- succ pred


sequence generation Generic Comparison before after cmp
Numerical Comparison < == > <=> <= >=
String Comparison lt eq gt leg le ge
joined comparison 3 < $a == $a < 7


is not the same as 3 < $a < 7


because latter is evaled at once and the first in 2 steps (left to right) Junctions | & ^ !
any all one none
Ranges .. ^
logical selection && - and
|| - or
// - err
^^ - xor


see also numerical selection ternary ?? !!
flipflop ff fff
file test

table yadda ...
???
!!!
context forcing scalar ops bool context ? !
?& ?| ?^
numeric context + - * ** / % %%
+& +| +^ +< +>
mod exp sqrt sin cos tan log log10
numerical selection min max minmax
String context ~ x
~& ~| ~^ ~< ~>
Ops for arrays/lists List generation

The simplest way to create a list is by repeating some values: 'munch' xx 3 # results in 'munch', 'munch', 'munch'
('hallo', 'echo') xx 2 --> 'hallo', 'echo', 'hallo', 'echo'


In list context the range operator produces lists: @ 2 .. 7 --> 2,3,4,5,6,7
Sequence Operator ...


traversing sequence Zip Z
Combinators X
Hyperops << >>
Reduce [ ]
Triangle [\ ]
Feed Ops <== ==>
<<== ==>>
Assignment ops self assigning ops precedence table

is in Appendix B intentionally not existing ops making own operators
 


Created by Herbert Breunung on Sep 25 12:46pm . Updated by Herbert Breunung on Apr 16 4:56pm .
-  14373 views  - 34 revisions

Settings - Login - Register - Help
Home
 Search



 

 Save

 Preview

 Cancel
Simple Advanced Edit Tips
 

 Editing:  Perl 6 Operator Tablet
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