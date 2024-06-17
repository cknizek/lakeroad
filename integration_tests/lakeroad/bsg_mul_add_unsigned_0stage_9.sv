// RUN: outfile=$(mktemp)
// RUN: (racket $LAKEROAD_DIR/bin/main.rkt \
// RUN:  --solver stp \
// RUN:  --verilog-module-filepath %s \
// RUN:  --architecture xilinx-ultrascale-plus \
// RUN:  --template dsp \
// RUN:  --out-format verilog \
// RUN:  --top-module-name bsg_mul_add_unsigned \
// RUN:  --verilog-module-out-signal o:19 \
// RUN:  --clock-name clk_i \
// RUN:  --module-name test_module \
// RUN:  --input-signal a_i:9 \
// RUN:  --input-signal b_i:9 \
// RUN:  --input-signal c_i:18 \
// RUN:  --timeout 120 \
// RUN:  || true) \
// RUN:  > $outfile \
// RUN:  2>&1
// RUN: FileCheck %s < $outfile

`include "bsg_defines.sv"
  
(* use_dsp = "yes" *) module bsg_mul_add_unsigned #(
     parameter width_a_p = 9
    ,parameter width_b_p = 9
    ,parameter `BSG_INV_PARAM(width_a_p)
    ,parameter `BSG_INV_PARAM(width_b_p)
    ,parameter width_c_p = width_a_p + width_b_p
    ,parameter width_o_p = `BSG_SAFE_CLOG2( ((1 << width_a_p) - 1) * ((1 << width_b_p) - 1) + 
                                                    ((1 << width_c_p)-1) + 1 )
    ,parameter pipeline_p = 0
  ) (
    input clk_i
    ,input [width_a_p-1 : 0] a_i
    ,input [width_b_p-1 : 0] b_i
    ,input [width_c_p-1 : 0] c_i
    ,output [width_o_p-1 : 0] o
    );

    wire [width_o_p-1:0] o_r = a_r * b_r + c_r;

    assign o = o_r;

endmodule


// CHECK: module bsg_mul_add_unsigned(a_i, b_i, c_i, o);
