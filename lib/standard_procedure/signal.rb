# frozen_string_literal: true

module StandardProcedure
  module Signal
    require_relative "signal/version"
    require_relative "signal/manager"
    require_relative "signal/observer"
    require_relative "signal/observable"
    require_relative "signal/attribute"

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
      StandardProcedure::Signal::Attribute.new(nil).tap do |attribute|
        observe { attribute.set block.call }
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

    # Build an attribute that signals its changes to dependents
    # See StandardProcedure::Signal::Attribute for the different types available
    #
    # include StandardProcedure::Signal
    # @name = attribute.text "Alice"
    # @age = attribute.integer 23
    # @colours = attribute.array %w[red green blue]
    # @object = attribute.new @some_object
    def attribute
      StandardProcedure::Signal::Attribute
    end
  end
end
