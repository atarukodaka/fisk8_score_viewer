ScoreViewer::App.controllers :elements do

  settings.filter_keys[:elements] = [:element, :partial_match, :skater_name, :category, :segment, :nation, :competition_name,]
  
  get :index do
    redirect url_for(:elements, :list)
  end
  
  get :list, map: "/elements/list/*", provides: [:html, :csv] do
    splat_to_params(params)
    scores = filter(Score.order("starting_time DESC"), :scores)

    elements = Technical.joins(:score).merge(scores).order("starting_time DESC")
    #elements = Technical.where(score_id: scores.select(:id))
    if params[:element]
      elements = 
        if params[:partial_match]
          elements.where("element like(?)", "%#{params[:element]}%")
        else
        elements.where(element: params[:element])
        end
    end
    case content_type
    when :csv
      header = [:score_id, :skater, :competition_name, :category, :segment,
                 :number, :info, :element, :credit, :base_value, :eog, :judges, :value]
      records = elements.map do |e|
        [e.score.id, e.score.skater_name, e.score.competition_name,
         e.score.category, e.score.segment,
         e.number, e.info, e.element, e.credit, e.base_value, e.goe, e.judges, e.value]
      end
      output_csv(header, records, filename: "elements.csv")
    else
      render :"elements/index", locals: {elements: elements }
    end
  end

  post :list do
    redirect url_for(:elements, :list, params_to_query(params, :elements))
  end
end
