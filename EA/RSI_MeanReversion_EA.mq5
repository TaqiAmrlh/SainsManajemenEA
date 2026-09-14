#property copyright "MusfiqTaqi"
#property version   "1.10"

#include <Trade/Trade.mqh>
CTrade trade;

input int              RSI_Period       = 14;
input ENUM_TIMEFRAMES  RSI_Timeframe    = PERIOD_H1;
input double           Buy_Threshold    = 30.0;
input double           Sell_Threshold   = 70.0;

input int              MA_Period        = 50;
input ENUM_MA_METHOD   MA_Method        = MODE_SMA;

input double           Lot_Size         = 0.01;
input double           SL_Percent       = 5.0;
input double           TP_Percent       = 1.0;

input ulong            Magic_Number     = 123456;

int rsiHandle;
int maHandle;

bool buyArmed  = true;
bool sellArmed = true;

//+------------------------------------------------------------------+
int OnInit()
{
   rsiHandle = iRSI(_Symbol, RSI_Timeframe, RSI_Period, PRICE_CLOSE);

   if(rsiHandle == INVALID_HANDLE)
      return INIT_FAILED;

   maHandle = iMA(_Symbol, RSI_Timeframe, MA_Period, 0,
                  MA_Method, PRICE_CLOSE);

   if(maHandle == INVALID_HANDLE)
      return INIT_FAILED;

   trade.SetExpertMagicNumber(Magic_Number);

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(rsiHandle);
   IndicatorRelease(maHandle);
}

//+------------------------------------------------------------------+
bool HasOpenPosition()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);

      if(ticket == 0)
         continue;

      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;

      if((ulong)PositionGetInteger(POSITION_MAGIC) != Magic_Number)
         continue;

      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
void OnTick()
{
   double rsiBuffer[2];
   double maBuffer[1];

   if(CopyBuffer(rsiHandle, 0, 0, 2, rsiBuffer) < 2)
      return;

   if(CopyBuffer(maHandle, 0, 0, 1, maBuffer) < 1)
      return;

   double rsi = rsiBuffer[0];
   double ma  = maBuffer[0];

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   // Reset permission
   if(rsi >= 50.0)
      buyArmed = true;

   if(rsi <= 50.0)
      sellArmed = true;

   if(HasOpenPosition())
      return;

   // BUY
   if(rsi < Buy_Threshold &&
      ask > ma &&
      buyArmed)
   {
      double sl = 0;
      double tp = 0;

      if(SL_Percent > 0)
         sl = ask * (1.0 - SL_Percent / 100.0);

      if(TP_Percent > 0)
         tp = ask * (1.0 + TP_Percent / 100.0);

      if(trade.Buy(Lot_Size, _Symbol, ask, sl, tp, "RSI Buy"))
         buyArmed = false;

      return;
   }

   // SELL
   if(rsi > Sell_Threshold &&
      bid < ma &&
      sellArmed)
   {
      double sl = 0;
      double tp = 0;

      if(SL_Percent > 0)
         sl = bid * (1.0 + SL_Percent / 100.0);

      if(TP_Percent > 0)
         tp = bid * (1.0 - TP_Percent / 100.0);

      if(trade.Sell(Lot_Size, _Symbol, bid, sl, tp, "RSI Sell"))
         sellArmed = false;

      return;
   }
}
//+------------------------------------------------------------------+