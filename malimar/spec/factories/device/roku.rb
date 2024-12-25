require "factory_girl"
require "faker"
require_relative "../user"

FactoryGirl.define do
  factory :roku_device, class: Device::Roku do
    serial_number { "4114AC001000" }
    user { build :user }

    trait :invalid do
      serial_number "invalid!"
    end

    trait :premium do
      permissions do
        save
        [
          create(:permission, :premium, subject_id: id, subject_type: "Roku::Device")
        ]
      end
    end
  end
end
