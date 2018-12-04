class ArticlesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def new
    @article = Article.new
  end

  def index
    @articles = Article.where("name LIKE ?", "%article%").order(updated_at: :desc)
  end

  def show
    @article = Article.find(params[:id])
    @comments = Article.where(name: "#{@article.id}-commentaire").order(updated_at: :desc)
    @twitter_url = request.original_url.to_query('url')
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirection_for_comment_and_articles
    else
      render :new
    end
  end

  def update
    @article = Article.find(params[:article][:id])
    @article.update(article_params)
    redirection_for_comment_and_articles
  end

  def destroy
    @article = Article.find(params[:id])
    reference_article = Article.where(id: @article.name.to_i).first
    @article.destroy
    redirection_for_comment_and_articles
  end

  private

  def article_params
    params.require(:article).permit(:content, :name, :user_id, :id, :article_main_photo, :title)
  end

  def redirection_for_comment_and_articles
    reference_article = Article.where(id: @article.name.to_i).first
    if @article.name.include? "article"
      redirect_to articles_path
    elsif @article.name.include? "commentaire"
      redirect_to article_path(reference_article)
    else
      redirect_to request.referrer
    end
  end
end
