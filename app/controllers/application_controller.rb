class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :update_sanitized_params, if: :devise_controller?
  before_filter :get_places_left

  #accept additional attribute for user table
  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:firstname, :surname, :email, :password, :password_confirmation, :confirm_payment)}
    # devise_parameter_sanitizer.for(:account_update) {|u| u.permit(..)}
  end

  def active_user
    if current_user
      unless current_user.active?
        redirect_to events_path, notice: 'Velkommen! Inden for få dage vil vi bekræfte dit medlemsskab, og du vil få adgang til yderligere funktioner på siden'
      end
    end
  end

  def get_places_left
    @places_left = MAX_USERS - User.where(status: ['active', 'pending']).length 
    @bank_members = User.where(status: ['active','pending']).includes(:subscription).where( :subscriptions => { :user_id => nil } ).length
  end

  def get_permission
    if current_user
      unless current_user.can_do
        if current_user.status == 'passive'
          message = 'Du er ikke aktiv medlem af Tinkuy'
        else
          message = 'Dit medlemsskab understøtter desværre ikke denne handling'
        end
        redirect_to :back, notice: message
      end
    end
  end

end
