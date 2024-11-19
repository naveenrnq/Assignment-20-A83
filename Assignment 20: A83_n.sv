class transaction;
 
  rand bit [7:0] a;
  rand bit [7:0] b;
  rand bit wr;
 
endclass


class generator;

  transaction t;
  mailbox #(transaction) mbx;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task main();
    for(int i = 0; i < 10; i++) begin
     t = new();
     assert(t.randomize) else $display("Randomization Failed");
      $display("[GEN] : DATA SENT : a, b, wr: %0d | %0d | %0d", t.a, t.b, t.wr);
     mbx.put(t);
     #10;
    end
  endtask

endclass

class driver;

  transaction dc;
  mailbox #(transaction) mbx;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task main();
    forever begin
      mbx.get(dc);
      $display("[DRV] : DATA RCVD : a, b, wr: %0d | %0d | %0d", dc.a, dc.b, dc.wr);
      #10;
    end
  endtask

endclass


module tb;

  generator g;
  driver d;
  mailbox #(transaction) mbx;

  initial begin
    mbx = new();
    g = new(mbx);
    d = new(mbx);

    fork
      g.main();
      d.main();
    join

  end
  

endmodule
