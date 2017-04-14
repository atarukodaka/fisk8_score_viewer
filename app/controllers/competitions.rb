ScoreViewer::App.controllers :competitions do
  get :index do
    competitions = Competition.order("start_date DESC").to_a
    render "competitions/index".to_sym, layout: :layout, locals: {competitions: competitions}
  end
  get :id, with: :id do
    competition = Competition.find(params[:id])
    render "competitions/show".to_sym, layout: :layout, locals: {competition: competition, scores: competition.scores.to_a}
  end

  get :id, with: [:id, :category] do
    competition = Competition.find(params[:id])
    scores = Score.where(competition_id: params[:id], category: params[:category]).to_a
    render "competitions/show".to_sym, layout: :layout, locals: {competition: competition, scores: scores}
  end

  get :id, with: [:id, :category, :segment] do
    competition = Competition.find(params[:id])
    scores = Score.where(competition_id: params[:id], category: params[:category], segment: params[:segment]).to_a
    render "competitions/show".to_sym, layout: :layout, locals: {competition: competition, scores: scores}
  end
end
