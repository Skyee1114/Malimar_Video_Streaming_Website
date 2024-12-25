require "rails_helper"
require "matrix"
require_relative "shared_examples/permissin_matrix_specs"
require "factories/user"
require "factories/plan"

describe AdminPolicy do
  subject { described_class }

  describe "registered user" do
    let(:resource) { build :user, :registered }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,        :registered,  :invited,  :guest,  :admin,  :supervisor,  :agent],
      [:create?,   false,        false,     false,   true,    true,         true],
      [:show?,     false,        false,     false,   true,    true,         true],
      [:update?,   false,        false,     false,   true,    true,         true],
      [:destroy?,  false,        false,     false,   true,    true,         false],
      [:index?,    false,        false,     false,   true,    true,         true],
    ]
  end

  describe "self" do
    let(:resource) { @user }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,        :registered,  :invited,  :guest,  :admin,  :supervisor,  :agent],
      [:show?,     false,        false,     false,   true,    true,         true],
      [:update?,   false,        false,     false,   true,    true,         true],
      [:destroy?,  false,        false,     false,   true,    true,         false],
      [:index?,    false,        false,     false,   true,    true,         true],
    ]
  end

  describe "permission on self" do
    let(:resource) { @user.permissions.first }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,        :registered,  :admin,  :supervisor,  :agent],
      [:show?,     false,        true,    true,         true],
      [:update?,   false,        true,    false,        false],
      [:destroy?,  false,        true,    false,        false],
      [:index?,    false,        true,    true,         true],
    ]
  end

  describe "admin user" do
    let(:resource) { build :user, :admin }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,        :registered,  :invited,  :guest,  :admin,  :supervisor,  :agent],
      [:create?,   false,        false,     false,   true,    false,        false],
      [:show?,     false,        false,     false,   true,    true,         true],
      [:update?,   false,        false,     false,   true,    false,        false],
      [:destroy?,  false,        false,     false,   true,    false,        false],
      [:index?,    false,        false,     false,   true,    true,         true],
    ]
  end

  describe "admin permission" do
    let(:resource) { build :permission, :admin }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,        :registered,  :invited,  :guest,  :admin,  :supervisor,  :agent],
      [:create?,   false,        false,     false,   true,    false,        false],
      [:show?,     false,        false,     false,   true,    true,         true],
      [:update?,   false,        false,     false,   true,    false,        false],
      [:destroy?,  false,        false,     false,   true,    false,        false],
      [:index?,    false,        false,     false,   true,    true,         true],
    ]
  end

  describe "supervisor permission" do
    let(:resource) { build :permission, :supervisor }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,        :registered,  :invited,  :guest,  :admin,  :supervisor,  :agent],
      [:create?,   false,        false,     false,   true,    false,        false],
      [:show?,     false,        false,     false,   true,    true,         true],
      [:update?,   false,        false,     false,   true,    false,        false],
      [:destroy?,  false,        false,     false,   true,    false,        false],
      [:index?,    false,        false,     false,   true,    true,         true],
    ]
  end

  describe "premium permission" do
    let(:resource) { build :permission, :premium }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,        :registered,  :invited,  :guest,  :admin,  :supervisor,  :agent],
      [:create?,   false,        false,     false,   true,    true,         true],
      [:show?,     false,        false,     false,   true,    true,         true],
      [:update?,   false,        false,     false,   true,    true,         true],
      [:destroy?,  false,        false,     false,   true,    true,         false],
      [:index?,    false,        false,     false,   true,    true,         true],
    ]
  end

  describe "plans" do
    let(:resource) { build :plan }

    include_examples :permission_matrix, matrix: Matrix[
      [nil,        :registered,  :invited,  :guest,  :admin,  :supervisor,  :agent],
      [:create?,   false,        false,     false,   true,    false,         false],
      [:show?,     false,        false,     false,   true,    true,          true],
      [:update?,   false,        false,     false,   true,    false,         false],
      [:destroy?,  false,        false,     false,   true,    false,         false],
      [:index?,    false,        false,     false,   true,    true,          true],
    ]
  end

  describe "PermissionTypeScope" do
    it "returns full set for admin" do
      user = build :user, :admin
      resolved_types = described_class::PermissionTypeScope.new(user, Permission::TYPES).resolve
      expect(resolved_types).to eq Permission::TYPES
    end

    it "removes admin and supervisor for supervisor" do
      user = build :user, :supervisor
      resolved_types = described_class::PermissionTypeScope.new(user, Permission::TYPES).resolve
      expect(resolved_types).to eq Permission::TYPES - %i[admin supervisor]
    end

    it "removes admin, supervisor and agent for agent" do
      user = build :user, :agent
      resolved_types = described_class::PermissionTypeScope.new(user, Permission::TYPES).resolve
      expect(resolved_types).to eq Permission::TYPES - %i[admin supervisor agent]
    end
  end
end
