
class InvitationCode < ApplicationRecord
  def self.verify(value)
    return self.exists? code: value
  end
end
