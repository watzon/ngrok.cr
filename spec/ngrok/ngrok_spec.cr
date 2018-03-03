require "../spec_helper"

describe Ngrok do
  describe ".initialize" do
    it "initializes with default params" do
      ngrok = Ngrok.new
      expect(ngrok.params).to eq(Ngrok::DEFAULTS)
    end

    it "merges included params with defaults" do
      params = {
        addr:    "127.0.0.1:9999",
        inspect: true,
      }
      ngrok = Ngrok.new(params)
      expect(ngrok.params).to eq(Ngrok::DEFAULTS.merge(params))
    end
  end

  describe ".start" do
    context "with block" do
      it "starts a new ngrok instance with default params" do
        Ngrok.start do |ngrok|
          expect(ngrok.params).to eq(Ngrok::DEFAULTS)
          expect(ngrok.ngrok_url).to be_a String
          expect(ngrok.ngrok_url_https).to be_a String
          expect(ngrok.running?).to be_true
        end
      end

      it "starts a new ngrok instance with a different local address" do
        Ngrok.start({addr: "127.0.0.1:9999"}) do |ngrok|
          expect(ngrok.addr).to eq("127.0.0.1:9999")
          expect(ngrok.running?).to be_true
        end
      end
    end

    context "without block" do
      it "starts a new ngrok instance with default params" do
        ngrok = Ngrok.start
        expect(ngrok.params).to eq(Ngrok::DEFAULTS)
        expect(ngrok.ngrok_url).not_to be_nil
        expect(ngrok.ngrok_url_https).not_to be_nil
        expect(ngrok.running?).to be_true
      end

      it "starts a new ngrok instance with a different local address" do
        ngrok = Ngrok.start({addr: "127.0.0.1:9999"})
        expect(ngrok.addr).to eq("127.0.0.1:9999")
        expect(ngrok.running?).to be_true
      end
    end
  end

  describe "#stop" do
    it "stops a running ngrok instance" do
      ngrok = Ngrok.start
      expect(ngrok.running?).to be_true
      ngrok.stop
      expect(ngrok.stopped?).to be_true
    end
  end
end
