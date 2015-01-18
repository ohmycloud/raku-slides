Paired up Hashes December 20, 2011


What is possible with arrays and lists in Perl 6 is truly remarkable and was demonstrated here several times. But what about hashes?
Superficially not much has changed.
(Following Damian’s rule from PBP to name a hash variable in singular.)
    %song = Panacea => 'found a lover', Photek => 'ni ten ichi ryu';
    say keys %song;   # also %song.keys
    say values %song; # %song.values

Yes, the sigils are now invariant, so you get values with:获取散列的值：
    %song{'Panacea'}
    %song{'Panacea', 'Photek'}

That can be shortened, because <> is the new qw(): <>代替 qw()，自动为单词添加引号：
    %song<Panacea>
    %song<Panacea Photek>

Frankly, almost everything else has changed. Perl 6 can be sometimes hideous, just mimicking to be your good old pal Perl 5 while being a friendly T-X, blasting behind your back your programming problems away. The fat arrow is no longer a fancy comma but an infix operator, creating an object that contains a key-value pair.胖剪头不再是一个令人着迷的逗号了，而是一个中缀操作符，这会创建一个包含一个键值对的对象。
    my $song = paniq => 'Godshatter';
    say $song.WHAT; # says: "Pair()"
    $song.key;     # as expected is paniq
    $song.value;  # you guess it

There is another Syntax for that, heavily used in signatures:还有另外一种在签名中很常见的语法，使用冒号：
    my $song = :paniq('Godshatter');

But what happens if I:但是如果我这样呢:
    my @songs = %song; # 与 @(%songs)相同

You maybe predicted it, @songs gets a list of pairs. For the old behaviour, you have to say explicitly: “I want the keys and values as a list.”:你可能预测到了，@songs 获得一个键值对列表。在过去，你需要显示地说，我想要键和值作为一个列表：
    my @songs = %song.kv; # key 1, value 1, key 2 ....

This new setup of hashes is not only theoretically very pleasing. It also allows iterating over hashes, without the risk of loosing the precious key => value correlation. That’s handy for all kinds of sorting and mashing of data, for which Perl is famous. What else did Randal L. Schwartz once upon a time than creating a list of pairs, sorting them and then picking the needed data bits.

Having pairs as a built-in type helps also subs and methods to handle their parameters. Some of the can be positional, which could be ordered in an array. Some of them are named and could be stored in a hash. But they are actually stored in a “Parcel”, a list that can contain pairs. This way the order of the parameters and the key => value correlations are preserved.

A very similar type is the Capture, which can hold all arguments sent to a routine. Therefore it has to behave more like routine and pass all the named arguments under their names. But if you ask for the positional parameter, you get only them, not the named ones. With a Capture full of values you can ask with a smartmatch if it would pass a certain subroutine and many fine things more. The vaults are going here deeper and deeper, but lets get back to the daylight of everyday hash-usage.

Panacea aka Mathis Mootz had a lot of great tracks. And when I do:
    %song<Panacea> = "state of extacy";

“found a lover” 被覆盖。目前为止，没有什么新鲜的，但是我有时候不想弄丢我的数据。然后我需要对散列执行一些强制行为gets overwritten. Nothing new so far, but there are times I just don’t want to loose my data. Then I need to execute some force onto the hash.
    %song.push( Panacea => "state of extacy" );

整个键值对列表被压进另外一个散列。结果仍然是一个散列，但是键 'Panacea' 现在指向一个数组，这个数组中包含两个歌曲标题。反转散列的时候这也很有用。Whole lists of pairs can be pushed into another hash this way. The result will be (not surprisingly) still a hash but the key ‘Panacea’ now points to an array, containing both song titles. That’s also useful when inverting a hash, that means pulling out a pair-list where key and value are flipped. Pasting that into a hash may lead to collisions, if several keys have the same value. A simple:反转键值对时，如果几个键对应的值相同，那么反转后会发生冲突：
    # list with song => artist pairs
    %song = %artist.invert;

might produce losses, but the following does not:这会造成丢失，但是下面的就不会：
    %song.push( %artist.invert ); # or:
    %song.push: %artist.invert;

While doing some heavy data munging you might regroup the values under a different set of keys. In that case it is likely that several values will end up under the same key. Given you have a sub that recognizes a genre of a song, you might write something like:当你在做很多数据挖掘时，你可能在不同的键组成的集合中重组键值。在那种情况下，很可能几个值会对应着同一个键。
    map { %genre.push(genre_of_song($_) => $_) }, %song.values;

But as you already guessed it, there is an easier way to do that:更容易的方式：
    %genre = classify { genre_of_song($_) }, %song.values;

Now you probably say: “That’s unrealistic!”. There are songs for instance from “Magnetic Man” that can be labeled “Drum ‘n Base”, “Dubstep” or even “Pop”. Larry knows that. (This kind of problem of course.) That’s why he pulled out a second hash generating method.
    %genre = categorize { genre_of_song($_) }, %song.values;

Unlike classify, which expects exactly one value (Called scalar in P5 but item in Perl 6 world), categorize can handle a list of results returned by the closure (block). It also happily accepts a Nil, which means, unlike undef in Perl 5, really nothing. When classify gets a Nil, the song will then not appear in any category, meaning under no hash key.

Imagine a routine of real artificial intelligence that can distinct good from bad songs. (Your definition of good of course!)
    my %quality = classify { good_music($_) ?? 'good' !! 'bad' }, %song.values;

Hence %quality<good> contains all the songs I sent to my music player and %quality<bad> to /dev/null (which is the name of another electronic music artist).

