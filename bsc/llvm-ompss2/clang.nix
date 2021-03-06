{
  stdenv
, fetchgit
, cmake
, lld
, bash
, python3
, perl
, clang
, which
, libelf
, libffi
, pkg-config
, enableDebug ? true
}:

stdenv.mkDerivation rec {
  version = "11.0.0";
  pname = "clang-ompss2";
  enableParallelBuilding = true;
  #isClang = true;
  #isGNU = true;

  isClangWithOmpss = true;

  buildInputs = [
    which
    clang
    bash
    python3
    perl
    cmake
    lld
    libelf
    libffi
    pkg-config
  ];

  cmakeBuildType = if enableDebug then "Debug" else "Release";

  dontUseCmakeBuildDir = true;

  preConfigure = ''
    mkdir -p build
    cd build
    cmakeDir="../llvm"
    cmakeFlagsArray=(
      "-DLLVM_ENABLE_LLD=ON"
      "-DCMAKE_CXX_FLAGS_DEBUG=-g -ggnu-pubnames"
      "-DCMAKE_EXE_LINKER_FLAGS_DEBUG=-Wl,-gdb-index"
      "-DLLVM_LIT_ARGS=-sv --xunit-xml-output=xunit.xml"
      "-DLLVM_ENABLE_PROJECTS=clang;openmp"
      "-DLLVM_ENABLE_ASSERTIONS=ON"
      "-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON"
    )
  '';

# About "-DCLANG_DEFAULT_NANOS6_HOME=${nanos6}", we could specify a default
# nanos6 installation, but this is would require a recompilation of clang each
# time nanos6 is changed. Better to use the environment variable NANOS6_HOME,
# and specify nanos6 at run time.

  src = builtins.fetchGit {
    url = "ssh://git@bscpm02.bsc.es/llvm-ompss/llvm-mono.git";
    rev = "38e2e6aac04d40b6b2823751ce25f6b414f52263";
    ref = "master";
  };
}
