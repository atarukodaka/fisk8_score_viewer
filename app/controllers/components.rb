ScoreViewer::App.controllers :components do
  filter_keys = [:skater_name, :category, :segment, :nation, :competition_name, :component_number]
  
  get :index do
    redirect url_for(:components, :list)
  end

  get :list, map: "/components/list/*", provides: [:json, :csv, :html] do
    splat_to_params(params)

    # first, filter by score
    scores = Score.order("updated_at DESC")
    [:skater_name, :category, :segment, :nation, :competition_name].each do |filter|
      scores = scores.where(filter => params[filter]) if params[filter]
    end
    
    # next, filter by component number
    number = params[:component_number].to_i
    components = Component.where(score_id: scores.select(:id))
    components = components.where(number: number) if number >= 1
    
    case params[:format]
    when :json
      components.to_a.map(&:as_json).join('')      
    when 'csv'
      header = [:skater, :competition_name, :category, :segment,
                 :number, :component, :factor, :judges, :value]
      ret = components.map do |c|
        score = c.score
        [score.skater_name, score.competition_name, score.category, score.segment,
         c.number, c.component, c.factor, c.judges, c.value]
      end
      output_csv(header, ret, filename: "components.csv")
    else
      render :"components/index", locals: {components: components, filter_keys: filter_keys}
    end
  end

  post :list do
    redirect url_for(:components, :list, params_to_query(params, filter_keys), format: params[:format])
  end
end
