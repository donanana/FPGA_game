module LD_final_project(output reg [7:0] DATA_R, DATA_G, DATA_B,
								output reg [6:0] d7_1, 
								output reg [2:0] COMM,
								output reg [3:0] Life,
								output reg [1:0] COMM_CLK,
								output EN,beep,
								input CLK, clear, Left, Right);
	reg [7:0] plate [7:0];
	reg [7:0] people [7:0];
	reg [6:0] seg1, seg2;
	reg [3:0] bcd_s,bcd_m;
	reg [2:0] random01, random02, random03, r, r1, r2;
	reg left, right, temp;
	segment7 S0(bcd_s, A0,B0,C0,D0,E0,F0,G0);
	segment7 S1(bcd_m, A1,B1,C1,D1,E1,F1,G1);
	divfreq div0(CLK, CLK_div);
	divfreq1 div1(CLK, CLK_time);				//時間的除頻器
	divfreq2 div2(CLK, CLK_mv);				//物件移動的除頻器
	divfreq3 div3(CLK, CLK_halfsec);			//提示音效的除頻器
	byte line, count, count1;
	integer a, b, c, touch, bouns, life_value, s_noticed_times, s_notice, notice;
//初始值
	initial
		begin
			bcd_m = 0;
			bcd_s = 0;
			line = 3;
			s_notice = 0;		
			random01 = (5*random01 + 3)%16;
			r = random01 % 8;
			random02 = (5*(random02+1) + 3)%16;
			r1 = random02 % 8;
			random03= (5*(random03+2) + 3)%16;
			r2 = random03 % 8;
			a = 0;
			b = 0;
			c = 0;
			touch = 1;		//default hp is 3
			beep = 0;
			DATA_R = 8'b11111111;
			DATA_G = 8'b11111111;
			DATA_B = 8'b11111111;
			plate[0] = 8'b11111111;
			plate[1] = 8'b11111111;
			plate[2] = 8'b11111111;
			plate[3] = 8'b11111111;
			plate[4] = 8'b11111111;
			plate[5] = 8'b11111111;
			plate[6] = 8'b11111111;
			plate[7] = 8'b11111111;
			people[0] = 8'b11111111;
			people[1] = 8'b11111111;
			people[2] = 8'b11111111;
			people[3] = 8'b00111111;
			people[4] = 8'b11111111;
			people[5] = 8'b11111111;
			people[6] = 8'b11111111;
			people[7] = 8'b11111111;
			count1 = 0;
		end

//7段顯示器的視覺暫留
always@(posedge CLK_div)
	begin
		seg1[0] = A0;
		seg1[1] = B0;
		seg1[2] = C0;
		seg1[3] = D0;
		seg1[4] = E0;
		seg1[5] = F0;
		seg1[6] = G0;
		
		seg2[0] = A1;
		seg2[1] = B1;
		seg2[2] = C1;
		seg2[3] = D1;
		seg2[4] = E1;
		seg2[5] = F1;
		seg2[6] = G1;
		
		if(count1 == 0)
			begin
				d7_1 <= seg1;
				COMM_CLK[1] <= 1'b1;
				COMM_CLK[0] <= 1'b0;
				count1 <= 1'b1;
			end
		else if(count1 == 1)
			begin
				d7_1 <= seg2;
				COMM_CLK[1] <= 1'b0;
				COMM_CLK[0] <= 1'b1;
				count1 <= 1'b0;
			end
		
		


	end

//計時&進位	
always@(posedge CLK_time, posedge clear)
	begin

		if(clear)
			begin
				bcd_m = 3'b0;
				bcd_s = 4'b0;
				//更改
			end
		else
			begin
				if(touch < 4)//bug 應該用life_value判斷
					begin
						if(bcd_s >= 9)
							begin
								bcd_s <= 0;		
								bcd_m <= bcd_m + 1;
							end
						else
							begin
							bcd_s <= bcd_s + 1;
							end
						if(bcd_m >= 9) bcd_m <= 0;
					end
			end
	end

//主畫面的視覺暫留	
always@(posedge CLK_div)
	begin
		//更改
		if(clear == 1)
			life_value = 3;
		if(count >= 7)
			count <= 0;
		else
			count <= count + 1;
		COMM = count;
		EN = 1'b1;
		//更改 **
//		life_value = life_value + bouns - touch;//bug 值錯誤  **

		if(touch < 4) 		
			begin
				DATA_G <= plate[count];
				DATA_R <= people[count];
				if(touch == 0)
					Life <= 4'b1111;
				else if(touch == 1)
					Life <= 4'b1110;
				else if(touch == 2)
					Life <= 4'b1100;				
				else if(touch == 3)
					Life <= 4'b1000;
			end
		else
			begin
				DATA_R <= plate[count];
				DATA_G <= 8'b11111111;
				Life <= 4'b0000;
			end
	end

