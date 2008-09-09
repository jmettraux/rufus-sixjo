#
#--
# Copyright (c) 2008, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#++
#

#
# "made in Japan"
#

require 'erb'
require 'rack'

require 'time'
require 'date'


class Rack::Request

  #
  # not sure about this one, might vanish soon
  #
  def content
    @env['rack.request.form_vars']
  end

  #
  # returns an array of ETags
  #
  def etags
    (@env['HTTP_IF_NONE_MATCH'] || '').split(/\s*,\s*/)
  end
end

class Rack::Response

  def location= (l)
    header['Location'] = l
  end
  def content_type= (t)
    header['Content-type'] = t
  end
end


module Rufus

  module Sixjo

    VERSION = '0.1.3'

    #
    # Sixjo's Rack app
    #
    class App

      attr_reader :environment

      def initialize (next_app, routes, helpers, configures, options)

        @next_app = next_app
        @routes = routes || [] # the 'no route' case is rather useless...
        @helpers = helpers || []

        #@prefix = options[:prefix] || ''
        #@rprefix = Regexp.new(@prefix)

        @environment = options[:environment] || 'development'
        @environment = @environment.to_s

        #
        # run the configure blocks

        (configures || []).each do |envs, block|
          instance_eval(&block) if envs.empty? or envs.include?(@environment)
        end
      end

      def application
        self
      end

      def call (env)

        block = nil

        begin
          block = lookup_block(env)
        rescue => e
          #puts e
          #puts e.backtrace
          return [ 400, {}, e.to_s ]
        end

        if block
          Context.service(self, block, @helpers, env)
        elsif @next_app
          @next_app.call(env)
        else
          [ 404, {}, [ "not found #{env['PATH_INFO']}" ] ]
        end
      end

      protected

        H_METHODS = [ 'GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS' ]
        R_METHOD = /_method=(put|delete|PUT|DELETE)/
        R_MULTIPART = /^multipart\/form-data;/

        def lookup_block (env)

          request_method = get_request_method(env)

          @routes.each do |verb, route, block|
            next unless request_method == verb
            next unless route.match?(env)
            return block
          end

          nil
        end

        def get_request_method (env)

          rm = env['X-HTTP-Method-Override'] || env['REQUEST_METHOD']
          rm = rm.upcase

          #puts env.inspect

          if rm == 'POST'

            md = R_METHOD.match(env['QUERY_STRING'])
            rm = md[1].upcase if md

            ct = env['CONTENT_TYPE']

            if ct and R_MULTIPART.match(ct)
              request = Rack::Request.new(env)
              env['_rack_request'] = request # no need to rebuild later
              hidden_method = request.POST['_method']
              rm = hidden_method.upcase if hidden_method
            end

          elsif rm == 'HEAD'

            rm = 'GET'
          end

          raise "unknown HTTP method '#{rm}'" unless H_METHODS.include?(rm)

          rm
        end
    end

    #
    # ERB views
    #
    module Erb

      #
      # a local [context] for ERB views
      #
      class Local

        def initialize (context, locals)
          @context = context
          @locals = locals
        end

        def method_missing (m, *args)

          s = m.to_sym
          return @locals[s] if @locals.has_key?(s)

          @context.send(m, *args)
        end

        #def application; @context.application; end
        #def request; @context.request; end
        #def response; @context.response; end

        def get_binding
          binding
        end
      end

      def erb (template, options = {})

        content = File.read("views/#{template}.erb")
          #
          # TODO : make views/ configurable

        l = options[:locals]
        l = Local.new(self, l || {}) unless l.is_a?(Local)

        ::ERB.new(content).result(l.get_binding)
      end
    end

    #
    # The context in which an HTTP request is handled
    #
    class Context

      include Erb

      def metaclass
        class << self
          self
        end
      end

      attr_reader :application
      attr_reader :request, :response

      def initialize (app, env)

        @application = app
        @request = env.delete('_rack_request') || Rack::Request.new(env)
        @response = Rack::Response.new

        @params = @request.params.merge(@request.env['_ROUTE_PARAMS'])
        @params = @params.inject({}) { |r, (k, v)| r[k.to_sym] = v; r }
      end

      def self.service (app, block, helpers, env)

        r = self.new(app, env)

        helpers.each { |h| r.instance_eval &h }

        r.metaclass.instance_eval { define_method :call, &block }

        begin

          caught = catch :done do
            r.response.body = r.call || []
            nil
          end

          if caught
            caught = Array(caught)
            r.response.status = caught[0]
            r.response.body = caught[1]
          end

        rescue Exception => e

          r.response.status = 500
          r.response.content_type = 'text/plain'
          r.response.body = e.to_s + "\n" + e.backtrace.join("\n")
        end

        r.response.body = [] if env['REQUEST_METHOD'] == 'HEAD'
          #
          # remove body in case of HEAD

        r.response.finish
      end

      def params
        @params
      end

      def h (text)
        Rack::Utils.escape_html(text)
      end

      def redirect (path, status=303, body=nil)
        @response.status = status
        @response.location = path
        @response.body = body || "#{status} redirecting to #{path}"
        throw :done
      end

      #
      # throws 304 as needed
      #
      def set_etag (t, weak=false)

        t = '"%s"' % t
        t = weak ? "W/#{t}" : t

        @response.header['ETag'] = t

        etags = @request.etags

        if etags.include?(t) or etags.include?('*')
          throw(:done, 304) if @request.get? or @request.head?
          throw(:done, 412) # precondition failed
        end
      end

      #
      # throws 304 as needed
      #
      def set_last_modified (t)

        t = Time.local(*t.to_a) # flatten milliseconds

        @response.header['Last-Modified'] = t.httpdate

        sin = @request.env['HTTP_IF_MODIFIED_SINCE']

        return unless sin

        # taken from the "Ruby Cookbook" by
        # Lucas Carlson and Leonard Richardson
        #
        sin = DateTime.parse(sin)
        sin = sin.new_offset(DateTime.now.offset - sin.offset)
        sin = Time.local(
          sin.year, sin.month, sin.day, sin.hour, sin.min, sin.sec, 0)

        if sin >= t
          throw(:done, 304) if @request.get? or @request.head?
          throw(:done, 412) # precondition failed
        end
      end
    end

    #
    # Wrapping all the details about route.match?(path) here...
    #
    class Route

      C_CHAR = '[^/?:,&#\.]'
      R_PARAM = /:(#{C_CHAR}+)/ # capturing route params
      R_FORMAT = /\.(#{C_CHAR}+)$/ # capturing the resource/file format

      def initialize (route, options)

        @param_keys = []

        @regex = route.gsub(R_PARAM) do
          @param_keys << $1.to_sym
          "(#{C_CHAR}+)" # ready to capture param values
        end

        @regex = /^#{@regex}(?:\.(#{C_CHAR}+))?$/

        # TODO : do something with the options :agent, :accept, ...
      end

      def match? (env)

        m = env['PATH_INFO'].match(@regex)

        return false unless m

        values = m.to_a[1..-1]
        params = @param_keys.zip(values).inject({}) { |r, (k, v)| r[k] = v; r }

        env['_ROUTE_PARAMS'] = params

        env['_FORMAT'] = values.last if values.length > @param_keys.length

        true
      end
    end

    #--
    # the methods for registering the routes
    #++
    [ :post, :get, :put, :delete ].each do |v|
      module_eval <<-EOS
        def #{v} (rt, opts={}, &blk)
          (@routes ||= []) << [ '#{v.to_s.upcase}', Route.new(rt, opts), blk ]
        end
      EOS
    end

    #
    # for example :
    #
    #   helpers do
    #     def hello
    #       "hello #{params['who']}"
    #     end
    #   end
    #
    def helpers (&block)

      (@helpers ||= []) << block
    end

    #
    # Code in the 'configure' block will be run inside the application
    # instance.
    #
    def configure (*envs, &block)

      (@configures ||= []) << [ envs.collect { |e| e.to_s }, block ]
    end

    #
    # Packages the routing info into a Rack application, suitable for
    # insertion into a Rack app chain.
    #
    # Returns an instance of Rufus::Sixjo::App
    #
    def new_sixjo_rack_app (next_app, options={})

      App.new(next_app, @routes, @helpers, @configures, options)
    end
  end
end

