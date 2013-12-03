require "base64"

require "rack"
require "sinatra/base"
require "sinatra/json"
require "sinatra/reloader"
require "sprockets"
require "sass"
require "coffee-script"
require "slim"

class App < Sinatra::Base
  set :root, File.expand_path("../..", __FILE__)
  set :raise_errors, true
  set :show_exceptions, true
  set :sprockets, Sprockets::Environment.new(root)
  set :precompile, [/\w+\.(?!js|css).+/, /application.(css|js)$/, "gif.worker.js"]
  set :protection, false

  configure do
    Dir["#{root}/{app,vendor}/*"].each do |path|
      sprockets.append_path(path)
    end

    sprockets.context_class.class_eval do
      def asset_path(path, options = {})
        asset = environment.find_asset(path)
        if asset
          "/assets/#{asset.digest_path}"
        else
          raise "Missing asset #{path}#{" (#{options.inspect[1...-1]})" unless options.empty?}"
        end
      end
    end
  end

  helpers Sinatra::JSON

  helpers do
    def asset_path(path)
      "/assets/#{settings.sprockets.find_asset(path).try(:digest_path)}"
    end

    def asset_data_uri(path)
      asset = settings.sprockets.find_asset(path)
      base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
      "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
    end

    def url(path)
      "#{request.scheme}://#{request.env["HTTP_HOST"]}#{path}"
    end
  end

  get "/" do
    slim :index
  end
end
