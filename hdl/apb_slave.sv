module apb_slave
(   
    input                            pclk            ,
    input                            presetn         ,
    input                            psel            ,
    input                            penable         ,
    input                            pwrite          ,
    input       [3:0]                pstrb           ,
    input       [11:0]               paddr           ,
    input       [31:0]               pwdata          ,

    input                            wadderr         ,
    input                            radderr         ,
    output                           pready          ,
    output                           pslverr         ,
    output      [31:0]               prdata          ,

    // output to register block
    output      [11:0]               waddr           ,
    output      [31:0]               wdata           ,
    output                           pwrite_o        ,
    output      [11:0]               raddr           ,
    //input from register block
    input       [31:0]               rdata           ,
    output logic                     host_read_data

 );

    enum logic [1:0] {IDLE, WRITE, READ} curr_state, next_state;

    logic       [31:0]               reg_wdata       ;
    logic       [11:0]               reg_waddr       ;
    logic       [11:0]               reg_raddr       ;
    logic       [31:0]               reg_rdata       ;
    logic                            reg_pready      ;


    

    always_comb begin   : CAL_NEXT_STATE
        case(curr_state)
                IDLE: begin
                    casex ({psel,penable,pwrite})
                        3'b0xx: next_state = IDLE;
                        3'b110: next_state = READ;
                        3'b111: next_state = WRITE;  
                    endcase 
                end
                WRITE: begin
                    casex ({psel,penable,pwrite})
                        3'bxxx: next_state = IDLE;
                        3'b111: next_state = WRITE;  
                    endcase 
                end
                READ: begin
                    casex ({psel,penable,pwrite})
                        3'bxxx: next_state = IDLE;
                        3'b110: next_state = READ;
                    
                    endcase 
                end
        endcase
    end

    always_comb begin   : CAL_OUTPUT
        reg_waddr  =12'h0;
        reg_wdata = 32'h0;
        reg_raddr = 12'h0;
        reg_rdata = 32'h0;
        reg_pready = 1'b1;
        host_read_data = 1'b0;
        case(curr_state)
                IDLE: begin
                    reg_pready = 1'b0;
                end
                WRITE: begin
                    if(~penable & ~psel) begin
                        reg_pready = 1'b0;
                    end else begin
                        reg_pready = 1'b1;
                    end
                    
                    if(pstrb[0]) begin
                        reg_waddr = paddr;
                        reg_wdata = pwdata;
                    
                    end else begin
                        reg_waddr = paddr;
                        reg_wdata = 'hz;
                    end
                end
                READ: begin
                    reg_pready = 1'b1;
                    reg_raddr = paddr;
                    reg_rdata = rdata;
                    host_read_data = 1'b1;
                end
                default: begin
                end
        endcase
    end


    always_ff @( posedge pclk, negedge presetn ) begin : UPDATE_CURRENT_STATE
        if(~presetn) begin
            curr_state <= IDLE; 
        end else begin
            curr_state <= next_state;
        end
        
    end


    assign prdata     =     reg_rdata             ;
    assign waddr      =     reg_waddr             ;
    assign wdata      =     reg_wdata             ;
    assign raddr      =     reg_raddr             ;
    assign pwrite_o   =     pwrite                ;
    assign pready     =     reg_pready            ;
    assign pslverr    =  ~( wadderr & radderr )   ;
endmodule