require "rubygems"
require "rspec"
require "../lib/holiday.rb"


class HolidayTestClass
	include Holiday

	def initialize (year, month, day, regions=[])
		@date = Time.local(year,month,day)
		@date.regions = regions if regions.size > 0
	end

	def date()
		@date
	end
end

describe Holiday do
	
	it "should have no regions when first created" do
		hday = Time.local(2012,1,1)
		hday.regions.should be_empty
	end

	it "bayern? should be true when region is :bayern" do
		hday = Time.local(2012,1,1)
		hday.regions = :bayern
		hday.bayern?.should be true
	end


	it "sachsen? should be true when region is %w{Brandenburg Thueringen Sachsen Sachsen-Anhalt Mecklenburg-Vorpommern}" do
		hday = Time.local(2012,1,1)
		hday.regions = %w{Brandenburg Thueringen Sachsen Sachsen-Anhalt Mecklenburg-Vorpommern}
		hday.sachsen?.should be true
	end


	# Test different holidays in different years
	it "1.1.2012 should be a holiday" do
		hday = HolidayTestClass.new(1012,1,1)
		hday.is_holiday?.should be true
	end

	it "1.5.2014 should be a holiday" do
		hday = HolidayTestClass.new(2014,5,1)
		hday.is_holiday?.should be true
	end

	it "3.10.2015 should be a holiday" do
		hday = HolidayTestClass.new(2015,10,3)
		hday.is_holiday?.should be true
	end

	it "25.12.2016 should be a holiday" do
		hday = HolidayTestClass.new(2016,12,25)
		hday.is_holiday?.should be true
	end

	it "26.12.2017 should be a holiday" do
		hday = HolidayTestClass.new(2016,12,26)
		hday.is_holiday?.should be true
	end


	it "6.4.2012 should be a holiday (Karfreitag)" do
		hday = HolidayTestClass.new(2012,4,6)
		hday.is_holiday?.should be true
	end

	it "1.4.2013 should be a holiday (Ostermontag)" do
		hday = HolidayTestClass.new(2013,4,1)
		hday.is_holiday?.should be true
	end

	it "29.5.2014 should be a holiday (Christi-Himmelfahrt)" do
		hday = HolidayTestClass.new(2014,5,29)
		hday.is_holiday?.should be true
	end

	it "25.5.2015 should be a holiday (Pfingstmontag)" do
		hday = HolidayTestClass.new(2015,5,25)
		hday.is_holiday?.should be true
	end

	it "6.1.2013 should be a holiday in Baden-Wuerttemberg" do
		hday = HolidayTestClass.new(2013,1,6,"Baden_Wuerttemberg")
		hday.is_holiday?.should be true
	end

	it "15.8.2014 should be a holiday in Saarland" do
		hday = HolidayTestClass.new(2014,8,15,:saarland)
		hday.is_holiday?.should be true
	end

	it "31.10.2015 should be a holiday in Brandenburg" do
		hday = HolidayTestClass.new(2015,10,31,:Brandenburg)
		hday.is_holiday?.should be true
	end

	it "1.11.2016 should be a holiday in Bayern" do
		hday = HolidayTestClass.new(2016,11,1,"BAYERN")
		hday.is_holiday?.should be true
	end

	it "15.6.2017 should be a holiday in Nordrhein-Westfalen (Fronleichnam)" do
		hday = HolidayTestClass.new(2017,6,15,:nordrhein_westfalen)
		hday.is_holiday?.should be true
	end

	it "21.11.2018 should be a holiday in Sachsen (Buss- und Bettag)" do
		hday = HolidayTestClass.new(2018,11,21,:SACHSEN)
		hday.is_holiday?.should be true
	end


	it "1.1.2012 should be NO holiday if holiday_value was set to false" do
		hday = HolidayTestClass.new(2012,1,1)
		hday.holiday_value=false
		hday.is_holiday?.should be false
	end

	it "2.1.2012 should be NO holiday" do
		hday = HolidayTestClass.new(2012,1,2)
		hday.is_holiday?.should be false
	end

	it "2.1.2012 should be a holiday if holiday_value was set to true" do
		hday = HolidayTestClass.new(2012,1,2)
		hday.holiday_value=true
		hday.is_holiday?.should be true
	end
end


=begin

