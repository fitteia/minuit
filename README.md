# MINUIT (fitteia fork)

This repository is a fork of [Alberto Ramos's MINUIT](https://github.com/ramos/minuit), which is
itself a packaging of **CERN's classic MINUIT** minimization library — the Fortran source here was
originally imported from CERNLIB 2000 (see the CVS `$Log$` headers still present in the `.F` files,
e.g. `minuit.F`: "import of MINUIT from CERNlib 2000"). This is not a rewrite: it is vendored,
patched third-party numerical code.

It exists to build `libminuit.a` for the [fitteia/OneFit-Engine](https://github.com/fitteia/OneFit-Engine)
fitting engine — see "Consumption by OneFit-Engine" below.

## License

GNU GPL v2 (see `COPYING`) is the license stated by this fork. The source retains
its CERN/CERNLIB provenance and upstream attribution; no attribution has been stripped.

## What's changed vs. upstream (`ramos/minuit`)

The changes are purely about getting stock MINUIT to build cleanly and reproducibly on modern
toolchains, without altering its numerical behaviour:

- **Compiler-warning fixes** (`minuit.patch`, ~1000 lines across 25 `.F` files): rewrites obsolete
  shared-label `DO ... CONTINUE` loops (e.g. a single `200 CONTINUE` terminating two nested loops)
  into one `CONTINUE` per loop, and similarly modernizes other constructs gfortran warns about.
  The stated goal (see `minuit.patch` header) is to eliminate warnings while keeping results
  bit-for-bit consistent with "the last compiled version available for debian
  ...20061220+dfsg3-4.4".
- **The patch is now baked into the tree, not something you apply by hand.** Early history had a
  workflow of `patch -p1 < minuit.patch && make` (and reverting afterwards); as of the "make this
  fork the default to avoid patching" commit, the patched sources are the committed `.F` files
  themselves. `minuit.patch` is kept as a historical record of the upstream diff, not a step in the
  normal build.
- **Makefile**: compiler switched from `ifort` to `gfortran` (`CC` is overridable), with
  `-O3 -fpic -std=legacy -Wno-surprising` plus earlier warning suppressions for newer gfortran
  releases (`-Wno-deprecated`, then `-Wno-surprising`) as the toolchain evolved — see recent commits
  like `22679ea` and `7cb7947`. `PATHLIB` defaults to `../OneFit-Engine/lib`, i.e. this repo is
  expected to live as a sibling checkout of `OneFit-Engine`.
- **Array sizing**: `minuit/d506cm.inc`'s `PARAMETER (MNE=..., MNI=...)` (max external/internal fit
  parameters) has been adjusted over time. Note: OneFit-Engine's installer rewrites this line itself
  at install time (see below), so a locally modified `d506cm.inc` is often just installer-generated
  state rather than an intentional source change.

## Build

```
make            # builds libminuit.a from the .F sources with gfortran
make install    # also copies libminuit.a to $PATHLIB (default: ../OneFit-Engine/lib)
make clean      # removes *.o and *.a
```

`CC` selects the compiler (default `gfortran`); `PATHLIB` selects the install destination, e.g.:

```
make install PATHLIB=/some/other/lib
```

## Consumption by OneFit-Engine

This repo is built and consumed by [fitteia/OneFit-Engine](https://github.com/fitteia/OneFit-Engine)
as a sibling checkout. OneFit-Engine's `INSTALL` script:

1. Clones this repo to `../minuit` relative to the OneFit-Engine checkout (`git clone
   https://github.com/fitteia/minuit.git`) if not already present, and otherwise `git pull`s it.
2. Rewrites the `PARAMETER (MNE=..., MNI=...)` line in `minuit/d506cm.inc` to match its own
   `--minuit=N` install option (max number of fit parameters, default `250`), so `MNE=2*N` and
   `MNI=N`.
3. Runs `make install PATHLIB=<OneFit-Engine>/lib && make clean` in this repo.
4. `Build.rakumod` in OneFit-Engine lists `lib/libminuit.a` as a build artifact/dependency.

OneFit-Engine's own `makefile` can alternatively be pointed at a Debian-packaged system MINUIT
instead of building this fork (see the note in OneFit-Engine's `INSTALL` script) — this fork exists
specifically so that OneFit-Engine doesn't have to depend on that OS package being available.
