require "rails_helper"
require "matrix"
require_relative "../shared_examples/permissin_matrix_specs"
require "factories/user"
require "factories/form/subscription_payment"

describe Form::SubscriptionPaymentPolicy do
  subject { described_class }

  describe "another" do
    let(:resource) { build :subscription_payment_form }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,           :registered, :invited, :guest],
      [:create?,      false, false, false],
    ]
  end

  describe "self" do
    let(:resource) { build :subscription_payment_form, user: @user }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,           :registered,  :invited,  :guest],
      [:create?,      true,         false,     false],
    ]
  end
end
