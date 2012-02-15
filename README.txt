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
	
	1) It expands the class Time so every instance of the Time-Object will have the following methods:

		is_holiday?
			- If no region is defined it returns true if the Time-Object represents a day
	  		  that is a holiday throughout Germany
			- If regions (states) are defined it returns true if the Time-Object
	  		  represents a day that is a holiday in at least one of these states
			- If holiday_value is defined it returns its value ignoring all the other factors
	    
	    holiday_value=(boolean)
	    	- Manually sets a day as a holiday (or no holiday)

	    holiday_value
	    	- Returns the value of holiday_value 
	    
	    regions=(regions)
	    	- Defines the regions for this object. regions can be an array or a single region
	    	  (see: add_region)
	    
	    add_region(region)
	    	- Adds a region
	    	- Use a symbol or a string to define a region. The object will f.e. respond to bayern?
	    	  if region is set to bayern. Correct notation of the German states is mandatory for
	    	  automatic recognition!
	    	  Right: "Baden-Wuerttemberg", "BADEN_WUERTTEMBERG", :baden_wuerttemberg, :BADEN_WUERTTEMBERG
	    	  Wrong: "Baden-Württemberg", :badenwuerttemberg, "BW"

	    regions
	    	- Returns the defined regions. By default this will be an empty array.
	    
	    clear_regions
	    	- Sets regions to an emty array

	    configure
	    	- Makes it more readable to configure the object.
	    	- Use like:
	    		obj.configure do |config|
					config.regions = %w{Brandenburg Thueringen Sachsen Sachsen-Anhalt Mecklenburg-Vorpommern}
				end

	    easter_sunday(year)
	    	- Returns the date of easter sunday for a given year

	    penance_day(year)
	    	- Returns the date of penance day for a given year


	2) Defines a Module holiday.
	   A class that does mixin holiday should have a method "date" that returns a Time-Object.
	   If not -> is_holiday? will raise a DateNotImplementedError

		is_holiday?
			- It delegates is_holiday to the Object returned by "date"
			- If holiday_value is defined it returns its value ignoring the date-object
	    
	    holiday_value=(boolean)
	    	- Manually sets the object to a holiday (or no holiday)

	    holiday_value
	    	- Returns the value of holiday_value 

	    configure
	    	- Makes it more readable to configure the object.
	    	- Use like:
	    		obj.configure do |config|
					config.date.regions = %w{Brandenburg Thueringen Sachsen Sachsen-Anhalt Mecklenburg-Vorpommern}
				end


Have fun!