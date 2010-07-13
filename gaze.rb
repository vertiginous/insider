require 'sinatra/base'
require 'maruku'
require 'redcloth'

class Gaze < Sinatra::Base
  set :run, true
  set :public, File.dirname(__FILE__)+'/public'

  enable :inline_templates

  configure do
    # Format options
    {:Markdown => 'maruku', :Textile => 'RedCloth'}.each do |name, gem|
      begin
        require "#{gem}"
      rescue LoadError => e
        puts <<-MSG
  To format #{name} as well:
  $ gem install #{gem}
  It is not needed though.
  MSG
      end
    end

    Dir.chdir ARGV[0] if ARGV[0]
  end

  helpers do
    def title
      "API docs"
    end

    def pages
      files = Dir.glob "public/*"
      formats = [".md", ".markdown", ".textile"]
      pages   = []
      
      files.each do |file|
        pages << file if formats.member? File.extname(file)
      end
      
      pages.map {|file| File.basename file }
    end
    
    def read(filename)
      File.read( File.join('public', filename) )
    end
  end

  get '/' do
    redirect '/pages/'
  end

  get '/pages/' do
    # If there is only one file present, serve that instantly.
    #redirect "#{pages.first}" if pages.size == 1 

    haml :pages
  end
  
  get '/pages/:page.:ext' do
    file = "#{params[:page]}.#{params[:ext]}"

    @output = case params[:ext]
    when "markdown", "md"
      Maruku.new( read file ).to_html
    when "textile"
      RedCloth.new( read file ).to_html
    else
      read file
    end
    
    haml :page
  end

  get 'old/pages/:page.:ext' do
    begin
      File.open( filename ) do |file|
        @output = case params[:ext]
                  when "markdown", "md"
                    Maruku.new(file.read).to_html
                  when "textile"
                    RedCloth.new(file.read).to_html
                  else
                    #file.read
                  end
      end
      haml :page
    rescue
      raise Sinatra::NotFound
    end
  end

  get '/stylesheet.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :stylesheet
  end
end

__END__

@@layout
!!! XML
!!!
%html
  %head
    %link{:rel => 'stylesheet', :href => '/stylesheet.css', :type => 'text/css'}
    %meta{'http-equiv' => "Content-Type", :content => "text/html; charset=utf-8"}
    %title Mendicant Student API documentation
    
  %body
    #container
      %h2{:style=>'text-transform: uppercase;'} mendicant students
    #container= yield
    #footer
      powered by
      %a{:href => 'http://github.com/ichverstehe/gaze'} gaze

@@pages
%h1 The Four W
%h2 Why
%h2 When
%h2 Who
%h1= title
%ul
  - pages.each do |page|
    %li
      %a{:href => "/pages/#{page}"}= page

@@page
%strong
  %a{:href => '/pages/'}= title
- pages.each do |page|
  %a{:href => "/pages/#{page}"}= page
%hr
~ @output

@@stylesheet
body
  :font-family "Lucida Grande", sans-serif
  :font-size 12px
  :background #f1f1f1
h1,h2,h3,h4,h5,h6
  :font-family "Helvetica", sans-serif
#container, #container2
  :width 520px
  :margin 30px auto 3px
  :padding 20px
  :background #fff
  :border 5px solid #ccc
  :-moz-border-radius 10px
  :-webkit-border-radius 10px
#footer
  :text-align center
  :color #888
  a
    :color #888
#container2
  :align center
#logo
  :position relative
  :height 2.5em
  :width 2.5em
  :float left
  :background blue
#title
  :position relative
  :margin-left 4em
  :height 1em
  :background grey
  :text-align center
  :font-size 2em