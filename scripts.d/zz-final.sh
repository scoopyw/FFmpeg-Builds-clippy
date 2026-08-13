#!/bin/bash

SCRIPT_SKIP="1"

ffbuild_depends() {
    # Trimmed for the Clippy slim variant.
    #
    # This list is load-bearing for BOTH size and licence, not a build-time
    # optimisation. generate.sh sources the variant, then appends every
    # enabled library's own ffbuild_configure output onto FF_CONFIGURE:
    #
    #     FF_CONFIGURE+=" $(get_output "$SCRIPT" configure)"
    #
    # So with the stock list, `--disable-everything` still ends up followed
    # by --enable-libx264, --enable-libopus, --enable-libaom and ~60 more,
    # producing a large binary. Worse for us, scripts.d/50-x264.sh disables
    # itself only when `$VARIANT == lgpl*` -- our variant is "clippy", so
    # x264 would be pulled in and the result would be GPL, defeating the
    # entire point of the exercise.
    #
    # Keep only what Clippy's invocation sites actually need.
    echo libiconv       # common mingw dependency of the base toolchain
    echo zlib           # --enable-zlib; mov demuxer meets compressed atoms
    echo ffnvcodec      # h264_nvenc  (NVIDIA)
    echo amf            # h264_amf    (AMD)
    echo onevpl         # h264_qsv    (Intel, via libvpl)
    echo openh264       # libopenh264 (software fallback for trim/export)
    echo rpath
}

ffbuild_enabled() {
    return 0
}

ffbuild_dockerfinal() {
    return 0
}

ffbuild_dockerdl() {
    return 0
}

ffbuild_dockerlayer() {
    return 0
}

ffbuild_dockerstage() {
    return 0
}

ffbuild_dockerbuild() {
    return 0
}

ffbuild_ldexeflags() {
    return 0
}
