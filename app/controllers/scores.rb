ScoreViewer::App.controllers :scores do
  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get '/example' do
  #   'Hello world!'
  # end

  limit = 20

  get :index do
    scores = Score.order("date DESC")
    mp = max_pages(scores, limit)
    scores = scores.limit(limit)
    render "scores/index".to_sym, layout: "layout", locals: {scores: scores, page: 1, max_pages: mp }
  end

  get :page, with: :page do
    page = params[:page].to_i
    scores = Score.order("date DESC")
    mp = max_pages(scores, limit)
    scores = scores.limit(limit).offset((page-1)*limit)
    render "scores/index".to_sym, layout: "layout", locals: {scores: scores, page: page, max_pages: mp}
  end
  
  get :search do
    redirect url_for(:scores, :index)
  end
  
  get :id, with: :id do
    render "scores/show".to_sym, layout: "layout", locals: {score: Score.find(params[:id])}
  end

  post :search do
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
    #scores ||= Score.order("date DESC")
  
    ####
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
      mp = max_pages(scores, limit)
      scores = scores.limit(limit).offset((page-1)*limit)
      
      render "scores/index".to_sym, layout: :layout, locals: {scores: scores, page: page, max_pages: mp}
    end
  end
end
