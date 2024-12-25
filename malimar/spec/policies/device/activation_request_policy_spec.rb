require "rails_helper"
require "matrix"
require_relative "../shared_examples/permissin_matrix_specs"
require "factories/user"
require "factories/device/activation_request"

describe Device::ActivationRequestPolicy do
  subject { described_class }

  let(:resource) { build :device_activation_request }

  include_examples :permission_matrix, matrix: Matrix[
    [nil,       :registered,  :invited, :guest],
    [:create?,  true,         false,    false],
  ]
end
