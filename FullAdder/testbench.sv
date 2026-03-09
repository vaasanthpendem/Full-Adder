
interface FA_if;
logic a,b,cin;
logic sum,cout;
endinterface

module FA_tb;
FA_if tb_if();

FullAdder dut(
    .a(tb_if.a),
    .b(tb_if.b),
    .cin(tb_if.cin),
    .sum(tb_if.sum),
    .cout(tb_if.cout)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
     
    tb_if.a=0;tb_if.b=0;tb_if.cin=1;#10
    tb_if.a=0;tb_if.b=1;tb_if.cin=1;#10
    tb_if.a=1;tb_if.b=0;tb_if.cin=0;#10
    tb_if.a=1;tb_if.b=1;tb_if.cin=0;#10
    tb_if.a=1;tb_if.b=1;tb_if.cin=1;#10

    $finish;
end

endmodule
