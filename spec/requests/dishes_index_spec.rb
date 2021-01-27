require "rails_helper"

RSpec.describe "料理一覧ページ", type: :request do
  let!(:user) { create(:user) }
  let!(:dish) { create(:dish, user: user) }

  context "ログインしているユーザーの場合" do
    it "レスポンスが正常に表示されること" do
      login_for_request(user)
      get dishes_path
      expect(response).to have_http_status "200"
      expect(response).to render_template('dishes/index')
    end
  end

  context "ログインしていないユーザーの場合" do
    it "ログイン画面にリダイレクトすること" do
      get dishes_path
      expect(response).to have_http_status "302"
      expect(response).to redirect_to login_path
    end
  end

  context "検索機能" do
    context "ログインしている場合" do
      before do
        login_for_system(user)
        visit root_path
      end

      it "ログイン後の各ページに検索窓が表示されていること" do
        expect(page).to have_css 'form#dish_search'
        visit about_path
        expect(page).to have_css 'form#dish_search'
        visit use_of_terms_path
        expect(page).to have_css 'form#dish_search'
        visit users_path
        expect(page).to have_css 'form#dish_search'
        visit user_path(user)
        expect(page).to have_css 'form#dish_search'
        visit edit_user_path(user)
        expect(page).to have_css 'form#dish_search'
        visit following_user_path(user)
        expect(page).to have_css 'form#dish_search'
        visit followers_user_path(user)
        expect(page).to have_css 'form#dish_search'
        visit dishes_path
        expect(page).to have_css 'form#dish_search'
        visit dish_path(dish)
        expect(page).to have_css 'form#dish_search'
        visit new_dish_path
        expect(page).to have_css 'form#dish_search'
        visit edit_dish_path(dish)
        expect(page).to have_css 'form#dish_search'
      end

      it "フィードの中から検索ワードに該当する結果が表示されること" do
        create(:dish, name: 'かに玉', user: user)
        create(:dish, name: 'かに鍋', user: other_user)
        create(:dish, name: '野菜炒め', user: user)
        create(:dish, name: '野菜カレー', user: other_user)

        # 誰もフォローしない場合
        fill_in 'q_name_cont', with: 'かに'
        click_button '検索'
        expect(page).to have_css 'h3', text: "”かに”の検索結果：1件"
        within find('.dishes') do
          expect(page).to have_css 'li', count: 1
        end
        fill_in 'q_name_cont', with: '野菜'
        click_button '検索'
        expect(page).to have_css 'h3', text: "”野菜”の検索結果：1件"
        within find('.dishes') do
          expect(page).to have_css 'li', count: 1
        end

        # other_userをフォローする場合
        user.follow(other_user)
        fill_in 'q_name_cont', with: 'かに'
        click_button '検索'
        expect(page).to have_css 'h3', text: "”かに”の検索結果：2件"
        within find('.dishes') do
          expect(page).to have_css 'li', count: 2
        end
        fill_in 'q_name_cont', with: '野菜'
        click_button '検索'
        expect(page).to have_css 'h3', text: "”野菜”の検索結果：2件"
        within find('.dishes') do
          expect(page).to have_css 'li', count: 2
        end
      end

      it "検索ワードを入れずに検索ボタンを押した場合、料理一覧が表示されること" do
        fill_in 'q_name_cont', with: ''
        click_button '検索'
        expect(page).to have_css 'h3', text: "料理一覧"
        within find('.dishes') do
          expect(page).to have_css 'li', count: Dish.count
        end
      end
    end

    context "ログインしていない場合" do
      it "検索窓が表示されないこと" do
        visit root_path
        expect(page).not_to have_css 'form#dish_search'
      end
    end
  end
end
