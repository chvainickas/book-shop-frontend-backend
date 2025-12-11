# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow requests from frontend development server and production URLs
    origins 'localhost:3001', '127.0.0.1:3001', /\Ahttp:\/\/localhost:\d+\z/, /\Ahttps:\/\/.*\.vercel\.app\z/, /\Ahttps:\/\/.*\.netlify\.app\z/

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      expose: ['Authorization']
  end
end
