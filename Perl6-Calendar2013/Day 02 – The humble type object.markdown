Day 02 – The humble type object By   Carl


For some inscrutable reason, we have defined a  Dog  class in today’s post.
class Dog {
    has $.name;
}

Don’t ask me why — maybe we’re writing software for a kennel? Maybe we’re writing software  for  dogs? “Teach your dog how to type!” Clever dogs can do up to 10 words a minute, with surprisingly few typos.

Anyway. Having a  Dog  class gives us the dubious pleasure of being able to create dogs out of thin air and passing them to functions. No surprise there.
sub check(Dog $d) {
    say "Yup, that's a dog for sure.";
}
 
my Dog $dog .= new(:name);
check($dog);     # Yup, that's a dog for sure.

But where there  might  be some surprise — if you haven’t gotten used to the idea of Perl 6′s type objects yet — is that you can also do  this :
check(Dog);      # Yup, that's a dog for sure.

What did we just do there?

We didn’t pass  a  dog to the function, we passed  Dog  to the function. And the function accepts it and says it’s a dog, too. So, Dog  is a dog. Huh.

What’s going on here is that in Perl 6 when we declare a class  Dog like we just did, the word  Dog  ends up having two meanings:
The class  Dog  that we declared.
The  type object   Dog , kind of a patron saint for all  Dog  objects ever instantiated.


Cramming two concepts into one word like this seems like a recipe for failure. But it turns out it works  surprisingly  well.

Before we look at the reasons for using type objects, let’s find out a bit more about what they are.
say Dog;          # (Dog)
say Dog.name;     # ERROR: Cannot look up attributes in a type object
say ?Dog;         # False
say defined Dog;  # False

So, in summary, the  Dog  type object identifies itself as  (Dog) , it refuses to have its attribute inspected, it boolifies to  False , and it’s not defined. Contrast this with an instance of  Dog :
say $dog;         # Dog.new(name => "Fido")
say $dog.name;    # Fido
say ?$dog;        # True
say defined $dog; # True

An instance is everthing the type object isn’t: it knows how to output itself, it will happily tell you its name, and it’s both  True  and defined. Nice.

(Being undefined is only  almost  a surefire way to identify the type object. Someone could have gone through the trouble of making their instance object undefined. As they say in the industry, you don’t  have  to be a type object to be undefined… but it helps!)

And now, as promised, the Top Five Reasons Type Objects Work Surprisingly Well:
Classes actually make sense as objects in the program. There’s this idea that classes have to haughtily refuse to play among the rest of the values in a program, that they have to somehow be like gods looking down on the instances from a Parthenon of class-hood. Perl 5 kind of has it like that. But both Ruby and Python show that classes can behave as more or less normal objects. In Perl 6,  Dog  is also what you get if you do $dog.WHAT .
It fits quite well with the whole smartmatching thing. So what $dog ~~ Dog  actually means is something like “hey,  Dog  type object, does this  $fido  look anything like you?”. The type object doesn’t just sit there, it does useful things like smartmatching.
Another thing: the whole reason that line,  my Dog $dog .= new(:name); , works as it does is because we end up calling .new  on the type object. So here’s what that line does in slow motion. It desugars to a declaration and an assignment. The declaration is  my Dog $dog;  and so, because the  $dog variable needs to start out with  some  undefined value, it starts out with  Dog , the type object. The assignment then is simply $dog.=new , which is short for  $dog = $dog.new . Conveniently, because the type object  Dog  is an object of the type  Dog , it has a  .new  method (inherited from  Mu  in this case) that knows how to construct dogs.
A little detail from that last point, which actually turns out to be a rather big deal: Perl 6 doesn’t really have  undef  like Perl 5 does. It turned out that  undef  wasn’t a really good fit with a type system;  undef  gets in everywhere, and doesn’t really have  a type at all. (A bit like Java’s  null  which is known to have caused people no end of suffering.) So what Perl 6 has instead are these  typed undefined values , namely — you guessed it — the type objects. If you declare a variable  my Int $i , then  $i will start out as undefined, that is, containing the type object Int .
Not only do you sometimes want to call  .new  on the type object, sometimes you have other methods which don’t require an instance. (These kinds of methods are sometimes known as static methods in some languages, and class methods in other languages. Some languages have both of these, and they’re different, just to be confusing.) Again, the type object comes to the rescue here, sort of acts like an instance so that you can call your method on it, and then once again fades into the background. For example, if the class  Dog  had a  method bark { say "woof" }  then the  Dog  type object would be able to bark just as well as actual dog instances. (But the type object still refuses to tell you its  .name , or any of its attributes.)

So that’s type objects for you. They’re sitting in a convenient semantic spot halfway between the class and its instances, sometimes representing one end of the spectrum, sometimes the other.

One thing before we part ways today. It doesn’t happen often, but sometimes you  do  want to be able to tell type objects and real instances apart, for example when accepting parameters in a function:
multi sniff(Dog:U $dog) {
    say "a type object, of course"
}
multi sniff(Dog:D $dog) {
    say "definitely a real dog instance"
}
 
sniff Dog;    # a type object, of course
sniff $dog;   # definitely a real dog instance

Here,  :U  stands for “undefined” and  :D  for “defined”. (And that, dear friends, is how we got a  smiley  into the design of Perl 6. Program language designers, take heed.) As I mentioned parenthetically before, it’s actually possible to be an undefined object without being a type object. For these special occasions, we have  :T , but this modifier isn’t implemented in Rakudo as of this writing. (Though moritz++ informs me that, in Rakudo,  :U  currently has the semantics that  :T  should have.)

Let’s just end this post with maybe the corniest one-liner ever to see the light of day in  #perl6 :
$ perl6 -e 'say (my @a = "Hip " x 2), @a.^name, "!"'
Hip Hip Array!

来源： < http://perl6advent.wordpress.com/2013/12/02/day-02-the-humble-type-object/ >  