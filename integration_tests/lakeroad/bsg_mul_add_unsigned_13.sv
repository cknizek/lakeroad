// RUN: outfile=$(mktemp)
// RUN: (racket $LAKEROAD_DIR/bin/main.rkt \
// RUN:  --solver stp \
// RUN:  --verilog-module-filepath %s \
// RUN:  --architecture xilinx-ultrascale-plus \
// RUN:  --template dsp \
// RUN:  --out-format verilog \
// RUN:  --top-module-name bsg_mul_add_unsigned \
// RUN:  --verilog-module-out-signal o:27 \
// RUN:  --initiation-interval 3 \
// RUN:  --clock-name clk_i \
// RUN:  --module-name test_module \
// RUN:  --input-signal a_i:13 \
// RUN:  --input-signal b_i:13 \
// RUN:  --input-signal c_i:26 \
// RUN:  --timeout 120 \
// RUN:  --extra-cycles 2 \
// RUN:  || true) \
// RUN:  > $outfile \
// RUN:  2>&1
// RUN: FileCheck %s < $outfile

`include "bsg_defines.sv"
  
(* use_dsp = "yes" *) module bsg_mul_add_unsigned #(
     parameter width_a_p = 13
    ,parameter width_b_p = 13
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

    localparam pre_pipeline_lp = 0;
    localparam post_pipeline_lp = pipeline_p;

    wire [width_a_p-1:0] a_r;
    wire [width_b_p-1:0] b_r;
    wire [width_c_p-1:0] c_r;

    bsg_dff_chain #(width_a_p + width_b_p + width_c_p, pre_pipeline_lp)
        pre_mul_add (
            .clk_i(clk_i)
            ,.data_i({a_i, b_i, c_i})
            ,.data_o({a_r, b_r, c_r})
        );

    wire [width_o_p-1:0] o_r = a_r * b_r + c_r;

    bsg_dff_chain #(width_o_p, post_pipeline_lp)
        post_mul_add (
            .clk_i(clk_i)
            ,.data_i(o_r)
            ,.data_o(o)
        );
endmodule


// CHECK: module bsg_mul_add_unsigned(a_i, b_i, c_i, o);