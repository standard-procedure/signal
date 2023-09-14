# frozen_string_literal: true

module StandardProcedure
  module Signal
    require_relative "signal/version"
    require_relative "signal/manager"
    require_relative "signal/observer"
    require_relative "signal/observable"
    require_relative "signal/attribute"
    require_relative "signal/signal_extensions"

    # Build a "computed" attribute that automatically updates based upon its dependents
    #
    # This compound address will be updated any time any of its constituent fields is updated
    #
    # include StandardProcedure::Signal
    # @first_line = attribute.text "123 Fake Street"
    # @second_line = attribute.text "Some place"
    # @city = attribute.text "Springfield"
    # @region = attribute.text "Who Knows"
    # address = compute do
    #   "#{first_line.get}\n#{second_line.get}\n#{city.get}\n#{region.get}"
    # end
    def compute(&block)
      attribute(nil).tap do |a|
        observe { a.set block.call }
      end
    end

    # Build an observer that gets updated whenever any of the attributes that are accessed within the block are updated
    #
    # This API will be posted to every time the headline or contents change
    #
    # include StandardProcedure::Signal
    # @headline = attribute.text "Breaking news"
    # @contents = attribute.text "Things have happened around the world today"
    # api = Some::NewsBroadcaster.new(access_token)
    # observe do
    #   api.post headline: @headline.get, contents: @contents.get
    # end
    def observe(&block)
      StandardProcedure::Signal::Observer.new(&block).call
    end

    # Batch changes to various attributes without triggering updates till the very end
    #
    # include StandardProcedure::Signal
    # @expensive = attribute.text "Prada"
    # @operation = attribute.text "Hip Replacement"
    # update do
    #   @expensive.set "Gucci"
    #   @operation.set "Brain Surgery"
    # end
    def update(&block)
      StandardProcedure::Signal::Manager.start_update
      begin
        block.call
      ensure
        StandardProcedure::Signal::Manager.finish_update
      end
    end

    # Shortcut method to build an attribute that signals its changes to dependents
    #
    # There are also helpers for the various types of Attribute - see StandardProcedure::Signal::Attribute::TYPES
    #
    # include StandardProcedure::Signal
    # @object = attribute @some_object
    # @name = text_attribute "Alice"
    # @age = integer_attribute 23
    # @colours = array_attribute %w[red green blue]
    def attribute value
      StandardProcedure::Signal::Attribute.new value
    end

    class_eval do
      StandardProcedure::Signal::Attribute::TYPES.each do |type|
        define_method :"#{type}_attribute" do |value|
          StandardProcedure::Signal::Attribute.send type, value
        end
      end
    end
  end
end

def Signal
  StandardProcedure::Signal
end
