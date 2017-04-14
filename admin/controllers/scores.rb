ScoreViewer::Admin.controllers :scores do
  get :index do
    @title = "Scores"
    @scores = Score.all
    render 'scores/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'score')
    @score = Score.new
    render 'scores/new'
  end

  post :create do
    @score = Score.new(params[:score])
    if @score.save
      @title = pat(:create_title, :model => "score #{@score.id}")
      flash[:success] = pat(:create_success, :model => 'Score')
      params[:save_and_continue] ? redirect(url(:scores, :index)) : redirect(url(:scores, :edit, :id => @score.id))
    else
      @title = pat(:create_title, :model => 'score')
      flash.now[:error] = pat(:create_error, :model => 'score')
      render 'scores/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "score #{params[:id]}")
    @score = Score.find(params[:id])
    if @score
      render 'scores/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'score', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "score #{params[:id]}")
    @score = Score.find(params[:id])
    if @score
      if @score.update_attributes(params[:score])
        flash[:success] = pat(:update_success, :model => 'Score', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:scores, :index)) :
          redirect(url(:scores, :edit, :id => @score.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'score')
        render 'scores/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'score', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Scores"
    score = Score.find(params[:id])
    if score
      if score.destroy
        flash[:success] = pat(:delete_success, :model => 'Score', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'score')
      end
      redirect url(:scores, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'score', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Scores"
    unless params[:score_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'score')
      redirect(url(:scores, :index))
    end
    ids = params[:score_ids].split(',').map(&:strip)
    scores = Score.find(ids)
    
    if Score.destroy scores
    
      flash[:success] = pat(:destroy_many_success, :model => 'Scores', :ids => "#{ids.join(', ')}")
    end
    redirect url(:scores, :index)
  end
end
