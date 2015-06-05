require 'sinatra'
require 'pg'
require 'uri'

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  redirect "/actors"
end

get '/actors' do
  actors_data = db_connection { |conn| conn.exec("SELECT name FROM actors ORDER BY name;") }

  erb :'/actors/index', locals: { actors: actors_data}
end

get '/actors/:id' do
  actor_info = db_connection { |conn| conn.exec_params("SELECT movies.title, cast_members.character FROM actors
    LEFT JOIN cast_members ON (cast_members.actor_id = actors.id)
    LEFT JOIN movies ON (movies.id = cast_members.movie_id)
    WHERE actors.name = $1;", [params['id']]) }
  erb :'actors/show', locals: { actor_info: actor_info, actor_name: params['id']}
end

get '/movies' do
  movies_data = db_connection { |conn| conn.exec("SELECT movies.title, movies.year, movies.rating, genres.name, studios.name FROM movies
    LEFT JOIN genres ON (genres.id = movies.genre_id)
    LEFT JOIN studios ON (studios.id = movies.studio_id)
    ORDER BY genres.name;") }
  erb :'/movies/index', locals: { movies: movies_data }
end

get '/movies/:id' do
  movie_info = db_connection { |conn| conn.exec_params("SELECT genres.name AS genre, studios.name AS studio, actors.name, cast_members.character FROM movies
    LEFT JOIN cast_members ON (cast_members.movie_id = movies.id)
    LEFT JOIN genres ON (genres.id = movies.genre_id)
    LEFT JOIN studios ON (studios.id = movies.studio_id)
    LEFT JOIN actors ON (actors.id = cast_members.actor_id)
    WHERE movies.title = $1;", [params['id']]) }
  erb :'movies/show', locals: { movie_info: movie_info, movie_title: params['id']}
end
