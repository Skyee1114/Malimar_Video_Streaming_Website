require_relative "inputs"
if defined? ActiveAdmin
  module DefaultNestedActions
    def default_nested_actions(resource, options = {})
      config = active_admin_resource_for(resource.class)
      disabled_actions = options.fetch(:except) { [] }

      if authorized?(ActiveAdmin::Auth::READ, resource) && !disabled_actions.include?(:view)
        begin
          item I18n.t("active_admin.view"), url_for(config.route_instance_path(resource.id)), class: "view_link #{options[:css_class]}"
        rescue StandardError
          nil
        end
      end
      if authorized?(ActiveAdmin::Auth::UPDATE, resource) && !disabled_actions.include?(:edit)
        begin
          item I18n.t("active_admin.edit"), url_for(config.route_edit_instance_path(resource.id)), class: "edit_link #{options[:css_class]}"
        rescue StandardError
          nil
        end
      end
      if authorized?(ActiveAdmin::Auth::DESTROY, resource) && !disabled_actions.include?(:delete)
        begin
          item I18n.t("active_admin.delete"), url_for(config.route_instance_path(resource.id)), class: "delete_link #{options[:css_class]}",
                                                                                                method: :delete, data: { confirm: I18n.t("active_admin.delete_confirmation") }
        rescue StandardError
          nil
        end
      end
    end
  end

  module ActiveAdmin
    module Views
      class TableFor < Arbre::HTML::Table
        include DefaultNestedActions

        def actions(options = {})
          column do |resource|
            table_actions do
              default_nested_actions resource, { css_class: :member_link }.merge(options)
            end
          end
        end
      end
    end
  end

  module ActiveAdmin
    module Views
      class IndexAsTable < ActiveAdmin::Component
        class IndexTableFor < ::ActiveAdmin::Views::TableFor
          def actions(*)
            super
          end
        end
      end
    end
  end

  module ActiveAdmin
    module Views
      class AttributesTable < ActiveAdmin::Component
        include DefaultNestedActions

        def nested_actions(options = {})
          row :actions do |resource|
            table_actions do
              default_nested_actions resource, { css_class: :member_link }.merge(options)
            end
          end
        end
      end
    end
  end

  module ActiveAdmin
    class DSL
      def sidebar(name, options = {}, &block)
        is_duplicate = config.sidebar_sections.any? do |section|
          section.name == name
        end

        config.sidebar_sections << ActiveAdmin::SidebarSection.new(name, options, &block) unless is_duplicate
      end
    end
  end

  module ActiveAdmin
    module Comments
      module Views
        class Comments < ActiveAdmin::Views::Panel
          def build(resource, panel: true)
            @resource = resource
            @comments = ActiveAdmin::Comment.find_for_resource_in_namespace(resource, active_admin_namespace.name).includes(:author).page(params[:page])
            super(title, for: resource) if panel
            build_comments
          end
        end
      end
    end
  end

  ActiveAdmin::BaseController.include ::Authentication
  ActiveAdmin::BaseController.send :define_method, :authentication_strategies do
    [
      Authentication::LoginStrategy.new(request)
    ]
  end

  ActiveAdmin::BaseController.send :rescue_from, ActiveAdmin::AccessDenied do |_exeption|
    ActionController::HttpAuthentication::Basic.authentication_request self, "Admin"
  end

  module ActiveAdmin
    class PunditAdapter < AuthorizationAdapter
      def scope_collection(collection, _action = Auth::READ)
        default_policy_class::Scope.new(user, collection).resolve
      end

      def retrieve_policy(subject)
        default_policy(user, subject)
      end
    end
  end

  module ActiveAdmin
    module ResourceController::DataAccess
      def apply_filtering(chain)
        filter_params = params[:q] || {}
        filter_params.update(filter_params) do |key, value|
          key.include?("cont") ? value.strip : value
        end

        @search = chain.ransack(filter_params || {})
        @search.result
      end
    end
  end
end
