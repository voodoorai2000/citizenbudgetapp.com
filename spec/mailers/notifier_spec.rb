require "spec_helper"

describe Notifier do
  describe "thank_you" do
    let(:mail) { Notifier.thank_you }

    it "renders the headers" do
      mail.subject.should eq("Thank you")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
