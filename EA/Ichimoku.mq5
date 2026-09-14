#include <Trade/Trade.mqh>

input double Lots = 0.1;

input int TenkanSen = 9;
input int KijunSen = 26;
input int SenkouSpanB = 52;

input string Commentary = "Comment";
input int Magic = 1;

CTrade trade;

int totalBars;
int handleIchimoku;

int OnInit(){
   totalBars = iBars(_Symbol,PERIOD_CURRENT);

   trade.SetExpertMagicNumber(Magic);

   handleIchimoku = iIchimoku(
      _Symbol,
      PERIOD_CURRENT,
      TenkanSen,
      KijunSen,
      SenkouSpanB
   );

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick(){

   int bars = iBars(_Symbol,PERIOD_CURRENT);

   if(totalBars != bars){
      totalBars = bars;

      double tenkanSen[];
      double kijunSen[];
      double senkouSpanA[];
      double senkouSpanB[];

      CopyBuffer(handleIchimoku,TENKANSEN_LINE,1,2,tenkanSen);
      CopyBuffer(handleIchimoku,KIJUNSEN_LINE,1,2,kijunSen);
      CopyBuffer(handleIchimoku,SENKOUSPANA_LINE,1,1,senkouSpanA);
      CopyBuffer(handleIchimoku,SENKOUSPANB_LINE,1,1,senkouSpanB);

      if(tenkanSen[1] > kijunSen[1] &&
         tenkanSen[0] <= kijunSen[0]){

         Print("Buy Crossover...");

         for(int i = PositionsTotal()-1; i >= 0; i--){

            ulong ticket = PositionGetTicket(i);

            if(PositionSelectByTicket(ticket)){

               if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
                  PositionGetInteger(POSITION_MAGIC) == Magic){

                  if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){

                     if(trade.PositionClose(ticket)){
                        Print("Closed pos #",ticket);
                     }
                  }
               }
            }
         }

         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);

         if(ask > senkouSpanA[0] &&
            ask > senkouSpanB[0]){

            double entry = ask;
            entry = NormalizeDouble(entry,_Digits);

            trade.Buy(
               Lots,
               _Symbol,
               entry,
               0,
               0,
               Commentary
            );
         }

      }else if(tenkanSen[1] < kijunSen[1] &&
               tenkanSen[0] >= kijunSen[0]){

         Print("Sell Crossover...");

         for(int i = PositionsTotal()-1; i >= 0; i--){

            ulong ticket = PositionGetTicket(i);

            if(PositionSelectByTicket(ticket)){

               if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
                  PositionGetInteger(POSITION_MAGIC) == Magic){

                  if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){

                     if(trade.PositionClose(ticket)){
                        Print("Closed pos #",ticket);
                     }
                  }
               }
            }
         }

         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);

         if(bid < senkouSpanA[0] &&
            bid < senkouSpanB[0]){

            double entry = bid;
            entry = NormalizeDouble(entry,_Digits);

            trade.Sell(
               Lots,
               _Symbol,
               entry,
               0,
               0,
               Commentary
            );
         }
      }
   }
}