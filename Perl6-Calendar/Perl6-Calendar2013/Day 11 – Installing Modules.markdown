Day 11 – Installing Modules By   Tleich


“Honey, I can’t find my keys!”
– “Hmmm, have you already looked at  home  or  site ?”

Preface:  This post is about a new feature which currently resides in the branches  rakudo/eleven  and  panda/eleven .

So this post is about installing “modules” and finding them again later. I quoted the word “modules” here because we are not really talking about modules. Even when we say that we meant classes, roles, grammars and every other packagy type by that term, we’re in fact talking about distributions.

That is what we see when we look at  modules.perl6.org . These things that have a name, an author or authority and hopefully a version, are the things that provide compilation units which then can be loaded later using statements like  use Foo ,  need Bar  or  require Baz .

But these distributions can ship other information as well: executable scripts or music, graphics or fonts that are used by another application.
And this bunch of information that is put in a paper bag called distribution, labeled with name/auth/ver is meant to be downloaded by an installer ( panda ), placed safely on your harddisk, your stick or a webspace, and should be easily locatable later when we need it.

But we are devs, right? We want to use our in-developement-modules without the need to install them. So, there should be a way of telling the compiler that we have a directory structure where our github clones are. These directories should be considered when searching for candidates of a  use  statement. And, to the fact that we are lacking the paper bag in such a situation, these should be preferred, whatever name/auth/version-trait a  use  statement may have attached.

This could be one of our rules of thumb: Not installed modules in a known path are preferred over installed ones.

Our first crux, or: Use it.

use Foo:ver<1.2.3>  does not mean you are loading a module  Foo with version  v1.2.3 . You are in case loading a package  Foo  that is part of a distribution that has the required version and that provides such a namespace.

Al right, we are all good hackers, we can handle that. We would just need a (sort of) database were we can put all installed distributions that we would query later, say, when  use ing a module.

After a few days and the first prototype we would come at a point where we play with panda, our installer toolchain.
We would be ready in so far that panda would install dists into our database. Our tests would show that we could load these installed modules by name, auth and version even when several distributions would supply modules that only differ by version number.
Wasn’t that hard… All fine now?

The second crux, or: The installer installs the installer.

Even panda itself must be installed in our new environment. And that will become insteresting in two ways. We take the pathy way first:
What panda does when we execute its  bootstrap.pl  script is that it loads the not-yet-installed  File::Find  for example, compiles it, and installes it to the destination path, just to pick it up to compile Shell::Command . That breaks the our rule of thumb badly. Now a installed  module should preferred.
It seems like we would need some sort of ordering there.¹

The third crux, or: I thought it is all about modules?

Panda (or perhaps pandora) offers another box for us: It is our first distribution that has executable files.
Okay, we have a problem here. Our task is to install several versions of the same distribution, but all of them are going to provide executables with the same name, but likely with different functionality?
Clearly we need a way of invoking the correct executable. Our shell would just pick the executable that is found in PATH first. We need something better.
What if we would only create one `bin` folder per installation repository? We could have a script that delegates to the correct version of the wanted executable. Querying our wrapper would then look like this:
panda --ver=1.2 install Foo::Bar

Our wrapper would only need to know about parameters named `–auth`, `–name` and `–ver`, and would just pass everything else to the original executable  panda  in this case.
Luckily this helps us in another aspect. We could install wrappers like panda-p and panda-j also, which would explicitely invoke the backends parrot and jvm.

The final chapter.

Let us forget about the subjunctive for a moment, what can we do *now*?

There are two interesting branches:  rakudo/eleven  and panda/eleven . Called after today’s date and the fact that the corresponding spec is the  S11 .
With these two branches you are able to:
configure your directories for vendor, perl, site and home and also your developement paths using the  libraries.cfg .
bootstrap panda which gives you panda, panda-p and panda-j executeables
install modules the “new” way, and also locate them in the following way:
use Foo:ver(*);
use Foo:ver(1.*);
use Foo:ver(/alpha$/);
use Foo:auth<FROGGS>
use Foo:auth({ .substr(0,3) eq 'Bar' });
...
you can invoke executables like:
myscript --auth=Peter rec0001.wav
yourscript --ver="2.*" index.html
...

I hope this will land in the master/nom branch soon, but I think there are a few glitches that need to be discovered and fixed before doing so. (One glitch might be just less Windows® testing from my side.)

Another glitch, now that I think about it: When you load a specific version of a module or execute a script, the magic must make sure that it prefers its own distribution when it loads modules without the need to specify this in the use statements. Otherwise you would execute the  panda  script version  v1  while this loads modules of version  v2 .
This will require additional thought in the S11 specification.

A note for module authors:

You probably know about the  META.info , in most cases you need to add a “provides” section as shown  here .
Without that the packages can’t be  use d. This “provides” section will not break current code, so please add that.

¹) You can set the ordering of the repositories in your libraries.cfg  and in  -I  compiler switches like:
perl6 -ICompUnitRepo::Local::File:prio[10]=/home/peter/project-a:/home/peter/project-b

来源： < http://perl6advent.wordpress.com/2013/12/11/day-11-installing-modules/ >  