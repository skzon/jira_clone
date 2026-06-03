class HomeController < ApplicationController
  def index
    if user_signed_in?
      @projects = current_user.projects.order("projects.created_at DESC").distinct
      @total_projects = @projects.size
      @active_projects = @projects.count { |p| (p.status.presence || "active").downcase == "active" }
      @on_hold_projects = @projects.count { |p| p.status.to_s.downcase == "on_hold" }
      @completed_projects = @projects.count { |p| p.status.to_s.downcase == "completed" }
      @recent_projects = @projects.first(3)
    end
  end
end
