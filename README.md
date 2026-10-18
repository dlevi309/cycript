### Build Cycript for iOS from source (Thanks claude!)

To build on your Mac, run these in order:

1.  `git submodule update --init`
2.  `./sysroot.sh`
3.  `./apple-lib.sh`
4.  `./apple-configure.sh`
5.  `make -f build.mk`
