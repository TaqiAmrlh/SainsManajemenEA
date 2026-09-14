int OnInit(){

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}

void OnTick(){

   if(isNewsEventAhead()){
      Print("News event is ahead...!");
   }
}

bool isNewsEventAhead(){

   MqlCalendarValue values[];

   datetime startTime = iTime(_Symbol,PERIOD_D1,0);
   datetime endTime = startTime + PeriodSeconds(PERIOD_D1);

   CalendarValueHistory(values,startTime,endTime,NULL,NULL);

   for(int i = 0; i < ArraySize(values); i++){

      MqlCalendarEvent event;
      CalendarEventById(values[i].event_id,event);

      MqlCalendarCountry country;
      CalendarCountryById(event.country_id,country);

      if(StringFind(_Symbol,country.currency) < 0) continue;
      if(event.importance == CALENDAR_IMPORTANCE_NONE) continue;
      if(event.importance == CALENDAR_IMPORTANCE_LOW) continue;

      if(TimeCurrent() >= values[i].time-15*PeriodSeconds(PERIOD_M1) &&
         TimeCurrent() < values[i].time+15*PeriodSeconds(PERIOD_M1)){

         Print(event.name," is ahead or was just published! Stop trading...");
         return true;
      }
   }

   return false;
}