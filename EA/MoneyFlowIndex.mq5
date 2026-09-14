#include <Trade/Trade.mqh>

input double Lots = 0.1;
input double MfiSellLevel = 80;
input double MfiBuyLevel = 20;
input double TpPercent = 0.5;
input double SlPercent = 1.5;

int handleMfi;
int barsTotal;
bool isTradeAllowed;

int OnInit()
{
   handleMfi = iMFI(_Symbol, PERIOD_CURRENT, 14, VOLUME_TICK);
   barsTotal = iBars(_Symbol, PERIOD_CURRENT);

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
   int bars = iBars(_Symbol, PERIOD_CURRENT);

   if(bars > barsTotal)
   {
      barsTotal = bars;

      double mfi[];
      CopyBuffer(handleMfi, MAIN_LINE, 1, 1, mfi);

      if(mfi[0] < MfiSellLevel && mfi[0] > MfiBuyLevel)
      {
         isTradeAllowed = true;
      }

      if(isTradeAllowed)
      {
         if(mfi[0] >= MfiSellLevel)
         {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            bid = NormalizeDouble(bid, _Digits);

            double tp = bid - bid * TpPercent / 100;
            tp = NormalizeDouble(tp, _Digits);

            double sl = bid + bid * SlPercent / 100;
            sl = NormalizeDouble(sl, _Digits);

            CTrade trade;

            if(trade.Sell(Lots, _Symbol, bid, sl, tp))
            {
               Print(__FUNCTION__,
                     " > New sell signal! Sent order #",
                     trade.ResultOrder(),
                     "...");
               isTradeAllowed = false;
            }
         }
         else if(mfi[0] <= MfiBuyLevel)
         {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            ask = NormalizeDouble(ask, _Digits);

            double tp = ask + ask * TpPercent / 100;
            tp = NormalizeDouble(tp, _Digits);

            double sl = ask - ask * SlPercent / 100;
            sl = NormalizeDouble(sl, _Digits);

            CTrade trade;

            if(trade.Buy(Lots, _Symbol, ask, sl, tp))
            {
               Print(__FUNCTION__,
                     " > New buy signal! Sent order #",
                     trade.ResultOrder(),
                     "...");
               isTradeAllowed = false;
            }
         }
      }

      Comment("\nMFI: ", DoubleToString(mfi[0]));
   }
}