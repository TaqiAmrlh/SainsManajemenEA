#include <Trade/Trade.mqh>

input double Lots = 0.1;

input ENUM_TIMEFRAMES Timeframe = PERIOD_H1;
input int Periods = 100;
input ENUM_MA_METHOD MaMethod = MODE_SMA;

int maHandle;
int barsTotal;
int maDirection;

CTrade trade;

int OnInit(){
   maHandle = iMA(_Symbol,Timeframe,Periods,0,MaMethod,PRICE_CLOSE);
   barsTotal = iBars(_Symbol,Timeframe);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick(){
   int bars = iBars(_Symbol,Timeframe);
   if(barsTotal < bars){
      barsTotal = bars;
      
      double ma[];
      CopyBuffer(maHandle,MAIN_LINE,1,2,ma);

      if(ma[1] > ma[0] && maDirection <= 0){
         maDirection = 1;
         
         trade.PositionClose(_Symbol);
         trade.Buy(Lots);
      }else if(ma[1] < ma[0] && maDirection >= 0){
         maDirection = -1;
         
         trade.PositionClose(_Symbol);
         trade.Sell(Lots);
      }
      
      Comment("\nMa Direction: ",maDirection,
              "\nma[0]: ",DoubleToString(ma[0],_Digits),
              "\nma[1]: ",DoubleToString(ma[1],_Digits));
   }
}