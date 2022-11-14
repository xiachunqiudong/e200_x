

module ifu_litebpu(
    input [`E203_PC_SIZE-1:0]     pc,
    
    input                         dec_jal,
    input                         dec_jalr,
    input                         dec_bxx,
    input [`E203_XLEN-1:0]        dec_bjp_imm,
    input [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,

    output                        bpu_busy,
    output                        prdt_taken,
    output [`E203_PC_SIZE-1:0]    prdt_pc_add_op1,
    output [`E203_PC_SIZE-1:0]    prdt_pc_add_op2,

    input                         dec_i_valid,

    // RS1 to read regfile
    output                        bpu2rf_rs1_ena,
    input                         ir_valid_clr,
    input [`E203_XLEN-1:0]        rf2bpu_x1,
    input [`E203_XLEN-1:0]        rf2bpu_rs1,
    
    input                         clk,
    input                         rst_n
);

    // E201 采用了简单的静态分支预测
    // 1. bxx 静态分支预测 预测向后为跳转 向前不跳 pc_next = pc_cur + (imm << 1);
    //    指令最小为2字节(压缩指令) 所以指令地址最低位一定为0 
    // 
    // 

    // imm 最高位为1 为负数 向后跳转 预测为跳转
    assign prdt_taken = (dec_jal | dec_jalr | (dec_bxx & dec_bjp_imm[`E203_XLEN-1]));

    wire dec_jalr_rs1x0 = (dec_jalr_rs1idx == `E203_RFIDX_WIDTH'b0);
    wire dec_jalr_rs1x1 = (dec_jalr_rs1idx == `E203_RFIDX_WIDTH'b1);
    wire dec_jalr_rs1xn = (~dec_jalr_rs1x0 & ~dec_jalr_rs1x1);

    

endmodule