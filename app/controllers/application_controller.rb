class ApplicationController < ActionController::Base
  before_action :authenticate_tenant!
  protect_from_forgery
end
