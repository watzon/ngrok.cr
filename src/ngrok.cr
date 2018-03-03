require "tempfile"
require "./core_extensions/*"
require "./ngrok/*"

class Ngrok
  DEFAULTS = {
    addr:                 "127.0.0.1:3001",
    subdomain:            nil,
    hostname:             nil,
    authtoken:            nil,
    timeout:              10,
    inspect:              false,
    log:                  IO::Memory.new,
    config:               nil,
    use_local_executable: true,
    ngrok_bin:            "./bin",
  }

  @params : NamedTuple(
    addr: String,
    subdomain: String?,
    hostname: String?,
    authtoken: String?,
    timeout: Int32,
    inspect: Bool,
    log: IO,
    config: String?,
    use_local_executable: Bool,
    ngrok_bin: String)

  @process : Process? = nil
  @ngrok_url : String? = nil
  @ngrok_url_https : String? = nil
  @status : Symbol = :stopped

  getter :params, :ngrok_url, :ngrok_url_https, :status

  protected setter :process, :ngrok_url, :ngrok_url_https, :status

  def initialize(params = nil)
    @params = params ? DEFAULTS.merge(params) : DEFAULTS
  end

  def self.start(params = nil)
    ngrok = new(params)
    binary = ngrok.binary_path

    if ngrok.stopped?
      process = ngrok.process = Process.new(
        command: binary,
        args: ngrok.ngrok_exec_params,
        output: ngrok.params[:log])
    end

    ngrok.status = :running
    ngrok.fetch_urls
    ngrok
  end

  def self.start(params = nil, &block)
    ngrok = self.start(params)
    yield(ngrok)
  end

  def stop
    if running? && @process
      @process.not_nil!.kill(Signal::KILL)
      @status = :stopped
    end
    @status
  end

  def running?
    @status == :running
  end

  def stopped?
    @status == :stopped
  end

  def addr
    @params[:addr]
  end

  def port
    @params[:port]
  end

  def log
    @params[:log]
  end

  def subdomain
    @params[:subdomain]
  end

  def authtoken
    @params[:authtoken]
  end

  def ngrok_exec_params
    exec_params = ["http", "-log=stdout", "-log-level=debug"]
    exec_params << "-authtoken=#{@params[:authtoken]}" if @params[:authtoken]
    exec_params << "-subdomain=#{@params[:subdomain]}" if @params[:subdomain]
    exec_params << "-hostname=#{@params[:hostname]}" if @params[:hostname]
    exec_params << "-inspect=#{@params[:inspect]}" if @params.has_key? :inspect
    exec_params << "-config=#{@params[:config]} #{@params[:addr]}" if @params[:config]
    exec_params << params[:addr] if !@params[:config]
    exec_params
  end

  def fetch_urls
    @params[:timeout].times do
      log_content = @params[:log].to_s
      result = log_content.scan(/URL:(.+)\sProto:(http|https)\s/)
      if !result.empty?
        result = result.map { |r| r.captures.reverse }.to_h
        @ngrok_url = result["http"]
        @ngrok_url_https = result["https"]
        return @ngrok_url if @ngrok_url
      end

      error = log_content.scan(/msg="command failed" err="([^"]+)"/).flatten
      unless error.empty?
        self.stop
        raise error.first.to_s
      end

      sleep 1
      @params[:log].rewind
    end
    raise "Unable to fetch external url"

    @ngrok_url
  end

  def binary_path
    if params[:use_local_executable]
      exe = Process.find_executable("ngrok")
      if exe
        exe
      else
        download_ngrok(params[:ngrok_bin])
      end
    else
      download_ngrok(params[:ngrok_bin])
    end
  end

  private def download_ngrok(bin_path)
    downloader = Downloader.new(bin_path: bin_path)
    downloader.download!
    downloader.binary_path
  end
end
