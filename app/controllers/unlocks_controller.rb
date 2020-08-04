
class UnlocksController < Devise::UnlocksController
  before_action :require_no_sso!

  def create
    self.resource = resource_class.new(resource_params.permit(:email))
    unless verify_complex_captcha?(self.resource)
      return render "devise/unlocks/new"
    end

    self.resource = resource_class.send_unlock_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_unlock_instructions_path_for(resource))
    else
      respond_with(resource)
    end
  end
end