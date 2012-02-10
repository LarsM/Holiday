module Holiday

  extend self

  # just for demonstration purposes
  def is_holiday?
    self == Time.now
  end

  # all the other methods here
end

class DateNotImplementedError < StandardError

  def message
    %{You have to implement a #date method to use delegation of holiday check.}
  end

end

# Variation one
# This module defines delegation of holiday check to
# an attribute of a class which wants to get the
# check directly
# 
# It's a simplier approach, and avoids double checks
# (has_date?)
module HolidayCheckable

  def is_holiday?
    raise DateNotImplementedError.new unless self.respond_to?(:date)
    self.send(:date).is_holiday?
  end
end

# Variation two
# This module defines an config method, where the  
# attribute could be explicitly defined. 
module HolidayCheckableWithDelegate

  def self.included(base)
    base.send(:include,InstanceMethods)
    base.send(:extend,ClassMethods)
  end

  module ClassMethods

    def method_for_holiday_check
      @holiday_method ||= :date
    end

    # @param [String|Symbol] method_name The method name the check should delegate to.
    def delegate_holiday_check_to(method_name)
      @holiday_method = method_name
    end
  end

  module InstanceMethods

    def is_holiday?
      if self.class.method_for_holiday_check.eql?(:date)
        raise DateNotImplementedError.new unless self.respond_to?(:date)
      end
      self.send(self.class.method_for_holiday_check).is_holiday?
    end

  end

end
class Time
  include Holiday
end

class TestDay

  include HolidayCheckable # now TestDay has an instance method is_holiday?

  def date
    Time.now
  end

end

class TestDayWithoutDateImplemented
  include HolidayCheckable # now TestDay has an instance method is_holiday? but it fails
end

class TestDayWithConfigurableHolidayCheck
  include HolidayCheckableWithDelegate # now TestDay has an instance method is_holiday?

  delegate_holiday_check_to :new_day # is_holiday? is delegated to new_day.is_holiday?

  def new_day
    Time.now
  end
end

class TestDayWithConfigurableHolidayCheckButDefaultUsage
  
  include HolidayCheckableWithDelegate  # same as TestDay but with possibility to configure the 
                                        # delegation, which isn't used here.

  def date
    Time.now
  end
end

day = TestDay.new
p "for holiday implement like lars did: #{day.is_holiday?}"

day_with_config = TestDayWithConfigurableHolidayCheck.new
p "for day_with_config: #{day_with_config.is_holiday?}"

day_with_default = TestDayWithConfigurableHolidayCheckButDefaultUsage.new
p "for day_with_default: #{day_with_default.is_holiday?}"

# At the end because it raises an error
day_without = TestDayWithoutDateImplemented.new
p day_without.is_holiday?

# How we can use this as ActiveRecord plugin without including 
# HolidayCheckableWithDelegate? 
# In the main file of the Gem:
#
# ActiveRecord::Base.send(:include, HolidayCheckableWithDelegate) if defined? ActiveRecord::Base
#   
# So every ActiveRecord::Base class could use delegate_holiday_check_to out of the box.
#
# With plain Ruby every class has to include the module HolidayCheckableWithDelegate
#
# Summary:
# configurable Holiday included in Time to get the same 'subject' context:
# - configuring of regions where an holiday check should be available
# - date check
# 
# configuring delegation of holiday check to any attribute or a default in a
# single module to keep the delegation config scope clear and avoiding of double checks
# (date is just an attribute of an class and the class is not a Time object)