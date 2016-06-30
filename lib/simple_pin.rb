require "simple_pin/version"
require 'httparty'

module SimplePin
  class Pin
    include HTTParty
    attr_accessor :auth, :base_url

    ##
    # Create a new Pin instance
    #  key: Your Pin secret key
    #  env: The environment you want to use.
    def initialize(key = '', env = :test)
      @key = key
      env = env.to_sym
      @auth = { username: @key, password: '' }
      @base_url = if env == :live
                    'https://api.pin.net.au/1/'
                  else
                    'https://test-api.pin.net.au/1/'
                  end
    end

    ##
    # Pin error response
    ##
    class PinError < StandardError
    end

    ##
    # Create a charge given charge details and a card,
    # https://pin.net.au/docs/api/charges
    # returns: a charge object
    ##
    def create_charge(options = {})
      build_response(make_request(:post, url: 'charges', options: options))
    end

    ##
    # Creates a card given a hash of options
    # https://pin.net.au/docs/api/cards
    # returns: a card object
    ##
    def create_card(options = {})
      build_response(make_request(:post, url: 'cards', options: options))
    end

    ##
    # Create a customer given customer details and a card_token
    # https://pin.net.au/docs/api/customers
    # returns: a customer object
    ##
    def create_customer(options = {})
      build_response(make_request(:post, url: 'customers', options: options))
    end

    private

    def build_response(response)
      fail PinError, error_message(response) unless response.code == 201
      response['response']
    end

    ##
    # Sends an authenticated request to pin's server
    ##
    def make_request(method, args)
      @args = args
      HTTParty.send(method, "#{@base_url}#{args[:url]}", body: @args[:options], basic_auth: @auth)
    end

    def error_message(response)
      %(Pin API returned code #{response.code} for #{@base_url}, with error: '#{response.body}')
    end
  end
end
