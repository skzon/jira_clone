class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :set_current_actor
  before_action :set_locale

  private

  def set_current_actor
    Current.actor = current_user if respond_to?(:current_user) && current_user
  end

  def set_locale
    requested = params[:locale].presence || session[:locale].presence
    locale    = requested.to_s.to_sym
    I18n.locale = I18n.available_locales.include?(locale) ? locale : I18n.default_locale
  end

  # Authorize the current user against a project's membership.
  # Returns true if allowed; otherwise redirects and returns false.
  def require_project_member!(project)
    return true if project&.member?(current_user)

    redirect_to projects_path, alert: t("flash.access_denied")
    false
  end
end
