ScoreViewer::App.controllers :elements do
  
  get :index do
    elements = Technical.first(10)
    render "elements/index".to_sym, layout: :layout, locals: {elements: elements}


  end

  get :search do
    redirect '/elements/search'
  end
  
  post :search do
    elements =
      if params[:partial]
        Technical.where("element like(?)", "%#{params[:element]}%").to_a
      else
        Technical.where(element: params[:element]).to_a
      end
    #erb elements.join(","), layout: :layout
    case params[:format]
    when "json"
      content_type 'application/json'
      
      ret = elements.map do |e|
        e.score.as_json.merge(e.as_json)
      end
      ret.to_s
    when "csv"
      require 'csv'
      content_type 'text/csv'
      content_type "application/x-csv"
      content_type "text/plain"
      #content_disposition 'attachment; filename=hoge.csv'
      header = [:skater, :competition_name, :category, :segment,
                :number, :info, :element, :credit, :base_value, :goe, :judges, :value].to_csv
      ret = elements.map do |e|
        score = e.score
        [score.skater, score.competition_name, score.category, score.segment,
         e.number, e.info, e.element, e.credit, e.base_value, e.goe,
         e.judges, e.value].to_csv
      end
      [header, ret].flatten.join("")
    else
      render "elements/index".to_sym, layout: :layout, locals: {elements: elements}
    end
  end
end
