require "rails_helper"
require "matrix"
require_relative "../shared_examples/permissin_matrix_specs"
require "factories/invitation"

describe User::SessionPolicy do
  subject { described_class }

  let(:resource) { double :resource }

  include_examples :permission_matrix, matrix: Matrix[
    [nil,       :registered,  :invited, :guest],
    [:create?,  true,         false, false],
  ]
end
