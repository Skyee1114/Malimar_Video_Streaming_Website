require "factory_girl"
require "faker"
require_relative "permission"

FactoryGirl.define do
  sequence(:email) { |n| "doctor#{n}.who@example.com" }

  factory :user, class: "User::Local" do
    email
    login { email }

    trait :with_password do
      password { "secret123456" }
      initialize_with { User::Local::WithPassword.new }
    end

    trait :as_sign_up do
      password { "secret123456" }
      initialize_with { User::Local::AsSignUp.new }
    end

    trait :invalid do
      email "invalid_email"
    end

    trait :premium_adult do
      permissions do
        save
        [
          create(:permission, :premium, subject_id: id, subject_type: "User::Local")
        ]
      end
    end

    trait :adult do
      permissions do
        save
        [
          create(:permission, :premium, subject_id: id, subject_type: "User::Local")
        ]
      end
    end

    trait :premium do
      permissions do
        save
        [
          create(:permission, :premium, subject_id: id, subject_type: "User::Local")
        ]
      end
    end

    trait :expired do
      permissions do
        save
        [
          create(:permission, :premium, subject_id: id, subject_type: "User::Local", expires_at: 1.year.ago)
        ]
      end
    end

    trait :admin do
      permissions do
        save
        [create(:permission, :admin, subject_id: id, subject_type: "User::Local")]
      end
    end

    trait :supervisor do
      permissions do
        save
        [create(:permission, :supervisor, subject_id: id, subject_type: "User::Local")]
      end
    end

    trait :agent do
      permissions do
        save
        [create(:permission, :agent, subject_id: id, subject_type: "User::Local")]
      end
    end

    trait :registered
    trait :facebook
    trait :google

    trait :guest  do
      transient { password nil }
      initialize_with { User::Guest.new }
    end

    trait :invited do
      transient { password nil }
      initialize_with { User::Invited.new attributes }
    end
  end
end
