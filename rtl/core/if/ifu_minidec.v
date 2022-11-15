

module ifu_minidec(
    // IR stage to Deco
    input [`E203_INSTR_SIZE-1:0] instr;

    // decoded info-bus

    output                         dec_rs1_en,
    output                         dec_rs2_en,
    output [`E203_RFIDX_WIDTH-1:0] dec_rs1idx,
    output [`E203_RFIDX_WIDTH-1:0] dec_rs2idx,

    output                         dec_mulhsu,
    output                         dec_mul,
    output                         dec_rem,
    output                         dec_divu,
    output                         dec_remu,

    output                         dec_rv32, // 32bit or 16bit
    output                         dec_bjp, // is branch ? 
    output                         dec_jal, 
    output                         dec_jalr,
    output                         dec_bxx, // beq, bne, blt, bge, bgt
    output [`E203_RFIDX_WIDTH-1:0] dec_jalr_rs1idx,
    output [`E203_XLEN-1:0]        dec_bjp_imm
);

    exu_decode u_exu_decode();

endmodule