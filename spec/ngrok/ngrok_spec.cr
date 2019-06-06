require "../spec_helper"

describe Ngrok do
  describe ".initialize" do
    it "initializes with default params" do
      ngrok = Ngrok.new
      ngrok.params.should eq(Ngrok::DEFAULTS)
    end

    it "merges included params with defaults" do
      params = {
        addr:    "127.0.0.1:9999",
        inspect: true,
      }
      ngrok = Ngrok.new(params)
      ngrok.params.should eq(Ngrok::DEFAULTS.merge(params))
    end
  end

  describe ".start" do
    context "with block" do
      it "starts a new ngrok instance with default params" do
        Ngrok.start do |ngrok|
          ngrok.params.should eq(Ngrok::DEFAULTS)
          ngrok.ngrok_url.should be_a String
          ngrok.ngrok_url_https.should be_a String
          ngrok.running?.should be_true
        end
      end

      it "starts a new ngrok instance with a different local address" do
        Ngrok.start({addr: "127.0.0.1:9999"}) do |ngrok|
          ngrok.addr.should eq("127.0.0.1:9999")
          ngrok.running?.should be_true
        end
      end
    end

    context "without block" do
      it "starts a new ngrok instance with default params" do
        ngrok = Ngrok.start
        ngrok.params.should eq(Ngrok::DEFAULTS)
        ngrok.ngrok_url.should_not be_nil
        ngrok.ngrok_url_https.should_not be_nil
        ngrok.running?.should be_true
      end

      it "starts a new ngrok instance with a different local address" do
        ngrok = Ngrok.start({addr: "127.0.0.1:9999"})
        ngrok.addr.should eq("127.0.0.1:9999")
        ngrok.running?.should be_true
      end
    end
  end

  describe "#stop" do
    it "stops a running ngrok instance" do
      ngrok = Ngrok.start
      ngrok.running?.should be_true
      ngrok.stop
      ngrok.stopped?.should be_true
    end
  end
end
