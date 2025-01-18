# libfvad: voice activity detection (VAD) library #
[![Build Status](https://travis-ci.org/dpirch/libfvad.svg?branch=master)](https://travis-ci.org/dpirch/libfvad)

This is a fork of the VAD engine that is part of the WebRTC Native Code package
(https://webrtc.org/native-code/), for use as a standalone library independent
from the rest of the WebRTC code. There are currently no changes in
functionality.

## Building and Installing ##
libfvad uses autoconf/automake and can be build and installed with the usual:
```
./configure
make
sudo make install
```

 - When building from the cloned git repository (instead of a downloaded release),
   run `autoreconf -i` to create the missing *configure* script (this requires autoconf, libtool and pkg-config; e.g. run `sudo apt install autoconf libtool pkg-config` on Debian/Ubuntu first).
 - An optional example can be enabled enabled by `./configure --enable-examples`.
   This requires libsndfile (http://www.mega-nerd.com/libsndfile/, e.g.
   `apt install libsndfile1-dev`).

## Usage ##
The API is documented in the `include/fvad.h` header file. See also
`examples/fvadwav.h`.

## Development notes ##
Recommended CFLAGS to turn on warnings: `-std=c11 -Wall -Wextra -Wpedantic`.
Tests can be run with `make check`.

### Origin ###
This library largely consists of parts of the WebRTC Native Code package, the
repository of which can be found at
https://chromium.googlesource.com/external/webrtc:

 - Most of `webrtc/common_audio/vad/` has been moved to `src/vad`.
 - Parts of `webrtc/common_audio/signal_processing` have been moved to
   `src/signal_processing`. Parts of this signal processing library not needed
   by the VAD engine have been removed. Also, some platform-specific assembly
   code has been removed for now, for easier maintainability.
 - Relevant unit tests have been converted into automake tests and moved to
   `tests`.

### Merging upstream changes ###
It is intended that future changes and fixes in the WebRTC Native Code package
will also be be merged into libfvad.

To help with this, the libfvad git
repository has an `upstream-import` branch containing the required subset of the
WebRTC Native Code package's files, and an `upstream-renamed` branch which also
contains these unmodified files, but moved/renamed to the libfvad directory
structure.

The `tools/import.sh` script is intended to be run in the
`upstream-import` branch and imports changes from a local clone of the WebRTC
Native Code package git repository; it reads `tools/import-paths` which contains
the list of files to import, and reads and updates `tools/import-commit` which
contains the most recent imported commit hash of the source repository.

After this import, the changes can be merged first into the `upstream-renamed`
branch and then into the `master` branch. The intermediate step is necessary
because *git merge* would treat files that were both renamed and heavily changed
as new files.


## Setup with conan
```shell
pip install conan
mkdir build

## For debug version of the app
conan install . --build=missing --settings=build_type=Debug
cmake --preset conan-debug
cmake --build --preset conan-debug
```

## Cross-compile for Raspberry Pi
The whole build process is based on running toolchain in Docker(thanks for this repo https://github.com/tttapa/docker-arm-cross-toolchain)

### Interactive build
```shell
docker build --platform linux/amd64 -t libvad-crossbuild .
docker run -t -i -v $PWD:/current_project libvad-crossbuild /bin/bash
cd /current_project
conan install . --build=missing -pr /build_dir/docker-arm-cross-toolchain/profiles/aarch64-rpi3-linux-gnu.conan
cmake --preset conan-release -DENABLE_EXAMPLES=ON
cmake --build --preset conan-release
```
### Cross build in the container
```shell
docker create --name libvad-crossbuilder libvad-crossbuild
docker cp libvad-crossbuilder:/build_dir/build/Release/examples/fvadwav ${PWD}/fwadwav_aarch64_rpi
docker rm -f libvad-crossbuilder
```

### Deploy to Raspberry Pi
```shell
python3.11 deploy_to_remote_target.py --ip="192.168.0.119" --local-path=${PWD}/build/Release/examples/fvadwav --remote-path=/home/pi/Documents/phd/vad_playground
```