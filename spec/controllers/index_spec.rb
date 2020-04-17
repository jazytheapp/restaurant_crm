require 'spec_helper'

RSpec.describe 'index controller' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'get index' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq(
      {status: 0}.to_json()
    )
  end
end
