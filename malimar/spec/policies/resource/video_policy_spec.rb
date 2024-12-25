require "rails_helper"
require "matrix"
require_relative "../shared_examples/permissin_matrix_specs"
require "factories/user"
require "factories/resource/video"

describe Resource::VideoPolicy do
  subject { described_class }

  if feature_active? :subscription
    describe "free content" do
      let(:resource) { build :video, :free }

      include_examples :permission_matrix, matrix: Matrix[
        [nil,     :premium_adult,  :adult,  :premium,  :registered,  :guest],
        [:show?,  true,            true,    true,      true,         true],
      ]
    end

    describe "premium content" do
      let(:resource) { build :video, :premium }

      include_examples :permission_matrix, matrix: Matrix[
        [nil,     :premium_adult,  :adult,  :premium,  :registered,  :guest,  :admin,  :supervisor,  :agent],
        [:show?,  true,            true,    true,      false,        false,   true,    true,         true],
      ]
    end

    describe "adult content" do
      let(:resource) { build :video, :adult }

      include_examples :permission_matrix, matrix: Matrix[
        [nil,     :premium_adult,  :adult,  :premium,  :registered,  :guest],
        [:show?,  true,            true,    true,      false,        false],
      ]
    end

  else

    describe "free content" do
      let(:resource) { build :video, :free }

      include_examples :permission_matrix, matrix: Matrix[
        [nil,     :premium_adult,  :adult,  :premium,  :registered,  :guest],
        [:show?,  true,            true,    true,      true,         true],
      ]
    end

    describe "premium content" do
      let(:resource) { build :video, :premium }

      include_examples :permission_matrix, matrix: Matrix[
        [nil,     :premium_adult,  :adult,  :premium,  :registered,  :guest],
        [:show?,  true,            true,    true,      true, false],
      ]
    end

    describe "adult content" do
      let(:resource) { build :video, :adult }

      include_examples :permission_matrix, matrix: Matrix[
        [nil,     :premium_adult,  :adult,  :premium,  :registered,  :guest],
        [:show?,  true,            true,    true,      true,         false],
      ]
    end
  end
end
