ScoreViewer::App.controllers :scores do

  filter_keys = [:skater_name, :category, :segment, :nation, :competition_name]

  ## show
  get :id, with: :id do
    if score = Score.find_by(id: params[:id])
      render "scores/show".to_sym, locals: {score: score}
    else
      render :record_not_found, locals: {message: "id: #{params[:id].to_i} in Score"}
    end
  end

  ## list
  get :index do
    redirect url_for(:scores, :list)
  end

  get :list, map: "/scores/list/*", provides: [:json, :csv, :html] do
    splat_to_params(params)
    scores = Score.order("date DESC")
    filter_keys.each do |filter|
      scores = scores.where(filter => params[filter]) if params[filter]
    end
    
    ## output format
    case content_type
    when :json
      scores.to_a.map(&:as_json).join('')
    when :csv
      keys = [:id, :skater_name, :nation, :competition_name, :category, :segment,
              :date, :rank, :starting_number, :tss, :tes, :pcs, :deductions]
      output_csv(keys, scores.map {|r| keys.map {|k| r[k]}}, filename: "scores.csv")
      #output_csv(keys, scores)
    else
      render :"scores/index", locals: {scores: scores, filter_keys: filter_keys}
    end
  end

  
  post :list do
    format = (params["format"].presence || "html").to_sym
    redirect url_for(:scores, :list, params_to_query(params, filter_keys), format: format)
  end

  
end # controller
