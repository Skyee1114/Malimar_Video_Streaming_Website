require_relative "../00_tweaks"
if defined?(ActiveAdmin) && feature_active?(:roku)
  ActiveAdmin.register Device::BlackListEntry do
    menu priority: 3, parent: "Other"

    controller do
      def permitted_params
        params.permit!
      end
    end

    show do
      panel "Details" do
        attributes_table_for resource do
          Device::BlackListEntry.column_names.each do |column_name|
            row column_name.to_sym unless %w[id created_at updated_at].include? column_name
          end
          row :id
        end
      end
    end

    sidebar "Comments", only: :show do
      active_admin_comments_for(resource, panel: false)
    end
  end
end
