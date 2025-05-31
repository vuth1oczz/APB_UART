module test;

    logic                           clk;
    logic                           reset_n;
    logic [11:0]                    paddr;
    logic [31:0]                    pwdata;
    logic [3:0]                     pstrb;
    logic                           pwrite;
    logic                           psel;
    logic                           penable;
    logic [31:0]                    prdata;
    logic                           pready;
    logic                           pslverr;
    logic                           rx;   //rx input
    logic                           tx;   //tx output
    logic                           cts_n;
    logic                           rts_n;
   

    
    localparam BAUD_RATE = 115200;
    localparam FREQUENCY_CLK = 50000000;
dti_apb_uart_top #(
    .BAUD_RATE(BAUD_RATE),
    .FREQUENCY_CLK(FREQUENCY_CLK)
) dti_apb_uart_top_i (
  .clk    (clk),
  .reset_n (reset_n),
  .presetn(reset_n),
  .pclk(clk),
  .psel   (psel),
  .penable(penable),
  .pwrite (pwrite),
  .paddr  (paddr),
  .pwdata (pwdata),
  .pstrb  (pstrb),
  .prdata (prdata),
  .pready (pready),
  .pslverr(pslverr),
  .rx     (rx),
  .tx     (tx),
  .cts_n  (cts_n),
  .rts_n  (rts_n)
  );

    

    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 50MHz clock
    end



