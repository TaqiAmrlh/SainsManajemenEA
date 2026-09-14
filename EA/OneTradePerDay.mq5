#include <Trade/Trade.mqh>

int totalBars;
ulong posTicket;

CTrade trade;

int OnInit(){
   totalBars = iBars(_Symbol,PERIOD_D1);
   
   return(INIT_SUCCEEDED);
}

void OnTick(){
   int bars = iBars(_Symbol,PERIOD_D1);
   
   if(totalBars < bars){
      Print("Total bars changed to ",bars);
      
      trade.PositionClose(posTicket);
      if(!PositionSelectByTicket(posTicket)){
         double open = iOpen(_Symbol,PERIOD_D1,1);
         double close = iClose(_Symbol,PERIOD_D1,1);
         
         if(open < close){
            Print("last d1 candle is green");
            
            trade.Buy(0.1);
            posTicket = trade.ResultOrder();
            if(posTicket > 0) totalBars = bars;
         }else if(open > close){
            Print("last d1 candle is red");
            
            trade.Sell(0.1);
            posTicket = trade.ResultOrder();
            if(posTicket > 0) totalBars = bars;
         }
      }
   }
}