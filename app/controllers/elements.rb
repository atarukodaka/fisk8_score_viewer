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
      header = [:score_id, :skater, :competition_name, :category, :segment,
                 :number, :info, :element, :credit, :base_value, :eog, :judges, :value]
      ret = elements.map do |e|
        score = e.score
        [score.id, score.skater_name, score.competition_name, score.category, score.segment,
         e.number, e.info, e.element, e.credit, e.base_value, e.goe, e.judges, e.value]
      end
      output_csv(header, ret, filename: "elements.csv")
    else
      render :"elements/index", locals: {elements: elements, score_filter_forms: score_filter_forms}
    end
  end

  post :list do
    redirect url_for(:elements, :list, params_to_query(params))
  end
end
