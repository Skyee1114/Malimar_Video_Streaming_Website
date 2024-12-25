require_relative "00_tweaks"
if defined? ActiveAdmin
  ActiveAdmin.register Permission do
    menu false
    actions :all, except: [:index]
    breadcrumb { [] }

    controller do
      def permitted_params
        params.permit!
      end

      def scoped_collection
        super.includes :subject
      end

      def redirect_to_user
        lambda do |success, _failure|
          success.html { redirect_to [:admin, resource.subject] }
        end
      end

      def new
        @page_title = "Subscription"
        super
      end

      def update
        permission = params.fetch(:permission)[:allow].to_sym
        allowed_permissions = AdminPolicy::PermissionTypeScope.new(current_user, Permission::TYPES).resolve
        render(:new) && return unless allowed_permissions.include? permission

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
          panel "Subscription" do
            attributes_table_for permission do
              rows :allow, :expires_at, :id
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
            subject = permission.subject
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

    form do |_f|
      inputs "Details" do
        input :subject_id,    as: :hidden
        input :subject_type,  as: :hidden

        input :allow, collection: AdminPolicy::PermissionTypeScope.new(current_user, Permission::TYPES).resolve, as: :select
        input :expires_at, as: :datepicker
      end

      actions do
        action :submit
        cancel_link :back
      end
    end
  end
end
