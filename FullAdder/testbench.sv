
interface FA_if;
  logic a,b,cin,sum,cout;
endinterface

class transaction;
  rand bit a,b,cin;
  bit sum,cout;
  
  function new();
  endfunction
  
  function void display(string msg="");
    $display("s A=%0b B=%0b Cin=%0b| Sum=%0b Cout=%0b",a,b,cin,sum,cout);
  endfunction
  
  endclass

class generator;
  mailbox #(transaction) gen2drv;
  
  function new(mailbox #(transaction) gen2drv);
    this.gen2drv=gen2drv;
  endfunction
  
  task generateStimuli();
    transaction tr;
    repeat(10) begin
      tr=new();
      assert(tr.randomize()) else $display("Randomization failed at time %0t",$time);
      gen2drv.put(tr);
      #10;
    end
    endtask
endclass

// Driver: Drives stimuli to the interface
class driver;
  virtual FA_if tb_if;
  mailbox #(transaction) gen2drv;
  mailbox #(transaction) drv2scb;  
  
  function new(virtual FA_if tb_if, mailbox #(transaction) gen2drv, mailbox #(transaction) drv2scb);
    this.tb_if = tb_if;
    this.gen2drv = gen2drv;
    this.drv2scb = drv2scb;
  endfunction
  
  task drive();
    transaction tr;
    repeat(10) begin
      gen2drv.get(tr);
      tb_if.a=tr.a;
      tb_if.b=tr.b;
      tb_if.cin=tr.cin;
      drv2scb.put(tr);
      #10;
    end 
  endtask
endclass

// Monitor: Samples the interface and sends to Scoreboard
class monitor;
  virtual FA_if tb_if;
  mailbox #(transaction) mon2scb;
  
  function new(virtual FA_if tb_if, mailbox #(transaction) mon2scb);
    this.tb_if = tb_if;
    this.mon2scb = mon2scb;
  endfunction
  
  task observe();
    transaction tr;
    $display("Time\t A B Cin | Sum Cout");
    $display("-------------------------");
    repeat(10) begin
      // Sample FIRST (at the beginning of the time slot)
      tr = new();
      tr.a = tb_if.a;
      tr.b = tb_if.b;
      tr.cin = tb_if.cin;
      tr.sum = tb_if.sum;
      tr.cout = tb_if.cout;
      
      $display("%0t\t %b %b %b| %b %b", $time, tr.a, tr.b, tr.cin, tr.sum, tr.cout);
      mon2scb.put(tr);
      
      #10;  
    end
  endtask
endclass

// Scoreboard: Validates the results
class scoreboard;
  mailbox #(transaction) drv2scb;
  mailbox #(transaction) mon2scb;
  function new(mailbox #(transaction) drv2scb,mailbox #(transaction) mon2scb);
    this.drv2scb=drv2scb;
    this.mon2scb=mon2scb;
  endfunction
  
  task check();
    transaction dtr,mtr;
    bit expectedSum,expectedCout;
    repeat(10)begin
      drv2scb.get(dtr);
      mon2scb.get(mtr);
      expectedSum=dtr.a^dtr.b^dtr.cin;
      expectedCout=(dtr.a&dtr.b)|(dtr.b&dtr.cin)|(dtr.cin&dtr.a);
      
      if(mtr.sum!==expectedSum||mtr.cout!==expectedCout)//begin
        $display("ERROR at %0t: Expected Sum=%b Expected Cout=%b| Got Sum=%b Got Cout=%b",$time, expectedSum,expectedCout,mtr.sum,mtr.cout);
      //end
      else  $display("PASS: A=%b B=%b Cin=%b | Sum=%b Cout=%b",dtr.a,dtr.b,dtr.cin,mtr.sum,mtr.cout);
    end
  endtask
endclass

class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard scb;
  mailbox #(transaction) gen2drv,mon2scb,drv2scb;
  virtual FA_if tb_if;
  function new(virtual FA_if tb_if);
    this.tb_if = tb_if;
    gen2drv = new();
    mon2scb = new();
    drv2scb = new();  
    gen = new(gen2drv);
    drv = new(tb_if, gen2drv, drv2scb);  
    mon = new(tb_if, mon2scb);
    scb = new(drv2scb, mon2scb);
  endfunction
  
  task run;
    fork
      gen.generateStimuli();
      drv.drive();
      mon.observe();
      scb.check();
    join
  endtask
endclass

module FA_tb;
  FA_if tb_if();
  FA dut(
    .a(tb_if.a),
    .b(tb_if.b),
    .cin(tb_if.cin),
    .sum(tb_if.sum),
    .cout(tb_if.cout)
  );
  environment env;
  initial begin
    $dumpfile("dump.vcd"); //generation of wave forms on edaplayground.com
    $dumpvars;
    env=new(tb_if);
    env.run();
    $finish;
  end
endmodule
    