class RatingCalculator
  def initialize(store, questions)
    @store = store
    @questions = questions
  end

  def calculate
    identify_run
    prompt_and_store
    calculate_and_store_rating
    calculate_avg_rating
    do_report
  end

  def identify_run
    @store.transaction do
      @current_run = @store['run'].to_i + 1
      @store['run'] = @current_run
    end
  end

  def prompt_and_store
    @store.transaction do
      # Ask each question and get an answer from the user's input and store the answer.
      @questions.each_key do |question_key|
        print @questions[question_key]
        ans = gets.chomp
        @store[question_key] = ans
      end
    end
  end

  def calculate_and_store_rating
    @store.transaction do
      rating = 100 * count_of_yes / number_of_questions
      @store["rating_#{@current_run}"] = rating
    end
  end

  def calculate_avg_rating
    @store.transaction do
      sum = (1..@current_run).to_a.map do |run|
        @store["rating_#{run}"]
      end.sum

      @store['avg_rating'] = sum / @current_run
    end
  end

  def do_report
    @store.transaction do
      puts "@store: #{@store.inspect}"
      puts "current_run: #{@current_run}"
      rating = @store["rating_#{@current_run}"]
      puts "current_rating: #{rating}"
      avg_rating = @store['avg_rating']
      puts "avg_rating: #{avg_rating}"
    end
  end

  def count_of_yes
    answers = @questions.map do |question_key, _question|
      ans = @store[question_key].downcase
      ans == 'yes' || ans == 'y'
    end
    answers.count(true)
  end

  def number_of_questions
    @questions.keys.count
  end
end
