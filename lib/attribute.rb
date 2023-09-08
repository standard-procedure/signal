# frozen_string_literal: true

require_relative "attribute/version"

class Attribute
  def initialize value
    @value = value
    @listeners = [] # contains Listeners
  end

  def to_s
    @value.to_s
  end

  def call
    if (current = call_stack.last)
      @listeners << current
      current.add @listeners
    end
    @value
  end
  alias_method :get, :call
  alias_method :read, :call

  def set new_value
    return @value if new_value == @value
    @value = new_value
    _update_listeners
    @value
  end
  alias_method :write, :set

  def _update_listeners
    if batch_in_progress?
      updated_attributes.add self
    else
      @listeners.each do |listener|
        listener.call
      end
    end
  end

  class << self
    TYPES = {
      string: "Attribute::String",
      boolean: "Attribute::Boolean"
    }.freeze

    def types
      TYPES.keys
    end

    TYPES.each do |type, klass|
      define_method type do |value|
        Attribute.new value
      end
    end

    def compute &block
      Attribute.new(nil).tap do |attribute|
        changed do
          attribute.set block.call
        end
      end
    end

    def changed &block
      Listener.new(&block).call
    end

    def update &block
      start_update
      begin
        block.call
      ensure
        finish_update
      end
    end

    attr_reader :update_in_progress

    def _call_stack
      @call_stack ||= []
    end

    def _updated_attributes
      @updated_attributes ||= Set.new
    end

    private

    def start_update
      @update_in_progress = true
    end

    def finish_update
      @update_in_progress = false
      begin
        _updated_attributes.each do |attribute|
          attribute._update_listeners
        end
      ensure
        _updated_attributes.clear
      end
    end
  end

  private

  def call_stack
    Attribute._call_stack
  end

  def update_in_progress?
    Attribute.update_in_progress
  end

  def updated_attributes
    Attribute._updated_attributes
  end

  class Listener
    def initialize &block
      @block = block
      @listeners = Set.new # contains Sets of Listeners
    end

    def add set_of_listeners
      @listeners.add set_of_listeners
    end

    def call
      start
      begin
        @block.call
      ensure
        finish
      end
    end

    def start
      @listeners.each do |listener|
        listener.delete self
      end
      @listeners.clear
      call_stack.push self
    end

    def finish
      call_stack.pop
    end

    def call_stack
      Attribute._call_stack
    end
  end
end