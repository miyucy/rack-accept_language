class Rack::AcceptLanguage
  QVALUE         = /(?:0(?:\.\d{0,3})?)|(?:1(?:\.0{0,3})?)/
  ALPHABET       = /[a-z]/i
  LANGUAGE_TAG   = /(?:#{ALPHABET}{1,8}(?:-#{ALPHABET}{1,8})*)|\*/o
  LANGUAGE_RANGE = /(#{LANGUAGE_TAG})(?:;q=(#{QVALUE}))?/o

  def initialize(app, *args, &block)
    @app = app
  end

  def call(env)
    @app.call(accept_language env)
  end

  def accept_language(env)
    env.tap{ |e| e['rack.accept_language'] = parse env['HTTP_ACCEPT_LANGUAGE'] }
  end

  def parse(hal)
    hal.to_s.scan(LANGUAGE_RANGE).inject([]) { |r, (l, q)|
      r << [l, [1 - (q || 1).to_f, -l.size, r.size]]
    }.sort_by{ |e| e[1] }.map{ |e|
      l, c = e[0].split(/-/, 2)
      c ? "#{l.downcase}-#{c.upcase}" : l.downcase
    }
  end
end
