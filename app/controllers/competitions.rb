ScoreViewer::App.controllers :competitions do
  get :index do
    competitions = Competition.order("start_date DESC").to_a
    render "competitions/index".to_sym, layout: :layout, locals: {competitions: competitions}
  end
  get :id, with: :id do
    if competition = Competition.find_by(id: params[:id]).presence
      render :"competitions/show", locals: {competition: competition, scores: competition.scores}
    else
      erb "record not found"
    end
  end

  get :id, with: [:id, :category] do
    if competition = Competition.find_by(id: params[:id]).presence
      scores = competition.scores.where(category: params[:category])
      render :"competitions/show", locals: {competition: competition, scores: scores}
    else
      erb "record not found"
    end
  end

  get :id, with: [:id, :category, :segment] do
    if competition = Competition.find(params[:id]).presence
      scores = competition.scores.where(category: params[:category], segment: params[:segment])
      render :"competitions/show", locals: {competition: competition, scores: scores}
    else
      erb "record not found"
    end
  end
end
