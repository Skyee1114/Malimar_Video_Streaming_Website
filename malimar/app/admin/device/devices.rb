require_relative "../00_tweaks"
if defined?(ActiveAdmin) && feature_active?(:roku)
  ActiveAdmin.register Device do
    menu priority: 3
    config.sort_order = "created_at_desc"
    actions :all

    # scope :all, default: true
    # scope :premium
    # scope :free

    filter :name_or_serial_number_or_user_login_or_user_email_or_user_billing_addresses_first_name_or_user_billing_addresses_last_name_or_user_billing_addresses_email_or_user_billing_addresses_phone_or_user_billing_addresses_zip_cont, label: "Device search", as: :string
    filter :serial_number, as: :select
    filter :type, as: :select
    filter :created_at

    controller do
      def permitted_params
        params.permit!
      end

      def scoped_collection
        super.distinct(:id).includes(user: :billing_addresses)
      end
    end

    index do
      selectable_column
      column :user do |device|
        device.user&.name
      end
      column :name
      column :serial_number

      # column :premium do |device|
      #   # FIXME: N+1
      #   status_tag device.subscription.has_access_to? :premium
      # end

      column :registered, sortable: :created_at do |device|
        device.created_at.to_formatted_s :short
      end

      actions
    end

    show do
      columns do
        column do
          panel "Device" do
            attributes_table_for device do
              rows :type, :serial_number, :id
            end
          end

          panel "Audit data" do
            attributes_table_for(resource) do
              row :created_at
              row :updated_at
            end
          end
        end

        column do
          panel "User" do
            user = device.user
            if user
              attributes_table_for user do
                row :name
                row :login
                row :email
                row(:registered) { user.created_at }

                nested_actions
              end
            else
              text_node link_to("Link user", edit_admin_device_path, class: "member_link add_link")
              text_node link_to("NEW user", new_admin_user_path, class: "member_link add_link")
            end
          end
        end
      end
    end

    # sidebar "Subscription", only: :show do
    #   permission = device.permissions.first
    #   attributes_table_for permission do
    #     row :premium do
    #       status_tag device.subscription.has_access_to? :premium
    #     end

    #     if permission
    #       row :expires_at
    #       row :days_left do
    #         pluralize ((permission.expires_at - Time.now.utc) / 86400).round(0), "day"
    #       end
    #       nested_actions
    #     end
    #   end

    #   text_node link_to(
    #     'NEW', new_admin_permission_path(
    #       "permission[subject_id]": device.id,
    #       "permission[subject_type]": "Device",
    #       "permission[allow]": :premium
    #     ), class: 'member_link add_link') unless permission
    # end

    sidebar "Comments", only: :show do
      active_admin_comments_for(resource, panel: false)
    end

    form do |_f|
      semantic_errors
      unless resource.user_id
        inputs "Links" do
          users = User::Local.all.map { |user| [user.to_s, user.id] }
          input :user, collection: users
        end
      end

      inputs "Device" do
        input :user_id, as: :hidden if resource.user_id
        input :name
        input :type, collection: Device.subclasses.map(&:name), as: :select
        input :serial_number
      end

      actions do
        action :submit
        cancel_link :back
      end
    end
  end
end
