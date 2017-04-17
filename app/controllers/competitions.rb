ScoreViewer::App.controllers :competitions do
  filter_keys = [:competition_type, :season]
  
  get :index do
    redirect url_for(:competitions, :list)
  end
  get :list, map: "/competitions/list/*", provides: [:html, :csv] do
    splat_to_params(params)
    competitions = Competition.order("start_date DESC")
    filter_keys.each do |filter|
      competitions = competitions.where(filter => params[filter]) if params[filter]
    end
    render :"competitions/index", locals: {competitions: competitions}
  end

  post :list do
    format = (params["format"].presence || "html").to_sym
    redirect url_for(:competitions, :list, params_to_query(params, filter_keys), format: format)
  end
  ################
  get :id, with: :id do
    if competition = Competition.find_by(id: params[:id])
      render :"competitions/show", locals: {competition: competition, scores: competition.scores}
    else
      render :record_not_found, locals: {message: "id: #{params[:id].to_i} in Competition"}
    end
  end

  get :id, with: [:id, :category] do
    if competition = Competition.find_by(id: params[:id])
      scores = competition.scores.where(category: params[:category])
      render :"competitions/show", locals: {competition: competition, scores: scores}
    else
      erb "record not found"
    end
  end

  get :id, with: [:id, :category, :segment] do
    if competition = Competition.find(params[:id])
      scores = competition.scores.where(category: params[:category], segment: params[:segment])
      render :"competitions/show", locals: {competition: competition, scores: scores}
    else
      erb "record not found"
    end
  end
end
