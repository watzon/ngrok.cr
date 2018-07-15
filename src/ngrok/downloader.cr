require "http/client"
require "tempfile"

class Ngrok
  class Downloader
    CDN_URL        = "https://bin.equinox.io"
    CDN_PATH       = "c/4VmDzA7iaHb/ngrok-stable"
    DOWNLOAD_FILES = {
      "darwinia32"  => "darwin-386.zip",
      "darwinx64"   => "darwin-amd64.zip",
      "linuxarm"    => "linux-arm.zip",
      "linuxarm64"  => "linux-arm64.zip",
      "linuxia32"   => "linux-386.zip",
      "linuxx64"    => "linux-amd64.zip",
      "win32"       => "windows-386.zip",
      "win64"       => "windows-amd64.zip",
      "freebsdx64"  => "freebsd-amd64.zip",
      "freebsdia32" => "freebsd-386.zip",
    }

    def initialize(@cdn_url = CDN_URL, @cdn_path = CDN_PATH, @bin_path = "./bin")
      Dir.mkdir(@bin_path) unless Dir.exists?(@bin_path)
    end

    def binary_path
      ext = case current_platform
            when .includes?("win")
              ".exe"
            else
              ""
            end

      File.join(@bin_path, "ngrok" + ext)
    end

    def download!
      return if File.exists?(binary_path)

      url = download_url(current_platform)

      HTTP::Client.get(url) do |response|
        response.consume_body_io
        tempfile = Tempfile.open("ngrok-#{current_platform}", ".zip") do |file|
          file.puts response.body
        end
        Zip::File.open(tempfile.path) do |zip|
          zip.extract_all(@bin_path, 0x7777)
        end
        # tempfile.unlink # crystal 0.24
        tempfile.delete # crystal 0.25
      end
    end

    private def download_url(platform)
      File.join(@cdn_url, @cdn_path + "-" + download_file_name(platform))
    end

    private def download_file_name(platform)
      DOWNLOAD_FILES[platform]
    end

    private def current_platform
      {% if flag?(:linux) && flag?(:arm) %}
        {% if flag?(:i686) %}
          "linuxarm64"
        {% else %}
          "linuxarm"
        {% end %}
      {% elsif flag?(:linux) %}
        {% if flag?(:i686) %}
          "linuxx64"
        {% else %}
          "linuxia32"
        {% end %}
      {% elsif flag?(:darwin) %}
        {% if flag?(:i686) %}
          "darwinx64"
        {% else %}
          "darwinia32"
        {% end %}
      {% elsif flag?(:freebsd) %}
        {% if flag?(:i686) %}
          "freebsdx64"
        {% else %}
          "freebsdia32"
        {% end %}
      {% elsif flag?(:win32) %}
        "win32ia32"
      {% elsif flag?(:win64) %}
        "win32x64"
      {% else %}
        raise "Unsupported platform"
      {% end %}
    end
  end
end
