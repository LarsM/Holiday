class DateNotImplementedError < StandardError

	def message
    	%{You have to implement a #date method to use delegation of holiday check.}
  	end
end


# Module that represents a holiday
# It's possible to manually set the holiday (see: holiday_name=).
# If holiday_name is nil (by default) it delegates the methods is_holiday? and holiday_name
# to an object that is returned by calling a "date" method 
module Holiday
	extend self

	def is_holiday?
		return !(@holiday_name.empty?) unless @holiday_name.nil?
		_intern_is_holiday?
	end 


	def holiday_name
		return @holiday_name unless @holiday_name.nil?
		_intern_holiday_name
	end

	def holiday_name=(name)
		if name.respond_to?(:to_s)
			@holiday_name = name.to_s
		else
			@holiday_name = nil
		end
	end


	# Call like:
	# Holiday.configure do |config|
	#    config.holiday_value = true
	# end
	def configure
		yield(self) if block_given?
	end


	private
	
	def _intern_is_holiday?
	    raise DateNotImplementedError.new unless self.respond_to?(:date)
   		self.send(:date).is_holiday?
	end

	def _intern_holiday_name
	    raise DateNotImplementedError.new unless self.respond_to?(:date)
   		self.send(:date).holiday_name
	end
end



# Objects of classes that include this module will be able to define regions they
# "belong" to (f.e. "worldwide", :germany, :sachsen, "Australia").
#
# Adding a region will convert it to a symbol with all lowercase letters. Whitespaces
# will be ignored and '-' will be replaced by '_'
#
# Once a region is added (f.e. :germany) objects will respond to "germany?".
# This is done by overwriting the method 'method_missing'
module Regionable
	extend self

	def clear_regions
		@regions = []
	end


	def regions
		@regions ||= []
	end

	# Call like regions = :worldwide or regions = ["Sachsen", "Bayern", ...] 	
	def regions=(regions)
		clear_regions

		if regions.respond_to? :each
			regions.each { |region| add_region(region) } # an array of regions	
		else
			add_region(regions)							 # only 1 region
		end
	end

	#Adds a region by converting it to a symbol (see: region_to_sym)
	def add_region(region)
		regions.push(region_to_sym(region)).uniq!
	end


	# Adds the possibility to use methods like .bayern?
	# (if a region called "bayern" or "BAYERN" or :bayern or :BAYERN was added)
	# without implementing every single one of it 
	def method_missing(meth_name,*args,&block)
		super if self.respond_to?(meth_name) or [:to_ary, :to_str].include?(meth_name)
		method = meth_name.to_s
		method = method.chop if method.split("").last.eql?("?")
		
		regions.include?(region_to_sym(method))
	end


	private

	#Converts a region to a symbol by
	# => converting it to a string,
	# => removing leading and trailing whitespaces
	# => all lowercase letters
	# => replace all "-" with "_" 
	def region_to_sym(region)
		region.to_s.strip.downcase.gsub("-","_").to_sym
	end
end



# Class Time is expanded to automatically identify German holidays.
#
# It overwrites private method _intern_is_holiday? of module Holiday.
# It's still possible to set a day as a holiday manually
# (or set a holiday as no holiday) by using holiday_name="something"
#
# To identify holidays by states (bundesländer) it includes Regionable.
# is_holiday? returns false for holidays that are only holidays
# in some communities (Gemeinden).
#
# If there are more than one region defined (f.e. [:sachsen, :bayern])
# is_holiday? returns true if the day is a holiday in at least one
# of these region.
class Time
	include Holiday, Regionable


	#Adds some number of days (possibly negative) to time and returns that value as a new time.
	def roll_days (number_of_days)
		raise "Wrong number_of_days type" unless number_of_days.is_a?(Fixnum)
		self + number_of_days * 24 * 60 * 60 # days in seconds
	end


	# Returns the date of easter sunday of a given year
	# Formula created by Carl Friedrich Gauß (1777-1855)
	def self.easter_sunday (year)
		# Copied from http://www.igelnet.de/Dateien/xlostern.htm
		# -----------------------------------------------------------------------
		# Ostern fällt im Jahre J auf den (D + e + 1)sten Tag nach dem 21. März: 
		# a = Rest von J / 19 
		# b = Rest von J / 4 
		# c = Rest von J / 7 
		# m = ganze Zahl von (8 * ganze Zahl von (J / 100) + 13) / 25 - 2 
		# s = ganze Zahl von (J / 100 ) - ganze Zahl von (J / 400) - 2 
		# M = Rest von (15 + s - m) / 30 
		# N = Rest von (6 + s) / 7 
		# d = Rest von (M + 19 * a) / 30 
		# D = 28 falls d = 29 oder 
		# D = 27 falls d = 28 und a größer/gleich 11 oder 
		# D = d für alle anderen Fälle 
		# e = Rest von (2 * b + 4 * c + 6 * D + N) / 7 

		# Ostern = 21. März + (D + e + 1)

		a = year % 19
		b = year % 4
		c = year % 7
		m = (8 * (year / 100) + 13) / 25 - 2
		s = year / 100 - year / 400 - 2
		mm = (15 + s - m) % 30
		nn = (6 + s) % 7
		d = (mm + 19 * a) % 30

		if d == 29
			dd = 28
		elsif d == 28 && a >= 11
			dd = 27
		else
			dd = d
		end

		e = (2 * b + 4 * c + 6 * dd + nn) % 7

		Time.local(year, 3, 21).roll_days(dd + e + 1)
	end


	# Returns the date of Penance Day (Buß- und Bettag)
	def self.penance_day (year)
		dec25 = Time.local(year, 12, 25)

		return dec25.roll_days(-7 - 32) if dec25.wday == 0 # Dec. 25th is a sunday
		return dec25.roll_days(-dec25.wday - 32)
	end


	private


	# Check if the date is a holiday
	def _intern_is_holiday?

		# Neujahr (1.1. bundesweit)
		if day == 1 && month == 1 
			@_intern_holiday_name = "new_years_day"
			return true
		end

		# Heilige Drei Könige (6.1. nur Baden-Württemberg, Bayern, Sachsen-Anhalt)
		if day == 6 && month == 1 && (baden_wuerttemberg? || bayern? || sachsen_anhalt?) 
			@_intern_holiday_name = "twelfth_day"
			return true
		end

		# Karfreitag (bewegl. bundesweit)
		hday = Time.easter_sunday(year).roll_days(-2)
		if day == hday.day && month == hday.month
			@_intern_holiday_name = "good_friday"
			return true
		end

		# Ostersonntag (bewegl. bundesweit)
		#hday = Time.easter_sunday(year)
		#if day == hday.day && month == hday.month
		#	@_intern_holiday_name = "easter_sunday"
		#	return true
		#end

		# Ostermontag (bewegl. bundesweit)
		hday = Time.easter_sunday(year).roll_days(1)
		if day == hday.day && month == hday.month
			@_intern_holiday_name = "easter_monday"
			return true
		end

		# Maifeiertag (1.5. bundesweit)
		if day == 1 && month == 5 
			@_intern_holiday_name = "may_first"
			return true
		end

		# Christi Himmelfahrt (bewegl. bundesweit)
		hday = Time.easter_sunday(year).roll_days(39)
		if day == hday.day && month == hday.month
			@_intern_holiday_name = "ascension_day"
			return true
		end

		# Pfingstmontag (bewegl. bundesweit)
		hday = Time.easter_sunday(year).roll_days(50)
		if day == hday.day && month == hday.month
			@_intern_holiday_name = "whit_monday"
			return true
		end

		# Fronleichnam (bewgl. nur Baden-Württemberg, Bayern, Hessen, Nordrhein-Westfalen, Rheinland-Pfalz, Saarland)
		hday = Time.easter_sunday(year).roll_days(60)
		if day == hday.day && month == hday.month && (	baden_wuerttemberg? || bayern? || hessen? || nordrhein_westfalen? || rheinland_pfalz? || saarland? )
			@_intern_holiday_name = "corpus_christi"
			return true
		end

		# Mariä Himmelfahrt (15.8. nur Saarland)
		if day == 15 && month == 8 && saarland?
			@_intern_holiday_name = "assumption_day"
			return true
		end

		# Tag der deutschen Einheit (3.10. bundesweit)
		if day == 3 && month == 10 
			@_intern_holiday_name = "german_unification_day"
			return true
		end

		# Reformationstag (31.10. nur Brandenburg, Mecklenburg-Vorpommern, Sachsen, Sachsen-Anhalt, Thüringen)
		if day == 31 && month == 10 && (brandenburg? || mecklenburg_vorpommern? || sachsen? || sachsen_anhalt? || thueringen?)
			@_intern_holiday_name = "reformation_day"
			return true
		end

		# Allerheiligen (1.11. nur Baden-Württemberg, Bayern, Nordrhein-Westfalen, Rheinland-Pfalz, Saarland)
		if day == 1 && month == 11 && ( baden_wuerttemberg? || bayern? || nordrhein_westfalen? || rheinland_pfalz? || saarland? )
			@_intern_holiday_name = "all_saints_day"
			return true
		end

		# Buß- und Bettag (bewgl. nur Sachsen)
		hday = Time.penance_day(year)
		if day == hday.day && month == hday.month && sachsen?
			@_intern_holiday_name = "penance_day"
			return true
		end

		# 1. Weihnachtsfeiertag (25.12. bundesweit)
		if day == 25 && month == 12 
			@_intern_holiday_name = "christmas_day"
			return true
		end

		# 2. Weihnachstfeiertag (26.12. bundesweit)
		if day == 26 && month == 12
			@_intern_holiday_name = "boxing_day"
			return true
		end

		# No holiday
		@_intern_holiday_name = ""
		return false
	end


	def _intern_holiday_name
		_intern_is_holiday?
		@_intern_holiday_name
	end
end
