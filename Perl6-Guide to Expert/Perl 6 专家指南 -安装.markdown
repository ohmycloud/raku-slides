Perl 6 专家指南 -_gt_ 安装Rakudo （1.3）
分类: Perl6
日期: 2013-05-16 22:56

Installing Rakudo

  While there are monthly releases of Parrot and separately releases of Rakudo, you cannot really "install" them yet. Besides their development is still so fast that I'd recommend using the latest as checked out from their respective version controls system. That's what I am going to describe here.
Currently the recommended way to install Rakudo is the following:

For this you'll need to have Git installed:

Linux
  $ cd ~
  $ mkdir somedir
  $ cd somedir
  $ git clone git://github.com/rakudo/rakudo.git
  $ cd rakudo
  $ perl Configure.pl --gen-parrot
  $ make
  $ make test
  $ make install
  $ make spectest

Windows
First install DWIM Perl for Windows and Git for Windows . Then open a command window by clicking on Start/Run and typing in cmd in command line.

  c:> cd \
  c:> mkdir somedir
  c:> cd somedir
  c:> git clone git://github.com/rakudo/rakudo.git
  c:> cd rakudo
  c:> perl Configure.pl --gen-parrot
  c:> gmake
  c:> gmake test
  c:> gmake install
  c:> gmake spectest

For up-to-date instructions, please visit the Rakudo web site .
