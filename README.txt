
= 'rufus-sixjo'

== what is it ?

A 'Rack application' for RESTfully serving stuff (the RESTful last mile is up to you). Heavily Sinatra-inspired but less polished and... Well Sixjo is not a framework.


== features

Does the conditional GET thing.


== getting it

    sudo gem install -y rufus-sixjo

or download[http://rubyforge.org/frs/?group_id=4812] it from RubyForge.


== usage

see under the examples/ directory : http://github.com/jmettraux/rufus-sixjo/tree/master/examples

It goes like :

    require 'rubygems'
    require 'rufus/sixjo' # gem 'rufus-sixjo'
    
    module ExampleOne
    
      extend Rufus::Sixjo
      
      get '/toto' do
        "nada at #{request.path_info}"
      end
    end
      
    app = Rack::Builder.new do
      
      use Rack::CommonLogger
      use Rack::ShowExceptions
      run ExampleOne.new_sixjo_rack_app(nil)
    end
    
    Rack::Handler::Mongrel.run app, :Port => 2042


== dependencies

the 'rack' gem


== mailing list

On the Rufus-Ruby list[http://groups.google.com/group/rufus-ruby] :

    http://groups.google.com/group/rufus-ruby


== issue tracker

    http://rubyforge.org/tracker/?atid=18584&group_id=4812&func=browse


== source

http://github.com/jmettraux/rufus-sixjo

    git clone git://github.com/jmettraux/rufus-sixjo.git


== author

John Mettraux, jmettraux@gmail.com,
http://jmettraux.wordpress.com


== the rest of Rufus

http://rufus.rubyforge.org


== license

MIT

