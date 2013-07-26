module RSpec
  module Mocks
    module AnyInstance
      # @api private
      class ExpectationChain < Chain
        def expectation_fulfilled?
          @expectation_fulfilled || constrained_to_any_of?(:never, :any_number_of_times)
        end

        def initialize(*args, &block)
          @expectation_fulfilled = false
          super
        end

        private
        def verify_invocation_order(rspec_method_name, *args, &block)
        end
      end

      # @api private
      class PositiveExpectationChain < ExpectationChain

        private

        def create_message_expectation_on(instance)
          proxy = ::RSpec::Mocks.proxy_for(instance)
          expected_from = IGNORED_BACKTRACE_LINE
          me = proxy.add_message_expectation(expected_from, *@expectation_args, &@expectation_block)
          if RSpec::Mocks.configuration.yield_receiver_to_any_instance_implementation_blocks?
            me.and_yield_receiver_to_implementation
          end

          warn_about_receiver_passing_if_necessary

          me
        end

        def invocation_order
          @invocation_order ||= {
            :with => [nil],
            :and_return => [:with, nil],
            :and_raise => [:with, nil]
          }
        end

        def warn_about_receiver_passing_if_necessary
          Kernel.warn(<<MSG
`expect_any_instance_of(...).to receive(:message) { ... }` blocks will get the
receiving instance in 3.0. please explicitly set:
`RSpec::Mocks.configuration.yield_receiver_to_any_instance_implementation_blocks = true`
in your spec helper and fix any failing specs.
MSG
          ) if RSpec::Mocks.configuration.should_warn_about_any_instance_blocks?
        end
      end
    end
  end
end

