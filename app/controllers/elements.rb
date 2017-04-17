ScoreViewer::App.controllers :elements do

  filter_keys = [:skater_name, :category, :segment, :nation, :competition_name, :component_number, :element, :partial_match]
  
  get :index do
    redirect url_for(:elements, :list)
  end

  get :list, map: "/elements/list/*", provides: [:json, :csv, :html] do
    splat_to_params(params)
    # first, filter by score
    scores = Score.order("updated_at DESC")
    [:skater_name, :category, :segment, :nation, :competition_name].each do |filter|
      scores = scores.where(filter => params[filter]) if params[filter]
    end

    # next, filter by component number
    element = params[:element]
    partial_match = params[:partial_match]
    elements = Technical.where(score_id: scores.select(:id))
    elements = 
      if params[:partial_match]
        elements.where("element like(?)", "%#{params[:element]}%")
      else
        elements.where(element: params[:element])
      end
    
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
      output_csv(header, ret, filename: "elements.csv")
    else
      render :"elements/index", locals: {elements: elements, filter_keys: filter_keys}
    end
  end

  post :list do
    redirect url_for(:elements, :list, params_to_query(params, filter_keys), format: params[:format])
  end
end
