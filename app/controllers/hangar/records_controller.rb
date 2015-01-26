module Hangar
  class RecordsController < ActionController::Base
    def delete
      DatabaseCleaner.clean_with Hangar.clean_strategy, except: Hangar.do_not_delete
      render nothing: true, status: :no_content
    end
  end
end
