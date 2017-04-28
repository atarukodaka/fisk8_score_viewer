module ScoreViewer
  class App < Padrino::Application
    use ConnectionPoolManagement
    register Padrino::Mailer
    register Padrino::Helpers
    enable :sessions

    layout :layout
    set :filter_keys, {}

    get :index do
      redirect url_for(:scores, :list)
    end

    get :about do
      render :about
    end
  end
end
