 Perl 6 Documentation
Search 

Classes and Objects
Starting with class
I can haz state?
Methods
Constructors
Consuming our class
Inheritance
Overriding Inherited Methods
Multiple Inheritance
Introspection

The following program shows how a dependency handler might look in Perl 6. It showcases custom constructors, private and public attributes, methods and various aspects of signatures. It's not very much code, and yet the result is interesting and, at times, useful.
    class Task {
        has      &!callback;
        has Task @!dependencies;
        has Bool $.done;

        method new(&callback, Task *@dependencies) {
            return self.bless(:&callback, :@dependencies);
        }

        method add-dependency(Task $dependency) {
            push @!dependencies, $dependency;
        }

        method perform() {
            unless $!done {
                .perform() for @!dependencies;
                &!callback();
                $!done = True;
            }
        }
    }

    my $eat =
        Task.new({ say 'eating dinner. NOM!' },
            Task.new({ say 'making dinner' },
                Task.new({ say 'buying food' },
                    Task.new({ say 'making some money' }),
                    Task.new({ say 'going to the store' })
                ),
                Task.new({ say 'cleaning kitchen' })
            )
        );

    $eat.perform();
 Starting with class





Perl 6, like many other languages, uses the class keyword to introduce a new class. The block that follows may contain arbitrary code, just as with any other block, but classes commonly contain state and behavior declarations. The example code includes attributes (state), introduced through the has keyword, and behaviors introduced through the method keyword.



Declaring a class creates a type object which, by default, is installed into the current package (just like a variable declared with our scope). This type object is an "empty instance" of the class. You've already seen these in previous chapters. For example, types such as Int and Str refer to the type object of one of the Perl 6 built- in classes. The example above uses the class name Task so that other code can refer to it later, such as to create class instances by calling the new method.

Type objects are undefined , in the sense that they return False if you call the .defined method on them. You can use this method to find out if a given object is a type object or not:
    my $obj = Int;
    if $obj.defined {
        say "Ordinary, defined object";
    } else {
        say "Type object";
    }
 I can haz state?





The first three lines inside the class block all declare attributes (called fields or instance storage in other languages). These are storage locations that every instance of a class will obtain. Just as a my variable can not be accessed from the outside of its declared scope, attributes are not accessible outside of the class. This encapsulation is one of the key principles of object oriented design.

The first declaration specifies instance storage for a callback -- a bit of code to invoke in order to perform the task that an object represents:
    has &!callback;




The & sigil indicates that this attribute represents something invocable. The ! character is a twigil , or secondary sigil. A twigil forms part of the name of the variable. In this case, the ! twigil emphasizes that this attribute is private to the class.

The second declaration also uses the private twigil:
    has Task @!dependencies;


However, this attribute represents an array of items, so it requires the @ sigil. These items each specify a task that must be completed before the present one can complete. Furthermore, the type declaration on this attribute indicates that the array may only hold instances of the Task class (or some subclass of it).

The third attribute represents the state of completion of a task:
    has Bool $.done;




This scalar attribute (with the $ sigil) has a type of Bool . Instead of the ! twigil, this twigil is . . While Perl 6 does enforce encapsulation on attributes, it also saves you from writing accessor methods. Replacing the ! with a . both declares the attribute $!done and an accessor method named done . It's as if you had written:
    has Bool $!done;
    method done() { return $!done }


Note that this is not like declaring a public attribute, as some languages allow; you really get both a private storage location and a method, without having to write the method by hand. You are free instead to write your own accessor method, if at some future point you need to do something more complex than return the value.

Note that using the . twigil has created a method that will provide with readonly access to the attribute. If instead the users of this object should be able to reset a task's completion state (perhaps to perform it again), you can change the attribute declaration:
    has Bool $.done is rw;




The is rw trait causes the generated accessor method to return something external code can modify to change the value of the attribute. Methods



While attributes give objects state, methods give objects behaviors. Ignore the new method temporarily; it's a special type of method. Consider the second method, add-dependency , which adds a new task to this task's dependency list.
    method add-dependency(Task $dependency) {
        push @!dependencies, $dependency;
    }




In many ways, this looks a lot like a sub declaration. However, there are two important differences. First, declaring this routine as a method adds it to the list of methods for the current class. Thus any instance of the Task class can call this method with the . method call operator. Second, a method places its invocant into the special variable self .

The method itself takes the passed parameter--which must be an instance of the Task class--and push es it onto the invocant's @!dependencies attribute.