/*音效
	s_notice 有三種狀態
	1 = 血量增加	響一下
	2 = 血量減少 響兩下
	3 = 遊戲結束 長響
	
	beep = 控制揚聲器開關
	
	
*/
always@(posedge CLK_halfsec)
	begin
		if(clear == 1)
			begin
			beep = 0;
			end
		if ((s_notice > 0))
			begin
				if (s_notice == 3)
					begin
						beep = 1;
					end
				else 
					begin
						if((s_notice < 3) && (s_notice != s_noticed_times) && (beep == 0))
							begin
								beep = 1;
							end
						else
							begin
								beep = 0;
							end
					end
			end


			
	end

	
//遊戲
always@(posedge CLK_mv)
	begin
		right = Right;
		left = Left;	
		if(clear == 1)
				begin
					s_notice = 0;			//音效的狀態  state of the notice
					s_noticed_times = 0;	//紀錄響了多少次
					touch = 1;		//default hp is 3
					bouns = 1;		//是否可以增加血量 用於防止一次增加過多血量
					notice = 1; 	//是否可以開啟揚聲器 用於把兩次音效區間開來
					line = 3;
					a = 0;
					b = 0;
					c = 0;
					random01 = (5*random01 + 3)%16;
					r = random01 % 8;
					random02 = (5*(random02+1) + 3)%16;
					r1 = random02 % 8;
					random03= (5*(random03+2) + 3)%16;
					r2 = random03 % 8;
					plate[0] = 8'b11111111;
					plate[1] = 8'b11111111;
					plate[2] = 8'b11111111;
					plate[3] = 8'b11111111;
					plate[4] = 8'b11111111;
					plate[5] = 8'b11111111;
					plate[6] = 8'b11111111;
					plate[7] = 8'b11111111;
					people[0] = 8'b11111111;
					people[1] = 8'b11111111;
					people[2] = 8'b11111111;
					people[3] = 8'b00111111;
					people[4] = 8'b11111111;
					people[5] = 8'b11111111;
					people[6] = 8'b11111111;
					people[7] = 8'b11111111;
					
				end
////////////////////////////////////////
			//fall object 1
		if(touch < 4)//bug 應該用life_value判斷 **
			begin
				if(a == 0)
					begin
						plate[r][a] = 1'b0;
						a = a+1;
					end
				else if (a > 0 && a <= 7)
						begin
							plate[r][a-1] = 1'b1;
							plate[r][a] = 1'b0;
							a = a+1;
						end
				else if(a == 8) 
					begin
						plate[r][a-1] = 1'b1;
						random01 = (5*random01 + 3)%16;
						r = random01 % 8;
						a = 0;
					end
/////////////////////////////////////////	
			//fall object 2
				if(b == 0)
					begin
						plate[r1][b] = 1'b0;
						b = b+1;
					end
				else if (b > 0 && b <= 7)
					begin
						plate[r1][b-1] = 1'b1;
						plate[r1][b] = 1'b0;
						b = b+1;
					end
				else if(b == 8) 
					begin
						plate[r1][b-1] = 1'b1;
						random02 = (5*(random01+1) + 3)%16;
						r1 = random02 % 8;
						b = 0;
					end
/////////////////////////////////////////		
			//fall object 3
				if(c == 0)
					begin
						plate[r2][c] = 1'b0;
						c = c+1;
					end
				else if (c > 0 && c <= 7)
					begin
						plate[r2][c-1] = 1'b1;
						plate[r2][c] = 1'b0;
						c = c+1;
					end
				else if(c == 8) 
					begin
						plate[r2][c-1] = 1'b1;
						random03= (5*(random01+2) + 3)%16;
						r2 = random03 % 8;
						c = 0;
					end
/////////////////////////////////////////	
			//people move		
				if((right == 1) && (line != 7))
					begin
						people[line][6] = 1'b1;
						people[line][7] = 1'b1;
						line = line + 1;
					end
				if((left == 1) && (line != 0))
					begin
						people[line][6] = 1'b1;
						people[line][7] = 1'b1;
						line = line - 1;
					end
				people[line][6] = 1'b0;
				people[line][7] = 1'b0;
///////// one bouns health per 9 sec 
				if((bcd_s >= 9) && (touch > 0) && (bouns == 1))				//check bouns health on/off
					begin
						bouns = 0;		//bouns off
						touch = touch - 1'b1;	//decrease the count of damaged
						s_notice = 1;
					end
					
				if(bcd_s !=9)
					begin
						bouns = 1;
					end
