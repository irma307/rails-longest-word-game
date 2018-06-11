require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
  end

  def score
    session[:score] = session[:score] || 0
    @letters = params[:letters]
    count = included?(params[:longest_word], @letters)
    english_word = english_word?(params[:longest_word])
    if count && !english_word
      @result = { message: "Sorry but #{params[:longest_word]} does not seem to be a valid English word...", score: session[:score] }
    elsif !count && english_word
      @result = { message: "Sorry but #{params[:longest_word]} can't be built out of #{@letters}", score: session[:score] }
    else
      @result = { message: "Congratulations! #{params[:longest_word]} is a valid English word!", score: adding_score(params[:longest_word]) }
    end
    session[:score]
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    return json['found']
  end

  def adding_score(guess)
    points = guess.length
    session[:score] += points
  end
end