task Write_tx_data_reg(logic [7:0] tx_data);
        @(posedge clk);
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        pstrb = 4'b0000;
        paddr   = 12'b0;
        pwdata  = 32'b0;
        @(posedge clk);
        psel    = 1'b1;
        penable = 1'b0;
        pwrite  = 1'b1;
        pstrb = 4'b1111;
        paddr   = 12'h0;
        pwdata  = tx_data;
        @(posedge clk);
        psel    = 1'b1;
        penable = 1'b1;
        pwrite  = 1'b1;
        @(posedge clk);
        while (pready == 0) begin
            @(posedge clk);
        end
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        pstrb = 4'b0000;
        paddr   = 12'b0;
        pwdata  = 32'b0;
    endtask
    
    task Write_cfg_reg(logic [4:0] cfg_data);
        @(posedge clk);
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        pstrb = 4'b0000;
        paddr   = 12'h000;
        pwdata  = 32'b0;
        @(posedge clk);
        psel    = 1;
        penable = 0;
        pwrite  = 1;
        pstrb = 4'b1111;
        paddr   = 12'h008;

        pwdata[1:0] = cfg_data[1:0];
        pwdata[2]   = cfg_data[2];
        pwdata[3]   = cfg_data[3];
        pwdata[4]   = cfg_data[4];

        @(posedge clk);
        psel    = 1;
        penable = 1;
        pwrite  = 1;
        @(posedge clk);
        while (pready == 0) begin
            @(posedge clk);
        end
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        pstrb = 4'b0000;
        paddr   = 12'b0;
        pwdata  = 32'b0;
    endtask

    

    task Write_ctrl_reg(logic start_tx);
        @(posedge clk);
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = '0;
        pstrb = 4'b0000;
        pwdata  = '0;
        @(posedge clk);
        psel    = 1;
        penable = 0;
        pwrite  = 1;
        pstrb = 4'b1111;
        paddr   = 12'h00C;
        pwdata[0] = start_tx;
        @(posedge clk);
        psel    = 1;
        penable = 1;
        pwrite  = 1;
        @(posedge clk);
        while (pready == 0) begin
            @(posedge clk);
        end
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        pstrb = 4'b0000;
        paddr   = '0;
        pwdata  = '0;
    endtask
    task Read_tx_data_reg();
        @(posedge clk);
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = '0;
        pwdata  = '0;
        @(posedge clk);
        psel    = 1;
        penable = 0;
        pwrite  = 0;
        paddr   = 12'h000;
        @(posedge clk);
        psel    = 1;
        penable = 1;
        pwrite  = 0;
        @(posedge clk);
        while (pready == 0) begin
            @(posedge clk);
        end
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = '0;
    endtask

    task Read_rx_data_reg();
        @(posedge clk);
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = '0;
        pwdata  = '0;
        @(posedge clk);
        psel    = 1;
        penable = 0;
        pwrite  = 0;
        paddr   = 12'h004;
        @(posedge clk);
        psel    = 1;
        penable = 1;
        pwrite  = 0;
        @(posedge clk);
        while (pready == 0) begin
            @(posedge clk);
        end
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = '0;
    endtask

    task Read_cfg_reg();
        @(posedge clk);
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = '0;
        pwdata  = '0;
        @(posedge clk);
        psel    = 1;
        penable = 0;
        pwrite  = 0;
        paddr   = 12'h008;
        @(posedge clk);
        psel    = 1;
        penable = 1;
        pwrite  = 0;
        @(posedge clk);
        while (pready == 0) begin
            @(posedge clk);
        end
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = '0;
    endtask

    task Read_ctrl_reg();
        @(posedge clk);
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = '0;
        pwdata  = '0;
        @(posedge clk);
        psel    = 1;
        penable = 0;
        pwrite  = 0;
        paddr   = 12'h00C;
        @(posedge clk);
        psel    = 1;
        penable = 1;
        pwrite  = 0;
        @(posedge clk);
        while (pready == 0) begin
            @(posedge clk);
        end
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = '0;
    endtask

    task Read_stt_reg();
        @(posedge clk);
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = '0;
        pwdata  = '0;
        @(posedge clk);
        psel    = 1;
        penable = 0;
        pwrite  = 0;
        paddr   = 12'h10;
        @(posedge clk);
        psel    = 1;
        penable = 1;
        pwrite  = 0;
        @(posedge clk);
        while (pready == 0) begin
            @(posedge clk);
        end
        psel    = 0;
        penable = 0;
        pwrite  = 0;
        paddr   = '0;
    endtask

    
    task send_rx (input [7:0] data);
        begin
            integer i;
            integer data_num;
            integer stop_num;
            case (dti_apb_uart_top_i.register_block.data_bit_num)
                2'b00: data_num = 5;
                2'b01: data_num = 6;
                2'b10: data_num = 7;
                2'b11: data_num = 8;
            endcase

            case (dti_apb_uart_top_i.register_block.stop_bit_num)
                1'b0: stop_num = 1;
                1'b1: stop_num = 2;
            endcase

            rx=1'b0;
            repeat (405) begin
                    @(posedge clk); 
            end

            for (i=0;i<data_num;i++) begin
                rx = data[i]; 
                repeat (405) begin
                    @(posedge clk);
                end
            end

            if (dti_apb_uart_top_i.register_block.parity_en) begin
               // rx = (dti_apb_uart_top_i.register_block.parity_type) ? ~(^(data[data_num-1:0])) : (^(data[data_num-1:0]));
               rx = 1'b1;
                repeat (405) begin
                    @(posedge clk);
                end
            end

            repeat(stop_num) begin
                repeat (405) begin
                    @(posedge clk);
                end
                rx=1;
            end
        end
    endtask

    task send_tx;
        begin
            
          
            integer i;
            integer data_num;
            integer stop_num;
            case (dti_apb_uart_top_i.register_block.cfg_reg[1:0])
                2'b00: data_num = 5;
                2'b01: data_num = 6;
                2'b10: data_num = 7;
                2'b11: data_num = 8;
            endcase

            case (dti_apb_uart_top_i.register_block.cfg_reg[2])
                1'b0: stop_num = 1;
                1'b1: stop_num = 2;
            endcase
            repeat (data_num + stop_num + dti_apb_uart_top_i.register_block.cfg_reg[3]) begin
                repeat (432) begin
                    @(posedge clk);
                end                   
            end
            @(posedge clk);
            @(posedge clk);
        end
    endtask


    initial begin
    reset_n = 0;
    pwdata = 32'h000;
    paddr = 12'h000;
    pstrb = 4'b0;
    pwrite = 1'b0;
    psel = 1'b0;
    penable = 1'b0;
    cts_n = 1'b1;
    rx = 'h1;
    @(posedge clk);
    @(posedge clk);
    fork
        // Nhiệm vụ 1: Ghi dữ liệu và đọc dữ liệu từ các thanh ghi
        begin
            reset_n = 1'b1;
            @(posedge clk);

            Write_tx_data_reg(32'h000000A3);
            Write_cfg_reg(8'b00011111);
            Write_ctrl_reg(1'b1);
            
           repeat(1000) 
           begin
           @(posedge clk);
           end
            

        end


        begin
            wait (dti_apb_uart_top_i.register_block.start_tx == 1);
             repeat(1000) 
           begin
           @(posedge clk);
           end
            cts_n = 1'b0;
           // send_tx();
            wait (dti_apb_uart_top_i.register_block.tx_done);
            repeat(1000) 
           begin
           @(posedge clk);
           end
           cts_n= 1'b1;
           Write_tx_data_reg(32'h00000012);
           Write_cfg_reg(8'b00011101);
           Write_ctrl_reg(1'b1);
            
            wait (dti_apb_uart_top_i.register_block.start_tx == 1);
            repeat(1000) 
           begin
           @(posedge clk);
           end
            cts_n = 1'b0;
           // send_tx();
            wait (dti_apb_uart_top_i.register_block.tx_done);
            repeat(1000) 
           begin
           @(posedge clk);
           end
           send_rx(8'b10010011);
           wait (dti_apb_uart_top_i.register_block.rx_done);
           repeat(1000) 
           begin
           @(posedge clk);
           end
           Read_rx_data_reg();
           repeat(1000) 
           begin
           @(posedge clk);
           end  
             repeat(1000) 
           begin
           @(posedge clk);
           end
           send_rx(8'b10101010);
           wait (dti_apb_uart_top_i.register_block.rx_done);
           repeat(1000) 
           begin
           @(posedge clk);
           end
           Read_rx_data_reg();
           repeat(1000) 
           begin
           @(posedge clk);
           end 
           $stop;
        end
             
       
    join
    @(posedge clk);
    $finish;
end


//     initial begin
//         reset_n = 0;
//         pwdata= 32'h000;
//         paddr = 12'h000;
//         pstrb = 4'b0;
//         pwrite = 1'b0;
//         psel = 1'b0;
//         penable = 1'b0;
//         @(posedge clk);
//         fork
//             begin
//                 reset_n = 1'b1;

//                 Write_tx_data_reg(32'h000000A3);
//                 Write_cfg_reg (8'b00011111);
//                 Write_ctrl_reg (1'b1);
//                 @(posedge clk);


//                 Read_cfg_reg();
//                 Read_ctrl_reg();
//                 Read_rx_data_reg();
//                 Read_stt_reg();
//                 Read_tx_data_reg();
//                 $display("%b",dti_apb_uart_top_i.register_block.ctrl_reg[0]);

//             end

//             begin
//                 while(dti_apb_uart_top_i.register_block.start_tx)
//                     begin   
//                         @(posedge clk);
//                     end
//                     send_tx();
//             end
//         join
//         @(posedge clk);


//     #200ns;
//   $finish;
//   end

endmodule