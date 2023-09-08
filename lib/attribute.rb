# frozen_string_literal: true

class Attribute
  Dir["#{__dir__}/attribute/*.rb"].sort.each { |file| require file }

  def initialize value
    @listeners = [] # contains Listeners
    set value
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
    if new_value != @value
      @value = new_value
      _update_listeners
    end
    @value
  end
  alias_method :write, :set

  def observe &block
    Attribute.observe(&block)
  end

  def _update_listeners
    if update_in_progress?
      updated_attributes.add self
    else
      @listeners.each do |listener|
        listener.call
      end
    end
  end

  class << self
    %i[text integer float date time boolean].each do |type|
      class_name = "Attribute::#{type.to_s.capitalize}"
      define_method type do |value|
        const_get(class_name).new value
      end
    end

    def compute &block
      Attribute.new(nil).tap do |attribute|
        observe { attribute.set block.call }
      end
    end

    def observe &block
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
end
