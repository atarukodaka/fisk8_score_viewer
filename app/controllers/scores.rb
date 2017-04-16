ScoreViewer::App.controllers :scores do

  limit = 20

  get :index do
    mp = max_pages(Score.count, limit)
    scores = scores.limit(limit)
    render "scores/index".to_sym, layout: "layout", locals: {scores: scores, page: 1, max_pages: mp }
  end
  
  get :search do
    redirect url_for(:scores, :index)
=begin
    scores = Score.order("date DESC")
    if params[:skater_name].presence
      scores = scores.where(skater_name: params[:skater_name])
    end
    if params[:category].presence
      scores = scores.where(category: params[:category])
    end
    if params[:segment].presence
      scores = scores.where(segment: params[:segment])
    end
    if params[:nation].presence
      scores = scores.where(nation: params[:nation])
    end
    if params[:competition].presence
      scores = scores.where(competition_name: params[:competition])
    end
      page = params[:pages] || 1
      mp = max_pages(scores.count, limit)
      scores = scores.limit(limit).offset((page-1)*limit)
      
      render "scores/index".to_sym, layout: :layout, locals: {scores: scores, page: page, max_pages: mp}
=end
  end
  
  
  get :page, with: :page do
    mp = max_pages(Score.count, limit)
    
    scores = Score.limit(limit).offset((page-1)*limit)    
    page = params[:page].to_i

    render "scores/index".to_sym, layout: "layout", locals: {scores: scores, page: page, max_pages: mp}
  end
  
  get :id, with: :id do
    render "scores/show".to_sym, layout: "layout", locals: {score: Score.find_by(id: params[:id])}
  end

  post :search do
    scores = Score.order("date DESC")
    if params[:skater_name].presence
      scores = scores.where(skater_name: params[:skater_name])
    end
    if params[:category].presence
      scores = scores.where(category: params[:category])
    end
    if params[:segment].presence
      scores = scores.where(segment: params[:segment])
    end
    if params[:nation].presence
      scores = scores.where(nation: params[:nation])
    end
    if params[:competition].presence
      scores = scores.where(competition_name: params[:competition])
    end
  
    ## output format
    case params[:format]
    when "json"
      content_type 'application/json'
      scores.to_a.map {|s| s.as_json}.join('')
    when "csv"
      require 'csv'
      content_type 'text/plain'
      header = [:id, :skater, :nation, :competition_name, :category, :segment,
         :date, :rank, :starting_number, :tss, :tes, :pcs, :deductions].to_csv

      ret = scores.to_a.map {|s|
        [s.id, s.skater, s.nation, s.competition_name, s.category, s.segment,
         s.date, s.rank, s.starting_number, s.tss, s.tes, s.pcs, s.deductions].to_csv
      }.join('')
      [header, ret].flatten.join('')
    else
      page = params[:pages] || 1
      mp = max_pages(scores.count, limit)
      scores = scores.limit(limit).offset((page-1)*limit)
      
      render "scores/index".to_sym, layout: :layout, locals: {scores: scores, page: page, max_pages: mp}
    end
  end
end
