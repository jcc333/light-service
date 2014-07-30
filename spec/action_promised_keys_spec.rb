require 'spec_helper'
require 'test_doubles'

module LightService
  describe ":promises macro" do

    context "when the promised key is not in the context" do
      it "raises an ArgumentError" do
        class TestDoubles::KeysToPromiseAction
          executed do |context|
            context[:some_tea] = "#{context.tea} - #{context.milk}"
          end
        end

        exception_error_text = "promised :milk_tea to be in the context during TestDoubles::KeysToPromiseAction"
        expect {
          TestDoubles::KeysToPromiseAction.execute(:tea => "black", :milk => "full cream")
        }.to raise_error(PromisedKeysNotInContextError, exception_error_text)
      end

      it "can fail the context without fulfilling its promise" do
        class TestDoubles::KeysToPromiseAction
          executed do |context|
            context.fail!("Sorry, something bad has happened.")
          end
        end

        result_context = TestDoubles::KeysToPromiseAction.execute(:tea => "black",
                                                             :milk => "full cream")

        expect(result_context).to be_failure
        expect(result_context.keys).not_to include(:milk_tea)
      end
    end

    context "when the promised key is in the context" do
      it "can be set with an actual value" do
        class TestDoubles::KeysToPromiseAction
          executed do |context|
            context.milk_tea = "#{context.tea} - #{context.milk}"
            context.milk_tea += " hello"
          end
        end

        result_context = TestDoubles::KeysToPromiseAction.execute(:tea => "black",
                                                             :milk => "full cream")
        expect(result_context).to be_success
        expect(result_context[:milk_tea]).to eq("black - full cream hello")
      end

      it "can be set with nil" do
        class TestDoubles::KeysToPromiseAction
          executed do |context|
            context.milk_tea = nil
          end
        end
        result_context = TestDoubles::KeysToPromiseAction.execute(:tea => "black",
                                                             :milk => "full cream")
        expect(result_context).to be_success
        expect(result_context[:milk_tea]).to be_nil
      end
    end

    it "can collect promised keys when the `promised` macro is called multiple times" do
      resulting_context = TestDoubles::MultiplePromisesAction.execute(:coffee => "espresso")

      expect(resulting_context.cappuccino).to eq("Cappucino needs espresso and a little milk")
      expect(resulting_context.latte).to eq("Latte needs espresso and a lot of milk")
    end

  end
end
