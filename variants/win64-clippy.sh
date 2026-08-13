#!/bin/bash
# BtbN/FFmpeg-Builds variant for Clippy's slim LGPL encoder.
#
# Install as `variants/win64-clippy.sh` in a fork of
# https://github.com/BtbN/FFmpeg-Builds.
#
# The filename is NOT free-form: build.sh does
#   source "variants/${TARGET}-${VARIANT}.sh"
# so this file must be named `<target>-<variant>.sh` and is selected with
# `./build.sh win64 clippy`.
#
# The two `source` lines below are load-bearing, not boilerplate:
#  * windows-install-static.sh defines `package_variant`, which build.sh
#    calls to assemble the output tree. Without it the compile succeeds and
#    then the run dies at packaging with "command not found".
#  * We deliberately do NOT source defaults-lgpl.sh: it sets
#    `--enable-version3` and LICENSE_FILE=COPYING.LGPLv3, which BtbN needs
#    because their LGPL variant pulls in version3-only dependencies. Ours
#    doesn't, so we stay on plain LGPL v2.1 and set FF_CONFIGURE ourselves.
#
# Design notes (each --enable is load-bearing; see README.md in this
# directory for the invocation-site inventory):
#  * --disable-everything disables COMPONENTS, not autodetected external
#    libs — hence --disable-autodetect, then explicit re-enables.
#  * h264_mp4toannexb is auto-inserted by "-c copy" mp4 → raw h264; without
#    it the realtime pipe muxer path dies at runtime, not at build time.
#  * scale/aresample pull in swscale/swresample (enabled by default, do NOT
#    disable them); format/aformat/anull/null are auto-inserted by avfilter.
#  * QSV must be libvpl (50-onevpl.sh) — libmfx is deprecated and mutually
#    exclusive with it. h264_qsv works on libvpl.
#  * No libx264: GPL-forcing. But it CANNOT simply be dropped — libopenh264
#    replaces it, because `run_ffmpeg_trim` falls back to a software H.264
#    encoder and, unlike the realtime capture path, has no in-process
#    OpenH264 escape hatch. Cisco's OpenH264 is BSD-2-Clause and its ffmpeg
#    wrapper needs neither --enable-gpl nor --enable-nonfree, so the build
#    stays LGPL v2.1. Provided by scripts.d/50-openh264.sh, which upstream
#    already ships.
#  * No --disable-doc. It saves nothing in the binary (docs are separate
#    files) and breaks packaging: build.sh runs `make install install-doc`
#    and package_variant then does `cp -r share/doc/ffmpeg/*`, which fails
#    when the docs were never generated.

source "$(dirname "$BASH_SOURCE")"/windows-install-static.sh

SLIM_CONFIG=(
    --disable-autodetect
    --disable-everything
    --disable-ffplay
    --disable-ffprobe
    --disable-network
    --disable-debug

    # Hardware encoders (all MIT-licensed integration, LGPL-safe).
    --enable-ffnvcodec
    --enable-amf
    --enable-libvpl
    # Software H.264 fallback for trim/export on boxes with no usable
    # hardware encoder. Load-bearing — see the header note.
    --enable-libopenh264

    --enable-protocol=file,pipe
    --enable-demuxer=rawvideo,mov,wav,ffmetadata
    --enable-muxer=h264,mp4,ipod,image2pipe,ffmetadata
    --enable-decoder=h264,aac,pcm_s16le,rawvideo
    --enable-encoder=h264_nvenc,h264_amf,h264_qsv,libopenh264,aac,mjpeg
    --enable-parser=h264,aac
    --enable-bsf=h264_mp4toannexb,aac_adtstoasc,extract_extradata
    --enable-filter=aresample,volume,asplit,amix,alimiter,scale,format,aformat,anull,null

    # mov demuxer can meet zlib-compressed atoms in the wild.
    --enable-zlib
)

FF_CONFIGURE="${SLIM_CONFIG[*]}"
FF_CFLAGS=""
FF_CXXFLAGS=""
FF_LDFLAGS=""
GIT_BRANCH="master"
LICENSE_FILE="COPYING.LGPLv2.1"
