# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*'   #Specifying what we want to allow. * means everything. 
  
      resource '*',
        headers: :any,
        expose: ["Authorization"],   #Exposing a header called "Authorization, we are specifying where the JSON web tokens are going to be included in requests and allow the devise the recognize the currently logged in user. 
        methods: [:get, :post, :put, :patch, :delete, :options, :head]
    end
  end