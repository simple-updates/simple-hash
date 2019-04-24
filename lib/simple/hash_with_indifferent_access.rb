require "active_support/core_ext/hash/keys"
require "active_support/core_ext/hash/reverse_merge"
require "active_support/core_ext/hash/except"

module Simple
end

# same as ActiveSupport::HashWithIndifferentAccess except it does deep value conversion
# https://github.com/rails/rails/blob/master/activesupport/lib/active_support/hash_with_indifferent_access.rb
class Simple::HashWithIndifferentAccess < Hash
  def extractable_options?
    true
  end

  def with_indifferent_access
    dup
  end

  def nested_under_indifferent_access
    self
  end

  def initialize(constructor = {})
    if constructor.respond_to?(:to_hash)
      super()
      update(constructor)

      hash = constructor.to_hash
      self.default = hash.default if hash.default
      self.default_proc = hash.default_proc if hash.default_proc
    else
      super(constructor)
    end
  end

  def self.[](*args)
    new.merge!(Hash[*args])
  end

  alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
  alias_method :regular_update, :update unless method_defined?(:regular_update)

  def []=(key, value)
    regular_writer(convert_key(key), convert_value(value, for: :assignment))
  end

  alias_method :store, :[]=

  def update(other_hash)
    if other_hash.is_a?(Simple::HashWithIndifferentAccess)
      super(other_hash)
    else
      other_hash.to_hash.each_pair do |key, value|
        if block_given? && key?(key)
          value = yield(convert_key(key), self[key], value)
        end
        regular_writer(convert_key(key), convert_value(value))
      end
      self
    end
  end

  alias_method :merge!, :update

  def key?(key)
    super(convert_key(key))
  end

  alias_method :include?, :key?
  alias_method :has_key?, :key?
  alias_method :member?, :key?

  def [](key)
    convert_value(super(convert_key(key)))
  end

  def assoc(key)
    convert_values(super(convert_key(key)))
  end

  def fetch(key, *extras)
    convert_value(super(convert_key(key), *extras))
  end

  def dig(*args)
    args[0] = convert_key(args[0]) if args.size > 0
    convert_value(super(*args))
  end

  def default(*args)
    super(*args.map { |arg| convert_key(arg) })
  end

  def values_at(*keys)
    convert_values(super(*keys.map { |key| convert_key(key) }))
  end

  def fetch_values(*indices, &block)
    convert_values(super(*indices.map { |key| convert_key(key) }, &block))
  end

  def dup
    self.class.new(self).tap do |new_hash|
      set_defaults(new_hash)
    end
  end

  def merge(hash, &block)
    dup.update(hash, &block)
  end

  def reverse_merge(other_hash)
    super(self.class.new(other_hash))
  end

  alias_method :with_defaults, :reverse_merge

  def reverse_merge!(other_hash)
    super(self.class.new(other_hash))
  end

  alias_method :with_defaults!, :reverse_merge!

  def replace(other_hash)
    super(self.class.new(other_hash))
  end

  def delete(key)
    super(convert_key(key))
  end

  def except(*keys)
    slice(*self.keys - keys.map { |key| convert_key(key) })
  end

  alias_method :without, :except

  def stringify_keys!; self end
  def deep_stringify_keys!; self end
  def stringify_keys; dup end
  def deep_stringify_keys; dup end
  undef :symbolize_keys!
  undef :deep_symbolize_keys!
  def symbolize_keys; to_hash.symbolize_keys! end
  alias_method :to_options, :symbolize_keys
  def deep_symbolize_keys; to_hash.deep_symbolize_keys! end
  def to_options!; self end

  def select(*args, &block)
    return to_enum(:select) unless block_given?
    dup.tap { |hash| hash.select!(*args, &block) }
  end

  def reject(*args, &block)
    return to_enum(:reject) unless block_given?
    dup.tap { |hash| hash.reject!(*args, &block) }
  end

  def transform_values(*args, &block)
    return to_enum(:transform_values) unless block_given?
    dup.tap { |hash| hash.transform_values!(*args, &block) }
  end

  def transform_keys(*args, &block)
    return to_enum(:transform_keys) unless block_given?
    dup.tap { |hash| hash.transform_keys!(*args, &block) }
  end

  def transform_keys!
    return enum_for(:transform_keys!) { size } unless block_given?
    keys.each do |key|
      self[yield(key)] = delete(key)
    end
    self
  end

  def slice(*keys)
    keys.map! { |key| convert_key(key) }
    self.class.new(super)
  end

  def slice!(*keys)
    keys.map! { |key| convert_key(key) }
    super
  end

  def compact
    dup.tap(&:compact!)
  end

  def to_hash
    _new_hash = Hash.new
    set_defaults(_new_hash)

    each do |key, value|
      _new_hash[key] = convert_value(value, for: :to_hash)
    end
    _new_hash
  end

  private

  def convert_keys(keys)
    keys.map { |key| convert_key(key) }
  end

  def convert_key(key)
    key.kind_of?(Symbol) ? key.to_s : key
  end

  def convert_values(values)
    values.map { |value| convert_value(value) }
  end

  def convert_value(value, options = {})
    if value.is_a? Hash
      if options[:for] == :to_hash
        value.to_hash
      else
        value.nested_under_indifferent_access
      end
    elsif value.is_a?(Array)
      if options[:for] != :assignment || value.frozen?
        value = value.dup
      end
      value.map! { |e| convert_value(e, options) }
    else
      value
    end
  end

  def set_defaults(target)
    if default_proc
      target.default_proc = default_proc.dup
    else
      target.default = default
    end
  end
end
