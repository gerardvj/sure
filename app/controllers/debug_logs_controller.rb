class DebugLogsController < ApplicationController
  def index
    if Current.user&.admin? || Rails.env.development?
      log_path = Rails.root.join("log", "production.log")
      
      lines = if File.exist?(log_path)
                `tail -n 250 #{log_path}`
              else
                "Log file not found at #{log_path}"
              end
              
      render plain: lines
    else
      render plain: "Unauthorized", status: :unauthorized
    end
  end
end
