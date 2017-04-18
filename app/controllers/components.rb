ScoreViewer::App.controllers :components do
  get :index do
    redirect url_for(:components, :list)
  end

  get :list, map: "/components/list/*", provides: [:json, :csv, :html] do
    splat_to_params(params)

    # first, filter by score
    scores = filter(Score.order("updated_at DESC"), [:skater_name, :category, :segment, :nation, :competition_name])
    
    # next, filter by component number
    number = params[:component_number].to_i
    components = Component.where(score_id: scores.select(:id))
    components = components.where(number: number) if number >= 1
    
    case content_type
    when :csv
      header = [:skater, :competition_name, :category, :segment,
                 :number, :component, :factor, :judges, :value]
      ret = components.map do |c|
        score = c.score
        [score.skater_name, score.competition_name, score.category, score.segment,
         c.number, c.component, c.factor, c.judges, c.value]
      end
      output_csv(header, ret, filename: "components.csv")
    else
      render :"components/index", locals: {components: components, score_filter_forms: score_filter_forms}
    end
  end

  post :list do
    redirect url_for(:components, :list, params_to_query(params))
  end
end
