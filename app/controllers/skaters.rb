ScoreViewer::App.controllers :skaters do
  ## show
  get :id, with: :id do
    id = params[:id]
    if skater = Skater.find_by(id: params[:id])
      render :"skaters/show", locals: {skater: skater}
    else
      render :record_not_found
    end
  end
  get :name, with: :name do
    if skater = Skater.find_by(name: params[:name])
      render :"skaters/show", locals: {skater: skater}
    else
      render :record_not_found
    end
  end

  ## list
  get :index do
    redirect url_for(:skaters, :list)
  end
  get :list, map: "/skaters/list/*" do
    splat_to_params(params)
    render :"skaters/index", locals: {skaters: filter(Skater.order("name"))}    
  end

  post :list do
    redirect url_for(:skaters, :list, params_to_query(params))
  end
end
