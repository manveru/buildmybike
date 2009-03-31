module Shop
  class Controller < Ramaze::Controller
    layout :default
    trait :app => :shop
    helper :form, :xhtml, :formatting
  end
end

require 'controller/main'
