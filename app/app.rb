module ScoreViewer
  class App < Padrino::Application
    use ConnectionPoolManagement
    register Padrino::Mailer
    register Padrino::Helpers
    enable :sessions

    layout :layout
    set :filter_keys, {}

    #access_logger = Logger.new(Padrino.root('log', 'access.log'))
    #access_logger
                               
    
    get :index do
      redirect url_for(:scores, :index)
    end
  end
end
