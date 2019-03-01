require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'
require 'rspotify'
require 'httpclient'
require 'json'
require 'uri'
require 'net/http'

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

before 'tasks' do
  if current_user.nil?
    redirect '/'
  end
end

get '/' do
  if current_user.nil?
    @tasks = Task.none
  else
    @tasks = current_user.tasks
  end
  erb :index
end

get '/signup' do
  erb :sign_up
end

post '/signup' do
  user = User.create(
    name: params[:name],
    password: params[:password],
    password_confirmation: params[:password_confirmation]
  )
  if user.persisted?
    session[:user] = user.id
  end
  redirect '/'
end

get '/signin' do
  erb :sign_in
end

post '/signin' do
  user = User.find_by(name:params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end

get '/signout' do
  session[:user] = nil
  redirect '/'
end

get '/tasks/new' do
  erb :new
end

post 'tasks' do
  Current_user.tasks.create(title: params[:title])
  redirect '/'
end

get '/search/new' do
  erb :search
end

post '/search' do
  RSpotify.authenticate("2f93108ea1704df6bc3308631ccb32e5", "d8e6e60ba2cd40b2b7e2fc2a18a17813")
  artists = RSpotify::Artist.search (params[:artist])
  resultJSON = artists.to_json
  resultHash = JSON.parse(resultJSON)[0]['name']['']
  imageHash = JSON.parse(resultJSON)[0]['images'][0]['url']
  # @name = result[0]['name']
  @result = resultHash
  @imageurl = imageHash

  # @artists = artists
    # p artist.name
    # p artist.popularity

  # @albums = artist.albums
  # @album = albums.first
  #   p album.name
  #   p album.release_date
  #   p album.images

  # @tracks = album.tracks
  # @track = tracks.first
  #   p track.name
  #   p track.duration_ms
  #   p track.track_number
  #   p track.preview_url
erb :search_result
end