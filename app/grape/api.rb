require "entities"
require "helpers"
require "utils"
class Api < Grape::API
  prefix "api"
  format :json
  default_error_formatter :json
  
  mount Api_v1
  
end