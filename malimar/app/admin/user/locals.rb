require_relative "../00_tweaks"
if defined? ActiveAdmin
  ActiveAdmin.register User::Local, as: "User" do
    require "country_select"

    menu priority: 1
    permit_params :login, :email, :password
    config.sort_order = "created_at_desc"

    actions :all

    scope :all, default: true
    scope "Web", :premium
    scope "Device", :with_devices
    scope :free

    filter :login_or_email_or_billing_addresses_first_name_or_billing_addresses_last_name_or_billing_addresses_email_or_billing_addresses_phone_or_billing_addresses_zip_cont, label: "User search", as: :string
    filter :billing_addresses_country, label: "Country", as: :select, collection: -> { BillingAddress.uniq.pluck(:country).reject(&:blank?).sort }
    filter :created_at

    controller do
      def scoped_collection
        User::Local::WithPassword.distinct(:id).includes :billing_addresses, :permissions, :devices
      end

      def update
        params[:user].delete("password") if params[:user][:password].blank?
        super
      end
    end

    index do
      selectable_column
      column :name
      column :login

      column :registered, sortable: :created_at do |user|
        user.created_at.to_formatted_s :short
      end

      column :web do |user|
        # FIXME: N+1
        status_tag user.subscription.has_access_to? :premium
      end

      if feature_active? :roku
        column :device do |user|
          # FIXME: N+1
          status_tag user.devices.any?
        end
      end

      column :contacts do |user|
        user.billing_addresses.map do |billing_address|
          link_to billing_address, admin_billing_address_path(billing_address)
        end.join(", ").html_safe
      end

      actions except: [:edit]
    end

    sidebar "New Subscribers", only: :index do
      permissions = Permission.order(created_at: :desc).premium.for_users.includes(:subject).limit(10)
      table_for permissions do
        column(:user) { |permission| auto_link permission.subject }
        column(:at) { |permission| permission.created_at.to_formatted_s :short }
      end
    end

    if feature_active? :roku
      sidebar "New Devices", only: :index do
        permissions = Permission.order(created_at: :desc).premium.for_devices.includes(:subject).limit(10)
        table_for permissions do
          column(:serial_number) { |permission| link_to permission.subject.serial_number, admin_device_path(permission.subject.id) }
          column(:at) { |permission| permission.created_at.to_formatted_s :short }
        end
      end
    end

    show do
      columns do
        column do
          panel "User" do
            attributes_table_for user do
              rows :name, :login, :email
              row :has_password do |user|
                status_tag user.password_digest.present?
              end
            end

            text_node link_to(
              "Edit User", edit_admin_user_path, class: "member_link edit_link"
            )
          end
        end

        column do
          panel "Subscription" do
            permission = user.permissions.first
            attributes_table_for permission do
              row :premium do
                status_tag user.subscription.has_access_to? :premium
              end

              if permission
                row :expires_at
                row :days_left do
                  pluralize ((permission.expires_at - Time.now.utc) / 86_400).round(0), "day"
                end
                nested_actions
              end
            end

            unless permission
              text_node link_to(
                "NEW", new_admin_permission_path(
                         "permission[subject_id]": user.id,
                         "permission[subject_type]": "User::Local",
                         "permission[allow]": :premium
                       ), class: "member_link add_link"
              )
            end
          end
        end
      end

      panel "Recent transactions" do
        transactions = user.transactions.order(created_at: :desc)
        header_action link_to "List #{pluralize transactions.count, 'entry'}", admin_transactions_path("q[user_id_eq]": user.id)

        if transactions.any?
          table_for transactions.limit(10) do
            column :card
            column :name, sortable: "billing_addresses.last_name" do |transaction|
              transaction.billing_address&.name
            end

            column :date, sortable: :created_at do |transaction|
              transaction.created_at.to_formatted_s :short
            end

            column :successful

            column :amount do |transaction|
              number_to_currency transaction.amount
            end
            actions
          end
        end

        text_node link_to(
          "NEW", new_admin_transaction_path(
                   "transaction[user_id]": user.id
                 ), class: "member_link add_link"
        )
      end

      panel "Billing addresses" do
        addresses = user.billing_addresses.order(created_at: :desc)

        if addresses.any?
          table_for addresses do
            column :name
            column :country_code
            column :phone
            column :email
            column :country
            column :zip
            actions
          end
        end

        text_node link_to(
          "NEW", new_admin_billing_address_path(
                   "billing_address[user_id]": user.id
                 ), class: "member_link add_link"
        )
      end

      if feature_active? :roku
        panel "Registered Devices" do
          devices = user.devices.order(created_at: :desc)
          header_action link_to "List #{pluralize devices.count, 'entry'}", admin_devices_path("q[user_id_eq]": user.id)

          if devices.any?
            table_for devices.limit(10) do
              column :type
              column :serial_number
              # column :premium do |device|
              #   # FIXME: N+1
              #   status_tag device.subscription.has_access_to? :premium
              # end

              column :registered do |device|
                device.created_at.to_formatted_s :short
              end

              actions
            end
          end

          text_node link_to(
            "NEW", new_admin_device_path(
                     "device[user_id]": user.id
                   ), class: "member_link add_link"
          )
        end
      end

      panel "Audit data" do
        attributes_table_for user do
          row :created_at
          row :updated_at
        end
      end
    end

    sidebar "Comments", only: :show do
      active_admin_comments_for(resource, panel: false)
    end

    form do |_f|
      semantic_errors
      inputs do
        input :login
        input :email
        input :password
      end

      actions do
        action :submit
        cancel_link :back
      end
    end
  end
end
