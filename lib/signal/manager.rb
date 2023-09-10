module Signal
  module Manager
    def self.update_in_progress?
      @@update_in_progress ||= false
    end

    def self.call_stack
      @@call_stack ||= []
    end

    def self.updated_observables
      @@updated_observables ||= Set.new
    end

    def self.start_update
      @@update_in_progress = true
    end

    def self.finish_update
      @@update_in_progress = false
      begin
        updated_observables.each do |observable|
          observable._update_observers
        end
      ensure
        updated_observables.clear
      end
    end
  end
end
