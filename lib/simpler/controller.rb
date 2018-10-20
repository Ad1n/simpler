require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
    end

    def make_response(action, env)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action
      check_controller_action(env)
      @request.params[:id] = set_parameters

      send(action)
      check_header
      write_response

      env["simpler.params"] = params
      check_params(env)
      check_template(env)

      @response.finish
    end

    private

    def check_params(env)
      env["simpler.params"] = "" if env["simpler.params"].nil?
    end

    def check_controller_action(env)
      if env["simpler.controller"].nil? || env["simpler.action"].nil?
        env["simpler.controller"] = ""
        env["simpler.action"] = ""
      else
        env["simpler.controller"] = env["simpler.controller"].name.capitalize! + "Controller#"
      end
    end

    def check_template(env)
      if env["simpler.template"].nil?
        env["simpler.template"] = ""
      else
        env["simpler.template"] += ".html.erb"
      end
    end

    def status(code)
      @response.status = code
    end

    def set_parameters
      reg_params = %r{[0-9]+}
      @request.path.scan(reg_params)
    end

    def check_header
      check = @request.env['simpler.template']

      if check.is_a?(Hash)
        set_plain_headers if check.key?(:plain)
      else
        set_default_headers
      end
    end

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_plain_headers
      @response['Content-Type'] = 'text/plain'
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.params
    end

    def render(template)
      @request.env['simpler.template'] = template
    end

  end
end