////////////////////////
				if(plate[line][6] == 0)
					begin
						touch <= touch + 1'b1;
						
						s_notice = 2;

						plate[r][6] = 1'b1;
						
						plate[r1][6] = 1'b1;
						
						plate[r2][6] = 1'b1;
						
						a = 8;
						b = 8;
						c = 8;
					end
				else if (plate[line][7] == 0)
					begin
						touch <= touch + 1'b1;
						
						s_notice = 2;
						
						plate[r][7] = 1'b1;
						
						plate[r1][7] = 1'b1;
						
						plate[r2][7] = 1'b1;
						a = 8;
						b = 8;
						c = 8;
						
					end
///////////////////
			if((s_notice < 3) && (s_notice != s_noticed_times) && (beep == 0) && (notice == 1))
				begin
					s_noticed_times ++ ;
					notice = 0;
				end
			if (beep == 1)
				begin
					notice = 1;
				end
					
			if((s_notice == s_noticed_times) && (s_noticed_times != 0))
				begin
					s_notice = 0;
					s_noticed_times = 0;
				end
///////////////////				
			end
			//game over ---> GG
			//更改
		else
			begin
				plate[0] = 8'b11111111;//直 0亮 1暗 
				plate[1] = 8'b10111001;//下->上
				plate[2] = 8'b11011001;
				plate[3] = 8'b11011111;
				plate[4] = 8'b11011111;
				plate[5] = 8'b11011001;
				plate[6] = 8'b10111001;
				plate[7] = 8'b11111111;
				s_notice = 3;
			end
			

	end
	
endmodule


//秒數轉7段顯示器
module segment7(input [0:3] a, output A,B,C,D,E,F,G);


	
	assign A = ~(a[0]&~a[1]&~a[2] | ~a[0]&a[2] | ~a[1]&~a[2]&~a[3] | ~a[0]&a[1]&a[3]),
	       B = ~(~a[0]&~a[1] | ~a[1]&~a[2] | ~a[0]&~a[2]&~a[3] | ~a[0]&a[2]&a[3]),
			 C = ~(~a[0]&a[1] | ~a[1]&~a[2] | ~a[0]&a[3]),
			 D = ~(a[0]&~a[1]&~a[2] | ~a[0]&~a[1]&a[2] | ~a[0]&a[2]&~a[3] | ~a[0]&a[1]&~a[2]&a[3] | ~a[1]&~a[2]&~a[3]),
			 E = ~(~a[1]&~a[2]&~a[3] | ~a[0]&a[2]&~a[3]),
			 F = ~(~a[0]&a[1]&~a[2] | ~a[0]&a[1]&~a[3] | a[0]&~a[1]&~a[2] | ~a[1]&~a[2]&~a[3]),
			 G = ~(a[0]&~a[1]&~a[2] | ~a[0]&~a[1]&a[2] | ~a[0]&a[1]&~a[2] | ~a[0]&a[2]&~a[3]);
			 
endmodule


		
//視覺暫留除頻器
module divfreq(input CLK, output reg CLK_div);
  reg [24:0] Count;
  always @(posedge CLK)
    begin
      if(Count > 5000)
        begin
          Count <= 25'b0;
          CLK_div <= ~CLK_div;
        end
      else
        Count <= Count + 1'b1;
    end
endmodule

//計時除頻器
module divfreq1(input CLK, output reg CLK_time);
  reg [25:0] Count;
/*  initial
    begin
      CLK_time = 0;
	 end	
*/		
  always @(posedge CLK)
    begin
      if(Count > 25000000)
        begin
          Count <= 25'b0;
          CLK_time <= ~CLK_time;
        end
      else
        Count <= Count + 1'b1;
    end
endmodule 


//掉落物&人物移動除頻器
module divfreq2(input CLK, output reg CLK_mv);
  reg [35:0] Count;
  initial
    begin
      CLK_mv = 0;
	 end	
		
  always @(posedge CLK)
    begin
      if(Count > 3500000)
        begin
          Count <= 35'b0;
          CLK_mv <= ~CLK_mv;
        end
      else
        Count <= Count + 1'b1;
    end
endmodule 

//提示音效的除頻器
module divfreq3(input CLK, output reg CLK_halfsec);
  reg [24:0] Count = 25'b0;
/*	initial
    begin
      CLK_halfsec = 0;
	 end	
*/		
  always @(posedge CLK)
    begin
//      if(Count > 95419)
		  if (Count > 6250000)
        begin
          Count <= 25'b0;
          CLK_halfsec <= ~CLK_halfsec;
        end
     else
        Count <= Count + 1'b1;
    end
endmodule 
