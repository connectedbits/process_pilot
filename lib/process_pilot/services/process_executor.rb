# frozen_string_literal: true

module ProcessPilot
  module Services
    module ProcessExecutor

      def execute_process(*args, env: nil, stdin: nil)
        command = args.shelljoin

        process_env = env || {}
        process_env["PATH"] ||= ENV["PATH"]
        process_env["NODE_PATH"] ||= ENV["NODE_PATH"]

        # The redirection of err to the STDERR of the owning process is to allow the
        # caller process to have a chance to display any extra information emitted via STDERR
        #
        # We also specifically drop any env vars that are not indicated by the caller
        # since we likely do not want to bleed any external information into the JS process
        stdout = String.new
        IO.popen(process_env, command, "r+", unsetenv_others: true, err: STDERR) do |io|
          io.write(stdin) if stdin != nil
          io.close_write
          stdout += io.read.chomp until io.eof?
        end

        status = $?
        if status.success?
          stdout
        else
          raise "#{command} failed, #{status}: #{stdout || "No output"}"
        end
      end

      def execute_json_process(...)
        JSON.parse(execute_process(...))
      end
    end
  end
end
