require "rails_helper"
require "matrix"
require_relative "../shared_examples/permissin_matrix_specs"
require "factories/user"

describe User::LocalPolicy do
  subject { described_class }

  describe "user" do
    let(:resource) { build_stubbed :user }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,       :registered,  :invited,  :guest],
      [:show?,    false,        false,     false],
      [:create?,  true,         true,      true],
      [:update?,  false,        false,     false],
    ]
  end

  describe "self" do
    let(:resource) { @user }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,       :registered,  :invited,  :guest],
      [:show?,    true,         false,     false],
      [:create?,  true,         true,      false],
      [:update?,  true,         false,     false],
    ]
  end
end
