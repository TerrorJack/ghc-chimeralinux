# `ghc-chimeralinux`

This repo contains recipe to build a container image based on [Chimera
Linux](https://chimera-linux.org) that contains cabal-3.12 and
ghc-9.10. It's suitable for building fully statically linked Haskell
executables for Linux.

## Doesn't GHC support Alpine already?

Chimera Linux uses [mimalloc](https://github.com/microsoft/mimalloc)
to replace musl's own mallocng allocator. See my blog post linked from
[rust-alpine-mimalloc](https://github.com/tweag/rust-alpine-mimalloc)
for more explanation.

For Haskell executables, the majority of memory allocation is handled
by GHC RTS, not libc allocator. But still, once you link against
foreign libraries that allocates heavily, your executable's
performance will be heavily impacted by mallocng under multi-threaded
workloads. And Alpine's musl build still defaults to mallocng. (same
for nix)

You can still use the same tricks in my blog post to patch Alpine
`libc.a` so you also get mimalloc for free in your statically linked
executable. The mimalloc build shipped in Chimera Linux musl is
slightly less performant than how I build it in rust-alpine-mimalloc
(smaller segments/arenas, hardening & PIC enabled, etc). If you're
super paranoid about performance and doesn't mind the hacks I pulled
in rust-alpine-mimalloc, use that as a starting point to build Haskell
stuff.

## Why not just use Alpine bindists in Chimera Linux?

GHC provides two kinds of Alpine bindists: regular bindists with
dynamic executables & shared libraries, and fully static bindists.

A regular Alpine GHC bindist only works in a musl environment with a
musl ld.so. The musl version in its build environment is likely older
than Chimera Linux musl, and while musl has excellent backwards
compatibility, it's still safer to bootstrap a native GHC build for
Chimera Linux.

A fully static Alpine GHC bindist is commonly misinterpreted as the
best GHC bindist for building fully static executables. That's
completely false. Expect RTS linker errors and segfaults when you
build non-trivial projects that involve Template Haskell and GHC
plugins.

Fully static Alpine GHC bindists should only be used in exactly one
scenario: acting as the binary seed for bootstrapping GHC in a new
distro. This would even work for bootstrapping a dynamic GHC in a
glibc environment.

## Can this be properly packaged into Chimera cports?

Yes, with more effort than my mental energy budget. Feel free to take
and modify build script here. The script downloads stuff from
Internet, you'll need to handle the hadrian bootstrap sources stuff if
you intend to package it for Chimera cports.
