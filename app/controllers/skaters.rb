ScoreViewer::App.controllers :skaters do

  settings.filter_keys[:skaters] =  [:name, :category, :nation]
  
  ## show
  get :id, with: :id do
    id = params[:id]
    if skater = Skater.find_by(id: params[:id])
      render :"skaters/show", locals: {skater: skater}
    else
      render :record_not_found, locals: {message: "no such id: #{params[:id]} in Skater"}
    end
  end

  get :name, with: :name do
    if skater = Skater.find_by(name: params[:name])
      render :"skaters/show", locals: {skater: skater}
    else
      render :record_not_found, locals: {message: "no such name: #{params[:name]} in Skater"}
    end
  end

  get :isu_number, with: :isu_number do
    if skater = Skater.find_by(isu_number: params[:isu_number])
      render :"skaters/show", locals: {skater: skater}
    else
      render :record_not_found, locals: {message: "no such isu_number: #{params[:isu_number]} in Skater"}
    end
  end
  ## list
  get :index do
    redirect url_for(:skaters, :list)
  end
  get :list, map: "/skaters/list/*", provides: [:html, :cvs] do
    splat_to_params(params)
    #skaters = filter(Skater.order(:category).order(:name), :skaters)
    skaters = filter_by_keys(Skater.order(:category).order(:name), [:category, :nation, {key: :name, match: :partial}])

    case content_type
    when :csv
      csv_keys = [:id, :name, :nation, :category, :isu_number, :birthday, :height, :club, :coach, :choreographer]
      csv_records = skaters.map {|r| csv_keys.map {|k| r[k]}}
      output_csv(csv_keys, csv_records, filename: "skaters.csv")
    else
      render :"skaters/index", locals: {skaters: skaters}
    end
  end

  post :list do
    redirect url_for(:skaters, :list, params_to_query(params, :skaters))
  end
end
