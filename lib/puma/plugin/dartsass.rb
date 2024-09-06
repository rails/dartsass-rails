require "dartsass/runner"
require "puma/plugin"

Puma::Plugin.create do
  attr_reader :puma_pid, :dartsass_pid, :log_writer

  def start(launcher)
    @log_writer = launcher.log_writer
    @puma_pid = $$
    @dartsass_pid = fork do
      Thread.new { monitor_puma }
      # Using IO.popen(command, 'r+') will avoid watch_command read from $stdin.
      # If we use system(*command) instead, IRB and Debug can't read from $stdin
      # correctly bacause some keystrokes will be taken by watch_command.
      IO.popen(Dartsass::Runner.dartsass_watch_command, 'r+') do |io|
        IO.copy_stream(io, $stdout)
      end
    end

    launcher.events.on_stopped { stop_dartsass }

    in_background do
      monitor_dartsass
    end
  end

  private
    def stop_dartsass
      Process.waitpid(dartsass_pid, Process::WNOHANG)
      log "Stopping dartsass..."
      Process.kill(:INT, dartsass_pid) if dartsass_pid
      Process.wait(dartsass_pid)
    rescue Errno::ECHILD, Errno::ESRCH
    end

    def monitor_puma
      monitor(:puma_dead?, "Detected Puma has gone away, stopping dartsass...")
    end

    def monitor_dartsass
      monitor(:dartsass_dead?, "Detected dartsass has gone away, stopping Puma...")
    end

    def monitor(process_dead, message)
      loop do
        if send(process_dead)
          log message
          Process.kill(:INT, $$)
          break
        end
        sleep 2
      end
    end

    def dartsass_dead?
      Process.waitpid(dartsass_pid, Process::WNOHANG)
      false
    rescue Errno::ECHILD, Errno::ESRCH
      true
    end

    def puma_dead?
      Process.ppid != puma_pid
    end

    def log(...)
      log_writer.log(...)
    end
end
