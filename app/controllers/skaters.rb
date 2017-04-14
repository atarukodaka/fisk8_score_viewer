ScoreViewer::App.controllers :skaters do
  get :index do
    skaters = Skater.order(:category).order(:name).to_a
    render "skaters/index".to_sym, layout: :layout, locals: {skaters: skaters}
    
    #skaters = Score.select(:skater_name, :nation, :category).order(:category).distinct.to_a.uniq
    #render "skaters/index".to_sym, layout: :layout, locals: {skaters: skaters}
  end
  get :search do
    redirect('/skaters')
  end
             
  ####
  get :id, with: :id do
    id = params[:id]
    skater = Skater.where(id: id).first

    render "skaters/show".to_sym, layout: :layout, locals: {skater: skater}

  end
  get :name, with: :name do
    name = params[:name]
    skater = Skater.where(name: name).first

    render "skaters/show".to_sym, layout: :layout, locals: {skater: skater }
  end

  ####
  post :search do
    name = params[:name]
    category = params[:category]
    nation = params[:nation]
    skaters = Skater.where('name like(?)', "%#{name}%")

    if category && (category != '-')
      skaters = skaters.where(category: category)
    end

    if nation && (nation != '-')
      skaters = skaters.where(nation: nation)
    end
    skaters = skaters.order(:category).order(:name)
    render "skaters/index".to_sym, layout: :layout, locals: {skaters: skaters.to_a}
  end
end
