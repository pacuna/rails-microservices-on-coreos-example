class User < ActiveRecord::Base
  def comments
    require 'net/http'
    url = URI.parse("http://#{ENV['COMMENTS_SERVICE_HOST']}/comments/by_author/#{self.id}")
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http|
      http.request(req)
    }
    res.body
  end
end
