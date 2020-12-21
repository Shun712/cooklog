module ApplicationHelper
  def full_title(page_title = '')  # full_titleメソッドを定義
    base_title = 'クックログ'
    if page_title.blank?
      base_title  # トップページはタイトル「クックログ」
    else
      "#{page_title} - #{base_title}" # トップ以外のページはタイトル「利用規約 - クックログ」（例）
    end
  end
end
