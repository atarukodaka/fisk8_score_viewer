ScoreViewer::App.controllers :competitions do
  get :index do
    competitions = Competition.order("start_date DESC").to_a
    render "competitions/index".to_sym, layout: :layout, locals: {competitions: competitions}
  end
  get :id, with: :id do
    if competition = Competition.find_by(id: params[:id])
      render :"competitions/show", locals: {competition: competition, scores: competition.scores}
    else
      render :record_not_found, locals: {message: "id: #{params[:id].to_i} in Competition"}
    end
  end

  get :id, with: [:id, :category] do
    if competition = Competition.find_by(id: params[:id])
      scores = competition.scores.where(category: params[:category])
      render :"competitions/show", locals: {competition: competition, scores: scores}
    else
      erb "record not found"
    end
  end

  get :id, with: [:id, :category, :segment] do
    if competition = Competition.find(params[:id])
      scores = competition.scores.where(category: params[:category], segment: params[:segment])
      render :"competitions/show", locals: {competition: competition, scores: scores}
    else
      erb "record not found"
    end
  end
end
