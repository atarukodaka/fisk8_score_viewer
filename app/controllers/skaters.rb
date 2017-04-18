module SkatersController
  def render_html(rel)
    render :"skaters/index", locals: {skaters: rel}
  end
end

ScoreViewer::App.controllers :skaters do
  ## show
  get :id, with: :id do
    id = params[:id]
    skater = Skater.find_by(id: params[:id])
    render :"skaters/show", locals: {skater: skater}
  end
  get :name, with: :name do
    skater = Skater.find_by(name: params[:name])
    render :"skaters/show", locals: {skater: skater}
  end

  ## list
  get :index do
    redirect url_for(:skaters, :list)
  end
  get :list, map: "/skaters/list/*" do
    splat_to_params(params)
    rel = filter(Skater.order("name"))
    render :"skaters/index", locals: {skaters: rel}    
  end

  post :list do
    redirect url_for(:skaters, :list, params_to_query(params))
  end
end
