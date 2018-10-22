require_relative 'router/route'

module Simpler
  class Router

    def initialize
      @routes = []
    end

    def get(path, route_point)
      add_route(:get, path, route_point)
    end

    def post(path, route_point)
      add_route(:post, path, route_point)
    end

    def route_for(env)
      method = env['REQUEST_METHOD'].downcase.to_sym
      path = env['PATH_INFO']

      #Regular Exp for routes with param
      reg = %r[^\/[a-z]+\/([:id]{3}|[0-9]+)$]

      @routes.find do |route|
        if path.match?(reg) && route.path.match?(reg)
          set_route_params(env, :id)
          route
        else
          env["simpler.route_params"] = ""
          route.match?(method, path)
        end
      end

    end

    private

    def set_route_params(env, key)
      case key
      when :id
        env["simpler.route_params"] = { id: env['PATH_INFO'].split('/').last }
      when :UUID
        #something
      else
        env["simpler.route_params"] = { key => env['PATH_INFO'].split('/').last }
      end
    end

    def add_route(method, path, route_point)
      route_point = route_point.split('#')
      controller = controller_from_string(route_point[0])
      action = route_point[1]

      route = Route.new(method, path, controller, action)

      @routes.push(route)
    end

    def controller_from_string(controller_name)
      Object.const_get("#{controller_name.capitalize}Controller")
    end

  end
end
