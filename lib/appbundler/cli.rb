require 'appbundler/version'
require 'appbundler/app'

module Appbundler
  class CLI

    def self.run(argv)
      cli = new(argv)
      cli.validate!
      cli.run
    end

    attr_reader :argv

    attr_reader :app_path
    attr_reader :bin_path

    def initialize(argv)
      @argv = argv
    end

    def validate!
      if argv.any? {|arg| %w{-h --help help -v --version}.include?(arg) }
        $stdout.print(usage)
        exit 0
      elsif argv.size != 2
        usage_and_exit!
      else
        @app_path = File.expand_path(argv[0])
        @bin_path = File.expand_path(argv[1])
        verify_app_path
        verify_bin_path
      end
    end

    def verify_app_path
      if !File.directory?(app_path)
        err("APPLICATION_DIR `#{app_path}' is not a directory or doesn't exist")
        usage_and_exit!
      elsif !File.exist?(File.join(app_path, "Gemfile.lock"))
        err("APPLICATION_DIR does not contain require Gemfile.lock")
        usage_and_exit!
      end
    end

    def verify_bin_path
      if !File.directory?(bin_path)
        err("BINSTUB_DIR `#{bin_path}' is not a directory or doesn't exist")
        usage_and_exit!
      end
    end

    def run
      created_stubs = App.new(app_path, bin_path).write_executable_stubs
      created_stubs.each do |real_executable_path, stub_path|
        $stdout.puts "Generated binstub #{stub_path} => #{real_executable_path}"
      end
    end

    def err(message)
      $stderr.print("#{message}\n")
    end

    def usage_and_exit!
      err(usage)
      exit 1
    end

    def usage
      <<-E
Usage: appbundler APPLICATION_DIR BINSTUB_DIR

  APPLICATION_DIR is the root directory of your app
  BINSTUB_DIR is the directory where you want generated executables to be written
E
    end

  end
end
