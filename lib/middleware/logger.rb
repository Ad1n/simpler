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
    logger_string = <<~HEREDOC
      Request: #{env["REQUEST_METHOD"]} #{env["REQUEST_URI"]} 
      Handler: #{env["simpler.controller"]} #{env["simpler.action"]}
      Parameters: #{env["simpler.params"]}
      Response: #{status} [#{headers["Content-Type"]}] #{env["simpler.template"]}
    HEREDOC
    @logger.info(logger_string)
  end

end
