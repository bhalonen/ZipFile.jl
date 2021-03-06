using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libz"], :libz),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/bicycle1885/ZlibBuilder/releases/download/v1.0.3"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.aarch64-linux-gnu.tar.gz", "72aa633f5291d3a514f615b68f9a0550d66310d9563bb3fa72c8b5bd8ea4d58d"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/Zlib.v1.2.11.aarch64-linux-musl.tar.gz", "041932deac67883e7ee07feb243fcfaa0a9a52e6e6112fe0c6425e1c4094f0fc"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/Zlib.v1.2.11.arm-linux-gnueabihf.tar.gz", "f50e80b44ba8fd20e9a59d51e96b783066414e4ef7c51ebad4308be89611fa2d"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/Zlib.v1.2.11.arm-linux-musleabihf.tar.gz", "842a2485d10fc98589db0b6c9fa5d2b8919ecdda1a125b6313aa2c1ef787887d"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.i686-linux-gnu.tar.gz", "c2ca5c65343f96b329654f7785cfa7a17fb603541cf7f5e19c3ba4d77ce42cf3"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/Zlib.v1.2.11.i686-linux-musl.tar.gz", "0d86ffc9e2021112371a7efb646804bf3f51d798f89234e9e3c5809068e8facc"),
    Windows(:i686) => ("$bin_prefix/Zlib.v1.2.11.i686-w64-mingw32.tar.gz", "fa43ec42f5d6521f806aaa594f5438eb81fa8f1e841542e0a5808446890b80e6"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.powerpc64le-linux-gnu.tar.gz", "937b115771c60310497a3d00d0f888944b4582b1a1e67658f445432da1cefbcb"),
    MacOS(:x86_64) => ("$bin_prefix/Zlib.v1.2.11.x86_64-apple-darwin14.tar.gz", "777ace94953082dfbfdc4bbc0d7217eb16f868bca0cc6c26f1cf5652c318ae04"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/Zlib.v1.2.11.x86_64-linux-gnu.tar.gz", "3c1259cd136a53c11d21980f41581ae4d9db226dca0beb9c7effa501b93de1e1"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/Zlib.v1.2.11.x86_64-linux-musl.tar.gz", "fd3e452718763857b8fe5e600e1f426ed86dc1b47b1e186991e22ad7c33d0f92"),
    FreeBSD(:x86_64) => ("$bin_prefix/Zlib.v1.2.11.x86_64-unknown-freebsd11.1.tar.gz", "2e7248503c96ad7d49ba62f94b5a9813f216d07a66d953b55719f8c1adca2864"),
    Windows(:x86_64) => ("$bin_prefix/Zlib.v1.2.11.x86_64-w64-mingw32.tar.gz", "b2a642c6ecc3f20ccc7357d91d39029a15cf3e1a38c639a339330231fd8b7601"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
