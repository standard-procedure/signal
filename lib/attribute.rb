# frozen_string_literal: true

class Attribute
  Dir["#{__dir__}/attribute/*.rb"].sort.each { |file| require file }

  # Create a new, untyped, Attribute, with the given value
  # Alternatively, you can use the class factory methods to build an attribute that automatically performs type conversions.
  # These are Attribute.text, integer, float, boolean, date, time, array, hash
  def initialize value
    @listeners = [] # contains Listeners
    set value
  end

  # Get this value converted to a string
  # @return [String]
  def to_s
    @value.to_s
  end

  # Get the value of this attribute
  #
  # This method is aliased as `get` and `read` so it can be accessed in whichever way makes most sense to you
  # The following are all equivalent:
  #     @attribute.call
  #     @attribute.get
  #     @attribute.read
  #     @attribute.()
  #
  # @return [Object]
  def call
    if (current = call_stack.last)
      @listeners << current
      current.add @listeners
    end
    @value
  end
  alias_method :get, :call
  alias_method :read, :call

  # Set the value of this attribute and notify any observers
  #
  # This method is aliased as `write` it can be used in whichever way makes most sense to you
  # The following are all equivalent:
  #     @attribute.set @new_value
  #     @attribute.write @new_value
  #
  # @param new_value [Object]
  # @return [Object]
  def set new_value
    if new_value != @value
      @value = new_value
      _update_listeners
    end
    @value
  end
  alias_method :write, :set

  # Observe this attribute
  #
  # The block will be called whenever this attribute or its dependents is updated.
  # The block handler does not require any parameters, simply access the attribute, or any other attributes and act accordingly.  If you access any dependents outside of this attribute, they will be tracked and you will be notified again when they update.
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

    # Build a `computed` attribute that automatically updates based upon its dependents
    #
    # This compound address will be updated any time any of its constituent fields is updated
    # @first_line = Attribute.text "123 Fake Street"
    # @second_line = Attribute.text "Some place"
    # @city = Attribute.text "Springfield"
    # @region = Attribute.text "Who Knows"
    # address = Attribute.computed do
    #   "#{first_line.get}\n#{second_line.get}\n#{city.get}\n#{region.get}"
    # end
    def compute &block
      Attribute.new(nil).tap do |attribute|
        observe { attribute.set block.call }
      end
    end

    # Build an observer that gets updated whenever any of the attributes that are accessed within the block are updated
    #
    # This API will be posted to every time the headline or contents change
    # @headline = Attribute.text "Breaking news"
    # @contents = Attribute.text "Things have happened around the world today"
    # api = Some::NewsBroadcaster.new(access_token)
    # Attribute.observe do
    #   api.post headline: @headline.get, contents: @contents.get
    # end
    def observe &block
      Listener.new(&block).call
    end

    # Batch changes to various attributes without triggering updates till the very end
    #
    # @expensive = Attribute.text "Prada"
    # @operation = Attribute.text "Hip Replacement"
    # Attribute.update do
    #   @expensive.set "Gucci"
    #   @operation.set "Brain Surgery"
    # end
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
