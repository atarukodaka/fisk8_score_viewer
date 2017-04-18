ScoreViewer::App.controllers :scores do
  ## show
  get :id, with: :id do
    if score = Score.find_by(id: params[:id])
      render "scores/show".to_sym, locals: {score: score}
    else
      render :record_not_found, locals: {message: "id: #{params[:id].to_i} in Score"}
    end
  end

  ## list
  get :list, map: "/scores/list/*", provides: [:csv, :html] do
    splat_to_params(params)
    rel = filter(Score.order("id DESC"))

    case content_type
    when :csv
      csv_keys = [:id, :skater_name, :nation, :competition_name, :category, :segment,
                  :date, :rank, :starting_number, :tss, :tes, :pcs, :deductions]
      csv_records = rel.map {|r| csv_keys.map {|k| r[k]}}
      output_csv(csv_keys, csv_records, filename: "scores.csv")
    else
      forms = score_filter_forms
      render :"scores/index", locals: {scores: rel, score_filter_forms: forms}
    end
  end
  
  get :index do
    redirect url_for(:scores, :list)
  end

  post :list do
    redirect url_for(:scores, :list, params_to_query(params))
  end
end # controller
