require "factory_girl"
require_relative "roku"

FactoryGirl.define do
  sequence(:serial_number) { |n| n.to_s.rjust(12, "A") }

  factory :device_black_list_entry, class: Device::BlackListEntry do
    serial_number
  end
end
