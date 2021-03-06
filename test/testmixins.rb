
#
# Testing rufus-sixjo
#
# jmettraux at gmail.org
#
# Fri Aug  8 18:01:29 JST 2008
#

require 'rubygems'
require 'rufus/sixjo'

#class Rack::MockResponse
#  alias :old_init :initialize
#  def initialize (s, h, b, errors=nil)
#    puts
#    p [ :status, s ]
#    p [ :headers, h ]
#    p [ :body, b ]
#    old_init(s, h, b, errors)
#  end
#end

class NilClass
  def empty?
    true
  end
end

module SixjoTestMixin

  [ :post, :get, :put, :delete, :head ].each do |v|
    module_eval <<-EOS
      def #{v} (path, options={})
        @request = Rack::MockRequest.new(@app)
        @response = @request.request('#{v}'.upcase, path, options)
      end
    EOS
  end

  MFD_BOUNDARY = "AaB03x"

  def encode_multipart (data = {})
    ret = ""
    data.each do |key, value|
      next if value == nil or value.strip == ''
      ret << "--#{MFD_BOUNDARY}\r\n"
      ret << "Content-Disposition: form-data; name=\"#{key}\"\r\n\r\n"
      ret << value
      ret << "\r\n"
    end
    ret << "--#{MFD_BOUNDARY}--\r\n"
  end

  def save_view (filename, content)

    FileUtils.mkdir_p( File.dirname( filename ) ) unless File.exists?( File.dirname( filename ) )

    FileUtils.rm(filename) if File.exist?(filename)
    File.open(filename, 'w') { |f| f.write(content) }
  end
end

