require_relative "00_tweaks"
if defined? ActiveAdmin
  ActiveAdmin.register BillingAddress do
    menu false
    actions :all, except: [:index]
    breadcrumb { [] }

    controller do
      def permitted_params
        params.permit!
      end

      def scoped_collection
        super.includes :user
      end

      def redirect_to_user
        lambda do |success, _failure|
          success.html { redirect_to [:admin, resource.user] }
        end
      end

      def update
        super &redirect_to_user
      end

      def create
        super &redirect_to_user
      end

      def destroy
        super &redirect_to_user
      end
    end

    show do
      columns do
        column do
          panel "Details" do
            attributes_table_for billing_address do
              rows :first_name, :last_name, :country_code, :phone, :email, :address, :city, :state, :zip, :country, :id
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
            user = billing_address.user
            if user
              attributes_table_for user do
                row :login
                row :email
                row(:registered) { user.created_at }

                nested_actions
              end
            else
              text_node link_to("Link user", edit_admin_billing_address_path, class: "member_link add_link")
              text_node link_to("NEW user", new_admin_user_path, class: "member_link add_link")
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
      inputs do
        input :user_id, as: :hidden
        input :country, as: :country, priority_countries: %w[US CA FR GB DE], selected: "US"

        BillingAddress.column_names.each do |column_name|
          input column_name.to_sym unless %w[id user_id created_at updated_at country].include? column_name
        end
      end

      actions do
        action :submit
        cancel_link :back
      end
    end
  end
end
