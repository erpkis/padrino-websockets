module Padrino
  module WebSockets
    module Faye
      class EventManager < BaseEventManager
      include Helpers
        def initialize(channel, user, ws, event_context, &block)
          ws.on :open do |event|
            self.on_open event #&method(:on_open)
          end
          ws.on :message do |event|
            self.on_message event.data, @ws
          end
          ws.on :close do |event|
            self.on_shutdown event # method(:on_shutdown)
          end

          super channel, user, ws, event_context, &block
        end

        ##
        # Manage the WebSocket's connection being closed.
        #
        def on_shutdown(event)
          @pinger.cancel if @pinger
          super
        end

        ##
        # Write a message to the WebSocket.
        #
        def self.write(message, ws, serialize = true)
          if serialize 
            ws.send ::Oj.dump(message)
          else
            ws.send message
          end
        end

        def send_message(message, serialize = true)
          Padrino::WebSockets::Faye::EventManager.send_message(@channel,@user,message,serialize)
       end

        protected
          ##
          # Maintain the connection if ping frames are supported
          #
          def on_open(event)
            super event

            @ws.ping('pong')
          end
      end
    end
  end
end
