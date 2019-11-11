require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def generate_grid
    grid = []
    6.times { grid << %w(B C D F G H J K L M N P Q R S T V W X Z).sample }
    4.times { grid << %w(A E I O U Y).sample}
    grid.shuffle
  end

  def word_in_grid(attempt, grid)
    grid_hash = Hash.new(0)
    attempt_hash = Hash.new(0)
    attempt_arr = attempt.split('')
    grid.each { |letter| grid_hash[letter] += 1 }
    attempt_arr.each { |letter| attempt_hash[letter.upcase] += 1 }
    attempt_hash.all? do |letter|
      letter[1] <= grid_hash[letter[0]]
    end
  end

  def parsed_answer(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    JSON.parse(open(url).read)
  end

  def new
    @letters = generate_grid
  end

  def score
    @letters = params[:letters]
    @answer = params[:answer].upcase
    @success = parsed_answer(@answer)["found"]
    @belongs = word_in_grid(@answer, @letters.split)
    @string_letters = "#{@letters.split[0]}"
    @letters.split[1..9].each { |letter| @string_letters << ", #{letter}" }
    @score = @answer.length * @answer.length
    if session[:score] == nil
      session[:score] = @score
    else
      session[:score] += @score
    end
  end
end
