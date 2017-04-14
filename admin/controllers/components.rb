ScoreViewer::Admin.controllers :components do
  get :index do
    @title = "Components"
    @components = Component.all
    render 'components/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'component')
    @component = Component.new
    render 'components/new'
  end

  post :create do
    @component = Component.new(params[:component])
    if @component.save
      @title = pat(:create_title, :model => "component #{@component.id}")
      flash[:success] = pat(:create_success, :model => 'Component')
      params[:save_and_continue] ? redirect(url(:components, :index)) : redirect(url(:components, :edit, :id => @component.id))
    else
      @title = pat(:create_title, :model => 'component')
      flash.now[:error] = pat(:create_error, :model => 'component')
      render 'components/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "component #{params[:id]}")
    @component = Component.find(params[:id])
    if @component
      render 'components/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'component', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "component #{params[:id]}")
    @component = Component.find(params[:id])
    if @component
      if @component.update_attributes(params[:component])
        flash[:success] = pat(:update_success, :model => 'Component', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:components, :index)) :
          redirect(url(:components, :edit, :id => @component.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'component')
        render 'components/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'component', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Components"
    component = Component.find(params[:id])
    if component
      if component.destroy
        flash[:success] = pat(:delete_success, :model => 'Component', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'component')
      end
      redirect url(:components, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'component', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Components"
    unless params[:component_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'component')
      redirect(url(:components, :index))
    end
    ids = params[:component_ids].split(',').map(&:strip)
    components = Component.find(ids)
    
    if Component.destroy components
    
      flash[:success] = pat(:destroy_many_success, :model => 'Components', :ids => "#{ids.join(', ')}")
    end
    redirect url(:components, :index)
  end
end
