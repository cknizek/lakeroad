# Lakeroad

See the paper [here.](https://arxiv.org/abs/2401.16526)

Lakeroad
  is a technology mapper for FPGAs
  built using sketch-guided program synthesis
  provided by [Rosette](https://emina.github.io/rosette/).
Given a description
  of an FPGA's resources,
  it can compile input designs
  to FPGA primitives.
It is especially powerful for complex,
  programmable primitives
  like DSPs.

## Dependencies

- LLVM
  - set `LLVM_CONFIG` to the location of your `llvm-config` binary, e.g. `/usr/local/Cellar/llvm/15.0.3/bin/llvm-config`
- `lit` test runner, which can be installed with `pip install lit`
- Racket, plus Racket packages (installable via `raco pkg install`):
  - `rosette`
  - `json`
  - `yaml`
- Verilator, ideally 4.228 or later
- Boolector, which can be built from source from <https://github.com/Boolector/boolector>
- Yosys

Please see the [Dockerfile](./Dockerfile)
  for a complete listing of all
  dependencies.

## Environment Variables

- `LAKEROAD_DIR`
- `LAKEROAD_PRIVATE_DIR`
- `LLVM_CONFIG`

## Testing in Lakeroad

[`run-tests.sh`](./run-tests.sh) is the primary script
  for running tests.
We have three sources of tests at the moment:

- Rust tests within the (dormant) Lakeroad Rust crate.
- Racket tests within the Lakeroad Racket implementation.
- Integration tests in [`./integration_tests/`](./integration_tests/).

Ideally, we should aim to do most of our testing
  via *integration tests:*
  tests which test Lakeroad from the outside,
  only running commands that users can run.
We use the LLVM testing tool `FileCheck`
  to build our integration tests, and another LLVM tool,
  `lit`,
  to run them.
FileCheck tests take the form of a file to be compiled
  using Lakeroad or some other tool within Lakeroad.
FileCheck tests can be written in any language;
  in Lakeroad's case, they're generally writte in Verilog,
  representing a Verilog file to be compiled
  with Lakeroad.
At the top of the file are generally commands
  for how to compile the file and how to execute
  FileCheck on the result.
At the bottom of the file are syntactic checks
  to perform on the results.

An example of what Lakeroad integration tests will
  often look like:

```verilog
// RUN: racket $LAKEROAD_DIR/bin/main.rkt \
// RUN:  --verilog-module-filepath %s \
// RUN:  --architecture xilinx-ultrascale-plus \
// RUN:  --template dsp \
// RUN:  --out-format verilog \
// RUN:  --top-module-name three_stage_multiplier \
// RUN:  --verilog-module-out-signal p:16 \
// RUN:  --initiation-interval 3 \
// RUN:  --clock-name clk \
// RUN:  --module-name out \
// RUN:  --input-signal a:16 \
// RUN:  --input-signal b:16 \
// RUN: | FileCheck %s

module three_stage_multiplier(input clk, input [15:0] a, b, output [15:0] p);

  reg [15:0] tmp0, tmp1, out;

  always @ (posedge clk) begin
    ...

endmodule

// CHECK: module out(a, b, clk, p);
// CHECK:   wire [47:0] P_0;
// CHECK:   input [15:0] a;
// CHECK:   wire [15:0] a;
// CHECK: ...
```

When generating tests, it can often be useful
  to replace the following line:

```verilog
// RUN: | FileCheck %s
```

With this:

```verilog
// RUN: | awk '{print "// CHECK: " $0}' >> %s
```

Which will automatically take the output of the tool
  and append it to the end of the file
  with ``// CHECK: ` as a prefix.

## Notes for Mac

Mac users with an old version of `gcc`/`g++` (i.e. `clang`/`clang++`)
  as their default compiler
  will need to install a newer `clang++`
  via `brew install llvm`,
  and then ensure that `clang++` is used
  when running tests.
This can be done by setting
  `CXX` as follows:

```sh
CXX=/usr/local/Cellar/llvm/16.0.3/bin/clang++ lit -v integration_tests/lakeroad/presubaddor_2_stage_unsigned_10_bit.sv
```

TODO(@gussmith23): this is unintuitive and not user-friendly.

### Use of GNU sed

The [./import_all_primitives.sh](./import_all_primitives.sh) script uses sed, which it expects to be GNU sed. On Mac, you can install GNU sed via Homebrew and add it to your PATH temporarily or permanently.

TODO(@gussmith23): Find better cross-platform regex. I thought Perl might be the answer.

## Yosys Plugin

Lakeroad is usable via a Yosys plugin, which can be built separately and loaded directly into your existing Yosys installation. The plugin is located in [./yosys-plugin/](./yosys-plugin/) and can be built using the Makefile in that directory. The plugin can be loaded into Yosys using Yosys's `-m` option, e.g. `yosys -m lakeroad.so ...`. An example of this can be seen in [this integration test.](./integration_tests/lakeroad/xilinx_muladd_0_stage_signed_8_bit_yosys_plugin.sv)


Note: the Lakeroad plugin needs to be built in the same environment (i.e. same glibc version) as the Yosys executable it's being loaded into. This can be an issue e.g. when using the Yosys executable in `oss-cad-suite`. The easiest way to prevent this is to build Yosys yourself using their directions.


-------------------------
# Getting Started
## 0. Clone repository and navigate to directory
`git clone https://github.com/uwsampl/lakeroad.git`

`cd lakeroad`

## 1. Install LLVM
Refer to the [LLVM Installation Guide](https://apt.llvm.org/)

## 2. Install Bitwuzla
#### Clone Bitwuzla repository
`git clone https://github.com/bitwuzla/bitwuzla`
`cd bitwuzla`
#### Configure Bitwuzla release build

`./configure.py`
#### Build & Install

`cd build && ninja install`
#### Locate the Bitwuzla binary
`cd src/main`
#### Copy the Bitwuzla binary into Rosette's binaries
`cp bitwuzla ~/.racket/8.6/pkgs/rosette/bin`

`# Replace ~/.racket/8.6/... (Replace 8.6 with X.Y, where X.Y corresponds to your own installed Racket version number)`

## 3. Install Homebrew 
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
        
## 4. Install Racket
`sudo add-apt-repository ppa:plt/racket`

`sudo apt update`

## 5. Install Rosette
`raco pkg install rosette`

## 6. Install Verilator
`apt-get install verilator   # On Ubuntu`

## 7. Install Yosys
`brew install yosys`

## 8. Install YAML
`raco pkg install yaml`

## 9. Install Boolector
`brew install boolector`

## 10. Install lit
`pip install lit`

## 11. Install Yices
`sudo add-apt-repository ppa:sri-csl/formal-methods`

`sudo apt-get update`

`sudo apt-get install yices2`

... or ...

`git clone https://github.com/SRI-CSL/yices2.git`

`autoconf`

`./configure`

`make`

`sudo make install`

`cd ./build/x86_64-pc-linux-gnu-release/bin`

`cp -a /bin/. /home/YOUR_USERNAME/.racket/8.6/pkgs/rosette/bin/`

## 12. Install CVC5
`git clone https://github.com/cvc5/cvc5.git`

`cd cvc5`

`./configure.sh --auto-download # Make sure you have cmake installed`

`cd build`

`make`

`cd bin`

`cp cvc5 /home/YOUR_USERNAME/.racket/8.6/pkgs/rosette/bin/`

## 13. Make Yosys plugin

In the lakeroad directory ...
`cd ./yosys-plugin`

`make`

## 14. Install boost
`apt-get install libboost-filesystem-dev`

`brew install boost`

`cd .. # return to main lakeroad directory`

## 15. Install stp
`brew install stp`


## Run all tests

_Running all of the tests may take a very long time (the Racket tests take particularly long)_

Within the Lakeroad directory (e.g. `./lakeroad`), run the command: `./run-tests.sh`

## Run only integration tests

_Running only the integration tests will take comparatively less time_

Using a text editor (vim, nano, sublime-text, etc), open `run-tests.sh` and comment out the line:

`for f in $SCRIPT_DIR/racket/*.rkt; do time raco test $f; done`

so that it looks like:

`#for f in $SCRIPT_DIR/racket/*.rkt; do time raco test $f; done`


## Installation Notes
1. If Bitwuzla wasn't installed correctly, `./run-tests.sh` will fail when running the test for `./lakeroad/racket/lattice-end-to-end.rkt`

2. The test for `./lakeroad/racket/sketches.rkt` can take a long time

3. If you are running into issues when doing the integration tests and everything is erroring, re-clone the repository and re-run `./run-tests.sh`
