ScoreViewer::Admin.controllers :skaters do
  get :index do
    @title = "Skaters"
    @skaters = Skater.all
    render 'skaters/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'skater')
    @skater = Skater.new
    render 'skaters/new'
  end

  post :create do
    @skater = Skater.new(params[:skater])
    if @skater.save
      @title = pat(:create_title, :model => "skater #{@skater.id}")
      flash[:success] = pat(:create_success, :model => 'Skater')
      params[:save_and_continue] ? redirect(url(:skaters, :index)) : redirect(url(:skaters, :edit, :id => @skater.id))
    else
      @title = pat(:create_title, :model => 'skater')
      flash.now[:error] = pat(:create_error, :model => 'skater')
      render 'skaters/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "skater #{params[:id]}")
    @skater = Skater.find(params[:id])
    if @skater
      render 'skaters/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'skater', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "skater #{params[:id]}")
    @skater = Skater.find(params[:id])
    if @skater
      if @skater.update_attributes(params[:skater])
        flash[:success] = pat(:update_success, :model => 'Skater', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:skaters, :index)) :
          redirect(url(:skaters, :edit, :id => @skater.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'skater')
        render 'skaters/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'skater', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Skaters"
    skater = Skater.find(params[:id])
    if skater
      if skater.destroy
        flash[:success] = pat(:delete_success, :model => 'Skater', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'skater')
      end
      redirect url(:skaters, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'skater', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Skaters"
    unless params[:skater_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'skater')
      redirect(url(:skaters, :index))
    end
    ids = params[:skater_ids].split(',').map(&:strip)
    skaters = Skater.find(ids)
    
    if Skater.destroy skaters
    
      flash[:success] = pat(:destroy_many_success, :model => 'Skaters', :ids => "#{ids.join(', ')}")
    end
    redirect url(:skaters, :index)
  end
end
