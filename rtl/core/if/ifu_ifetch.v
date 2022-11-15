`include "e203_defines.v"


// 产生下一个PC 以及总线访问
module ifu_ifetch(
    output [`E203_PC_SIZE-1:0] inspect_pc,
    // 初始化PC
    input  [`E203_PC_SIZE-1:0] pc_rtvec,
    
    //xxxxxxxxxxxxxxxxxxxxxxxxxxx//
    // Fetch interface to Memory
    //xxxxxxxxxxxxxxxxxxxxxxxxxxx//
    // * IFetch REQ channel
    output                     ifu_req_valid, // Handshake valid
    input                      ifu_req_ready, // Handshake ready
    // Note : 请求地址可能是非对齐的 req_len 
    //        (ITCM, ICache, Sys-mem) 会处理非对齐情况 以及分割与合并的工作
    output [`E203_PC_SIZE-1:0] ifu_req_pc,      // Fetch PC
    output                     ifu_req_seq,     // 当前指令为顺序取指
    output                     ifu_req_rv32,    // 32bit ? 
    output [`E203_PC_SIZE-1:0] ifu_req_last_pc, // ?
    // * IFetch REQ channel
    output                     ifu_rsp_ready,
    input                      ifu_rsp_valid,
    input                      ifu_rsp_err,
    // Note : RSP channel 永远返回一个有效的地址
    //        非对齐取指的情况是由存储单元处理的
    input [`E203_INSTR_SIZE-1:0] ifu_rsp_instr, // response instruction

    //xxxxxxxxxxxxxxxxxxxxxxxxxxx//
    // IR stage to EXU interface
    //xxxxxxxxxxxxxxxxxxxxxxxxxxx//
    output [`E203_INSTR_SIZE-1:0]  ifu_o_ir, // 指令
    output [`E203_PC_SIZE-1:0]     ifu_o_pc, // 指令的pc
    output                         ifu_o_pc_vld,
    output [`E203_RFIDX_WIDTH-1:0] ifu_o_rs1idx,
    output [`E203_RFIDX_WIDTH-1:0] ifu_o_rs2idx,
    output                         ifu_o_prdt_taken, // BXX is predict as taken
    output                         ifu_o_misalgn,    // 取指非对齐
    output                         ifu_o_buserr,     // 取指总线错误
    output                         ifu_o_muldiv_b2b, 
    output                         ifu_o_valid,      // 和EXU的握手
    output                         ifu_o_ready,

    output                    pipe_flush_ack,
    input                     pipe_flush_req,
    input [`E203_PC_SIZE-1:0] pipe_flush_op1,
    input [`E203_PC_SIZE-1:0] pipe_flush_op2,
    
    // 暂停取指
    input ifu_halt_req,
    output ifu_halt_ack,

    // 
    input                         oitf_empty,
    input [`E203_XLEN-1:0]        rf2ifu_x1,
    input [`E203_XLEN-1:0]        rf2ifu_rs1,
    input                         dec2ifu_rs1en,
    input                         dec2ifu_rden,
    input [`E203_RFIDX_WIDTH-1:0] dec2ifu_rdidx,
    input                         dec2ifu_mulhsu,
    input                         dec2ifu_div,
    input                         dec2ifu_rem,
    input                         dec2ifu_divu,
    input                         dec2ifu_remu,

    input clk,
    input rst_n
);


endmodule