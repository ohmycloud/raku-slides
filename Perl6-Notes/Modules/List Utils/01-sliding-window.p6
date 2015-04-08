sub push-one-take-if-enough(@values is rw, $new-value, $n) {
    @values.push($new-value);
    @values.shift if +@values > $n;
    if +@values == $n {
        for @values { take $_ }
    }
}

sub sliding-window(@a, $n)  {
    my @values;
    gather for @a -> $a {
        push-one-take-if-enough(@values, $a, $n);
    }
}

say ~sliding-window((1,2,3),1);
say ~sliding-window((1, 2, 3, 4, 5), 3);
