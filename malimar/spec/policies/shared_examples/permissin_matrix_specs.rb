# frozen_string_literal: true

require "pundit/rspec"
shared_examples_for :permission_matrix do |matrix:|
  actions           = matrix.column_vectors[0][1..-1]
  roles             = matrix.row_vectors[0][1..-1]
  permission_values = matrix.minor(1..-1, 1..-1)
  let(:owner) { nil }

  actions.each_with_index do |action, action_index|
    permissions action do
      roles.each_with_index do |role, role_index|
        permission = permission_values[action_index, role_index]
        it "is #{permission ? 'granted' : 'denied'} to #{role}" do
          @user = build_stubbed :user, role
          action_index_resource = defined?(index_resource) && index_resource.present? ? index_resource : [resource]
          action_resource = action == :index? ? action_index_resource : resource

          expect(subject.new(@user, action_resource, owner: owner).public_send(action)).to eq permission
        end
      end
    end
  end
end
