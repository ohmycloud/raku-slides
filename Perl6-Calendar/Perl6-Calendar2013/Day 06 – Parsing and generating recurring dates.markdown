Day 06 – Parsing and generating recurring dates By   Moritz


There are a lot of events that are scheduled on particular days of the week each month, for example the regular Windows Patch Day on  the second Tuesday of each month , or in Perl 6 land that Rakudo Perl 6 compiler release, which is scheduled for two days after the Parrot release day, which again is scheduled for the third Tuesday of the month.

So let's write something that calculates those dates.

The specification format I have chosen looks like  3rd tue + 2  for the Rakudo release date, that is, two days after the 3rd Tuesday of each month (note that this isn't always the same as the 3rd Thursday).

Parsing it isn't hard with a simple  grammar :

grammar DateSpec::Grammar {
    rule TOP {
        [<count><.quant>?]?
        <day-of-week>
        [<sign>? <offset=count>]?
    }
    token count { \d+ }
    token quant { st | nd | rd | th }
    token day-of-week { :i
        [ mon | tue | wed | thu | fri | sat | sun ]
    }
    token sign { '+' | '-' }
}

As you can see, everything except the day of the week is optional, so  sun  would simply be the first Sunday of the month, and  2 sun - 1  the Saturday before the second Sunday of the month.

Now it's time to actually turn this specification into a data structure that does something useful. And for that, a class wouldn't be a bad choice:

my %dow = (mon => 1, tue => 2, wed => 3, thu => 4,
        fri => 5, sat => 6, sun => 7);
 
class DateSpec {
    has $.day-of-week;
    has $.count;
    has $.offset;
 
    multi method new(Str $s) {
        my $m = DateSpec::Grammar.parse($s);
        die "Invalid date specification '$s'\n" unless $m;
        self.bless(
            :day-of-week(%dow{lc $m<day-of-week>}),
            :count($m<count> ?? +$m<count>[0] !! 1),
            :offset( ($m<sign> eq '-' ?? -1 !! 1)
                    * ($m<offset> ?? +$m<offset> !! 0)),
        );
    }

We only need three pieces of data from those date specification strings: the day of the week, whether the 1st, 2nd, 3rd. etc is wanted (here named  $.count ), and the offset. Extracting them is a wee bit fiddly, mostly because so many pieces of the grammar are optional, and because the grammar allows a space between the sign and the offset, which means we can't use the Perl 6 string-to-number conversion directly.

There is a  cleaner but longer  method of extracting the relevant data using an  actions  class.

The closing  }  is missing, because the class doesn't do anything useful yet, and that should be added. The most basic operation is to find the specified date in a given month. Since Perl 6 has no built-in type for months, we use a  Date  object where the  .day  is one, that is, a Date object for the first day of the month.

    method based-on(Date $d is copy where { .day == 1}) {
        ++$d until $d.day-of-week == $.day-of-week;
        $d += 7 * ($.count - 1) + $.offset;
        return $d;
    }

The algorithm is quite simple: Proceed to the next date ( ++$d ) until the day of week matches, then advance as many weeks as needed, plus as many days as needed for the offset.  Date  objects support addition and subtraction of integers, and the integers are interpreted as number of days to add or subtract. Handy, and exactly what we need here. (The API is blatantly copied from the Date::Simple  Perl 5 module).

Another handy convenience method to implement is  next , which returns the next date matching the specification, on or after a reference date.

    method next(Date $d = Date.today) {
        my $month-start = $d.truncated-to(month);
        my $candidate   = $.based-on($month-start);
        if $candidate ge $d {
            return $candidate;
        }
        else {
            return $.based-on($month-start + $month-start.days-in-month);
        }
    }
}

Again there's no rocket science involved: try the date based on the month of  $d , and if that's before  $d , try again, but with the next month as base.

Time to close the class :-).

So, when is the next Rakudo release? And the next Rakudo release after Christmas?

my $spec = DateSpec.new('3rd Tue + 2');
say $spec.next;
say $spec.next(Date.new(2013, 12, 25));

Output:

2013-12-19
2014-01-23

The  code  works fine on Rakudo with both the Parrot and the JVM backend.

Happy recurring hollidates!

来源： < http://perl6advent.wordpress.com/2013/12/06/day-06-parsing-and-generating-recurring-dates/ >  