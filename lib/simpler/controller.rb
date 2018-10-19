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
      @request.params[:id] = set_parameters

      send(action)
      check_header
      write_response

      env["simpler.params"] = params.to_s

      @response.finish
    end

    private

    def status(code)
      @response.status = code
    end

    def set_parameters
      @request.path.split("/").last.to_i
    end

    def check_header
      check = @request.env['simpler.template']

      if check.class == Hash
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
