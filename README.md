# [simple_pin]()
A simple gem for creating customers and charges using pin-payments [pin.net.au API](https://pin.net.au/)

[![Gem Version](https://badge.fury.io/rb/simple_pin.svg)](https://badge.fury.io/rb/simple_pin)

based on [dNitza's](https://github.com/dNitza) [pin_up](https://github.com/dNitza/pin_up)

## Install

`gem install simple_pin`

or add: `gem 'pin_up'` to your Gemfile.

## API

simple_pin provides a simple wrapper around pin's 3 main endpoints:

- [customers](https://pin.net.au/docs/api/customers)
- [charges](https://pin.net.au/docs/api/charges)
- [cards](https://pin.net.au/docs/api/cards)

## Usage

##### initialize Pin

    pin = SimplePin::Pin.new(ENV['PIN_SECRET_ID'], :test)

Pass in your PIN Secret Id and the environment (:live or :test). The default is :test.

## Cards

##### Create A Card

    card_details = {number: "4200000000000000", expiry_month: "12", expiry_year: "2020", cvc: "123", name: "Roland Robot", address_line1: "123 Fake Road", address_line2: "", address_city: "Melbourne", address_postcode: "1223", address_state: "Vic", address_country: "AU"}

    # create a card in Pin and get the token
    card_response = pin.create_card(card_details)

Will return a card_token that can be stored against a customer.

## Charges

##### Create A Charge

    card_token = card_response['token']

    charge = {email: "email@example.com", description: "Description", amount: "400", currency: "AUD", ip_address: "127.0.0.1", card_token: card_token   }

    pin.create_charge(charge)

Created a charge with a given card token and charge details

## Customers

##### Create A Customer

    card_details = {number: "5520000000000000", expiry_month: "12", expiry_year: "2018", cvc: "123", name: "Roland TestRobot", address_line1: "123 Fake Road", address_line2: "", address_city: "Melbourne", address_postcode: "1223", address_state: "Vic", address_country: "AU"}

    card = Pin::Card.create(card_details)
    Pin::Customer.create('email@example.com',card['token'])

Create a customer with a given card token and email

    card_options = {
      email: 'email@example.com',
      card_token: card_token
    }
    customer = pin.create_customer(card_options)

Charge the customer, Could be a recurring payment with a cron task using the stored customer_token.

    charge = {email: "email@example.com", description: "Description", amount: "400", currency: "AUD", ip_address: "127.0.0.1", customer_token: customer['token']   }

    pin.create_charge(charge)

## Pin Errors

Returns an error object with a `response` attribute. 

The response is the raw response from Pin (useful for logging).

## Example

##### An example of using SimplePin in Rails 

A Donations Controller sets up a customer for a recurring payment or a one-off payment.

```rb
class DonationsController < ApplicationController

  def create
    @donation = Donation.new(donation_params)

    if @donation.save
      res = create_donation
      redirect_to donation_path(@donation), notice: 'Thank you for your donation.' if res['success']
    else
      render 'edit'
    end
  end

  def create_donation
    # set up the Card details
    card_details = {number: @donation.credit_card_number, expiry_month: @donation.expiry_month, expiry_year: @donation.expiry_year, cvc: @donation.cvc, name: @donation.user_name, address_line1: "123 Fake Road", address_line2: "", address_city: "Melbourne", address_postcode: "1223", address_state: "Vic", address_country: "AU"}

    # initialize Simple Pin
    pin = SimplePin::Pin.new(ENV['PIN_SECRET_ID'], :test)

    # create a card in Pin and get the token
    card_response = pin.create_card(card)

    if @donation.recurring
      monthy_charge(pin, card_response['token']) if current_user
    else
      one_off_charge(pin, card_response['token'])
    end
  end

  ##
  # Create a customer for monthly charging with a cron task
  ##
  def monthy_charge(pin, card_token)
    card_options = {
      email: @donation.email,
      card_token: card_token
    }
    customer = pin.create_customer(card_options)

    # charge customer for the first month's donation
    charge = {
      email: @donation.email,
      description: 'Test Donation',
      amount: @donation.amount,
      currency: 'AU',
      ip_address: '127.0.0.1',
      customer_token: customer['token']
    }
    pin.create_charge(charge)
  end

  ##
  # Create a one off charge with the given card details
  ##
  def one_off_charge(pin, card_token)
    charge = {
      email: @donation.email,
      description: 'Test Donation',
      amount: @donation.amount,
      currency: 'AU',
      ip_address: '127.0.0.1',
      card_token: card_token
    }
    pin.create_charge(charge)
  end
end
```

## License

[MIT](http://isekivacenz.mit-license.org/)
