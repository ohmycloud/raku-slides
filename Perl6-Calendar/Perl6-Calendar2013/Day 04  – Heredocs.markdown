Day 04 — Heredocs, Theredocs, Everywheredocs docs By   Lueinc


So let’s say you’ve got a bit of documentation to print out, a help statement perhaps. You could use an ordinary string, but it always looks like something you really shouldn’t be doing.

 1
 2
 3
 4
 5
 6
 7
 8
 9
 sub USAGE {
      say "foobar Usage:
 ./foobar <args> <file>
  
 Options:
  
 ...
 ";
 }


Perl 6 has a much better idea for you, fortunately: heredocs! They work a bit differently from Perl 5, and are now invoked using the adverb  :heredoc  on quoting constructs:

 1
 2
 3
 say q:heredoc/END/;
 Hello world!
 END


When you use  :heredoc , the contents of the string are no longer the final contents; they become the string that signifies the end of a heredoc.  q"END"  results in the string  "END" ,  q:heredoc"END" results in everything before the next  END  to appear on its own line.

You will have also noticed that heredocs only start on the next possible line for them to start, not immediately after the construct closes. That semicolon after the construct never gets picked up as part of a heredoc, don’t worry :) .

The  :heredoc  adverb is nice, but it seems a bit long, doesn’t it? Luckily it has a short form,  :to , which is much more commonly used. So that’s what we’ll be using through the rest of the post.

 1
 2
 3
 say q:to"FIN";
 Hello again.
 FIN


You can use any sort of string for the delimiter, so long as there’s no leading whitespace in it. A null delimiter ( q:to// ) is fine too, it just means you end the heredoc with two newlines, effectively a blank line.

And yes, delimiters need to be on their own line. This heredoc never ends:

 1
 2
 say q:to"noend";
 HELLO WORLD noend


A note about indentation: look at this heredoc

 1
 2
 3
 4
 say q:to[finished];
    Hello there
      everybody
 finished


Which of those three heredoc lines decides how much whitespace is removed from the beginning of each line (and thus sets the base level of indentation)? It’s the line with the end delimiter, “finished” in the last example. Lines with more indentation than the delimiter will appear indented by however much extra space they use, and lines with less indentation will be as indented as the delimiter, with a warning about the issue.

(Tabs are considered to be 8 spaces long, unless you change  $?TABSTOP . This usually doesn’t matter unless you mix spaces and tabs for indentation anyway though.)

It doesn’t matter how much the delimiter indentation is, all that matters is indentation relative to the delimiter. So these are all the same:

 1
 2
 3
 4
 say q:to/END/;
 HELLO
    WORLD
 END


 1
 2
 3
 4
 say q:to/END/;
      HELLO
        WORLD
      END


 1
 2
 3
 4
 say q:to/END/;
                 HELLO
                   WORLD
                 END


One other thing to note is that what quoting construct you use will affect how the heredoc contents are parsed, so

 1
 2
 3
 say q:to/EOF/;
 $dlrs dollars and {$cnts} cents.
 EOF


Interpolates nothing,

 1
 2
 3
 say q:to:c/EOF/;
 $dlrs dollars and {$cnts} cents.
 EOF


Interpolates just  {$cnts}  (the  :c  adverb allows for interpolation of just closures), and

 1
 2
 3
 say qq:to/EOF/;
 $dlrs dollars and {$cnts} cents.
 EOF


Interpolates both  $dlrs  and  {$cnts} .

Here’s the coolest part of heredocs: using more than one at once! It’s easy too, just use more than one heredoc quoting construct on the line!

 1
 2
 3
 4
 5
 6
 7
 8
 9
 say q:to/end1/, qq:to/end2/, Q:to/end3/;
 This is q.\\Only some backslashes work though\t.
 $sigils don't interpolate either.
 end1
 This is qq. I can $interpolate-sigils as well as \\ and \t.
 Neat, yes?
 end2
 This is Q. I can do \\ no \t such $things.
 end3


Which, assuming you’ve defined  $interpolate-sigils  to hold the string  "INTERPOLATE SIGILS" , prints out
    This is q.\Only some backslashes work though\t.
    $sigils don't interpolate either.
    This is qq. I can INTERPOLATE SIGILS as well as \ and   .
    Neat, yes?
    This is Q. I can do \\ no \t such $things.

After every end delimiter, the next heredoc to look for its contents starts.

Of course, indentation of different heredocs will help whenever you have to stack a bunch of them like this.

 1
 2
 3
 4
 5
 6
 7
 8
 9
 say qq:to/ONE/, qq:to/TWO/, qq:to/THREE/, qq:to/ONE/;
 The first one.
 ONE
      The second one.
      TWO
 The third one.
 THREE
      The fourth one.
      ONE


Which outputs:
    The first one.
    The second one.
    The third one.
    The fourth one.

(And yes, you don’t have to come up with a unique end delimiter every time. That could have been four  q:to/EOF/  statements and it’d still work.)

One final note you should be aware of when it comes to heredocs. Like the rest of Perl 6 (barring a couple of small exceptions), heredocs are read using one-pass parsing (this means your Perl 6 interpreter won’t re-read or skip ahead to better understand the code you wrote). For heredocs this means Perl 6 will just wait for a newline to start reading heredoc data, instead of looking ahead to try and find the heredoc.

As long as the heredoc contents and the statement that introduces the heredoc are part of the same compilation unit, everything’s fine. In addition to what you’ve seen so far, you can even do stuff like this:

 1
 2
 3
 4
 sub all-info { return q:to/END/ }
 This is a lot of important information,
 and it is carefully formatted.
 END


(If you didn’t put the brace on the same line, it would be part of the heredoc, and then you’d need another brace on a line after END .)

However, things like  BEGIN  blocks start compiling before normal code, so trying that last one with  BEGIN  block fails:

 1
 2
 3
 BEGIN { say q:to/END/ }
 This is only the BEGINning.
 END


You have to put the heredoc inside the  BEGIN  block, with the quoting construct, in order to place them in the same compilation unit.

 1
 2
 3
 4
 5
 BEGIN {
      say q:to/END/;
      This is only the BEGINning.
      END
 }


That’s it for heredocs! When should you use them? I would say whenever you need to type a literal newline (by hitting Enter) into the string. Help output from the  USAGE  sub is probably the most common case. The one at the beginning could easily (and more readably) be written as

 1
 2
 3
 4
 5
 6
 7
 8
 9
 10
 sub USAGE {
      say q:to"EOHELP";
          foobar Usage:
          ./foobar <args> <file>
  
          Options:
  
          ...
          EOHELP
 }


来源： < http://perl6advent.wordpress.com/2013/12/04/day-04-heredocs-theredocs-everywheredocs-docs/ >  