The second method contains the main logic of the dependency handler:
    method perform() {
        unless $!done {
            .perform() for @!dependencies;
            &!callback();
            $!done = True;
        }
    }


It takes no parameters, working instead with the object's attributes. First, it checks if the task has already completed by checking the $!done attribute. If so, there's nothing to do.



Otherwise, the method performs all of the task's dependencies, using the for construct to iterate over all of the items in the @!dependencies attribute. This iteration places each item--each a Task object--into the topic variable, $_ . Using the . method call operator without specifying an explicit invocant uses the current topic as the invocant. Thus the iteration construct calls the .perform() method on every Task object in the @!dependencies attribute of the current invocant.

After all of the dependencies have completed, it's time to perform the current Task 's task by invoking the &!callback attribute directly; this is the purpose of the parentheses. Finally, the method sets the $!done attribute to True , so that subsequent invocations of perform on this object (if this Task is a dependency of another Task , for example) will not repeat the task. Constructors



Perl 6 is rather more liberal than many languages in the area of constructors. A constructor is anything that returns an instance of the class. Furthermore, constructors are ordinary methods. You inherit a default constructor named new from the base class Object , but you are free to override new , as this example does:
    method new(&callback, Task *@dependencies) {
        return self.bless(:&callback, :@dependencies);
    }




The biggest difference between constructors in Perl 6 and constructors in languages such as C# and Java is that rather than setting up state on a somehow already magically created object, Perl 6 constructors actually create the object themselves. This easiest way to do this is by calling the bless method, also inherited from Mu . The bless method expects a set of named parameters providing the initial values for each attribute.

The example's constructor turns positional arguments into named arguments, so that the class can provide a nice constructor for its users. The first parameter is the callback (the thing to do to execute the task). The rest of the parameters are dependent Task instances. The constructor captures these into the @dependencies slurpy array and passes them as named parameters to bless (note that :&callback uses the name of the variable--minus the sigil--as the name of the parameter). Consuming our class

After creating a class, you can create instances of the class. Declaring a custom constructor provides a simple way of declaring tasks along with their dependencies. To create a single task with no dependencies, write:
    my $eat = Task.new({ say 'eating dinner. NOM!' });


An earlier section explained that declaring the class Task installed a type object in the namespace. This type object is a kind of "empty instance" of the class, specifically an instance without any state. You can call methods on that instance, as long as they do not try to access any state; new is an example, as it creates a new object rather than modifying or accessing an existing object.

Unfortunately, dinner never magically happens. It has dependent tasks:
    my $eat =
        Task.new({ say 'eating dinner. NOM!' },
            Task.new({ say 'making dinner' },
                Task.new({ say 'buying food' },
                    Task.new({ say 'making some money' }),
                    Task.new({ say 'going to the store' })
                ),
                Task.new({ say 'cleaning kitchen' })
            )
        );


Notice how the custom constructor and sensible use of whitespace allows a layout which makes task dependencies clear.

Finally, the perform method call recursively calls the perform method on the various other dependencies in order, giving the output:
    making some money
    going to the store
    buying food
    cleaning kitchen
    making dinner
    eating dinner. NOM!
 Inheritance

Object Oriented Programming provides the concept of inheritance as one of the  mechanisms to allow for code reuse. Perl 6 supports the ability for one class  to inherit from one or more classes. When a class inherits from another class that informs the method dispatcher to follow the inheritance chain to look for a method to dispatch. This happens both for standard methods defined via the method keyword and for methods generated through other means such as  attribute accessors.

TODO: the example here is rather bad, and needs to be replaced (or much improved). See https://github.com/perl6/book/issues/58 for discussion.
    class Employee {
        has $.salary;

        method pay() {
            say "Here is \$$.salary";
        }

    }

    class Programmer is Employee {
        has @.known_languages is rw;
        has $.favorite_editor;

        method code_to_solve( $problem ) {
            say "Solving $problem using $.favorite_editor in " 
            ~ $.known_languages[0] ~ '.';
        }
    }


Now any object of type Programmer can make use of the methods and accessors  defined in the Employee class as though they were from the Programmer class.
    my $programmer = Programmer.new(
        salary => 100_000, 
        known_languages => <Perl5 Perl6 Erlang C++>,
        favorite_editor => 'vim'
    );

    $programmer.code_to_solve('halting problem');
    $programmer.pay();
 Overriding Inherited Methods

