#! /bin/bash

RPC_VERSION_FOLDER="rpclib-2.3.0"
folder_name="Release"
build_dir=build


mkdir -p build
cd build

CC=/usr/bin/clang-12 CXX=/usr/bin/clang++-12 cmake ../cmake -DCMAKE_CXX_FLAGS='-stdlib=libc++ -I/usr/lib/llvm-17/include/c++/v1~'

make -j$(nproc)

cd ..

mkdir -p AirLib/lib/x64/$folder_name
mkdir -p AirLib/deps/rpclib/lib
mkdir -p AirLib/deps/MavLinkCom/lib
cp $build_dir/output/lib/libAirLib.a AirLib/lib
cp $build_dir/output/lib/libMavLinkCom.a AirLib/deps/MavLinkCom/lib
cp $build_dir/output/lib/librpc.a AirLib/deps/rpclib/lib/librpc.a

# Update AirLib/lib, AirLib/deps, Plugins folders with new binaries
rsync -a --delete build/output/lib/ AirLib/lib/x64/$folder_name
rsync -a --delete external/rpclib/$RPC_VERSION_FOLDER/include AirLib/deps/rpclib
rsync -a --delete MavLinkCom/include AirLib/deps/MavLinkCom
rsync -a --delete AirLib Unreal/Plugins/AirSim/Source
rm -rf Unreal/Plugins/AirSim/Source/AirLib/src

# Update all environment projects 
for d in ~/Documents/Unreal\ Projects/*; do
    # Skip if not a directory
    [ -d "$d" ] || continue
    # Skip if symbolic link
    [ -L "${d%/}" ] && continue

    # Execute clean.sh if it exists and is executable
    if [ -x "$d/clean.sh" ]; then
        "$d/clean.sh"
    fi

    # Ensure Plugins directory exists
    mkdir -p "$d/Plugins"

    # Sync AirSim plugin into Plugins directory
    rsync -a --delete Unreal/Plugins/AirSim/ "$d/Plugins/AirSim/"
done

echo ""
echo ""
echo "=================================================================="
echo " Colosseum plugin is built! Here's how to build Unreal project."
echo "=================================================================="
echo "All environments under Unreal/Environments have been updated."
echo ""
echo "For further info see the docs:"
echo "https://codexlabsllc.github.io/Colosseum/build_linux/"
echo "=================================================================="
