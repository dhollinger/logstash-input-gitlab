# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname

# Generate a repeating message.
#
# This plugin is intented only as an example.

class LogStash::Inputs::Gitlab < LogStash::Inputs::Base
  config_name "gitlab"

  default :codec, "plain"

  # The ip to listen on
  config :ip, :validate => :string, :default => "0.0.0.0"

  # The port to listen on
  config :port, :validate => :number, :required => true

  # Your Gitlab Application Token for the Webhook
  config :token, :validate => :string, :required => false

  # 

  # Set how frequently messages should be sent.
  #
  # The default, `1`, means send a message every second.
  config :interval, :validate => :number, :default => 1

  public
  def register
    @host = Socket.gethostname
  end # def register

  def run(queue)
    # we can abort the loop if stop? becomes true
    while !stop?
      event = LogStash::Event.new("message" => @message, "host" => @host)
      decorate(event)
      queue << event
      # because the sleep interval can be big, when shutdown happens
      # we want to be able to abort the sleep
      # Stud.stoppable_sleep will frequently evaluate the given block
      # and abort the sleep(@interval) if the return value is true
      Stud.stoppable_sleep(@interval) { stop? }
    end # loop
  end # def run

  def stop
    # nothing to do in this case so it is not necessary to define stop
    # examples of common "stop" tasks:
    #  * close sockets (unblocking blocking reads/accepts)
    #  * cleanup temporary files
    #  * terminate spawned threads
  end
end # class LogStash::Inputs::Example
