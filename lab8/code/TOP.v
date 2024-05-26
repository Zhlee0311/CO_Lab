`timescale 1ns / 1ps


module TOP (
    clk_H4,  //数码管的时钟信号
    rst,
    clk,
    SW,
    FR,
    ST,
    which,
    seg
);

  input clk_H4, rst, clk;
  input [2:0] SW;
  output [3:0] FR;
  output [2:0] ST;
  output [3:0] which;
  output [7:0] seg;

  wire clk_n;
  assign clk_n = ~clk;  //clk的反相信号
  //除了IM和CU，其他需要时钟信号的模块都使用clk_n

  wire IS_R, IS_IMM, IS_LUI;
  wire PC_Write, IR_Write, Reg_Write;
  wire rs2_imm_s, w_data_s;
  wire [3:0] ALU_OP, OP;


  wire [ 5:0] PC_out;
  wire [31:0] IM_out;


  wire [ 2:0] funct3;
  wire [6:0] opcode, funct7;
  wire [4:0] rs1, rs2, rd;
  wire [31:0] inst, imm;


  wire [31:0] Data_A, Data_B;
  wire [31:0] A, B, F, W_Data;


  reg [31:0] data;

  always @(*) begin
    case (SW)
      3'b000:  data = inst;  //当前指令
      3'b001:  data = imm;  //当前指令对应的立即数
      3'b010:  data = {26'b0, PC_out};  //PC（下一条指令的地址）
      3'b011:  data = IM_out;  //下一条指令
      3'b100:  data = A;
      3'b101:  data = B;
      3'b110:  data = F;
      3'b111:  data = W_Data;
      default: data = 32'h0000_0000;
    endcase
  end

  assign W_Data = (w_data_s == 1) ? imm : F;

  //DISPLAY-数码管显示
  DISPLAY display (
      .clk  (clk_H4),
      .data (data),
      .which(which),
      .seg  (seg)
  );

  //PC-程序计数器
  PC pc (
      .rst(rst),
      .clk(clk_n),
      .en (PC_Write),
      .out(PC_out)
  );

  //IM-指令存储器
  ROM_B rom_b (
      .clka (clk),
      .addra(PC_out),
      .douta(IM_out)
  );

  //IR-指令寄存器
  IR ir (
      .rst(rst),
      .clk(clk_n),
      .en (IR_Write),
      .in (IM_out),
      .out(inst)
  );

  //ID1-初级译码
  ID1 id1 (
      .inst(inst),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .opcode(opcode),
      .funct3(funct3),
      .funct7(funct7),
      .imm(imm)
  );

  //ID2-次级译码
  ID2 id2 (
      .opcode(opcode),
      .funct3(funct3),
      .funct7(funct7),
      .IS_R  (IS_R),
      .IS_IMM(IS_IMM),
      .IS_LUI(IS_LUI),
      .ALU_OP(ALU_OP)
  );

  //CU-控制单元
  CU cu (
      .rst(rst),
      .clk(clk),
      .IS_R(IS_R),
      .IS_IMM(IS_IMM),
      .IS_LUI(IS_LUI),
      .ALU_OP(ALU_OP),
      .PC_Write(PC_Write),
      .IR_Write(IR_Write),
      .Reg_Write(Reg_Write),
      .rs2_imm_s(rs2_imm_s),
      .w_data_s(w_data_s),
      .OP(OP),
      .ST(ST)
  );

  //REG_HEAP-寄存器堆
  REG_HEAP reg_heap (
      .rst(rst),
      .clk(clk_n),
      .en(Reg_Write),
      .R_Addr_A(rs1),
      .R_Addr_B(rs2),
      .W_Addr(rd),
      .W_Data(W_Data),
      .R_Data_A(Data_A),
      .R_Data_B(Data_B)
  );

  //ALU_REG-带有暂存器的ALU
  ALU_REG alu_reg (
      .OP(OP),
      .rs2_imm_s(rs2_imm_s),
      .Data_A(Data_A),
      .Data_B(Data_B),
      .imm(imm),
      .rst(rst),
      .clk_RR(clk_n),
      .clk_F(clk_n),
      .A(A),
      .B(B),
      .F(F),
      .FR(FR)
  );


endmodule
