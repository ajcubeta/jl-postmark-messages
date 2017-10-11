class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == "#{ENV["JL_UNAME"]}" && password == "#{ENV["JL_PWORD"]}"
      end
    end
end