class HolidayCalendar
	attr_reader :year

	def initialize (year, *flexible_holidays)
		@year = year

		@constant_holidays = ["01.01.#{year}", "01.05.#{year}", "03.10.#{year}", "25.12.#{year}", "26.12.#{year}"]

		@flexible_holidays = flexible_holidays[0..3]

		@constant_holidays_by_state = {	"06.01.#{year}" => [:BADEN_WUERTTEMBERG,
															:BAYERN,
															:SACHSEN_ANHALT],
										"15.08.#{year}" => [:SAARLAND],
										"31.10.#{year}" => [:BRANDENBURG,
															:MECKLENBURG_VORPOMMERN,
															:SACHSEN,
															:SACHSEN_ANHALT,
															:THUERINGEN],
										"01.11.#{year}" => [:BADEN_WUERTTEMBERG,
															:BAYERN,
															:NORDRHEIN_WESTFALEN,
															:RHEINLAND_PFALZ,
															:SAARLAND]}
		
		@flexible_holidays_by_state = { flexible_holidays[4] => [	:BADEN_WUERTTEMBERG,
																	:BAYERN,
																	:HESSEN,
																	:NORDRHEIN_WESTFALEN,
																	:RHEINLAND_PFALZ,
																	:SAARLAND],
										flexible_holidays[5] => [	:SACHSEN]}
	end

	def is_holiday? (datestr, state)
		return true if @constant_holidays.find { |d| d == datestr}
		return true if @flexible_holidays.find { |d| d == datestr}

		states = @constant_holidays_by_state[datestr]
		return true if states.find { |s| s == state} unless states.nil?

		states = @flexible_holidays_by_state[datestr]
		return true if states.find { |s| s == state} unless states.nil?

		return false
	end
end


class HolidayTest
	include Holiday

	attr_reader :date

	def initialize(year, month, day)
		@date = Time.local(year,month,day)
	end
end


describe Holiday do
	
	it "should be a holiday if it's a holiday in HolidayCalendar" do
		
		all_states = Holiday::ALL_STATES
		all_states[:NONSENS] = "17. Bundesland"

		calendars = Array.new
		calendars[0] = HolidayCalendar.new(2012, "06.04.2012", "09.04.2012", "17.05.2012", "28.05.2012", "07.06.2012", "21.11.2012")
		calendars[1] = HolidayCalendar.new(2013, "29.03.2013", "01.04.2013", "09.05.2013", "20.05.2013", "30.05.2013", "20.11.2013")
		calendars[2] = HolidayCalendar.new(2014, "18.04.2014", "21.04.2014", "29.05.2014", "09.06.2014", "19.06.2014", "19.11.2014")
		calendars[3] = HolidayCalendar.new(2015, "03.04.2015", "06.04.2015", "14.05.2015", "25.05.2015", "04.06.2015", "18.11.2015")
		calendars[4] = HolidayCalendar.new(2016, "25.03.2016", "28.03.2016", "05.05.2016", "16.05.2016", "26.05.2016", "16.11.2016")
		calendars[5] = HolidayCalendar.new(2017, "14.04.2017", "17.04.2017", "25.05.2017", "05.06.2017", "15.06.2017", "22.11.2017")
		calendars[6] = HolidayCalendar.new(2018, "30.03.2018", "02.04.2018", "10.05.2018", "21.05.2018", "31.05.2018", "21.11.2018")
		calendars[7] = HolidayCalendar.new(2019, "19.04.2019", "22.04.2019", "30.05.2019", "10.06.2019", "20.06.2019", "20.11.2019")
		calendars[8] = HolidayCalendar.new(2020, "10.04.2020", "13.04.2020", "21.05.2020", "01.06.2020", "11.06.2020", "18.11.2020")


		calendars.each do |cal|

			hday = HolidayTest.new(cal.year, 1, 1)

			until hday.date.year > cal.year do

				datestr = hday.date.strftime("%d.%m.%Y")

				all_states.each do |state|
					
					hday.configure { |config| config.states = state }

					hday.is_holiday?.should == cal.is_holiday?(datestr, state)
				end

				nextDay = hday.date.roll_days(1)
				hday = HolidayTest.new(nextDay.year, nextDay.month, nextDay.day)
			end
		end
	end
end
=end
