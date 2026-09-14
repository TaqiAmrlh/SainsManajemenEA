#include<Trade\Trade.mqh>

// Create an instance of CTrade
CTrade trade;

void OnTick()
{
   // We create a variable for the signal
   string signal = "";

   // We calculate the Ask price
   double Ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);

   // We calculate the Bid price
   double Bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);

   // Create an array for the price data
   double PriceArray[];

   // define the AverageTrueRange EA
   int AverageTrueRangeDefinition=iATR(_Symbol,_Period,14);

   // sort the prices from the current candle downwards
   ArraySetAsSeries(PriceArray,true);

   // Defined EA, Buffer 0, 3 candles, save in array
   CopyBuffer(AverageTrueRangeDefinition,0,0,3,PriceArray);

   // Calculate the current value
   double AverageTrueRangeValue=NormalizeDouble(PriceArray[0],5);

   static double OldValue;

   // Intialisation for the old value
   if(OldValue==0)
   {
      OldValue=AverageTrueRangeValue;
   }

   // buy signal

   // If it is going up
   if(AverageTrueRangeValue>OldValue)
   {
      signal="buy";
   }

   // sell signal

   // if it is going down
   if(AverageTrueRangeValue<OldValue)
   {
      signal="sell";
   }

   // Sell 10 Microlot
   if(signal=="sell" && PositionsTotal()<1)
      trade.Sell(0.10,NULL,Bid,(Bid+200 * _Point),(Bid-150 * _Point),NULL);

   // Buy 10 Microlot
   if(signal=="buy" && PositionsTotal()<1)
      trade.Buy(0.10,NULL,Ask,(Ask-200 * _Point),(Ask+150 * _Point),NULL);

   // Chart output
   Comment("The signal is: ",signal,"\n",OldValue,"\n",AverageTrueRangeValue);

   // Assign current value to old value
   OldValue=AverageTrueRangeValue;
}