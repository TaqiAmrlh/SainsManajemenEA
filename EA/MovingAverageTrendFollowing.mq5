#include <Trade/Trade.mqh>

input double TriggerPercent = 1;
input double Lots = 0.1;
input double TpPercent = 1;
input double SlPercent = 1;

input ENUM_TIMEFRAMES MaTimeframe = PERIOD_H1;
input int MaPeriods = 200;
input ENUM_MA_METHOD MaMethod = MODE_SMA;
input ENUM_APPLIED_PRICE MaAppPrice = PRICE_CLOSE;

CTrade trade;
int handleMa;
datetime maDirChange;
double lastTrigger;

int OnInit()
{
   handleMa = iMA(
      _Symbol,
      MaTimeframe,
      MaPeriods,
      0,
      MaMethod,
      MaAppPrice
   );

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
   datetime time0 = iTime(_Symbol, PERIOD_M1, 0);
   static datetime timestamp = time0;

   if(timestamp != time0)
   {
      timestamp = time0;

      double ma[];
      CopyBuffer(handleMa, MAIN_LINE, 1, 3, ma);
      ArraySetAsSeries(ma, true);

      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

      // UP TREND
      if(ma[0] > ma[1])
      {
         if(ma[1] < ma[2])
         {
            maDirChange = time0;
            lastTrigger = 0;
         }

         int indexChange =
            iBarShift(_Symbol, MaTimeframe, maDirChange);

         int highest =
            iHighest(
               _Symbol,
               MaTimeframe,
               MODE_HIGH,
               indexChange + 1
            );

         double high =
            iHigh(_Symbol, MaTimeframe, highest);

         if(
            maDirChange > 0 &&
            highest > 0 &&
            high > lastTrigger &&
            bid < high - high * TriggerPercent / 100
         )
         {
            double tp = ask + ask * TpPercent / 100;
            double sl = ask - ask * SlPercent / 100;

            trade.Buy(
               Lots,
               _Symbol,
               ask,
               sl,
               tp
            );

            lastTrigger = high;
         }
      }

      // DOWN TREND
      else if(ma[0] < ma[1])
      {
         if(ma[1] > ma[2])
         {
            maDirChange = time0;
            lastTrigger = INT_MAX;
         }

         int indexChange =
            iBarShift(_Symbol, MaTimeframe, maDirChange);

         int lowest =
            iLowest(
               _Symbol,
               MaTimeframe,
               MODE_LOW,
               indexChange + 1
            );

         double low =
            iLow(_Symbol, MaTimeframe, lowest);

         if(
            maDirChange > 0 &&
            lowest > 0 &&
            low < lastTrigger &&
            bid > low + low * TriggerPercent / 100
         )
         {
            double tp = bid - bid * TpPercent / 100;
            double sl = bid + bid * SlPercent / 100;

            trade.Sell(
               Lots,
               _Symbol,
               ask,
               sl,
               tp
            );

            lastTrigger = low;
         }
      }

      Comment(
         "\nDirection Change: ",
         maDirChange
      );
   }
}