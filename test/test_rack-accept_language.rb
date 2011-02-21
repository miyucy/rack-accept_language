require 'helper'

class TestRackAcceptLanguage < Test::Unit::TestCase
  def setup
    @app = lambda { |env| [200, {"Content-Type" => "text/plain"}, env['rack.accept_language']] }
    @mdl = Rack::AcceptLanguage.new(@app)
    @env = {'HTTP_ACCEPT_LANGUAGE' => 'it;q=0.4,en-us, en-gb;q=0.8,en;q=0.6, de;q=2, invalid;q=1, xx;q=30,, ., .'}
  end

  def test_initialize
    assert_nothing_raised do
      Rack::AcceptLanguage.new(@app)
    end
  end

  def test_accept_language
    assert @mdl.accept_language({}).has_key? 'rack.accept_language'
  end

  def tets_app
    status, header, body = @mdl.call(@env)
    assert_equal %w[en-US en-GB en it], body
  end

  def test_parse
    assert_equal %w[da fr-FR en-GB en],
                 @mdl.parse('da, en-gb;q=0.8, en;q=0.7, FR-FR;q=0.9')
  end

  def test_parse_blank_string
    assert_equal [], @mdl.parse('')
    assert_equal [], @mdl.parse(nil)
  end

  def test_parse_sort_by_quality_value
    assert_equal %w[a b c d e f], @mdl.parse('c;q=0.7 a;q=0.9 f;q=0.4 e;q=0.5 d;q=0.6 b;q=0.8')
  end

  def test_parse_sort_by_langtag_size
    assert_equal %w[aaa bb c], @mdl.parse('c;q=0.5 bb;q=0.5 aaa;q=0.5')
  end

  def test_parse_stable_sort
    assert_equal %w[c b a x y z v], @mdl.parse('x;q=0.1 c y;q=0.1 z;q=0.1 b v;q=0.1 a')
  end

  def test_parse_sorted
    assert_equal %w[e aa bb c d], @mdl.parse('c;q=0.5, aa;q=0.5, d;q=0.4, bb;q=0.5, e')
  end
end
