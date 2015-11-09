class ErrorsController < ApplicationController
  def not_found
    @error_msg = "Keevah cannot find that page"
    render(status: 404)
  end

  def internal_server_error
    @error_msg = "Keevah is experiencing problems with it's server. Please"\
                 " try again later"
    render(status: 500)
  end
end
