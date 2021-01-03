require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  
  it "createアクションは実行できず、ログインページへリダイレクトすること" do
    expect {
      post relationships_path
    }.not_to change(Relationship, :count)
    expect(response).to redirect_to login_path
  end
  
  it "destroyアクションは実行できず、ログインページへリダイレクトすること" do
    expect {
      delete relationship_path(user)
    }.not_to change(Relationship, :count)
    expect(response).to redirect_to login_path
  end
end
