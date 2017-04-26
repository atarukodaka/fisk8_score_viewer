ScoreViewer::App.controllers :components do

  settings.filter_keys[:components] = [:component_number, :skater_name, :category, :segment, :nation, :competition_name,]
  
  get :index do
    redirect url_for(:components, :list)
  end

  get :list, map: "/components/list/*", provides: [:html, :csv] do
    splat_to_params(params)

    # first, filter by score
    scores = filter(Score.order("updated_at DESC"), :scores)
    
    # next, filter by component number
    number = params[:component_number].to_i
    components = Component.where(score_id: scores.select(:id))
    components = components.where(number: number) if number >= 1
    
    case content_type
    when :csv
      header = [:skater, :competition_name, :category, :segment,
                :number, :component, :factor, :judges, :value]
      records = components.map do |c|
        [c.score.skater_name, c.score.competition_name, c.score.category, c.score.segment,
         c.number, c.component, c.factor, c.judges, c.value]
      end
      output_csv(header, records, filename: "components.csv")
    else
      render :"components/index", locals: {components: components}
    end
  end

  post :list do
    redirect url_for(:components, :list, params_to_query(params, :components))
  end
end
