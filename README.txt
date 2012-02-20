***********
* HOLIDAY *
***********


Description
-----------

Holiday is a tool to easily find out if a day is a holiday.
Right now it supplies automatic recognition for Germany and German states. 


Usage
-----
To use Holiday include holidy.rb into your projects.

There are two different ways to use holiday:
  
  1) It expands the class Time so every instance of the Time-Object will have the
     following methods:

    is_holiday?
      - If no region is defined it returns true if the Time-Object represents a date
        that is a holiday throughout Germany
      - If regions (states) are defined it returns true if the Time-Object
        represents a day that is a holiday in at least one of these states
      - If holiday_name was set to an empty string it returns false ignoring all the
        other factors
      - If holiday_name was set to a non empty string it returns true ignoring all
        the other factors
    
    holiday_name
      - If holiday_name is set by the user (not nil) it returns its value ignoring
        all the other factors
      - Otherwise it returns one of the following names if the date is a holiday
          * "new_years_day" (Neujahrstag)
          * "twelfth_day" (Heilige Drei Koenige)
          * "good_friday" (Karfreitag)
          * "easter_monday" (Ostermontag)
          * "may_first" (Maifeiertag)
          * "ascension_day" (Christi Himmelfahrt)
          * "whit_monday" (Pfingstmontag)
          * "corpus_christi" (Fronleichnam)
          * "assumption_day" (Mariae Himmelfahrt)
          * "german_unification_day" (Tag der deutschen Einheit)
          * "reformation_day" (Reformationstag)
          * "all_saints_day" (Allerheiligen)
          * "penance_day" (Buss- und Bettag)
          * "christmas_day" (1. Weihnachtsfeiertag)
          * "boxing_day" (2. Weihnachtsfeiertag)
     
    regions=(regions)
      - Defines the regions for this object. regions can be an array or a single
        region (see: add_region)
      
    add_region(region)
      - Adds a region
      - Use a symbol or a string to define a region. The object will f.e. respond
        to bayern? if region is set to bayern. Correct notation of the German
        states is mandatory for automatic recognition!
        Right: "Baden-Wuerttemberg", "BADEN_WUERTTEMBERG",
               :baden_wuerttemberg, :BADEN_WUERTTEMBERG
        Wrong: "Baden-Württemberg", :badenwuerttemberg, "BW"

    regions
      - Returns the defined regions. By default this will be an empty array.
      
    clear_regions
      - Sets regions to an emty array

    configure
      - Makes it more readable to configure the object.
      - Use like:
          obj.configure do |config|
            config.regions = 
            %w{Brandenburg Thueringen Sachsen Sachsen-Anhalt Mecklenburg-Vorpommern}
          end

    easter_sunday(year)
      - Returns the date of easter sunday for a given year

    penance_day(year)
      - Returns the date of penance day for a given year


  2) Defines a Module holiday.
     A class that does mixin holiday should have a method "date" that returns
     a Time-Object. If not: is_holiday? and holiday_name will raise a
     DateNotImplementedError if holiday_name is not set by the user (=nil)  

    is_holiday?
      - By default it delegates is_holiday to the object returned by "date"
      - If holiday_name was set to an empty string it returns false
      - If holiday_name was set to a non empty string it returns true
      
    holiday_name
      - By default it delegates holiday_name to the object returned by "date"
      - If holiday_name was defined by holiday_name= (not nil) it returns
        its value ignoring the date-object


    holiday_name=
      - Manually sets the name for the holiday
      - Possible values:
          * Nil - By default, is_holiday? will delegate to date-object
          * "" - is_holiday? will return false
          * "Some string" - is_holiday? will return true

    configure
      - Makes it more readable to configure the object.
      - Use like:
          obj.configure do |config|
            config.date.regions = %w{Brandenburg Thueringen Sachsen Sachsen-Anhalt Mecklenburg-Vorpommern}
          end


Have fun!