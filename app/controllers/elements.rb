ScoreViewer::App.controllers :elements do
  get :index do
    redirect url_for(:elements, :list)
  end
  
  get :list, map: "/elements/list/*", provides: [:csv, :html] do
    splat_to_params(params)
    scores = filter(Score.order("updated_at DESC"), [:skater_name, :category, :segment, :nation, :competition_name])

    element = params[:element]
    partial_match = params[:partial_match]
    elements = Technical.where(score_id: scores.select(:id))
    elements = 
      if params[:partial_match]
        elements.where("element like(?)", "%#{params[:element]}%")
      else
        elements.where(element: params[:element])
      end
    
    case content_type
    when :csv
      header = [:skater, :competition_name, :category, :segment,
                 :number, :component, :factor, :judges, :value]
      ret = components.map do |c|
        score = c.score
        [score.skater_name, score.competition_name, score.category, score.segment,
         c.number, c.component, c.factor, c.judges, c.value]
      end
      output_csv(header, ret, filename: "elements.csv")
    else
      render :"elements/index", locals: {elements: elements}
    end
  end

  post :list do
    params[:element].gsub!(/\+/, "%2B")
    redirect url_for(:elements, :list, params_to_query(params))
    #redirect url_for(:elements, :list, "element:1T%2B1")
  end
end
