FactoryGirl.define do
  factory :permission do
    subject { create :user }
    allow { Permission::TYPES.sample }
    expires_at { 1.month.from_now }

    trait(:adult)   { allow :adult }
    trait(:premium) { allow :premium }
    trait(:expired) { expires_at 1.month.ago }
    trait(:active) { expires_at 1.month.from_now }

    trait(:admin) { allow :admin }
    trait(:supervisor) { allow :supervisor }
    trait(:agent) { allow :agent }
  end
end
