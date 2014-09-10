module Controllers
  module MainAppHelper
    def main_app
      Rails.application.class.routes.url_helpers
    end
  end
end

RSpec.configure do |config|
  config.include Controllers::MainAppHelper, type: :controller
end