#include <Trade/Trade.mqh>

input double Lots = 0.1;
input double TpPercent = 0.5;
input double SlPercent = 0.5;

input ENUM_TIMEFRAMES Timeframe = PERIOD_H1;
input int Periods = 100;
input ENUM_MA_METHOD MaMethod = MODE_SMA;

input int BbPeriods = 20;
input double BbDeviation = 2.0;
input double BbMinSize = 0.5;

int maHandle;
int bbHandle;

int barsTotal;
int maDirection;

CTrade trade;

int OnInit(){
   maHandle = iMA(_Symbol,Timeframe,Periods,0,MaMethod,PRICE_CLOSE);
   bbHandle = iBands(_Symbol,Timeframe,BbPeriods,0,BbDeviation,PRICE_CLOSE);
   
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
      
      double bbUpper[], bbLower[];
      CopyBuffer(bbHandle,UPPER_BAND,1,1,bbUpper);
      CopyBuffer(bbHandle,LOWER_BAND,1,1,bbLower);
      bool isBbMinDistance = bbUpper[0] - bbLower[0] > SymbolInfoDouble(_Symbol,SYMBOL_BID) * BbMinSize / 100;

      if(ma[1] > ma[0] && maDirection <= 0){
         maDirection = 1;
         
         trade.PositionClose(_Symbol);
         
         if(isBbMinDistance) executeBuy();
      }else if(ma[1] < ma[0] && maDirection >= 0){
         maDirection = -1;
         
         trade.PositionClose(_Symbol);

         if(isBbMinDistance) executeSell();
      }
      
      Comment("\nMa Direction: ",maDirection,
              "\nma[0]: ",DoubleToString(ma[0],_Digits),
              "\nma[1]: ",DoubleToString(ma[1],_Digits),
              "\n\nBB Filter: ",isBbMinDistance,
              "\nbbUpper: ",DoubleToString(bbUpper[0],_Digits),
              "\nBBLower: ",DoubleToString(bbLower[0],_Digits));
   }
}

void executeBuy(){
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   
   double entry = NormalizeDouble(ask,_Digits);
   
   double tp = 0;
   if(TpPercent > 0) tp = entry + ask * TpPercent / 100;
   tp = NormalizeDouble(tp,_Digits);
   
   double sl = 0;
   if(SlPercent > 0) sl = entry - ask * SlPercent / 100;
   sl = NormalizeDouble(sl,_Digits);
   
   trade.Buy(Lots,_Symbol,entry,sl,tp);
}

void executeSell(){
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   
   double entry = NormalizeDouble(bid,_Digits);
   
   double tp = 0;
   if(TpPercent > 0) tp = entry - bid * TpPercent / 100;
   tp = NormalizeDouble(tp,_Digits);
   
   double sl = 0;
   if(SlPercent > 0) sl = entry + bid * SlPercent / 100;
   sl = NormalizeDouble(sl,_Digits);

   trade.Sell(Lots,_Symbol,entry,sl,tp);
}