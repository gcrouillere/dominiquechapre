class Article < ApplicationRecord
  belongs_to :user

  validates :name, presence: :true
  validates :title, presence: { if: -> { self.name == "article" } }
  validates :content, presence: { if: -> { self.name == "article" } }

  has_attachment :article_main_photo

  extend Mobility
  translates :content, type: :text, fallbacks: { fr: :en, en: :fr }, locale_accessors: [:en, :fr]
  translates :title, type: :string, fallbacks: { fr: :en, en: :fr }, locale_accessors: [:en, :fr]

  def to_param
    title_param = self.send(I18n.locale == :fr ? (title_fr.present? ? "title_fr" : (title_en.present? ? "title_en" : "title")) : (title_en.present? ? "title_en" : "title")) || ""
    [id, title_param.parameterize].join("-")
  end
end
