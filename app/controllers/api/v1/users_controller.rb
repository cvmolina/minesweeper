class Api::V1::UsersController < ApplicationController
  # GET /api/v1/users
  def index
    json_response User.all
  end
end
