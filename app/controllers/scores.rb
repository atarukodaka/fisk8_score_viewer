ScoreViewer::App.controllers :scores do
  settings.filter_keys[:scores] = [:skater_name, :category, :segment, :nation, :competition_name,]
  
  ## show
  get :id, with: :id do
    if score = Score.find_by(id: params[:id])
      render :"scores/show", locals: {score: score}
    else
      render :record_not_found, locals: {message: "id: #{params[:id].to_i} in Score"}
    end
  end

  ## list
  get :list, map: "/scores/list/*", provides: [:html, :csv] do
    splat_to_params(params)
    #scores = filter(Score.order("starting_time DESC"), :scores)
    scores = filter_by_keys(Score.order("starting_time DESC"), [:skater_name, :category, :segment, :nation, :competition_name])
    
    case content_type
    when :csv
      csv_keys = [:id, :skater_name, :nation, :competition_name, :category, :segment,
                  :starting_time, :rank, :starting_number, :tss, :tes, :pcs, :deductions]
      csv_records = scores.map {|r| csv_keys.map {|k| r[k]}}
      output_csv(csv_keys, csv_records, filename: "scores.csv")
    else
      render :"scores/index", locals: {scores: scores}
    end
  end
  
  get :index do
    redirect url_for(:scores, :list)
  end

  post :list do
    redirect url_for(:scores, :list, params_to_query(params, :scores))
  end
end # controller
