# frozen_string_literal: true

module Helpers
  def fullname(user)
    fullname = "#{user.first_name} #{user.last_name}"
    # only append username if the user actually has one
    user.username ? fullname + " (#{user.username})" : fullname
  end
end
