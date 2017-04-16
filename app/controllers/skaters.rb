ScoreViewer::App.controllers :skaters do
  get :index do
    redirect url_for(:skaters, :list)
  end
  get :list, map: "/skaters/list/*" do
    splat_to_params(params)
    skaters = Skater.order(:category).order(:name)
    [:category, :nation].each do |filter|
      skaters = skaters.where(filter => params[filter]) if params[filter]
    end
    render "skaters/index".to_sym, layout: :layout, locals: {skaters: skaters.to_a}
  end
             
  ####
  get :id, with: :id do
    id = params[:id]
    skater = Skater.find_by(id: params[:id])
    render :"skaters/show", locals: {skater: skater}

  end
  get :name, with: :name do
    skater = Skater.find_by(name: params[:name])
    render :"skaters/show", locals: {skater: skater }
  end

  ####
  post :list do
    redirect url_for(:skaters, :list, params_to_query(params, [:category, :nation]))
  end
end
