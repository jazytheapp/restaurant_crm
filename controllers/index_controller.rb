# frozen_string_literal: true

class IndexController < Base
  get '/' do
    { status: 0 }.to_json
  end
end

use IndexController
