ScoreViewer::Admin.controllers :technicals do
  get :index do
    @title = "Technicals"
    @technicals = Technical.all
    render 'technicals/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'technical')
    @technical = Technical.new
    render 'technicals/new'
  end

  post :create do
    @technical = Technical.new(params[:technical])
    if @technical.save
      @title = pat(:create_title, :model => "technical #{@technical.id}")
      flash[:success] = pat(:create_success, :model => 'Technical')
      params[:save_and_continue] ? redirect(url(:technicals, :index)) : redirect(url(:technicals, :edit, :id => @technical.id))
    else
      @title = pat(:create_title, :model => 'technical')
      flash.now[:error] = pat(:create_error, :model => 'technical')
      render 'technicals/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "technical #{params[:id]}")
    @technical = Technical.find(params[:id])
    if @technical
      render 'technicals/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'technical', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "technical #{params[:id]}")
    @technical = Technical.find(params[:id])
    if @technical
      if @technical.update_attributes(params[:technical])
        flash[:success] = pat(:update_success, :model => 'Technical', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:technicals, :index)) :
          redirect(url(:technicals, :edit, :id => @technical.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'technical')
        render 'technicals/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'technical', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Technicals"
    technical = Technical.find(params[:id])
    if technical
      if technical.destroy
        flash[:success] = pat(:delete_success, :model => 'Technical', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'technical')
      end
      redirect url(:technicals, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'technical', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Technicals"
    unless params[:technical_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'technical')
      redirect(url(:technicals, :index))
    end
    ids = params[:technical_ids].split(',').map(&:strip)
    technicals = Technical.find(ids)
    
    if Technical.destroy technicals
    
      flash[:success] = pat(:destroy_many_success, :model => 'Technicals', :ids => "#{ids.join(', ')}")
    end
    redirect url(:technicals, :index)
  end
end
