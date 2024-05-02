`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/29 20:37:20
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU(
    input [31:0]ALU_A,
    input [31:0]ALU_B,
    input [3:0]ALU_OP,
    output [31:0]ALU_F,
    output reg[3:0]flag
);

reg C32;//最高位进位
reg tmp;//暂存变量
reg add;//是否为加法
reg [31:0]F;//运算结果
integer cnt;//循环计数变量

always@(*)
begin
    case(ALU_OP)
        4'b0000:{C32,F}=ALU_A+ALU_B;
        4'b0001:{C32,F}=ALU_A<<ALU_B;
        4'b0010:{C32,F}=$signed(ALU_A)<$signed(ALU_B)?1:0;
        4'b0011:{C32,F}=ALU_A<ALU_B?1:0;
        4'b0100:{C32,F}=ALU_A^ALU_B;
        4'b0101:{C32,F}=ALU_A>>ALU_B;
        4'b0110:{C32,F}=ALU_A|ALU_B;
        4'b0111:{C32,F}=ALU_A&ALU_B;
        4'b1000:{C32,F}=ALU_A-ALU_B;
        4'b1101:{C32,F}=ALU_A>>>ALU_B;
        default:{C32,F}=0;
    endcase

tmp=0;
for(cnt=0;cnt<=31;cnt=cnt+1)
begin
    tmp=tmp||F[cnt];
end

if(tmp==0)
begin
    flag[3]=1;
end
else 
begin
    flag[3]=0;
end

add=(ALU_OP==4'b0000)?1:0;

flag[2]=add^C32;

flag[1]=ALU_A[31]^ALU_B[31]^C32^F[31];

flag[0]=F[31];

end

assign ALU_F=F;

endmodule