require 'rails_helper'

RSpec.describe "コメント機能", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:dish) { create(:dish) }
  let!(:comment) { create(:comment, user_id: user.id, dish: dish) }

  context "コメントの登録" do
    context "ログインしている場合" do
        before do
        login_for_request(user)
      end

      it "有効な内容のコメントが登録できること" do
        expect {
          post comments_path, params: { dish_id: dish.id,
                                        comment: { content: "最高です！" } }
        }.to change(dish.comments, :count).by(1)
      end

      it "無効な内容のコメントが登録できないこと" do
        expect {
          post comments_path, params: { dish_id: dish.id,
                                        comment: { content: "" } }
        }.not_to change(dish.comments, :count)
      end
    end

    context "ログインしていない場合" do
      it "コメントは登録できず、ログインページへリダイレクトすること" do
        expect {
          post comments_path, params: { dish_id: dish.id,
                                        comment: { content: "最高です！" } }
        }.not_to change(dish.comments, :count)
        expect(response).to redirect_to login_path
      end
    end
  end

  context "コメントの削除" do
    context "ログインしている場合" do
      context "コメントを作成したユーザーである場合" do
        it "コメントの削除ができること" do
          login_for_request(user)
          expect {
            delete comment_path(comment)
          }.to change(dish.comments, :count).by(-1)
        end
      end

      context "コメントを作成したユーザーでない場合" do
        it "コメントの削除はできないこと" do 
          login_for_request(other_user)
            expect {
              delete comment_path(comment)
            }.not_to change(dish.comments, :count)
          end
        end
      end

    context "ログインしていない場合" do
      it "コメントの削除はできず、ログインページへリダイレクトすること" do
        expect {
          delete comment_path(comment)
        }.not_to change(dish.comments, :count)
      end
    end

    context "コメントの登録＆削除" do
      it "自分の料理に対するコメントの登録＆削除が正常に完了すること" do
        login_for_system(user)
        visit dish_path(dish)
        fill_in "comment_content", with: "今日の味付けは大成功"
        click_button "コメント"
        within find("#comment-#{Comment.last.id}") do
          expect(page).to have_selector 'span', text: user.name
          expect(page).to have_selector 'span', text: '今日の味付けは大成功'
        end
        expect(page).to have_content "コメントを追加しました！"
        click_link "削除", href: comment_path(Comment.last)
        expect(page).not_to have_selector 'span', text: '今日の味付けは大成功'
        expect(page).to have_content "コメントを削除しました"
      end

      it "別ユーザーの料理のコメントには削除リンクが無いこと" do
        login_for_system(other_user)
        visit dish_path(dish)
        within find("#comment-#{comment.id}") do
          expect(page).to have_selector 'span', text: user.name
          expect(page).to have_selector 'span', text: comment.content
          expect(page).not_to have_link '削除', href: dish_path(dish)
        end
      end
    end
  end
end

