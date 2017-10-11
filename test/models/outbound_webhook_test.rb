require "test_helper"

describe OutboundWebhook do
  let(:outbound_webhook) { OutboundWebhook.new }

  it "must be valid" do
    value(outbound_webhook).must_be :valid?
  end
end
