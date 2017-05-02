ScoreViewer::App.controllers :components do

  settings.filter_keys[:components] = [:component_number, :skater_name, :category, :segment, :nation, :competition_name,]
  
  get :index do
    redirect url_for(:components, :list)
  end

  get :list, map: "/components/list/*", provides: [:html, :csv] do
    splat_to_params(params)

    scores = filter_by_keys(Score.order("starting_time DESC"), [:skater_name, :category, :segment, :nation, :competition_name])
    components = Component.joins(:score).merge(scores).order("starting_time DESC")
    number = params[:component_number].to_i
    components = components.where(number: number) if number >= 1
    
    case content_type
    when :csv
      header = [:skater, :competition_name, :category, :segment, :date,
                :number, :component, :factor, :judges, :value]
      records = components.map do |c|
        [c.score.skater_name, c.score.competition_name,
         c.score.category, c.score.segment, c.score.starting_time.try(:strftime, "%Y-%m-%d"),
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
