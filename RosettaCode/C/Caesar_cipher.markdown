### 凯撒加密

实现一个凯撒加密， 编码和解码都要有

 key 是一个 1 到 25 之间的整数

This cipher rotates (either towards left or right) the letters of the alphabet (A to Z).
The encoding replaces each letter with the 1st to 25th next letter in the alphabet (wrapping Z to A). So key 2 encrypts "HI" to "JK", but key 20 encrypts "HI" to "BC".
This simple "monoalphabetic substitution cipher" provides almost no security, because an attacker who has the encoded message can either use frequency analysis to guess the key, or just try all 25 keys.
Caesar cipher is identical to Vigenère cipher with a key of length 1. 
Also, Rot-13 is identical to Caesar cipher with key 13.


```perl
my @alpha = 'A' .. 'Z';
sub encrypt ( $key where 1..25, $plaintext ) {
    $plaintext.trans( @alpha Z=> @alpha.rotate($key) );
}
sub decrypt ( $key where 1..25, $cyphertext ) {
    $cyphertext.trans( @alpha.rotate($key) Z=> @alpha );
}
 
my $original = 'THE FIVE BOXING WIZARDS JUMP QUICKLY';
my $en = encrypt( 13, $original );
my $de = decrypt( 13, $en );
 
.say for $original, $en, $de;
 
say 'OK' if $original eq all( map { .&decrypt(.&encrypt($original)) }, 1..25 );
```

    Output:
    THE FIVE BOXING WIZARDS JUMP QUICKLY
    GUR SVIR OBKVAT JVMNEQF WHZC DHVPXYL
    THE FIVE BOXING WIZARDS JUMP QUICKLY
    OK

