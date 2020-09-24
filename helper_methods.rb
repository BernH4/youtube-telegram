module Helpers

  def fullname(user)
    fullname = "#{user.first_name} #{user.last_name}"
    # only append username if the user actually has one
    fullname += " (#{user.username})" if user.username
    fullname
  end

end
