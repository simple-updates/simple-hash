require "minitest/autorun"
require_relative '../../lib/simple/hash'

class TestSimpleHash < Minitest::Test
  extend MiniTest::Spec::DSL

  @@counter = 0

  def self.it(&block)
    @@counter += 1

    define_method("test_#{@@counter}", &block)
  end

  def assert_nothing_raised(&block)
    error = nil

    begin
      block.call
    rescue => e
      error = e
      puts e.message
      puts e.backtrace
    end

    assert_nil(error)
  end

  def assert_raises_message(message, &block)
    error = nil

    begin
      block.call
    rescue => e
      error = e
    end

    assert_includes(error&.message.to_s, message)
  end

  before do
    @data = { a: 1, b: [{ c: { d: 2 } }, { e: 3 }], f: { g: 4 } }
    @simple_hash = Simple::Hash[@data]
  end

  # initialize
  it { assert_nothing_raised { Simple::Hash.new(@data).b } }
  it { assert_nothing_raised { Simple::Hash[@data].b } }
  it { assert_nothing_raised { Simple::Hash[@data.to_a].b } }
  it { assert_nothing_raised { Simple::Hash[:a, 1, :b, 2].b } }
  it { assert_raises(ArgumentError) { Simple::Hash.new(:a, 1, :b, 2).b } }

  # access by method
  it { assert_equal(1, @simple_hash.a) }
  it { assert_equal(2, @simple_hash.b[0].c.d) }
  it { assert_equal(2, @simple_hash.b[0].c.d) }
  it { assert_equal(3, @simple_hash.b[1].e) }
  it { assert_equal(4, @simple_hash.f.g) }

  # raise if no method
  it { assert_raises(NoMethodError) { @simple_hash.something } }
  it { assert_raises(NoMethodError) { @simple_hash.a.something } }
  it { assert_raises(NoMethodError) { @simple_hash.b.first.something } }
  it { assert_raises(NoMethodError) { @simple_hash.b.first.c.something } }

  # access by indifferent key
  it { assert_equal(1, @simple_hash["a"]) }
  it { assert_equal(2, @simple_hash[:b][0].fetch("c").d) }
  it { assert_equal(2, @simple_hash[:b][0][:c][:d]) }
  it { assert_equal(2, @simple_hash.b[0][:c]["d"]) }
  it { assert_equal(3, @simple_hash.b[1].fetch("e")) }
  it { assert_equal(4, @simple_hash.fetch(:f).g) }

  # can get keys/values
  it { assert_equal(["a", "b", "f"], @simple_hash.keys) }
  it { assert_equal(1, @simple_hash.values.first) }
  it { assert_equal({ "g" => 4 }, @simple_hash.values.last) }

  # did you mean
  it { assert_raises_message('Did you mean?  a') { @simple_hash.aa } }
  it { assert_raises_message('Did you mean?  b') { @simple_hash.bb } }
  it { assert_raises_message('Did you mean?  d') { @simple_hash.b[0].c.dd } }

  # to_json
  it { require 'json'; assert_equal('{"a":1}', Simple::Hash[a: 1].to_json) }
  it { require 'json'; assert_equal('{"a":{"b":2}}', Simple::Hash[a: { b: 2 }].to_json) }

  # can't modify deep keys
  it { assert_raises { @simple_hash.b.first.c.merge!(d: 5) } }
end
