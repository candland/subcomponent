module Subcomponent
  class Railtie < ::Rails::Railtie
    initializer "subcomponent.helper" do
      ActiveSupport.on_load(:action_view) do
        include ComponentHelper
      end
    end
  end
end
