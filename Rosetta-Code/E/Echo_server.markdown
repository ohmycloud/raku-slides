### Echo server

Create a network service that sits on TCP port 12321, which accepts connections on that port, and which echoes complete lines (using a carriage-return/line-feed sequence as line separator) back to clients. No error handling is required. For the purposes of testing, it is only necessary to support connections from localhost (127.0.0.1 or perhaps ::1). Logging of connection information to standard output is recommended.
The implementation must be able to handle simultaneous connections from multiple clients. A multi-threaded or multi-process solution may be used. Each connection must be able to echo more than a single line.
The implementation must not stop responding to other clients if one client sends a partial line or stops reading responses.

```perl
my $socket = IO::Socket::INET.new:
    localhost => 'localhost',
    localport => 12321,
    listen    => 1;
 
while $socket.accept -> $conn {
    say "Accepted connection";
    async {
        while $conn.recv -> $stuff {
            say "Echoing $stuff";
            $conn.send($stuff);
        }
        $conn.close;
    }
}
```
