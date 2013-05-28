require 'sinatra'
require "sinatra/reloader" if development?
require 'active_record'
require 'pry'

configure :development, :production do
    ActiveRecord::Base.establish_connection(
       :adapter => 'sqlite3',
       :database =>  'db/dev.sqlite3.db'
     )
end

# Quick and dirty form for testing application
#
# If building a real application you should probably
# use views:
# http://www.sinatrarb.com/intro#Views%20/%20Templates
form = <<-eos
    <form id='myForm'>
        <input class=".text" type='text' name="url">
        <input type="submit" value="Shorten">
    </form>
    <h2>Results:</h2>
    <h3 id="display"></h3>
    <script src="jquery.js"></script>

    <script type="text/javascript">
        $(function() {
            $('#myForm').submit(function() {
            $.post('/new', $("#myForm").serialize(), function(data){
                $('.text').val('');
                $('#display').html(data);
                });
            return false;
            });
    });
    </script>
eos

# Models to Access the database
# through ActiveRecord.  Define
# associations here if need be
#
# http://guides.rubyonrails.org/association_basics.html
class Link < ActiveRecord::Base
    validates :rawUrl, :shortenedUrl, {presence: true}
    validates_uniqueness_of :rawUrl
    validates_uniqueness_of :shortenedUrl
end

def hash_string string
  hash = 0
  string.split('').each do |item|
    hash = (hash<<5) + hash + item.ord
    hash = hash & hash
    hash = hash.abs
  end
  hash
end

get '/' do
    form
end

get '/jquery.js' do
    send_file 'jquery.js'
end

get '/:somenumber' do
  l = Link.where(:shortenedUrl => request.host + '/' + params[:somenumber])
  if l.size > 0
    redirect 'http://' + l.first.rawUrl
  else
    halt 404
  end
end


post '/new' do
  l = Link.where(:rawUrl => params[:url])
  if l.size > 0
    l.first.shortenedUrl
  else
     nl = Link.new(:rawUrl => params[:url], :shortenedUrl => request.host + '/' + hash_string(params[:url]).to_s)
     nl.save
     nl.shortenedUrl
  end
end



####################################################
####  Implement Routes to make the specs pass ######
####################################################
