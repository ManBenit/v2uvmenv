
module uart_rx(
    input rx_clk,rx_start,
    input rst, rx,
    input [3:0] length,
    input parity_type,parity_en,
    input stop2,
    output reg [7:0] rx_out,
    output logic rx_done, rx_error
);

    logic parity = 0;   
    logic [7:0] datard = 0;
    int count = 0;
    int bit_count = 0;

    typedef enum bit [2:0] {idle = 0, start_bit = 1, recv_data = 2, check_parity = 3, check_first_stop = 4, check_sec_stop= 5, done = 6} state_type;
    state_type state = idle, next_state = idle;

    ///////////////////// reset detector
    always@(posedge rx_clk)
    begin
        if(rst)
        state <= idle;
        else
        state <= next_state;
    end

    ///////////////////next_State decoder + output

    ///////////////////// reset detector
    always@(*)
    begin
        case(state)
            idle:  begin
                rx_done  = 0;
                rx_error = 0;
                if(rx_start && !rx)
                    next_state = start_bit;
                else
                    next_state = idle;
                
            end
        
            
            start_bit: begin
                if(count == 7 && rx)
                    begin
                        next_state = idle;
                    end
                else if (count == 15)
                    begin
                        next_state = recv_data;
                    end
                else
                    begin
                        next_state = start_bit;
                    end
            end
        
            recv_data: begin
                if(count == 7) begin
                    datard[7:0]   =  {rx,datard[7:1]};   
                end
                else if(count == 15 && bit_count == (length - 1))
                    begin
                        case(length)
                            5: rx_out = datard[7:3];
                            6: rx_out = datard[7:2];
                            7: rx_out = datard[7:1];
                            8: rx_out = datard[7:0];
                            default : rx_out = 8'h00;
                        endcase

                        if(parity_type)
                            parity = ^datard;
                        else
                            parity  = ~^datard;
                            
                            if(parity_en)
                                next_state = check_parity;
                            else
                                next_state = check_first_stop;
                    end
                else
                    next_state = recv_data;
            end  
            
            check_parity: begin
                if(count == 7) 
                    begin
                    if(rx == parity)
                        rx_error = 1'b0;
                    else
                        rx_error = 1'b1;
                    end  
                else if (count == 15) 
                    begin  
                        next_state = check_first_stop;
                    end
                else
                    begin
                        next_state = check_parity;
                    end
            end       

            check_first_stop: begin
                if(count == 7)
                    begin
                        if(rx != 1'b1)
                            rx_error = 1'b1;
                        else
                            rx_error = 1'b0;
                    end
                else if (count == 15)
                    begin
                        if(stop2)
                            next_state = check_sec_stop;
                        else
                            next_state = done; 
                    end
            end
                  
            check_sec_stop: begin
                if(count == 7)
                    begin
                        if(rx != 1'b1)
                            rx_error = 1'b1;
                        else
                            rx_error = 1'b0;
                    end
                else if (count == 15)
                    begin
                        next_state = done; 
                    end
            end
      
            done :  begin
                rx_done = 1'b1;
                next_state = idle;
                rx_error = 1'b0;
            end    
        endcase
    end


    ///////////////////// reset detector
    always@(posedge rx_clk)
    begin
        case(state)
            idle: begin
                count     <= 0;
                bit_count <= 0;
            end
            
            start_bit: begin
                if(count < 15)
                    count <= count + 1;
                else
                    count <= 0;
            end
        
            recv_data: begin
                if(count < 15)
                    count <= count + 1;
                else begin
                    count <= 0;
                    bit_count <= bit_count + 1;
                    end
            end  
            
            check_parity: begin
                if(count < 15)
                    count <= count + 1;
                else
                    count <= 0;     
            end   

            check_first_stop : begin
                if(count < 15)
                    count <= count + 1;
                else
                    count <= 0;
            end
                    
            check_sec_stop: begin
                if(count < 15)
                    count <= count + 1;
                else
                    count <= 0;
            end
                        
            done :  begin
                count <= 0;
                bit_count <= 0;
            end    
        endcase
    end


endmodule

