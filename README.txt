hr-zig

This is a port of hr to zig, as a learning exercise for zig.

You can find my C version of hr here:
https://github.com/djmattyg007/hr

To build hr from source, you're going to need zig 0.6.0. Then simply
run the following command:

zig build install -Drelease-small

To install it into a custom directory:

zig build install -Drelease-small --prefix "${custom}/usr"

To build just the binary, use the following command:

zig build-exe src/hr.zig --library c --release-small --strip --single-threaded

This will create a binary named 'hr' in the current working directory.

Some Linux distributions (such as Arch Linux) compile zig in such a way that it
does not produce static binaries by default. I've found that specifying the
platform target gets around this issue. For example:

zig build-exe src/hr.zig --library c --release-small --strip --single-threaded -target x86_64-linux

This program is released into the public domain without any warranty.
