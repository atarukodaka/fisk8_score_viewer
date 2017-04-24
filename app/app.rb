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
  end
end
