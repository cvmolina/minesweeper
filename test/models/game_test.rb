require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test 'game is invalid without attributes set' do
    game = Game.new
    assert_not game.valid?
    assert_not game.errors[:width].empty?
    assert_not game.errors[:height].empty?
    assert_not game.errors[:num_mines].empty?
    assert_not game.errors[:user].empty?
  end

  test 'game is valid with attributes set' do
    game = Game.new width: 2, height: 2, num_mines: 1, user: users(:david)
    assert game.valid?
  end

  test 'game is valid with number of mines below game cells number' do
    (1..5).each do |num_mines|
      game = Game.new width: 2, height: 3, num_mines: num_mines, user: users(:david)
      assert game.valid?
    end
  end

  test 'game is invalid with too many mines' do
    [4, 5, 10, 100].each do |num_mines|
      game = Game.new width: 2, height: 2, num_mines: num_mines, user: users(:david)
      assert_not game.valid?
    end
  end

  test 'converting to an array with #to_a' do
    # TODO: avoid duplication
    game = Game.new width: 2, height: 2, num_mines: 2, user: users(:david)
    assert_equal game.to_a, [[' ', ' '], [' ', ' ']]
    game.to_a.flatten.each { |c| assert_valid_cell_value c }

    game = Game.new width: 2, height: 3, num_mines: 2, user: users(:david)
    assert_equal game.to_a, [[' ', ' '], [' ', ' '], [' ', ' ']]
    game.to_a.flatten.each { |c| assert_valid_cell_value c }

    game = Game.new width: 3, height: 2, num_mines: 2, user: users(:david)
    assert_equal game.to_a, [[' ', ' ', ' '], [' ', ' ', ' ']]
    game.to_a.flatten.each { |c| assert_valid_cell_value c }
  end

  test 'generate a game with n mines' do
    w, h = 4, 5
    (1..(w * h - 1)).each do |num_mines|
      game = Game.new width: w, height: h, num_mines: num_mines, user: users(:david)
      result = game.generate!

      # result grid has w*h size
      assert result.size, w * h

      # result is asign to grid attribute
      assert_equal result, game.grid

      # generated cells contains valid values
      result.chars.each { |c| assert_valid_cell_value c }
    end
  end

  test 'do not generate on invalid game' do
    game = Game.new width: 2, height: 2, num_mines: 10, user: users(:david)
    assert_raises(RuntimeError) { game.generate! }
  end

  private

  def assert_valid_cell_value(char)
    assert_match /[012345678*\s]/, char, "not a valid cell value: #{char}"
  end
end
