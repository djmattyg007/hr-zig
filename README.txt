hr-zig

This is a port of hr to zig, as a learning exercise for zig.

You can find my C version of hr here:
https://github.com/djmattyg007/hr

To build hr from source, you're going to need at least zig 0.15.1. Then simply
run the following command:

zig build install -Doptimize=ReleaseSmall

To install it into a custom directory:

zig build install -Doptimize=ReleaseSmall --prefix "${custom}/usr"

I used to have instructions for building just the binary (with 'zig build-exe'),
but it seems like using it is simply infeasible once you take on dependencies.
Just use 'zig build' and look in the 'zig-out' folder that gets created.

This program is released into the public domain without any warranty.
