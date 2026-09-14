#include <Trade/Trade.mqh>

// Create an instance of CTrade
CTrade trade;

void OnTick()
{
   // We create a string for the signal
   string signal = "";

   // We calculate the Ask price
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);

   // We calculate the Bid price
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);

   // We create an array for the K-line and D-line
   double KArray[];
   double DArray[];

   // Sort the array from the current candle downwards
   ArraySetAsSeries(KArray, true);
   ArraySetAsSeries(DArray, true);

   // Defined EA, current candle, 3 candles, save the result
   int StochasticDefinition = iStochastic(_Symbol, PERIOD_CURRENT, 5, 3, 3, MODE_SMA, STO_LOWHIGH);

   // We fill the array with price data
   CopyBuffer(StochasticDefinition, 0, 0, 3, KArray);
   CopyBuffer(StochasticDefinition, 1, 0, 3, DArray);

   // We calculate the value for the current candle
   double KValue0 = KArray[0];
   double DValue0 = DArray[0];

   // We calculate the value for the last candle
   double KValue1 = KArray[1];
   double DValue1 = DArray[1];

   // buy signal

   // if both values are below 20
   if (KValue0 < 20 && DValue0 < 20)

      // If the K value has crossed the D value from below
      if ((KValue0 > DValue0) && (KValue1 < DValue1))
      {
         signal = "buy";
      }

   // sell signal

   // if both values are above 80
   if (KValue0 > 80 && DValue0 > 80)

      // If the K value has crossed the D value from above
      if ((KValue0 < DValue0) && (KValue1 > DValue1))
      {
         signal = "sell";
      }

   // Sell 10 Microlot
   if (signal == "sell" && PositionsTotal() < 1)
      trade.Sell(0.10, NULL, Bid, 0, (Bid - 150 * _Point), NULL);

   // Buy 10 Microlot
   if (signal == "buy" && PositionsTotal() < 1)
      trade.Buy(0.10, NULL, Ask, 0, (Ask + 150 * _Point), NULL);

   // Create a chart output
   Comment("The current signal is: ", signal);
}