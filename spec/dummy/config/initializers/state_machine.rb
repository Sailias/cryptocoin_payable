module StateMachine
  module Integrations
    module ActiveModel
      alias around_validation_protected around_validation
      def around_validation(*args, &block)
        around_validation_protected(*args, &block)
      end
    end
  end
end
