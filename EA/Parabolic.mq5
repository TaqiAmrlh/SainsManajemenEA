#include <Trade/Trade.mqh>

input double Lots = 0.1;

input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;
input double Step = 0.01;
input double Maximum = 0.2;

input int Magic = 111;

int parabolicSarHandle;
int barsTotal;

CTrade trade;

int OnInit(){
   parabolicSarHandle = iSAR(_Symbol,Timeframe,Step,Maximum);
   barsTotal = iBars(_Symbol,Timeframe);
   
   trade.SetExpertMagicNumber(Magic);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick(){
   double val[];  
   CopyBuffer(parabolicSarHandle,0,0,2,val);
   
   int bars = iBars(_Symbol,Timeframe);
   if(barsTotal != bars){
      double close0 = iClose(_Symbol,Timeframe,0);
      double close1 = iClose(_Symbol,Timeframe,1);
       
      if(close0 > val[1] && close1 < val[0]){
         Print(__FUNCTION__," > Buy signal...");
         
         trade.Buy(Lots,_Symbol,0,0,0,"SAR BUY");

         barsTotal = bars;
      }else if(close0 < val[1] && close1 > val[0]){
         Print(__FUNCTION__," > Sell signal...");

         trade.Sell(Lots,_Symbol,0,0,0,"SAR BUY");
      
         barsTotal = bars;
      }
      
      Comment("\nParabolic SAR[0]: ",DoubleToString(val[0],_Digits),
              "\nParabolic SAR[1]: ",DoubleToString(val[1],_Digits));
   }
   
   double sl = val[1];
   sl = NormalizeDouble(sl,_Digits);
   for(int i = PositionsTotal()-1; i >= 0; i--){
      ulong posTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket)){
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic){
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);     
            double posSl = PositionGetDouble(POSITION_SL);
            double posTp = PositionGetDouble(POSITION_TP);
            
            if(posType == POSITION_TYPE_BUY){
               if(sl > posSl || posSl == 0){
                  if(trade.PositionModify(posTicket,sl,posTp)){
                     Print(__FUNCTION__," > Pos #",posTicket," was modified by tsl...");
                  }
               }
            }else if(posType == POSITION_TYPE_SELL){
               if(sl < posSl || posSl == 0){
                  if(trade.PositionModify(posTicket,sl,posTp)){
                     Print(__FUNCTION__," > Pos #",posTicket," was modified by tsl...");
                  }
               }          
            }
         }
      }
   }
}