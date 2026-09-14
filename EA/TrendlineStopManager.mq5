#include <Trade/Trade.mqh>

input string LineName = "Line";

CTrade trade;

void OnTick(){

   if(ObjectFind(0,LineName) == 0){
      datetime time = TimeCurrent();
      double objPrice = ObjectGetValueByTime(0,LineName,time);
      objPrice = NormalizeDouble(objPrice,_Digits);

      double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);

      for(int i = PositionsTotal()-1; i >= 0; i--){
         ulong posTicket = PositionGetTicket(i);

         if(PositionSelectByTicket(posTicket)){
            double posSl = PositionGetDouble(POSITION_SL);
            double posTp = PositionGetDouble(POSITION_TP);

            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
               if(objPrice < bid){
                  if(objPrice > posSl){
                     if(trade.PositionModify(posTicket,objPrice,posTp)){
                        Print(__FUNCTION__," > Modified sl for pos #",posTicket,"...");
                     }
                  }
               }
            }else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
               if(objPrice > ask){
                  if(objPrice < posSl || posSl == 0){
                     if(trade.PositionModify(posTicket,objPrice,posTp)){
                        Print(__FUNCTION__," > Modified sl for pos #",posTicket,"...");
                     }
                  }
               }
            }
         }
      }
   }
}