hr-zig

This is a port of hr to zig, as a learning exercise for zig.

You can find my C version of zig at here:
https://github.com/djmattyg007/hr

To build hr from source, you're going to need zig 0.6.0. Then simply
run the following command:

zig build install -Drelease-small

To install it into a custom directory:

zig build install -Drelease-small --prefix "${custom}/usr"

This program is released into the public domain without any warranty.
