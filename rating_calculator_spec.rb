require 'spec_helper'
require './rating_calculator.rb'
require 'pstore'

RSpec.describe RatingCalculator do

  let(:store) do
    PStore.new('tendable_test.pstore')
  end

  let(:questions) do
    {
      "q1" => "Can you code in Ruby?",
      "q2" => "Can you code in JavaScript?",
      "q3" => "Can you code in Swift?",
      "q4" => "Can you code in Java?",
      "q5" => "Can you code in C#?"
    }
  end

  let(:calc) do
    RatingCalculator.new(store, questions)
  end

  context '#identify_run' do
    it 'increments run value and stores' do
      store.transaction do
        @prev_value = store['run'].to_i # => 0
      end

      calc.identify_run

      store.transaction do
        expect(store['run']).to eq(@prev_value + 1)
      end
    end
  end

  context '#calculate_and_store_rating' do
    it 'calculates rating with all yes' do
      store.transaction do
        store['q1'] = 'y'
        store['q2'] = 'Y'
        store['q3'] = 'Yes'
        store['q4'] = 'YES'
        store['q5'] = 'yEs'
      end

      calc.identify_run
      calc.calculate_and_store_rating

      store.transaction do
        expect(store['rating_1']).to eq(100)
      end
    end

    it 'calculates rating with 3 yes and 2 no' do
      store.transaction do
        store['q1'] = 'y'
        store['q2'] = 'n'
        store['q3'] = 'Yes'
        store['q4'] = 'N'
        store['q5'] = 'Y'
      end

      calc.identify_run
      calc.calculate_and_store_rating

      store.transaction do
        expect(store['rating_1']).to eq(60)
      end
    end

    it 'calculates rating with 2 yes and 3 no' do
      store.transaction do
        store['q1'] = 'y'
        store['q2'] = 'n'
        store['q3'] = 'Yes'
        store['q4'] = 'N'
        store['q5'] = 'no'
      end

      calc.identify_run
      calc.calculate_and_store_rating

      store.transaction do
        expect(store['rating_1']).to eq(40)
      end
    end

    it 'calculates rating with all no' do
      store.transaction do
        store['q1'] = 'n'
        store['q2'] = 'N'
        store['q3'] = 'No'
        store['q4'] = 'NO'
        store['q5'] = 'nO'
      end

      calc.identify_run
      calc.calculate_and_store_rating

      store.transaction do
        expect(store['rating_1']).to eq(0)
      end
    end
  end

  context '#calculate_avg_rating' do
    it 'calculates avg rating with 2 yes in 1st run and 4 yes in 2nd run' do
      ## 1st Run ##
      store.transaction do
        store['q1'] = 'y'
        store['q2'] = 'N'
        store['q3'] = 'Y'
        store['q4'] = 'no'
        store['q5'] = 'NO'
      end

      calc.identify_run
      calc.calculate_and_store_rating
      calc.calculate_avg_rating

      store.transaction do
        expect(store['rating_1']).to eq(40)
        expect(store['avg_rating']).to eq(40)
      end

      ## 2nd run ##
      store.transaction do
        store['q1'] = 'y'
        store['q2'] = 'yes'
        store['q3'] = 'Y'
        store['q4'] = 'YES'
        store['q5'] = 'NO'
      end

      calc.identify_run
      calc.calculate_and_store_rating
      calc.calculate_avg_rating

      store.transaction do
        expect(store['rating_2']).to eq(80)
        expect(store['avg_rating']).to eq(60)
      end
    end
  end

  after(:each) do
    File.delete('./tendable_test.pstore')
  end
end
