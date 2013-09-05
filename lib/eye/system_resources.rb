require 'celluloid'

class Eye::SystemResources

  # cached system resources
  class << self

    def memory(pid)
      cache.proc_mem(pid).try(:resident)
    end

    def cpu(pid)
      if cpu = cache.proc_cpu(pid)
        cpu.percent * 100
      end
    end

    def childs(parent_pid)
      if ppids = cache.ppids
        childs = []
        ppids.each { |pid, ppid| childs << pid if parent_pid == ppid }
        childs
      else
        []
      end
    end

    def start_time(pid) # unixtime
      if cpu = cache.proc_cpu(pid)
        cpu.start_time.to_i / 1000
      end
    end

    def resources(pid)
      { :memory => memory(pid),
        :cpu => cpu(pid),
        :start_time => start_time(pid),
        :pid => pid
      }
    end

    def cache
      @cache ||= Cache.new
    end
  end

  class Cache
    include Celluloid

    attr_reader :expire

    def initialize
      clear
      setup_expire
    end

    def setup_expire(expire = 5)
      @expire = expire
      @timer.cancel if @timer
      @timer = every(@expire) { clear }
    end

    def clear
      @memory = {}
      @cpu = {}
      @ppids = nil
    end

    def proc_mem(pid)
      @memory[pid] ||= Eye::Sigar.proc_mem(pid) if pid

    rescue ArgumentError # when incorrect PID
    end

    def proc_cpu(pid)
      @cpu[pid] ||= Eye::Sigar.proc_cpu(pid) if pid

    rescue ArgumentError # when incorrect PID
    end

    def ppids # slow
      @ppids ||= begin
        h = {}
        Eye::Sigar.proc_list.each do |pid|
          c = Eye::Sigar.proc_state(pid) rescue nil
          h[pid] = c.ppid if c
        end
        h
      end

    rescue ArgumentError # when incorrect PID
    end

  end

end
