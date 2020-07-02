#!/bin/bash
# Compile opendpn3 lib for x86_64, ARM of Sierra FX30S or ARM of OWA

cd $(dirname $0)/../../..
projectDirectory=$(pwd)
projectBuildDirectory=${projectDirectory}/target

if [[ $# != 2 ]] || [[ $1 != "--arch" ]]
then
    echo "Invalid params calling to $0"
    echo "Usage: make.sh --arch [x86_64 | legato | owasys]"
    exit 1
fi

if [[ $2 != "owasys" ]] && [[ $2 != "legato" ]] && [[ $2 != "x86_64" ]]
then
    echo "Invalid params calling to $0"
    echo "Unknown architecture $2. Only x86_64, legato and owasys are possible"
    exit 2
fi

arch="$2"
echo "Compiling Open DNP 3.0 library for ${arch} architecture"

# Create build folder for build (inside target folder to be cleaned by Maven)
mkdir -p ${projectBuildDirectory}/checkout-${arch}
cd ${projectBuildDirectory}/checkout-${arch}

# If is for ARM architecture get the compiler programs and options from the toolchain file
if [[ ${arch} == "legato" ]]
then
    # Source Sierra FX30S toolchain file to cross-compile (Legato should be installed at USER home)
    toolchainfile=${HOME}/legato/packages/legato.sdk.latest/resources/configlegatoenv
    environmentfile=${HOME}/legato/packages/legato.sdk.latest/resources/toolchain/native/environment-setup-armv7a-vfp-neon-poky-linux-gnueabi

    if [[ -z $toolchainfile ]]
    then
        echo "Legato it's not install or it's not located at ${HOME}/legato. Legato is needed to cross-compile native libs."
        exit 3
    fi

    source "${toolchainfile}"
    source "${environmentfile}"
elif [[ ${arch} == "owasys" ]]
then
    # Source Sierra FX30S toolchain file to cross-compile (Legato should be installed at USER home)
    toolchainfile=${HOME}/owa-compiler/gcc-linaro-5.3-2016.02-x86_64_arm-linux-gnueabihf/configowasysenv.cmake

    if [[ -z $toolchainfile ]]
    then
        echo "Owasys toolchain not found. Ensure that the deploy downloaded it."
        exit 3
    fi

    cmake ${projectBuildDirectory}/checkout -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${projectBuildDirectory}/checkout-${arch} -DDNP3_JAVA=ON -DCMAKE_TOOLCHAIN_FILE=$toolchainfile
    make -j
    make install
    exit 0
fi

# Compile opendnp3 lib in target/opendnp3/${arch} with JAVA option
cmake ${projectBuildDirectory}/checkout -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${projectBuildDirectory}/checkout-${arch} -DDNP3_JAVA=ON
make
make install
