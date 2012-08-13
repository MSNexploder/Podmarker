module Api
  module V2
    class UsersController < ApplicationController
      before_filter :authenticate, only: ['verify']
      before_filter :fix_params_parsing, only: ['create']

      def verify
        respond_to do |format|
            format.json { render json: current_user }
          end
      end

      def create
        # user already exists
        if User.exists? username: params[:username]
          render :nothing => true, :status => :conflict
          return
        end

        # create user
        user = User.new(params.slice(:username, :password))
        if user.save
          render :nothing => true, :status => :created
        else
          respond_to do |format|
            format.json { render json: user.errors.full_messages, :status => :unprocessable_entity }
          end
        end
      end
    end
  end
end
