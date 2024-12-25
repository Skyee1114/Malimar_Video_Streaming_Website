require_relative "../00_tweaks"
if defined?(ActiveAdmin) && feature_active?(:roku)
  ActiveAdmin.register Device::Activation do
    menu priority: 7
    config.sort_order = "created_at_desc"
    actions :all

    controller do
      def permitted_params
        params.permit!
      end
    end

    show do
      panel "Details" do
        attributes_table_for resource do
          Device::Activation.column_names.each do |column_name|
            row column_name.to_sym unless %w[id created_at updated_at ip].include? column_name
          end
          row :id
        end
      end

      panel "Audit data" do
        attributes_table_for(resource) do
          row :ip
          row :created_at
          row :updated_at
        end
      end
    end

    sidebar "Comments", only: :show do
      active_admin_comments_for(resource, panel: false)
    end
  end
end
