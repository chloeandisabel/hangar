module Hangar
  class ResourcesController < ActionController::Base

    rescue_from StandardError, with: :error_render_method
    rescue_from ActiveRecord::RecordInvalid, with: :invalid_render_method
    def create
      created = FactoryGirl.create resource, *traits, resource_attributes
      render json: created.as_json(include: includes)
    end

    def new
      attributes = FactoryGirl.attributes_for resource, *traits, resource_attributes
      render json: attributes
    end

    private

    def resource
      request.path.split('/')[2].to_sym
    end

    def resource_attributes
      params.fetch(resource, {}).permit!
    end

    def traits
      params.fetch(:traits, []).map &:to_sym
    end

    def includes
      params.fetch(:include, [])
    end

    def error_render_method(exception)
      status_code = ActionDispatch::ExceptionWrapper.new(env, exception).status_code
      respond_to do |type|
        type.all {
          error = {message: exception.message, stack_trace: exception.backtrace}
          render json: error, status: status_code
        }
      end
      true
    end

    def invalid_render_method(exception)
      status_code = ActionDispatch::ExceptionWrapper.new(env, exception).status_code
      respond_to do |type|
        type.all {
          error = {message: exception.message, record: exception.record}.to_json(include: includes)
          render json: error, status: status_code
        }
      end
      true
    end
  end
end
