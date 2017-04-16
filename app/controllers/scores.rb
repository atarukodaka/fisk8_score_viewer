ScoreViewer::App.controllers :scores do

  limit = 5

  ## show
  get :id, with: :id do
    render "scores/show".to_sym, layout: "layout", locals: {score: Score.find_by(id: params[:id])}
  end

  ## list
=begin
  get :index do
    mp = max_pages(Score.count, limit)
    scores = Score.limit(limit)
    render "scores/index".to_sym, locals: {scores: scores, page: 1, max_pages: mp }
  end
=end
  get :index do
    redirect url_for(:scores, :list)
  end
  get :list, map: "/scores/list/*", provides: [:json, :csv, :html] do
    splat_to_params(params)
    scores = Score.order("date DESC")
    [:skater_name, :category, :segment, :nation, :competition_name].each do |filter|
      scores = scores.where(filter => params[filter]) if params[filter]
    end
    ## output format
    case content_type
    when :json
      content_type 'application/json'
      scores.to_a.map(&:as_json).join('')
    when :csv
      keys = [:id, :skater_name, :nation, :competition_name, :category, :segment,
         :date, :rank, :starting_number, :tss, :tes, :pcs, :deductions]

      output_csv(keys, scores)
    else
      mp = max_pages(scores.count, limit)
      page = (params[:page].presence || 1).to_i
      scores = scores.limit(limit).offset((page-1)*limit)    
      
      render :"scores/index", locals: {scores: scores, page: page, max_pages: mp}
    end
  end

  
  post :list do
    keys = [:skater_name, :category, :segment, :nation, :competition_name]
    format = (params["format"].presence || "html").to_sym
    redirect url_for(:scores, :list, params_to_string(params, keys))
  end

  
end # controller
