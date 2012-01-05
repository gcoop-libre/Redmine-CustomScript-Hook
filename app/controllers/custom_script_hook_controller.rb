
class CustomScriptHookController < ApplicationController

  skip_before_filter :verify_authenticity_token, :check_if_login_required

  def index
    if request.post?
       exec('/home/redmine/repositorios/actualizar_repositorios')
    end

    render(:text => 'You have to POST if you want to execute the script')
  end

  private

  # Executes shell command. Returns true if the shell command exits with a success status code
  def exec(command)
    logger.debug { "CustomScriptHook: Executing command: '#{command}'" }

    # Get a path to a temp file
    logfile = Tempfile.new('github_hook_exec')
    logfile.close

    success = system("#{command} > #{logfile.path} 2>&1")
    output_from_command = File.readlines(logfile.path)
    if success
      logger.debug { "CustomScriptHook: Command output: #{output_from_command.inspect}"}
    else
      logger.error { "CustomScriptHook: Command '#{command}' didn't exit properly. Full output: #{output_from_command.inspect}"}
    end

    return success
  ensure
    logfile.unlink
  end

end
