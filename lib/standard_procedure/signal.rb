# frozen_string_literal: true

module StandardProcedure
  module Signal
    require_relative "signal/version"
    require_relative "signal/manager"
    require_relative "signal/observer"
    require_relative "signal/observable"
    require_relative "signal/attribute"

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
    def self.compute(&block)
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
    def self.observe(&block)
      Observer.new(&block).call
    end

    # Batch changes to various attributes without triggering updates till the very end
    #
    # @expensive = Attribute.text "Prada"
    # @operation = Attribute.text "Hip Replacement"
    # Attribute.update do
    #   @expensive.set "Gucci"
    #   @operation.set "Brain Surgery"
    # end
    def self.update(&block)
      Signal::Manager.start_update
      begin
        block.call
      ensure
        Signal::Manager.finish_update
      end
    end
  end
end
