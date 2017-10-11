require "test_helper"

describe MessageDetail do
  let(:message_detail) { MessageDetail.new }

  it "must be valid" do
    value(message_detail).must_be :valid?
  end
end
