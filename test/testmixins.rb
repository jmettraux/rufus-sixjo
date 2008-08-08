
#
# Testing rufus-sixjo
#
# jmettraux at gmail.org
#
# Fri Aug  8 18:01:29 JST 2008
#

require 'rubygems'
require 'rufus/sixjo'


module SixjoTestMixin

  [ :post, :get, :put, :delete ].each do |v|
    module_eval <<-EOS
      def #{v} (path, options={})
        @response = Rack::MockRequest.new(@app).#{v}(path, options)
        @response
      end
    EOS
  end
end

