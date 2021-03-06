require 'rails_helper'

RSpec.feature 'User can book a showtime' do
  scenario 'they fill out the order form and successfully book the showtime' do
    movie = create(:movie)
    auditorium = create(:auditorium)
    showtime = create(:showtime, movie: movie, auditorium: auditorium)
    card_number = CreditCardValidations::Factory.random(:visa)

    expect(Order.count).to eq 0
    expect(showtime.tickets_available).to eq 160

    visit new_order_path(showtime: showtime)

    within('#new-showtime-order-form') do
      fill_in 'First Name', with: 'David'
      fill_in 'Last Name', with: 'T'
      fill_in 'Email Address', with: 'david@example.com'
      fill_in 'Credit Card Number', with: card_number
      fill_in 'Credit Card Expiration Date', with: '03/19'
      click_button 'Book Showtime'
    end

    expect(current_path).to eq showtimes_path
    expect(Order.count).to eq 1
    showtime.reload
    expect(showtime.tickets_available).to eq 159

    order = Order.last

    within('.alert') do
      expect(page).to have_content "Thanks for your order #{order.first_name}!
      A confirmation email has been sent to #{order.email}."
    end
  end

  scenario 'they cannot book an order if there are no tickets available' do
    movie = create(:movie)
    auditorium = create(:auditorium)
    showtime = create(
      :showtime,
      movie: movie,
      auditorium: auditorium,
      tickets_available: 0
    )
    card_number = CreditCardValidations::Factory.random(:visa)

    expect(Order.count).to eq 0
    expect(showtime.tickets_available).to eq(0)

    visit new_order_path(showtime: showtime)

    within('#new-showtime-order-form') do
      fill_in 'First Name', with: 'David'
      fill_in 'Last Name', with: 'T'
      fill_in 'Email Address', with: 'david@example.com'
      fill_in 'Credit Card Number', with: card_number
      fill_in 'Credit Card Expiration Date', with: '03/19'
      click_button 'Book Showtime'
    end

    expect(current_path).to eq showtimes_path
    expect(Order.count).to eq 0
    expect(showtime.tickets_available).to eq(0)

    within('.alert') do
      expect(page).to have_content 'Sorry, there are no more tickets available.'
    end
  end
end
