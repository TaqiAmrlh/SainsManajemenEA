#include <Trade/Trade.mqh>

input double RiskMoney = 50;

input int RangeStartHour = 3;
input int RangeStartMin = 0;
input int RangeEndHour = 6;
input int RangeEndMin = 0;
input int TradingEndHour = 18;
input int TradingEndMin = 0;

input int Magic = 123;

datetime rangeTimeStart;
datetime rangeTimeEnd;
datetime tradingTimeEnd;

double rangeHigh;
double rangeLow;

CTrade trade;
bool isTrade;

int OnInit(){

   trade.SetExpertMagicNumber(Magic);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick(){

   calcTimes();
   calcRange();

   if(TimeCurrent() > rangeTimeEnd && TimeCurrent() < tradingTimeEnd){

      double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);

      if(!isTrade){

         if(rangeHigh > 0 && rangeLow > 0){

            if(bid > rangeHigh){

               double lots = calcLots();

               trade.Buy(lots,_Symbol,0,rangeLow);
               isTrade = true;

            }else if(bid < rangeLow){

               double lots = calcLots();

               trade.Sell(lots,_Symbol,0,rangeHigh);
               isTrade = true;
            }
         }

      }

   }else if(TimeCurrent() >= tradingTimeEnd){

      for(int i = PositionsTotal()-1; i >= 0; i--){

         CPositionInfo pos;

         if(pos.SelectByIndex(i)){

            if(pos.Magic() == Magic){
               trade.PositionClose(pos.Ticket());
            }
         }
      }
   }
}

void calcTimes(){

   MqlDateTime dt;
   TimeCurrent(dt);

   dt.sec = 0;

   dt.hour = RangeStartHour;
   dt.min = RangeStartMin;

   if(rangeTimeStart != StructToTime(dt)){
      isTrade = false;
      rangeHigh = 0;
      rangeLow = 0;
   }

   rangeTimeStart = StructToTime(dt);

   dt.hour = RangeEndHour;
   dt.min = RangeEndMin;

   rangeTimeEnd = StructToTime(dt);

   dt.hour = TradingEndHour;
   dt.min = TradingEndMin;

   tradingTimeEnd = StructToTime(dt);
}

void calcRange(){

   double highs[];
   CopyHigh(_Symbol,PERIOD_M1,rangeTimeStart,rangeTimeEnd,highs);

   double lows[];
   CopyLow(_Symbol,PERIOD_M1,rangeTimeStart,rangeTimeEnd,lows);

   if(ArraySize(highs) < 1 || ArraySize(lows) < 1) return;

   int indexHighest = ArrayMaximum(highs);
   int indexLowest = ArrayMinimum(lows);

   rangeHigh = highs[indexHighest];
   rangeLow = lows[indexLowest];

   string objName = "Range "+TimeToString(rangeTimeStart,TIME_DATE);

   if(ObjectFind(0,objName) < 0){

      ObjectCreate(
         0,
         objName,
         OBJ_RECTANGLE,
         0,
         rangeTimeStart,
         rangeLow,
         rangeTimeEnd,
         rangeHigh
      );

      ObjectSetInteger(0,objName,OBJPROP_FILL,true);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clrYellow);

   }else{

      ObjectSetDouble(0,objName,OBJPROP_PRICE,0,rangeLow);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,1,rangeHigh);
   }
}

double calcLots(){

   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickvalue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);

   double rangeSize = rangeHigh - rangeLow;
   double riskPerLot = rangeSize / ticksize * tickvalue;
   double lots = RiskMoney / riskPerLot;

   lots = NormalizeDouble(lots,2);

   return lots;
}