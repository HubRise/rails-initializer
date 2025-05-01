# frozen_string_literal: true
class MockTcpServer
  attr_reader :received_messages

  def initialize(_host, _port)
    reset!

    @server = TCPServer.new("127.0.0.1", 24225)
    @clients = []
    @thread = Thread.new { accept_loop }

    sleep(0.2) # give the server a moment to bind
  end

  def shutdown
    @server&.close
    @thread&.kill&.join
  end

  def reset!
    @received_messages = []
    @paused = false
  end

  # Stop reading, keep the socket open
  def pause!
    @paused = true
  end

  # Close every active client socket (simulates crash)
  def drop_connections!
    @clients.each do |c|
      puts "Closing client connection: #{c}"
      c.close
    rescue
      nil
    end
    @clients.clear
  end

  private

  def accept_loop
    loop do
      client = @server.accept
      @clients << client
      puts "Opening client connection: #{client}"
      unpacker = MessagePack::Factory.new.unpacker(client)

      # Custom ext type (0) → Time object
      unpacker.register_type(0) do |data|
        sec, nsec = data.unpack("NN")
        Time.at(sec, nsec / 1_000.0)
      end

      unpacker.each do |record|
        sleep(0.05) while @paused
        # puts "[tcp] Received: #{record.inspect}"
        @received_messages << record
      end

    rescue EOFError, IOError, Errno::ECONNRESET
      begin
        client.close
      rescue
        nil
      end
      retry
    end
  end
end
