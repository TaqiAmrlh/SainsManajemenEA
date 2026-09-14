#include <Trade/Trade.mqh>

input double Lots = 0.01;
input int LevelDistancePoints = 100;

CTrade trade;
double baseLevel;

void OnTick()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(baseLevel == 0)
   {
      baseLevel = bid;
   }

   if(bid > baseLevel + LevelDistancePoints * _Point)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong positionTicket = PositionGetTicket(i);

         if(PositionSelectByTicket(positionTicket))
         {
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            {
               trade.PositionClose(positionTicket);
            }
         }
      }

      trade.Buy(Lots);

      baseLevel = bid + LevelDistancePoints * _Point;
   }
   else if(bid < baseLevel - LevelDistancePoints * _Point)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong positionTicket = PositionGetTicket(i);

         if(PositionSelectByTicket(positionTicket))
         {
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            {
               trade.PositionClose(positionTicket);
            }
         }
      }

      trade.Sell(Lots);

      baseLevel = bid - LevelDistancePoints * _Point;
   }

   Comment(baseLevel);
}