ScoreViewer::App.controllers :components do
  get :index do
    components = Component.first(10)
    render "components/index".to_sym, layout: :layout, locals: {components: components}
  end

  get :search do
    redirect(:components, :index)
   
  end

  post :search do
    ## firs, filter by score

    scores = Score.order("date DESC")
    if params[:skater_name] && params[:skater_name] != '-'
      scores = scores.where(skater_name: params[:skater_name])
    end
    if params[:category] && params[:category] != '-'
      scores = scores.where(category: params[:category])
    end
    if params[:segment] && params[:segment] != '-'
      scores = scores.where(segment: params[:segment])
    end
    if params[:nation] && params[:nation] != '-'
      scores = scores.where(nation: params[:nation])
    end
    if params[:competition] && params[:competition] != '-'
      scores = scores.where(competition_name: params[:competition])
    end

    #components = scores.map {|score| score.components}.flatten
    components = []
    # next, filter by component number
    component_number = params[:component_number].to_i
    if component_number > 1
      components = scores.map {|score| score.components.where(number: component_number)}.flatten
    else
      components = scores.map {|score| score.components}.flatten
    end

    case params[:format]
    when 'csv'
      require 'csv'
      content_type "text/plain"
      header = [:skater, :competition_name, :category, :segment,
                :number, :component, :factor, :judges, :value].to_csv
      ret = components.map do |c|
        score = c.score
        [score.skater_name, score.competition_name, score.category, score.segment,
         c.number, c.component, c.factor, c.judges, c.value].to_csv
      end
      [header, ret].flatten.join("")
      
    else
      render "components/index".to_sym, layout: :layout, locals: {components: components}
    end
  end
end
