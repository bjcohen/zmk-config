alias b := build

build_file := "build.yaml"

default:
  @just --list

setup:
    uvx west init -l config
    uvx west update

targets:
    #!/usr/bin/env bash
    targets=$(yq '.include[].artifact-name' {{ build_file }})
    echo "$targets" | tr '' '\n'

build TARGET:
    #!/usr/bin/env bash
    set -euxo pipefail
    board=$(yq '.include[] | select(.artifact-name == "{{ TARGET }}") | .board' -e {{ build_file }})
    shield=$(yq '.include[] | select(.artifact-name == "{{ TARGET }}") | .shield' -e {{ build_file }})
    cmake_args=$(yq '.include[] | select(.artifact-name == "{{ TARGET }}") | .cmake-args // ""' {{ build_file }})
    uvx --with pyelftools west build -p always -s zmk/app -b "$board" -d build/{{ TARGET }} -- -DZMK_CONFIG=$(realpath config) -DSHIELD="$shield" $cmake_args
    cp build/sofle_left/zephyr/zmk.uf2 {{ TARGET }}.uf2

flash TARGET: (build TARGET)
    cp {{ TARGET }}.uf2 /Volumes/NICENANO
