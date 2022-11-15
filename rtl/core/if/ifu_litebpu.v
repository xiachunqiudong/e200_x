

module ifu_litebpu(
    // current PC
    input [`E203_PC_SIZE-1:0]     pc,
    
    // mini-decoded
    input                         dec_jal,
    input                         dec_jalr,
    input                         dec_bxx,
    input [`E203_XLEN-1:0]        dec_bjp_imm,
    input [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,

    // IR的rd以及oitf的状态 用于判断数据相关性
    input                         oitf_empty,
    input                         ir_empty,
    input                         ir_rs1_en,
    input                         jalr_rs1idx_cam_irridx,

    // op to next-pc adder
    output                        bpu_wait,
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
    // * JAL  采用PC相对寻址的方式 pc_next = pc_cur + (imm << 1); 无条件跳转
    // * JALR 
    // * BXX  静态分支预测 预测向后为跳转 向前不跳 pc_next = pc_cur + (imm << 1);
    //        指令最小为2字节(压缩指令) 所以指令地址最低位一定为0 
    // 
    // 

    // imm 最高位为1 为负数 向后跳转 预测为跳转
    assign prdt_taken = (dec_jal | dec_jalr | (dec_bxx & dec_bjp_imm[`E203_XLEN-1]));

    wire dec_jalr_rs1x0 = (dec_jalr_rs1idx == `E203_RFIDX_WIDTH'b0);
    wire dec_jalr_rs1x1 = (dec_jalr_rs1idx == `E203_RFIDX_WIDTH'b1);
    wire dec_jalr_rs1xn = (~dec_jalr_rs1x0 & ~dec_jalr_rs1x1);

    // 判断数据相关性
    // 判断x1是否可能和EXU中的指令有数据相关性
    // 1. OITF不为空，可能有长指令在执行，结果可能写回到x1中
    // 2. IR中指令写回的目标地址为x1，存在RAW相关性
    wire jalr_rs1x1_dep = dec_i_valid & dec_jalr & dec_jalr_rs1x1 & ((~oitf_empty) | (jalr_rs1idx_cam_irridx));
    
    // 如果rs1是除了x0和x1的其他寄存器 不对其进行加速
    // 需要判断第一个读端口是否空闲且不存在资源冲突
    // 1. OITF不为空，可能有长指令在执行，结果可能写回到x1中
    // 2. IR寄存器中存在指令，结果可能写回到xn
    wire jalr_rs1xn_dep = dec_i_valid & dec_jalr & dec_jalr_rs1xn & ((~oitf_empty) | (~ir_empty));

    wire jalr_rs1xn_dep_ir_clr = (jalr_rs1xn_dep & oitf_empty & (~ir_empty)) & (ir_valid_clr | (~ir_rs1_en));

    // 由于没有特殊优化，所以需要判断寄存器文件第一个读端口是否空闲
    wire rs1xn_rdrf_r;
    wire rs1xn_rdrf_set = (~rs1xn_rdrf_r) & dec_i_valid & dec_jalr &dec_jalr_rs1xn & ((~jalr_rs1xn_dep) | jalr_rs1xn_dep_ir_clr);
    wire rs1xn_rdrf_clr = rs1xn_rdrf_r;
    wire rs1xn_rdrf_ena = rs1xn_rdrf_set | rs1xn_rdrf_clr;
    wire rs1xn_rdrf_nxt = rs1xn_rdrf_set | (~rs1xn_rdrf_clr);

    assign bpu2rf_rs1_ena = rs1xn_rdrf_set;

    assign bpu_wait = jalr_rs1x1_dep | jalr_rs1xn_dep | rs1xn_rdrf_set;

    // 预测PC计算
    // 基地址 + 偏移量 相对寻址
    // jal和bxx PC作为基地址
    // jalr    从寄存中取值作为基地址
    assign prdt_pc_add_op1 = (dec_jal  | dec_bxx)        ? pc[`E203_PC_SIZE-1:0]
                           // rs1 = x0 直接使用常数0
                           : (dec_jalr & dec_jalr_rs1x0) ? `E203_PC_SIZE'b0 
                           // rs1 = x1 x1用于link寄存器 用于保存函数调用返回地址
                           // 直接从regfile中拉线取出 为了避免RAW相关性 需要判断EXU没有写回x1                
                           : (dec_jalr & dec_jalr_rs1x1) ? rf2bpu_x1[`E203_PC_SIZE-1:0]     
                           :                               rf2bpu_rs1[`E203_PC_SIZE-1:0];   // 

    assign prdt_pc_add_op2 = dec_bjp_imm[`E203_PC_SIZE-1:0];

endmodule
