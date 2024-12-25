require_relative "00_tweaks"
require_relative "user/locals"
if defined? ActiveAdmin
  ActiveAdmin.register Transaction do
    menu priority: 2
    config.sort_order = "created_at_desc"
    actions :all

    controller do
      def permitted_params
        params.permit!
      end

      def scoped_collection
        super.distinct(:id).includes :user, :billing_address
      end
    end

    scope :all, default: true
    scope :successful
    scope :failed

    filter :user_login_or_user_email_or_billing_address_first_name_or_billing_address_last_name_or_billing_address_email_or_billing_address_phone_or_billing_address_zip_cont, label: "User search", as: :string
    filter :description_or_response_or_transaction_id_or_authorization_code_or_ip_cont, label: "Transaction field search", as: :string
    filter :billing_address_country, label: "Country", as: :select, collection: -> { BillingAddress.uniq.pluck(:country).reject(&:blank?).sort }
    filter :description, as: :select
    filter :amount, as: :select
    filter :created_at, label: "Date"

    index do
      selectable_column
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

    show do
      columns do
        column do
          panel "Billing address" do
            address = transaction.billing_address
            if address
              attributes_table_for address do
                row :name
                row :country_code
                row :phone
                row :email
                row :address
                row :city
                row :state
                row :zip
                row :country

                nested_actions
              end
            else
              text_node link_to("Link address", edit_admin_transaction_path, class: "member_link add_link")
              text_node link_to(
                "NEW user address", new_admin_billing_address_path(
                                      "billing_address[user_id]": transaction.user_id
                                    ), class: "member_link add_link"
              )
            end
          end

          panel "User" do
            user = transaction.user
            if user
              attributes_table_for user do
                row :name
                row :login
                row :email
                row(:registered) { user.created_at }

                nested_actions
              end
            else
              text_node link_to("Link user", edit_admin_transaction_path, class: "member_link add_link")
              text_node link_to("NEW user", new_admin_user_path, class: "member_link add_link")
            end
          end
        end

        column do
          panel "Request" do
            attributes_table_for transaction do
              rows :amount, :description, :card, :invoice, :id
            end
          end

          panel "Gateway response" do
            attributes_table_for transaction do
              rows :transaction_id, :authorization_code
              row :successful do
                status_tag transaction.successful?
              end
              row :response
            end
          end

          panel "Audit data" do
            attributes_table_for transaction do
              row :ip
              row :created_at
              row :updated_at
            end
          end
        end
      end
    end

    sidebar "Comments", only: :show do
      active_admin_comments_for(resource, panel: false)
    end

    form do |_f|
      semantic_errors
      unless resource.user_id
        panel "Notice" do
          text_node "For better experience, add transaction from user page. You can find user "
          text_node link_to "here", admin_users_path
        end
      end

      inputs "Links" do
        if resource.user_id
          addresses = BillingAddress.where(user_id: resource.user_id).order(created_at: :desc).map { |ba| [ba.to_s, ba.id] }
          input :user_id, as: :hidden
          input :billing_address, collection: addresses, selected: addresses.first
        else
          addresses = BillingAddress.all.order(created_at: :desc).map { |ba| [ba.to_s, ba.id] }
          users = User::Local.all.map { |user| [user.to_s, user.id] }
          input :user, collection: users
          input :billing_address, collection: addresses
        end
      end

      inputs "Request" do
        input :amount
        input :description
        input :card, placeholder: "last 4 digits"
        input :invoice
      end

      inputs "Gateway response" do
        input :transaction_id, label: "Transaction ID"
        input :authorization_code
        input :successful, as: :radio
        input :response
      end

      inputs "Audit data" do
        input :ip
      end

      actions do
        action :submit
        cancel_link :back
      end
    end
  end
end
