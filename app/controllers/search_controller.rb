class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:q].to_s.strip

    if @query.present?
      project_ids = current_user.projects.pluck(:id)

      # Search tasks — only within projects the user is a member of
      @tasks = Task.search(
        @query,
        fields:  [ :title, :description, :assignee_email ],
        where:   { project_id: project_ids },
        order:   { updated_at: :desc },
        limit:   20,
        misspellings: { below: 3 }
      )

      # Search projects — only projects the user belongs to
      @projects = Project.search(
        @query,
        fields: [ :name, :description ],
        where:  { member_ids: current_user.id },
        limit:  10,
        misspellings: { below: 3 }
      )
    else
      @tasks    = []
      @projects = []
    end
  rescue Searchkick::Error, Faraday::ConnectionFailed, Elastic::Transport::Transport::Error, SocketError => e
    # Gracefully degrade when Elasticsearch is unavailable
    flash.now[:alert] = t("search.elasticsearch_unavailable")
    @tasks    = []
    @projects = []
  end
end
