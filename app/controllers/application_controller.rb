class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def check_user_is_admin
    unless Current.user.admin?
      redirect_to root_path, alert: "Requisição inválida, consulte o administrador do serviço."
    end
  end
end
