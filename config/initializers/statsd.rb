STATSD = Statsd.new("localhost", 8125)
STATSD.namespace = "api.#{Rails.env}"