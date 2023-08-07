class SessionsController < ApplicationController
   
  
    def create
        password = params[:password]
        if password == "goda"
          session[:admin] = true
          redirect_to admin_path 
        else
          flash[:alert] = "パスワードが違います。"
          redirect_to root_path 
        end
      end
  

  end
  