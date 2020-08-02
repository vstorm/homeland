class ConfirmationsController < Devise::ConfirmationsController
  before_action :require_no_sso!

  def create
    self.resource = resource_class.new(resource_params.permit(:email))
    unless verify_complex_captcha?(self.resource)
      return render "devise/confirmations/new"
    end

    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?
    if successfully_sent?(resource)
      respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end
end