Of course, classes can override methods and attributes defined by parent  classes by defining their own. The example below demonstrates the Baker class  overriding the Cook 's cook method.
    class Cook is Employee {
        has @.utensils  is rw;
        has @.cookbooks is rw;

        method cook( $food ) {
            say "Cooking $food";
        }

        method clean_utensils {
            say "Cleaning $_" for @.utensils;
        }
    }

    class Baker is Cook {
        method cook( $confection ) {
            say "Baking a tasty $confection";
        }
    }

    my $cook = Cook.new( 
        utensils => (<spoon ladle knife pan>), 
        cookbooks => ('The Joy of Cooking'), 
        salary => 40000);

    $cook.cook( 'pizza' ); # Cooking pizza

    my $baker = Baker.new(
        utensils => ('self cleaning oven'), 
        cookbooks => ("The Baker's Apprentice"), 
        salary => 50000);

    $baker.cook('brioche'); # Baking a tasty brioche


Because the dispatcher will see the cook method on Baker before it moves up to  the parent class the Baker 's cook method will be called. Multiple Inheritance

As mentioned before, a class can inherit from multiple classes. When a class  inherits from multiple classes the dispatcher knows to look at both classes when looking up a method to search for. As a side note, Perl 6 uses the C3  algorithm to linearize the multiple inheritance hierarchies, which is a  significant improvement over Perl 5's approach to handling multiple inheritance.
    class GeekCook is Programmer is Cook {
        method new( *%params ) {
            %params<cookbooks> //= [];  # remove once Rakudo fully supports autovivification
            push( %params<cookbooks>, "Cooking for Geeks" );
            return self.bless(|%params);
        }
    }

    my $geek = GeekCook.new( 
        books           => ('Learning Perl 6'), 
        utensils        => ('stainless steel pot', 'knife', 'calibrated oven'),
        favorite_editor => 'MacVim',
        known_languages => <Perl6>
    );

    $geek.cook('pizza');
    $geek.code_to_solve('P =? NP');


Now all the methods made available by both the Programmer class and the Cook class are available from the GeekCook class.

While multiple inheritance is a useful concept to know and on occasion of use, it is important to understand that there are more useful OOP concepts. When reaching for multiple inheritance it is good practice to consider whether the design wouldn't be better realized by using roles, which are generally safer because they force the class author to explicitly resolve conflicting method names. For more information on roles see A<sec:roles> . Introspection

Introspection is the process of gathering information about some objects in your program, not by reading the source code, but by querying the object (or a controlling object) for some properties, like its type.

Given an object $p , and the class definitions from the previous sections, we can ask it a few questions:
    if $o ~~ Employee { say "It's an employee" };
    if $o ~~ GeekCook { say "It's a geeky cook" };
    say $o.WHAT;
    say $o.perl;
    say $o.^methods(:local).join(', ');


The output can look like this:
It's an employee Programmer() Programmer.new(known_languages => ["Perl", "Python", "Pascal"], favorite_editor => "gvim", salary => "too small") code_to_solve, known_languages, favorite_editor

The first two tests each smart-match against a class name. If the object is of that class, or of an inheriting class, it returns true. So the object in question is of class Employee or one that inherits from it, but not GeekCook .

The .WHAT method returns the type object associated with the object $o , which tells the exact type of $o : in this case Programmer .

$o.perl returns a string that can be executed as Perl code, and reproduces the original object $o . While this does not work perfectly in all cases [1] , it is very useful for debugging simple objects.

Finally $o.^methods(:local) produces a list of methods that can be called on $o . The :local named argument limits the returned methods to those defined in the Employee class, and excludes the inherited methods.

The syntax of calling method with .^ instead of a single dot means that it is actually a method call on the meta class , which is a class managing the properties of the Employee class - or any other class you are interested in. This meta class enables other ways of introspection too:
    say $o.^attributes.join(', ');
    say $o.^parents.join(', ');  


Introspection is very useful for debugging, and for learning the language and new libraries. When a function or method returns an object you don't know about, finding its type with .WHAT , a construction recipe for it with .perl and so on you'll get a good idea what this return value is. With .^methods you can learn what you can do with it.

But there are other applications too: a routine that serializes objects to a bunch of bytes needs to know the attributes of that object, which it can find out via introspection.
[↑] For example closures cannot easily be reproduced this way; if you don't know what a closure is don't worry. Also current implementations have problems with dumping cyclic data structures this way, but they are expected to be handled correctly by .perl at some point.


Generated on 2014-03-22T13:18:49-0400 from the sources at perl6/doc on github . This is a work in progress to document Perl 6, and known to be incomplete. Your contribution is appreciated.

The Camelia image is copyright 2009 by Larry Wall.
