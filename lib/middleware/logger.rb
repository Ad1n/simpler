require 'logger'

class AppLogger

  def initialize(app, **options)
    @logger = Logger.new(options[:logdev] || STDOUT)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    generate_logger_string(env, status, headers)
    [status, headers, body]
  end

  private

  def generate_logger_string(env, status, headers)
    check_template(env)
    check_controller_action(env)

    env["simpler.params"] = "" if env["simpler.params"].nil?

    logger_string = "\n\nRequest: " + env["REQUEST_METHOD"] + " " + env["REQUEST_URI"] + "\n" + \
                    "Handler: " + env["simpler.controller"] + env["simpler.action"] + "\n" +\
                    "Parameters: " + env["simpler.params"] + "\n" + \
                    "Response: " + status.to_s + " [" + headers["Content-Type"] + "] " + env["simpler.template"] + "\n"
    @logger.info(logger_string)
  end

  def check_template(env)
    if env["simpler.template"].nil?
      env["simpler.template"] = ""
    else
      env["simpler.template"] += ".html.erb"
    end
  end

  def check_controller_action(env)
    if env["simpler.controller"].nil? || env["simpler.action"].nil?
      env["simpler.controller"] = ""
      env["simpler.action"] = ""
    else
      env["simpler.controller"] = env["simpler.controller"].name.capitalize! + "Controller#"
    end
  end

end
