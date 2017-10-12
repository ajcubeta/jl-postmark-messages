require "test_helper"

describe MessageDetailEvent do
  let(:message_detail_event) { MessageDetailEvent.new }

  it "must be valid" do
    value(message_detail_event).must_be :valid?
  end
end
