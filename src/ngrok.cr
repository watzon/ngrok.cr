require "log"
require "./extensions/*"
require "./ngrok/*"

class Ngrok
  Log = ::Log.for("ngrok")

  @process : Process? = nil

  @process_out : IO::Memory

  getter addr : String
  getter subdomain : String?
  getter hostname : String?
  getter timeout : Time::Span
  getter inspect : Bool
  getter region : String
  getter config : String?
  getter use_local_executable : Bool
  getter ngrok_bin : String

  getter! url : String?
  getter! url_https : String?

  getter status : Status
  private setter status

  def initialize(@addr = "127.0.0.1:3001",
                 @subdomain = nil,
                 @hostname = nil,
                 @timeout = 10.seconds,
                 @inspect = false,
                 @region = "us",
                 @config = nil,
                 @use_local_executable = true,
                 @ngrok_bin = "./bin")
    @status = :stopped
    @process_out = IO::Memory.new
  end

  def self.start(**params)
    ngrok = new(**params)
    ngrok.start
    ngrok
  end

  def self.start(**params, &block)
    ngrok = self.start(**params)
    yield(ngrok)
    ngrok
  end

  def self.auth(token, use_local_executable = true, bin_path = "./bin")
    io = IO::Memory.new
    proc = Process.run(
      self.binary_path(use_local_executable, bin_path),
      ["authtoken", token.to_s],
      output: io,
      error: io
    )
    Log.info { io.rewind.gets_to_end }
  end

  def start
    if stopped? || !@process || !@process.not_nil!.exists?
      @process = Process.new(
        command: Ngrok.binary_path(@use_local_executable, @ngrok_bin),
        args: ngrok_exec_params,
        output: @process_out,
        error: @process_out
      )
      fetch_urls
    else
      Log.warn { "Ngrok already running" }
      @process
    end
  end

  def stop
    if running?
      Log.info { "Stopping ngrok process" }
      @process.try &.signal(Signal::KILL)
      @status = :stopped
    end
    @status
  end

  def running?
    @status.running?
  end

  def stopped?
    @status.stopped?
  end

  def errored?
    @status.errored?
  end

  def ngrok_exec_params
    exec_params = ["http", "-log=stdout", "-log-level=debug"]
    exec_params << "-subdomain=#{@subdomain}" if @subdomain
    exec_params << "-hostname=#{@hostname}" if @hostname
    exec_params << "-inspect=#{@inspect}" if @inspect
    exec_params << "-region=#{@region}"
    exec_params << "-config=#{@config} #{@addr}" if @config
    exec_params << @addr if !@config
    exec_params
  end

  def fetch_urls
    start_time = Time.monotonic
    loop do
      if Time.monotonic - 10.seconds > start_time
        raise "Timeout: failed to fetch ngrok urls in time"
      end

      log_content = @process_out.rewind.gets_to_end
      http_url = log_content.match(/url=(http:\/\/.*)/)
      https_url = log_content.match(/url=(https:\/\/.*)/)

      if http_url && https_url
        @url = http_url[1]
        @url_https = https_url[1]
        return
      end

      if error = log_content.match(/msg="command failed" err="(.*)"/)
        self.stop
        self.status = Status::Errored
        raise error[1].gsub(/(\\r)?\\n/, '\n')
      end

      sleep 100.milliseconds
    end
  end

  def self.binary_path(use_local_executable = true, bin_dir = "./bin")
    if use_local_executable
      exe = Process.find_executable("ngrok")
      if exe
        exe
      else
        self.download_ngrok(bin_dir)
      end
    else
      self.download_ngrok(bin_dir)
    end
  end

  def self.download_ngrok(bin_path)
    downloader = Downloader.new(bin_path: bin_path)
    downloader.download!
    downloader.binary_path
  end

  def finalize
    stop
  end

  enum Status
    Stopped
    Running
    Errored
  end
end
