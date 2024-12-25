require "rails_helper"
require "matrix"
require_relative "../shared_examples/permissin_matrix_specs"
require "factories/user"
require "factories/resource/container"

describe Resource::ContainerPolicy do
  subject { described_class }

  describe "free content" do
    let(:resource) { build :container, :free }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,     :premium_adult,  :adult,  :premium,  :registered,  :guest],
      [:show?,  true,            true,    true,      true,         true],
    ]
  end

  describe "premium content" do
    let(:resource) { build :container, :premium }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,     :premium_adult,  :adult,  :premium,  :registered,  :guest],
      [:show?,  true,            true,    true,      true,         true],
    ]
  end

  describe "adult content" do
    let(:resource) { build :container, :adult }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,     :premium_adult,  :adult,  :premium,  :registered,  :guest],
      [:show?,  true,            true,    true,      true,         true],
    ]
  end

  describe "hidden content" do
    let(:resource) { build :grid, :english_for_free }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,     :premium_adult,  :adult,  :premium,  :registered,  :guest],
      [:show?,  false,           false,   false,     false,        false],
    ]
  end
end
