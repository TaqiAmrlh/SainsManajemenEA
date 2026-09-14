#include <Trade/Trade.mqh>

int handleAlligator;
int barsTotal;

CTrade trade;

int OnInit(){
   handleAlligator = iAlligator(_Symbol,PERIOD_CURRENT,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN);

   barsTotal = iBars(_Symbol,PERIOD_CURRENT);

   OnTick();

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick(){
   int bars = iBars(_Symbol,PERIOD_CURRENT);
   if(barsTotal < bars){
      barsTotal = bars;

      double jaws[];
      CopyBuffer(handleAlligator,GATORJAW_LINE,1,2,jaws);

      double teeth[];
      CopyBuffer(handleAlligator,GATORTEETH_LINE,1,2,teeth);

      double lips[];
      CopyBuffer(handleAlligator,GATORLIPS_LINE,1,2,lips);

      if(lips[1] > teeth[1] && lips[0] < teeth[0]){
         Print(__FUNCTION__, " > Alligator buy signal.");

         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         ask = NormalizeDouble(ask,_Digits);

         if(ask > jaws[1]){
            double tp = ask + 150 * _Point;
            tp = NormalizeDouble(tp,_Digits);

            double sl = ask - 50 * _Point;
            sl = NormalizeDouble(sl,_Digits);

            trade.Buy(0.1,_Symbol,ask,sl,tp,"Alligator Buy");
         }
      }

      if(lips[1] < teeth[1] && lips[0] > teeth[0]){
         Print(__FUNCTION__, " > Alligator sell signal.");

         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         bid = NormalizeDouble(bid,_Digits);

         if(bid < jaws[1]){
            double tp = bid - 150 * _Point;
            tp = NormalizeDouble(tp,_Digits);

            double sl = bid + 50 * _Point;
            sl = NormalizeDouble(sl,_Digits);

            trade.Sell(0.1,_Symbol,bid,sl,tp,"Alligator Sell");
         }
      }

      Comment("\nAlligator Jaw[0]: ",DoubleToString(jaws[0],_Digits),
              " Alligator Jaw[1]: ",DoubleToString(jaws[1],_Digits),
              "\nAlligator Teeth[0]: ",DoubleToString(teeth[0],_Digits),
              " Alligator Teeth[1]: ",DoubleToString(teeth[1],_Digits),
              "\nAlligator Lips[0]: ",DoubleToString(lips[0],_Digits),
              " Alligator Lips[1]: ",DoubleToString(lips[1],_Digits));
   }
}