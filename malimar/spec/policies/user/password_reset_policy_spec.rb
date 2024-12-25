require "rails_helper"
require "matrix"
require_relative "../shared_examples/permissin_matrix_specs"
require "factories/password_reset"

describe User::InvitationPolicy do
  subject { described_class }

  let(:resource) { build :password_reset, email: user.email }
  let(:user) { create :user, :registered }

  include_examples :permission_matrix, matrix: Matrix[
    [nil,       :registered,  :invited, :guest],
    [:create?,  true,         true,     true],
  ]
end
