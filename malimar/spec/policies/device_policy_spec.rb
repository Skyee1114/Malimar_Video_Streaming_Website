require "rails_helper"
require "matrix"
require_relative "shared_examples/permissin_matrix_specs"
require "factories/user"
require "factories/device/roku"

describe DevicePolicy do
  subject { described_class }

  describe "another" do
    let(:resource) { build :roku_device }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,           :registered, :invited, :guest],
      [:create?,      true,          false,     false],
      [:show?,        false,         false,     false],
      [:update?,      false,         false,     false],
      [:destroy?,     false,         false,     false],
    ]
  end

  describe "self" do
    let(:resource) { build :roku_device, user_id: @user.id }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,           :registered, :invited, :guest],
      [:create?,      true,          false,     false],
      [:show?,        true,          false,     false],
      [:update?,      true,          false,     false],
      [:destroy?,     true,          false,     false],
    ]
  end
end
