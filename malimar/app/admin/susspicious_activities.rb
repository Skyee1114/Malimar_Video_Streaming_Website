require_relative "00_tweaks"
if defined? ActiveAdmin
  ActiveAdmin.register SusspiciousActivity do
    menu priority: 4, parent: "Other"
    config.sort_order = "created_at_desc"

    controller do
      def permitted_params
        params.permit!
      end

      def scoped_collection
        SusspiciousActivity.distinct(:id)
      end
    end

    scope :all, default: true

    filter :'subject_of_User::Local_type_login_or_subject_of_User::Local_type_email_or_subject_of_User::Local_type_billing_addresses_first_name_or_subject_of_User::Local_type_billing_addresses_last_name_or_subject_of_User::Local_type_billing_addresses_email_or_subject_of_User::Local_type_billing_addresses_phone_or_subject_of_User::Local_type_billing_addresses_zip_cont', label: "User search", as: :string
    filter :action, as: :select
    filter :ip, as: :string
    filter :count, as: :numeric
    filter :object
    filter :created_at, label: "Date"

    SusspiciousActivity::ACTIONS.each do |action|
      scope action
    end

    index do
      selectable_column
      column :subject, sortable: :subject_id
      column :object
      column :action
      column :count
      column :ip
      column :banned do |activity|
        status_tag activity.banned?
      end

      column :created_at

      actions
    end

    show do
      columns do
        column do
          panel "Details" do
            attributes_table_for resource do
              SusspiciousActivity.column_names.each do |column_name|
                row column_name.to_sym unless %w[id created_at updated_at subject_id].include? column_name
              end
              row :id
              text_node button_to "Unban", clear_bans_admin_susspicious_activity_path(resource), method: :post
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
          panel "Subject" do
            subject = resource.subject
            if subject&.is_a?(Device)
              attributes_table_for subject do
                row :class
                row :name
                row :serial_number
                row(:registered) { subject.created_at }

                nested_actions
              end
            end

            if subject&.is_a?(User::Local)
              attributes_table_for subject do
                row :class
                row :login
                row :email
                row(:registered) { subject.created_at }

                nested_actions
              end
            end
          end
        end
      end
    end

    sidebar "Comments", only: :show do
      active_admin_comments_for(resource, panel: false)
    end

    member_action :clear_bans, method: :post do
      resource.clear_bans
      redirect_to resource_path, notice: "Unbanned"
    end
  end
end
