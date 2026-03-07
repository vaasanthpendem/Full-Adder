module FA_tb;

logic a,b,cin;
logic sum,cout;

FullAdder dut(
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
);

initial begin
    $display("A B Cin | Sum Cout");

    a=0; b=0; cin=0; #1;
    $display("%0b %0b %0b | %0b %0b",a,b,cin,sum,cout);

    a=0; b=0; cin=1; #1;
    $display("%0b %0b %0b | %0b %0b",a,b,cin,sum,cout);

    a=0; b=1; cin=0; #1;
    $display("%0b %0b %0b | %0b %0b",a,b,cin,sum,cout);

    a=0; b=1; cin=1; #1;
    $display("%0b %0b %0b | %0b %0b",a,b,cin,sum,cout);

    a=1; b=0; cin=0; #1;
    $display("%0b %0b %0b | %0b %0b",a,b,cin,sum,cout);

    a=1; b=0; cin=1; #1;
    $display("%0b %0b %0b | %0b %0b",a,b,cin,sum,cout);

    a=1; b=1; cin=0; #1;
    $display("%0b %0b %0b | %0b %0b",a,b,cin,sum,cout);

    a=1; b=1; cin=1; #1;
    $display("%0b %0b %0b | %0b %0b",a,b,cin,sum,cout);

    $finish;
end

endmodule
