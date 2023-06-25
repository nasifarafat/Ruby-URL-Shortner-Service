require 'sinatra'  # Import the Sinatra framework
require 'securerandom'  # Import the SecureRandom library
require 'redis'  # Import the Redis library

redis = Redis.new  # Create a new Redis client

# Handle GET requests to the root URL
get '/' do
  erb :index, locals: { short_url: nil }  # Render the index.erb file
end

# Handle POST requests to the '/shorten' URL
post '/shorten' do
  long_url = params[:long_url]  # Get the long URL from the request parameters
  substrings = ["http","https","HTTP","HTTPS"] # Condition check for HTTP

  if substrings.any? { |substring| long_url.include?(substring) }
    short_url = generate_short_url  # Generate a unique short URL
    # Store the mapping in Redis
    redis.set("url:#{short_url}", long_url)
    erb :shortened, locals: { short_url: short_url }  # Render the shortened.erb file
  else
    erb :not_found  # Render the not_found.erb file
  end
end

# Handle GET requests to the '/:short_url' URL
get '/:short_url' do
  short_url = params[:short_url]  # Get the short URL from the URL parameter
  long_url = redis.get("url:#{short_url}")  # Retrieve the long URL from Redis

  if long_url.nil?
    status 404  # Set the HTTP status code to 404 (Not Found)
    erb :not_found  # Render the not_found.erb file
  else
    redirect to(long_url)  # Redirect the user to the long URL
  end
end

# A helper method to generate a unique short URL
def generate_short_url
  SecureRandom.urlsafe_base64(8)  # Generate a random URL-safe string of length 8
end
