require_relative 'hash_with_indifferent_access'
require_relative 'hash_serializer'

module Simple
end

class Simple::Hash < Simple::HashWithIndifferentAccess
  VERSION = "1.1.1"

  def method_missing(method_name, *args, &block)
    if keys.map(&:to_s).include?(method_name.to_s) && args.empty? && block.nil?
      fetch(method_name)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    keys.map(&:to_s).include?(method_name.to_s) || super
  end

  def methods
    super + keys.map(&:to_sym)
  end

  protected

  def convert_value(value, options = {})
    if value.is_a?(Hash)
      Simple::Hash.new(value).freeze
    elsif value.is_a?(Array)
      value.map { |val| convert_value(val, options) }
    else
      value
    end
  end
end
